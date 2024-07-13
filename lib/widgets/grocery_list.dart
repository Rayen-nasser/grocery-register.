import 'package:flutter/material.dart';
import '../models/grocery_item.dart';
import '../data/dummy_items.dart';
import '../widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [...groceryItems];

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  void _editItem(GroceryItem item) async {
    final editedItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (ctx) => NewItem(groceryItem: item,),
      ),
    );
    if (editedItem != null) {
      setState(() {
        final index = _groceryItems.indexWhere((element) => element.id == item.id);
        if (index != -1) {
          _groceryItems[index] = editedItem;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("No Items Added Yet"));

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _groceryItems[index].quantity.toString(),
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editItem(_groceryItems[index]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () async {
              final newItem = await Navigator.push<GroceryItem>(
                context,
                MaterialPageRoute(builder: (ctx) => const NewItem()),
              );
              if (newItem != null) {
                setState(() {
                  _groceryItems.add(newItem);
                });
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}