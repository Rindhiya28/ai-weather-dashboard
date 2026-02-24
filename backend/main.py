# main.py — FastAPI backend for Weather ML Models
# Run with: uvicorn main:app --host 0.0.0.0 --port 8000

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import requests
import joblib
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Chennai Weather API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")
GROQ_API_KEY        = os.getenv("GROQ_API_KEY")
CITY = "Chennai"

# Load models once at startup
try:
    forecast_model = joblib.load("forecast_model.pkl")
    anomaly_model  = joblib.load("anomaly.pkl")
    print("✅ Models loaded successfully")
except Exception as e:
    print(f"❌ Model load error: {e}")
    forecast_model = None
    anomaly_model  = None


# ── Helpers ───────────────────────────────────────────────────────────────────

def fetch_current_temp() -> float:
    url = (
        f"https://api.openweathermap.org/data/2.5/weather"
        f"?q={CITY}&appid={OPENWEATHER_API_KEY}&units=metric"
    )
    resp = requests.get(url, timeout=10)
    if resp.status_code != 200:
        raise HTTPException(status_code=502, detail=f"OpenWeather error: {resp.text}")
    return resp.json()["main"]["temp"]


def get_forecast_list() -> list:
    """Run the forecast model and return 7 predicted temps."""
    current_temp = fetch_current_temp()
    lag1, lag2, lag3 = current_temp, current_temp, current_temp
    forecast = []
    for _ in range(7):
        X = pd.DataFrame([[lag1, lag2, lag3]], columns=["lag1", "lag2", "lag3"])
        pred = float(forecast_model.predict(X)[0])
        forecast.append(round(pred, 2))
        lag3, lag2, lag1 = lag2, lag1, pred
    return forecast


def ask_groq(user_message: str, forecast: list) -> str:
    """Call Groq LLaMA with forecast context + user message."""
    if not GROQ_API_KEY:
        return "⚠️ GROQ_API_KEY not set in .env file."

    url = "https://api.groq.com/openai/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    full_prompt = f"""
7-Day Temperature Forecast for Chennai: {forecast}

User Question: {user_message}

Instructions:
1. First briefly analyze if this forecast resembles any historical weather disasters 
   (floods, cyclones, heatwaves, storms) — keep this to 2-3 sentences.
2. Then answer the user's question in a friendly, helpful way.
3. Keep the total response concise and readable.
"""

    data = {
        "model": "llama-3.3-70b-versatile",
        "messages": [
            {
                "role": "system",
                "content": (
                    "You are a weather disaster risk analysis assistant for Chennai, India. "
                    "You have access to a 7-day ML temperature forecast. "
                    "Analyze disaster risks and answer weather questions in a clear, friendly way. "
                    "Keep responses concise — under 150 words."
                )
            },
            {
                "role": "user",
                "content": full_prompt
            }
        ],
        "temperature": 0.7
    }

    resp = requests.post(url, headers=headers, json=data, timeout=30)
    if resp.status_code == 200:
        return resp.json()["choices"][0]["message"]["content"]
    else:
        return f"AI Error: {resp.text}"


# ── Request model ─────────────────────────────────────────────────────────────

class ChatRequest(BaseModel):
    message: str


# ── Endpoints ─────────────────────────────────────────────────────────────────

@app.get("/")
def root():
    return {"status": "ok", "message": "Chennai Weather API is running"}


@app.get("/forecast")
def get_forecast():
    if forecast_model is None:
        raise HTTPException(status_code=500, detail="Forecast model not loaded")
    forecast = get_forecast_list()
    return {"city": CITY, "forecast_celsius": forecast}


@app.get("/anomaly")
def get_anomaly():
    if anomaly_model is None:
        raise HTTPException(status_code=500, detail="Anomaly model not loaded")
    current_temp = fetch_current_temp()
    input_df = pd.DataFrame([[current_temp]], columns=["tavg"])
    prediction = int(anomaly_model.predict(input_df)[0])
    is_anomaly = prediction == -1
    return {
        "city": CITY,
        "current_temp_celsius": round(current_temp, 2),
        "is_anomaly": is_anomaly,
        "message": "⚠️ Anomaly Detected!" if is_anomaly else "✅ Temperature is Normal",
    }


@app.post("/chat")
def chat(req: ChatRequest):
    """
    GenAI chatbot endpoint — uses Groq LLaMA + ML forecast.
    Request:  { "message": "Will it flood this week?" }
    Response: { "reply": "Based on the forecast..." }
    """
    if forecast_model is None:
        raise HTTPException(status_code=500, detail="Forecast model not loaded")

    try:
        forecast = get_forecast_list()
        reply = ask_groq(req.message, forecast)
        return {"reply": reply}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))