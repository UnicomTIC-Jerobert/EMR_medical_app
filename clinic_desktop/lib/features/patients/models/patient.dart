class Patient {
  final String id;
  final String fullName;
  final String mobile;
  final String dob; // YYYY-MM-DD
  final String gender;
  final String bloodGroup;
  final String? allergies;
  final String? address;
  final DateTime createdAt;

  const Patient({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.dob,
    required this.gender,
    required this.bloodGroup,
    this.allergies,
    this.address,
    required this.createdAt,
  });

  Patient copyWith({
    String? id,
    String? fullName,
    String? mobile,
    String? dob,
    String? gender,
    String? bloodGroup,
    String? allergies,
    String? address,
    DateTime? createdAt,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      mobile: mobile ?? this.mobile,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      address: address ?? this.address,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'mobile': mobile,
      'dob': dob,
      'gender': gender,
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'address': address,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'] as String,
      fullName: json['fullName'] as String,
      mobile: json['mobile'] as String,
      dob: json['dob'] as String,
      gender: json['gender'] as String,
      bloodGroup: json['bloodGroup'] as String,
      allergies: json['allergies'] as String?,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
