import os
from openai import APIConnectionError, APITimeoutError
from config import client, base_dir

def text_to_speech(text: str, output_file: str = "recommendation.mp3"):
    speech_file_path = os.path.join(base_dir, output_file)

    try:
        with client.audio.speech.with_streaming_response.create(
            model="gpt-4o-mini-tts",
            voice="alloy",
            input=text
        ) as response:
            response.stream_to_file(speech_file_path)

        return speech_file_path

    except APITimeoutError:
        return None
    except APIConnectionError:
        return None

def transcribe_audio_file(audio_path: str):
    try:
        with open(audio_path, "rb") as audio_file:
            transcription = client.audio.transcriptions.create(
                model="gpt-4o-mini-transcribe",
                file=audio_file
            )
        return transcription.text

    except FileNotFoundError:
        return None
    except Exception as e:
        print(f"STT error: {e}")
        return None

def ask_for_tts_and_generate(text: str, output_file: str = "recommendation.mp3"):
    while True:
        choice = input("\nWould you like to hear this response? (y/n): ").strip().lower()
        if choice in ["y", "n"]:
            break
        print("⚠️ Please type 'y' or 'n'.")

    if choice == "y":
        audio_path = text_to_speech(text, output_file)

        if audio_path:
            print(f"\n🔊 Audio saved to: {audio_path}")
        else:
            print("\n:( Could not generate audio.")