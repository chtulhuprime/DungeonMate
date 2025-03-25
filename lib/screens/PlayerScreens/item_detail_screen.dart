import 'package:flutter/material.dart';

import '../../widget/item.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Item item;

  const ItemDetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Image.asset(
                  item.imageUrl,
                  width: 150,
                  height: 150,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.shield, size: 100);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Описание:', style: Theme.of(context).textTheme.titleLarge),
            Text(item.fullDescription),
            const SizedBox(height: 20),
            Text('Характеристики:', style: Theme.of(context).textTheme.titleLarge),
            ...item.characteristics.entries.map((e) =>
                Text('${e.key}: ${e.value}')).toList(),
          ],
        ),
      ),
    );
  }
}