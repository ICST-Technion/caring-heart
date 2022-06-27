import 'package:nivapp/item_spec.dart';

abstract class InventoryServiceI {
  Future<Item> getItemByID(String id);
  Future<void> collectItem(id);
  Future<List<Item>> getCheckedItems();
}
