/// Model for pick_location_users table
class PickLocationUsers {
  PickLocationUsers({
    this.id,
    this.userName,
    this.userPassword,
    this.role,
    this.controlUnit,
    this.technicalId,
  });

  /// Create from JSON
  factory PickLocationUsers.fromJson(Map<String, dynamic> json) {
    return PickLocationUsers(
      id: json['id'] as int?,
      userName: json['user_name'] as String? ?? json['userName'] as String?,
      userPassword:
          json['user_password'] as String? ?? json['userPassword'] as String?,
      role: json['role'] as int?,
      controlUnit:
          json['control_unit'] as String? ?? json['controlUnit'] as String?,
      technicalId: json['technical_id'] as int? ?? json['technicalId'] as int?,
    );
  }

  /// Create from database row
  factory PickLocationUsers.fromDb(Map<String, dynamic> row) {
    // Helper function for safe int casting
    int? safeIntCast(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      return parsed;
    }

    return PickLocationUsers(
      id: safeIntCast(row['id']),
      userName: row['user_name']?.toString(),
      userPassword: row['user_password']?.toString(),
      role: safeIntCast(row['role']),
      controlUnit: row['control_unit']?.toString(),
      technicalId: safeIntCast(row['technical_id']),
    );
  }
  final int? id;
  final String? userName;
  final String? userPassword;
  final int? role;
  final String? controlUnit;
  final int? technicalId;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userName != null) 'user_name': userName,
      if (userPassword != null) 'user_password': userPassword,
      if (role != null) 'role': role,
      if (controlUnit != null) 'control_unit': controlUnit,
      if (technicalId != null) 'technical_id': technicalId,
    };
  }

  /// Copy with method
  PickLocationUsers copyWith({
    int? id,
    String? userName,
    String? userPassword,
    int? role,
    String? controlUnit,
    int? technicalId,
  }) {
    return PickLocationUsers(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userPassword: userPassword ?? this.userPassword,
      role: role ?? this.role,
      controlUnit: controlUnit ?? this.controlUnit,
      technicalId: technicalId ?? this.technicalId,
    );
  }
}
