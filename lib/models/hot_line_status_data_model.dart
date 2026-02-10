/// Model for hot_line_status_data table
class HotLineStatusData {
  HotLineStatusData({
    required this.id,
    required this.street,
    this.uid,
    this.waterStopDT,
    this.caseRepairDT,
    this.waterOpeningDT,
    this.notes,
    this.finalClosed,
    this.reporterName,
    this.refNo,
    this.mainStreet,
    this.x,
    this.y,
    this.nearTo,
    this.userName,
    this.area,
    this.town,
    this.sector,
    this.locationName,
    this.companyAcroName,
    this.caseType,
    this.activityName,
    this.valvesCount,
    this.network,
    this.pressure,
    this.details,
    this.extraDataNotes,
    this.pipeDiameter,
    this.pipeType,
    this.pipeStatus,
    this.pipeDepth,
    this.pipeAge,
    this.breakLength,
    this.bWidth,
    this.plantName,
    this.plantStatus,
    this.affectedAreas,
    this.resons,
    this.repairType,
    this.delayResons,
    this.caseReportDateTime,
    this.address,
  });

  /// Create from JSON
  factory HotLineStatusData.fromJson(Map<String, dynamic> json) {
    return HotLineStatusData(
      uid: json['uid'] as int?,
      id: json['id'] as int? ?? 0,
      waterStopDT:
          json['water_stop_d_t'] as String? ?? json['waterStopDT'] as String?,
      caseRepairDT:
          json['case_repair_d_t'] as String? ?? json['caseRepairDT'] as String?,
      waterOpeningDT: json['water_opening_d_t'] as String? ??
          json['waterOpeningDT'] as String?,
      notes: json['notes'] as String?,
      finalClosed:
          json['final_closed'] as bool? ?? json['finalClosed'] as bool?,
      reporterName:
          json['reporter_name'] as String? ?? json['reporterName'] as String?,
      refNo: json['ref_no'] as int? ?? json['refNo'] as int?,
      street: json['street'] as String? ?? '',
      mainStreet:
          json['main_street'] as String? ?? json['mainStreet'] as String?,
      x: json['x'] as String?,
      y: json['y'] as String?,
      nearTo: json['near_to'] as String? ?? json['nearTo'] as String?,
      userName: json['user_name'] as String? ?? json['userName'] as String?,
      area: json['area'] as String?,
      town: json['town'] as String?,
      sector: json['sector'] as String?,
      locationName:
          json['location_name'] as String? ?? json['locationName'] as String?,
      companyAcroName:
          json['company_acro_name'] as int? ?? json['companyAcroName'] as int?,
      caseType: json['case_type'] as String? ?? json['caseType'] as String?,
      activityName:
          json['activity_name'] as String? ?? json['activityName'] as String?,
      valvesCount: json['valves_count'] as int? ?? json['valvesCount'] as int?,
      network: json['network'] as String?,
      pressure: (json['pressure'] as num?)?.toDouble(),
      details: json['details'] as String?,
      extraDataNotes: json['extra_data_notes'] as String? ??
          json['extraDataNotes'] as String?,
      pipeDiameter:
          json['pipe_diameter'] as int? ?? json['pipeDiameter'] as int?,
      pipeType: json['pipe_type'] as String? ?? json['pipeType'] as String?,
      pipeStatus:
          json['pipe_status'] as String? ?? json['pipeStatus'] as String?,
      pipeDepth: json['pipe_depth'] as String? ?? json['pipeDepth'] as String?,
      pipeAge: json['pipe_age'] as String? ?? json['pipeAge'] as String?,
      breakLength: (json['break_length'] as num?)?.toDouble(),
      bWidth: (json['b_width'] as num?)?.toDouble(),
      plantName: json['plant_name'] as String? ?? json['plantName'] as String?,
      plantStatus:
          json['plant_status'] as String? ?? json['plantStatus'] as String?,
      affectedAreas:
          json['affected_areas'] as String? ?? json['affectedAreas'] as String?,
      resons: json['resons'] as String?,
      repairType:
          json['repair_type'] as String? ?? json['repairType'] as String?,
      delayResons:
          json['delay_resons'] as String? ?? json['delayResons'] as String?,
      caseReportDateTime: json['case_report_date_time'] as String? ??
          json['caseReportDateTime'] as String?,
      address: json['address'] as String?,
    );
  }

  /// Create from database row
  factory HotLineStatusData.fromDb(Map<String, dynamic> row) {
    // Helper function for safe int casting
    int? safeIntCast(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      return parsed;
    }

    // Helper function for safe bool casting
    bool? safeBoolCast(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is int) return value != 0;
      if (value is String) {
        final lower = value.toLowerCase();
        if (lower == 'true' || lower == '1') return true;
        if (lower == 'false' || lower == '0') return false;
      }
      return null;
    }

    // Helper function for safe double casting
    double? safeDoubleCast(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value.toString());
      return parsed;
    }

    return HotLineStatusData(
      uid: safeIntCast(row['uid']),
      id: safeIntCast(row['id']) ?? 0,
      waterStopDT: row['water_stop_d_t']?.toString(),
      caseRepairDT: row['case_repair_d_t']?.toString(),
      waterOpeningDT: row['water_opening_d_t']?.toString(),
      notes: row['notes']?.toString(),
      finalClosed: safeBoolCast(row['final_closed']),
      reporterName: row['reporter_name']?.toString(),
      refNo: safeIntCast(row['ref_no']),
      street: row['street']?.toString() ?? '',
      mainStreet: row['main_street']?.toString(),
      x: row['x']?.toString(),
      y: row['y']?.toString(),
      nearTo: row['near_to']?.toString(),
      userName: row['user_name']?.toString(),
      area: row['area']?.toString(),
      town: row['town']?.toString(),
      sector: row['sector']?.toString(),
      locationName: row['location_name']?.toString(),
      companyAcroName: safeIntCast(row['company_acro_name']),
      caseType: row['case_type']?.toString(),
      activityName: row['activity_name']?.toString(),
      valvesCount: safeIntCast(row['valves_count']),
      network: row['network']?.toString(),
      pressure: safeDoubleCast(row['pressure']),
      details: row['details']?.toString(),
      extraDataNotes: row['extra_data_notes']?.toString(),
      pipeDiameter: safeIntCast(row['pipe_diameter']),
      pipeType: row['pipe_type']?.toString(),
      pipeStatus: row['pipe_status']?.toString(),
      pipeDepth: row['pipe_depth']?.toString(),
      pipeAge: row['pipe_age']?.toString(),
      breakLength: safeDoubleCast(row['break_length']),
      bWidth: safeDoubleCast(row['b_width']),
      plantName: row['plant_name']?.toString(),
      plantStatus: row['plant_status']?.toString(),
      affectedAreas: row['affected_areas']?.toString(),
      resons: row['resons']?.toString(),
      repairType: row['repair_type']?.toString(),
      delayResons: row['delay_resons']?.toString(),
      caseReportDateTime: row['case_report_date_time']?.toString(),
      address: row['address']?.toString(),
    );
  }
  final int? uid;
  final int id;
  final String? waterStopDT;
  final String? caseRepairDT;
  final String? waterOpeningDT;
  final String? notes;
  final bool? finalClosed;
  final String? reporterName;
  final int? refNo;
  final String street;
  final String? mainStreet;
  final String? x;
  final String? y;
  final String? nearTo;
  final String? userName;
  final String? area;
  final String? town;
  final String? sector;
  final String? locationName;
  final int? companyAcroName;
  final String? caseType;
  final String? activityName;
  final int? valvesCount;
  final String? network;
  final double? pressure;
  final String? details;
  final String? extraDataNotes;
  final int? pipeDiameter;
  final String? pipeType;
  final String? pipeStatus;
  final String? pipeDepth;
  final String? pipeAge;
  final double? breakLength;
  final double? bWidth;
  final String? plantName;
  final String? plantStatus;
  final String? affectedAreas;
  final String? resons;
  final String? repairType;
  final String? delayResons;
  final String? caseReportDateTime;
  final String? address;

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      if (uid != null) 'uid': uid,
      'id': id,
      if (waterStopDT != null) 'water_stop_d_t': waterStopDT,
      if (caseRepairDT != null) 'case_repair_d_t': caseRepairDT,
      if (waterOpeningDT != null) 'water_opening_d_t': waterOpeningDT,
      if (notes != null) 'notes': notes,
      if (finalClosed != null) 'final_closed': finalClosed,
      if (reporterName != null) 'reporter_name': reporterName,
      if (refNo != null) 'ref_no': refNo,
      'street': street,
      if (mainStreet != null) 'main_street': mainStreet,
      if (x != null) 'x': x,
      if (y != null) 'y': y,
      if (nearTo != null) 'near_to': nearTo,
      if (userName != null) 'user_name': userName,
      if (area != null) 'area': area,
      if (town != null) 'town': town,
      if (sector != null) 'sector': sector,
      if (locationName != null) 'location_name': locationName,
      if (companyAcroName != null) 'company_acro_name': companyAcroName,
      if (caseType != null) 'case_type': caseType,
      if (activityName != null) 'activity_name': activityName,
      if (valvesCount != null) 'valves_count': valvesCount,
      if (network != null) 'network': network,
      if (pressure != null) 'pressure': pressure,
      if (details != null) 'details': details,
      if (extraDataNotes != null) 'extra_data_notes': extraDataNotes,
      if (pipeDiameter != null) 'pipe_diameter': pipeDiameter,
      if (pipeType != null) 'pipe_type': pipeType,
      if (pipeStatus != null) 'pipe_status': pipeStatus,
      if (pipeDepth != null) 'pipe_depth': pipeDepth,
      if (pipeAge != null) 'pipe_age': pipeAge,
      if (breakLength != null) 'break_length': breakLength,
      if (bWidth != null) 'b_width': bWidth,
      if (plantName != null) 'plant_name': plantName,
      if (plantStatus != null) 'plant_status': plantStatus,
      if (affectedAreas != null) 'affected_areas': affectedAreas,
      if (resons != null) 'resons': resons,
      if (repairType != null) 'repair_type': repairType,
      if (delayResons != null) 'delay_resons': delayResons,
      if (caseReportDateTime != null)
        'case_report_date_time': caseReportDateTime,
      if (address != null) 'address': address,
    };
  }
}
