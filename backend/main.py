from fastapi import FastAPI, UploadFile, File, Form
from PIL import Image
import numpy as np
import tensorflow as tf
import io
import os
import cv2
import json
import pytesseract

pytesseract.pytesseract.tesseract_cmd = (
    r"C:\Program Files\Tesseract-OCR\tesseract.exe"
)

from cosmetic_analyzer import analyze_cosmetic
from medicine_analyzer import analyze_medicine

app = FastAPI()


# =========================================================
# MODEL
# =========================================================

MODEL_PATH = os.path.join(
    "models",
    "skin_model",
    "skin_model.keras"
)

print("Loading skin model...")

model = tf.keras.models.load_model(MODEL_PATH)

print("Skin model loaded successfully.")

class_names = [
    "combination",
    "dry",
    "normal",
    "oily"
]


# =========================================================
# FACE DETECTOR
# =========================================================

face_detector = cv2.CascadeClassifier(
    cv2.data.haarcascades +
    "haarcascade_frontalface_default.xml"
)


# =========================================================
# HOME
# =========================================================

@app.get("/")
def home():
    return {
        "message": "HerBalance AI Backend is running!"
    }


# =========================================================
# SKIN ANALYSIS
# =========================================================

@app.post("/analyze-skin")
async def analyze_skin(file: UploadFile = File(...)):

    image_data = await file.read()

    try:
        image = Image.open(
            io.BytesIO(image_data)
        ).convert("RGB")

    except Exception:
        return {
            "success": False,
            "message": "Invalid image file."
        }

    print("\n========== NEW SKIN ANALYSIS ==========")
    print("Image:", file.filename)
    print("Original size:", image.size)

    image_array = np.array(image)

    gray = cv2.cvtColor(
        image_array,
        cv2.COLOR_RGB2GRAY
    )

    faces = face_detector.detectMultiScale(
        gray,
        scaleFactor=1.1,
        minNeighbors=5,
        minSize=(80, 80)
    )

    print("Faces detected:", len(faces))

    if len(faces) == 0:

        print("NO HUMAN FACE DETECTED")

        return {
            "success": False,
            "message": (
                "No human face detected. "
                "Please upload a clear face photo."
            )
        }

    x, y, w, h = max(
        faces,
        key=lambda rect: rect[2] * rect[3]
    )

    print(
        "Face detected:",
        f"x={x}, y={y}, width={w}, height={h}"
    )

    face_image = image_array[
        y:y + h,
        x:x + w
    ]

    face_pil = Image.fromarray(
        face_image
    )

    face_pil = face_pil.resize(
        (224, 224)
    )

    face_array = np.array(
        face_pil
    ).astype(np.float32)

    # IMPORTANT:
    # Do NOT divide by 255.
    # The model already contains its own Rescaling layer.

    input_image = np.expand_dims(
        face_array,
        axis=0
    )

    predictions = model.predict(
        input_image,
        verbose=0
    )

    probabilities = predictions[0]

    print(
        "RAW MODEL PROBABILITIES:",
        probabilities.tolist()
    )

    predicted_index = int(
        np.argmax(probabilities)
    )

    print(
        "ARGMAX INDEX:",
        predicted_index
    )

    print(
        "CLASS NAMES:",
        class_names
    )

    skin_type = class_names[
        predicted_index
    ]

    confidence = float(
        probabilities[predicted_index] * 100
    )

    print(
        "Predicted skin type:",
        skin_type
    )

    print(
        "Confidence:",
        round(confidence, 2),
        "%"
    )

    print(
        "======================================\n"
    )

    return {
        "success": True,
        "message": "Skin analysis completed successfully.",
        "skin_type": skin_type,
        "confidence": round(confidence, 2)
    }


# =========================================================
# HEALTH CHECK
# =========================================================

@app.get("/health")
def health():

    return {
        "status": "ok",
        "skin_model_loaded": model is not None
    }


# =========================================================
# COSMETIC INGREDIENT ANALYSIS
# =========================================================

@app.post("/analyze-cosmetic")
async def analyze_cosmetic_endpoint(
    file: UploadFile = File(...),
    profile: str = Form("{}"),
    current_condition: str = Form("{}")
):

    print("\n========== NEW COSMETIC ANALYSIS ==========")
    print("Image:", file.filename)

    # PROFILE
    try:
        user_profile = json.loads(profile)

        if not isinstance(user_profile, dict):
            user_profile = {}

    except Exception as e:

        print("Profile JSON error:", e)

        return {
            "success": False,
            "message": "Invalid profile data."
        }

    # CURRENT CONDITION
    try:
        current_context = json.loads(
            current_condition
        )

        if not isinstance(current_context, dict):
            current_context = {}

    except Exception as e:

        print(
            "Current condition JSON error:",
            e
        )

        return {
            "success": False,
            "message": "Invalid current condition data."
        }

    print("USER PROFILE:")
    print(user_profile)

    print("CURRENT CONDITION:")
    print(current_context)

    # READ IMAGE
    image_data = await file.read()

    try:

        image = Image.open(
            io.BytesIO(image_data)
        ).convert("RGB")

    except Exception:

        return {
            "success": False,
            "message": "Invalid image file."
        }

    # OCR
    print("Running cosmetic OCR...")

    image_array = np.array(image)

    ocr_text = pytesseract.image_to_string(
        image_array
    )

    print("OCR TEXT:")
    print(ocr_text)

    # COMBINE PROFILE + CURRENT CONDITION
    analysis_profile = dict(user_profile)

    analysis_profile["current_condition"] = current_context

    print("\n========== PROFILE SENT TO COSMETIC ANALYZER ==========")
    print(analysis_profile)
    print("========================================================")

    # COSMETIC ANALYSIS
    result = analyze_cosmetic(
        ocr_text,
        analysis_profile
    )

    result["current_condition_used"] = current_context

    print(
        "Product category:",
        result.get("product_category")
    )

    print(
        "Overall status:",
        result.get("overall_status")
    )

    print(
        "===========================================\n"
    )

    return result


# =========================================================
# MEDICINE ANALYSIS
# =========================================================

@app.post("/analyze-medicine")
async def analyze_medicine_endpoint(
    file: UploadFile = File(...),
    profile: str = Form("{}"),
    current_condition: str = Form("{}")
):

    print("\n========== NEW MEDICINE ANALYSIS ==========")
    print("Image:", file.filename)

    # PROFILE
    try:

        user_profile = json.loads(profile)

        if not isinstance(user_profile, dict):
            user_profile = {}

    except Exception as e:

        print("Profile JSON error:", e)

        return {
            "success": False,
            "message": "Invalid profile data."
        }

    # CURRENT CONDITION
    try:

        current_context = json.loads(
            current_condition
        )

        if not isinstance(current_context, dict):
            current_context = {}

    except Exception as e:

        print(
            "Current condition JSON error:",
            e
        )

        return {
            "success": False,
            "message": "Invalid current condition data."
        }

    print("USER PROFILE:")
    print(user_profile)

    print("CURRENT CONDITION:")
    print(current_context)

    # READ IMAGE
    image_data = await file.read()

    try:

        image = Image.open(
            io.BytesIO(image_data)
        ).convert("RGB")

    except Exception:

        return {
            "success": False,
            "message": "Invalid image file."
        }

    # OCR
    print("Running medicine OCR...")

    image_array = np.array(image)

    ocr_text = pytesseract.image_to_string(
        image_array
    )

    print("OCR TEXT:")
    print(ocr_text)

    # COMBINE PROFILE + CURRENT CONDITION
    analysis_profile = dict(user_profile)

    analysis_profile["current_condition"] = current_context

    print(
        "\n========== PROFILE SENT TO MEDICINE ANALYZER =========="
    )

    print(analysis_profile)

    print(
        "========================================================"
    )

    # MEDICINE ANALYSIS
    result = await analyze_medicine(
        ocr_text,
        analysis_profile
    )

    result["current_condition_used"] = current_context

    print(
        "Medicine:",
        result.get("medicine_name")
    )

    print(
        "Overall status:",
        result.get("overall_status")
    )

    print(
        "===========================================\n"
    )

    return result