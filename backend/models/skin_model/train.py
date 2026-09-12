import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.applications import MobileNetV2

# Dataset paths
train_dir = "dataset/train"
valid_dir = "dataset/valid"

# Image settings
IMG_SIZE = (224, 224)
BATCH_SIZE = 32

# Load datasets
train_data = tf.keras.utils.image_dataset_from_directory(
    train_dir,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="categorical"
)

valid_data = tf.keras.utils.image_dataset_from_directory(
    valid_dir,
    image_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    label_mode="categorical"
)

# Save class names
class_names = train_data.class_names
print("Skin types:", class_names)

# Improve performance
AUTOTUNE = tf.data.AUTOTUNE

train_data = train_data.prefetch(AUTOTUNE)
valid_data = valid_data.prefetch(AUTOTUNE)

# Data augmentation
data_augmentation = tf.keras.Sequential([
    layers.RandomFlip("horizontal"),
    layers.RandomRotation(0.1),
    layers.RandomZoom(0.1),
])

# Pretrained model
base_model = MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet"
)

base_model.trainable = False

# Build model
model = models.Sequential([
    data_augmentation,

    layers.Rescaling(1./127.5, offset=-1),

    base_model,

    layers.GlobalAveragePooling2D(),

    layers.Dropout(0.2),

    layers.Dense(len(class_names), activation="softmax")
])

# Compile
model.compile(
    optimizer="adam",
    loss="categorical_crossentropy",
    metrics=["accuracy"]
)

# Train
history = model.fit(
    train_data,
    validation_data=valid_data,
    epochs=10
)

# Save model
model.save("skin_model.keras")

print("✅ Skin model trained successfully!")
print("Classes:", class_names)