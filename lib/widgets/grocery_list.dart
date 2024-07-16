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
  late Future<List<GroceryItem>> _loadedItems;
  var _error;

  @override
  void initState() {
    super.initState();
    _loadedItems = _loadItems();
  }

  void _removeItem(GroceryItem item) async {
    var index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
        'heroic-psyche-399016-default-rtdb.europe-west1.firebasedatabase.app', 'shopping-list/${item.id}.json');

    var response = await http.delete(url);

    if (response.statusCode >= 400) {
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
        _loadedItems = _loadItems();
      });
    }
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https(
        'heroic-psyche-399016-default-rtdb.europe-west1.firebasedatabase.app', 'shopping-list.json');

    try {
      final response = await http.get(url);

      if (response.statusCode == 404) {
        setState(() {
          _error = "Failed to fetch data. Please try again later";
        });
        return [];
      }

      if (response.body == 'null') {
        return [];
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
          });
          return loadedItems;
        } else {
          return [];
        }
      } else {
        throw Exception('Failed to load items');
      }
    } catch (error) {
      setState(() {
        _error = "An error occurred: $error";
      });
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
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
                setState(() {
                  _loadedItems = _loadItems();
                });
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder<List<GroceryItem>>(
        future: _loadedItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const Center(child: Text("No items added yet."));
          }

          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (ctx, index) {
              final item = snapshot.data![index];
              return Dismissible(
                key: ValueKey(item.id),
                onDismissed: (direction) {
                  _removeItem(item);
                },
                child: ListTile(
                  title: Text(item.name),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: item.category.color,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.quantity.toString(),
                        style: const TextStyle(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editItem(item),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
