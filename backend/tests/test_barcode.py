from app.routers.barcode import _parse_product


def test_parse_product_surfaces_fiber_from_per_serving_nutriments():
    product = {
        "product_name": "Whole Wheat Bread",
        "serving_size": "40g",
        "nutriments": {
            "carbohydrates": 18.0,
            "proteins": 4.0,
            "fat": 1.0,
            "energy-kcal": 100.0,
            "fiber": 3.2,
        },
    }
    result = _parse_product(product)
    assert result["fiber_g"] == 3.2


def test_parse_product_scales_fiber_in_per_100g_fallback():
    # No per-serving macros → forces the per-100g fallback path.
    product = {
        "product_name": "Rolled Oats",
        "serving_size": "50g",
        "nutriments": {
            "carbohydrates_100g": 60.0,
            "proteins_100g": 13.0,
            "fat_100g": 7.0,
            "energy-kcal_100g": 380.0,
            "fiber_100g": 10.0,
        },
    }
    result = _parse_product(product)
    assert result["fiber_g"] == 5.0  # 10 g per 100 g x 50 g serving
