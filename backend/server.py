import re

from flask import Flask, request, jsonify
from flask_cors import CORS

from dotenv import load_dotenv
from google import genai
from PIL import Image

import os

load_dotenv()

app = Flask(__name__)

CORS(
    app,
    resources={
        r"/*": {
            "origins": "*"
        }
    }
)

client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY")
)

@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "status": "success",
        "message": "Caption Generator API is running"
    })

@app.route("/routes", methods=["GET"])
def routes():
    return jsonify([
        {
            "path": rule.rule,
            "methods": sorted(rule.methods)
        }
        for rule in app.url_map.iter_rules()
    ])

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
        platform = request.form.get("platform", "General")

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

        PLATFORM_PROMPTS = {

         "General": """
         Write a natural caption suitable for any social media platform.
         """,

         "Instagram": """
         Write an engaging Instagram caption.

         Keep it trendy.

         Encourage engagement.

         Use a friendly tone.

         No hashtags.
         """,

         "LinkedIn": """
         Write a professional LinkedIn caption.

         Keep it inspiring and career-focused.

         Use a professional tone.

         No hashtags.
         """,

         "Facebook": """
         Write a friendly Facebook caption.

         Slightly longer than Instagram.

         Encourage conversation.

         No hashtags.
         """,

         "X (Twitter)": """
         Write a short caption.

         Maximum 280 characters.

         Make it punchy.

         No hashtags.
         """,

         "WhatsApp": """
         Write a casual status update.

         Keep it simple.

         No hashtags.
         """,
        }

        prompt = f"""
         {PROMPTS[style]}

         {PLATFORM_PROMPTS[platform]}

         Generate the caption in {language}.

         Generate ONLY ONE caption.

         Every request should generate a DIFFERENT caption.

         Do not include hashtags.

         Return only the caption text.
         """

        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                prompt,
                image,
            ],
        )
        
        caption = response.text.strip().replace('"', "")

        def generate_emojis(caption: str,platform: str,):
           emoji_response = client.models.generate_content(
           model="gemini-2.5-flash",
           contents=f"""
            Caption:
            {caption}

           Platform:
           {platform}

           Generate emojis that fit this platform.

           Rules:

           Instagram:
           4-6 expressive emojis

           LinkedIn:
           Maximum 2 professional emojis

           Facebook:
           2-4 emojis

           X (Twitter):
           1-2 emojis

           WhatsApp:
           2-3 casual emojis

           General:
           3-4 emojis

           Return ONLY emojis separated by spaces.
           """,
        )
           emoji_text = emoji_response.text.strip()
           return emoji_text.split()

        def generate_hashtags(caption: str, platform: str):
            HASHTAG_LIMITS = {
             "Instagram": 10,
             "LinkedIn": 3,
             "Facebook": 5,
             "X (Twitter)": 2,
             "WhatsApp": 1,
             "General": 6,
            }

            limit = HASHTAG_LIMITS.get(platform, 6)
            """
            Generate simple hashtags from a caption.
            """

            words = re.findall(r"[A-Za-z]+", caption)

            stop_words = {
                "the", "a", "an", "and", "of", "to", "in",
                "on", "at", "for", "is", "are", "was", "were",
                "with", "this", "that", "your", "my", "our",
                "their", "it", "its", "be", "as"
            }

            hashtags = []
            for word in words:
                clean = word.strip().capitalize()

                if len(clean) < 3:
                    continue

                if clean.lower() in stop_words:
                    continue

                tag = f"#{clean}"

                if tag not in hashtags:
                    hashtags.append(tag)

            return hashtags[:limit]

        hashtags = generate_hashtags(caption,platform,)
        emojis = generate_emojis(caption,platform,)

        return jsonify({
         "generated_text": caption,
         "hashtags": hashtags,
         "emojis": emojis,
        })

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
        port=int(os.environ.get("PORT", 5000)),
        debug=False,
    )