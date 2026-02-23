# anomaly_detect.py

import requests
import joblib
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

print("⚠️ Anomaly Detection Started")

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")
CITY = "Chennai"

model = joblib.load("anomaly.pkl")

url = f"https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={OPENWEATHER_API_KEY}&units=metric"

response = requests.get(url)

if response.status_code != 200:
    raise Exception("Weather API Failed")

data = response.json()

current_temp = data["main"]["temp"]

input_df = pd.DataFrame([[current_temp]], columns=["tavg"])

prediction = model.predict(input_df)

if prediction[0] == -1:
    print("⚠️ Anomaly Detected!")
else:
    print("✅ Temperature is Normal. No anomaly detected!")