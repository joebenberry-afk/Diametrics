"""
DiaMetrics Backend — Open Food Facts barcode proxy

GET /api/v1/food/barcode/{barcode}

Proxies Open Food Facts so the Flutter app never calls the third-party
API directly. Parsing logic moved here from Flutter's OpenFoodFactsService.

Security note: Only the barcode string (EAN-13 / UPC-A) is received.
No patient PII is involved.
"""
import re

from fastapi import APIRouter, Depends, Path, HTTPException
import httpx

from ..auth import verify_token
from ..rate_limiter import barcode_limiter

router = APIRouter()

_OFF_BASE = "https://world.openfoodfacts.org/api/v2/product"
_TIMEOUT = 12.0  # seconds


@router.get("/barcode/{barcode}")
async def barcode_lookup(
    barcode: str = Path(..., min_length=8, max_length=14, pattern=r"^\d+$"),
    token: str = Depends(verify_token),
) -> dict:
    """
    Look up a food product by barcode via Open Food Facts.

    Returns:
        { "found": true, "name": "...", "portion": "...",
          "carbs_g": 24.5, "protein_g": 2.6, "fat_g": 0.3,
          "calories": 114.0, "source": "Open Food Facts" }
        or
        { "found": false }
    """
    barcode_limiter.check(token)

    url = f"{_OFF_BASE}/{barcode}.json"

    try:
        async with httpx.AsyncClient(timeout=_TIMEOUT) as client:
            response = await client.get(url)
    except (httpx.TimeoutException, httpx.ConnectError) as e:
        raise HTTPException(status_code=503, detail=f"Open Food Facts unreachable: {e}")

    if response.status_code == 404:
        return {"found": False}

    if response.status_code != 200:
        raise HTTPException(
            status_code=502,
            detail=f"Open Food Facts returned HTTP {response.status_code}",
        )

    data = response.json()
    status_code = data.get("status", 0)
    product = data.get("product")

    if status_code == 0 or product is None:
        return {"found": False}

    result = _parse_product(product)
    if result is None:
        return {"found": False}

    return result


# ---------------------------------------------------------------------------
# Parsing helpers (moved from Flutter's OpenFoodFactsService)
# ---------------------------------------------------------------------------

def _parse_product(product: dict) -> dict | None:
    """Parse Open Food Facts product JSON into a clean nutrition dict."""
    name = (product.get("product_name") or "").strip()
    if not name:
        return None

    serving_size = product.get("serving_size") or "1 serving"
    nutriments = product.get("nutriments") or {}

    # Prefer per-serving values; fall back to per-100g scaled by serving grams
    carbs = _nutriment(nutriments, "carbohydrates")
    protein = _nutriment(nutriments, "proteins")
    fat = _nutriment(nutriments, "fat")
    calories = _nutriment(nutriments, "energy-kcal")

    if carbs == 0 and protein == 0 and fat == 0:
        carbs_100 = _nutriment(nutriments, "carbohydrates_100g")
        protein_100 = _nutriment(nutriments, "proteins_100g")
        fat_100 = _nutriment(nutriments, "fat_100g")
        cal_100 = _nutriment(nutriments, "energy-kcal_100g")
        grams = _parse_serving_grams(serving_size)
        scale = grams / 100.0 if grams > 0 else 1.0
        carbs = carbs_100 * scale
        protein = protein_100 * scale
        fat = fat_100 * scale
        calories = cal_100 * scale

    # Safety clamp (UI defence — mirrors Flutter's original clamping)
    return {
        "found": True,
        "name": name,
        "portion": serving_size,
        "carbs_g": min(max(carbs, 0.0), 500.0),
        "protein_g": min(max(protein, 0.0), 300.0),
        "fat_g": min(max(fat, 0.0), 300.0),
        "calories": min(max(calories, 0.0), 3000.0),
        "source": "Open Food Facts",
    }


def _nutriment(n: dict, key: str) -> float:
    """Extract a nutriment value; try `key`, then `key_serving`."""
    val = n.get(key) or n.get(f"{key}_serving") or 0
    if isinstance(val, (int, float)):
        return float(val)
    if isinstance(val, str):
        try:
            return float(val)
        except ValueError:
            return 0.0
    return 0.0


def _parse_serving_grams(serving: str) -> float:
    """Extract grams from a serving string like '28g' or '1 oz (28g)'."""
    match = re.search(r"(\d+(?:\.\d+)?)\s*g", serving, re.IGNORECASE)
    if match:
        try:
            return float(match.group(1))
        except ValueError:
            pass
    return 0.0
