from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)
CORS(app)

# 🔑 Put your Replicate API key here
API_KEY = os.getenv("REPLICATE_API_KEY")

@app.route("/caption", methods=["POST"])
def caption():
    try:
        if "image" not in request.files:
            return jsonify({"error": "No image"}), 400

        image = request.files["image"]

        # Step 1: Upload image to Replicate
        upload_res = requests.post(
            "https://api.replicate.com/v1/files",
            headers={"Authorization": f"Token {API_KEY}"},
            files={"file": image}
        )

        file_url = upload_res.json()["urls"]["get"]

        # Step 2: Run model
        prediction = requests.post(
            "https://api.replicate.com/v1/predictions",
            headers={
                "Authorization": f"Token {API_KEY}",
                "Content-Type": "application/json",
            },
            json={
                "version": "c6c2f7c0d8b1b0c1c0d",  # stable BLIP version
                "input": {
                    "image": file_url
                }
            }
        )

        result = prediction.json()

        # Wait until result ready (simple polling)
        prediction_url = result["urls"]["get"]

        while True:
            check = requests.get(
                prediction_url,
                headers={"Authorization": f"Token {API_KEY}"}
            ).json()

            if check["status"] == "succeeded":
                caption = check["output"]
                break

        return jsonify([{"generated_text": caption}])

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
