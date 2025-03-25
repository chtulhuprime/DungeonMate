import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/PlayerScreens/item_detail_screen.dart';
import 'inventory_provider.dart';
import 'item.dart';

class InventoryItemCard extends StatelessWidget {
  final Item item;

  const InventoryItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Consumer<InventoryProvider>(
      builder: (context, provider, child) {
        return Card(
          child: ListTile(
            leading: Image.asset(
              item.imageUrl, // Вот здесь используется путь из вашего Item
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.shield); // Fallback иконка
              },
            ),
            title: Text(item.name),
            subtitle: Text(item.description),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ItemDetailsScreen(item: item),
                ),
              );
            },
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    provider.removeItemFromCharacter(item);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Предмет ${item.name} использован')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => provider.removeItemFromCharacter(item),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}