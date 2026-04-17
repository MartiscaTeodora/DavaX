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

<!-- 
### Cum funcționează proiectul
Asta e partea foarte valoroasă. Nu doar „cum rulezi”, ci și „ce se întâmplă înăuntru”.

Exemplu:

```md -->
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

## Development stages:

This project was developed step by step to ensure a clear understanding of the RAG pipeline and tool integration.

### 1. Data Preparation
- Created `books.json` with 10+ books
- Each book includes a title and a short summary
- Purpose: provide a local knowledge base for recommendations

### 2. Tool Implementation
- Implemented `get_summary_by_title(title)`
- Retrieves the full summary from local data
- Purpose: provide deterministic access to detailed information

### 3. Vector Store (ChromaDB)
- Converted book summaries into embeddings using OpenAI
- Stored embeddings in ChromaDB
- Purpose: enable semantic search

### 4. Retrieval (RAG)
- Implemented `retrieve_books(query)`
- Finds the most relevant books based on user input
- Purpose: match user intent with book themes

### 5. Prompt Construction
- Built a structured prompt including:
  - user query
  - retrieved books
- Purpose: guide the LLM to select the best recommendation

### 6. LLM Integration
- Used OpenAI to generate a conversational recommendation
- Ensured the model selects from retrieved books only

### 7. Tool Calling Integration
- Registered `get_summary_by_title` as a tool
- The model calls the tool to fetch the full summary
- Purpose: separate reasoning (LLM) from data retrieval (tool)

### 8. CLI Interface
- Implemented interactive loop using `input()`
- Added validations and error handling

### 9. Improvements & Robustness
- Added input validation
- Added error handling for API failures
- Improved output formatting