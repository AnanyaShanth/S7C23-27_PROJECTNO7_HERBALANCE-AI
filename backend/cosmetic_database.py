import requests


API_BASE_URL = "https://cosingchecker.com/api/v1"


def find_ingredient(ingredient_name):
    """
    Search the CosIng Checker API for an exact INCI ingredient name.
    """

    if not ingredient_name:
        return None

    ingredient_name = ingredient_name.strip()

    if not ingredient_name:
        return None

    try:
        response = requests.get(
            f"{API_BASE_URL}/ingredients/",
            params={
                "q": ingredient_name,
                "per_page": 50,
            },
            timeout=15,
        )

        response.raise_for_status()

        data = response.json()

        results = data.get("results", [])

        # Prefer an exact INCI match.
        target = ingredient_name.casefold()

        for item in results:
            inci_name = (
                item.get("inci_name") or ""
            ).strip()

            if inci_name.casefold() == target:
                return item

        return None

    except requests.RequestException as error:
        print(
            f"Cosmetic API request failed for "
            f"'{ingredient_name}': {error}"
        )

        return None