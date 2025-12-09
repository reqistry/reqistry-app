# Public APIs Scraper & Server - Complete Documentation

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Setup & Installation](#setup--installation)
4. [Environment Variables](#environment-variables)
5. [API Endpoints](#api-endpoints)
6. [Data Models](#data-models)
7. [File Structure](#file-structure)
8. [Deployment](#deployment)
9. [Admin Operations](#admin-operations)
10. [Examples & Curl Commands](#examples--curl-commands)

---

## Overview

**Public APIs Scraper** is a full-stack API aggregation and discovery service that:

- Scrapes APIs from multiple sources (PublicAPIs.io, Public APIs Dev)
- Enriches API data with runtime checks (ping, response time, status codes)
- Provides search, filtering, and recommendation capabilities
- Allows users to submit new APIs for review
- Offers admin tools to manage submissions

**Stack**: Node.js + Express, Serverless (Vercel), File-based storage

---

## Architecture

### High-Level Flow

```
┌─────────────────────────────────────────────────────┐
│        Public APIs Sources                           │
│  • PublicAPIs.io (25 pages)                         │
│  • Public APIs Dev (GitHub)                         │
└──────────────────┬──────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────┐
│        Scraper (/scrape endpoint)                   │
│  • Fetch raw API data                               │
│  • Deduplicate by URL                               │
│  • Enrich with runtime checks                       │
│  • Categorize by type                               │
│  • Save to /export/{timestamp}/                     │
└──────────────────┬──────────────────────────────────┘
                   │
         ┌─────────┴──────────┬──────────────┐
         ▼                    ▼              ▼
    uncategorized.json  categorized.json  categories.json
         │                    │              │
         └─────────────────────┬──────────────┘
                               ▼
         ┌─────────────────────────────────────┐
         │  API Retrieval & Discovery Layer    │
         │  • Search (/search)                 │
         │  • Filter (pricing, auth, cors...)  │
         │  • Recommend (/recommend)           │
         │  • Get APIs (/APIs.json)            │
         └─────────────────────────────────────┘
                               │
         ┌─────────────────────┴──────────────────┐
         │                                        │
         ▼                                        ▼
    ┌─────────────────┐              ┌──────────────────┐
    │  Mobile Apps    │              │  Web Clients     │
    │  (Flutter)      │              │  (React, Vue)    │
    └─────────────────┘              └──────────────────┘
```

### Data Flow for Submissions

```
User Submit API
      │
      ▼
/submit endpoint (validates)
      │
      ▼
Save to /submissions/pending/
      │
      ▼
Admin Review (/admin/submissions)
      │
   ┌──┴──┐
   ▼     ▼
Approve Reject
   │     │
   ▼     ▼
/approved/ /rejected/
```

---

## Setup & Installation

### Local Development

```bash
# Clone and install
git clone <repo>
cd public-apis-scrapper
npm install

# Set up environment
cp .env.example .env
# Edit .env with your tokens

# Start server
npm start
# Server runs on http://localhost:3000
```

### Environment File (.env)

```dotenv
AUTH_TOKEN=secret123
ADMIN_TOKEN=admin-secret-token
PORT=3000
```

### Production (Vercel)

```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel deploy --prod

# Set environment variables in Vercel dashboard:
# Project Settings > Environment Variables
# - AUTH_TOKEN (for /APIs.json, /search, /recommend, /submit)
# - ADMIN_TOKEN (for /admin/* endpoints)
```

---

## Environment Variables

| Variable | Required | Purpose |
|----------|----------|---------|
| `AUTH_TOKEN` | Yes | User authentication token for protected endpoints |
| `ADMIN_TOKEN` | Yes | Admin-only token for submission management |
| `PORT` | No | Server port (default: 3000) |

**Note**: On Vercel, `ADMIN_TOKEN` should be kept secret and not exposed in client code.

---

## API Endpoints

### 1. Server Info

**GET** `/`

- **Auth**: None
- **Description**: Get server info and all available endpoints
- **Response**: JSON with endpoints list, authentication methods, examples

```bash
curl http://localhost:3000
```

---

### 2. Health Check

**GET** `/health`

- **Auth**: None
- **Description**: Check if server is running
- **Response**: `{ status: "ok", uptime, timestamp }`

```bash
curl http://localhost:3000/health
```

---

### 3. Scrape APIs

**GET/POST** `/scrape`

- **Auth**: Required (`AUTH_TOKEN`)
- **Description**: Trigger full API scraping from all sources
- **Duration**: 2-5 minutes (depends on number of APIs)
- **Response**: Scraping results with file paths and statistics

```bash
# Trigger scraping
curl -X POST http://localhost:3000/scrape \
  -H "Authorization: Bearer secret123"

# Or via query param
curl -X GET "http://localhost:3000/scrape?token=secret123"
```

**Response Example**:

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
  "categories": ["Weather", "Social", "Finance", ...]
}
```

---

### 4. Get APIs

**GET** `/APIs.json`

- **Auth**: Required (`AUTH_TOKEN`)
- **Query Params**:
  - `file` (default: "categorized") - File type: uncategorized, categorized, categories
  - `folder` (optional) - Specific export folder timestamp
- **Description**: Get latest or specific API dataset
- **Response**: JSON array of APIs with enriched data

```bash
# Get latest categorized APIs
curl "http://localhost:3000/APIs.json?token=secret123"

# Get uncategorized raw data
curl "http://localhost:3000/APIs.json?token=secret123&file=uncategorized"

# Get categories list
curl "http://localhost:3000/APIs.json?token=secret123&file=categories"

# Get specific folder
curl "http://localhost:3000/APIs.json?token=secret123&folder=2025-12-08T15-30-45.123456"
```

**API Object Schema**:

```json
{
  "title": "Weather",
  "apis": [
    {
      "name": "OpenWeather",
      "description": "Real-time weather data",
      "category": "Weather",
      "auth": "API Key",
      "https": "true",
      "cors": "Yes",
      "link": "https://openweathermap.org",
      "apiType": "REST",
      "pricing": "Free",
      "rateLimit": "1000 requests/day",
      "documentation": "https://openweathermap.org/api",
      "isAlive": true,
      "responseTime": 245,
      "statusCode": 200,
      "lastChecked": "2025-12-08T15:30:45.123456Z"
    }
  ]
}
```

---

### 5. Search & Filter APIs

**GET** `/search`

- **Auth**: Required (`AUTH_TOKEN`)
- **Query Params**:
  - `q` - Search keyword (searches name, description, category)
  - `pricing` - Filter by pricing (free, freemium, paid, unknown)
  - `auth` - Filter by auth type (none, api-key, oauth, etc.)
  - `cors` - Filter by CORS (yes, no, unknown)
  - `https` - Filter by HTTPS (true/false)
  - `apiType` - Filter by type (REST, GraphQL, SOAP, RPC, Webhook)
  - `category` - Filter by category
  - `alive` - Filter by status (true/false)
  - `maxResponseTime` - Maximum response time in ms
  - `sortBy` - Sort field (name, responseTime, category)
  - `sortOrder` - Sort direction (asc, desc)
  - `page` - Page number (default: 1)
  - `limit` - Results per page (default: 20, max: 100)

```bash
# Search for weather APIs
curl "http://localhost:3000/search?q=weather&token=secret123"

# Get free, CORS-enabled APIs
curl "http://localhost:3000/search?pricing=free&cors=yes&token=secret123"

# Get fastest APIs (under 500ms response time)
curl "http://localhost:3000/search?maxResponseTime=500&sortBy=responseTime&sortOrder=asc&token=secret123"

# Get alive REST APIs with pagination
curl "http://localhost:3000/search?alive=true&apiType=REST&page=1&limit=20&token=secret123"

# Complex filter: free, no-auth, CORS-enabled APIs
curl "http://localhost:3000/search?pricing=free&auth=none&cors=yes&token=secret123"
```

**Response**:

```json
{
  "success": true,
  "query": "weather",
  "filters": {
    "pricing": "free",
    "cors": "yes"
  },
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 15,
    "totalPages": 1,
    "hasMore": false
  },
  "data": [
    { ...api object... }
  ]
}
```

---

### 6. API Recommendations

**GET** `/recommend`

- **Auth**: Required (`AUTH_TOKEN`)
- **Query Params**:
  - `type` - Recommendation type: `best`, `similar`, `usecase`
  - For `type=best`:
    - `criteria` - Best by: fastest, most-reliable, free, no-auth, cors-enabled, https-only
  - For `type=similar`:
    - `apiName` - API name to find similar ones
  - For `type=usecase`:
    - `useCase` - Use case description (weather, payment, maps, email, sms, storage, search)
  - `limit` - Max results (default: 10, max: 50)

```bash
# Get fastest responding APIs
curl "http://localhost:3000/recommend?type=best&criteria=fastest&token=secret123"

# Get most reliable APIs
curl "http://localhost:3000/recommend?type=best&criteria=most-reliable&token=secret123"

# Get free APIs only
curl "http://localhost:3000/recommend?type=best&criteria=free&token=secret123"

# Get APIs similar to GitHub
curl "http://localhost:3000/recommend?type=similar&apiName=GitHub&token=secret123"

# Get APIs for weather use case
curl "http://localhost:3000/recommend?type=usecase&useCase=weather&limit=10&token=secret123"

# Get payment APIs
curl "http://localhost:3000/recommend?type=usecase&useCase=payment&token=secret123"
```

**Supported Use Cases**:

- weather, climate
- social, twitter, facebook
- payment, stripe, paypal
- maps, location, geo
- mail, email, smtp
- sms, text, messaging
- storage, cloud, s3
- search, elasticsearch, database

---

### 7. Submit New API

**GET** `/submit/stats` (No Auth)

- **Description**: Get submission statistics
- **Response**: Counts of pending, approved, rejected submissions

```bash
curl http://localhost:3000/submit/stats
```

**POST** `/submit`

- **Auth**: Required (`AUTH_TOKEN`)
- **Body** (JSON):
  - `name` (required) - API name
  - `link` (required) - API URL
  - `description` (required) - Description (10+ characters)
  - `category` (required) - Category name
  - `auth` (optional) - Auth type
  - `https` (optional) - Boolean
  - `cors` (optional) - Yes/No/Unknown
  - `pricing` (optional) - Pricing model
  - `documentation` (optional) - Docs URL
  - `rateLimit` (optional) - Rate limit info
  - `submitterEmail` (optional) - Submitter email
  - `submitterName` (optional) - Submitter name
  - `notes` (optional) - Additional notes

```bash
curl -X POST http://localhost:3000/submit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer secret123" \
  -d '{
    "name": "My Weather API",
    "link": "https://api.myweather.com",
    "description": "A comprehensive weather API with forecasts and historical data",
    "category": "Weather",
    "auth": "API Key",
    "https": true,
    "cors": "Yes",
    "pricing": "Free",
    "documentation": "https://docs.myweather.com",
    "rateLimit": "1000 requests/hour",
    "submitterEmail": "dev@example.com",
    "submitterName": "John Doe",
    "notes": "Great API, very reliable!"
  }'
```

**Response**:

```json
{
  "success": true,
  "message": "API submission received successfully",
  "submissionId": "1733680123456-abc123def",
  "submission": {
    "id": "1733680123456-abc123def",
    "submittedAt": "2025-12-08T15:30:45.123Z",
    "status": "pending",
    "api": { ...submitted api data... }
  }
}
```

---

### 8. Admin: List Submissions

**GET** `/admin/submissions`

- **Auth**: Required (`ADMIN_TOKEN`)
- **Query Params**:
  - `status` - Filter: pending, approved, rejected, all (default: pending)

```bash
# List pending submissions
curl "http://localhost:3000/admin/submissions?status=pending&token=admin-secret-token"

# List all submissions
curl "http://localhost:3000/admin/submissions?status=all&token=admin-secret-token"

# List approved only
curl "http://localhost:3000/admin/submissions?status=approved&token=admin-secret-token"
```

---

### 9. Admin: Approve Submission

**POST** `/admin/submissions/approve`

- **Auth**: Required (`ADMIN_TOKEN`)
- **Body** (JSON):
  - `submissionId` (required) - Submission ID
  - `reviewedBy` (optional) - Admin name/email

```bash
curl -X POST http://localhost:3000/admin/submissions/approve \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer admin-secret-token" \
  -d '{
    "submissionId": "1733680123456-abc123def",
    "reviewedBy": "admin@example.com"
  }'
```

---

### 10. Admin: Reject Submission

**PUT** `/admin/submissions/reject`

- **Auth**: Required (`ADMIN_TOKEN`)
- **Body** (JSON):
  - `submissionId` (required) - Submission ID
  - `rejectionReason` (required) - Why it was rejected
  - `reviewedBy` (optional) - Admin name/email

```bash
curl -X PUT http://localhost:3000/admin/submissions/reject \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer admin-secret-token" \
  -d '{
    "submissionId": "1733680123456-abc123def",
    "rejectionReason": "API endpoint not responding",
    "reviewedBy": "admin@example.com"
  }'
```

---

### 11. Admin: Delete Submission

**DELETE** `/admin/submissions/delete`

- **Auth**: Required (`ADMIN_TOKEN`)
- **Body** (JSON):
  - `submissionId` (required) - Submission ID

```bash
curl -X DELETE http://localhost:3000/admin/submissions/delete \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer admin-secret-token" \
  -d '{
    "submissionId": "1733680123456-abc123def"
  }'
```

---

## Data Models

### API Object (Enriched)

```typescript
interface Api {
  name: string;                // API name
  description: string;         // Brief description
  category: string;            // Category (Weather, Finance, etc.)
  auth: string;               // Auth type (None, API Key, OAuth, etc.)
  https: string;              // "true" or "false"
  cors: string;               // "Yes", "No", or "Unknown"
  link: string;               // API endpoint URL
  apiType: string;            // REST, GraphQL, SOAP, RPC, Webhook
  pricing: string;            // Free, Freemium, Paid, Unknown
  rateLimit: string;          // Rate limit description
  documentation: string;      // Link to documentation
  isAlive: boolean;           // Whether API is responding
  responseTime: number;       // Response time in ms
  statusCode: number | null;  // HTTP status code
  lastChecked: string;        // ISO timestamp
}
```

### Categorized Response

```typescript
interface CategoryApis {
  title: string;  // Category name
  apis: Api[];    // Array of APIs in this category
}

type CategorizedApis = CategoryApis[];
```

### Submission Object

```typescript
interface Submission {
  id: string;                    // Unique submission ID
  submittedAt: string;           // ISO timestamp
  submitterEmail: string;        // Submitter email
  submitterName: string;         // Submitter name
  api: {
    name: string;
    link: string;
    description: string;
    category: string;
    auth: string;
    https: boolean;
    cors: string;
    pricing: string;
    documentation: string;
    rateLimit: string;
  };
  notes: string;                 // Additional notes
  status: "pending" | "approved" | "rejected";
  reviewedAt: string | null;     // When admin reviewed it
  reviewedBy: string | null;     // Who reviewed it
  rejectionReason: string | null; // Reason if rejected
}
```

---

## File Structure

```
public-apis-scrapper/
├── api/
│   ├── index.js           # Server info endpoint
│   ├── health.js          # Health check
│   ├── scrape.js          # Scraping logic & /scrape endpoint
│   ├── apis.js            # /APIs.json endpoint
│   ├── search.js          # /search endpoint
│   ├── recommend.js       # /recommend endpoint
│   ├── submit.js          # /submit endpoint
│   ├── admin.js           # /admin/* endpoints
│   └── auth.js            # Authentication utilities
├── export/
│   ├── 2025-12-08T15-30-45.123456/
│   │   ├── uncategorized.json  # Raw API data
│   │   ├── categorized.json    # Categorized APIs
│   │   └── categories.json     # Category list
│   └── 2025-12-08T14-20-10.654321/
│       └── ...
├── submissions/
│   ├── pending/
│   │   └── {id}.json     # Pending API submissions
│   ├── approved/
│   │   └── {id}.json     # Approved submissions
│   └── rejected/
│       └── {id}.json     # Rejected submissions
├── server.js             # Express server setup
├── package.json          # Dependencies
├── .env                  # Environment variables
├── vercel.json          # Vercel deployment config
└── README.md            # This file
```

---

## Deployment

### Local Testing

```bash
# Start server
npm start

# In another terminal, test endpoints
curl http://localhost:3000/health
curl "http://localhost:3000/APIs.json?token=secret123"
```

### Vercel Deployment

```bash
# One-time setup
vercel login
vercel link  # Link to your Vercel project

# Deploy
npm run deploy  # or: vercel deploy --prod

# Set env vars in Vercel dashboard
# Settings > Environment Variables:
# - AUTH_TOKEN=your-secret-token
# - ADMIN_TOKEN=admin-secret-token
```

**Production URL**: `https://public-apis-scrapper-xxxxx.vercel.app`

---

## Admin Operations

### Workflow

1. **Monitor**: Check stats and pending submissions

   ```bash
   curl http://localhost:3000/submit/stats
   curl "http://localhost:3000/admin/submissions?status=pending&token=admin-token"
   ```

2. **Review**: Check submission details
   - Look at API name, description, link, category
   - Verify it's a real, working API

3. **Approve**:

   ```bash
   curl -X POST http://localhost:3000/admin/submissions/approve \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer admin-token" \
     -d '{"submissionId": "id-here"}'
   ```

4. **Reject** (if invalid):

   ```bash
   curl -X PUT http://localhost:3000/admin/submissions/reject \
     -H "Content-Type: application/json" \
     -H "Authorization: Bearer admin-token" \
     -d '{
       "submissionId": "id-here",
       "rejectionReason": "API not responding"
     }'
   ```

---

## Examples & Curl Commands

### Complete Workflow Example

```bash
# 1. Start local server
npm start

# 2. Check server is running
curl http://localhost:3000

# 3. Trigger scraping (takes 2-5 minutes)
curl -X POST "http://localhost:3000/scrape?token=secret123"

# 4. Search for weather APIs
curl "http://localhost:3000/search?q=weather&token=secret123"

# 5. Get fastest APIs
curl "http://localhost:3000/recommend?type=best&criteria=fastest&token=secret123"

# 6. Submit a new API
curl -X POST http://localhost:3000/submit \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer secret123" \
  -d '{
    "name": "My API",
    "link": "https://api.example.com",
    "description": "A useful API for doing things",
    "category": "Utilities"
  }'

# 7. As admin, view pending submissions
curl "http://localhost:3000/admin/submissions?status=pending&token=admin-token"

# 8. Approve a submission
curl -X POST http://localhost:3000/admin/submissions/approve \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer admin-token" \
  -d '{"submissionId": "submission-id"}'
```

### Advanced Search Combinations

```bash
# Get free REST APIs with CORS support and fast response times
curl "http://localhost:3000/search?pricing=free&apiType=REST&cors=yes&maxResponseTime=500&token=secret123"

# Get all alive, HTTPS-only APIs in specific categories
curl "http://localhost:3000/search?alive=true&https=true&category=Finance&token=secret123"

# Get payment APIs sorted by response time
curl "http://localhost:3000/recommend?type=usecase&useCase=payment&limit=20&token=secret123"

# Search with pagination
curl "http://localhost:3000/search?q=data&page=2&limit=50&token=secret123"
```

---

## Error Handling

All endpoints return error responses in this format:

```json
{
  "error": "Error type",
  "message": "Detailed error message"
}
```

### Common Status Codes

- `200` - OK
- `201` - Created (submission accepted)
- `400` - Bad request (invalid params)
- `401` - Unauthorized (missing token)
- `403` - Forbidden (invalid token)
- `404` - Not found (API/submission not found)
- `500` - Server error

---

## Performance & Best Practices

1. **Caching**: Store recently fetched APIs in memory or use CDN for `/APIs.json`
2. **Rate Limiting**: Implement per-IP rate limits on `/search` and `/recommend`
3. **Batch Operations**: Use pagination on large result sets (limit: 20-100)
4. **Scraping Frequency**: Run `/scrape` daily via cron to keep data fresh
5. **Auth**: Keep tokens secret, rotate `ADMIN_TOKEN` periodically
6. **Monitoring**: Log scrape durations, failures, and submission volumes

---

## Troubleshooting

**Scraping fails**:

- Check network connectivity
- Verify source URLs are accessible (PublicAPIs.io, GitHub)
- Increase timeout if running on slow connection

**Auth errors**:

- Ensure `AUTH_TOKEN` and `ADMIN_TOKEN` are set in `.env` (local) or Vercel dashboard (prod)
- Use correct token in Authorization header or query param

**Search returns empty**:

- Ensure `/scrape` has been run at least once
- Check `export/` folder exists and contains data

**Submissions not saving**:

- Ensure `submissions/pending/` folder has write permissions
- Check disk space availability

---

## Future Enhancements

- [ ] Response caching (Redis/Vercel KV)
- [ ] Rate limiting middleware
- [ ] Scheduled scraping (Vercel Cron)
- [ ] Detailed API analytics/metrics
- [ ] User favorites/bookmarks
- [ ] API comparison tool
- [ ] Notification system for changes
- [ ] GraphQL API layer
- [ ] WebSocket for real-time updates
- [ ] Database migration (Prisma + PostgreSQL)

---

## Support & Contributing

For issues or feature requests, please create a GitHub issue or contact the maintainers.

Last updated: December 8, 2025
