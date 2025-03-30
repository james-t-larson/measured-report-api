
# Measured Gazette REST API Specification

## Overview

This API provides access to the articles and categories. It uses RESTful principles and returns JSON responses.

## Base URL

All endpoints are prefixed with  `/api/v1/`.

## Endpoints
---------------------
### Get Article by ID

Retrieves a single article by its unique identifier.

-   **URL**:  `/articles/{id}`
-   **Method**: GET
-   **URL Parameters**:
    -   `id`: The unique identifier of the article

**Example Request:**

```
GET /articles/123
```

**Example Response:**

Status: 200 OK
```

{
  "message":"success",
  "data": {
    "id":123,
    "title":"Sample Article",
    "summary":"This is a summary of the article",
    "created_at":"2025-03-26T20:14:00Z",
    "updated_at":"2025-03-26T20:14:00Z",
    "content":"Full content of the article...",
    "sources":"Source information",
    "external_article_id":456,
    "category_id":789,
    "image":"[https://example.com/image.jpg](https://example.com/image.jpg)",
    "sentiment_score":0.75,
    "event_id":null,
    "location":"Port Coquitlam, BC, Canada",
    "relevance":0.9
  }
}
```
---------------------
### Get All Categories

Retrieves all available categories.

-   **URL**:  `/categories`
    
-   **Method**: GET
    

**Example Request:**

```
GET /categories
```

**Example Response:**

Status: 200 OK
```
{
   "message":"success",
   "data":[
      {
         "id":1,
         "name":"Technology"",
         "slug":"technology""
      },
      {
         "id":2,
         "name":"Science"",
         "slug":"science""
      }
   ]
}
```

## Get Articles by Category

Retrieves all articles belonging to a specific category.

-   **URL**:  `/categories/{category_id}/articles`
-   **Method**: GET
-   **URL Parameters**:
    -   `category_id`: The unique identifier of the category
        

**Example Request:**
```
GET /categories/1/articles
```
**Example Response:**

Status: 200 OK
```
{
   "message":"success",
   "data":[
      {
         "id":123,
         "title":"Latest Tech Trends",
         ...rest of params outlined below
      },
      {
         "id":124,
         "title":"AI Advancements",
         ...rest of params outlined below
      }
   ]
}
```
## Error Handling

The API uses standard HTTP status codes to indicate the success or failure of requests. Common error codes include:

-   400 Bad Request: Invalid input or parameters
    
-   401 Unauthorized: Authentication failure
    
-   404 Not Found: Requested resource/data base recored doesn't exist
    
-   500 Internal Server Error: Unexpected server error
    
Error responses will include a JSON body with more details about the error.

## Data Models

## Article

-   id: number
-   title: string
-   summary: string
-   content: string
-   sources: string
-   category_id: number
-   image: string (URL)
-   sentiment_score: number
-   created_at: string (ISO 8601 date)
-   updated_at: string (ISO 8601 date)
    

## Category

-   id: number
-   slug: string
-   name: string
    

## Authentication

For the static rest api, there will be IP based authentication. This is to ensure security and development are easy. 
For the staging and production environments, I will be implementing domain based auth to ensure that only the frontend can send requests to the API


