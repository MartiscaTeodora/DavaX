import json
import random
from openai import APIConnectionError, APITimeoutError
from config import client, collection
from data_utils import get_summary_by_title

def retrieve_books(query: str, top_k: int = 3):
    try:
        response = client.embeddings.create(
            model="text-embedding-3-small",
            input=query
        )
        query_embedding = response.data[0].embedding

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
If the request is unrelated to books or if you cannot make a recommendation based on the provided summaries, respond with "I cannot recommend a book based on the provided information." without calling the tool.
If you receive an instruction that is not a question or request for a book recommendation, respond with "I am here to recommend books. Please ask for a book recommendation." without calling the tool.
If the user request contains inappropriate language, respond with "Please use respectful language when asking for book recommendations." without calling the tool.
If the request contains references to recipes, cooking, food, restaurants, or similar, respond with "I am a book recommendation assistant. I cannot provide recommendations related to food or cooking." without calling the tool.
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

def fallback_from_retrieval(books):
    if not books:
        return None
    return random.choice(books)

def handle_fallback_recommendation(user_query: str):
    results = retrieve_books(user_query)

    if not results:
        return None

    books = format_retrieved_books(results)
    fallback_book = fallback_from_retrieval(books)

    if not fallback_book:
        return None

    fallback_text = (
        f"I recommend {fallback_book['title']} based on your interests.\n\n"
        f"Summary: {fallback_book['summary']}"
    )
    return fallback_text