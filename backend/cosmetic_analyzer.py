import re
from typing import Dict, List, Tuple


# ============================================================
# HERBALANCE AI
# COSMETIC INGREDIENT KNOWLEDGE BASE
# ============================================================

INGREDIENT_RULES = {

    # --------------------------------------------------------
    # MOISTURIZING / CONDITIONING
    # --------------------------------------------------------

    "water": {
        "aliases": ["aqua"],
        "level": "GENERALLY SUITABLE",
        "function": "Solvent",
        "reason": "Common solvent used in cosmetic formulations.",
        "sensitive_skin": "Generally suitable.",
        "dry_skin": "Generally suitable.",
        "oily_skin": "Generally suitable.",
    },

    "glycerin": {
        "aliases": ["glycerol"],
        "level": "GENERALLY SUITABLE",
        "function": "Humectant",
        "reason": "Common moisturizing ingredient.",
        "sensitive_skin": "Generally suitable.",
        "dry_skin": "Can support hydration.",
        "oily_skin": "Generally suitable.",
    },

    "hyaluronic acid": {
        "aliases": [
            "sodium hyaluronate",
            "hydrolyzed hyaluronic acid",
        ],
        "level": "GENERALLY SUITABLE",
        "function": "Humectant",
        "reason": "Common moisturizing ingredient.",
        "sensitive_skin": "Generally suitable.",
        "dry_skin": "Can support skin hydration.",
        "oily_skin": "Generally suitable.",
    },

    "panthenol": {
        "aliases": [
            "provitamin b5",
            "d panthenol",
            "dl panthenol",
        ],
        "level": "GENERALLY SUITABLE",
        "function": "Skin conditioning",
        "reason": "Used as a skin-conditioning and moisturizing ingredient.",
        "sensitive_skin": "Generally suitable.",
        "dry_skin": "Can support moisturization.",
        "oily_skin": "Generally suitable.",
    },

    "niacinamide": {
        "aliases": ["nicotinamide"],
        "level": "GENERALLY SUITABLE",
        "function": "Skin conditioning",
        "reason": "Commonly used for skin conditioning and barrier support.",
        "sensitive_skin": "Generally suitable for many users.",
        "dry_skin": "Can support the skin barrier.",
        "oily_skin": "Commonly used in products for oily skin.",
    },

    "ceramide": {
        "aliases": [
            "ceramide np",
            "ceramide ap",
            "ceramide eop",
            "ceramide ns",
            "ceramide as",
        ],
        "level": "GENERALLY SUITABLE",
        "function": "Skin conditioning",
        "reason": "Used in skincare formulations for skin conditioning.",
        "sensitive_skin": "Generally suitable.",
        "dry_skin": "Can support the skin barrier.",
        "oily_skin": "Generally suitable.",
    },

    "squalane": {
        "aliases": ["squalene"],
        "level": "GENERALLY SUITABLE",
        "function": "Emollient",
        "reason": "Emollient commonly used to soften and condition skin.",
        "sensitive_skin": "Generally suitable for many users.",
        "dry_skin": "Can provide emollient support.",
        "oily_skin": "May be suitable depending on the formulation.",
    },

    "allantoin": {
        "aliases": [],
        "level": "GENERALLY SUITABLE",
        "function": "Skin conditioning",
        "reason": "Commonly used as a skin-conditioning ingredient.",
        "sensitive_skin": "Generally suitable for many users.",
        "dry_skin": "Can support skin comfort.",
        "oily_skin": "Generally suitable.",
    },


    # --------------------------------------------------------
    # FRAGRANCE
    # --------------------------------------------------------

    "fragrance": {
        "aliases": [
            "parfum",
            "perfume",
        ],
        "level": "CAUTION",
        "function": "Fragrance",
        "reason": "Fragrance ingredients can be a concern for people with fragrance sensitivity.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May be a concern for fragrance-sensitive users.",
        "oily_skin": "Generally depends on individual sensitivity.",
    },

    "parfum": {
        "aliases": [
            "fragrance",
            "perfume",
        ],
        "level": "CAUTION",
        "function": "Fragrance",
        "reason": "Fragrance ingredients can cause sensitivity in some users.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May be a concern for fragrance-sensitive users.",
        "oily_skin": "Generally depends on individual sensitivity.",
    },

    "limonene": {
        "aliases": ["d limonene"],
        "level": "CAUTION",
        "function": "Fragrance component",
        "reason": "A fragrance component that may be relevant for fragrance-sensitive users.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May be a concern for fragrance-sensitive users.",
        "oily_skin": "Depends on individual sensitivity.",
    },

    "linalool": {
        "aliases": [],
        "level": "CAUTION",
        "function": "Fragrance component",
        "reason": "A fragrance component that may be relevant for fragrance-sensitive users.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May be a concern for fragrance-sensitive users.",
        "oily_skin": "Depends on individual sensitivity.",
    },

    "citronellol": {
        "aliases": [],
        "level": "CAUTION",
        "function": "Fragrance component",
        "reason": "A fragrance component that may be relevant for fragrance-sensitive users.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May be a concern for fragrance-sensitive users.",
        "oily_skin": "Depends on individual sensitivity.",
    },

    "eugenol": {
        "aliases": [],
        "level": "CAUTION",
        "function": "Fragrance component",
        "reason": "A fragrance component that may be relevant for fragrance-sensitive users.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May be a concern for fragrance-sensitive users.",
        "oily_skin": "Depends on individual sensitivity.",
    },


    # --------------------------------------------------------
    # ALCOHOLS / SOLVENTS
    # --------------------------------------------------------

    "alcohol denat": {
        "aliases": [
            "denatured alcohol",
            "sd alcohol",
            "sd alcohol 40",
            "ethanol",
            "ethyl alcohol",
        ],
        "level": "CAUTION",
        "function": "Solvent",
        "reason": "May be irritating or drying for some sensitive skin users.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May feel drying for some users.",
        "oily_skin": "May be suitable depending on the formulation.",
    },

    "benzyl alcohol": {
        "aliases": [],
        "level": "CAUTION",
        "function": "Preservative / fragrance component",
        "reason": "Can be a concern for some sensitive users.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "Depends on individual sensitivity.",
        "oily_skin": "Depends on individual sensitivity.",
    },


    # --------------------------------------------------------
    # EXFOLIATING / ACTIVE INGREDIENTS
    # --------------------------------------------------------

    "salicylic acid": {
        "aliases": [
            "beta hydroxy acid",
            "bha",
        ],
        "level": "CAUTION",
        "function": "Exfoliant",
        "reason": "An exfoliating active that may cause irritation for some users.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May be drying or irritating for some users.",
        "oily_skin": "Commonly used in products targeting oily skin.",
    },

    "glycolic acid": {
        "aliases": [
            "alpha hydroxy acid",
            "aha",
        ],
        "level": "CAUTION",
        "function": "AHA",
        "reason": "An exfoliating acid that may irritate sensitive skin.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May be irritating or drying for some users.",
        "oily_skin": "May be useful depending on the formulation.",
    },

    "lactic acid": {
        "aliases": [],
        "level": "CAUTION",
        "function": "AHA",
        "reason": "An exfoliating acid that may irritate sensitive skin.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May require gradual introduction.",
        "oily_skin": "May be suitable depending on the formulation.",
    },

    "retinol": {
        "aliases": [
            "retinal",
            "retinaldehyde",
        ],
        "level": "CAUTION",
        "function": "Vitamin A derivative",
        "reason": "Vitamin A derivatives can cause irritation and require appropriate product use.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May cause dryness or irritation for some users.",
        "oily_skin": "May be used in some skincare routines.",
    },

    "retinyl palmitate": {
        "aliases": [
            "vitamin a palmitate",
        ],
        "level": "CAUTION",
        "function": "Vitamin A derivative",
        "reason": "Vitamin A derivative used in some cosmetic formulations.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "May cause irritation for some users.",
        "oily_skin": "Depends on individual tolerance.",
    },


    # --------------------------------------------------------
    # PRESERVATIVES
    # --------------------------------------------------------

    "methylisothiazolinone": {
        "aliases": [
            "mit",
        ],
        "level": "HIGH CONCERN",
        "function": "Preservative",
        "reason": "Associated with contact allergy concerns.",
        "sensitive_skin": "Requires particular caution.",
        "dry_skin": "Requires consideration of individual sensitivity.",
        "oily_skin": "Requires consideration of individual sensitivity.",
    },

    "methylchloroisothiazolinone": {
        "aliases": [
            "mci",
        ],
        "level": "HIGH CONCERN",
        "function": "Preservative",
        "reason": "Associated with contact allergy concerns.",
        "sensitive_skin": "Requires particular caution.",
        "dry_skin": "Requires consideration of individual sensitivity.",
        "oily_skin": "Requires consideration of individual sensitivity.",
    },

    "formaldehyde": {
        "aliases": [],
        "level": "HIGH CONCERN",
        "function": "Preservative",
        "reason": "Associated with irritation and sensitization concerns.",
        "sensitive_skin": "Requires particular caution.",
        "dry_skin": "Requires particular caution.",
        "oily_skin": "Requires consideration of individual sensitivity.",
    },

    "phenoxyethanol": {
        "aliases": [],
        "level": "CAUTION",
        "function": "Preservative",
        "reason": "Common cosmetic preservative; individual sensitivity should be considered.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "Depends on individual sensitivity.",
        "oily_skin": "Generally depends on individual sensitivity.",
    },


    # --------------------------------------------------------
    # SUNSCREEN / UV FILTERS
    # --------------------------------------------------------

    "titanium dioxide": {
        "aliases": [
            "ci 77891",
        ],
        "level": "GENERALLY SUITABLE",
        "function": "UV filter / Colorant",
        "reason": "Commonly used in cosmetic and sunscreen formulations.",
        "sensitive_skin": "Generally suitable for many users.",
        "dry_skin": "Generally suitable.",
        "oily_skin": "Generally suitable.",
    },

    "zinc oxide": {
        "aliases": [
            "ci 77947",
        ],
        "level": "GENERALLY SUITABLE",
        "function": "UV filter",
        "reason": "Commonly used in sunscreen formulations.",
        "sensitive_skin": "Generally suitable for many users.",
        "dry_skin": "Generally suitable.",
        "oily_skin": "Generally suitable.",
    },

    "avobenzone": {
        "aliases": [
            "butyl methoxydibenzoylmethane",
        ],
        "level": "GENERALLY SUITABLE",
        "function": "UV filter",
        "reason": "UV filter commonly used in sunscreen products.",
        "sensitive_skin": "Individual sensitivity should still be considered.",
        "dry_skin": "Generally suitable.",
        "oily_skin": "Generally suitable.",
    },

    "octocrylene": {
        "aliases": [],
        "level": "CAUTION",
        "function": "UV filter",
        "reason": "UV filter that may be relevant when assessing individual sensitivity.",
        "sensitive_skin": "May warrant additional caution.",
        "dry_skin": "Depends on individual sensitivity.",
        "oily_skin": "Depends on individual sensitivity.",
    },

    "homosalate": {
        "aliases": [],
        "level": "CAUTION",
        "function": "UV filter",
        "reason": "UV filter; product-specific regulatory and formulation context should be considered.",
        "sensitive_skin": "Individual sensitivity should be considered.",
        "dry_skin": "Depends on individual sensitivity.",
        "oily_skin": "Depends on individual sensitivity.",
    },

    "octisalate": {
        "aliases": [
            "ethylhexyl salicylate",
        ],
        "level": "GENERALLY SUITABLE",
        "function": "UV filter",
        "reason": "UV filter commonly used in sunscreen formulations.",
        "sensitive_skin": "Individual sensitivity should still be considered.",
        "dry_skin": "Generally suitable.",
        "oily_skin": "Generally suitable.",
    },

    "octinoxate": {
        "aliases": [
            "ethylhexyl methoxycinnamate",
            "octyl methoxycinnamate",
        ],
        "level": "CAUTION",
        "function": "UV filter",
        "reason": "UV filter used in sunscreen formulations; product-specific context should be considered.",
        "sensitive_skin": "Individual sensitivity should be considered.",
        "dry_skin": "Depends on individual sensitivity.",
        "oily_skin": "Depends on individual sensitivity.",
    },

    "bemotrizinol": {
        "aliases": [
            "bis ethylhexyloxyphenol methoxyphenyl triazine",
        ],
        "level": "GENERALLY SUITABLE",
        "function": "UV filter",
        "reason": "Modern UV filter used in some sunscreen formulations.",
        "sensitive_skin": "Individual sensitivity should still be considered.",
        "dry_skin": "Generally suitable.",
        "oily_skin": "Generally suitable.",
    },

    "diethylamino hydroxybenzoyl hexyl benzoate": {
        "aliases": [
            "uvinal a plus",
        ],
        "level": "GENERALLY SUITABLE",
        "function": "UV filter",
        "reason": "UV filter used in some sunscreen formulations.",
        "sensitive_skin": "Individual sensitivity should still be considered.",
        "dry_skin": "Generally suitable.",
        "oily_skin": "Generally suitable.",
    },
}


# ============================================================
# TEXT NORMALIZATION
# ============================================================
def normalize_text(text: str) -> str:
    """
    Normalize OCR text so that ingredient matching is more reliable.
    """

    if not text:
        return ""

    text = text.lower()

    replacements = {
        "–": "-",
        "—": "-",
        "’": "'",
        "“": '"',
        "”": '"',
        "\n": " ",
        "\r": " ",
        "\t": " ",
    }

    for old, new in replacements.items():
        text = text.replace(old, new)

    # Remove percentages such as 3%, 10.5%, etc.
    text = re.sub(r"\b\d+(?:\.\d+)?\s*%", " ", text)

    # Normalize multiple spaces.
    text = re.sub(r"\s+", " ", text)

    return text.strip()


def normalize_ingredient_name(text: str) -> str:
    """
    Normalize an ingredient name for reliable matching.
    """

    if not text:
        return ""

    text = normalize_text(text)

    # Normalize common OCR variations.
    text = text.replace("-", " ")
    text = text.replace("_", " ")

    # Remove punctuation.
    text = re.sub(r"[^a-z0-9\s]", " ", text)

    # Normalize multiple spaces.
    text = re.sub(r"\s+", " ", text)

    return text.strip()
# ============================================================
# PRODUCT CATEGORY DETECTION
# ============================================================

def detect_product_category(ocr_text: str) -> str:

    text = normalize_text(ocr_text)

    if any(word in text for word in [
        "sunscreen",
        "sun screen",
        "spf",
        "uv protection",
        "sun protection"
    ]):
        return "sunscreen"

    if any(word in text for word in [
        "moisturizer",
        "moisturiser",
        "moisturizing cream",
        "moisturising cream",
        "hydrating cream"
    ]):
        return "moisturizer"

    if any(word in text for word in [
        "cleanser",
        "face wash",
        "facial wash"
    ]):
        return "cleanser"

    if "serum" in text:
        return "serum"

    if any(word in text for word in [
        "foundation",
        "makeup base"
    ]):
        return "foundation"

    if any(word in text for word in [
        "pressed powder",
        "compact powder",
        "face powder"
    ]):
        return "pressed_powder"

    if any(word in text for word in [
        "lipstick",
        "lip balm",
        "lip gloss",
        "lip color",
        "lip colour"
    ]):
        return "lip_product"

    if "toner" in text:
        return "toner"

    if any(word in text for word in [
        "face mask",
        "facial mask"
    ]):
        return "face_mask"

    if any(word in text for word in [
        "eye cream",
        "under eye cream",
        "eye gel"
    ]):
        return "eye_cream"

    if any(word in text for word in [
        "body lotion",
        "body cream"
    ]):
        return "body_lotion"

    if any(word in text for word in [
        "spot treatment",
        "acne treatment"
    ]):
        return "spot_treatment"

    return "unknown"
    # ============================================================
# PERSONALIZED PRODUCT RECOMMENDATIONS
# ============================================================

def generate_product_recommendation(
    product_category: str,
    profile: Dict,
) -> Dict:

    skin_type = str(
        profile.get("skin_type", "unknown")
    ).lower().strip()

    current_condition = profile.get(
        "current_condition",
        {}
    )

    if not isinstance(current_condition, dict):
        current_condition = {}

    skin_problems = current_condition.get(
        "skin_problems",
        []
    )

    if not isinstance(skin_problems, list):
        skin_problems = [str(skin_problems)]

    skin_problems = [
        str(problem).lower().strip()
        for problem in skin_problems
    ]

    recommendations = []
    recommended_features = []
    recommended_ingredients = []
    caution = []

    # --------------------------------------------------------
    # SUNSCREEN
    # --------------------------------------------------------

    if product_category == "sunscreen":

        recommendations.append(
            "Choose a broad-spectrum sunscreen with "
            "SPF 30 or higher."
        )

        recommended_features.extend([
            "Lightweight texture",
            "Broad-spectrum UV protection",
            "SPF 30 or higher",
            "Non-comedogenic formulation",
        ])

        recommended_ingredients.extend([
            "Zinc oxide",
            "Titanium dioxide",
            "Niacinamide",
        ])

        if skin_type == "oily" or "acne" in skin_problems:

            recommendations.append(
                "For oily or acne-prone skin, prefer a "
                "lightweight gel or fluid sunscreen with "
                "a non-greasy finish."
            )

            recommended_features.extend([
                "Gel or fluid texture",
                "Oil-free or non-greasy finish",
                "Non-comedogenic",
            ])

            caution.extend([
                "Very heavy or greasy formulations",
                "Strongly fragranced products"
            ])

        elif skin_type == "dry" or "dryness" in skin_problems:

            recommendations.append(
                "For dry skin, prefer a moisturizing "
                "sunscreen that supports the skin barrier."
            )

            recommended_features.extend([
                "Moisturizing formulation",
                "Barrier-supporting ingredients",
            ])

            recommended_ingredients.extend([
                "Glycerin",
                "Hyaluronic acid",
                "Ceramides",
                "Panthenol",
            ])

        elif (
            "irritation" in skin_problems
            or "redness" in skin_problems
        ):

            recommendations.append(
                "While the skin is irritated, prefer a "
                "gentle sunscreen and avoid unnecessarily "
                "fragranced or irritating formulations."
            )

            recommended_features.extend([
                "Gentle formulation",
                "Minimal fragrance",
            ])

    # --------------------------------------------------------
    # MOISTURIZER
    # --------------------------------------------------------

    elif product_category == "moisturizer":

        recommendations.append(
            "Choose a moisturizer suited to your skin type "
            "and current skin condition."
        )

        if skin_type == "dry" or "dryness" in skin_problems:

            recommendations.append(
                "For dry skin, prioritize barrier-supporting "
                "and hydrating ingredients."
            )

            recommended_ingredients.extend([
                "Glycerin",
                "Hyaluronic acid",
                "Ceramides",
                "Panthenol",
            ])

            recommended_features.extend([
                "Rich or nourishing texture",
                "Barrier-supporting formulation",
            ])

        elif skin_type == "oily" or "acne" in skin_problems:

            recommendations.append(
                "For oily or acne-prone skin, prefer a "
                "lightweight, non-comedogenic moisturizer."
            )

            recommended_features.extend([
                "Lightweight texture",
                "Non-comedogenic",
                "Oil-free or low-grease finish",
            ])

            recommended_ingredients.extend([
                "Niacinamide",
                "Hyaluronic acid",
            ])

        else:

            recommended_features.extend([
                "Lightweight to medium texture",
                "Hydrating formulation",
            ])

    # --------------------------------------------------------
    # CLEANSER
    # --------------------------------------------------------

    elif product_category == "cleanser":

        recommendations.append(
            "Choose a cleanser that removes impurities "
            "without excessively drying the skin."
        )

        if skin_type == "oily" or "acne" in skin_problems:

            recommended_features.extend([
                "Gentle foaming or gel texture",
                "Non-comedogenic formulation",
            ])

            recommended_ingredients.append(
                "Salicylic acid"
            )

        elif skin_type == "dry" or "dryness" in skin_problems:

            recommended_features.extend([
                "Gentle hydrating formulation",
                "Low-irritation formula",
            ])

            recommended_ingredients.extend([
                "Glycerin",
                "Panthenol",
            ])

    # --------------------------------------------------------
    # SERUM
    # --------------------------------------------------------

    elif product_category == "serum":

        if "pigmentation" in skin_problems:

            recommendations.append(
                "For pigmentation concerns, consider a "
                "gentle brightening serum and introduce "
                "active ingredients gradually."
            )

            recommended_ingredients.extend([
                "Niacinamide",
            ])

            recommended_features.append(
                "Gentle brightening formulation"
            )

        elif "irritation" in skin_problems:

            recommendations.append(
                "During irritation, prioritize a simple "
                "barrier-supporting serum and avoid "
                "multiple strong actives."
            )

            recommended_ingredients.extend([
                "Panthenol",
                "Hyaluronic acid",
            ])

        else:

            recommendations.append(
                "Choose serum ingredients based on your "
                "specific skin concern."
            )

    # --------------------------------------------------------
    # PRESSED POWDER
    # --------------------------------------------------------

    elif product_category == "pressed_powder":

        recommendations.append(
            "For regular use, prefer a lightweight "
            "non-comedogenic pressed powder."
        )

        recommended_features.extend([
            "Lightweight formula",
            "Non-comedogenic",
            "Oil-control finish",
        ])

        if (
            "irritation" in skin_problems
            or "redness" in skin_problems
        ):

            caution.append(
                "Strong fragrance or irritating additives"
            )

    # --------------------------------------------------------
    # FOUNDATION
    # --------------------------------------------------------

    elif product_category == "foundation":

        recommendations.append(
            "Choose a foundation that matches your skin "
            "type and is comfortable for regular wear."
        )

        recommended_features.extend([
            "Non-comedogenic formulation",
            "Lightweight texture",
        ])

        if skin_type == "oily":

            recommended_features.append(
                "Oil-control or semi-matte finish"
            )

        elif skin_type == "dry":

            recommended_features.append(
                "Hydrating or natural finish"
            )

    # --------------------------------------------------------
    # UNKNOWN PRODUCT
    # --------------------------------------------------------

    else:

        recommendations.append(
            "Product category could not be confidently "
            "identified. Check the product label before "
            "choosing it."
        )

    # Remove duplicates while preserving order

    recommendations = list(dict.fromkeys(recommendations))
    recommended_features = list(
        dict.fromkeys(recommended_features)
    )
    recommended_ingredients = list(
        dict.fromkeys(recommended_ingredients)
    )
    caution = list(dict.fromkeys(caution))

    return {
        "personalized_product_recommendation": (
            recommendations
        ),
        "recommended_product_features": (
            recommended_features
        ),
        "recommended_ingredients": (
            recommended_ingredients
        ),
        "ingredients_to_be_cautious_about": caution,
    }
# ============================================================
# ACTIVE / INACTIVE SECTION DETECTION
# ============================================================

def extract_sections(ocr_text: str) -> Tuple[str, str]:
    """
    Attempts to separate Active Ingredients and Inactive Ingredients.

    If the product does not clearly contain these headings,
    the entire OCR text is returned as general ingredient text.
    """

    text = normalize_text(ocr_text)

    active_text = ""
    inactive_text = ""

    active_match = re.search(
        r"active\s+ingredients?(.*?)(?:inactive\s+ingredients?|other\s+ingredients?|ingredients?)",
        text,
        flags=re.IGNORECASE,
    )

    inactive_match = re.search(
        r"(?:inactive\s+ingredients?|other\s+ingredients?|ingredients?)(.*)",
        text,
        flags=re.IGNORECASE,
    )

    if active_match:
        active_text = active_match.group(1).strip()

    if inactive_match:
        inactive_text = inactive_match.group(1).strip()

    return active_text, inactive_text


# ============================================================
# INGREDIENT MATCHING
# ============================================================

def ingredient_occurs_in_text(
    ingredient_name: str,
    aliases: List[str],
    text: str,
) -> bool:

    normalized = normalize_ingredient_name(text)

    candidates = [
        ingredient_name,
        *aliases,
    ]

    for candidate in candidates:

        candidate_normalized = normalize_ingredient_name(candidate)

        if not candidate_normalized:
            continue

        # Word-boundary matching prevents accidental partial matches.
        pattern = r"(?<![a-z0-9])" + re.escape(candidate_normalized) + r"(?![a-z0-9])"

        if re.search(pattern, normalized):
            return True

    return False


def find_known_ingredients(text: str) -> List[Dict]:
    """
    Finds ingredients from the local knowledge base.
    """

    if not text:
        return []

    found = []

    for canonical_name, rule in INGREDIENT_RULES.items():

        if ingredient_occurs_in_text(
            canonical_name,
            rule.get("aliases", []),
            text,
        ):

            found.append({
                "name": canonical_name.title(),
                "canonical_name": canonical_name,
                "level": rule["level"],
                "function": rule["function"],
                "reason": rule["reason"],
            })

    # Remove duplicates.
    unique = {}
    for ingredient in found:
        unique[ingredient["canonical_name"]] = ingredient

    return list(unique.values())


# ============================================================
# UNKNOWN INGREDIENT DETECTION
# ============================================================

def extract_possible_ingredient_names(text: str) -> List[str]:
    """
    Attempts to extract possible ingredient names from an ingredient
    section.

    This is intentionally conservative. It does not claim that every
    OCR token is an ingredient.
    """

    if not text:
        return []

    text = normalize_text(text)

    # Common separators in ingredient lists.
    text = text.replace(";", ",")
    text = text.replace("|", ",")
    text = text.replace("•", ",")
    text = text.replace("·", ",")

    pieces = re.split(r",", text)

    possible = []

    for piece in pieces:

        piece = piece.strip()

        if not piece:
            continue

        # Remove percentages.
        piece = re.sub(
            r"\b\d+(?:\.\d+)?\s*%",
            "",
            piece,
        )

        # Remove common dosage / concentration patterns.
        piece = re.sub(
            r"\b\d+(?:\.\d+)?\s*(mg|g|ml|oz)\b",
            "",
            piece,
            flags=re.IGNORECASE,
        )

        piece = re.sub(r"\s+", " ", piece).strip()

        # Ignore very short fragments.
        if len(piece) < 3:
            continue

        # Ignore obvious non-ingredient text.
        ignored_phrases = [
            "active ingredients",
            "inactive ingredients",
            "drug facts",
            "directions",
            "warning",
            "warnings",
            "uses",
            "purpose",
            "keep out of reach",
            "net wt",
            "net weight",
            "distributed by",
            "made in",
        ]

        if any(
            phrase in piece.lower()
            for phrase in ignored_phrases
        ):
            continue

        # Keep text that looks like an ingredient name.
        if re.search(r"[a-zA-Z]", piece):
            possible.append(piece)

    return list(dict.fromkeys(possible))


def find_unknown_ingredients(
    text: str,
    known_ingredients: List[Dict],
) -> List[str]:

    possible = extract_possible_ingredient_names(text)

    known_names = set()

    for ingredient in known_ingredients:

        known_names.add(
            normalize_ingredient_name(
                ingredient["name"]
            )
        )

        rule = INGREDIENT_RULES.get(
            ingredient["canonical_name"],
            {},
        )

        for alias in rule.get("aliases", []):
            known_names.add(
                normalize_ingredient_name(alias)
            )

    unknown = []

    for item in possible:

        normalized_item = normalize_ingredient_name(item)

        if not normalized_item:
            continue

        if normalized_item in known_names:
            continue

        # Don't treat obvious label instructions as ingredients.
        if len(normalized_item.split()) > 12:
            continue

        unknown.append(item)

    return list(dict.fromkeys(unknown))


# ============================================================
# ALLERGY / SENSITIVITY NORMALIZATION
# ============================================================

def normalize_profile_list(value) -> List[str]:
    """
    Converts profile values such as:
        ["Fragrance", "Niacinamide"]

    or:
        "Fragrance, Niacinamide"

    into a normalized list.
    """

    if value is None:
        return []

    if isinstance(value, list):
        values = value

    else:
        values = re.split(
            r"[,;/|]",
            str(value),
        )

    result = []

    for value in values:

        normalized = normalize_ingredient_name(
            str(value)
        )

        if normalized:
            result.append(normalized)

    return list(dict.fromkeys(result))


def ingredient_matches_profile_term(
    ingredient: Dict,
    profile_terms: List[str],
) -> bool:

    if not profile_terms:
        return False

    canonical = ingredient["canonical_name"]

    rule = INGREDIENT_RULES.get(
        canonical,
        {},
    )

    candidates = [
        canonical,
        ingredient["name"],
        *rule.get("aliases", []),
    ]

    normalized_candidates = [
        normalize_ingredient_name(c)
        for c in candidates
    ]

    for profile_term in profile_terms:

        normalized_profile_term = normalize_ingredient_name(
            profile_term
        )

        for candidate in normalized_candidates:

            if not candidate:
                continue

            if (
                candidate == normalized_profile_term
                or candidate in normalized_profile_term
                or normalized_profile_term in candidate
            ):
                return True

    return False

# ============================================================
# PERSONALIZED ANALYSIS
# ============================================================

def analyze_personalization(
    ingredients: List[Dict],
    profile: Dict,
) -> Dict:

    skin_type = str(
        profile.get("skin_type", "unknown")
    ).strip().lower()

    allergies = normalize_profile_list(
        profile.get("allergies", "")
    )

    health_conditions = normalize_profile_list(
        profile.get("health_conditions", "")
    )

    # --------------------------------------------------------
    # CURRENT CONDITION
    # --------------------------------------------------------

    current_condition = profile.get(
        "current_condition",
        {}
    )

    if not isinstance(current_condition, dict):
        current_condition = {}

    current_skin_problems = normalize_profile_list(
        current_condition.get(
            "skin_problems",
            []
        )
    )

    allergic_reaction = str(
        current_condition.get(
            "allergic_reaction",
            ""
        )
    ).strip().lower()

    current_treatments = str(
        current_condition.get(
            "current_treatments",
            ""
        )
    ).strip().lower()

    concerns = []
    recommendations = []
    ingredient_findings = []

    # --------------------------------------------------------
    # INGREDIENT-LEVEL PERSONALIZATION
    # --------------------------------------------------------

    for ingredient in ingredients:

        name = ingredient["name"]
        canonical = ingredient["canonical_name"]

        personal_flags = []

        # ----------------------------------------------------
        # ALLERGY / SENSITIVITY
        # ----------------------------------------------------

        if ingredient_matches_profile_term(
            ingredient,
            allergies,
        ):

            concerns.append(
                f"{name} matches an allergy or sensitivity "
                f"recorded in your profile."
            )

            personal_flags.append(
                "Matches recorded allergy or sensitivity"
            )

            recommendations.append(
                f"Avoid or verify {name} if it is a confirmed "
                f"allergen for you."
            )

        # ----------------------------------------------------
        # SENSITIVE SKIN
        # ----------------------------------------------------

        if skin_type == "sensitive":

            if ingredient["level"] in [
                "CAUTION",
                "HIGH CONCERN",
            ]:

                concerns.append(
                    f"{name} may require additional caution "
                    f"for sensitive skin."
                )

                personal_flags.append(
                    "Sensitive-skin caution"
                )

            if canonical in [
                "fragrance",
                "parfum",
                "limonene",
                "linalool",
                "citronellol",
                "eugenol",
            ]:

                recommendations.append(
                    "Because you have sensitive skin, "
                    "consider fragrance-free products if "
                    "you experience fragrance sensitivity."
                )

        # ----------------------------------------------------
        # DRY SKIN
        # ----------------------------------------------------

        if skin_type == "dry":

            if canonical == "alcohol denat":

                concerns.append(
                    "Alcohol Denat may feel drying for some "
                    "users with dry skin."
                )

                personal_flags.append(
                    "Possible dryness concern"
                )

                recommendations.append(
                    "Consider a more hydrating formulation if "
                    "this product leaves your skin feeling dry."
                )

            if canonical in [
                "glycolic acid",
                "lactic acid",
                "salicylic acid",
                "retinol",
                "retinyl palmitate",
            ]:

                recommendations.append(
                    f"{name} may contribute to dryness or "
                    f"irritation for some users, so monitor "
                    f"your skin closely."
                )

                personal_flags.append(
                    "Possible dryness or irritation"
                )

        # ----------------------------------------------------
        # OILY SKIN
        # ----------------------------------------------------

        if skin_type == "oily":

            if canonical == "salicylic acid":

                recommendations.append(
                    "Salicylic acid is commonly used in "
                    "products targeting oily or acne-prone "
                    "skin, but individual tolerance should "
                    "still be considered."
                )

                personal_flags.append(
                    "Potentially relevant for oily skin"
                )

        # ----------------------------------------------------
        # CURRENT ACNE
        # ----------------------------------------------------

        if "acne" in current_skin_problems:

            if canonical == "salicylic acid":

                recommendations.append(
                    "Salicylic acid is commonly used in "
                    "products targeting acne-prone skin."
                )

                personal_flags.append(
                    "Relevant to current acne"
                )

            if ingredient["level"] in [
                "CAUTION",
                "HIGH CONCERN",
            ]:

                personal_flags.append(
                    "Current acne may make irritation "
                    "more important to monitor"
                )

        # ----------------------------------------------------
        # CURRENT IRRITATION
        # ----------------------------------------------------

        if "irritation" in current_skin_problems:

            if ingredient["level"] in [
                "CAUTION",
                "HIGH CONCERN",
            ]:

                concerns.append(
                    f"{name} may require additional caution "
                    f"because you currently report skin "
                    f"irritation."
                )

                personal_flags.append(
                    "Current skin irritation"
                )

        # ----------------------------------------------------
        # CURRENT REDNESS
        # ----------------------------------------------------

        if "redness" in current_skin_problems:

            if ingredient["level"] in [
                "CAUTION",
                "HIGH CONCERN",
            ]:

                concerns.append(
                    f"{name} may require additional caution "
                    f"while you are experiencing skin redness."
                )

                personal_flags.append(
                    "Current redness"
                )

        # ----------------------------------------------------
        # CURRENT DRYNESS
        # ----------------------------------------------------

        if "dryness" in current_skin_problems:

            if canonical in [
                "alcohol denat",
                "glycolic acid",
                "lactic acid",
                "salicylic acid",
                "retinol",
                "retinyl palmitate",
            ]:

                recommendations.append(
                    f"{name} may contribute to dryness or "
                    f"irritation for some users, so monitor "
                    f"your skin closely."
                )

                personal_flags.append(
                    "Current dryness"
                )

        # ----------------------------------------------------
        # CURRENT PIGMENTATION
        # ----------------------------------------------------

        if "pigmentation" in current_skin_problems:

            if canonical == "niacinamide":

                recommendations.append(
                    "Niacinamide is commonly used in skincare "
                    "formulations targeting uneven skin tone "
                    "and pigmentation."
                )

                personal_flags.append(
                    "Relevant to pigmentation concern"
                )

        # ----------------------------------------------------
        # CURRENT ALLERGIC / UNUSUAL REACTION
        # ----------------------------------------------------

        if allergic_reaction in [
            "yes",
            "true",
        ]:

            if ingredient["level"] in [
                "CAUTION",
                "HIGH CONCERN",
            ]:

                concerns.append(
                    f"{name} may warrant additional caution "
                    f"because you currently report an allergic "
                    f"or unusual skin reaction."
                )

                personal_flags.append(
                    "Current allergic or unusual reaction"
                )

        # ----------------------------------------------------
        # CURRENT SKIN TREATMENT
        # ----------------------------------------------------

        if current_treatments in [
            "yes",
            "true",
        ]:

            if canonical in [
                "salicylic acid",
                "glycolic acid",
                "lactic acid",
                "retinol",
                "retinyl palmitate",
            ]:

                recommendations.append(
                    f"Because you are currently using a skin "
                    f"treatment, introduce {name} carefully "
                    f"and consider possible irritation from "
                    f"combining active ingredients."
                )

                personal_flags.append(
                    "Currently using a skin treatment"
                )

        # ----------------------------------------------------
        # GENERAL INGREDIENT FINDING
        # ----------------------------------------------------

        ingredient_findings.append({

            "name": name,

            "canonical_name": canonical,

            "level": ingredient["level"],

            "function": ingredient["function"],

            "reason": ingredient["reason"],

            "personal_flags": list(
                dict.fromkeys(personal_flags)
            ),

        })

    # --------------------------------------------------------
    # HEALTH PROFILE
    # --------------------------------------------------------

    if health_conditions:

        recommendations.append(
            "Your recorded health information was considered "
            "as profile context. A medical condition alone "
            "does not automatically make a cosmetic ingredient "
            "unsafe."
        )

    # --------------------------------------------------------
    # PCOS
    # --------------------------------------------------------

    pcos_value = str(
        profile.get("pcos", "")
    ).strip().lower()

    if pcos_value in [
        "yes",
        "true",
        "pcos",
    ]:

        recommendations.append(
            "PCOS is included as part of your health profile, "
            "but the analyzer does not classify cosmetic "
            "ingredients as unsafe based on PCOS alone."
        )

    # --------------------------------------------------------
    # IRREGULAR PERIODS
    # --------------------------------------------------------

    irregular_periods = str(
        profile.get("irregular_periods", "")
    ).strip().lower()

    if irregular_periods in [
        "yes",
        "true",
    ]:

        recommendations.append(
            "Menstrual health information is retained as "
            "profile context and is not used to make "
            "unsupported cosmetic ingredient safety claims."
        )

    # --------------------------------------------------------
    # CURRENT CONDITION SUMMARY
    # --------------------------------------------------------

    if current_skin_problems:

        recommendations.append(
            "Your current skin concerns were considered "
            "along with your saved profile during this "
            "screening."
        )

    # --------------------------------------------------------
    # FINAL RESULT
    # --------------------------------------------------------

    return {

        "concerns": list(
            dict.fromkeys(concerns)
        ),

        "recommendations": list(
            dict.fromkeys(recommendations)
        ),

        "ingredient_findings": ingredient_findings,

        "current_condition_used": {
            "skin_problems": current_skin_problems,
            "allergic_reaction": allergic_reaction,
            "current_treatments": current_treatments,
        },
    }

 # ============================================================
# OVERALL STATUS
# ============================================================

def calculate_overall_status(
    ingredients: List[Dict],
    personalized_concerns: List[str],
) -> str:

    has_high_concern = any(
        ingredient.get("level") == "HIGH CONCERN"
        for ingredient in ingredients
    )

    if has_high_concern:
        return "HIGH CONCERN"

    has_caution = any(
        ingredient.get("level") == "CAUTION"
        for ingredient in ingredients
    )

    if has_caution or personalized_concerns:
        return "CAUTION"

    if ingredients:
        return "GENERALLY SUITABLE"

    return "UNKNOWN"
# ============================================================
# COMPATIBILITY SCORE
# ============================================================

def calculate_compatibility_score(
    ingredients: List[Dict],
    personalized_concerns: List[str],
    unknown_ingredients: List[str],
    current_condition: Dict,
) -> Dict:

    score = 100

    # --------------------------------------------------------
    # INGREDIENT-LEVEL DEDUCTIONS
    # --------------------------------------------------------

    for ingredient in ingredients:

        level = ingredient.get(
            "level",
            "GENERALLY SUITABLE"
        )

        if level == "CAUTION":
            score -= 8

        elif level == "HIGH CONCERN":
            score -= 25

    # --------------------------------------------------------
    # PERSONALIZED CONCERNS
    # --------------------------------------------------------

    score -= min(
        len(personalized_concerns) * 5,
        25
    )

    # --------------------------------------------------------
    # UNKNOWN INGREDIENTS
    # --------------------------------------------------------

    score -= min(
        len(unknown_ingredients) * 2,
        10
    )

    # --------------------------------------------------------
    # CURRENT ALLERGIC REACTION
    # --------------------------------------------------------

    if isinstance(current_condition, dict):

        allergic_reaction = str(
            current_condition.get(
                "allergic_reaction",
                ""
            )
        ).strip().lower()

        if allergic_reaction in [
            "yes",
            "true",
        ]:

            score -= 10

    # --------------------------------------------------------
    # KEEP SCORE WITHIN RANGE
    # --------------------------------------------------------

    score = max(
        0,
        min(100, score)
    )

    # --------------------------------------------------------
    # SCORE LABEL
    # --------------------------------------------------------

    if score >= 85:

        label = "Generally Suitable"

    elif score >= 65:

        label = "Use With Caution"

    elif score >= 40:

        label = "Higher Concern"

    else:

        label = "Avoid / Seek Professional Advice"

    return {

        "score": score,

        "label": label,

        "is_medical_probability": False,

        "note": (
            "This is a heuristic compatibility screening score "
            "based on detected ingredients and the information "
            "provided. It is not a medical probability or a "
            "guarantee of product safety."
        ),
    }


# ============================================================
# SUMMARY GENERATION
# ============================================================

def generate_summary(
    status: str,
    ingredients: List[Dict],
    unknown_ingredients: List[str],
) -> str:

    if status == "HIGH CONCERN":

        summary = (
            "One or more recognized ingredients have been "
            "flagged for a higher level of concern based on "
            "the current ingredient knowledge base."
        )

    elif status == "CAUTION":

        summary = (
            "Some recognized ingredients may require additional "
            "consideration based on their properties, your skin "
            "profile, or recorded sensitivities."
        )

    elif status == "GENERALLY SUITABLE":

        summary = (
            "The recognized ingredients do not currently show "
            "a major concern in the available knowledge base "
            "for the profile information provided."
        )

    else:

        summary = (
            "The ingredient list could not be interpreted "
            "reliably."
        )

    if unknown_ingredients:

        summary += (
            f" {len(unknown_ingredients)} ingredient or text "
            "entry could not be confidently identified and "
            "should be manually verified."
        )

    return summary


# ============================================================
# MAIN ANALYSIS FUNCTION
# ============================================================

def analyze_cosmetic(
    ocr_text: str,
    profile: Dict,
) -> Dict:
    if not ocr_text or not ocr_text.strip():

        return {
            "success": False,
            "overall_status": "UNKNOWN",
            "summary": (
                "No readable ingredient text was detected "
                "from the uploaded image."
            ),
            "ocr_text": "",
            "active_ingredients": [],
            "inactive_ingredients": [],
            "ingredients": [],
            "unknown_ingredients": [],
            "personalized_concerns": [],
            "recommendations": [
                "Take the photo in good lighting.",
                "Keep the ingredient label in focus.",
                "Move closer so the ingredient text is readable.",
                "Include the complete ingredient list.",
            ],
            "profile_used": {
                "skin_type": profile.get(
                    "skin_type",
                    "unknown",
                ),
                "allergies": profile.get(
                    "allergies",
                    "",
                ),
                "pcos": profile.get(
                    "pcos",
                    "Not sure",
                ),
            },
        }

    # Detect the type of cosmetic product
    ocr_text = ocr_text.strip()

    product_category = detect_product_category(
        ocr_text
    )

    print(
        "Detected product category:",
        product_category
    )
    
    # --------------------------------------------------------
    # EXTRACT ACTIVE / INACTIVE SECTIONS
    # --------------------------------------------------------

    active_text, inactive_text = extract_sections(
        ocr_text
    )

    if not active_text and not inactive_text:

        general_ingredient_text = ocr_text

    else:

        general_ingredient_text = (
            f"{active_text} {inactive_text}"
        )

    # --------------------------------------------------------
    # FIND KNOWN INGREDIENTS
    # --------------------------------------------------------

    all_known = find_known_ingredients(
        general_ingredient_text
    )

    active_ingredients = find_known_ingredients(
        active_text
    )

    inactive_ingredients = find_known_ingredients(
        inactive_text
    )

    # --------------------------------------------------------
    # REMOVE DUPLICATES
    # --------------------------------------------------------

    unique_all = {}

    for ingredient in all_known:

        unique_all[
            ingredient["canonical_name"]
        ] = ingredient

    all_known = list(
        unique_all.values()
    )

    # --------------------------------------------------------
    # UNKNOWN INGREDIENTS
    # --------------------------------------------------------

    unknown_ingredients = find_unknown_ingredients(
        general_ingredient_text,
        all_known,
    )

    # --------------------------------------------------------
    # PERSONALIZATION
    # --------------------------------------------------------

    personalization = analyze_personalization(
        all_known,
        profile,
    )

    # --------------------------------------------------------
    # OVERALL STATUS
    # --------------------------------------------------------

    status = calculate_overall_status(
        all_known,
        personalization["concerns"],
    )

    # --------------------------------------------------------
    # COMPATIBILITY SCORE
    # --------------------------------------------------------

    current_condition = profile.get(
        "current_condition",
        {}
    )

    if not isinstance(current_condition, dict):

        current_condition = {}

    compatibility = calculate_compatibility_score(
        all_known,
        personalization["concerns"],
        unknown_ingredients,
        current_condition,
    )

    # --------------------------------------------------------
    # SUMMARY
    # --------------------------------------------------------

    summary = generate_summary(
        status,
        all_known,
        unknown_ingredients,
    )

    # --------------------------------------------------------
    # RECOMMENDATIONS
    # --------------------------------------------------------

    recommendations = personalization[
        "recommendations"
    ]

    if not recommendations:

        recommendations = [
            "Review the complete ingredient list before "
            "purchasing or using the product.",
            "If you have a known allergy or experience "
            "irritation, check the product label carefully.",
        ]

    if unknown_ingredients:

        recommendations.append(
            "Manually verify the unidentified ingredients "
            "before relying on this analysis."
        )

         # --------------------------------------------------------
    # PERSONALIZED PRODUCT RECOMMENDATION
    # --------------------------------------------------------

    product_recommendation = generate_product_recommendation(
        product_category,
        profile,
    )
        # Add personalized product recommendations
    # to the main recommendations shown to the user.

    recommendations.extend(
        product_recommendation[
            "personalized_product_recommendation"
        ]
    )

    for feature in product_recommendation[
        "recommended_product_features"
    ]:
        recommendations.append(
            f"Look for: {feature}."
        )

    recommendations = list(
        dict.fromkeys(
            recommendations
        )
    )
    # --------------------------------------------------------
    # PROFILE SUMMARY
    # --------------------------------------------------------

    profile_used = {

        "skin_type": profile.get(
            "skin_type",
            "unknown",
        ),

        "allergies": profile.get(
            "allergies",
            "",
        ),

        "pcos": profile.get(
            "pcos",
            "Not sure",
        ),

        "irregular_periods": profile.get(
            "irregular_periods",
            "Not specified",
        ),

        "health_conditions": profile.get(
            "health_conditions",
            "",
        ),
    }

    # --------------------------------------------------------
    # FINAL RESPONSE
    # --------------------------------------------------------
    return {

        "success": True,

        "product_category": product_category,

        "personalized_product_recommendation":
            product_recommendation[
                "personalized_product_recommendation"
            ],

        "recommended_product_features":
            product_recommendation[
                "recommended_product_features"
            ],

        "recommended_ingredients":
            product_recommendation[
                "recommended_ingredients"
            ],

        "ingredients_to_be_cautious_about":
            product_recommendation[
                "ingredients_to_be_cautious_about"
            ],

        "overall_status": status,

        "compatibility_score": compatibility["score"],

        "compatibility_label": compatibility["label"],

        "compatibility_note": compatibility["note"],

        "summary": summary,

        "ocr_text": ocr_text,

        "active_ingredients": active_ingredients,

        "inactive_ingredients": inactive_ingredients,

        "ingredients": all_known,

        "unknown_ingredients": unknown_ingredients,

        "ingredients_analyzed": len(all_known),

        "potential_concerns": len(
            personalization["concerns"]
        ),

        "personalized_concerns":
            personalization["concerns"],

        "ingredient_findings":
            personalization["ingredient_findings"],

        "recommendations":
            list(
                dict.fromkeys(
                    recommendations
                )
            ),

        "profile_used": profile_used,

        "current_condition_used":
            personalization[
                "current_condition_used"
            ],

        "disclaimer": (
            "This analysis is an informational screening tool "
            "and is not a medical diagnosis or a guarantee of "
            "product safety. Ingredient effects can depend on "
            "the formulation, concentration, intended use, "
            "and individual sensitivity."
        ),
    }