import json

from app.routers.food_analysis import _parse_gemini_response


def _wrap(inner: dict) -> str:
    """Wrap an inner food-JSON payload in Gemini's candidates envelope."""
    return json.dumps(
        {"candidates": [{"content": {"parts": [{"text": json.dumps(inner)}]}}]}
    )


def test_parse_gemini_response_includes_fiber_per_item():
    inner = {
        "items": [
            {
                "name": "Lentils",
                "portion": "1 cup",
                "carbs_g": 40.0,
                "fiber_g": 15.0,
                "protein_g": 18.0,
                "fat_g": 1.0,
                "calories": 230.0,
            }
        ],
        "summary": "Lentils",
    }
    result = _parse_gemini_response(_wrap(inner))
    assert result["items"][0]["fiber_g"] == 15.0


def test_parse_gemini_response_defaults_missing_fiber_to_zero():
    inner = {
        "items": [
            {
                "name": "Plain Rice",
                "portion": "1 cup",
                "carbs_g": 45.0,
                "protein_g": 4.0,
                "fat_g": 0.5,
                "calories": 200.0,
            }
        ],
        "summary": "Rice",
    }
    result = _parse_gemini_response(_wrap(inner))
    assert result["items"][0]["fiber_g"] == 0.0
