
from fastapi import FastAPI
from pydantic import BaseModel

from data_utils import load_books, get_summary_by_title
from rag_utils import run_book_recommendation_only
from moderation_utils import contains_inappropriate_language, is_non_recommendation
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse
import os
from fastapi import UploadFile, File

from audio_utils import text_to_speech
from config import base_dir

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)        
books_data = load_books()


class QueryRequest(BaseModel):
    query: str

class SummaryRequest(BaseModel):
    title: str

class TTSRequest(BaseModel):
    text: str

@app.get("/")
def root():
    return {"message": "Smart Librarian API is running"}

@app.post("/recommend")
def recommend_book(request: QueryRequest):
    user_query = request.query

    if not user_query or len(user_query) < 5:
        return {"error": "Invalid query"}
    
    if not user_query:
        return {"error": "Please enter a valid question."}

    if contains_inappropriate_language(user_query):
        return {"error": "Please use respectful language"}

    title, answer = run_book_recommendation_only(user_query)

    return {
        "answer": answer,
        "title": title,
         "is_non_recommendation": is_non_recommendation(answer) if answer else False,
    }


@app.post("/summary")
def get_full_summary(request: SummaryRequest):
    if not request.title.strip():
        return {"error": "Missing title."}

    summary = get_summary_by_title(request.title, books_data)

    if summary.startswith("Title not found:"):
        return {"error": summary}

    return {"summary": summary}

@app.post("/tts")
def generate_tts(request: TTSRequest):
    text = request.text.strip()

    if not text:
        return {"error": "Missing text for audio generation."}

    output_file = "frontend_recommendation.mp3"
    audio_path = text_to_speech(text, output_file)

    if not audio_path:
        return {"error": "Could not generate audio."}

    return FileResponse(
        path=audio_path,
        media_type="audio/mpeg",
        filename=output_file
    )

@app.post("/stt")
async def transcribe_audio(file: UploadFile = File(...)):
    if not file.filename:
        return {"error": "No audio file provided."}

    try:
        transcription = client.audio.transcriptions.create(
            model="gpt-4o-mini-transcribe",
            file=(file.filename, await file.read(), file.content_type)
        )

        return {"transcript": transcription.text}

    except Exception as e:
        return {"error": f"Could not transcribe audio: {str(e)}"}