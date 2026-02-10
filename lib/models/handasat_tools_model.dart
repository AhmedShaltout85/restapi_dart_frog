/// Model for handasat_tools table
class HandasatTools {
  HandasatTools({
    this.id,
    this.handasahName,
    this.toolName,
    this.toolQty,
  });

  /// Create from JSON
  factory HandasatTools.fromJson(Map<String, dynamic> json) {
    return HandasatTools(
      id: json['id'] as int?,
      handasahName:
          json['handasah_name'] as String? ?? json['handasahName'] as String?,
      toolName: json['tool_name'] as String? ?? json['toolName'] as String?,
      toolQty: json['tool_qty'] as int? ?? json['toolQty'] as int?,
    );
  }

  /// Create from database row
  factory HandasatTools.fromDb(Map<String, dynamic> row) {
    // Helper function for safe int casting
    int? safeIntCast(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      return parsed;
    }

    return HandasatTools(
      id: safeIntCast(row['id']),
      handasahName: row['handasah_name']?.toString(),
      toolName: row['tool_name']?.toString(),
      toolQty: safeIntCast(row['tool_qty']),
    );
  }
  final int? id;
  final String? handasahName;
  final String? toolName;
  final int? toolQty;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (handasahName != null) 'handasah_name': handasahName,
      if (toolName != null) 'tool_name': toolName,
      if (toolQty != null) 'tool_qty': toolQty,
    };
  }

  /// Copy with method
  HandasatTools copyWith({
    int? id,
    String? handasahName,
    String? toolName,
    int? toolQty,
  }) {
    return HandasatTools(
      id: id ?? this.id,
      handasahName: handasahName ?? this.handasahName,
      toolName: toolName ?? this.toolName,
      toolQty: toolQty ?? this.toolQty,
    );
  }
}
