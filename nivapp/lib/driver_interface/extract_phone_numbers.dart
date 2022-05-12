// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class PhoneNumberExtraction {
  final String phoneNumber;
  final String name;
  PhoneNumberExtraction({
    required this.phoneNumber,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PhoneNumberExtraction &&
        other.phoneNumber == phoneNumber &&
        other.name == name;
  }

  @override
  int get hashCode => phoneNumber.hashCode ^ name.hashCode;
}

class ExtractPhoneNumbers {
  List<PhoneNumberExtraction> call(String phonesWithText) {
    final reg = RegExp(
        r"(?:([^-]+?)-\s*(0?(?:(?:[23489]{1}[0-9]{7})|5[0-9]{8})))(?:,|$|\s)");
    if (!reg.hasMatch(phonesWithText)) {
      return [];
    }
    return reg
        .allMatches(phonesWithText)
        .map((match) => PhoneNumberExtraction(
            phoneNumber: match.group(2)!, name: match.group(1)!))
        .toList();
  }
}
