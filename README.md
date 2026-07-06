# Caption Generator

A Flutter application that generates captions for uploaded images using a Python Flask backend and the Replicate API.

## Features

- Upload an image
- Generate AI-powered captions
- Flutter frontend
- Flask backend

## Project Structure

```
caption_generator/
│
├── backend/
├── frontend/
├── .gitignore
└── README.md
```

## Backend Setup

```bash
cd backend

python -m venv venv

# Windows
venv\Scripts\activate

pip install -r requirements.txt
```

Create a `.env` file inside the `backend` folder.

```
REPLICATE_API_KEY=your_api_key
```

Run the backend

```bash
python server.py
```

---

## Flutter Setup

```bash
cd frontend

flutter pub get

flutter run
```
