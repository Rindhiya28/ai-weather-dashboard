# forecast_app.py

import requests
import joblib
import pandas as pd
import os
from dotenv import load_dotenv

load_dotenv()

print("🚀 Forecast Script Started")

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY")
CITY = "Chennai"


def get_7_day_forecast():

    print("🌦 Forecast Function Running")

    model = joblib.load("forecast_model.pkl")

    url = f"https://api.openweathermap.org/data/2.5/weather?q={CITY}&appid={OPENWEATHER_API_KEY}&units=metric"

    response = requests.get(url)

    if response.status_code != 200:
        raise Exception(f"Weather API Error: {response.text}")

    data = response.json()

    current_temp = data["main"]["temp"]

    lag1 = current_temp
    lag2 = current_temp
    lag3 = current_temp

    forecast = []

    for _ in range(7):

        X_new = pd.DataFrame(
            [[lag1, lag2, lag3]],
            columns=["lag1", "lag2", "lag3"]
        )

        pred = model.predict(X_new)[0]

        forecast.append(round(float(pred), 2))

        lag3 = lag2
        lag2 = lag1
        lag1 = pred


    return forecast


if __name__ == "__main__":

    forecast = get_7_day_forecast()
    print("Final Forecast:", forecast)