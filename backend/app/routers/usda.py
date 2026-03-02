"""
DiaMetrics Backend — USDA FoodData Central proxy

GET /api/v1/food/usda-search?query=<food_name>

Queries the USDA FoodData Central API server-side so the USDA_API_KEY
never needs to be embedded in the Flutter APK.

Security note: Only food name strings are received from Flutter.
No patient PII (glucose, medications, user profiles) is involved.
"""
from fastapi import APIRouter, Depends, Query
import httpx

from ..auth import verify_token
from ..config import settings
from ..rate_limiter import usda_limiter

router = APIRouter()

_USDA_BASE = "https://api.nal.usda.gov/fdc/v1/foods/search"
_TIMEOUT = 10.0  # seconds

# USDA FoodData Central nutrient IDs
_CARB_ID = 1005      # Carbohydrate, by difference
_PROTEIN_ID = 1003   # Protein
_FAT_ID = 1004       # Total lipid (fat)
_CALORIE_ID = 1008   # Energy (kcal)


@router.get("/usda-search")
async def usda_search(
    query: str = Query(..., min_length=1, max_length=100, description="Food name to search"),
    token: str = Depends(verify_token),
) -> dict:
    """
    Search USDA FoodData Central for per-100g macro data.

    Returns:
        { "found": true, "carbs": 27.5, "protein": 3.2, "fat": 0.4, "calories": 130.0 }
        or
        { "found": false }
    """
    usda_limiter.check(token)

    params = {
        "query": query,
        "api_key": settings.USDA_API_KEY,
        "dataType": "SR Legacy,Survey (FNDDS)",
        "pageSize": "3",
    }

    try:
        async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
            response = await client.get(_USDA_BASE, params=params)

        if response.status_code != 200:
            return {"found": False}

        data = response.json()
        foods = data.get("foods", [])
        if not foods:
            return {"found": False}

        # Use the first result
        nutrients = foods[0].get("foodNutrients", [])
        carbs = protein = fat = calories = 0.0

        for n in nutrients:
            nid = n.get("nutrientId", 0)
            val = float(n.get("value", 0) or 0)
            if nid == _CARB_ID:
                carbs = val
            elif nid == _PROTEIN_ID:
                protein = val
            elif nid == _FAT_ID:
                fat = val
            elif nid == _CALORIE_ID:
                calories = val

        if carbs == 0 and protein == 0 and fat == 0:
            return {"found": False}

        return {
            "found": True,
            "carbs": min(max(carbs, 0.0), 100.0),
            "protein": min(max(protein, 0.0), 100.0),
            "fat": min(max(fat, 0.0), 100.0),
            "calories": min(max(calories, 0.0), 900.0),
        }

    except (httpx.TimeoutException, httpx.ConnectError):
        # Graceful fail — USDA is optional enrichment
        return {"found": False}
