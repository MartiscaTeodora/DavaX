# OOP THEORY IN PYTHON
"""
OOP THEORY IN PYTHON - ACCESS LEVELS AND VISIBILITY
This module demonstrates Object-Oriented Programming concepts in Python,
with a focus on access levels and attribute visibility.
ACCESS LEVELS IN PYTHON:
========================
1. PUBLIC ATTRIBUTES (no prefix):
    - Accessible from anywhere: inside the class, outside the class, subclasses
    - Example: self.name, self.age
    - Convention: Use when data should be freely accessible
    - No naming restrictions enforced by Python
2. PROTECTED ATTRIBUTES (single underscore prefix: _):
    - By convention, should only be accessed within the class and subclasses
    - Example: self._width, self._height
    - NOT enforced by Python - it's a code style guideline
    - Signals to other developers: "This is internal, use with caution"
    - Can be accessed from outside, but developers shouldn't do it
3. PRIVATE ATTRIBUTES (double underscore prefix: __):
    - Name mangling applied: Python mangles the name to _ClassName__attribute
    - Example: self.__balance becomes self._BankAccount__balance
    - Hardest to access from outside (not truly private, just obfuscated)
    - Prevents accidental access and overwrites in subclasses
    - Still accessible if you know the mangled name (not truly secure)
4. SPECIAL/MAGIC ATTRIBUTES (double underscore prefix and suffix: __name__):
    - Reserved methods for operator overloading and special behavior
    - Examples: __init__, __str__, __repr__, __eq__
    - Defined by Python; should not be created casually by developers
    - Enable customization of built-in operations
    - Example uses: __str__ for string representation, __eq__ for equality comparison
COMPARISON TABLE:
=================
Prefix          | Name          | Accessible | Use Case
----------------|---------------|-----------|--------------------------------------------------
(none)          | Public        | Everywhere| General attributes meant to be used freely
_single         | Protected     | Convention| Internal attributes; hint to subclasses
__double        | Private       | Name      | Hide from subclasses; prevent accidental access
                     |               | mangled   |
__both__        | Special/Magic | Anywhere  | Operator overloading and special methods
                     |               | (reserved)| (defined by Python, not user-created)
KEY TAKEAWAYS:
==============
- Python does NOT enforce true privacy (unlike Java/C++)
- Access levels are conventions that guide developers
- Use properties and setters to control attribute access
- Private attributes use name mangling as a discouragment, not a lock
- Special methods enable igintuitive object behavior (e.g., __str__ for print())
"""

# 1. CLASSES AND OBJECTS
class Dog:
    """A class represents a blueprint for creating objects."""
    species = "Canis familiaris"  # Class attribute
    
    def __init__(self, name, age):
        """Constructor: initializes object attributes."""
        self.name = name  # Instance attribute
        self.age = age

# Creating objects (instances)
dog1 = Dog("Buddy", 3)
dog2 = Dog("Max", 5)


# 2. INHERITANCE
class Animal:
    def __init__(self, name):
        self.name = name
    
    def speak(self):
        return f"{self.name} makes a sound"

class Cat(Animal):
    """Subclass inherits from Animal."""
    def speak(self):
        return f"{self.name} meows"  # Method overriding


# 3. ENCAPSULATION
class BankAccount:
    def __init__(self, balance):
        self.__balance = balance  # Private attribute (name mangling)
    
    def deposit(self, amount):
        self.__balance += amount
    
    def get_balance(self):
        return self.__balance


# 4. POLYMORPHISM
class Vehicle:
    def move(self):
        pass

class Car(Vehicle):
    def move(self):
        return "Driving on road"

class Boat(Vehicle):
    def move(self):
        return "Sailing on water"

# Same method call, different behavior
vehicles = [Car(), Boat()]
for vehicle in vehicles:
    print(vehicle.move())  # Polymorphic behavior


# 5. SPECIAL METHODS (Dunder Methods)
class Person:
    def __init__(self, name, age):
        self.name = name
        self.age = age
    
    def __str__(self):
        return f"{self.name}, {self.age}"
    
    def __repr__(self):
        return f"Person('{self.name}', {self.age})"
    
    def __eq__(self, other):
        return self.age == other.age


# 6. STATIC AND CLASS METHODS
class MathOps:
    pi = 3.14159
    
    @staticmethod
    def add(a, b):
        """Static method doesn't use self or cls."""
        return a + b
    
    @classmethod
    def from_string(cls, value):
        """Class method receives cls as first parameter."""
        return cls(int(value))


# 7. PROPERTIES (Getters/Setters)
class Rectangle:
    def __init__(self, width, height):
        self._width = width
        self._height = height
    
    @property
    def area(self):
        return self._width * self._height
    
    @property
    def width(self):
        return self._width
    
    @width.setter
    def width(self, value):
        if value <= 0:
            raise ValueError("Width must be positive")
        self._width = value

