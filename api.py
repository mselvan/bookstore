from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from pydantic import BaseModel, validator
from typing import List
import uvicorn

app = FastAPI()

# --- In-memory database ---
books = []
next_id = 0


# --- Book model ---
class Book(BaseModel):
    id: int = None
    author: str
    title: str

    @validator("author")
    def validate_author(cls, v):
        if v is None:
            raise ValueError('Field "author" is required')
        if not v.strip():
            raise ValueError('Field "author" cannot be empty')
        return v

    @validator("title")
    def validate_title(cls, v):
        if v is None:
            raise ValueError('Field "title" is required')
        if not v.strip():
            raise ValueError('Field "title" cannot be empty')
        return v


@app.exception_handler(ValueError)
async def value_error_handler(request: Request, exc: ValueError):
    return JSONResponse(status_code=400, content={"error": str(exc)})


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

    # ID is read-only
    if new_book.id is not None:
        raise HTTPException(status_code=400, detail="Field \"id\" is read-only")

    # Duplicate check
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
            if not updated_book.title.strip():
                raise HTTPException(status_code=400, detail='Field "title" cannot be empty')
            if not updated_book.author.strip():
                raise HTTPException(status_code=400, detail='Field "author" cannot be empty')

            updated = updated_book.dict()
            updated["id"] = book_id  # enforce correct id
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

@app.middleware("http")
async def reset_books_on_each_request(request: Request, call_next):
    # Optional: reset for each request (only for strict test reset)
    # global books, next_id
    # books = []
    # next_id = 0
    response = await call_next(request)
    return response


if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)

