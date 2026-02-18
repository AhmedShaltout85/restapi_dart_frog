/// Authentication data transfer objects
library;

/// Login request model
class LoginRequest {
  LoginRequest({
    required this.userName,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) {
    return LoginRequest(
      userName: json['userName'] as String? ?? json['user_name'] as String,
      password: json['password'] as String,
    );
  }

  final String userName;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'password': password,
    };
  }
}

/// Login response model
class LoginResponse {
  LoginResponse({
    required this.token,
    required this.userId,
    required this.userName,
    this.role,
    this.controlUnit,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      userId: json['userId'] as int,
      userName: json['userName'] as String,
      role: json['role'] as int?,
      controlUnit: json['controlUnit'] as String?,
    );
  }

  final String token;
  final int userId;
  final String userName;
  final int? role;
  final String? controlUnit;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'userId': userId,
      'userName': userName,
      if (role != null) 'role': role,
      if (controlUnit != null) 'controlUnit': controlUnit,
    };
  }
}

/// Register request model
class RegisterRequest {
  RegisterRequest({
    required this.userName,
    required this.password,
    this.role,
    this.controlUnit,
    this.technicalId,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      userName: json['userName'] as String? ?? json['user_name'] as String,
      password: json['password'] as String,
      role: json['role'] as int?,
      controlUnit:
          json['controlUnit'] as String? ?? json['control_unit'] as String?,
      technicalId: json['technicalId'] as int? ?? json['technical_id'] as int?,
    );
  }

  final String userName;
  final String password;
  final int? role;
  final String? controlUnit;
  final int? technicalId;

  Map<String, dynamic> toJson() {
    return {
      'user_name': userName,
      'password': password,
      if (role != null) 'role': role,
      if (controlUnit != null) 'control_unit': controlUnit,
      if (technicalId != null) 'technical_id': technicalId,
    };
  }
}

/// Register response model
class RegisterResponse {
  RegisterResponse({
    required this.message,
    required this.userId,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] as String,
      userId: json['userId'] as int,
    );
  }

  final String message;
  final int userId;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'userId': userId,
    };
  }
}
