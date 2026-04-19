import os
import chromadb
from openai import OpenAI
from dotenv import load_dotenv

base_dir = os.path.dirname(os.path.abspath(__file__))
load_dotenv()

client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    timeout=60,
    max_retries=2
)

chroma_client = chromadb.PersistentClient(path=os.path.join(base_dir, "chroma_db"))
collection = chroma_client.get_or_create_collection(name="books")