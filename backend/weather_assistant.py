import requests
import os
from dotenv import load_dotenv
from forecast_week import get_7_day_forecast

load_dotenv()
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

def ask_groq(prompt):
    
    url = "https://api.groq.com/openai/v1/chat/completions"

    headers = {
        "Authorization": f"Bearer {GROQ_API_KEY}",
        "Content-Type": "application/json"
    }

    data = {
        "model": "llama-3.3-70b-versatile",
        "messages": [
            {
                "role": "system",
                "content": (
                    "You are a weather disaster risk analysis assistant. "
                    "First analyze whether the given 7-day forecast resembles "
                    "any historical disasters (floods, cyclones, heatwaves, storms). "
                    "Explain the similarity clearly. "
                    "Then continue as a friendly chatbot answering the user question."
                )
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
        "temperature": 0.7
    }
    response = requests.post(url, headers=headers, json=data)

    if response.status_code == 200:
        return response.json()["choices"][0]["message"]["content"]
    else:
        print("❌ API Error:", response.text)
        return "API Error."

def main():
    print("🚀 Forecast Script Started")
    print("🤖 Weather Disaster Risk Assistant (Groq Powered)")

    forecast = get_7_day_forecast()

    print("\n📊 7-Day Forecast:", forecast)
    print("\nType 'exit' to quit.\n")

    while True:
        user_input = input("You: ")

        if user_input.lower() == "exit":
            print("👋 Exiting Weather Assistant.")
            break

        full_prompt = f"""
        7-Day Temperature Forecast: {forecast}

        User Question: {user_input}

        Instructions:
        1. First analyze disaster similarity.
        2. Then respond normally like a chatbot.
        """

        print("\nAI:\n")
        answer = ask_groq(full_prompt)
        print(answer)
        print("\n" + "-" * 60 + "\n")

if __name__ == "__main__":
    main()