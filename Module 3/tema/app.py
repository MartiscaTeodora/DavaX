import json
import os
import chromadb
from openai import OpenAI, APIConnectionError, APITimeoutError
from dotenv import load_dotenv
from streamlit import title


print(os.getcwd())
base_dir = os.path.dirname(os.path.abspath(__file__))


# Example usage of the get_summary_by_title function with some test cases.
""" print(get_summary_by_title("1984", books))
print(get_summary_by_title("The Hobbit", books))
print(get_summary_by_title("Unknown Book", books)) """



# 1. încărcăm variabilele din .env
load_dotenv()

# 2. inițializăm clientul OpenAI
client = OpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    timeout=60,
    max_retries=2)

# 3. ne conectăm la aceeași bază ChromaDB folosită la ingest
chroma_client = chromadb.PersistentClient(path="./chroma_db")
collection = chroma_client.get_or_create_collection(name="books")

# This function loads the book data from a JSON file and 
# returns it as a list of dictionaries.
def load_books(path="books.json"):
    with open(path, 'r', encoding='utf-8') as file:
        data = json.load(file)
        return data

# This function takes a book title and a list of book data, and 
# returns the summary of the book if found.
def get_summary_by_title(title: str, data: list)-> str:
    
    for book in data:
        # Compare titles in a case-insensitive manner and ignore 
        # leading/trailing whitespace
        if book['title'].strip().lower() == title.strip().lower(): 
            return book['summary']
    return 'Title not found: ' + title

books = load_books()

def retrieve_books(query: str, top_k: int = 3):
    """
    Primește query-ul utilizatorului, creează embedding,
    caută în ChromaDB și returnează cele mai relevante rezultate.
    """

    try:
        # 4. generăm embedding pentru întrebarea utilizatorului
        response = client.embeddings.create(
            model="text-embedding-3-small",
            input=query
        )
        query_embedding = response.data[0].embedding

        # 5. căutăm în vector store
        results = collection.query(
            query_embeddings=[query_embedding],
            n_results=top_k
        )

        return results
    except APITimeoutError:
        print("The request timed out. Please try again later.")
        return None
    except APIConnectionError:
        print("Failed to connect to the API. Please check your network connection.")
        return None

# Această funcție formatează rezultatele obținute de la ChromaDB într-un format ușor de citit.
def format_retrieved_books(results):
    formatted_books = []

    documents = results["documents"][0]
    metadatas = results["metadatas"][0]

    for doc, meta in zip(documents, metadatas):
        formatted_books.append({
            "title": meta["title"],
            "summary": doc
        })

    return formatted_books

def build_prompt(user_query: str, books: list):
    context_parts = []

    for book in books:
        context_parts.append(
            f"Title: {book['title']}\nSummary: {book['summary']}"
        )

    context = "\n\n".join(context_parts)

    prompt = f"""
You are a helpful book recommendation assistant.

User request:
{user_query}

Available books:
{context}

Choose the single best recommendation based only on the books above.
After choosing the book, call the tool get_summary_by_title with the exact title.
Then provide:
1. a short conversational recommendation
2. the detailed summary from the tool
"""
    return prompt

def run_book_assistant(user_query: str, books_data: list):
    results = retrieve_books(user_query)

    if results is None:
        return "Sorry, there was an error retrieving book recommendations. Please try again later."

    books = format_retrieved_books(results)

    if not books:
        return "No relevant books were found."

    prompt = build_prompt(user_query, books)

    tools = [
        {
            "type": "function",
            "name": "get_summary_by_title",
            "description": "Return the full local summary for an exact book title.",
            "parameters": {
                "type": "object",
                "properties": {
                    "title": {
                        "type": "string",
                        "description": "The exact title of the recommended book."
                    }
                },
                "required": ["title"],
                "additionalProperties": False
            }
        }
    ]

    try:
        first_response = client.responses.create(
            model="gpt-4.1-mini",
            input=prompt,
            tools=tools
        )
    except APITimeoutError:
        return "The request to OpenAI timed out. Please try again."
    except APIConnectionError:
        return "Could not connect to OpenAI. Check your internet, VPN, proxy, or firewall settings and try again."


    tool_call = None
    for item in first_response.output:
        if item.type == "function_call" and item.name == "get_summary_by_title":
            tool_call = item
            break

    if tool_call is None:
        return first_response.output_text

    arguments = json.loads(tool_call.arguments)
    title = arguments["title"]
    tool_result = get_summary_by_title(title, books_data)

    try:
        second_response = client.responses.create(
            model="gpt-4.1-mini",
            previous_response_id=first_response.id,
            input=[
                {
                    "type": "function_call_output",
                    "call_id": tool_call.call_id,
                    "output": tool_result
                }
            ]
        )
    except APITimeoutError:
        return "The recommendation was generated, but the follow-up tool step timed out."
    except APIConnectionError:
        return "The recommendation step worked, but the connection failed while finishing the response."


    return second_response.output_text


def extract_recommended_title(response_text: str):
    lines = response_text.splitlines()

    for line in lines:
        if line.startswith("RECOMMENDED_TITLE:"):
            return line.replace("RECOMMENDED_TITLE:", "").strip()

    return None
def get_book_recommendation(prompt: str):
    response = client.responses.create(
        model="gpt-4.1-mini",
        input=prompt
    )

    return response.output_text

if __name__ == "__main__":
    #books = load_books()
    #title = input("Enter book title: ")
    #print(get_summary_by_title(title, books))

    #results = retrieve_books("friendship and magic")

    #print(results)
    #books = format_retrieved_books(results)

    #print(books)

     #test for build_prompt
    """ user_query = "I want a book about friendship and magic"

    results = retrieve_books(user_query)
    books = format_retrieved_books(results)
    prompt = build_prompt(user_query, books)

    print(prompt) """
    # test for get_book_recommendation
    """ user_query = "I want a book about friendship and magic"

    results = retrieve_books(user_query)
    books = format_retrieved_books(results)
    prompt = build_prompt(user_query, books)
    recommendation = get_book_recommendation(prompt)

    print(recommendation)
    """
    # test for extract_recommended_title and get_summary_by_title integration
    """  user_query = "I want a book about friendship and magic"

    results = retrieve_books(user_query)
    books = format_retrieved_books(results)
    prompt = build_prompt(user_query, books)
    recommendation = get_book_recommendation(prompt)

    print("Recommendation:")
    print(recommendation)

    title = extract_recommended_title(recommendation)

    if title:
        full_summary = get_summary_by_title(title, load_books())
        print("\nDetailed summary:")
        print(full_summary)
    else:
        print("\nCould not extract the recommended title.")
     """
    
    # Final integration test with user input
    """ books_data = load_books()

    user_query = input("Ask for a book recommendation: ")

    if not user_query:
        print("Please enter a valid query.")
    else:    
        results = retrieve_books(user_query)
        books = format_retrieved_books(results)

        if not books:
            print("No relevant books found for your query.")
        else:
            prompt = build_prompt(user_query, books)
            recommendation = get_book_recommendation(prompt)

            print("\nRecommendation:")
            print(recommendation)

            title = extract_recommended_title(recommendation)

            if title:
                full_summary = get_summary_by_title(title, books_data)
                print("\nDetailed summary:")
                print(full_summary)
            else:
                print("\nCould not extract the recommended title.") """
    books_data = load_books()
    user_query = input("Ask for a book recommendation: ").strip()

    if not user_query:
        print("Please enter a valid question.")
    else:
        answer = run_book_assistant(user_query, books_data)
        print("\nAssistant response:\n")
        print(answer)