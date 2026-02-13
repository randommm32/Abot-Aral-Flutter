class UserModel {
  final String id;
  final String email;
  final String? firstName;
  final String? middleName;
  final String? lastName;
  final String? suffix;
  final String? avatarUrl;
  final String? role;
  final FacilitatorProfile? facilitatorProfile;

  UserModel({
    required this.id,
    required this.email,
    this.firstName,
    this.middleName,
    this.lastName,
    this.suffix,
    this.avatarUrl,
    this.role,
    this.facilitatorProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] ?? '',
      firstName: json['first_name'] as String?,
      middleName: json['middle_name'] as String?,
      lastName: json['last_name'] as String?,
      suffix: json['suffix'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      role: json['role'] as String?,
      facilitatorProfile: json['facilitator_profiles'] != null
          ? FacilitatorProfile.fromJson(json['facilitator_profiles'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'suffix': suffix,
      'avatar_url': avatarUrl,
      'role': role,
      'facilitator_profiles': facilitatorProfile?.toJson(),
    };
  }

  String get fullName {
    final StringBuffer nameBuffer = StringBuffer();
    if (firstName != null && firstName!.isNotEmpty) nameBuffer.write(firstName);
    if (middleName != null && middleName!.isNotEmpty) nameBuffer.write(' $middleName');
    if (lastName != null && lastName!.isNotEmpty) nameBuffer.write(' $lastName');
    if (suffix != null && suffix!.isNotEmpty) nameBuffer.write(' $suffix');
    return nameBuffer.toString().trim();
  }

  String get initials {
    String initials = '';
    if (firstName != null && firstName!.isNotEmpty) initials += firstName![0];
    if (lastName != null && lastName!.isNotEmpty) initials += lastName![0];
    if (initials.isEmpty) initials = 'U';
    return initials.toUpperCase();
  }
}

class FacilitatorProfile {
  final String? type;
  final String? specialization;
  final String? workplaceAssignment;
  final int? totalHoursRendered;
  final double? ratingAverage;
  final bool isVerified;

  FacilitatorProfile({
    this.type,
    this.specialization,
    this.workplaceAssignment,
    this.totalHoursRendered,
    this.ratingAverage,
    required this.isVerified,
  });

  factory FacilitatorProfile.fromJson(Map<String, dynamic> json) {
    return FacilitatorProfile(
      type: json['type'] as String?,
      specialization: json['specialization'] as String?,
      workplaceAssignment: json['workplace_assignment'] as String?, 
      totalHoursRendered: json['total_hours_rendered'] as int?,
      ratingAverage: (json['rating_average'] as num?)?.toDouble(),
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'specialization': specialization,
      'workplace_assignment': workplaceAssignment,
      'total_hours_rendered': totalHoursRendered,
      'rating_average': ratingAverage,
      'is_verified': isVerified,
    };
  }
}
