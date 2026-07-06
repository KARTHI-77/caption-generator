from flask import Flask, request, jsonify
from flask_cors import CORS

from PIL import Image
from transformers import BlipProcessor, BlipForConditionalGeneration

app = Flask(__name__)
CORS(app)

print("Loading BLIP model... (first run may take several minutes)")

processor = BlipProcessor.from_pretrained(
    "Salesforce/blip-image-captioning-base"
)

model = BlipForConditionalGeneration.from_pretrained(
    "Salesforce/blip-image-captioning-base"
)

print("BLIP model loaded successfully.")


@app.route("/caption", methods=["POST"])
def caption():

    try:

        if "image" not in request.files:
            return jsonify(
                {
                    "error": "No image uploaded."
                }
            ), 400

        image = request.files["image"]

        pil_image = Image.open(image.stream).convert("RGB")

        inputs = processor(
            images=pil_image,
            return_tensors="pt",
        )

        output = model.generate(
            **inputs,
            max_new_tokens=30,
        )

        generated_caption = processor.decode(
            output[0],
            skip_special_tokens=True,
        )

        return jsonify(
            {
                "generated_text": generated_caption
            }
        )

    except Exception as e:

        print(e)

        return jsonify(
            {
                "error": str(e)
            }
        ), 500


if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True,
    )