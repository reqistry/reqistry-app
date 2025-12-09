# AI Agent Prompt: Search API Integration

## Context
You are integrating a powerful search and filtering system for a Public APIs discovery platform. The server provides a comprehensive `/search` endpoint that supports full-text search, multi-criterion filtering, sorting, and pagination. This prompt contains complete specifications for accurate implementation.

---

## Endpoint Details

**URL:** `GET /search`  
**Authentication:** Required (Bearer token in `Authorization` header OR `token` query parameter)  
**Base URL:** `https://public-apis-scrapper-xxxxx.vercel.app`

---

## Complete Query Parameters Reference

### 1. Text Search
- **Parameter:** `q` (query)
- **Type:** String
- **Description:** Full-text search across API name, description, and category
- **Case-sensitive:** No (case-insensitive)
- **Example:** `?q=weather` searches for "weather" in name, description, or category
- **Default:** Empty (returns all APIs if no filters applied)

### 2. Filtering Options

#### 2.1 Pricing Filter
- **Parameter:** `pricing`
- **Type:** String or Array of Strings
- **Possible Values:** `free`, `freemium`, `paid`, `Free`, `Freemium`, `Paid` (case-insensitive)
- **Multiple Values:** Supported (comma-separated or multiple parameters)
- **Matching:** Partial match (e.g., "free" matches "Free", "freemium")
- **Examples:**
  - Single: `?pricing=free`
  - Multiple: `?pricing=free&pricing=freemium` OR `?pricing=free,freemium`

#### 2.2 Authentication Filter
- **Parameter:** `auth`
- **Type:** String or Array of Strings
- **Possible Values:** `none`, `apiKey`, `OAuth`, `API Key`, `OAuth2.0`, `Bearer`, etc.
- **Multiple Values:** Supported
- **Matching:** Partial match (case-insensitive)
- **Examples:**
  - Single: `?auth=none` (no authentication required)
  - Multiple: `?auth=apiKey&auth=OAuth`

#### 2.3 CORS Support Filter
- **Parameter:** `cors`
- **Type:** String
- **Possible Values:** `yes`, `no`, `unknown` (case-insensitive)
- **Matching:** Exact match
- **Example:** `?cors=yes` (only APIs with CORS enabled)

#### 2.4 HTTPS Support Filter
- **Parameter:** `https`
- **Type:** String (boolean)
- **Possible Values:** `true`, `false`
- **Matching:** Exact match
- **Example:** `?https=true` (only HTTPS-enabled APIs)

#### 2.5 API Type Filter
- **Parameter:** `apiType`
- **Type:** String or Array of Strings
- **Possible Values:** `REST`, `GraphQL`, `SOAP`, `WebSocket`, `gRPC`, etc.
- **Multiple Values:** Supported
- **Matching:** Exact match (case-insensitive)
- **Examples:**
  - Single: `?apiType=REST`
  - Multiple: `?apiType=REST&apiType=GraphQL`

#### 2.6 Category Filter
- **Parameter:** `category`
- **Type:** String or Array of Strings
- **Possible Values:** Any category (e.g., `Weather`, `Finance`, `Social`, `Maps`, `Email`, `Sports`, etc.)
- **Multiple Values:** Supported
- **Matching:** Exact match (case-insensitive)
- **Examples:**
  - Single: `?category=Weather`
  - Multiple: `?category=Weather&category=Finance`

#### 2.7 Alive Status Filter
- **Parameter:** `alive`
- **Type:** String (boolean)
- **Possible Values:** `true`, `false`
- **Description:** Filter by whether API is currently responding (based on health checks)
- **Matching:** Exact match
- **Example:** `?alive=true` (only working APIs)

#### 2.8 Max Response Time Filter
- **Parameter:** `maxResponseTime`
- **Type:** Integer (milliseconds)
- **Description:** Filter APIs with response time less than or equal to specified value
- **Note:** Excludes APIs with responseTime = -1 (unavailable/error)
- **Example:** `?maxResponseTime=500` (APIs responding in 500ms or less)

### 3. Sorting Options

#### 3.1 Sort By
- **Parameter:** `sortBy`
- **Type:** String
- **Possible Values:**
  - `name` - Sort by API name (alphabetically)
  - `responseTime` - Sort by response time (fastest first with asc)
  - `category` - Sort by category name (alphabetically)
- **Default:** `name`
- **Example:** `?sortBy=responseTime`

#### 3.2 Sort Order
- **Parameter:** `sortOrder`
- **Type:** String
- **Possible Values:**
  - `asc` - Ascending order
  - `desc` - Descending order
- **Default:** `asc`
- **Example:** `?sortOrder=desc`
- **Combined Example:** `?sortBy=responseTime&sortOrder=asc` (fastest APIs first)

### 4. Pagination

#### 4.1 Page Number
- **Parameter:** `page`
- **Type:** Integer
- **Minimum:** 1
- **Default:** 1
- **Example:** `?page=2`

#### 4.2 Results Limit
- **Parameter:** `limit`
- **Type:** Integer
- **Minimum:** 1
- **Maximum:** 100 (enforced server-side)
- **Default:** 20
- **Example:** `?limit=50`

---

## Response Structure

### Success Response (200 OK)
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
    // ... more API objects
  ]
}
```

### Error Responses

#### 401 Unauthorized
```json
{
  "error": "Authentication required",
  "message": "Please provide a token in Authorization header or query parameter"
}
```

#### 404 Not Found
```json
{
  "error": "No API data found",
  "message": "Please run the scraper first to generate API data"
}
```

#### 500 Server Error
```json
{
  "error": "Search failed",
  "message": "Error details here"
}
```

---

## API Data Schema

Each API object in the `data` array contains:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `name` | String | API name | `"OpenWeather API"` |
| `description` | String | API description | `"Weather forecasts in JSON"` |
| `auth` | String | Authentication type | `"apiKey"`, `"OAuth"`, `"none"` |
| `https` | String | HTTPS support | `"true"`, `"false"` |
| `cors` | String | CORS support | `"yes"`, `"no"`, `"unknown"` |
| `link` | String | API base URL | `"https://api.example.com"` |
| `category` | String | API category | `"Weather"`, `"Finance"`, `"Maps"` |
| `apiType` | String | API type | `"REST"`, `"GraphQL"`, `"SOAP"` |
| `pricing` | String | Pricing model | `"Free"`, `"Freemium"`, `"Paid"` |
| `rateLimit` | String | Rate limiting info | `"60 calls/minute"`, `"Unlimited"` |
| `documentation` | String | Docs URL | `"https://docs.example.com"` |
| `isAlive` | Boolean | API availability | `true`, `false` |
| `responseTime` | Integer | Response time (ms) | `234`, `-1` (error) |
| `statusCode` | Integer/null | HTTP status code | `200`, `404`, `null` |
| `lastChecked` | String (ISO) | Last health check | `"2025-12-08T10:30:00.000Z"` |

---

## Common Use Cases & Examples

### 1. Find Free Weather APIs
```
GET /search?category=Weather&pricing=free&alive=true&token=YOUR_TOKEN
```

### 2. Fast REST APIs with No Authentication
```
GET /search?apiType=REST&auth=none&maxResponseTime=300&sortBy=responseTime&sortOrder=asc&token=YOUR_TOKEN
```

### 3. HTTPS + CORS Enabled APIs for Frontend
```
GET /search?https=true&cors=yes&alive=true&limit=50&token=YOUR_TOKEN
```

### 4. Search "payment" in Multiple Categories
```
GET /search?q=payment&category=Finance&category=Payment&pricing=free&pricing=freemium&token=YOUR_TOKEN
```

### 5. Paginated Results (Page 3, 25 per page)
```
GET /search?page=3&limit=25&sortBy=name&token=YOUR_TOKEN
```

### 6. Find Similar APIs to a Use Case
```
GET /search?q=social%20media&apiType=REST&pricing=free&sortBy=responseTime&token=YOUR_TOKEN
```

### 7. Get Only Working APIs with Fast Response
```
GET /search?alive=true&maxResponseTime=500&sortBy=responseTime&sortOrder=asc&token=YOUR_TOKEN
```

---

## Implementation Guidelines for AI Agent

### 1. Authentication
**Always include authentication in one of two ways:**
- **Header:** `Authorization: Bearer YOUR_TOKEN`
- **Query:** `?token=YOUR_TOKEN` (append to URL)

Example:
```javascript
// Using header
fetch('https://api.example.com/search?q=weather', {
  headers: { 'Authorization': 'Bearer YOUR_TOKEN' }
})

// Using query parameter
fetch('https://api.example.com/search?q=weather&token=YOUR_TOKEN')
```

### 2. Multiple Filter Values
When applying multiple values for the same filter, use one of these approaches:
```
// Approach 1: Multiple parameters
?pricing=free&pricing=freemium

// Approach 2: Comma-separated (if your implementation supports it)
?pricing=free,freemium
```

### 3. Combining Search with Filters
Search query (`q`) and filters work together:
```
?q=weather&pricing=free&alive=true&https=true
```
This finds APIs containing "weather" that are free, alive, and support HTTPS.

### 4. Pagination Logic
```javascript
const page = 1;
const limit = 20;

// Check if more pages exist
if (response.pagination.hasMore) {
  // Load next page
  const nextPage = response.pagination.page + 1;
  // Make request with ?page=nextPage
}

// Calculate total pages
const totalPages = response.pagination.totalPages;
const currentPage = response.pagination.page;
```

### 5. Sorting Best Practices
- **Default:** Results sorted by name (A-Z)
- **Fastest APIs:** `?sortBy=responseTime&sortOrder=asc`
- **Slowest APIs:** `?sortBy=responseTime&sortOrder=desc`
- **Alphabetical reverse:** `?sortBy=name&sortOrder=desc`
- **By category:** `?sortBy=category&sortOrder=asc`

### 6. Response Time Filtering
- `responseTime = -1` means API didn't respond or error occurred
- `maxResponseTime` filter automatically excludes `-1` values
- Example: `?maxResponseTime=1000` returns only APIs responding within 1 second

### 7. Empty Results Handling
```javascript
if (response.data.length === 0) {
  // No results found - adjust filters or search query
  // Check response.query and response.filters to see what was applied
}
```

### 8. Error Handling
```javascript
// 401 - Invalid or missing token
// 404 - No API data (scraper hasn't run yet)
// 500 - Server error

if (response.status === 401) {
  // Check authentication token
}
if (response.status === 404) {
  // API data not available - inform user
}
```

---

## Search Behavior Details

### Text Search (`q` parameter)
- **Fields searched:** `name`, `description`, `category`
- **Matching:** Partial, case-insensitive
- **Example:** `q=weather` matches:
  - Name: "OpenWeather API"
  - Description: "Get weather forecasts..."
  - Category: "Weather"

### Filter Application Order
1. Text search (`q`) applied first
2. All filters applied simultaneously (AND logic)
3. Sorting applied to filtered results
4. Pagination applied last

### Multiple Values Logic
When using multiple values for the same filter:
- **OR logic within same filter:** `?pricing=free&pricing=paid` returns APIs that are free OR paid
- **AND logic across different filters:** `?pricing=free&alive=true` returns APIs that are free AND alive

---

## Performance Considerations

1. **Limit parameter:** Max 100 results per page (server enforced)
2. **Response size:** Paginate large result sets (default 20 per page)
3. **Caching:** Consider caching responses for 5-10 minutes
4. **Alive filter:** Use `alive=true` to get only working APIs (reduces unnecessary API calls)
5. **Response time:** Use `maxResponseTime` to filter out slow APIs

---

## Example Integration Code

### Basic Search Request
```javascript
async function searchApis(query, filters = {}) {
  const params = new URLSearchParams({
    ...(query && { q: query }),
    ...filters,
    token: 'YOUR_TOKEN'
  });

  const response = await fetch(`https://api.example.com/search?${params}`);
  const data = await response.json();
  
  return data;
}

// Usage
const results = await searchApis('weather', {
  pricing: 'free',
  alive: 'true',
  limit: 30
});
```

### Advanced Multi-Filter Search
```javascript
async function advancedSearch(options) {
  const {
    query = '',
    pricing = [],
    auth = [],
    cors,
    https,
    apiType = [],
    category = [],
    alive,
    maxResponseTime,
    sortBy = 'name',
    sortOrder = 'asc',
    page = 1,
    limit = 20
  } = options;

  const params = new URLSearchParams();
  
  if (query) params.append('q', query);
  pricing.forEach(p => params.append('pricing', p));
  auth.forEach(a => params.append('auth', a));
  if (cors) params.append('cors', cors);
  if (https !== undefined) params.append('https', https);
  apiType.forEach(t => params.append('apiType', t));
  category.forEach(c => params.append('category', c));
  if (alive !== undefined) params.append('alive', alive);
  if (maxResponseTime) params.append('maxResponseTime', maxResponseTime);
  params.append('sortBy', sortBy);
  params.append('sortOrder', sortOrder);
  params.append('page', page);
  params.append('limit', limit);
  params.append('token', 'YOUR_TOKEN');

  const response = await fetch(`https://api.example.com/search?${params}`, {
    headers: { 'Authorization': 'Bearer YOUR_TOKEN' }
  });

  return await response.json();
}

// Usage
const results = await advancedSearch({
  query: 'payment',
  pricing: ['free', 'freemium'],
  category: ['Finance', 'Payment'],
  alive: true,
  https: true,
  cors: 'yes',
  maxResponseTime: 500,
  sortBy: 'responseTime',
  sortOrder: 'asc',
  limit: 50
});
```

### Pagination Implementation
```javascript
async function getAllPages(searchOptions, maxPages = 10) {
  const allResults = [];
  let currentPage = 1;
  let hasMore = true;

  while (hasMore && currentPage <= maxPages) {
    const response = await searchApis('', {
      ...searchOptions,
      page: currentPage,
      limit: 50
    });

    allResults.push(...response.data);
    hasMore = response.pagination.hasMore;
    currentPage++;
  }

  return allResults;
}
```

---

## Testing Checklist

Before deploying your search integration, test:

- [ ] Text search with various queries
- [ ] Single filter (each type)
- [ ] Multiple filters combined
- [ ] Multiple values for same filter
- [ ] Sorting (all 3 fields, both directions)
- [ ] Pagination (first page, middle page, last page)
- [ ] Empty results handling
- [ ] Authentication (both methods)
- [ ] Error responses (401, 404, 500)
- [ ] Edge cases (limit=100, page beyond totalPages)

---

## Quick Reference Card

```
SEARCH ENDPOINT: GET /search

AUTHENTICATION:
  Header: Authorization: Bearer TOKEN
  OR Query: ?token=TOKEN

TEXT SEARCH:
  ?q=weather

FILTERS:
  ?pricing=free                 (free, freemium, paid)
  ?auth=none                    (none, apiKey, OAuth)
  ?cors=yes                     (yes, no, unknown)
  ?https=true                   (true, false)
  ?apiType=REST                 (REST, GraphQL, SOAP, WebSocket)
  ?category=Weather             (any category name)
  ?alive=true                   (true, false)
  ?maxResponseTime=500          (milliseconds)

SORTING:
  ?sortBy=name                  (name, responseTime, category)
  ?sortOrder=asc                (asc, desc)

PAGINATION:
  ?page=1                       (default: 1)
  ?limit=20                     (default: 20, max: 100)

COMBINE:
  ?q=weather&pricing=free&alive=true&sortBy=responseTime&page=1&limit=30&token=TOKEN
```

---

**Last Updated:** December 8, 2025  
**API Version:** 1.0  
**Support:** See API_DOCUMENTATION.md for full server documentation
