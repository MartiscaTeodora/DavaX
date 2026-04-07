import json

# This function loads the book data from a JSON file and 
# returns it as a list of dictionaries.
def load_books(path="Module 3/tema/books.json"):
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

print(get_summary_by_title("1984", books))
print(get_summary_by_title("The Hobbit", books))
print(get_summary_by_title("Unknown Book", books))