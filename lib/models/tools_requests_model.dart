/// Model for tools_requests table
class ToolsRequests {
  ToolsRequests({
    this.id,
    this.handasahName,
    this.toolName,
    this.toolQty = 0,
    this.techName,
    this.requestStatus = 1,
    this.isApproved = 0,
    this.date,
    this.address,
  });

  /// Create from JSON
  factory ToolsRequests.fromJson(Map<String, dynamic> json) {
    return ToolsRequests(
      id: json['id'] as int?,
      handasahName:
          json['handasah_name'] as String? ?? json['handasahName'] as String?,
      toolName: json['tool_name'] as String? ?? json['toolName'] as String?,
      toolQty: json['tool_qty'] as int? ?? json['toolQty'] as int? ?? 0,
      techName: json['tech_name'] as String? ?? json['techName'] as String?,
      requestStatus:
          json['request_status'] as int? ?? json['requestStatus'] as int? ?? 1,
      isApproved:
          json['is_approved'] as int? ?? json['isApproved'] as int? ?? 0,
      date: json['date'] as String?,
      address: json['address'] as String?,
    );
  }

  /// Create from database row
  factory ToolsRequests.fromDb(Map<String, dynamic> row) {
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

    return ToolsRequests(
      id: safeIntCastNullable(row['id']),
      handasahName: row['handasah_name']?.toString(),
      toolName: row['tool_name']?.toString(),
      toolQty: safeIntCast(row['tool_qty'], 0),
      techName: row['tech_name']?.toString(),
      requestStatus: safeIntCast(row['request_status'], 1),
      isApproved: safeIntCast(row['is_approved'], 0),
      date: row['date']?.toString(),
      address: row['address']?.toString(),
    );
  }
  final int? id;
  final String? handasahName;
  final String? toolName;
  final int toolQty;
  final String? techName;
  final int requestStatus;
  final int isApproved;
  final String? date;
  final String? address;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (handasahName != null) 'handasah_name': handasahName,
      if (toolName != null) 'tool_name': toolName,
      'tool_qty': toolQty,
      if (techName != null) 'tech_name': techName,
      'request_status': requestStatus,
      'is_approved': isApproved,
      if (date != null) 'date': date,
      if (address != null) 'address': address,
    };
  }
}
