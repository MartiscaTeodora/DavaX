import json
import chromadb
from openai import OpenAI # type: ignore
from dotenv import load_dotenv
import os


print(os.getcwd())
# load env
load_dotenv()

# init OpenAI
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# init ChromaDB
chroma_client = chromadb.PersistentClient(path="./chroma_db")
collection = chroma_client.get_or_create_collection(name="books")

# load books
base_dir = os.path.dirname(__file__)
file_path = os.path.join(base_dir, "books.json")

with open(file_path, "r", encoding="utf-8") as f:
    books = json.load(f)
# ingest
for i, book in enumerate(books):
    text = f"{book['title']}. {book['summary']}"

    response = client.embeddings.create(
        model="text-embedding-3-small",
        input=text
    )

    embedding = response.data[0].embedding

    collection.add(
        ids=[str(i)],
        embeddings=[embedding],
        documents=[book["summary"]],
        metadatas=[{"title": book["title"]}]
    )

print(" Ingest completed successfully")