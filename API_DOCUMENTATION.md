# API Scout Mobile Client — Complete API Documentation

Everything required to rebuild the backend and client integration from scratch.

---

## Table of Contents

1. [Architecture Overview](#1-architecture-overview)
2. [Remote REST API — Base Config](#2-remote-rest-api--base-config)
3. [REST API Endpoints](#3-rest-api-endpoints)
   - 3.1 GET /APIs.json (full data)
   - 3.2 GET /APIs.json?file=categories (category names)
   - 3.3 GET /trendy-categories
   - 3.4 GET /search
   - 3.5 GET /recommend
   - 3.6 GET /submit/stats
   - 3.7 POST /submit
4. [Admin Endpoints (Server-Side)](#4-admin-endpoints-server-side)
5. [Server Utility Endpoints](#5-server-utility-endpoints)
6. [Firebase Firestore — Favorites](#6-firebase-firestore--favorites)
7. [Metadata Service — HTML Scraping](#7-metadata-service--html-scraping)
8. [API Ping — Health Check](#8-api-ping--health-check)
9. [Data Models (Complete Schemas)](#9-data-models-complete-schemas)
10. [Error Handling](#10-error-handling)
11. [Authentication Flow](#11-authentication-flow)
12. [External URLs](#12-external-urls)
13. [Server Deployment](#13-server-deployment)
14. [Curl Reference](#14-curl-reference)

---

## 1. Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│  Flutter Mobile Client (GetX MVC)                        │
│                                                          │
│  ┌──────────────┐   ┌──────────────┐   ┌──────────────┐ │
│  │ Controllers  │──▶│   Services   │──▶│  HTTP Layer  │ │
│  │ (GetX)       │   │              │   │ (package:http)│ │
│  └──────────────┘   └──────────────┘   └──────┬───────┘ │
│                                               │         │
└───────────────────────────────────────────────┼─────────┘
                                                │
            ┌───────────────────────────────────┼──────────┐
            │                                   │          │
            ▼                                   ▼          ▼
┌──────────────────────┐  ┌──────────────┐  ┌────────────────────┐
│ 1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app│  │   Firebase   │  │ External API URLs  │
│ (REST API Backend)   │  │   Firestore  │  │ (Metadata + Ping)  │
│ Node.js + Express    │  │   + Auth     │  │                    │
│ Vercel Serverless    │  │              │  │                    │
└──────────────────────┘  └──────────────┘  └────────────────────┘
```

**Tech Stack:**

| Layer | Technology |
|-------|-----------|
| Client | Flutter/Dart, GetX, `package:http` |
| Auth | Firebase Auth (Google Sign-In) |
| Remote DB | Cloud Firestore |
| Analytics | Firebase Analytics |
| Crash Reporting | Firebase Crashlytics |
| Local DB | Hive (key-value) |
| Backend | Node.js + Express, Vercel Serverless |
| Data Storage | File-based JSON (no database) |

---

## 2. Remote REST API — Base Config

```
Base URL:      https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app
Client Key:    sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213
HTTP Client:   package:http/http.dart
Content-Type:  application/json (POST bodies only)
```

**Auth Method:** Query parameter `?key=<KEY>` or `?token=<KEY>` on all protected endpoints.

**Server Environment Variables:**

| Variable | Required | Purpose |
|----------|----------|---------|
| `AUTH_TOKEN` | Yes | User authentication token for protected endpoints |
| `ADMIN_TOKEN` | Yes | Admin-only token for submission management |
| `PORT` | No | Server port (default: 3000) |

---

## 3. REST API Endpoints

### 3.1 GET `/APIs.json` — Fetch All APIs (Full Dataset)

Returns the complete categorized API dataset with all enriched metadata.

**Query Parameters:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | string | Yes | — | Client API key |
| `file` | string | No | `"categorized"` | File type: `uncategorized`, `categorized`, `categories` |
| `folder` | string | No | latest export | Specific export folder timestamp (e.g. `2025-12-08T15-30-45.123456`) |

**Request Example:**
```
GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/APIs.json?key=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213
```

**Response (200 OK):**
```json
{
  "success": true,
  "count": 50,
  "fileName": "categorized.json",
  "folder": "2025-12-08T15-30-45.123456",
  "exportedAt": "2025-12-08T15:30:45.123456Z",
  "data": [
    {
      "title": "Animals",
      "apis": [
        {
          "name": "API Ninjas Cats",
          "description": "Query for data on different cat breeds",
          "auth": "apiKey",
          "https": "true",
          "cors": "Yes",
          "link": "https://api.api-ninjas.com/v1/cats",
          "category": "Animals",
          "apiType": "REST",
          "pricing": "Freemium",
          "rateLimit": "10 requests/second",
          "documentation": "https://api-ninjas.com/api/cats",
          "isAlive": true,
          "responseTime": 180,
          "statusCode": 200,
          "lastChecked": "2025-12-08T15:30:45.123456Z"
        }
      ]
    },
    {
      "title": "Weather",
      "apis": [
        {
          "name": "OpenWeather Map",
          "description": "Current weather and forecasts",
          "auth": "apiKey",
          "https": "true",
          "cors": "Yes",
          "link": "https://openweathermap.org/api",
          "category": "Weather",
          "apiType": "REST",
          "pricing": "Freemium",
          "rateLimit": "60 calls/minute",
          "documentation": "https://openweathermap.org/api",
          "isAlive": true,
          "responseTime": 245,
          "statusCode": 200,
          "lastChecked": "2025-12-08T15:30:45.123456Z"
        }
      ]
    }
  ]
}
```

**Client Parsed As:** `APIsDataResponse`
- `data` → `List<CategoryApis>` (each has `title` + `apis`)
- Each API → `ApiItem` (14 fields)

**Client Code:** `RemoteService.getData()` at `lib/app/services/fetch_api/remote_service.dart:386`

---

### 3.2 GET `/APIs.json?file=categories` — Fetch Category Names

Returns only the list of category names (no API data).

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `file` | string | Yes | Must be `"categories"` |
| `key` | string | Yes | Client API key |

**Request Example:**
```
GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/APIs.json?file=categories&key=sk_7acfa9c...
```

**Response (200 OK):**
```json
{
  "success": true,
  "count": 50,
  "fileName": "categories.json",
  "folder": "2025-12-08T15-30-45.123456",
  "exportedAt": "2025-12-08T15:30:45.123456Z",
  "data": [
    "Animals",
    "Anime",
    "Anti-Malware",
    "Art",
    "Authentication",
    "Blockchain",
    "Books",
    "Business",
    "Calendar",
    "Cloud Storage",
    "Communities",
    "Continuous Integration",
    "Currency Exchange",
    "Data Validation",
    "Development",
    "Documents & Productivity",
    "Environment",
    "Events",
    "Finance",
    "Food & Drink",
    "Games",
    "Geocoding",
    "Health",
    "IP Intelligence",
    "Jobs",
    "Machine Learning",
    "Maps",
    "Media",
    "Messaging",
    "Music",
    "News",
    "Open Data",
    "Open Source Projects",
    "Patent",
    "Personality",
    "Photography",
    "Programming",
    "Science",
    "Security",
    "Shopping",
    "Social",
    "Sports",
    "Test Data",
    "Tracking",
    "Transportation",
    "URL Shorteners",
    "Vehicle",
    "Video",
    "Weather",
    "Other"
  ]
}
```

**Client Parsed As:** `CategoriesResponse`
- `data` → `List<String>` (category names only)

**Client Code:** `RemoteService.getCategories()` at `lib/app/services/fetch_api/remote_service.dart:22`

---

### 3.3 GET `/trendy-categories` — Fetch Featured Categories

Returns category names that should be displayed with a trendy/featured badge.

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `key` | string | Yes | Client API key |

**Request Example:**
```
GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/trendy-categories?key=sk_7acfa9c...
```

**Response (200 OK):** Accepts 3 formats:

Format A — Direct array:
```json
["Weather", "Finance", "Social", "Maps"]
```

Format B — Object with `data`:
```json
{
  "data": ["Weather", "Finance", "Social", "Maps"]
}
```

Format C — Object with `categories`:
```json
{
  "categories": ["Weather", "Finance", "Social", "Maps"]
}
```

**Client Parsed As:** `List<String>`

**Client Code:** `RemoteService.getTrendyCategories()` at `lib/app/services/fetch_api/remote_service.dart:69`

---

### 3.4 GET `/search` — Search & Filter APIs

Full-text search with multi-criterion filtering, sorting, and pagination. The most complex endpoint.

**Query Parameters:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `token` | string | Yes | — | Client API key |
| `q` | string | No | — | Full-text search across name, description, category (case-insensitive partial match) |
| `pricing` | string[] | No | — | Filter: `free`, `freemium`, `paid`. Multi-value = OR |
| `auth` | string[] | No | — | Filter: `none`, `apiKey`, `OAuth`, `OAuth2.0`, `Bearer`, etc. Multi-value = OR |
| `cors` | string | No | — | Filter: `yes`, `no`, `unknown` (exact match) |
| `https` | string | No | — | Filter: `true`, `false` (exact match) |
| `apiType` | string[] | No | — | Filter: `REST`, `GraphQL`, `SOAP`, `WebSocket`, `gRPC`, `Webhook`. Multi-value = OR |
| `category` | string[] | No | — | Filter by category name. Multi-value = OR |
| `alive` | string | No | — | Filter: `true` (working), `false` (dead). Exact match |
| `maxResponseTime` | int | No | — | Max response time in ms. Excludes APIs with `responseTime = -1` |
| `sortBy` | string | No | `name` | Sort field: `name`, `responseTime`, `category` |
| `sortOrder` | string | No | `asc` | Sort direction: `asc`, `desc` |
| `page` | int | No | `1` | Page number (min: 1) |
| `limit` | int | No | `20` | Results per page (min: 1, max: 100, server-enforced) |

**Filter Logic:**
- Same filter, multiple values → OR: `?pricing=free&pricing=paid` = free OR paid
- Different filters → AND: `?pricing=free&alive=true` = free AND alive
- `q` is applied first, then all filters simultaneously, then sorting, then pagination

**Request Examples:**
```
GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/search?q=weather&pricing=free&alive=true&token=sk_7acfa9c...

GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/search?apiType=REST&auth=none&maxResponseTime=300&sortBy=responseTime&sortOrder=asc&token=sk_7acfa9c...

GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/search?pricing=free&pricing=freemium&category=Finance&category=Payment&token=sk_7acfa9c...

GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/search?page=2&limit=50&sortBy=name&token=sk_7acfa9c...
```

**Response (200 OK):**
```json
{
  "success": true,
  "query": "weather",
  "filters": {
    "pricing": "free",
    "alive": "true",
    "https": "true"
  },
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 156,
    "totalPages": 8,
    "hasMore": true
  },
  "data": [
    {
      "name": "OpenWeather API",
      "description": "Weather forecasts, nowcasts and history in JSON format",
      "auth": "apiKey",
      "https": "true",
      "cors": "yes",
      "link": "https://api.openweathermap.org",
      "category": "Weather",
      "apiType": "REST",
      "pricing": "Freemium",
      "rateLimit": "60 calls/minute",
      "documentation": "https://openweathermap.org/api",
      "isAlive": true,
      "responseTime": 234,
      "statusCode": 200,
      "lastChecked": "2025-12-08T10:30:00.000Z"
    }
  ]
}
```

**Client Parsed As:** `SearchResponse`
- `data` → `List<ApiItem>`
- `pagination` → `SearchPagination` (page, limit, total, totalPages, hasMore)

**Client Code:** `RemoteService.searchApis()` at `lib/app/services/fetch_api/remote_service.dart:128`

---

### 3.5 GET `/recommend` — Get API Recommendations

Returns recommended APIs based on type and criteria.

**Query Parameters:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `key` | string | Yes | — | Client API key |
| `type` | string | Yes | — | Recommendation type: `best`, `similar`, `usecase` |
| `criteria` | string | No | — | For `type=best`: `fastest`, `most-reliable`, `free`, `no-auth`, `cors-enabled`, `https-only` |
| `apiName` | string | No | — | For `type=similar`: Name of API to find similar ones |
| `useCase` | string | No | — | For `type=usecase`: Use case keyword |
| `limit` | int | No | `10` | Max results (max: 50) |

**Supported `useCase` values:**

| Use Case | Keywords |
|----------|----------|
| Weather | `weather`, `climate` |
| Social | `social`, `twitter`, `facebook` |
| Payment | `payment`, `stripe`, `paypal` |
| Maps | `maps`, `location`, `geo` |
| Mail | `mail`, `email`, `smtp` |
| SMS | `sms`, `text`, `messaging` |
| Storage | `storage`, `cloud`, `s3` |
| Search | `search`, `elasticsearch`, `database` |

**Request Examples:**
```
GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/recommend?type=best&criteria=fastest&token=sk_7acfa9c...

GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/recommend?type=similar&apiName=GitHub&token=sk_7acfa9c...

GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/recommend?type=usecase&useCase=weather&limit=10&token=sk_7acfa9c...
```

**Response (200 OK):** Returns either a direct array or an object with `data` field:

Format A — Direct array:
```json
[
  {
    "id": "uuid-string",
    "name": "OpenWeather",
    "description": "Weather data API",
    "auth": "API Key",
    "https": true,
    "cors": true,
    "link": "https://openweathermap.org",
    "categoryId": "Weather",
    "pricing": "Freemium",
    "alive": true
  }
]
```

Format B — Object wrapper:
```json
{
  "data": [
    {
      "id": "uuid-string",
      "name": "OpenWeather",
      "description": "Weather data API",
      "auth": "API Key",
      "https": true,
      "cors": true,
      "link": "https://openweathermap.org",
      "categoryId": "Weather",
      "pricing": "Freemium",
      "alive": true
    }
  ]
}
```

**Client Parsed As:** `List<Api>` (the `Api` model with `id`, `categoryId` fields — NOT `ApiItem`)

**Client Code:** `RemoteService.getRecommendations()` at `lib/app/services/fetch_api/remote_service.dart:213`

---

### 3.6 GET `/submit/stats` — Submission Statistics

No authentication required.

**Request Example:**
```
GET https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/submit/stats
```

**Response (200 OK):**
```json
{
  "pending": 5,
  "approved": 120,
  "rejected": 12,
  "total": 137
}
```

**Client Parsed As:** `Map<String, dynamic>`

**Client Code:** `RemoteService.getSubmissionStats()` at `lib/app/services/fetch_api/remote_service.dart:281`

---

### 3.7 POST `/submit` — Submit New API for Review

**Query Parameters:**

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `key` | string | Yes | Client API key |

**Request Headers:**
```
Content-Type: application/json
```

**Request Body (JSON):**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | Yes | API name |
| `link` | string | Yes | API URL |
| `description` | string | Yes | Description (min 10 characters) |
| `category` | string | Yes | Category name |
| `key` | string | Yes | Client API key (duplicated in body) |
| `auth` | string | No | Auth type (e.g. `API Key`, `OAuth`, `None`) |
| `https` | bool | No | HTTPS support |
| `cors` | string | No | CORS support: `Yes`, `No`, `Unknown` |
| `pricing` | string | No | Pricing model: `Free`, `Freemium`, `Paid` |
| `documentation` | string | No | Documentation URL |
| `rateLimit` | string | No | Rate limit info |
| `submitterEmail` | string | No | Submitter's email |
| `submitterName` | string | No | Submitter's name |
| `notes` | string | No | Additional notes |

**Request Example:**
```
POST https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/submit?key=sk_7acfa9c...
Content-Type: application/json

{
  "name": "My Weather API",
  "link": "https://api.myweather.com",
  "description": "A comprehensive weather API with forecasts and historical data",
  "category": "Weather",
  "key": "sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213",
  "auth": "API Key",
  "https": true,
  "cors": "Yes",
  "pricing": "Free",
  "documentation": "https://docs.myweather.com",
  "rateLimit": "1000 requests/hour",
  "submitterEmail": "dev@example.com",
  "submitterName": "John Doe",
  "notes": "Great API, very reliable!"
}
```

**Response (200/201 OK):**
```json
{
  "success": true,
  "message": "API submission received successfully",
  "submissionId": "1733680123456-abc123def",
  "submission": {
    "id": "1733680123456-abc123def",
    "submittedAt": "2025-12-08T15:30:45.123Z",
    "status": "pending",
    "api": {
      "name": "My Weather API",
      "link": "https://api.myweather.com",
      "description": "A comprehensive weather API with forecasts and historical data",
      "category": "Weather",
      "auth": "API Key",
      "https": true,
      "cors": "Yes",
      "pricing": "Free",
      "documentation": "https://docs.myweather.com",
      "rateLimit": "1000 requests/hour"
    },
    "submitterEmail": "dev@example.com",
    "submitterName": "John Doe",
    "notes": "Great API, very reliable!"
  }
}
```

**Client Parsed As:** `Map<String, dynamic>`

**Client Code:** `RemoteService.submitApi()` at `lib/app/services/fetch_api/remote_service.dart:314`

---

## 4. Admin Endpoints (Server-Side)

These are documented in the server codebase. The mobile client does NOT call these — they are for admin use only. Included for completeness.

### 4.1 GET `/admin/submissions` — List Submissions

**Auth:** `ADMIN_TOKEN` required.

**Query Parameters:**

| Param | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `token` | string | Yes | — | Admin token |
| `status` | string | No | `pending` | Filter: `pending`, `approved`, `rejected`, `all` |

**Response (200):**
```json
{
  "submissions": [
    {
      "id": "1733680123456-abc123def",
      "submittedAt": "2025-12-08T15:30:45.123Z",
      "submitterEmail": "dev@example.com",
      "submitterName": "John Doe",
      "api": { ... },
      "notes": "...",
      "status": "pending",
      "reviewedAt": null,
      "reviewedBy": null,
      "rejectionReason": null
    }
  ]
}
```

---

### 4.2 POST `/admin/submissions/approve` — Approve Submission

**Auth:** `ADMIN_TOKEN` required.

**Request Body:**
```json
{
  "submissionId": "1733680123456-abc123def",
  "reviewedBy": "admin@example.com"
}
```

---

### 4.3 PUT `/admin/submissions/reject` — Reject Submission

**Auth:** `ADMIN_TOKEN` required.

**Request Body:**
```json
{
  "submissionId": "1733680123456-abc123def",
  "rejectionReason": "API endpoint not responding",
  "reviewedBy": "admin@example.com"
}
```

---

### 4.4 DELETE `/admin/submissions/delete` — Delete Submission

**Auth:** `ADMIN_TOKEN` required.

**Request Body:**
```json
{
  "submissionId": "1733680123456-abc123def"
}
```

---

## 5. Server Utility Endpoints

### 5.1 GET `/` — Server Info

**Auth:** None.

Returns JSON with server info, available endpoints, authentication methods.

---

### 5.2 GET `/health` — Health Check

**Auth:** None.

**Response:**
```json
{
  "status": "ok",
  "uptime": 12345,
  "timestamp": "2025-12-08T15:30:45.123Z"
}
```

---

### 5.3 GET/POST `/scrape` — Trigger API Scraping

**Auth:** `AUTH_TOKEN` required.

Triggers full scraping from all sources (PublicAPIs.io, Public APIs Dev GitHub). Duration: 2-5 minutes.

**Response:**
```json
{
  "success": true,
  "message": "Scraping completed successfully",
  "folder": "2025-12-08T15-30-45.123456",
  "rawFileName": "uncategorized.json",
  "categorizedFileName": "categorized.json",
  "categoriesFileName": "categories.json",
  "totalFetched": 1700,
  "unique": 1529,
  "totalCategories": 45,
  "categories": ["Weather", "Social", "Finance"]
}
```

---

## 6. Firebase Firestore — Favorites

**Firebase Project:** `public-apis-gwhyy`

### 6.1 Collection Structure

```
users/
  └── {userId}/
        └── favorites/
              └── {favoriteId}/
```

### 6.2 Document Schema — `FirestoreFavorite`

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | string | No | UUID v4 (generated client-side) |
| `userId` | string | No | Firebase Auth UID |
| `apiName` | string | No | API display name |
| `apiLink` | string | No | API URL (used as unique identifier for `isFavorited`) |
| `category` | string | No | Category name |
| `description` | string | No | API description |
| `auth` | string | No | Auth type |
| `https` | string | No | `"true"` or `"false"` |
| `cors` | string | No | `"Yes"`, `"No"`, `"Unknown"` |
| `personalNotes` | string | Yes | User's personal notes about the API |
| `addedAt` | Timestamp | No | Firestore Timestamp (auto-set on create) |
| `updatedAt` | Timestamp | No | Firestore Timestamp (auto-set on create/update) |

### 6.3 Operations

#### Add Favorite
```dart
// Dart
await FirestoreFavoritesService().addFavorite(
  apiName: 'OpenWeather',
  apiLink: 'https://openweathermap.org',
  category: 'Weather',
  description: 'Weather data',
  auth: 'API Key',
  https: 'true',
  cors: 'Yes',
  personalNotes: 'My notes',  // optional
);
```

Firestore call:
```dart
_userFavoritesCollection.doc(favorite.id).set(favorite.toFirestore());
```

#### Get All Favorites (One-Time)
```dart
final snapshot = await _userFavoritesCollection.get();
// Returns List<FirestoreFavorite>
```

#### Get Favorites Stream (Real-Time)
```dart
_userFavoritesCollection.snapshots().map((snapshot) =>
  snapshot.docs.map((doc) => FirestoreFavorite.fromFirestore(doc)).toList()
);
```

#### Update Personal Notes
```dart
await _userFavoritesCollection.doc(favoriteId).update({
  'personalNotes': newNotes,
  'updatedAt': DateTime.now(),
});
```

#### Remove Favorite
```dart
await _userFavoritesCollection.doc(favoriteId).delete();
```

#### Check if Favorited
```dart
final snapshot = await _userFavoritesCollection
    .where('apiLink', isEqualTo: apiLink)
    .limit(1)
    .get();
return snapshot.docs.isNotEmpty;
```

#### Get Favorite by Link
```dart
final snapshot = await _userFavoritesCollection
    .where('apiLink', isEqualTo: apiLink)
    .limit(1)
    .get();
```

#### Clear All Favorites
```dart
final snapshot = await _userFavoritesCollection.get();
for (final doc in snapshot.docs) {
  await doc.reference.delete();
}
```

**Client Code:** `FirestoreFavoritesService` at `lib/app/services/firestore/firestore_favorites_service.dart`

---

## 7. Metadata Service — HTML Scraping

Fetches HTML from external API URLs to extract favicon, description, banner, and title for display in the UI.

### 7.1 Implementation

```dart
// Dart
class MetadataService {
  static final MetadataService _instance = MetadataService._internal();
  final Map<String, ApiMetadata> _cache = {};  // In-memory cache

  Future<ApiMetadata?> fetchMetadata(String url) async {
    if (_cache.containsKey(url)) return _cache[url];

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
      },
    ).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final metadata = _parseMetadata(response.body, url);
      _cache[url] = metadata;
      return metadata;
    }
    return null;
  }
}
```

### 7.2 Extracted Fields

| Field | HTML Source | Priority |
|-------|-----------|----------|
| `favicon` | `<link rel="icon">` → `<link rel="shortcut icon">` → `<link rel="apple-touch-icon">` → fallback `{baseUrl}/favicon.ico` | 1-4 |
| `description` | `<meta name="description">` → `<meta property="og:description">` → `<meta name="twitter:description">` | 1-3 |
| `banner` | `<meta name="announcement">` → `<meta name="status">` → `<meta name="notice">` → `<meta property="og:site_name">` → `.banner` → `.alert` → `.notice` → `.notification` → `[role="banner"]` → `[role="alert"]` | 1-10 |
| `title` | `<title>` → `<meta property="og:title">` | 1-2 |

### 7.3 Response Model

```dart
class ApiMetadata {
  final String? favicon;
  final String? description;
  final String? banner;
  final String? title;
}
```

### 7.4 URL Resolution

| Input | Resolved |
|-------|----------|
| `https://example.com/icon.png` | `https://example.com/icon.png` |
| `//cdn.example.com/icon.png` | `https://cdn.example.com/icon.png` |
| `/favicon.ico` | `{baseUrl}/favicon.ico` |
| `favicon.ico` | `{baseUrl}/favicon.ico` |

**Client Code:** `MetadataService` at `lib/app/services/metadata/metadata_service.dart`

---

## 8. API Ping — Health Check

The client pings external API URLs via HTTP HEAD to check availability.

### 8.1 Implementation

```dart
// Dart
final response = await http.head(
  Uri.parse(api.link),
  headers: {
    'User-Agent': 'Mozilla/5.0 (compatible; PublicAPIs/1.0; +https://api-client.app)'
  },
).timeout(const Duration(seconds: 10));
```

### 8.2 Result Model

```dart
class ApiPingResult {
  final bool isOnline;           // true if statusCode 200-499
  final int? statusCode;         // HTTP status code
  final String? statusMessage;   // Human-readable status
  final int durationMs;          // Response time in ms
  final String? errorMessage;    // Error message if failed
  final Map<String, String>? headers;  // Response headers
  final DateTime timestamp;      // When the ping was made
}
```

### 8.3 Status Code Mapping

| Code | Message |
|------|---------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 301 | Moved Permanently |
| 302 | Found |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 429 | Too Many Requests |
| 500 | Internal Server Error |
| 502 | Bad Gateway |
| 503 | Service Unavailable |

### 8.4 Online Determination

```dart
isOnline: response.statusCode >= 200 && response.statusCode < 500
```

**Client Code:** `ApiDetailController.pingApi()` at `lib/app/modules/controllers/api_detail_controller/api_detail_controller.dart:67`

---

## 9. Data Models (Complete Schemas)

### 9.1 `Api` — Recommendation/Detail Model

Used for `/recommend` endpoint responses and internal detail views.

```dart
class Api {
  final String id;           // Unique identifier
  final String name;         // API name
  final String description;  // API description
  final String auth;         // Auth type (e.g. "API Key", "OAuth", "None")
  final bool https;          // HTTPS support
  final bool cors;           // CORS support
  final String link;         // API URL
  final String categoryId;   // Category name/id
  final String? pricing;     // Pricing model (nullable)
  final bool? alive;         // Whether API is responding (nullable)
}
```

**JSON Serialization:**
```json
{
  "id": "uuid-string",
  "name": "OpenWeather",
  "description": "Weather data",
  "auth": "API Key",
  "https": true,
  "cors": true,
  "link": "https://openweathermap.org",
  "categoryId": "Weather",
  "pricing": "Freemium",
  "alive": true
}
```

Note: `https` and `cors` can be bool or string (`"true"`) in JSON — the `fromJson` handles both:
```dart
https: json["https"] is bool ? json["https"] : json["https"] == "true",
cors: json["cors"] is bool ? json["cors"] : json["cors"] == "true",
```

---

### 9.2 `ApiItem` — Full Enriched API Model

Used in `/APIs.json` and `/search` responses. Contains 14 fields.

```dart
class ApiItem {
  final String name;           // API name
  final String description;    // API description
  final String auth;           // Auth type (default: "None")
  final String https;          // "true" or "false" (String, not bool)
  final String cors;           // "Yes", "No", "Unknown"
  final String link;           // API URL
  final String category;       // Category name
  final String apiType;        // "REST", "GraphQL", "SOAP", etc. (default: "REST")
  final String pricing;        // "Free", "Freemium", "Paid", "Unknown"
  final String rateLimit;      // Rate limit description (default: "Unknown")
  final String documentation;  // Docs URL
  final bool isAlive;          // Whether API is responding
  final int responseTime;      // Response time in ms (-1 = error)
  final int? statusCode;       // HTTP status code (nullable)
  final String lastChecked;    // ISO timestamp of last health check
}
```

**JSON Serialization:**
```json
{
  "name": "OpenWeather API",
  "description": "Weather forecasts in JSON",
  "auth": "apiKey",
  "https": "true",
  "cors": "yes",
  "link": "https://api.openweathermap.org",
  "category": "Weather",
  "apiType": "REST",
  "pricing": "Freemium",
  "rateLimit": "60 calls/minute",
  "documentation": "https://openweathermap.org/api",
  "isAlive": true,
  "responseTime": 234,
  "statusCode": 200,
  "lastChecked": "2025-12-08T10:30:00.000Z"
}
```

**Computed Properties:**
```dart
bool get requiresAuth => auth.toLowerCase() != "none";
bool get supportsHttps => https.toLowerCase() == "true";
bool get supportsCors => cors.toLowerCase() == "yes";
String get healthStatus => isAlive ? "Alive" : "Dead";
String get responseTimeFormatted => responseTime < 1000 ? "${responseTime}ms" : "${(responseTime / 1000).toStringAsFixed(2)}s";
String get statusDescription { /* maps statusCode to human string */ }
bool get isFresh { /* true if lastChecked within 24 hours */ }
```

---

### 9.3 `CategoryApis` — Category with APIs

```dart
class CategoryApis {
  final String title;         // Category name
  final List<ApiItem> apis;   // APIs in this category
}
```

**JSON:**
```json
{
  "title": "Weather",
  "apis": [ ... ]
}
```

---

### 9.4 `Category` — Display Model

```dart
class Category {
  final String id;                // ID or title as string
  final String name;              // Display name
  final String? description;      // Optional description
  final String? imageUrl;         // Optional image URL
  final int apiCount;             // Number of APIs (default: 0)
  final String? icon;             // Optional icon identifier
  final List<String>? tags;       // Optional tags
  final bool hasTrendyBorder;     // Whether to show trendy badge
}
```

---

### 9.5 `CategoriesResponse` — Categories Endpoint Response

```dart
class CategoriesResponse {
  final bool success;
  final int count;
  final List<String> data;      // Category names
  final String fileName;
  final String folder;
  final String exportedAt;
}
```

---

### 9.6 `APIsDataResponse` — Full Dataset Response

```dart
class APIsDataResponse {
  final bool success;
  final List<CategoryApis> data;  // Categories with APIs
  final int count;
  final String fileName;
  final String folder;
  final String exportedAt;
}
```

**Computed Properties:**
```dart
int get totalApis;                    // Total APIs across all categories
CategoryApis? getCategoryByTitle(String title);
List<ApiItem> getAllApisAsList();      // Flat list of all APIs
List<ApiItem> searchApisByName(String query);
List<ApiItem> getApisByCategory(String categoryTitle);
DateTime? get exportedDateTime;
bool get isFresh;                     // true if exported within 24 hours
int get aliveApisCount;
int get deadApisCount;
double get availabilityPercentage;
bool validateData();                  // success + data not empty + at least 1 category has APIs
List<CategoryApis> getTopCategories({int limit = 10});
List<ApiItem> filterApis({String? categoryTitle, bool? requireHttps, ...});
```

---

### 9.7 `SearchResponse` — Search Endpoint Response

```dart
class SearchResponse {
  final bool success;
  final String? query;                              // The search query used
  final Map<String, dynamic>? filters;              // Active filters
  final SearchPagination pagination;                 // Pagination info
  final List<ApiItem> data;                         // Results
  final String? message;                            // Optional message
}

class SearchPagination {
  final int page;          // Current page
  final int limit;         // Results per page
  final int total;         // Total matching results
  final int totalPages;    // Total pages
  final bool hasMore;      // Whether more pages exist
}
```

---

### 9.8 `FirestoreFavorite` — Favorites Document

```dart
class FirestoreFavorite {
  final String id;
  final String userId;
  final String apiName;
  final String apiLink;
  final String category;
  final String description;
  final String auth;
  final String https;
  final String cors;
  final String? personalNotes;
  final DateTime addedAt;
  final DateTime? updatedAt;
}
```

**Firestore Serialization:**
```dart
Map<String, dynamic> toFirestore() => {
  'id': id,
  'userId': userId,
  'apiName': apiName,
  'apiLink': apiLink,
  'category': category,
  'description': description,
  'auth': auth,
  'https': https,
  'cors': cors,
  'personalNotes': personalNotes,
  'addedAt': addedAt,
  'updatedAt': updatedAt ?? DateTime.now(),
};
```

---

## 10. Error Handling

### 10.1 Server Error Format

All endpoints return:
```json
{
  "error": "Error type",
  "message": "Detailed error message"
}
```

### 10.2 HTTP Status Codes

| Code | Meaning |
|------|---------|
| 200 | OK |
| 201 | Created (submission accepted) |
| 400 | Bad request (invalid params) |
| 401 | Unauthorized (missing/invalid token) |
| 403 | Forbidden (invalid admin token) |
| 404 | Not found (no data / scraper hasn't run) |
| 500 | Server error |

### 10.3 Client-Side Error Model

```dart
class Failure {
  final String title;     // User-facing title
  final String content;   // User-facing description
}
```

### 10.4 Client-Side Error Mapping

| Exception | Failure Title | Failure Content |
|-----------|--------------|-----------------|
| `SocketException` | "no internet connection" | "check your internet connection and try again" |
| `HttpException` | "no service found" | "sorry, the service is not available at the moment" |
| `FormatException` | "Invalid Response Format" | "we're working on this issue, please try again later" |
| Other `Exception` | "unknown error" | "we're trying to fix this issue, please try again later" |

---

## 11. Authentication Flow

### 11.1 Mobile Client → Backend

All protected endpoints use query parameter auth:
```
?key=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213
```
OR:
```
?token=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213
```

### 11.2 Mobile Client → Firebase

- **Google Sign-In** via `google_sign_in` package
- **Firebase Auth** for user identity
- **Firestore** scoped to `users/{uid}/favorites/`

### 11.3 Admin Auth

Admin endpoints use `ADMIN_TOKEN` — never exposed to mobile client.

---

## 12. External URLs

| URL | Purpose |
|-----|---------|
| `https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app` | Main API backend |
| `https://gwhyyy.com` | Developer website |
| `https://gwhyyy.com/privacy` | Privacy policy |
| `mailto:work@gwhyyy.com` | Contact email |
| `https://play.google.com/store/apps/details?id=com.gwhyyy.publicApis` | Google Play Store |
| `https://apps.apple.com/app/id6502289191` | Apple App Store |
| `https://example.com/favicon.ico` | Fallback favicon |

---

## 13. Server Deployment

### Server Stack
- **Runtime:** Node.js + Express
- **Platform:** Vercel (Serverless)
- **Storage:** File-based JSON (no database)
- **Data Sources:** PublicAPIs.io, Public APIs Dev (GitHub)

### Server File Structure
```
public-apis-scrapper/
├── api/
│   ├── index.js           # Server info endpoint
│   ├── health.js          # Health check
│   ├── scrape.js          # Scraping logic
│   ├── apis.js            # /APIs.json endpoint
│   ├── search.js          # /search endpoint
│   ├── recommend.js       # /recommend endpoint
│   ├── submit.js          # /submit endpoint
│   ├── admin.js           # /admin/* endpoints
│   └── auth.js            # Authentication utilities
├── export/
│   └── {timestamp}/
│       ├── uncategorized.json
│       ├── categorized.json
│       └── categories.json
├── submissions/
│   ├── pending/{id}.json
│   ├── approved/{id}.json
│   └── rejected/{id}.json
├── server.js
├── package.json
├── .env
└── vercel.json
```

### Environment Setup
```bash
# .env
AUTH_TOKEN=secret123
ADMIN_TOKEN=admin-secret-token
PORT=3000
```

### Deploy
```bash
vercel deploy --prod
# Set env vars in Vercel dashboard: Settings > Environment Variables
```

---

## 14. Curl Reference

### Fetch All APIs
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/APIs.json?key=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Fetch Category Names
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/APIs.json?file=categories&key=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Fetch Trendy Categories
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/trendy-categories?key=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Search — Free Weather APIs
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/search?q=weather&pricing=free&alive=true&token=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Search — Fast REST APIs, No Auth
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/search?apiType=REST&auth=none&maxResponseTime=300&sortBy=responseTime&sortOrder=asc&token=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Search — HTTPS + CORS for Frontend
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/search?https=true&cors=yes&alive=true&limit=50&token=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Search — Paginated
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/search?q=data&page=2&limit=50&token=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Recommendations — Fastest APIs
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/recommend?type=best&criteria=fastest&token=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Recommendations — Similar to GitHub
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/recommend?type=similar&apiName=GitHub&token=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Recommendations — Weather Use Case
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/recommend?type=usecase&useCase=weather&limit=10&token=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
```

### Submission Stats
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/submit/stats"
```

### Submit New API
```bash
curl -X POST "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/submit?key=sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My API",
    "link": "https://api.example.com",
    "description": "A useful API for doing things",
    "category": "Utilities",
    "key": "sk_7acfa9c797c1bb3d5b6d97b98566fc227454ea60c1a5e213"
  }'
```

### Trigger Scraping (Admin)
```bash
curl -X POST "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/scrape?token=YOUR_AUTH_TOKEN"
```

### Admin — List Pending Submissions
```bash
curl "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/admin/submissions?status=pending&token=YOUR_ADMIN_TOKEN"
```

### Admin — Approve Submission
```bash
curl -X POST "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/admin/submissions/approve" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{"submissionId": "submission-id"}'
```

### Admin — Reject Submission
```bash
curl -X PUT "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/admin/submissions/reject" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{"submissionId": "submission-id", "rejectionReason": "API not responding"}'
```

### Admin — Delete Submission
```bash
curl -X DELETE "https://1423-2a09-bac5-3212-2c5a-00-46b-c.ngrok-free.app/admin/submissions/delete" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN" \
  -d '{"submissionId": "submission-id"}'
```

---

## Appendix: File Reference

| File | Purpose |
|------|---------|
| `lib/app/services/fetch_api/remote_service.dart` | All REST API calls (getData, getCategories, getTrendyCategories, searchApis, getRecommendations, submitApi, getSubmissionStats) |
| `lib/app/services/fetch_api/failure.dart` | Error model |
| `lib/app/services/metadata/metadata_service.dart` | HTML metadata scraping |
| `lib/app/services/firestore/firestore_favorites_service.dart` | Firestore CRUD operations |
| `lib/app/modules/controllers/api_detail_controller/api_detail_controller.dart` | API ping + metadata + scoring |
| `lib/app/modules/controllers/search_controller/search_controller.dart` | Search orchestration + filters |
| `lib/app/modules/controllers/submit_api_controller/submit_api_controller.dart` | Submit API form logic |
| `lib/app/modules/controllers/firestore_favorites_controller.dart` | Favorites orchestration |
| `lib/app/data/models/api.dart` | `Api` model (recommendations) |
| `lib/app/data/models/category_apis.dart` | `CategoryApis` + `ApiItem` models |
| `lib/app/data/models/apis_data_response.dart` | `APIsDataResponse` model |
| `lib/app/data/models/apis_search_response.dart` | `SearchResponse` + `SearchPagination` |
| `lib/app/data/models/categories_response.dart` | `CategoriesResponse` model |
| `lib/app/data/models/category.dart` | `Category` display model |
| `lib/app/data/models/firestore_favorite.dart` | `FirestoreFavorite` model |
