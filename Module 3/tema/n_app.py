from data_utils import load_books
from rag_utils import run_book_assistant, handle_fallback_recommendation
from audio_utils import transcribe_audio_file, ask_for_tts_and_generate
from moderation_utils import contains_inappropriate_language, is_non_recommendation

if __name__ == "__main__":
    books_data = load_books()

    print("=" * 50)
    print("📚 SMART LIBRARIAN")
    print("=" * 50)

    while True:
        mode = input("\nChoose input type (text, voice or type 'exit'): ").strip().lower()

        if mode == "exit":
            print("Goodbye!")
            break

        if mode == "voice":
            audio_path = input("Enter audio file path: ").strip()
            user_query = transcribe_audio_file(audio_path)

            if not user_query:
                print("⚠️ Could not transcribe the audio file.")
                continue

            print(f"\n📝 Transcribed text: {user_query}")

        elif mode == "text":
            user_query = input("Ask for a book recommendation: ").strip()

        else:
            print("⚠️ Please choose 'text', 'voice', or 'exit'.")
            continue

        if not user_query:
            print(":( Please enter a valid question.")
            continue

        if len(user_query) < 5:
            print(":( Please provide a more detailed request.")
            continue

        if contains_inappropriate_language(user_query):
            print(":/ Please use respectful language.")
            continue

        try:
            answer = run_book_assistant(user_query, books_data)

            if not answer:
                print("⚠️ No response received. Please try again.")
                continue

            if "Could not connect" in answer:
                fallback_text = handle_fallback_recommendation(user_query)

                if fallback_text:
                    print("\n" + "=" * 50)
                    print("📚 FALLBACK RECOMMENDATION")
                    print("=" * 50)
                    print(fallback_text)
                    ask_for_tts_and_generate(fallback_text, "fallback_recommendation.mp3")
                else:
                    print("Could not retrieve fallback data.")

                continue

            print("\n" + "=" * 50)
            if is_non_recommendation(answer):
                print("ℹ️ RESPONSE")
            else:
                print("📚 RECOMMENDATION")
            print("=" * 50)
            print(answer)

            ask_for_tts_and_generate(answer, "recommendation.mp3")

        except Exception as e:
            print("\n:( An unexpected error occurred.")
            print("Details:", str(e))
            print("Please try again.")