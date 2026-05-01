import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_models/shared_models.dart';

class UserRoles {
  static const String customer = 'customer';
  static const String admin = 'admin';
  static const String superAdmin = 'super_admin';
  static const String guest = 'guest';
}

class UserStatuses {
  static const String active = 'active';
  static const String inactive = 'inactive';
  static const String blocked = 'blocked';
  static const String guest = 'guest';
}

class UserModel {
  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email = '',
    this.phoneNumber = '',
    this.profilePicture = '',
    this.gender = '',
    this.dateOfBirth = '',
    this.role = UserRoles.customer,
    this.accountStatus = UserStatuses.active,
    this.isGuest = false,
    this.defaultAddressId = '',
    this.addresses = const [],
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final String gender;
  final String dateOfBirth;
  final String role;
  final String accountStatus;
  final bool isGuest;
  final String defaultAddressId;
  final List<UserAddressModel> addresses;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;
  final Timestamp? lastLoginAt;

  String get fullName {
    final name = '$firstName $lastName'.trim();
    return name.replaceAll(RegExp(r'\s+'), ' ');
  }

  String get displayNameForAdmin {
    if (fullName.trim().isNotEmpty) return fullName;
    if (email.trim().isNotEmpty) return email.trim();
    if (phoneNumber.trim().isNotEmpty) return phoneNumber.trim();
    return 'Unnamed User';
  }

  String get initials {
    final name = displayNameForAdmin.trim();
    if (name.isEmpty) return '?';
    return name.substring(0, 1).toUpperCase();
  }

  bool get hasProfilePhoto => profilePicture.trim().isNotEmpty;
  bool get isLoggedInGuest => isGuest;

  bool get isActive => accountStatus == UserStatuses.active;
  bool get isInactive => accountStatus == UserStatuses.inactive;
  bool get isBlocked => accountStatus == UserStatuses.blocked;

  bool get isCustomer => role == UserRoles.customer;
  bool get isAdmin => role == UserRoles.admin;
  bool get isSuperAdmin => role == UserRoles.superAdmin;
  bool get isAdminLike => isAdmin || isSuperAdmin;

  String get prettyRole => _prettyValue(role);
  String get prettyStatus => _prettyValue(accountStatus);

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

  static UserModel empty() => const UserModel(
    id: '',
    firstName: '',
    lastName: '',
  );

  static UserModel guest() => const UserModel(
    id: '',
    firstName: 'Guest',
    lastName: 'User',
    role: UserRoles.guest,
    accountStatus: UserStatuses.guest,
    isGuest: true,
  );

  static UserModel normalized(UserModel user) {
    return user.copyWith(
      firstName: user.firstName.trim(),
      lastName: user.lastName.trim(),
      email: user.email.trim(),
      phoneNumber: user.phoneNumber.trim(),
      profilePicture: user.profilePicture.trim(),
      gender: user.gender.trim(),
      dateOfBirth: user.dateOfBirth.trim(),
      role: normalizeRole(user.role),
      accountStatus: normalizeStatus(user.accountStatus),
      defaultAddressId: user.defaultAddressId.trim(),
    );
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
    String role = UserRoles.customer,
    String accountStatus = UserStatuses.active,
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
      role: normalizeRole(role),
      accountStatus: normalizeStatus(accountStatus),
      isGuest: isGuest,
      defaultAddressId: defaultAddressId,
      addresses: addresses,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'FirstName': firstName.trim(),
      'LastName': lastName.trim(),
      'Email': email.trim(),
      'PhoneNumber': phoneNumber.trim(),
      'ProfilePicture': profilePicture.trim(),
      'Gender': gender.trim(),
      'DOB': dateOfBirth.trim(),
      'Role': normalizeRole(role),
      'AccountStatus': normalizeStatus(accountStatus),
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
      id: id.trim(),
      firstName: (data['FirstName'] ?? '').toString().trim(),
      lastName: (data['LastName'] ?? '').toString().trim(),
      email: (data['Email'] ?? '').toString().trim(),
      phoneNumber: (data['PhoneNumber'] ?? '').toString().trim(),
      profilePicture: (data['ProfilePicture'] ?? '').toString().trim(),
      gender: (data['Gender'] ?? '').toString().trim(),
      dateOfBirth: (data['DOB'] ?? '').toString().trim(),
      role: normalizeRole((data['Role'] ?? UserRoles.customer).toString()),
      accountStatus: normalizeStatus(
        (data['AccountStatus'] ?? UserStatuses.active).toString(),
      ),
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

  static String normalizeRole(String value) {
    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'super admin':
      case 'super_admin':
        return UserRoles.superAdmin;
      case 'admin':
        return UserRoles.admin;
      case 'guest':
        return UserRoles.guest;
      default:
        return UserRoles.customer;
    }
  }

  static String normalizeStatus(String value) {
    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'blocked':
        return UserStatuses.blocked;
      case 'inactive':
        return UserStatuses.inactive;
      case 'guest':
        return UserStatuses.guest;
      default:
        return UserStatuses.active;
    }
  }

  static String formatTimestamp(dynamic value) {
    if (value == null) return '-';

    try {
      final dateTime = value.toDate();
      final year = dateTime.year.toString().padLeft(4, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute';
    } catch (_) {
      return '-';
    }
  }

  static String _prettyValue(String value) {
    final cleaned = value.trim().replaceAll('_', ' ');
    if (cleaned.isEmpty) return '-';

    return cleaned
        .split(' ')
        .map((e) {
      if (e.isEmpty) return e;
      return '${e[0].toUpperCase()}${e.substring(1)}';
    })
        .join(' ');
  }
}