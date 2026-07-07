from flask import Flask, request, jsonify
from flask_cors import CORS

from dotenv import load_dotenv
from google import genai
from PIL import Image

import os

load_dotenv()

app = Flask(__name__)
CORS(app)

client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY")
)


@app.route("/caption", methods=["POST"])
def caption():

    try:

        if "image" not in request.files:
            return jsonify(
                {
                    "error": "No image uploaded."
                }
            ), 400

        image_file = request.files["image"]

        image = Image.open(image_file.stream)

        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                "Describe this image with one detailed natural caption.",
                image,
            ],
        )

        return jsonify(
            {
                "generated_text": response.text
            }
        )

    except Exception as e:

        print(e)

        return jsonify(
            {
                "error": str(e)
            },
        ), 500


if __name__ == "__main__":

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True,
    )