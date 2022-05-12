import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:nivapp/driver_interface/extract_phone_numbers.dart';
import 'package:nivapp/item_spec.dart';
import 'package:nivapp/services/inventory_service.dart';
import 'package:test/test.dart';

void main() {
  group('ExtractPhoneNumbers', () {
    test('should extract phone number with "name - phone" format', () async {
      final extractor = ExtractPhoneNumbers();
      expect(
          extractor("a-0547693775"),
          equals(
              [PhoneNumberExtraction(name: "a", phoneNumber: "0547693775")]));
    });
    test('should return empty list if not in the right format', () {
      final extractor = ExtractPhoneNumbers();
      expect(extractor("a 0547693775"), isEmpty);
    });
    test(
        'should extract two phone number with "name1 - phone1, name2-phone2" format',
        () async {
      final extractor = ExtractPhoneNumbers();
      expect(
          extractor("a-0547693775,b-048120593"),
          equals([
            PhoneNumberExtraction(name: "a", phoneNumber: "0547693775"),
            PhoneNumberExtraction(name: "b", phoneNumber: "048120593")
          ]));
    });
  });
}
