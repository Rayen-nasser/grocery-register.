import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key,  this.groceryItem});

  final GroceryItem? groceryItem;

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  late String _enteredName;
  late int _enteredQuantity;
  late Category _selectCategory;

  @override
  void initState() {
    super.initState();
    _enteredName = widget.groceryItem?.name ?? '';
    _enteredQuantity = widget.groceryItem?.quantity ?? 1;
    _selectCategory = widget.groceryItem?.category ?? categories[Categories.vegetables]!;
  }

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      Navigator.of(context).pop(GroceryItem(
          id: widget.groceryItem?.id ?? DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectCategory
      ));
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
                        label: Text("Quantity"),
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
                    child: DropdownButtonFormField(
                      value: _selectCategory,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                              value: category.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    color: category.value.color,
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  Text(category.value.title)
                                ],
                              ))
                      ],
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
                  TextButton(onPressed: () {
                    _formKey.currentState!.reset();
                  }, child: const Text('Reset')),
                  const SizedBox(
                    width: 10,
                  ),
                  ElevatedButton(
                      onPressed: _saveItem,
                      child: Text(widget.groceryItem == null ? 'Add Item' : 'Save Changes')
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}