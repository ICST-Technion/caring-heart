import 'package:nivapp/pickup_point.dart';
import 'package:nivapp/format_date.dart';
import 'package:nivapp/item_spec.dart';



abstract class InventoryServiceI{
  Future<Item> getItemByID(String id);
  Future<void> collectItem(id);
  Future<List<Item>> getCheckedItems();
  Future<List<Item>> createItemListFromInventory(
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs);
}