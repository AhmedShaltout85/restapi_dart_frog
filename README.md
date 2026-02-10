# REST API - MS SQL Database with Dart Frog

A complete RESTful API built with **Dart Frog** and **dart_odbc** for managing MS SQL Server database tables. Features full CRUD operations, type-safe models, and comprehensive error handling.

## 🚀 Features

- ✅ **8 Database Tables** with full CRUD operations
- ✅ **RESTful API Endpoints** following industry standards
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
```

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

## 📚 API Endpoints

### Available Tables & Endpoints

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

### CRUD Operations

For each table, the following operations are supported:

#### 📥 **List All Records**

```http
GET /api/{table}
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

#### 🔍 **Get Single Record**

```http
GET /api/{table}/{id}
```

**Response:**

```json
{
  "success": true,
  "data": { "id": 1, "field1": "value1", ... },
  "timestamp": "2026-02-10T20:00:00.000Z"
}
```

#### ➕ **Create New Record**

```http
POST /api/{table}
Content-Type: application/json

{
  "field1": "value1",
  "field2": "value2"
}
```

**Response (201 Created):**

```json
{
  "success": true,
  "message": "{Table} created successfully",
  "data": { "id": 123, "field1": "value1", ... },
  "timestamp": "2026-02-10T20:00:00.000Z"
}
```

#### ✏️ **Update Record**

```http
PUT /api/{table}/{id}
Content-Type: application/json

{
  "field1": "new_value1",
  "field2": "new_value2"
}
```

**Response:**

```json
{
  "success": true,
  "message": "{Table} updated successfully",
  "data": { "id": 1, "field1": "new_value1", ... },
  "timestamp": "2026-02-10T20:00:00.000Z"
}
```

#### 🗑️ **Delete Record**

```http
DELETE /api/{table}/{id}
```

**Response:**

```json
{
  "success": true,
  "message": "{Table} deleted successfully",
  "timestamp": "2026-02-10T20:00:00.000Z"
}
```

### 🔧 Utility Endpoints

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

#### Create a new location:

```bash
curl -X POST http://localhost:8080/api/locations \
  -H "Content-Type: application/json" \
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
curl http://localhost:8080/api/hot_line_data
```

#### Update a tools request:

```bash
curl -X PUT http://localhost:8080/api/tools_requests/1 \
  -H "Content-Type: application/json" \
  -d '{
    "toolQty": 5,
    "requestStatus": 2,
    "isApproved": 1
  }'
```

#### Delete a tracking location:

```bash
curl -X DELETE http://localhost:8080/api/tracking_locations/5
```

### Using the HTTP Test File

The project includes `api_tests.http` with ready-to-use HTTP requests for all endpoints. Open it in VS Code with the REST Client extension and click "Send Request" above any request.

## 📁 Project Structure

```
restapi_dart_frog/
├── lib/
│   ├── database/
│   │   ├── database_config.dart      # Database configuration
│   │   └── database_helper.dart      # Database connection & query helpers
│   ├── models/                        # Data models (8 tables)
│   │   ├── locations_model.dart
│   │   ├── handasat_tools_model.dart
│   │   ├── hot_line_data_model.dart
│   │   ├── hot_line_status_data_model.dart
│   │   ├── pick_location_handasah_model.dart
│   │   ├── pick_location_users_model.dart
│   │   ├── tools_requests_model.dart
│   │   └── tracking_locations_model.dart
│   └── repositories/                  # Repository pattern implementations
│       ├── locations_repository.dart
│       └── ... (one for each model)
├── routes/
│   ├── _middleware.dart               # Global CORS middleware
│   ├── api/                           # API route handlers
│   │   ├── locations/
│   │   ├── handasat_tools/
│   │   ├── hot_line_data/
│   │   ├── hot_line_status_data/
│   │   ├── pick_location_handasah/
│   │   ├── pick_location_users/
│   │   ├── tools_requests/
│   │   └── tracking_locations/
│   ├── test/
│   │   └── db.dart                    # Database connection test
│   └── debug.dart                     # Debug endpoint
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

### Example Model Usage

```dart
// From JSON (API request)
final location = Locations.fromJson(jsonData);

// From Database Row
final location = Locations.fromDb(dbRow);

// To JSON (API response)
final jsonData = location.toJson();
```

## 🛡️ Error Handling

The API provides comprehensive HTTP error codes:

| Code | Meaning               | Description                   |
| ---- | --------------------- | ----------------------------- |
| 200  | OK                    | Request successful            |
| 201  | Created               | Resource created successfully |
| 400  | Bad Request           | Invalid request data          |
| 404  | Not Found             | Resource doesn't exist        |
| 405  | Method Not Allowed    | HTTP method not supported     |
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

The API automatically handles cases where the MS SQL Database returns string values instead of expected numeric types. Each model includes safe casting helpers:

```dart
int? safeIntCast(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
```

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

3. Deploy to your server and set environment variables

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
