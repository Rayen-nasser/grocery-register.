import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({Key? key, this.groceryItem});

  final GroceryItem? groceryItem;

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  late String _enteredName;
  late int _enteredQuantity;
  late Category _selectCategory;
  var _isSending = false;

  @override
  void initState() {
    super.initState();
    _enteredName = widget.groceryItem?.name ?? '';
    _enteredQuantity = widget.groceryItem?.quantity ?? 1;
    _selectCategory =
        widget.groceryItem?.category ?? categories[Categories.vegetables]!;
  }

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });

      final baseUrl = 'heroic-psyche-399016-default-rtdb.europe-west1.firebasedatabase.app';
      final endpoint = widget.groceryItem != null
          ? 'shopping-list/${widget.groceryItem!.id}.json'
          : 'shopping-list.json';
      final url = Uri.https(baseUrl, endpoint);

      final body = json.encode({
        'name': _enteredName,
        'quantity': _enteredQuantity,
        'category': _selectCategory.title
      });

      try {
        final response = widget.groceryItem != null
            ? await http.put(url, headers: {'Content-Type': 'application/json'}, body: body)
            : await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);

        if (response.statusCode >= 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.groceryItem != null ? 'Item updated successfully' : 'Item added successfully')),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to ${widget.groceryItem != null ? 'update' : 'add'} item');
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $error')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSending = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groceryItem == null ? "Add Item" : "Edit Item"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _enteredName,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: "Name",
                ),
                maxLength: 50,
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _enteredName = value!;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: const InputDecoration(
                        labelText: "Quantity",
                      ),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a quantity';
                        }
                        int? quantity = int.tryParse(value);
                        if (quantity == null) {
                          return 'Please enter a valid number';
                        }
                        if (quantity <= 0) {
                          return 'Quantity must be greater than 0';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: DropdownButtonFormField<Category>(
                      value: _selectCategory,
                      items: categories.entries.map((entry) {
                        return DropdownMenuItem<Category>(
                          value: entry.value,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: entry.value.color,
                              ),
                              const SizedBox(
                                width: 6,
                              ),
                              Text(entry.value.title)
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectCategory = value!;
                        });
                      },
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 18,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                      onPressed: _isSending ? null : _saveItem,
                      child: _isSending
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(),
                            )
                          : Text(widget.groceryItem == null
                              ? 'Add Item'
                              : 'Save Changes')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
