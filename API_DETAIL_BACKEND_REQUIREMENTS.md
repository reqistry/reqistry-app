  # API Detail Production Backend Contract

  The mobile client currently uses `MockApiDetailSource` for data that the server
  does not expose. Mock-derived UI is labeled `Mock preview` or `Not verified`.
  Replace that source when the endpoints below are available.

  ## 1. API detail

  ```http
  GET /v1/apis/{slug}
  ```

  Requirements:

  - Resolve an exact, unique slug. Never return a fuzzy search result.
  - Return `404` when the slug does not exist.
  - Return nullable values for facts that are unknown. Do not convert unknown to
    `false`.
  - Include separately typed links. `baseUrl`, `homepageUrl`, and
    `documentationUrl` are not interchangeable.
  - Return the most recent stored backend health observation. This request must
    not synchronously ping the provider.
  - Include verification source and timestamp for each dynamic fact.
  - Support `ETag`/`If-None-Match` or `Last-Modified` so the client can refresh a
    cached record cheaply.

  Response:

  ```json
  {
    "data": {
      "id": "api_123",
      "slug": "open-meteo",
      "name": "Open-Meteo",
      "shortDescription": "Weather forecasts and historical climate data",
      "fullDescription": null,
      "imageUrl": null,
      "category": {
        "id": "weather",
        "name": "Weather",
        "slug": "weather"
      },
      "access": {
        "authType": "NONE",
        "pricingType": "FREE",
        "rateLimit": null,
        "creditCardRequired": false,
        "commercialUseAllowed": null
      },
      "links": {
        "baseUrl": "https://api.open-meteo.com/v1",
        "homepageUrl": "https://open-meteo.com",
        "documentationUrl": "https://open-meteo.com/en/docs",
        "openApiUrl": null,
        "statusPageUrl": null,
        "termsUrl": null
      },
      "capabilities": {
        "https": true,
        "cors": "SUPPORTED",
        "protocol": "REST",
        "responseFormats": ["JSON"],
        "sdkLanguages": [],
        "openApiAvailable": null
      },
      "health": {
        "status": "OPERATIONAL",
        "statusCode": 200,
        "responseTimeMs": 184,
        "message": null,
        "checkMethod": "GET",
        "checkedAt": "2026-08-02T17:00:00Z",
        "uptime24h": null,
        "uptime7d": null,
        "uptime30d": 99.82,
        "observationCount": 712
      },
      "verification": {
        "health": {
          "source": "AUTOMATED_CHECK",
          "verifiedAt": "2026-08-02T17:00:00Z"
        },
        "pricing": {
          "source": "COMMUNITY_REPORT",
          "verifiedAt": "2026-07-15T10:00:00Z"
        },
        "authentication": {
          "source": "PROVIDER",
          "verifiedAt": "2026-07-29T10:00:00Z"
        },
        "documentation": {
          "source": "CORE_API_REVIEW",
          "verifiedAt": "2026-07-29T10:00:00Z"
        },
        "cors": {
          "source": "UNKNOWN",
          "verifiedAt": null
        }
      },
      "warnings": [
        {
          "code": "NO_OFFICIAL_FLUTTER_SDK",
          "message": "No official Flutter SDK found",
          "severity": "INFO",
          "verifiedAt": "2026-08-01T10:00:00Z"
        }
      ],
      "updatedAt": "2026-08-02T17:00:00Z"
    }
  }
  ```

  Recommended enums:

  - `authType`: `NONE`, `API_KEY`, `OAUTH2`, `BASIC`, `UNKNOWN`
  - `pricingType`: `FREE`, `FREEMIUM`, `PAID`, `UNKNOWN`
  - `cors`: `SUPPORTED`, `UNSUPPORTED`, `UNKNOWN`
  - `health.status`: `OPERATIONAL`, `AUTHENTICATION_REQUIRED`, `RATE_LIMITED`,
    `DEGRADED`, `UNAVAILABLE`, `UNKNOWN`
  - verification source: `PROVIDER`, `AUTOMATED_CHECK`, `CORE_API_REVIEW`,
    `COMMUNITY_REPORT`, `IMPORTED`, `UNKNOWN`

  ## 2. Manual health refresh

  ```http
  POST /v1/apis/{id}/health-check
  ```

  Behavior:

  - Return the stored result with `200` when it is inside the server cooldown.
  - Deduplicate active jobs for the same API.
  - Queue a backend-worker check when stale and return `202`.
  - Rate-limit repeated requests per user and API.
  - The worker should use the configured endpoint and method, not assume `HEAD`.
  - Treat `401`, `403`, `405`, and `429` as explicit reachable states rather than
    generic downtime.

  Cached response:

  ```json
  {
    "data": {
      "state": "CACHED",
      "health": {
        "status": "OPERATIONAL",
        "statusCode": 200,
        "responseTimeMs": 184,
        "message": null,
        "checkMethod": "GET",
        "checkedAt": "2026-08-02T17:00:00Z",
        "observationCount": 712
      },
      "cooldownEndsAt": "2026-08-02T17:01:00Z"
    }
  }
  ```

  Queued response:

  ```json
  {
    "data": {
      "state": "QUEUED",
      "checkId": "check_456",
      "pollUrl": "/v1/apis/api_123/health-checks/check_456",
      "pollAfterMs": 1500,
      "previousHealth": {}
    }
  }
  ```

  The polling endpoint should return `QUEUED`, `RUNNING`, `COMPLETED`, or
  `FAILED`, plus the previous result until a new result is complete.

  ## 3. Similar alternatives

  ```http
  GET /v1/apis/{id}/alternatives?limit=3
  ```

  Return two or three catalog APIs with stable IDs and slugs. Each result needs
  enough data to render, open, and bookmark without another list request.

  ```json
  {
    "data": [
      {
        "id": "api_456",
        "slug": "weather-api",
        "name": "WeatherAPI",
        "shortDescription": "Forecasts with historical weather data",
        "pricingType": "FREEMIUM",
        "authType": "API_KEY",
        "baseUrl": "https://api.weatherapi.com/v1"
      }
    ]
  }
  ```

  ## 4. Report incorrect information

  ```http
  POST /v1/apis/{id}/reports
  Authorization: Bearer <accessToken>
  ```

  Request:

  ```json
  {
    "reason": "PRICING_INCORRECT",
    "note": "The provider now requires a paid plan."
  }
  ```

  Return `201` with a stable report ID and status. Deduplicate abusive repeated
  reports and retain the API, user/device, timestamps, and review history.

  ```json
  {
    "data": {
      "id": "report_789",
      "status": "PENDING",
      "createdAt": "2026-08-02T17:05:00Z"
    }
  }
  ```

  ## 5. Project membership by API ID

  The current server accepts a mutable URL at
  `POST /v1/folders/{folderId}/api-links`. Add the stable relationship endpoint:

  ```http
  POST /v1/projects/{projectId}/apis
  Authorization: Bearer <accessToken>

  { "apiId": "api_123" }
  ```

  Return the updated membership or `409` when it already exists. Also expose API
  IDs in project detail responses so the mobile client can migrate away from URL
  matching.

  ## Client replacement map

  | Current client behavior                  | Production replacement                  |
  | ---------------------------------------- | --------------------------------------- |
  | Exact `/search` lookup for a direct slug | `GET /v1/apis/{slug}`                   |
  | Metadata enrichment through `/metadata`  | Detail response fields and verification |
  | Recommended-list heuristic marked mock   | Alternatives endpoint                   |
  | Refreshing the stored search snapshot    | Health-check endpoint and polling       |
  | Reports saved in local Hive storage      | Reports endpoint                        |
  | Project membership by URL                | Project API-ID relationship endpoint    |

  The existing `/track`, bookmark, folder, search, and metadata contracts remain
  usable during migration.
