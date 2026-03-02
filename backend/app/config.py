"""
DiaMetrics Backend — Configuration

Loads all secrets from the .env file (never from source code).
Copy .env.example to .env and fill in your real values before running.
"""
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # --- Third-party API keys (server-side only, never in the Flutter APK) ---
    GEMINI_API_KEY: str
    USDA_API_KEY: str = "DEMO_KEY"

    # --- Shared secret between Flutter app and this backend ---
    # Flutter passes this as Authorization: Bearer <BACKEND_API_KEY>
    BACKEND_API_KEY: str

    # --- Gemini model ---
    GEMINI_MODEL: str = "gemini-2.5-flash"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
