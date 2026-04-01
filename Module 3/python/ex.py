"""
Intro to Python:
- Variables and printing
- Lists (creation + basic methods)
- Arrays (using Python's built-in `array` module)
- Basic asynchronous functions with asyncio
"""

# -------------------------------
# 1) Variables and basic output
# -------------------------------
a = 10
name = "Python learner"

print("Value of a:", a)
print("Hello,", name)
print("-" * 40)

# -------------------------------
# 2) Lists (most common collection)
# -------------------------------
# A list can store multiple values and can mix data types.
numbers = [10, 5, 20, 15]

# Access by index (starts at 0)
print("First item:", numbers[0])

# Add items
numbers.append(25)         # adds at end
numbers.insert(1, 12)      # inserts 12 at index 1

# Remove items
numbers.remove(5)          # removes first matching value
last_item = numbers.pop()  # removes and returns last item

# Sort and reverse
numbers.sort()             # ascending order
numbers.reverse()          # reverse current order

# Useful built-in functions
print("List now:", numbers)
print("Removed last item:", last_item)
print("Length:", len(numbers))
print("Sum:", sum(numbers))
print("Slice [0:2]:", numbers[0:2])  # first two items
print("-" * 40)

# -------------------------------
# 3) Arrays (typed, from array module)
# -------------------------------
# Arrays are like lists, but all items must be the same type.
# 'i' means signed integer.
from array import array

scores = array('i', [70, 85, 90])

scores.append(100)     # add at end
scores.insert(1, 75)   # insert at index 1
removed = scores.pop() # remove last

print("Array scores:", scores)
print("Removed from array:", removed)
print("Second score:", scores[1])
print("-" * 40)

# -------------------------------
# 4) Asynchronous functions (asyncio)
# -------------------------------
# Async is useful when tasks wait (e.g., network, file, API calls).
import asyncio

async def fetch_data(task_name: str, delay: int) -> str:
    # Simulate waiting for I/O with asyncio.sleep
    print(f"{task_name}: started, waiting {delay}s...")
    await asyncio.sleep(delay)  # non-blocking wait
    print(f"{task_name}: finished")
    return f"{task_name} result"

async def main() -> None:
    # Run tasks concurrently (at the same time from your perspective)
    results = await asyncio.gather(
        fetch_data("Task A", 2),
        fetch_data("Task B", 1),
    )
    print("Async results:", results)

# Entry point for script execution
if __name__ == "__main__":
    asyncio.run(main())