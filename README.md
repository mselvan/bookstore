# 📚 Fake Bookstore API

A simple fake REST API for a bookstore built with FastAPI.

## 🚀 Getting Started

### Requirements
- Python 3.8+
- pip

### Install dependencies
```bash
pip install fastapi uvicorn
```

### Run the API
```bash
uvicorn fake-api:app --reload
```

## 📘 API Endpoints

### Books

- `GET /books` - List all books  
- `GET /books/{id}` - Get a book by ID  
- `POST /books` - Add a new book  
- `PUT /books/{id}` - Update a book  
- `DELETE /books/{id}` - Delete a book  

## 📎 Example Book Object
```json
{
  "id": 1,
  "title": "Clean Code",
  "author": "Robert C. Martin",
  "price": 29.99
}
```

## 🛠 Tech Stack

- FastAPI
- Uvicorn

## 📝 License

MIT
