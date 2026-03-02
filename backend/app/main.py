"""
DiaMetrics Backend — FastAPI Application

This server acts as a secure proxy between the Flutter app and third-party APIs
(Gemini, USDA FoodData Central, Open Food Facts).

Architecture:
    Flutter App  →  This Backend  →  Gemini / USDA / Open Food Facts
                    (holds keys)

All third-party API keys are stored in .env only.
The Flutter APK contains no third-party secrets — only BACKEND_URL and
BACKEND_API_KEY (a shared secret).

PII Boundary:
    STAYS ON DEVICE:  glucose logs, medication logs, meal logs, user profiles
    GOES TO BACKEND:  food images (base64), food names, barcodes — non-PII only

Run for development:
    uvicorn app.main:app --reload --port 8000
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .routers import barcode, food_analysis, usda

app = FastAPI(
    title="DiaMetrics Food API",
    description=(
        "Secure backend proxy for DiaMetrics diabetes management app. "
        "Proxies Gemini AI food analysis, USDA nutrition lookup, and "
        "Open Food Facts barcode lookup — keeping all API keys server-side."
    ),
    version="1.0.0",
)

# ---------------------------------------------------------------------------
# CORS — allow the Flutter app (mobile) to reach the API.
# For production, restrict allow_origins to your domain.
# ---------------------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET", "POST"],
    allow_headers=["Authorization", "Content-Type"],
    allow_credentials=False,
)

# ---------------------------------------------------------------------------
# Routers
# ---------------------------------------------------------------------------
app.include_router(food_analysis.router, prefix="/api/v1/food", tags=["Food Analysis"])
app.include_router(usda.router, prefix="/api/v1/food", tags=["Food Search"])
app.include_router(barcode.router, prefix="/api/v1/food", tags=["Barcode Lookup"])


# ---------------------------------------------------------------------------
# Health check (no auth required)
# ---------------------------------------------------------------------------
@app.get("/health", tags=["Health"])
def health_check() -> dict:
    """Returns OK — used to verify the server is running before making API calls."""
    return {"status": "ok", "service": "DiaMetrics Food API"}
