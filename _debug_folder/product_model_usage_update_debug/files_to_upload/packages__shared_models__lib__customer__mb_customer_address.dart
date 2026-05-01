class UserAddressModel {
  final String id;
  final String label;
  final String fullName;
  final String phoneNumber;
  final String addressLine;
  final String area;
  final String city;
  final String postalCode;
  final bool isDefault;

  const UserAddressModel({
    required this.id,
    required this.label,
    required this.fullName,
    required this.phoneNumber,
    required this.addressLine,
    required this.area,
    required this.city,
    required this.postalCode,
    this.isDefault = false,
  });

  factory UserAddressModel.empty() {
    return const UserAddressModel(
      id: '',
      label: 'Home',
      fullName: '',
      phoneNumber: '',
      addressLine: '',
      area: '',
      city: '',
      postalCode: '',
      isDefault: false,
    );
  }

  String get fullAddress {
    final parts = [
      addressLine.trim(),
      area.trim(),
      city.trim(),
      postalCode.trim(),
    ].where((e) => e.isNotEmpty).toList();

    return parts.join(', ');
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Label': label,
      'FullName': fullName,
      'PhoneNumber': phoneNumber,
      'AddressLine': addressLine,
      'Area': area,
      'City': city,
      'PostalCode': postalCode,
      'IsDefault': isDefault,
    };
  }

  factory UserAddressModel.fromMap(Map<String, dynamic> data) {
    return UserAddressModel(
      id: (data['Id'] ?? '').toString(),
      label: (data['Label'] ?? 'Home').toString(),
      fullName: (data['FullName'] ?? '').toString(),
      phoneNumber: (data['PhoneNumber'] ?? '').toString(),
      addressLine: (data['AddressLine'] ?? '').toString(),
      area: (data['Area'] ?? '').toString(),
      city: (data['City'] ?? '').toString(),
      postalCode: (data['PostalCode'] ?? '').toString(),
      isDefault: data['IsDefault'] == true,
    );
  }

  UserAddressModel copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phoneNumber,
    String? addressLine,
    String? area,
    String? city,
    String? postalCode,
    bool? isDefault,
  }) {
    return UserAddressModel(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addressLine: addressLine ?? this.addressLine,
      area: area ?? this.area,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  @override
  String toString() {
    return 'UserAddressModel('
        'id: $id, '
        'label: $label, '
        'fullName: $fullName, '
        'phoneNumber: $phoneNumber, '
        'addressLine: $addressLine, '
        'area: $area, '
        'city: $city, '
        'postalCode: $postalCode, '
        'isDefault: $isDefault'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserAddressModel &&
        other.id == id &&
        other.label == label &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.addressLine == addressLine &&
        other.area == area &&
        other.city == city &&
        other.postalCode == postalCode &&
        other.isDefault == isDefault;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    label.hashCode ^
    fullName.hashCode ^
    phoneNumber.hashCode ^
    addressLine.hashCode ^
    area.hashCode ^
    city.hashCode ^
    postalCode.hashCode ^
    isDefault.hashCode;
  }
}











