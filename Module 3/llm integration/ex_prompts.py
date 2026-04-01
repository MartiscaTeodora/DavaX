"""  # Example 1: Simple GET request
import requests

response = requests.get('https://api.example.com/users/1')
data = response.json()
print(data)

# Example 2: POST request with data
import requests

payload = {'name': 'Alice', 'email': 'alice@example.com'}
response = requests.post('https://api.example.com/users', json=payload)
print(response.json())

# Example 3: GET with query parameters
import requests

params = {'page': 1, 'limit': 10}
response = requests.get('https://api.example.com/posts', params=params)
print(response.json())

# Example 4: POST request with headers and authentication

headers = {'Authorization': 'Bearer token123', 'Content-Type': 'application/json'}
payload = {'prompt': 'Explain Python', 'temperature': 0.7}
response = requests.post('https://api.example.com/chat', json=payload, headers=headers)
print(response.json())

# Example 5: GET request with timeout and temperature parameter

params = {'model': 'gpt-4', 'temperature': 0.5, 'max_tokens': 100}
response = requests.get('https://api.example.com/generate', params=params, timeout=10)
print(response.json())

# Example 6: POST request with multiple parameters including temperature and top_p

payload = {
    'prompt': 'Write a story',
    'temperature': 0.9, # Higher temperature for more creativity; 0.7 is default
    'top_p': 0.95,
    'frequency_penalty': 0.5,
    'presence_penalty': 0.2
}
response = requests.post('https://api.example.com/completions', json=payload)
print(response.json()) """