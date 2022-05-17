import 'package:flutter_test/flutter_test.dart';
import 'package:nivapp/pickup_report.dart';

void main() {
  group('PickupReport', () {
    test('returns same object after toJson and then fromJson', () async {
      final originalPickUpReport = PickupReport.collected(
          itemID: 'id',
          comments: 'comments',
          collectedItems: {
            'item1': 1,
            'item2': 2,
          });
      final afterToFromJson =
          PickupReport.fromJson(originalPickUpReport.toJson(), 'id');
      // print(
      // '${originalPickUpReport.collectedItems!['item1']}, ${afterToFromJson.collectedItems!['item1']}');
      expect(originalPickUpReport, equals(afterToFromJson));
    });
  });
}
