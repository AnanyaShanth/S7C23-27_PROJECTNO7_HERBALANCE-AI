import os
import shutil

BASE_DIR = "dataset"
classes = ["combination", "dry", "oily", "normal"]

for split in ["train", "valid", "test"]:
    split_dir = os.path.join(BASE_DIR, split)

    for filename in os.listdir(split_dir):
        source = os.path.join(split_dir, filename)

        # Skip folders
        if not os.path.isfile(source):
            continue

        detected_class = None

        for class_name in classes:
            if filename.lower().startswith(class_name):
                detected_class = class_name
                break

        if detected_class:
            destination_folder = os.path.join(
                split_dir, detected_class
            )

            os.makedirs(destination_folder, exist_ok=True)

            destination = os.path.join(
                destination_folder, filename
            )

            shutil.move(source, destination)

print("Dataset organization completed!")