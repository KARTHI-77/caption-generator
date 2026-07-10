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
        style = request.form.get("style","Short & Crispy",)
        language = request.form.get("language","English",)

        image = Image.open(image_file.stream)

        PROMPTS = {

         "Short & Crispy":
         """
         Generate ONE short caption.

         Maximum 10 words.

         Return only the caption.
        """,

         "Instagram":
         """
         Generate an Instagram caption.

         Maximum 20 words.

         Catchy and engaging.

         No hashtags.
         """,

         "Funny":
         """
         Generate a funny caption.

         Maximum 15 words.

         Keep it playful.
         """,

         "Professional":
         """
         Generate a professional caption.

         Maximum 20 words.

         Clear and polished.
         """,

         "Travel":
         """
         Generate a travel caption.

         Maximum 15 words.

         Inspiring and adventurous.
         """,

         "Motivational":
         """
         Generate a motivational caption.

         Maximum 20 words.

         Positive and inspiring.
         """,

         "Poetic":
         """
         Generate a poetic caption.

         Maximum 20 words.

         Elegant and expressive.
         """,
        }
        prompt = f"""
         {PROMPTS[style]}

         Generate the caption in {language}.

         Return ONLY the caption.

         Do not explain anything.
         """

        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                prompt,
                image,
            ],
        )
        
        caption = response.text.strip().replace('"', "")
        return jsonify(
            {
                "generated_text": caption
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