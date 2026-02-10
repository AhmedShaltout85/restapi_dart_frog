/// Model for pick_location_handasah table
class PickLocationHandasah {
  PickLocationHandasah({
    required this.handasahName,
    required this.storeName,
    required this.storeNumber,
    this.id,
  });

  /// Create from JSON
  factory PickLocationHandasah.fromJson(Map<String, dynamic> json) {
    return PickLocationHandasah(
      id: json['id'] as int?,
      handasahName: json['handasah_name'] as String? ??
          json['handasahName'] as String? ??
          '',
      storeName:
          json['store_name'] as String? ?? json['storeName'] as String? ?? '',
      storeNumber:
          json['store_number'] as int? ?? json['storeNumber'] as int? ?? 0,
    );
  }

  /// Create from database row
  factory PickLocationHandasah.fromDb(Map<String, dynamic> row) {
    // Helper function for safe int casting with default value
    int safeIntCast(dynamic value, int defaultValue) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      return parsed ?? defaultValue;
    }

    // Helper for nullable int
    int? safeIntCastNullable(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString());
    }

    return PickLocationHandasah(
      id: safeIntCastNullable(row['id']),
      handasahName: row['handasah_name']?.toString() ?? '',
      storeName: row['store_name']?.toString() ?? '',
      storeNumber: safeIntCast(row['store_number'], 0),
    );
  }
  final int? id;
  final String handasahName;
  final String storeName;
  final int storeNumber;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'handasah_name': handasahName,
      'store_name': storeName,
      'store_number': storeNumber,
    };
  }

  /// Copy with method
  PickLocationHandasah copyWith({
    int? id,
    String? handasahName,
    String? storeName,
    int? storeNumber,
  }) {
    return PickLocationHandasah(
      id: id ?? this.id,
      handasahName: handasahName ?? this.handasahName,
      storeName: storeName ?? this.storeName,
      storeNumber: storeNumber ?? this.storeNumber,
    );
  }
}
