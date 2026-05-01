import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/customer/mb_customer_address.dart';

class AddressRepository {
  AddressRepository._();
  static final AddressRepository instance = AddressRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  Future<void> saveAddresses({
    required String uid,
    required List<UserAddressModel> addresses,
  }) async {
    final normalized = normalizeAddresses(addresses);

    String defaultAddressId = '';
    for (final address in normalized) {
      if (address.isDefault) {
        defaultAddressId = address.id;
        break;
      }
    }

    await userDoc(uid).set({
      'Addresses': normalized.map((e) => e.toJson()).toList(),
      'DefaultAddressId': defaultAddressId,
      'UpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  List<UserAddressModel> normalizeReorderedDefault({
    required List<UserAddressModel> addresses,
    required String defaultAddressId,
  }) {
    final reordered = addresses
        .map((e) => e.copyWith(isDefault: e.id == defaultAddressId))
        .toList();

    reordered.sort((a, b) {
      if (a.isDefault == b.isDefault) return 0;
      return a.isDefault ? -1 : 1;
    });

    return normalizeAddresses(reordered);
  }

  List<UserAddressModel> normalizeAddresses(List<UserAddressModel> input) {
    if (input.isEmpty) return input;

    final defaultCount = input.where((e) => e.isDefault).length;

    if (defaultCount == 0) {
      final first = input.first.copyWith(isDefault: true);
      return [first, ...input.skip(1)];
    }

    if (defaultCount == 1) {
      return input;
    }

    bool kept = false;
    return input.map((address) {
      if (address.isDefault && !kept) {
        kept = true;
        return address;
      }

      if (address.isDefault && kept) {
        return address.copyWith(isDefault: false);
      }

      return address;
    }).toList();
  }
}