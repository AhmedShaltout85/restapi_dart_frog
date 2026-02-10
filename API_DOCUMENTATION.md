# API Documentation

Complete API reference for all available endpoints.

## Authentication

Currently, the API does not require authentication. Consider adding authentication middleware for production use.

## Base URL

```
http://localhost:8080/api
```

## Response Format

All responses follow this structure:

### Success Response

```json
{
  "success": true,
  "message": "Description of the result",
  "data": { ... }  // or [ ... ] for lists
}
```

### Error Response

```json
{
  "success": false,
  "message": "Error description",
  "errors": { ... }  // Optional - validation errors
}
```

## HTTP Status Codes

- `200 OK` - Successful GET/PUT/DELETE
- `201 Created` - Successful POST
- `400 Bad Request` - Invalid request format or ID
- `404 Not Found` - Resource doesn't exist
- `405 Method Not Allowed` - Unsupported HTTP method
- `422 Unprocessable Entity` - Validation errors
- `500 Internal Server Error` - Server/database error

---

## 1. Pick Location Handasah

**Base Path:** `/api/pick_location_handasah`

### List All

```http
GET /api/pick_location_handasah
```

**Response:**

```json
{
  "success": true,
  "message": "Retrieved X records",
  "data": [
    {
      "id": 1,
      "handasah_name": "Engineering Dept",
      "store_name": "Main Store",
      "store_number": 101
    }
  ]
}
```

### Get Single Record

```http
GET /api/pick_location_handasah/{id}
```

### Create New Record

```http
POST /api/pick_location_handasah
Content-Type: application/json

{
  "handasah_name": "Engineering Dept",
  "store_name": "Main Store",
  "store_number": 101
}
```

### Update Record

```http
PUT /api/pick_location_handasah/{id}
Content-Type: application/json

{
  "handasah_name": "Updated Name",
  "store_name": "Updated Store",
  "store_number": 102
}
```

### Delete Record

```http
DELETE /api/pick_location_handasah/{id}
```

---

## 2. Pick Location Users

**Base Path:** `/api/pick_location_users`

### List All

```http
GET /api/pick_location_users
```

### Operations

Same CRUD operations as above with fields:

- `id` (auto-generated)
- `user_name` (string, optional)
- `user_password` (string, optional)
- `role` (integer, optional)
- `control_unit` (string, optional)
- `technical_id` (integer, optional)

---

## 3. Tracking Locations

**Base Path:** `/api/tracking_locations`

### Fields

- `id` (auto-generated)
- `address` (string, optional)
- `latitude` (string, optional)
- `longitude` (string, optional)
- `technical_Name` (string, optional)
- `start_latitude` (string, optional)
- `start_longitude` (string, optional)
- `current_latitude` (string, optional)
- `current_longitude` (string, optional)

### Operations

Standard CRUD operations (GET, POST, PUT, DELETE)

---

## 4. Handasat Tools

**Base Path:** `/api/handasat_tools`

### Fields

- `id` (auto-generated)
- `handasah_name` (string, optional)
- `tool_name` (string, optional)
- `tool_qty` (integer, optional)

### Operations

Standard CRUD operations (GET, POST, PUT, DELETE)

---

## 5. Hot Line Data

**Base Path:** `/api/hot_line_data`

### Fields

- `id` (auto-generated)
- `phone` (string, optional)
- `mobile` (string, optional)
- `title_id` (integer, optional)
- `home_number` (string, optional)
- `floor_number_id` (integer, optional)
- `area_id` (integer, optional)
- `side_street` (string, optional)
- `main_street` (string, optional)
- `near_to` (string, optional)
- `name` (string, optional)
- `subscribe_no` (string, optional)
- `area_no` (string, optional)
- `email` (string, optional)
- `user_id` (integer, optional)
- `source_id` (integer, optional)
- `date_time` (date, optional)
- `notes` (string, optional)
- `x` (string, optional)
- `y` (string, optional)
- `sig` (string, optional)
- `keys` (string, optional)
- `customer_id` (integer, optional)

### Operations

Standard CRUD operations (GET, POST, PUT, DELETE)

---

## 6. Locations

**Base Path:** `/api/locations`

### Fields

- `ID` (auto-generated, note: uppercase)
- `Address` (string, required)
- `Latitude` (string, optional)
- `Longtiude` (string, optional - note typo in DB)
- `Date` (date, auto-default: current date)
- `Flag` (integer, optional)
- `Gis_Url` (string, optional)
- `Handasah_Name` (string, optional)
- `Technical_Name` (string, optional)
- `Is_Finished` (integer, default: 0)
- `Is_Approved` (integer, default: 0)
- `Caller_Name` (string, optional)
- `Broken_Type` (string, optional)
- `Caller_Number` (string, optional, default: "10")
- `Video_Call` (integer, optional)

### Operations

Standard CRUD operations (GET, POST, PUT, DELETE)

---

## 7. Tools Requests

**Base Path:** `/api/tools_requests`

### Fields

- `id` (auto-generated)
- `handasah_name` (string, optional)
- `tool_name` (string, optional)
- `tool_qty` (integer, default: 0)
- `tech_name` (string, optional)
- `request_status` (integer, default: 1)
- `is_approved` (integer, default: 0)
- `date` (date, auto-default: current date)
- `address` (string, optional)

### Operations

Standard CRUD operations (GET, POST, PUT, DELETE)

---

## 8. Hot Line Status Data

**Base Path:** `/api/hot_line_status_data`

**Note:** This table uses `uid` as the primary key instead of `id`.

### Fields

- `uid` (auto-generated primary key)
- `id` (integer, required)
- `water_stop_d_t` (string, optional)
- `case_repair_d_t` (string, optional)
- `water_opening_d_t` (string, optional)
- `notes` (string, optional)
- `final_closed` (boolean, optional)
- `reporter_name` (string, optional)
- `ref_no` (integer, optional)
- `street` (string, required)
- `main_street` (string, optional)
- `x` (string, optional)
- `y` (string, optional)
- `near_to` (string, optional)
- `user_name` (string, optional)
- `area` (string, optional)
- `town` (string, optional)
- `sector` (string, optional)
- `location_name` (string, optional)
- `company_acro_name` (integer, optional)
- `case_type` (string, optional)
- `activity_name` (string, optional)
- `valves_count` (integer, optional)
- `network` (string, optional)
- `pressure` (float, optional)
- `details` (string, optional)
- `extra_data_notes` (string, optional)
- `pipe_diameter` (integer, optional)
- `pipe_type` (string, optional)
- `pipe_status` (string, optional)
- `pipe_depth` (string, optional)
- `pipe_age` (string, optional)
- `break_length` (float, optional, default: 0.00)
- `b_width` (float, optional, default: 0.00)
- `plant_name` (string, optional)
- `plant_status` (string, optional)
- `affected_areas` (string, optional)
- `resons` (string, optional)
- `repair_type` (string, optional)
- `delay_resons` (string, optional)
- `case_report_date_time` (string, optional)
- `address` (string, optional)

### Operations

Standard CRUD operations (GET, POST, PUT, DELETE)

**Important:** Use `uid` as the ID parameter in the URL

---

## Testing Examples

```bash
# List all pick location handasah records
curl http://localhost:8080/api/pick_location_handasah

# Create a new user
curl -X POST http://localhost:8080/api/pick_location_users \
  -H "Content-Type: application/json" \
  -d '{"user_name":"john_doe","role":1}'

# Get tracking location by ID
curl http://localhost:8080/api/tracking_locations/5

# Update tools request
curl -X PUT http://localhost:8080/api/tools_requests/3 \
  -H "Content-Type: application/json" \
  -d '{"tool_qty":10,"is_approved":1}'

# Delete a location
curl -X DELETE http://localhost:8080/api/locations/2
```
