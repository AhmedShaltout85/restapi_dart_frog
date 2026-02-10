// Update your locations_model.dart with this safer version
class Locations {
  Locations({
    required this.address,
    this.id,
    this.latitude,
    this.longitude,
    this.date,
    this.flag,
    this.gisUrl,
    this.handasahName,
    this.technicalName,
    this.isFinished = 0,
    this.isApproved = 0,
    this.callerName,
    this.brokenType,
    this.callerNumber,
    this.videoCall,
  });

  /// Create from database row with safe type casting
  factory Locations.fromDb(Map<String, dynamic> row) {
    // Helper function for safe casting
    T? safeCast<T>(dynamic value, T? defaultValue) {
      if (value == null) return defaultValue;

      try {
        if (T == int) {
          if (value is int) return value as T;
          if (value is num) return value.toInt() as T;
          final parsed = int.tryParse(value.toString());
          return parsed != null ? parsed as T : defaultValue;
        } else if (T == String) {
          return value.toString() as T;
        } else if (T == double) {
          if (value is double) return value as T;
          if (value is num) return value.toDouble() as T;
          final parsed = double.tryParse(value.toString());
          return parsed != null ? parsed as T : defaultValue;
        } else {
          return value as T?;
        }
      } catch (e) {
        print('Warning: Failed to cast $value to $T: $e');
        return defaultValue;
      }
    }

    // Try different column name variations
    final id = safeCast<int>(row['ID'] ?? row['Id'] ?? row['id'], null);

    // Address is required, so we need to handle it carefully
    final address = (row['Address'] ?? row['address'] ?? '').toString();

    return Locations(
      id: id,
      address: address,
      latitude: safeCast<String>(row['Latitude'] ?? row['latitude'], null),
      longitude: safeCast<String>(
          row['Longtiude'] ??
              row['Longitude'] ??
              row['longtiude'] ??
              row['longitude'],
          null),
      date: safeCast<String>(row['Date'] ?? row['date'], null),
      flag: safeCast<int>(row['Flag'] ?? row['flag'], null),
      gisUrl: safeCast<String>(
          row['Gis_Url'] ?? row['GisUrl'] ?? row['gis_url'] ?? row['gisUrl'],
          null),
      handasahName: safeCast<String>(
          row['Handasah_Name'] ??
              row['HandasahName'] ??
              row['handasah_name'] ??
              row['handasahName'],
          null),
      technicalName: safeCast<String>(
          row['Technical_Name'] ??
              row['TechnicalName'] ??
              row['technical_name'] ??
              row['technicalName'],
          null),
      isFinished: safeCast<int>(
              row['Is_Finished'] ??
                  row['IsFinished'] ??
                  row['is_finished'] ??
                  row['isFinished'],
              0) ??
          0,
      isApproved: safeCast<int>(
              row['Is_Approved'] ??
                  row['IsApproved'] ??
                  row['is_approved'] ??
                  row['isApproved'],
              0) ??
          0,
      callerName: safeCast<String>(
          row['Caller_Name'] ??
              row['CallerName'] ??
              row['caller_name'] ??
              row['callerName'],
          null),
      brokenType: safeCast<String>(
          row['Broken_Type'] ??
              row['BrokenType'] ??
              row['broken_type'] ??
              row['brokenType'],
          null),
      callerNumber: safeCast<String>(
          row['Caller_Number'] ??
              row['CallerNumber'] ??
              row['caller_number'] ??
              row['callerNumber'],
          null),
      videoCall: safeCast<int>(
          row['Video_Call'] ??
              row['VideoCall'] ??
              row['video_call'] ??
              row['videoCall'],
          null),
    );
  }

  /// Create from JSON
  factory Locations.fromJson(Map<String, dynamic> json) {
    return Locations.fromDb(json); // Reuse fromDb since it has safe casting
  }

  final int? id;
  final String address;
  final String? latitude;
  final String? longitude;
  final String? date;
  final int? flag;
  final String? gisUrl;
  final String? handasahName;
  final String? technicalName;
  final int isFinished;
  final int isApproved;
  final String? callerName;
  final String? brokenType;
  final String? callerNumber;
  final int? videoCall;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'address': address,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (date != null) 'date': date,
      if (flag != null) 'flag': flag,
      if (gisUrl != null) 'gisUrl': gisUrl,
      if (handasahName != null) 'handasahName': handasahName,
      if (technicalName != null) 'technicalName': technicalName,
      'isFinished': isFinished,
      'isApproved': isApproved,
      if (callerName != null) 'callerName': callerName,
      if (brokenType != null) 'brokenType': brokenType,
      if (callerNumber != null) 'callerNumber': callerNumber,
      if (videoCall != null) 'videoCall': videoCall,
    };
  }
}
