this model used in customer app, working fine.
during web admin dev, the model changes a lot.a



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';

class UserModel {
  final String id;

  String firstName;
  String lastName;
  String email;
  String phoneNumber;
  String profilePicture;
  String gender;
  String dateOfBirth;
  String role;
  String accountStatus;

  bool isGuest;
  String defaultAddressId;
  List<UserAddressModel> addresses;

  Timestamp? createdAt;
  Timestamp? updatedAt;
  Timestamp? lastLoginAt;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email = '',
    this.phoneNumber = '',
    this.profilePicture = '',
    this.gender = '',
    this.dateOfBirth = '',
    this.role = 'customer',
    this.accountStatus = 'active',
    this.isGuest = false,
    this.defaultAddressId = '',
    this.addresses = const [],
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.replaceAll(RegExp(r'\s+'), ' ');
  }

  bool get hasProfilePhoto => profilePicture.trim().isNotEmpty;

  bool get isLoggedInGuest => isGuest;

  UserAddressModel? get defaultAddress {
    if (addresses.isEmpty) return null;

    for (final address in addresses) {
      if (address.id == defaultAddressId) {
        return address;
      }
    }

    for (final address in addresses) {
      if (address.isDefault) {
        return address;
      }
    }

    return addresses.first;
  }

  static List<String> splitFullName(String fullName) {
    final cleaned = fullName.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (cleaned.isEmpty) {
      return ['', ''];
    }

    final parts = cleaned.split(' ');

    if (parts.length == 1) {
      return [parts.first, ''];
    }

    final firstName = parts.first;
    final lastName = parts.sublist(1).join(' ');

    return [firstName, lastName];
  }

  static UserModel fromFullName({
    required String id,
    required String fullName,
    String email = '',
    String phoneNumber = '',
    String profilePicture = '',
    String gender = '',
    String dateOfBirth = '',
    String role = 'customer',
    String accountStatus = 'active',
    bool isGuest = false,
    String defaultAddressId = '',
    List<UserAddressModel> addresses = const [],
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? lastLoginAt,
  }) {
    final parts = splitFullName(fullName);

    return UserModel(
      id: id,
      firstName: parts[0],
      lastName: parts[1],
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      gender: gender,
      dateOfBirth: dateOfBirth,
      role: role,
      accountStatus: accountStatus,
      isGuest: isGuest,
      defaultAddressId: defaultAddressId,
      addresses: addresses,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }

  static UserModel empty() => UserModel(
    id: '',
    firstName: '',
    lastName: '',
  );

  static UserModel guest() => UserModel(
    id: '',
    firstName: 'Guest',
    lastName: 'User',
    role: 'guest',
    accountStatus: 'guest',
    isGuest: true,
  );

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName.trim(),
      'LastName': lastName.trim(),
      'Email': email.trim(),
      'PhoneNumber': phoneNumber.trim(),
      'ProfilePicture': profilePicture.trim(),
      'Gender': gender.trim(),
      'DOB': dateOfBirth.trim(),
      'Role': role.trim().toLowerCase(),
      'AccountStatus': accountStatus.trim().toLowerCase(),
      'IsGuest': isGuest,
      'DefaultAddressId': defaultAddressId.trim(),
      'Addresses': addresses.map((e) => e.toJson()).toList(),
      'CreatedAt': createdAt,
      'UpdatedAt': updatedAt,
      'LastLoginAt': lastLoginAt,
    };
  }

  factory UserModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document,
      ) {
    final data = document.data();

    if (data == null) {
      return UserModel.guest();
    }

    return UserModel.fromMap(document.id, data);
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    final rawAddresses = (data['Addresses'] as List<dynamic>? ?? []);

    return UserModel(
      id: id,
      firstName: (data['FirstName'] ?? '').toString().trim(),
      lastName: (data['LastName'] ?? '').toString().trim(),
      email: (data['Email'] ?? '').toString().trim(),
      phoneNumber: (data['PhoneNumber'] ?? '').toString().trim(),
      profilePicture: (data['ProfilePicture'] ?? '').toString().trim(),
      gender: (data['Gender'] ?? '').toString().trim(),
      dateOfBirth: (data['DOB'] ?? '').toString().trim(),
      role: (data['Role'] ?? 'customer').toString().trim().toLowerCase(),
      accountStatus: (data['AccountStatus'] ?? 'active')
          .toString()
          .trim()
          .toLowerCase(),
      isGuest: data['IsGuest'] == true,
      defaultAddressId: (data['DefaultAddressId'] ?? '').toString().trim(),
      addresses: rawAddresses
          .map((e) => UserAddressModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      createdAt: data['CreatedAt'],
      updatedAt: data['UpdatedAt'],
      lastLoginAt: data['LastLoginAt'],
    );
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    String? gender,
    String? dateOfBirth,
    String? role,
    String? accountStatus,
    bool? isGuest,
    String? defaultAddressId,
    List<UserAddressModel>? addresses,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    Timestamp? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      accountStatus: accountStatus ?? this.accountStatus,
      isGuest: isGuest ?? this.isGuest,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}