/// Model for tracking_locations table
class TrackingLocations {
  TrackingLocations({
    this.id,
    this.address,
    this.latitude,
    this.longitude,
    this.technicalName,
    this.startLatitude,
    this.startLongitude,
    this.currentLatitude,
    this.currentLongitude,
  });

  /// Create from JSON
  factory TrackingLocations.fromJson(Map<String, dynamic> json) {
    return TrackingLocations(
      id: json['id'] as int?,
      address: json['address'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      technicalName:
          json['technical_Name'] as String? ?? json['technicalName'] as String?,
      startLatitude:
          json['start_latitude'] as String? ?? json['startLatitude'] as String?,
      startLongitude: json['start_longitude'] as String? ??
          json['startLongitude'] as String?,
      currentLatitude: json['current_latitude'] as String? ??
          json['currentLatitude'] as String?,
      currentLongitude: json['current_longitude'] as String? ??
          json['currentLongitude'] as String?,
    );
  }

  /// Create from database row
  factory TrackingLocations.fromDb(Map<String, dynamic> row) {
    // Helper function for safe int casting
    int? safeIntCast(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      return parsed;
    }

    return TrackingLocations(
      id: safeIntCast(row['id']),
      address: row['address']?.toString(),
      latitude: row['latitude']?.toString(),
      longitude: row['longitude']?.toString(),
      technicalName: row['technical_Name']?.toString(),
      startLatitude: row['start_latitude']?.toString(),
      startLongitude: row['start_longitude']?.toString(),
      currentLatitude: row['current_latitude']?.toString(),
      currentLongitude: row['current_longitude']?.toString(),
    );
  }
  final int? id;
  final String? address;
  final String? latitude;
  final String? longitude;
  final String? technicalName;
  final String? startLatitude;
  final String? startLongitude;
  final String? currentLatitude;
  final String? currentLongitude;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (address != null) 'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (technicalName != null) 'technical_Name': technicalName,
      if (startLatitude != null) 'start_latitude': startLatitude,
      if (startLongitude != null) 'start_longitude': startLongitude,
      if (currentLatitude != null) 'current_latitude': currentLatitude,
      if (currentLongitude != null) 'current_longitude': currentLongitude,
    };
  }

  /// Copy with method
  TrackingLocations copyWith({
    int? id,
    String? address,
    String? latitude,
    String? longitude,
    String? technicalName,
    String? startLatitude,
    String? startLongitude,
    String? currentLatitude,
    String? currentLongitude,
  }) {
    return TrackingLocations(
      id: id ?? this.id,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      technicalName: technicalName ?? this.technicalName,
      startLatitude: startLatitude ?? this.startLatitude,
      startLongitude: startLongitude ?? this.startLongitude,
      currentLatitude: currentLatitude ?? this.currentLatitude,
      currentLongitude: currentLongitude ?? this.currentLongitude,
    );
  }
}
