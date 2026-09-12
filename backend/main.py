from fastapi import FastAPI, UploadFile, File
from PIL import Image
import numpy as np
import tensorflow as tf
import io
import os

app = FastAPI()

# Path to trained model
MODEL_PATH = os.path.join(
    "models",
    "skin_model",
    "skin_model.keras"
)

# Load trained model
model = tf.keras.models.load_model(MODEL_PATH)

# IMPORTANT: Keep the same class order used during training
class_names = [
    "combination",
    "dry",
    "normal",
    "oily"
]


@app.get("/")
def home():
    return {
        "message": "HerBalance AI Backend is running!"
    }


@app.post("/analyze-skin")
async def analyze_skin(file: UploadFile = File(...)):

    # Read uploaded image
    image_data = await file.read()

    # Convert uploaded image to RGB
    image = Image.open(
        io.BytesIO(image_data)
    ).convert("RGB")

    # Resize image
    image = image.resize((224, 224))

    # Convert image to NumPy array
    image_array = np.array(
        image
    ).astype(np.float32)

    # IMPORTANT:
    # Do NOT use image_array / 255.0 here.
    # The trained model already contains:
    # Rescaling(1./127.5, offset=-1)

    # Add batch dimension
    image_array = np.expand_dims(
        image_array,
        axis=0
    )

    # Predict
    prediction = model.predict(
        image_array,
        verbose=0
    )

    # Print prediction for debugging
    print("\n========== SKIN PREDICTION ==========")
    print("Raw prediction:", prediction[0])

    predicted_index = int(
        np.argmax(prediction[0])
    )

    print("Predicted index:", predicted_index)

    skin_type = class_names[
        predicted_index
    ]

    print("Predicted skin type:", skin_type)

    confidence = float(
        np.max(prediction[0]) * 100
    )

    print("Confidence:", confidence)
    print("======================================\n")

    return {
        "success": True,
        "skin_type": skin_type,
        "confidence": round(confidence, 2)
    }