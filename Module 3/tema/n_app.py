from data_utils import load_books, get_summary_by_title
from rag_utils import (
    run_book_recommendation_only,
    handle_fallback_recommendation
)
from audio_utils import transcribe_audio_file, ask_for_tts_and_generate
from moderation_utils import contains_inappropriate_language, is_non_recommendation

def ask_yes_no(question: str):
    while True:
        choice = input(question).strip().lower()
        if choice in ["y", "n"]:
            return choice
        print("⚠️ Please type 'y' or 'n'.")

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
                print(":( Could not transcribe the audio file.")
                continue

            print(f"\n📝 Transcribed text: {user_query}")

        elif mode == "text":
            user_query = input("Ask for a book recommendation: ").strip()

        else:
            print(":( Please choose 'text', 'voice', or 'exit'.")
            continue

        # basic validations
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
            # 1. get only short recommendation
            title, answer = run_book_recommendation_only(user_query)

            if not answer:
                print(":( No response received. Please try again.")
                continue

            # 2. fallback if connection fails
            if "Could not connect" in answer:
                fallback_text = handle_fallback_recommendation(user_query)

                if fallback_text:
                    print("\n" + "=" * 50)
                    print("📚 FALLBACK RECOMMENDATION")
                    print("=" * 50)
                    print(fallback_text)

                    # ask for audio even for fallback
                    ask_for_tts_and_generate(fallback_text, "fallback_recommendation.mp3")
                else:
                    print("Could not retrieve fallback data.")

                continue

            # 3. normal response
            print("\n" + "=" * 50)
            if is_non_recommendation(answer):
                print(" RESPONSE")
            else:
                print("📚 RECOMMENDATION")
            print("=" * 50)
            print(answer)

            final_text_for_audio = answer

            # 4. ask if user wants full summary
            if title and not is_non_recommendation(answer):
                summary_choice = ask_yes_no("\nWould you like to see the full summary? (y/n): ")

                if summary_choice == "y":
                    full_summary = get_summary_by_title(title, books_data)

                    print("\n" + "-" * 50)
                    print("📖 FULL SUMMARY")
                    print("-" * 50)
                    print(full_summary)

                    final_text_for_audio = f"{answer}\n\nFull summary:\n{full_summary}"
                else:
                    print("👍 Okay, skipping full summary.")
                    final_text_for_audio = answer
            # 5. ask if user wants audio
            ask_for_tts_and_generate(final_text_for_audio, "recommendation.mp3")

        except Exception as e:
            print("\n:( An unexpected error occurred.")
            print("Details:", str(e))
            print("Please try again.")