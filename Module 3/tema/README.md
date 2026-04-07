# Smart Librarian - AI with RAG + Tool Calling

This project implements an AI chatbot that recommends books based on the user's interests.
It uses RAG with ChromaDB for semantic retrieval and OpenAI for conversational responses.
After recommending a book, it calls a local tool to fetch the full summary of the selected title.

## Project Goal

The goal of this project is to build a smart librarian chatbot that:
- understands user preferences in natural language
- retrieves relevant books using semantic search
- recommends one book conversationally
- fetches a detailed summary through a separate tool function

## Technologies Used

- Python
- OpenAI API
- ChromaDB
- JSON
- Streamlit / CLI

## Project Structure

- `books.json` - local database of book titles and summaries
- `ingest.py` - loads books into ChromaDB
- `app.py` - main chatbot application
- `README.md` - setup and usage instructions
- `.env` - stores API key

Start the chatbot
python app.py


### Cum funcționează proiectul
Asta e partea foarte valoroasă. Nu doar „cum rulezi”, ci și „ce se întâmplă înăuntru”.

Exemplu:

```md
## How It Works

1. Book data is stored locally in `books.json`
2. Each book summary is converted into embeddings using OpenAI
3. Embeddings are stored in ChromaDB
4. When the user asks for a recommendation, the query is embedded and matched against stored books
5. The most relevant books are passed to the LLM as context
6. The LLM recommends the best matching title
7. A tool called `get_summary_by_title(title)` is used to fetch the full summary of the selected book

## Example Prompts

- "I want a book about freedom and social control."
- "What do you recommend for someone who loves fantasy stories?"
- "I want a book about friendship and magic."
- "What is 1984 about?"

## Notes / Limitations

- The recommendation quality depends on the quality of the summaries in `books.json`
- Exact title matching is required for the summary tool
- The system currently uses a local JSON file as the source of truth for detailed summaries