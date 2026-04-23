import { useState } from "react";

function App() {
  const [query, setQuery] = useState("");
const [answer, setAnswer] = useState("");
const [title, setTitle] = useState("");
const [summary, setSummary] = useState("");
const [audioUrl, setAudioUrl] = useState("");
const [voiceFile, setVoiceFile] = useState(null);
const [loading, setLoading] = useState(false);
const [summaryLoading, setSummaryLoading] = useState(false);
const [audioLoading, setAudioLoading] = useState(false);
const [sttLoading, setSttLoading] = useState(false);
const [error, setError] = useState("");


  const handleGetSummary = async () => {
  if (!title) return;

  setSummaryLoading(true);
  setError("");

  try {
    const response = await fetch("http://127.0.0.1:8000/summary", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ title })
    });

    const data = await response.json();

    if (data.error) {
      setError(data.error);
    } else {
      setSummary(data.summary || "");
    }
  } catch (err) {
    setError("Could not load summary.");
  } finally {
    setSummaryLoading(false);
  }
};
const handleGenerateAudio = async () => {
  const textForAudio = summary
    ? `${answer}\n\nFull summary:\n${summary}`
    : answer;

  if (!textForAudio) {
    setError("No text available for audio generation.");
    return;
  }

  setAudioLoading(true);
  setError("");

  try {
    const response = await fetch("http://127.0.0.1:8000/tts", {
      method: "POST",
      headers: {
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ text: textForAudio })
    });

    if (!response.ok) {
      const data = await response.json();
      setError(data.error || "Could not generate audio.");
      return;
    }

    const blob = await response.blob();
    const url = URL.createObjectURL(blob);
    setAudioUrl(url);
  } catch (err) {
    setError("Could not generate audio.");
  } finally {
    setAudioLoading(false);
  }
};
  const handleRecommend = async () => {
    if (!query.trim()) {
      setError("Please enter a valid request.");
      return;
    }

    setLoading(true);
    setError("");
    setAnswer("");
    setTitle("");
    setAudioUrl("");

    try {
      const response = await fetch("http://127.0.0.1:8000/recommend", {
        method: "POST",
        headers: {
          "Content-Type": "application/json"
        },
        body: JSON.stringify({ query })
      });

      const data = await response.json();

      if (data.error) {
        setError(data.error);
      } else {
        setAnswer(data.answer || "");
        setTitle(data.title || "");
      }
    } catch (err) {
      setError("Could not connect to backend.");
    } finally {
      setLoading(false);
    }
  };
  const handleTranscribe = async () => {
  if (!voiceFile) {
    setError("Please select an audio file.");
    return;
  }

  setSttLoading(true);
  setError("");

  try {
    const formData = new FormData();
    formData.append("file", voiceFile);

    const response = await fetch("http://127.0.0.1:8000/stt", {
      method: "POST",
      body: formData,
    });

    const data = await response.json();

    if (data.error) {
      setError(data.error);
    } else {
      setQuery(data.transcript || "");
    }
  } catch (err) {
    setError("Could not transcribe audio.");
  } finally {
    setSttLoading(false);
  }
};

  return (
    <div style={{ maxWidth: "800px", margin: "40px auto", fontFamily: "Arial, sans-serif" }}>
      <h1>📚 Smart Librarian</h1>
      <p>Ask for a book recommendation based on your interests.</p>

      <textarea
        rows="4"
        style={{ width: "100%", padding: "12px", fontSize: "16px" }}
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        placeholder="Example: I want a book about friendship and magic"
      />

      <div style={{ marginTop: "20px" }}>
        <h3>Voice Input</h3>
        <input
          type="file"
          accept="audio/*"
          onChange={(e) => setVoiceFile(e.target.files[0])}
        />
      </div>
      <button
        onClick={handleRecommend}
        style={{ marginTop: "12px", padding: "10px 16px", cursor: "pointer" }}
      >
        {loading ? "Loading..." : "Get Recommendation"}
      </button>

      <button
        onClick={handleTranscribe}
        style={{ marginTop: "12px", padding: "10px 16px", cursor: "pointer" }}
      >
        {sttLoading ? "Transcribing..." : "Transcribe audio"}
      </button>
      {error && (
        <div style={{ marginTop: "20px", color: "crimson" }}>
          {error}
        </div>
      )}

      {answer && (
        <div style={{ marginTop: "24px", padding: "16px", border: "1px solid #ddd", borderRadius: "8px" }}>
          <h2>Recommendation</h2>
          <p style={{ whiteSpace: "pre-wrap" }}>{answer}</p>

          {title && (
            <p>
              <strong>Detected title:</strong> {title}
            </p>
          )}
          {title && (
            <button onClick={handleGetSummary}>
               {summaryLoading ? "Loading summary..." : "Show full summary"}
            </button>
          )}
          {summary && (
              <div style={{ marginTop: "24px", padding: "16px", border: "1px solid #ddd", borderRadius: "8px" }}>
                <h2>Full Summary</h2>
                <p style={{ whiteSpace: "pre-wrap" }}>{summary}</p>
              </div>
            )}
            {answer && (
              <button onClick={handleGenerateAudio}>
                {audioLoading ? "Generating audio..." : "Generate audio"}
              </button>
            )}
            {audioUrl && (
              <div style={{ marginTop: "24px" }}>
                <h2>Audio</h2>
                <audio controls src={audioUrl} />
              </div>
            )}
        </div>
        
      )}
    </div>
  );
}

export default App;