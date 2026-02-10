# REST API - MS SQL Database with Dart Frog

A complete REST API built with Dart Frog and dart_odbc for managing MS SQL Server database tables.

## Features

- ✅ 8 Database tables with full CRUD operations
- ✅ RESTful API endpoints
- ✅ Standardized JSON responses
- ✅ Error handling and validation
- ✅ Repository pattern for data access
- ✅ Environment-based configuration

## Prerequisites

- Dart SDK 3.0.0 or higher
- MS SQL Server database
- ODBC Driver for SQL Server installed on your system

### Installing ODBC Driver (Linux)

```bash
# For Ubuntu/Debian
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/prod.list | sudo tee /etc/apt/sources.list.d/mssql-release.list
sudo apt-get update
sudo ACCEPT_EULA=Y apt-get install -y msodbcsql18
sudo apt-get install -y unixodbc-dev
```

## Setup

1. **Clone and install dependencies:**

   ```bash
   cd restapi_dart_frog
   dart pub get
   ```

2. **Configure database connection:**

   Copy `.env.example` to `.env` and update with your database credentials:

   ```bash
   cp .env.example .env
   ```

   Edit `.env`:

   ```env
   DB_SERVER=your_server_name_or_ip
   DB_PORT=1433
   DB_DATABASE=your_database_name
   DB_USERNAME=your_username
   DB_PASSWORD=your_password
   DB_DRIVER={ODBC Driver 18 for SQL Server}
   ```

3. **Load environment variables:**
   ```bash
   export $(cat .env | xargs)
   ```

## Running the API

Start the development server:

```bash
dart_frog dev
```

The API will be available at `http://localhost:8080`

## API Endpoints

All endpoints return JSON responses in the following format:

### Success Response

```json
{
  "success": true,
  "message": "Operation successful",
  "data": {}
}
```

### Error Response

```json
{
  "success": false,
  "message": "Error message",
  "errors": {}
}
```

### Available Tables

Each table has the following endpoints:

| Table                  | Base Endpoint                 |
| ---------------------- | ----------------------------- |
| Pick Location Handasah | `/api/pick_location_handasah` |
| Pick Location Users    | `/api/pick_location_users`    |
| Tracking Locations     | `/api/tracking_locations`     |
| Handasat Tools         | `/api/handasat_tools`         |
| Hot Line Data          | `/api/hot_line_data`          |
| Locations              | `/api/locations`              |
| Tools Requests         | `/api/tools_requests`         |
| Hot Line Status Data   | `/api/hot_line_status_data`   |

### CRUD Operationsyour_server_name_or_ip

For each table:

**List all records:**

```bash
GET /api/{table}
```

**Get single record:**

```bash
GET /api/{table}/{id}
```

**Create new record:**

```bash
POST /api/{table}
Content-Type: application/json

{
  "field1": "value1",
  "field2": "value2"
}
```

**Update record:**

```bash
PUT /api/{table}/{id}
Content-Type: application/json

{
  "field1": "new_value1",
  "field2": "new_value2"
}
```

**Delete record:**

```bash
DELETE /api/{table}/{id}
```

## Example Usage

### Create a new location:

```bash
curl -X POST http://localhost:8080/api/pick_location_handasah \
  -H "Content-Type: application/json" \
  -d '{
    "handasah_name": "Engineering Department",
    "store_name": "Main Store",
    "store_number": 101
  }'
```

### Get all users:

```bash
curl http://localhost:8080/api/pick_location_users
```

### Update a tracking location:

```bash
curl -X PUT http://localhost:8080/api/tracking_locations/1 \
  -H "Content-Type: application/json" \
  -d '{
    "address": "123 Main St",
    "latitude": "30.0444",
    "longitude": "31.2357"
  }'
```

### Delete a record:

```bash
curl -X DELETE http://localhost:8080/api/handasat_tools/5
```

## Project Structure

```
restapi_dart_frog/
├── lib/
│   ├── database/          # Database configuration and helpers
│   ├── models/            # Data models for each table
│   ├── repositories/      # Repository pattern implementations
│   └── utils/             # Utility functions (response helpers, validators)
├── routes/
│   ├── _middleware.dart   # Global middleware for DB initialization
│   └── api/               # API route handlers for all tables
├── .env.example           # Environment variable template
└── pubspec.yaml           # Dependencies
```

## Models

All models support:

- JSON serialization/deserialization
- Database row mapping
- Null-safe field handling

## Error Handling

The API provides comprehensive error handling:

- 400: Bad Request (invalid data)
- 404: Not Found (resource doesn't exist)
- 422: Validation Error (invalid input)
- 500: Internal Server Error

## Development

Run tests:

```bash
dart test
```

Build for production:

```bash
dart_frog build
```

## License

MIT
