import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/character.dart';
import '../../widget/inventory_item.dart';
import '../../widget/inventory_provider.dart';
import '../../widget/item.dart';

class InventoryScreen extends StatefulWidget {
  final Character character;

  const InventoryScreen({super.key, required this.character});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<InventoryProvider>(context, listen: false);
    provider.selectCharacter(widget.character);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Инвентарь ${widget.character.name}'),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, child) {
          if (provider.characterItems.isEmpty) {
            return const Center(child: Text('Инвентарь пуст'));
          }

          return ListView.builder(
            itemCount: provider.characterItems.length,
            itemBuilder: (context, index) {
              final item = provider.characterItems[index];
              return InventoryItemCard(item: item);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddItemDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Добавить предмет'),
          content: FutureBuilder(
            future: provider.loadAllItems(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.allItems.length,
                  itemBuilder: (context, index) {
                    final item = provider.allItems[index];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(item.description),
                      onTap: () {
                        provider.addItemToCharacter(item);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
          ],
        );
      },
    );
  }
}