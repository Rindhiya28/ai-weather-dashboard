# main.py — FastAPI backend for Weather ML Models
# Run with: uvicorn main:app --host 0.0.0.0 --port 8000

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import requests
import joblib
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(title="Chennai Weather API", version="1.0.0")

# Allow Flutter (any origin during dev; restrict in production)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["*"],
)

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")
CITY = "Chennai"

# Load models once at startup (not on every request)
try:
    forecast_model = joblib.load("forecast_model.pkl")
    anomaly_model  = joblib.load("anomaly.pkl")
    print("✅ Models loaded successfully")
except Exception as e:
    print(f"❌ Model load error: {e}")
    forecast_model = None
    anomaly_model  = None


def fetch_current_temp() -> float:
    """Fetch current temperature from OpenWeather."""
    url = (
        f"https://api.openweathermap.org/data/2.5/weather"
        f"?q={CITY}&appid={OPENWEATHER_API_KEY}&units=metric"
    )
    resp = requests.get(url, timeout=10)
    if resp.status_code != 200:
        raise HTTPException(status_code=502, detail=f"OpenWeather error: {resp.text}")
    return resp.json()["main"]["temp"]


# ── Endpoints ────────────────────────────────────────────────────────────────

@app.get("/")
def root():
    return {"status": "ok", "message": "Chennai Weather API is running"}


@app.get("/forecast")
def get_forecast():
    """
    Returns a 7-day temperature forecast (°C) as a list.
    Example response:
      { "city": "Chennai", "forecast_celsius": [32.1, 31.8, 33.0, ...] }
    """
    if forecast_model is None:
        raise HTTPException(status_code=500, detail="Forecast model not loaded")

    current_temp = fetch_current_temp()
    lag1, lag2, lag3 = current_temp, current_temp, current_temp
    forecast = []

    for _ in range(7):
        X = pd.DataFrame([[lag1, lag2, lag3]], columns=["lag1", "lag2", "lag3"])
        pred = float(forecast_model.predict(X)[0])
        forecast.append(round(pred, 2))
        lag3, lag2, lag1 = lag2, lag1, pred

    return {"city": CITY, "forecast_celsius": forecast}


@app.get("/anomaly")
def get_anomaly():
    """
    Checks whether current temperature is anomalous.
    Example response:
      { "city": "Chennai", "current_temp_celsius": 38.5,
        "is_anomaly": true, "message": "⚠️ Anomaly Detected!" }
    """
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