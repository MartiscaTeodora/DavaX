def contains_inappropriate_language(text: str):
    banned_words = [
        "stupid", "idiot", "hate", "dumb",
        "garbage", "useless", "worthless",
        "terrible", "awful", "horrible"
    ]

    text_lower = text.lower()
    return any(word in text_lower for word in banned_words)

def is_non_recommendation(answer: str):
    triggers = [
        "I am here to recommend books",
        "I cannot recommend a book",
        "Please use respectful language",
        "I am a book recommendation assistant"
    ]
    return any(trigger.lower() in answer.lower() for trigger in triggers)