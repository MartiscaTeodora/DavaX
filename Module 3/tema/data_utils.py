import json
import os
from config import base_dir

def load_books(path=None):
    if path is None:
        path = os.path.join(base_dir, "books.json")

    with open(path, "r", encoding="utf-8") as file:
        return json.load(file)

def get_summary_by_title(title: str, data: list) -> str:
    for book in data:
        if book["title"].strip().lower() == title.strip().lower():
            return book["summary"]
    return f"Title not found: {title}"