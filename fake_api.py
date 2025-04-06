from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError
from pydantic import BaseModel, validator
from typing import List
import uvicorn

app = FastAPI()

# --- In-memory database ---
books = []
next_id = 0

# --- Custom exception ---
class BookValidationError(Exception):
    def __init__(self, message: str):
        self.message = message

# --- Book model ---
class Book(BaseModel):
    id: int = None
    author: str
    title: str

    @validator("author")
    def validate_author(cls, v):
        if v is None or not v.strip():
            raise BookValidationError('Field "author" cannot be empty')
        return v

    @validator("title")
    def validate_title(cls, v):
        if v is None or not v.strip():
            raise BookValidationError('Field "title" cannot be empty')
        return v

# --- Exception handlers ---
@app.exception_handler(BookValidationError)
async def book_validation_error_handler(request: Request, exc: BookValidationError):
    return JSONResponse(status_code=400, content={"error": exc.message})

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    error = exc.errors()[0]
    loc = error.get("loc", [])
    field = loc[-1] if loc else "field"
    if error["type"] == "missing":
        msg = f'Field "{field}" is required'
    else:
        msg = error.get("msg", "Invalid input")
    return JSONResponse(status_code=400, content={"error": msg})


@app.exception_handler(HTTPException)
async def custom_http_exception_handler(request: Request, exc: HTTPException):
    return JSONResponse(status_code=exc.status_code, content={"error": exc.detail})

# --- Endpoints ---
@app.get("/api/books/", response_model=List[Book])
def list_books():
    return books

@app.get("/api/books/{book_id}", response_model=Book)
def get_book(book_id: int):
    for book in books:
        if book["id"] == book_id:
            return book
    raise HTTPException(status_code=404, detail="Book not found")

@app.put("/api/books/", response_model=Book)
def add_book(new_book: Book):
    global next_id

    if new_book.id is not None:
        raise HTTPException(status_code=400, detail='Field "id" is read-only')

    for book in books:
        if book["author"] == new_book.author and book["title"] == new_book.title:
            raise HTTPException(status_code=400, detail="Another book with similar title and author already exists")

    book_dict = new_book.dict()
    book_dict["id"] = next_id
    next_id += 1
    books.append(book_dict)
    return book_dict

@app.put("/api/books/{book_id}", response_model=Book)
def update_book(book_id: int, updated_book: Book):
    global books
    for idx, book in enumerate(books):
        if book["id"] == book_id:
            if updated_book.id is not None and updated_book.id != book_id:
                raise HTTPException(status_code=400, detail='Field "id" is read-only')

            updated = updated_book.dict()
            updated["id"] = book_id
            books[idx] = updated
            return updated
    raise HTTPException(status_code=404, detail="Book not found")

@app.delete("/api/books/{book_id}", status_code=204)
def delete_book(book_id: int):
    global books
    for book in books:
        if book["id"] == book_id:
            books = [b for b in books if b["id"] != book_id]
            return
    raise HTTPException(status_code=404, detail="Book not found")


@app.delete("/api/books/", status_code=204)
def reset_store():
    global books
    books = []



@app.middleware("http")
async def reset_books_on_each_request(request: Request, call_next):
    # Optional reset logic here
    response = await call_next(request)
    return response

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
