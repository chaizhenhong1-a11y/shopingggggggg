import 'package:flutter/material.dart';

import '../../domain/models/category_model.dart';

class CategorySection extends StatelessWidget {
  final List<CategoryModel> categories;

  const CategorySection({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: categories.map((category) {
          return InkWell(
            onTap: () {},
            borderRadius: BorderRadius.circular(17),
            child: Column(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: category.backgroundColor,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    category.icon,
                    color: category.iconColor,
                    size: 27,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}