import 'dart:convert';

import 'package:flutter/material.dart';
import '../data/categories.dart';
import '../models/grocery_item.dart';
import '../widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  var _error;

  void _removeItem(GroceryItem item) async {
    var index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'heroic-psyche-399016-default-rtdb.europe-west1.firebasedatabase.app', 'shopping-list/${item.id}.json');

    var response = await http.delete(url);

    if(response.statusCode >= 400){
      setState(() {
        _groceryItems.insert(index, item);
      });
    }

  }

  void _editItem(GroceryItem item) async {
    final isEdited = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (ctx) => NewItem(groceryItem: item),
      ),
    );

    if (isEdited == true) {
      setState(() {
        _loadItems();
      });
    }
  }

  void _loadItems() async {
    final url = Uri.https(
        'heroic-psyche-399016-default-rtdb.europe-west1.firebasedatabase.app', 'shopping-list.json');

    try {
      final response = await http.get(url);

      if(response.statusCode == 404){
        setState(() {
          _error = "Failed to fetch data. Please try again later";
        });
      }

      if(response.body == 'null'){
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic>? listData = json.decode(response.body);

        if (listData != null) {
          final List<GroceryItem> loadedItems = [];
          for (final item in listData.entries) {
            final category = categories.entries.firstWhere(
                    (element) => element.value.title == item.value['category']
            ).value;
            loadedItems.add(GroceryItem(
                id: item.key,
                name: item.value['name'],
                quantity: item.value['quantity'],
                category: category
            ));
          }

          setState(() {
            _groceryItems = loadedItems;
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load items');
      }
    } catch (error) {
      _error = "Something Went Wrong Please Try Again Late";
      print('Error loading items: $error');
      // You might want to show an error message to the user here
    }
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("No Items Added Yet"));

    if(_isLoading){
      content = const Center(child: CircularProgressIndicator(),);
    }

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

    if(_error != null) {
      content = _error;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (ctx) => const NewItem()),
              );

              if (result == true) {
                // If an item was added, reload the data
                _loadItems();
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