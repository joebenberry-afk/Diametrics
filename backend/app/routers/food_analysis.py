"""
DiaMetrics Backend — Gemini food image analysis proxy

POST /api/v1/food/analyze-image

Receives a base64-encoded food image from Flutter and calls the Gemini API
server-side. The GEMINI_API_KEY never leaves the server.

Security improvements over the previous Flutter-direct approach:
  - API key sent via 'x-goog-api-key' header (not URL query param)
  - No API key compiled into the APK
  - Server-side rate limiting prevents quota abuse

Security note: Only food image bytes (base64) and MIME type are received.
No patient PII (glucose, medications, user profiles) is involved.
"""
import base64
import json

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
import httpx

from ..auth import verify_token
from ..config import settings
from ..rate_limiter import gemini_limiter

router = APIRouter()

_GEMINI_ENDPOINT = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    f"{settings.GEMINI_MODEL}:generateContent"
)
_TIMEOUT = 40.0  # seconds — Gemini can be slow on large images


# ---------------------------------------------------------------------------
# Request / Response models
# ---------------------------------------------------------------------------

class AnalyzeImageRequest(BaseModel):
    image_base64: str
    mime_type: str = "image/jpeg"


# ---------------------------------------------------------------------------
# Endpoint
# ---------------------------------------------------------------------------

@router.post("/analyze-image")
async def analyze_image(
    body: AnalyzeImageRequest,
    token: str = Depends(verify_token),
) -> dict:
    """
    Analyse a food image using Gemini and return identified items + macros.

    Returns:
        {
          "items": [
            { "name": "Doubles", "portion": "6 doubles",
              "carbs_g": 210.0, "calories": 1050, "protein_g": 30.0, "fat_g": 42.0 }
          ],
          "total_carbs": 210.0,
          "total_calories": 1050.0,
          "summary": "6 Trinidadian Doubles"
        }
    """
    gemini_limiter.check(token)

    # Validate image data
    try:
        base64.b64decode(body.image_base64, validate=True)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid base64 image data.")

    gemini_request = _build_gemini_request(body.image_base64, body.mime_type)

    try:
        async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
            response = await client.post(
                _GEMINI_ENDPOINT,
                headers={
                    # Use header instead of URL query param — security improvement
                    "x-goog-api-key": settings.GEMINI_API_KEY,
                    "Content-Type": "application/json",
                },
                content=json.dumps(gemini_request),
            )
    except httpx.TimeoutException:
        raise HTTPException(status_code=503, detail="Gemini API timed out. Please try again.")
    except httpx.ConnectError as e:
        raise HTTPException(status_code=503, detail=f"Could not reach Gemini API: {e}")

    if response.status_code == 429:
        raise HTTPException(
            status_code=429,
            detail="Gemini API rate limit reached. Please wait a minute and try again.",
        )

    if response.status_code != 200:
        raise HTTPException(
            status_code=502,
            detail=f"Gemini API error (HTTP {response.status_code}).",
        )

    return _parse_gemini_response(response.text)


# ---------------------------------------------------------------------------
# Gemini request builder (prompt/schema identical to the old Flutter impl)
# ---------------------------------------------------------------------------

def _build_gemini_request(image_base64: str, mime_type: str) -> dict:
    """Build the full Gemini generateContent request body."""
    return {
        "contents": [
            {
                "role": "user",
                "parts": [
                    {
                        "text": (
                            "You are a professional clinical nutritionist AI assisting patients "
                            "in Trinidad and Tobago. "
                            "Analyze this food image and identify every visible food item, "
                            "prioritizing local Caribbean dishes "
                            "(e.g., Doubles, Sada Roti, Pelau) if applicable.\n\n"
                            "CRITICAL INSTRUCTION: Analyze the ENTIRE image. "
                            "If there are multiple pieces of the same food, group them into a "
                            "single item and state the TOTAL visible quantity "
                            "(e.g., '4 chicken breasts').\n\n"
                            "EXAMPLE INPUT: A photo showing 6 doubles on a table.\n"
                            "EXAMPLE OUTPUT:\n"
                            "{\n"
                            '  "thought_process": "I see 6 flatbreads filled with chickpeas. '
                            'These are 6 portions of Trinidadian Doubles.",\n'
                            '  "items": [\n'
                            "    {\n"
                            '      "name": "Doubles",\n'
                            '      "portion": "6 doubles",\n'
                            '      "carbs_g": 210.0,\n'
                            '      "calories": 1050,\n'
                            '      "protein_g": 30.0,\n'
                            '      "fat_g": 42.0\n'
                            "    }\n"
                            "  ],\n"
                            '  "summary": "6 Trinidadian Doubles"\n'
                            "}\n\n"
                            "Analyze the provided image now."
                        ),
                    },
                    {
                        "inline_data": {
                            "mime_type": mime_type,
                            "data": image_base64,
                        },
                    },
                ],
            }
        ],
        "systemInstruction": {
            "parts": [
                {
                    "text": (
                        "You must only return valid JSON matching the requested schema. "
                        "No markdown, no explanations."
                    ),
                }
            ]
        },
        "generationConfig": {
            "temperature": 0.1,
            "maxOutputTokens": 2048,
            "responseMimeType": "application/json",
            "responseSchema": {
                "type": "OBJECT",
                "properties": {
                    "thought_process": {"type": "STRING"},
                    "items": {
                        "type": "ARRAY",
                        "items": {
                            "type": "OBJECT",
                            "properties": {
                                "name": {"type": "STRING"},
                                "portion": {"type": "STRING"},
                                "carbs_g": {"type": "NUMBER"},
                                "calories": {"type": "NUMBER"},
                                "protein_g": {"type": "NUMBER"},
                                "fat_g": {"type": "NUMBER"},
                            },
                            "required": [
                                "name",
                                "portion",
                                "carbs_g",
                                "calories",
                                "protein_g",
                                "fat_g",
                            ],
                        },
                    },
                    "summary": {"type": "STRING"},
                },
                "required": ["thought_process", "items", "summary"],
            },
        },
    }


# ---------------------------------------------------------------------------
# Response parser
# ---------------------------------------------------------------------------

def _parse_gemini_response(response_text: str) -> dict:
    """
    Parse Gemini's raw JSON response into a clean Flutter-compatible payload.

    The Flutter side (`_parseResponse`) previously did this work.
    Moving it here keeps the Flutter app simpler and ensures consistent
    parsing regardless of which Flutter version calls the backend.
    """
    try:
        response_json = json.loads(response_text)
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=502, detail=f"Invalid JSON from Gemini: {e}")

    candidates = response_json.get("candidates", [])
    if not candidates:
        raise HTTPException(status_code=502, detail="No response from Gemini API.")

    parts = candidates[0].get("content", {}).get("parts", [])
    if not parts:
        raise HTTPException(status_code=502, detail="Empty Gemini response.")

    text = parts[0].get("text", "").strip()

    # Strip any markdown code fences Gemini may add
    if text.startswith("```"):
        first_newline = text.find("\n")
        text = text[first_newline + 1:]
    if text.endswith("```"):
        text = text[:-3].strip()

    try:
        parsed = json.loads(text)
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=502, detail=f"Gemini returned invalid food JSON: {e}")

    raw_items = parsed.get("items", [])

    # Cap at 10 items (mirrors Flutter UI defence)
    raw_items = raw_items[:10]

    items = []
    total_carbs = 0.0
    total_calories = 0.0

    for item in raw_items:
        name = str(item.get("name", ""))[:100]
        portion = str(item.get("portion", ""))[:100]
        carbs_g = float(item.get("carbs_g") or 0)
        calories = float(item.get("calories") or 0)
        protein_g = float(item.get("protein_g") or 0)
        fat_g = float(item.get("fat_g") or 0)

        items.append({
            "name": name,
            "portion": portion,
            "carbs_g": carbs_g,
            "calories": calories,
            "protein_g": protein_g,
            "fat_g": fat_g,
        })
        total_carbs += carbs_g
        total_calories += calories

    return {
        "items": items,
        "total_carbs": total_carbs,
        "total_calories": total_calories,
        "summary": str(parsed.get("summary", "Meal analyzed"))[:200],
    }
