import 'package:flutter/material.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

class Grocery extends StatelessWidget {
  const Grocery({super.key, required this.groceryItem});

  final GroceryItem groceryItem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: groceryItem.category.color,
          ),
          const SizedBox(width: 10,),
          Text(groceryItem.name),
          const Spacer(), // This pushes the next widget to the far right
          Text(groceryItem.quantity.toString()),
        ],
      ),
    );
  }
}
