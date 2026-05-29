from app.routers.usda import _extract_macros


def test_extract_macros_maps_all_nutrient_ids_including_fiber():
    nutrients = [
        {"nutrientId": 1005, "value": 27.5},   # carbs
        {"nutrientId": 1003, "value": 3.2},    # protein
        {"nutrientId": 1004, "value": 0.4},    # fat
        {"nutrientId": 1008, "value": 130.0},  # calories
        {"nutrientId": 1079, "value": 1.8},    # dietary fiber
    ]
    assert _extract_macros(nutrients) == {
        "carbs": 27.5,
        "protein": 3.2,
        "fat": 0.4,
        "calories": 130.0,
        "fiber": 1.8,
    }


def test_extract_macros_defaults_fiber_to_zero_when_absent():
    nutrients = [
        {"nutrientId": 1005, "value": 50.0},
        {"nutrientId": 1003, "value": 2.0},
        {"nutrientId": 1004, "value": 1.0},
        {"nutrientId": 1008, "value": 210.0},
    ]
    assert _extract_macros(nutrients)["fiber"] == 0.0
