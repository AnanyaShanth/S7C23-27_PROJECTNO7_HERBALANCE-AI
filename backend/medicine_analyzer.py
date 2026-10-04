

from typing import Dict, List
import re
import httpx


# ============================================================
# TEXT NORMALIZATION
# ============================================================

def normalize_medicine_text(text: str) -> str:
    if not text:
        return ""

    text = text.lower()

    replacements = {
        "–": "-",
        "—": "-",
        "\n": " ",
        "\r": " ",
        "\t": " ",
    }

    for old, new in replacements.items():
        text = text.replace(old, new)

    text = re.sub(r"[^a-z0-9.%+\-/ ]+", " ", text)
    text = re.sub(r"\s+", " ", text)

    return text.strip()


def normalize_name(text: str) -> str:
    if not text:
        return ""

    text = text.lower()
    text = re.sub(r"[^a-z0-9]+", " ", text)
    text = re.sub(r"\s+", " ", text)

    return text.strip()


# ============================================================
# RXNORM IDENTIFICATION
# ============================================================

async def lookup_rxnorm(search_text: str) -> Dict:
    """
    Identify a medicine using the official RxNorm API.

    Only accepts a match when the returned confidence score
    is sufficiently high.
    """

    search_text = search_text.strip()

    if not search_text:
        return {
            "identified": False,
            "source": "RxNorm",
        }

    try:

        url = (
            "https://rxnav.nlm.nih.gov/REST/"
            "approximateTerm.json"
        )

        params = {
            "term": search_text,
            "maxEntries": 5,
            "option": 1,
        }

        async with httpx.AsyncClient(timeout=10.0) as client:

            response = await client.get(
                url,
                params=params,
            )

        if response.status_code != 200:

            print(
                "RxNorm HTTP status:",
                response.status_code,
            )

            return {
                "identified": False,
                "source": "RxNorm",
            }

        data = response.json()

        candidates = (
            data
            .get("approximateGroup", {})
            .get("candidate", [])
        )

        if not candidates:

            return {
                "identified": False,
                "source": "RxNorm",
            }

        normalized_search = normalize_name(
            search_text
        )

        # Examine candidates rather than blindly
        # accepting the first result.
        for candidate in candidates:

            rxcui = candidate.get("rxcui")
            name = candidate.get("name")
            score_raw = candidate.get("score")

            if not rxcui or not name:
                continue

            try:
                score = float(score_raw)
            except Exception:
                score = 0.0

            normalized_name = normalize_name(
                name
            )

            # Strong match:
            # exact normalized name OR high score.
            exact_match = (
                normalized_search == normalized_name
            )

            if score < 90 and not exact_match:
                continue

            print(
                "RxNorm match:",
                name,
            )

            print(
                "RxNorm RxCUI:",
                rxcui,
            )

            print(
                "RxNorm score:",
                score,
            )

            return {
                "identified": True,
                "source": "RxNorm",
                "rxcui": str(rxcui),
                "name": name,
                "match_score": score,
            }

        return {
            "identified": False,
            "source": "RxNorm",
        }

    except Exception as e:

        print(
            "RxNorm lookup error:",
            e,
        )

        return {
            "identified": False,
            "source": "RxNorm",
        }


        # ============================================================
# PUBCHEM MEDICINE IDENTIFICATION
# ============================================================

async def lookup_pubchem(search_text: str) -> Dict:
    """
    Identify medicines/brands using PubChem's public database.
    Useful for brand names that may not be directly recognized
    by RxNorm, including some non-US medicine brands.
    """

    if not search_text:
        return {
            "identified": False,
            "source": "PubChem",
        }

    try:
        encoded_name = search_text.strip().replace(" ", "%20")

        url = (
            "https://pubchem.ncbi.nlm.nih.gov/rest/pug/"
            f"compound/name/{encoded_name}/property/"
            "Title,CanonicalSMILES,IsomericSMILES/JSON"
        )

        async with httpx.AsyncClient(timeout=10.0) as client:
            response = await client.get(url)

        if response.status_code != 200:
            return {
                "identified": False,
                "source": "PubChem",
            }

        data = response.json()

        properties = (
            data
            .get("PropertyTable", {})
            .get("Properties", [])
        )

        if not properties:
            return {
                "identified": False,
                "source": "PubChem",
            }

        record = properties[0]

        title = record.get("Title")

        if not title:
            return {
                "identified": False,
                "source": "PubChem",
            }

        print("PubChem match:", title)

        return {
            "identified": True,
            "source": "PubChem",
            "name": title,
            "cid": str(record.get("CID", "")),
        }

    except Exception as e:

        print("PubChem lookup error:", e)

        return {
            "identified": False,
            "source": "PubChem",
        }


# ============================================================
# OPENFDA DRUG LABEL LOOKUP
# ============================================================

def clean_label_field(value) -> List[str]:

    if not value:
        return []

    if isinstance(value, list):

        cleaned = []

        for item in value:

            if isinstance(item, str):

                item = item.strip()

                if item:
                    cleaned.append(item)

        return cleaned

    if isinstance(value, str):

        value = value.strip()

        return [value] if value else []

    return []


async def lookup_openfda(
    medicine_name: str,
    rxcui: str = "",
) -> Dict:
    """
    Retrieve drug-label information from openFDA.

    The returned label can contain:
    - active ingredients
    - indications and usage
    - adverse reactions
    - contraindications
    - warnings
    - precautions
    - drug interactions
    """

    if not medicine_name:
        return {
            "found": False,
            "source": "openFDA",
        }

    queries = []

    # Search by standardized medicine name.
    queries.append(
        f'openfda.generic_name:"{medicine_name}"'
    )

    # Also try brand name.
    queries.append(
        f'openfda.brand_name:"{medicine_name}"'
    )

    # Try the plain substance/name as a fallback.
    queries.append(
        f'active_ingredient:"{medicine_name}"'
    )

    try:

        async with httpx.AsyncClient(
            timeout=12.0
        ) as client:

            for query in queries:

                try:

                    response = await client.get(
                        "https://api.fda.gov/drug/label.json",
                        params={
                            "search": query,
                            "limit": 1,
                        },
                    )

                    if response.status_code != 200:
                        continue

                    data = response.json()

                    results = data.get(
                        "results",
                        [],
                    )

                    if not results:
                        continue

                    label = results[0]

                    print(
                        "openFDA label found for:",
                        medicine_name,
                    )

                    return {
                        "found": True,
                        "source": "openFDA",
                        "label": label,
                    }

                except Exception as query_error:

                    print(
                        "openFDA query error:",
                        query_error,
                    )

        return {
            "found": False,
            "source": "openFDA",
        }

    except Exception as e:

        print(
            "openFDA connection error:",
            e,
        )

        return {
            "found": False,
            "source": "openFDA",
        }
# ============================================================
# BUILD MEDICINE INFORMATION
# ============================================================

def build_medicine_information(
    rx_result: Dict,
    fda_result: Dict,
) -> Dict:

    medicine_name = rx_result.get(
        "name"
    )

    label = fda_result.get(
        "label",
        {}
    )

    common_uses = clean_label_field(
        label.get(
            "indications_and_usage"
        )
    )

    if not common_uses:

        common_uses = clean_label_field(
            label.get(
                "purpose"
            )
        )

    side_effects = clean_label_field(
        label.get(
            "adverse_reactions"
        )
    )

    contraindications = clean_label_field(
        label.get(
            "contraindications"
        )
    )

    warnings = clean_label_field(
        label.get(
            "warnings"
        )
    )

    precautions = clean_label_field(
        label.get(
            "general_precautions"
        )
    )

    interactions = clean_label_field(
        label.get(
            "drug_interactions"
        )
    )

    active_ingredients = clean_label_field(
        label.get(
            "active_ingredient"
        )
    )

    important_precautions = (
        contraindications
        + warnings
        + precautions
    )

    # Remove duplicates while preserving order.
    important_precautions = list(
        dict.fromkeys(
            important_precautions
        )
    )

    return {

        "generic_name":
            medicine_name,

        "active_ingredients":
            active_ingredients,

        "common_uses":
            common_uses,

        "common_side_effects":
            side_effects,

        # Keep these separately.
        # This is important for personalized
        # safety screening.
        "contraindications":
            contraindications,

        "warnings":
            warnings,

        "precautions":
            precautions,

        "important_precautions":
            important_precautions,

        "interaction_notes":
            interactions,

        "rxcui":
            rx_result.get(
                "rxcui"
            ),

        "match_score":
            rx_result.get(
                "match_score"
            ),

        "sources": [
            "RxNorm",
            "openFDA",
        ],

    }
# ============================================================
# MEDICINE IDENTIFICATION
# ============================================================

def generate_search_candidates(
    ocr_text: str,
) -> List[str]:

    text = normalize_medicine_text(ocr_text)

    if not text:
        return []

    candidates = []

    # --------------------------------------------------------
    # Explicit medicine-strength patterns
    # Example:
    # Paracetamol IP 500 mg
    # Salbutamol 100 mcg
    # --------------------------------------------------------

    strength_patterns = re.findall(
        r"\b([a-z][a-z0-9-]{3,})"
        r"(?:\s+(?:ip|usp|bp))?"
        r"\s+\d+(?:\.\d+)?\s*"
        r"(?:mg|mcg|g|ml|%|iu)\b",
        text,
        flags=re.IGNORECASE,
    )

    for item in strength_patterns:
        item = item.strip()

        if len(item) >= 4:
            candidates.append(item)

    # --------------------------------------------------------
    # Search OCR lines.
    # Only reasonably short lines are considered.
    # --------------------------------------------------------

    for line in ocr_text.splitlines():

        line = normalize_medicine_text(line)

        if not line:
            continue

        words = line.split()

        if 1 <= len(words) <= 6:
            candidates.append(line)

    # --------------------------------------------------------
    # Individual meaningful words.
    # --------------------------------------------------------

    words = text.split()

    for word in words:

        clean_word = re.sub(
            r"[^a-z0-9]+",
            "",
            word,
        )

        if len(clean_word) >= 5:
            candidates.append(clean_word)

    # --------------------------------------------------------
    # Adjacent two-word combinations.
    # --------------------------------------------------------

    for i in range(len(words) - 1):

        candidate = (
            words[i]
            + " "
            + words[i + 1]
        )

        if len(candidate) >= 8:
            candidates.append(candidate)

    # Remove duplicates.
    candidates = list(
        dict.fromkeys(candidates)
    )

    return candidates


# ============================================================
# PUBCHEM SYNONYM LOOKUP
# ============================================================

async def lookup_pubchem_synonyms(
    cid: str,
) -> List[str]:
    """
    Retrieve PubChem synonyms for a compound.

    This allows the system to discover aliases such as:
    Salbutamol -> Albuterol

    without maintaining a manual medicine database.
    """

    if not cid:
        return []

    try:

        url = (
            "https://pubchem.ncbi.nlm.nih.gov/rest/pug/"
            f"compound/cid/{cid}/synonyms/JSON"
        )

        async with httpx.AsyncClient(
            timeout=10.0
        ) as client:

            response = await client.get(url)

        if response.status_code != 200:
            return []

        data = response.json()

        information = (
            data
            .get("InformationList", {})
            .get("Information", [])
        )

        if not information:
            return []

        synonyms = information[0].get(
            "Synonym",
            [],
        )

        if not isinstance(
            synonyms,
            list,
        ):
            return []

        return [
            str(item).strip()
            for item in synonyms
            if str(item).strip()
        ]

    except Exception as e:

        print(
            "PubChem synonym lookup error:",
            e,
        )

        return []


# ============================================================
# MEDICINE-LIKE OCR DETECTION
# ============================================================

def looks_like_medicine_text(
    ocr_text: str,
) -> bool:

    text = normalize_medicine_text(
        ocr_text
    )

    if not text:
        return False

    # Strong medicine-related indicators.
    medicine_terms = [
        "tablet",
        "tablets",
        "capsule",
        "capsules",
        "syrup",
        "suspension",
        "injection",
        "inhaler",
        "respules",
        "nebules",
        "cream",
        "ointment",
        "drops",
        "solution",
        "dose",
        "dosage",
        "composition",
        "each tablet contains",
        "each capsule contains",
        "active ingredient",
        "active ingredients",
        "paracetamol",
        "acetaminophen",
        "salbutamol",
        "albuterol",
        "medicine",
        "drug",
        "pharmaceutical",
        "mg",
        "mcg",
        "prescription",
        "physician",
    ]

    matches = 0

    for term in medicine_terms:

        if term in text:
            matches += 1

    # Product/cosmetic indicators.
    cosmetic_terms = [
        "pressed powder",
        "compact powder",
        "foundation",
        "lipstick",
        "lip balm",
        "face wash",
        "cleanser",
        "moisturizer",
        "moisturiser",
        "serum",
        "cosmetic",
        "makeup",
        "coverage",
        "matte finish",
        "flawless look",
        "skin care",
        "skincare",
    ]

    cosmetic_matches = sum(
        1
        for term in cosmetic_terms
        if term in text
    )

    # If strong cosmetic evidence exists and
    # medicine evidence is weak, reject it.
    if cosmetic_matches >= 1 and matches < 2:
        return False

    return matches >= 2


# ============================================================
# MEDICINE IDENTIFICATION
# ============================================================

async def identify_medicine(
    ocr_text: str,
) -> Dict:

    # --------------------------------------------------------
    # STEP 0
    # Prevent cosmetic/product images from being identified
    # as medicines through random PubChem matches.
    # --------------------------------------------------------

    if not looks_like_medicine_text(
        ocr_text
    ):

        return {
            "identified": False,
            "medicine": None,
            "message": (
                "The uploaded image does not "
                "appear to contain a medicine "
                "package."
            ),
            "source": "none",
        }

    candidates = generate_search_candidates(
        ocr_text
    )

    if not candidates:

        return {
            "identified": False,
            "medicine": None,
            "message": (
                "No medicine name could be "
                "reliably read from the image."
            ),
            "source": "none",
        }

    print(
        "\nMedicine search candidates:"
    )

    print(candidates)

    # ========================================================
    # STEP 1
    # Try PubChem only with useful candidates.
    # ========================================================

    for candidate in candidates:

        # Skip obviously generic/non-medicine words.
        ignored_words = {
            "contains",
            "composition",
            "dosage",
            "storage",
            "warning",
            "warnings",
            "physician",
            "doctor",
            "tablet",
            "tablets",
            "capsule",
            "capsules",
            "medicine",
            "product",
            "children",
            "external",
            "use",
        }

        if normalize_name(
            candidate
        ) in ignored_words:
            continue

        print(
            "Trying PubChem:",
            candidate,
        )

        pubchem_result = (
            await lookup_pubchem(
                candidate
            )
        )

        if not pubchem_result.get(
            "identified"
        ):
            continue

        medicine_name = (
            pubchem_result.get(
                "name"
            )
        )

        cid = pubchem_result.get(
            "cid",
            "",
        )

        if not medicine_name:
            continue

        # ----------------------------------------------------
        # PubChem synonym lookup.
        # This helps brand/generic aliases.
        # ----------------------------------------------------

        synonyms = (
            await lookup_pubchem_synonyms(
                cid
            )
        )

        # ----------------------------------------------------
        # STEP 2
        # Try RxNorm with PubChem's identified name.
        # ----------------------------------------------------

        rx_result = await lookup_rxnorm(
            medicine_name
        )

        # ----------------------------------------------------
        # If PubChem returned a compound but RxNorm
        # did not recognize the title, try useful
        # PubChem synonyms.
        # ----------------------------------------------------

        if not rx_result.get(
            "identified"
        ):

            for synonym in synonyms[:20]:

                if len(synonym) < 3:
                    continue

                rx_result = (
                    await lookup_rxnorm(
                        synonym
                    )
                )

                if rx_result.get(
                    "identified"
                ):
                    break

        # ----------------------------------------------------
        # IMPORTANT:
        # Never accept a random PubChem compound as
        # a medicine just because PubChem returned 200.
        #
        # We require RxNorm identification OR a strong
        # medicine-specific OCR candidate.
        # ----------------------------------------------------

        if not rx_result.get(
            "identified"
        ):

            continue

        standardized_name = (
            rx_result.get(
                "name"
            )
        )

        if standardized_name:
            medicine_name = (
                standardized_name
            )

        # ====================================================
        # STEP 3
        # openFDA
        # ====================================================

        fda_result = (
            await lookup_openfda(
                medicine_name,
                rx_result.get(
                    "rxcui",
                    "",
                ),
            )
        )

        # If openFDA does not find the standardized
        # name, try PubChem synonyms.
        if not fda_result.get(
            "found"
        ):

            for synonym in synonyms[:20]:

                if len(synonym) < 3:
                    continue

                fda_result = (
                    await lookup_openfda(
                        synonym,
                        rx_result.get(
                            "rxcui",
                            "",
                        ),
                    )
                )

                if fda_result.get(
                    "found"
                ):
                    break

        medicine = (
            build_medicine_information(
                rx_result,
                fda_result,
            )
        )

        return {
            "identified": True,
            "medicine": medicine,
            "source": [
                "PubChem",
                "RxNorm",
                (
                    "openFDA"
                    if fda_result.get(
                        "found"
                    )
                    else "openFDA not found"
                ),
            ],
            "label_found":
                fda_result.get(
                    "found",
                    False,
                ),
            "pubchem_cid":
                cid,
        }

    # ========================================================
    # STEP 4
    # Direct RxNorm fallback.
    # ========================================================

    for candidate in candidates:

        print(
            "Fallback RxNorm:",
            candidate,
        )

        rx_result = (
            await lookup_rxnorm(
                candidate
            )
        )

        if not rx_result.get(
            "identified"
        ):
            continue

        medicine_name = (
            rx_result.get(
                "name"
            )
        )

        fda_result = (
            await lookup_openfda(
                medicine_name,
                rx_result.get(
                    "rxcui",
                    "",
                ),
            )
        )

        medicine = (
            build_medicine_information(
                rx_result,
                fda_result,
            )
        )

        return {
            "identified": True,
            "medicine": medicine,
            "source": [
                "RxNorm",
                (
                    "openFDA"
                    if fda_result.get(
                        "found"
                    )
                    else "RxNorm only"
                ),
            ],
            "label_found":
                fda_result.get(
                    "found",
                    False,
                ),
        }

    # ========================================================
    # Nothing reliable found.
    # ========================================================

    return {
        "identified": False,
        "medicine": None,
        "message": (
            "The medicine could not be "
            "confidently identified from "
            "the available OCR text and "
            "trusted medicine sources."
        ),
        "source": "none",
    }

    # ============================================================
# MEDICAL TERM RELATIONSHIP MATCHING
# ============================================================

MEDICAL_TERM_GROUPS = {
    "stomach": [
        "stomach",
        "gastric",
        "gastrointestinal",
        "gastro",
        "peptic",
        "gastric ulcer",
        "stomach ulcer",
        "gi bleeding",
        "gastrointestinal bleeding",
        "stomach bleeding",
        "ulcer",
        "bleeding",
    ],

    "kidney": [
        "kidney",
        "renal",
        "renal impairment",
        "renal failure",
        "kidney disease",
    ],

    "liver": [
        "liver",
        "hepatic",
        "hepatic impairment",
        "liver disease",
        "liver failure",
    ],

    "bleeding": [
        "bleeding",
        "hemorrhage",
        "haemorrhage",
        "blood loss",
        "bleeding disorder",
        "clotting disorder",
    ],

    "allergy": [
        "allergy",
        "allergic",
        "hypersensitivity",
        "anaphylaxis",
    ],

    "breathing": [
        "breathing",
        "breathlessness",
        "shortness of breath",
        "wheezing",
        "bronchospasm",
        "respiratory",
    ],

    "heart": [
        "heart",
        "cardiac",
        "cardiovascular",
        "heart failure",
        "heart disease",
    ],

    "pregnancy": [
        "pregnancy",
        "pregnant",
        "fetus",
        "foetus",
        "fetal",
        "foetal",
    ],

    "blood_pressure": [
        "blood pressure",
        "hypertension",
        "high blood pressure",
    ],
}


def medical_terms_related(
    user_text: str,
    medicine_text: str,
) -> bool:

    user_text = normalize_medicine_text(
        user_text
    )

    medicine_text = normalize_medicine_text(
        medicine_text
    )

    if not user_text or not medicine_text:
        return False

    # Direct phrase match
    if user_text in medicine_text:
        return True

    # Check related medical concept groups
    for group_terms in MEDICAL_TERM_GROUPS.values():

        user_matches = [
            term
            for term in group_terms
            if term in user_text
        ]

        medicine_matches = [
            term
            for term in group_terms
            if term in medicine_text
        ]

        if user_matches and medicine_matches:
            return True

    return False
    # ============================================================
# PERSONALIZED MEDICINE SCREENING
# ============================================================

def analyze_medicine_personalization(
    medicine: Dict,
    profile: Dict,
) -> Dict:

    concerns = []
    recommendations = []
    assessment_reasons = []

    # --------------------------------------------------------
    # PROFILE INFORMATION
    # --------------------------------------------------------

    health_conditions = str(
        profile.get(
            "health_conditions",
            "",
        )
    ).strip()

    allergies = str(
        profile.get(
            "allergies",
            "",
        )
    ).strip()

    current_condition = profile.get(
        "current_condition",
        {},
    )

    if not isinstance(
        current_condition,
        dict,
    ):
        current_condition = {}

    current_symptoms = current_condition.get(
        "current_symptoms",
        [],
    )

    if not isinstance(
        current_symptoms,
        list,
    ):
        current_symptoms = []

    current_treatments = current_condition.get(
        "current_treatments",
        [],
    )

    if not isinstance(
        current_treatments,
        list,
    ):
        current_treatments = []

    # --------------------------------------------------------
    # MEDICINE INFORMATION
    # --------------------------------------------------------

    medicine_name = str(
        medicine.get(
            "generic_name",
            "",
        )
    ).strip()

    active_ingredients = " ".join(
        medicine.get(
            "active_ingredients",
            [],
        )
    )

    contraindications = " ".join(
        medicine.get(
            "contraindications",
            [],
        )
    )

    warnings = " ".join(
        medicine.get(
            "warnings",
            [],
        )
    )

    precautions = " ".join(
        medicine.get(
            "precautions",
            [],
        )
    )

    interaction_notes = " ".join(
        medicine.get(
            "interaction_notes",
            [],
        )
    )

    # --------------------------------------------------------
    # NORMALIZED SEARCH TEXT
    # --------------------------------------------------------

    
    contraindication_text = normalize_medicine_text(
        contraindications
    )

    precaution_text = normalize_medicine_text(
        precautions
    )

    interaction_text = normalize_medicine_text(
        interaction_notes
    )

    # --------------------------------------------------------
    # 1. ALLERGY SCREENING
    # --------------------------------------------------------

    if allergies:

        allergy_items = re.split(
            r"[,;/]+",
            allergies,
        )

        for allergy in allergy_items:

            allergy = allergy.strip()

            if not allergy:
                continue

            normalized_allergy = normalize_name(
                allergy
            )

            if not normalized_allergy:
                continue

            normalized_medicine = normalize_name(
                medicine_name
                + " "
                + active_ingredients
            )

            if (
                normalized_allergy
                in normalized_medicine
            ):

                concerns.append(
                    f"Potential allergy concern: "
                    f"your recorded allergy "
                    f"'{allergy}' appears to match "
                    f"the identified medicine or "
                    f"active ingredient."
                )

                assessment_reasons.append(
                    "An allergy recorded in your "
                    "profile matches the identified "
                    "medicine or active ingredient."
                )

    # --------------------------------------------------------
    # 2. HEALTH CONDITION SCREENING
    # --------------------------------------------------------

    if health_conditions:

        condition_items = re.split(
            r"[,;/]+",
            health_conditions,
        )

        for condition in condition_items:

            condition = condition.strip()

            if not condition:
                continue

            normalized_condition = normalize_name(
                condition
            )

            if not normalized_condition:
                continue

            condition_words = [
                word
                for word in normalized_condition.split()
                if len(word) >= 4
            ]

            # Require meaningful overlap rather than
            # matching tiny/common words.
            matched_words = [
                word
                for word in condition_words
                if word in contraindication_text
                or word in precaution_text
            ]

            if matched_words:

                concerns.append(
                    f"Potential condition-related "
                    f"concern: your recorded health "
                    f"condition '{condition}' overlaps "
                    f"with information in the medicine "
                    f"label."
                )

                assessment_reasons.append(
                    "Your recorded health condition "
                    "has a possible overlap with "
                    "the retrieved medicine label."
                )

  
    # --------------------------------------------------------
    # 3. CURRENT SYMPTOM SCREENING
    # --------------------------------------------------------

    symptom_matches = []

    combined_precaution_text = (
        contraindication_text
        + " "
        + precaution_text
    )

    for symptom in current_symptoms:

        symptom = str(symptom).strip()

        if not symptom:
            continue

        if medical_terms_related(
            symptom,
            combined_precaution_text,
        ):

            symptom_matches.append(
                symptom
            )

    if symptom_matches:

        concerns.append(
            "Potential symptom-related safety "
            "concern: one or more current symptoms "
            "are related to information in the "
            "medicine's contraindication or "
            "precaution label."
        )

        assessment_reasons.append(
            "The current symptom information has "
            "a medically related overlap with the "
            "retrieved medicine label."
        )

    # --------------------------------------------------------
    # 4. CURRENT MEDICINE / TREATMENT SCREENING
    # --------------------------------------------------------

    treatment_matches = []

    for treatment in current_treatments:

        treatment = str(
            treatment
        ).strip()

        if not treatment:
            continue

        if medical_terms_related(
            treatment,
            interaction_text,
        ):

            treatment_matches.append(
                treatment
            )

    if treatment_matches:

        concerns.append(
            "Potential drug interaction concern: "
            "a current treatment is related to "
            "interaction information in the "
            "retrieved medicine label."
        )

        assessment_reasons.append(
            "A current treatment has a possible "
            "overlap with the medicine's retrieved "
            "interaction information."
        )

    # --------------------------------------------------------
    # 5. PERSONALIZED RECOMMENDATIONS
    # --------------------------------------------------------

    if concerns:

        recommendations.append(
            "A potential safety concern was "
            "identified from the information you "
            "provided and the retrieved medicine "
            "label. Do not rely on this screening "
            "alone; consult a doctor or pharmacist "
            "before using the medicine."
        )

        recommendations.append(
            "Review the specific concern shown "
            "above with a healthcare professional."
        )

    else:

        recommendations.append(
            "No specific safety concern was "
            "identified from the available medicine "
            "label and the information you provided."
        )

        if current_symptoms:

            symptoms_text = ", ".join(
                str(item)
                for item in current_symptoms
            )

            recommendations.append(
                f"Your reported current symptoms "
                f"({symptoms_text}) did not show a "
                f"direct match with the retrieved "
                f"contraindication or precaution "
                f"information."
            )

        if current_treatments:

            recommendations.append(
                "Because you are currently using "
                "another treatment or medicine, "
                "confirm compatibility with a "
                "doctor or pharmacist before use."
            )

    # --------------------------------------------------------
    # 6. LABEL-BASED GENERAL ADVICE
    # --------------------------------------------------------

    if medicine.get(
        "important_precautions"
    ):

        recommendations.append(
            "Read the medicine label carefully "
            "and follow the stated dose and "
            "directions."
        )

    if medicine.get(
        "interaction_notes"
    ):

        recommendations.append(
            "The retrieved medicine label contains "
            "drug interaction information. A "
            "healthcare professional should review "
            "your complete medication list when "
            "needed."
        )

    if medicine.get(
        "common_side_effects"
    ):

        recommendations.append(
            "Review the listed side effects and "
            "seek medical advice if you experience "
            "a serious or unexpected reaction."
        )

    # --------------------------------------------------------
    # 7. FINAL ASSESSMENT
    # --------------------------------------------------------

    if concerns:

        assessment = (
            "POTENTIAL SAFETY CONCERN"
        )

    else:

        assessment = (
            "NO SPECIFIC SAFETY CONCERN FOUND"
        )

    return {

        "concerns":
            list(
                dict.fromkeys(
                    concerns
                )
            ),

        "recommendations":
            list(
                dict.fromkeys(
                    recommendations
                )
            ),

        "assessment":
            assessment,

        "assessment_reasons":
            list(
                dict.fromkeys(
                    assessment_reasons
                )
            ),

        "current_symptoms":
            current_symptoms,

        "current_treatments":
            current_treatments,

    }
 
    # ============================================================
# MEDICINE STATUS
# ============================================================

def calculate_medicine_status(
    concerns: List[str],
    information_available: bool,
) -> str:

    if not information_available:
        return "INSUFFICIENT INFORMATION"

    if concerns:
        return "POTENTIAL SAFETY CONCERN"

    return "NO SPECIFIC SAFETY CONCERN FOUND"

# ============================================================
# COMPLETE MEDICINE ANALYSIS
# ============================================================

async def analyze_medicine(
    ocr_text: str,
    profile: Dict,
) -> Dict:

    print("\n========== MEDICINE ANALYSIS ==========")

    print("OCR TEXT:")
    print(ocr_text)

    print("\nPROFILE:")
    print(profile)

    # --------------------------------------------------------
    # STEP 1: IDENTIFY MEDICINE
    # --------------------------------------------------------

    identification = await identify_medicine(
        ocr_text
    )

    if not identification.get("identified"):
        return {
            "success": False,
            "identified": False,
            "message": identification.get(
                "message",
                "Medicine could not be identified.",
            ),
            "source": identification.get(
                "source",
                "none",
            ),
            "ocr_text": ocr_text,
            "profile_used": profile,
        }

    medicine = identification.get("medicine")

    if not medicine:
        return {
            "success": False,
            "identified": False,
            "message": (
                "Medicine information could "
                "not be retrieved."
            ),
            "source": identification.get(
                "source",
                "none",
            ),
            "ocr_text": ocr_text,
            "profile_used": profile,
        }

    # --------------------------------------------------------
    # STEP 2: PERSONALIZED SCREENING
    # --------------------------------------------------------

    personalization = analyze_medicine_personalization(
        medicine,
        profile,
    )

    concerns = personalization.get(
        "concerns",
        [],
    )

    # --------------------------------------------------------
    # STEP 3: CHECK INFORMATION AVAILABILITY
    # --------------------------------------------------------

    information_available = bool(
        medicine.get("common_uses")
        or medicine.get("common_side_effects")
        or medicine.get("important_precautions")
        or medicine.get("interaction_notes")
        or medicine.get("active_ingredients")
    )

    status = calculate_medicine_status(
        concerns,
        information_available,
    )

    # --------------------------------------------------------
    # STEP 4: PERSONALIZED COMPATIBILITY SCORE
    # --------------------------------------------------------

    if not information_available:

        compatibility_score = None

        compatibility_label = (
            "Not Available"
        )

        compatibility_note = (
            "There was not enough reliable medicine "
            "information to calculate a personalized "
            "compatibility score."
        )

    else:

        compatibility_score = 100

        for concern in concerns:

            concern_text = str(
                concern
            ).lower()

            # Stronger concern
            if (
                "allerg" in concern_text
                or "contraindicat" in concern_text
                or "interaction" in concern_text
            ):
                compatibility_score -= 35

            # Moderate concern
            elif (
                "condition" in concern_text
                or "symptom" in concern_text
                or "treatment" in concern_text
            ):
                compatibility_score -= 20

            # General concern
            else:
                compatibility_score -= 10

        compatibility_score = max(
            0,
            min(
                100,
                compatibility_score,
            ),
        )

        if compatibility_score >= 80:

            compatibility_label = (
                "Generally Compatible"
            )

            compatibility_note = (
                "No major personalized concern was "
                "identified from the available medicine "
                "information and the information you "
                "provided."
            )

        elif compatibility_score >= 60:

            compatibility_label = (
                "Use With Caution"
            )

            compatibility_note = (
                "Some personalized considerations were "
                "identified. Review the precautions and "
                "recommendations before using the medicine."
            )

        else:

            compatibility_label = (
                "Higher Concern"
            )

            compatibility_note = (
                "One or more significant personalized "
                "concerns were identified. Consult a "
                "doctor or pharmacist before using this "
                "medicine."
            )

    # --------------------------------------------------------
    # DEBUG
    # --------------------------------------------------------

    print(
        "Medicine identified:",
        medicine.get("generic_name"),
    )

    print(
        "Overall status:",
        status,
    )

    print(
        "Compatibility score:",
        compatibility_score,
    )

    print(
        "Compatibility label:",
        compatibility_label,
    )

    print(
        "Personalized concerns:",
        concerns,
    )

    print(
        "======================================\n"
    )

    # --------------------------------------------------------
    # FINAL RESULT
    # --------------------------------------------------------

    return {
        "success": True,

        "identified": True,

        "medicine": medicine,

        "medicine_name": medicine.get(
            "generic_name"
        ),

        "overall_status": status,

        "compatibility_score":
            compatibility_score,

        "compatibility_label":
            compatibility_label,

        "compatibility_note":
            compatibility_note,

        "personalized_assessment":
            personalization.get(
                "assessment",
                "",
            ),

        "assessment_reasons":
            personalization.get(
                "assessment_reasons",
                [],
            ),

        "personalized_concerns":
            personalization.get(
                "concerns",
                [],
            ),

        "recommendations":
            personalization.get(
                "recommendations",
                [],
            ),

        "current_symptoms":
            personalization.get(
                "current_symptoms",
                [],
            ),

        "current_treatments":
            personalization.get(
                "current_treatments",
                [],
            ),

        "source":
            identification.get(
                "source"
            ),

        "rxcui":
            medicine.get(
                "rxcui"
            ),

        "match_score":
            medicine.get(
                "match_score"
            ),

        "label_found":
            identification.get(
                "label_found",
                False,
            ),

        "ocr_text":
            ocr_text,

        "profile_used":
            profile,

        "disclaimer":
            (
                "This is an AI-assisted, "
                "label-based screening tool. "
                "The compatibility score is a "
                "screening indicator based only on "
                "the available medicine information "
                "and the information provided by the "
                "user. It is not a medical probability "
                "or guarantee of safety. Consult a "
                "doctor or pharmacist for medical advice."
            ),
    }