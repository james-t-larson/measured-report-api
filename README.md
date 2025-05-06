
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
    "sources": https:original-source-link,
    "category_id": 1,
    "image":"[https://example.com/image.jpg](https://example.com/image.jpg)",
    "sentiment_score":0.75,
    "location":"Port Coquitlam, BC, Canada",
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
        "id": 1,
        "slug": "politics",
        "name": "Politics",
        "position": 1,
        "created_at": "2025-04-27T01:22:10.736Z",
        "updated_at": "2025-04-27T01:22:10.736Z"
      },
      {
        "id": 2,
        "slug": "world",
        "name": "World",
        "position": 2,
        "created_at": "2025-04-27T01:22:10.753Z",
        "updated_at": "2025-04-27T01:22:10.753Z"
      },
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
      "id": 1289,
      "title": "Analysis of Spending ...",
      "summary": "This article examines the impact...",
      "content": "Recent adjustments in federal spending have had implications for communities nationwide...",
      "sources": "https://www.npr.org/2025/05/05/1249236665/trumps-spending-cuts-are-hitting-trump-voters",
      "category_id": 1,
      "image": null,
      "sentiment_score": 1.4375,
      "created_at": "2025-05-05T23:38:48.667Z",
      "updated_at": "2025-05-05T23:38:48.667Z",
      "feed_entry_id": 1302
    },
    {
      "id": 1274,
      "title": "Former Palantir Employees Critique...",
      "summary": "Thirteen former...",
      "content": "Thirteen former employees from Palantir Technologies have expressed...",
      "sources": "https://www.npr.org/2025/05/05/nx-s1-5387514/palantir-workers-letter-trump",
      "category_id": 1,
      "image": null,
      "sentiment_score": -0.7397999999999998,
      "created_at": "2025-05-05T22:08:56.838Z",
      "updated_at": "2025-05-05T22:08:56.838Z",
      "feed_entry_id": 1287
    },
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


