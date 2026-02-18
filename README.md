# REST API - MS SQL Database with Dart Frog

A complete RESTful API built with **Dart Frog** and **dart_odbc** for managing MS SQL Server database tables. Features **JWT authentication**, full CRUD operations, type-safe models, and comprehensive error handling.

## 🚀 Features

- ✅ **JWT Authentication** - Secure token-based authentication with bcrypt password hashing
- ✅ **8 Database Tables** with full CRUD operations
- ✅ **RESTful API Endpoints** following industry standards
- ✅ **Protected Routes** - All API endpoints require authentication
- ✅ **Safe Type Casting** - Handles database string-to-int conversions automatically
- ✅ **Standardized JSON Responses** with timestamps
- ✅ **Repository Pattern** for clean data access layer
- ✅ **Environment-based Configuration** using .env files
- ✅ **CORS Support** for cross-origin requests
- ✅ **Error Handling & Validation** with detailed error messages
- ✅ **HTTP Test Suite** with ready-to-use API calls

## 📋 Prerequisites

- **Dart SDK** 3.0.0 or higher
- **MS SQL Server** database
- **ODBC Driver 18 for SQL Server** installed on your system

### Installing ODBC Driver (Linux)

```bash
# For Ubuntu/Debian
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18
sudo apt-get install -y unixodbc-dev
```

## ⚙️ Setup

### 1. Clone and Install Dependencies

```bash
cd restapi_dart_frog
dart pub get
```

### 2. Configure Database Connection

Copy `.env.example` to `.env` and update with your database credentials:

```bash
cp .env.example .env
```

Edit `.env` with your database details:

```env
DB_SERVER=your_server_name_or_ip
DB_PORT=1433
DB_DATABASE=your_database_name
DB_USERNAME=your_username
DB_PASSWORD=your_password
DB_DRIVER={ODBC Driver 18 for SQL Server}

# JWT Authentication (required)
JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
JWT_EXPIRATION_HOURS=24
```

> **⚠️ Important**: Change `JWT_SECRET` to a strong, random secret key in production!

### 3. Test Database Connection

```bash
dart run test_connection.dart
```

## 🏃 Running the API

Start the development server:

```bash
dart_frog dev
```

The API will be available at **`http://localhost:8080`**

For production build:

```bash
dart_frog build
```

## � Authentication

### JWT Token-Based Authentication

All API endpoints (except authentication routes) require a valid JWT token.

#### Public Endpoints (No Authentication Required)

- `POST /auth/register` - Register new user
- `POST /auth/login` - Login and get JWT token
- `GET /health` - Health check
- `GET /debug` - Debug information

#### Protected Endpoints

All `/api/*` routes require authentication:

```http
Authorization: Bearer YOUR_JWT_TOKEN
```

### Quick Start

#### 1. Register a New User

```bash
curl -X POST http://localhost:8080/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "userName": "testuser",
    "password": "password123",
    "role": 1,
    "controlUnit": "Engineering"
  }'
```

#### 2. Login to Get JWT Token

```bash
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "userName": "testuser",
    "password": "password123"
  }'
```

**Response includes your JWT token - save it!**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "userId": 2009,
    "userName": "testuser",
    "role": 1
  }
}
```

#### 3. Use Token for API Requests

```bash
curl http://localhost:8080/api/locations \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

**Token Details:**

- Algorithm: HS256
- Expiration: 24 hours
- Security: bcrypt password hashing

---

## �📚 API Endpoints

### Available Tables & Endpoints

**All endpoints require JWT authentication via `Authorization: Bearer <token>` header**

| Table                  | Base Endpoint                 | Records |
| ---------------------- | ----------------------------- | ------- |
| Locations              | `/api/locations`              | CRUD    |
| Handasat Tools         | `/api/handasat_tools`         | CRUD    |
| Hot Line Data          | `/api/hot_line_data`          | CRUD    |
| Hot Line Status Data   | `/api/hot_line_status_data`   | CRUD    |
| Pick Location Handasah | `/api/pick_location_handasah` | CRUD    |
| Pick Location Users    | `/api/pick_location_users`    | CRUD    |
| Tools Requests         | `/api/tools_requests`         | CRUD    |
| Tracking Locations     | `/api/tracking_locations`     | CRUD    |

### Authentication Endpoints (Public)

| Endpoint         | Method | Description             |
| ---------------- | ------ | ----------------------- |
| `/auth/register` | POST   | Register new user       |
| `/auth/login`    | POST   | Login and get JWT token |

### CRUD Operations

For each table, the following operations are supported:

#### 📥 **List All Records** (Protected)

```http
GET /api/{table}
Authorization: Bearer YOUR_TOKEN
```

**Response:**

```json
{
  "success": true,
  "data": [...],
  "count": 10,
  "timestamp": "2026-02-10T20:00:00.000Z"
}
```

#### 🔍 **Get Single Record** (Protected)

```http
GET /api/{table}/{id}
Authorization: Bearer YOUR_TOKEN
```

#### ➕ **Create New Record** (Protected)

```http
POST /api/{table}
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "field1": "value1",
  "field2": "value2"
}
```

#### ✏️ **Update Record** (Protected)

```http
PUT /api/{table}/{id}
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "field1": "new_value1"
}
```

#### 🗑️ **Delete Record** (Protected)

```http
DELETE /api/{table}/{id}
Authorization: Bearer YOUR_TOKEN
```

### 🔧 Utility Endpoints (Public)

#### Test Database Connection

```http
GET /test/db
```

#### Debug Environment Variables

```http
GET /debug
```

## 💡 Example Usage

### Using cURL

**All API requests require authentication.** First get a token:

```bash
# Login and extract token
TOKEN=$(curl -s -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{"userName":"testuser","password":"password123"}' \
  | grep -o '"token":"[^"]*' | cut -d'"' -f4)
```

#### Create a new location:

```bash
curl -X POST http://localhost:8080/api/locations \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "address": "123 Main St, Cairo",
    "latitude": "30.0444",
    "longitude": "31.2357",
    "handasahName": "Ahmed Hassan",
    "technicalName": "Mohamed Ali",
    "flag": 1
  }'
```

#### Get all hot line data:

```bash
curl http://localhost:8080/api/hot_line_data \
  -H "Authorization: Bearer $TOKEN"
```

#### Update a tools request:

```bash
curl -X PUT http://localhost:8080/api/tools_requests/1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "toolQty": 5,
    "requestStatus": 2,
    "isApproved": 1
  }'
```

#### Delete a tracking location:

```bash
curl -X DELETE http://localhost:8080/api/tracking_locations/5 \
  -H "Authorization: Bearer $TOKEN"
```

### Using the HTTP Test File

The project includes `api_tests.http` with ready-to-use HTTP requests for all endpoints.

1. Run a register request, then login
2. Copy the token from the login response
3. Update the `@authToken` variable at the top of the file
4. Use the REST Client extension in VS Code and click "Send Request" above any request

## 📁 Project Structure

```
restapi_dart_frog/
├── lib/
│   ├── database/
│   │   ├── database_config.dart      # Database + JWT configuration
│   │   └── database_helper.dart      # Database connection & query helpers
│   ├── models/                        # Data models (8 tables + auth)
│   │   ├── auth_models.dart          # Authentication DTOs
│   │   ├── locations_model.dart
│   │   └── ... (one for each table)
│   ├── repositories/                  # Repository pattern implementations
│   │   ├── pick_location_users_repository.dart  # Extended with auth methods
│   │   └── ... (one for each model)
│   ├── services/                      # Business logic services
│   │   ├── jwt_service.dart          # JWT token generation/validation
│   │   └── auth_service.dart         # Authentication logic
│   └── middleware/
│       └── auth_middleware.dart       # JWT validation middleware
├── routes/
│   ├── _middleware.dart               # Global middleware (DB + JWT provider)
│   ├── auth/
│   │   ├── login.dart                # Login endpoint
│   │   └── register.dart             # Registration endpoint
│   ├── api/
│   │   ├── _middleware.dart          # Authentication middleware for all API routes
│   │   ├── locations/
│   │   └── ... (one folder for each table)
│   └── test/
│       └── db.dart                    # Database connection test
├── .env.example                       # Environment variable template
├── .env                               # Your environment variables (gitignored)
├── api_tests.http                     # HTTP requests test suite
├── API_DOCUMENTATION.md               # Detailed API documentation
└── pubspec.yaml                       # Dependencies
```

## 🧩 Models & Type Safety

All models feature:

- ✅ **Safe Type Casting** - Automatically handles database string-to-int/double conversions
- ✅ **JSON Serialization/Deserialization** - `fromJson()` and `toJson()` methods
- ✅ **Database Row Mapping** - `fromDb()` for database results
- ✅ **Null-safe Field Handling** - Proper null safety throughout
- ✅ **camelCase ↔ snake_case Conversion** - Automatic field name mapping

## 🛡️ Error Handling

The API provides comprehensive HTTP error codes:

| Code | Meaning               | Description                   |
| ---- | --------------------- | ----------------------------- |
| 200  | OK                    | Request successful            |
| 201  | Created               | Resource created successfully |
| 400  | Bad Request           | Invalid request data          |
| 401  | Unauthorized          | Missing or invalid token      |
| 403  | Forbidden             | Token expired                 |
| 404  | Not Found             | Resource doesn't exist        |
| 422  | Validation Error      | Request validation failed     |
| 500  | Internal Server Error | Server-side error occurred    |

### Error Response Format

```json
{
  "success": false,
  "message": "Error description",
  "error": "Detailed error message",
  "timestamp": "2026-02-10T20:00:00.000Z"
}
```

## 🔐 Security Features

- ✅ **JWT Authentication** - Token-based authentication for all API endpoints
- ✅ **Password Hashing** - Bcrypt with automatic salt generation
- ✅ **Protected Routes** - Authentication middleware on all `/api/*` endpoints
- ✅ **Token Expiration** - 24-hour token lifetime (configurable)
- ✅ **Environment Variables** - Sensitive data in `.env` file
- ✅ **SQL Parameterization** - Protection against SQL injection
- ✅ **Type Validation** - Runtime type checking and casting
- ✅ **Error Sanitization** - No sensitive data in error responses

## 🧪 Testing

Run tests:

```bash
dart test
```

### Available Test Files

- `test_connection.dart` - Test database connectivity
- `test_locations_schema.dart` - Test Locations table schema
- `test_table_structure.dart` - Test table structures
- `test_raw_query.dart` - Test raw SQL queries

## 📝 Development Notes

### Safe Type Casting

The API automatically handles cases where the MS SQL Database returns string values instead of expected numeric types.

### Field Naming Convention

- **Database Columns**: `Pascal_Snake_Case` (e.g., `Handasah_Name`)
- **JSON Fields**: `camelCase` (e.g., `handasahName`)
- **Models**: Automatic conversion between conventions

## 🚀 Deployment

1. Build the production bundle:

   ```bash
   dart_frog build
   ```

2. The compiled application will be in `build/`

3. Deploy to your server and set environment variables (especially `JWT_SECRET`)

4. Run with:

   ```bash
   dart run build/bin/server.dart
   ```

## 📄 License

MIT License - See LICENSE file for details

## 👨‍💻 Author

Built with ❤️ using Dart Frog

---

**Project Version**: 1.0.0  
**Last Updated**: February 10, 2026
