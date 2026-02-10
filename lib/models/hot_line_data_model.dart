/// Model for hot_line_data table
class HotLineData {
  HotLineData({
    this.id,
    this.phone,
    this.mobile,
    this.titleId,
    this.homeNumber,
    this.floorNumberId,
    this.areaId,
    this.sideStreet,
    this.mainStreet,
    this.nearTo,
    this.name,
    this.subscribeNo,
    this.areaNo,
    this.email,
    this.userId,
    this.sourceId,
    this.dateTime,
    this.notes,
    this.x,
    this.y,
    this.sig,
    this.keys,
    this.customerId,
  });

  /// Create from JSON
  factory HotLineData.fromJson(Map<String, dynamic> json) {
    return HotLineData(
      id: json['id'] as int?,
      phone: json['phone'] as String?,
      mobile: json['mobile'] as String?,
      titleId: json['title_id'] as int? ?? json['titleId'] as int?,
      homeNumber:
          json['home_number'] as String? ?? json['homeNumber'] as String?,
      floorNumberId:
          json['floor_number_id'] as int? ?? json['floorNumberId'] as int?,
      areaId: json['area_id'] as int? ?? json['areaId'] as int?,
      sideStreet:
          json['side_street'] as String? ?? json['sideStreet'] as String?,
      mainStreet:
          json['main_street'] as String? ?? json['mainStreet'] as String?,
      nearTo: json['near_to'] as String? ?? json['nearTo'] as String?,
      name: json['name'] as String?,
      subscribeNo:
          json['subscribe_no'] as String? ?? json['subscribeNo'] as String?,
      areaNo: json['area_no'] as String? ?? json['areaNo'] as String?,
      email: json['email'] as String?,
      userId: json['user_id'] as int? ?? json['userId'] as int?,
      sourceId: json['source_id'] as int? ?? json['sourceId'] as int?,
      dateTime: json['date_time'] as String? ?? json['dateTime'] as String?,
      notes: json['notes'] as String?,
      x: json['x'] as String?,
      y: json['y'] as String?,
      sig: json['sig'] as String?,
      keys: json['keys'] as String?,
      customerId: json['customer_id'] as int? ?? json['customerId'] as int?,
    );
  }

  /// Create from database row
  factory HotLineData.fromDb(Map<String, dynamic> row) {
    // Helper function for safe int casting
    int? safeIntCast(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      return parsed;
    }

    return HotLineData(
      id: safeIntCast(row['id']),
      phone: row['phone']?.toString(),
      mobile: row['mobile']?.toString(),
      titleId: safeIntCast(row['title_id']),
      homeNumber: row['home_number']?.toString(),
      floorNumberId: safeIntCast(row['floor_number_id']),
      areaId: safeIntCast(row['area_id']),
      sideStreet: row['side_street']?.toString(),
      mainStreet: row['main_street']?.toString(),
      nearTo: row['near_to']?.toString(),
      name: row['name']?.toString(),
      subscribeNo: row['subscribe_no']?.toString(),
      areaNo: row['area_no']?.toString(),
      email: row['email']?.toString(),
      userId: safeIntCast(row['user_id']),
      sourceId: safeIntCast(row['source_id']),
      dateTime: row['date_time']?.toString(),
      notes: row['notes']?.toString(),
      x: row['x']?.toString(),
      y: row['y']?.toString(),
      sig: row['sig']?.toString(),
      keys: row['keys']?.toString(),
      customerId: safeIntCast(row['customer_id']),
    );
  }
  final int? id;
  final String? phone;
  final String? mobile;
  final int? titleId;
  final String? homeNumber;
  final int? floorNumberId;
  final int? areaId;
  final String? sideStreet;
  final String? mainStreet;
  final String? nearTo;
  final String? name;
  final String? subscribeNo;
  final String? areaNo;
  final String? email;
  final int? userId;
  final int? sourceId;
  final String? dateTime;
  final String? notes;
  final String? x;
  final String? y;
  final String? sig;
  final String? keys;
  final int? customerId;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (phone != null) 'phone': phone,
      if (mobile != null) 'mobile': mobile,
      if (titleId != null) 'title_id': titleId,
      if (homeNumber != null) 'home_number': homeNumber,
      if (floorNumberId != null) 'floor_number_id': floorNumberId,
      if (areaId != null) 'area_id': areaId,
      if (sideStreet != null) 'side_street': sideStreet,
      if (mainStreet != null) 'main_street': mainStreet,
      if (nearTo != null) 'near_to': nearTo,
      if (name != null) 'name': name,
      if (subscribeNo != null) 'subscribe_no': subscribeNo,
      if (areaNo != null) 'area_no': areaNo,
      if (email != null) 'email': email,
      if (userId != null) 'user_id': userId,
      if (sourceId != null) 'source_id': sourceId,
      if (dateTime != null) 'date_time': dateTime,
      if (notes != null) 'notes': notes,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (sig != null) 'sig': sig,
      if (keys != null) 'keys': keys,
      if (customerId != null) 'customer_id': customerId,
    };
  }
}
