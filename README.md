# ✨ Caption Generator AI

A Flutter-based AI social media content assistant that generates captions for uploaded images. The application uses a Flutter frontend, Python Flask backend, and AI-powered caption generation.

## 🚀 Live Demo

**Web Application:**
https://karthi-77.github.io/caption-generator/

> Note: The web version requires Google Sign-In configuration for the deployed domain.

---

## 📱 Features

* 🖼️ Upload images from your device
* 🤖 Generate AI-powered captions
* 🎭 Select different caption styles
* 🌐 Generate captions in different languages
* 📱 Generate platform-specific captions
* #️⃣ Automatically generate relevant hashtags
* 😀 Generate relevant emojis
* 📋 Copy generated captions
* 📤 Share captions
* 🔄 Regenerate captions
* ❤️ Save and manage favorite captions
* 📚 View caption history
* 🔐 Google authentication using Firebase
* 🌙 Dark mode support
* 📱 Android application support
* 🌐 Flutter Web support
* ☁️ Cloud-hosted backend API

---

## 🛠️ Technologies Used

### Frontend

* Flutter
* Dart
* Firebase Authentication
* Cloud Firestore
* Google Sign-In
* HTTP / REST API
* Image Picker
* Provider

### Backend

* Python
* Flask
* Flask-CORS
* Gunicorn
* AI APIs / AI models
* REST API

### Database & Authentication

* Firebase Authentication
* Cloud Firestore

### Deployment

* GitHub Pages — Flutter Web
* Render — Flask Backend

---

## 📂 Project Structure

```text
caption-generator/
│
├── .github/
│   └── workflows/
│       └── deploy-flutter-web.yml
│
├── backend/
│   ├── server.py
│   ├── requirements.txt
│   └── ...
│
├── frontend/
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── services/
│   │   ├── utils/
│   │   └── widgets/
│   ├── pubspec.yaml
│   └── ...
│
├── .gitignore
└── README.md
```

---

## ⚙️ Backend Setup

### 1. Clone the repository

```bash
git clone https://github.com/KARTHI-77/caption-generator.git
cd caption-generator
```

### 2. Navigate to the backend

```bash
cd backend
```

### 3. Create a virtual environment

#### Windows

```bash
python -m venv venv
```

Activate it:

```bash
venv\Scripts\activate
```

#### Linux / macOS

```bash
python3 -m venv venv
source venv/bin/activate
```

### 4. Install dependencies

```bash
pip install -r requirements.txt
```

### 5. Configure environment variables

Create a `.env` file inside the `backend` directory.

```env
GEMINI_API_KEY = your_api_key_here
```

> Never commit API keys, passwords, private keys, or other secrets to GitHub.

### 6. Run the backend

```bash
python server.py
```

The API will be available locally at:

```text
http://127.0.0.1:5000
```

---

## 📱 Flutter Setup

Open a new terminal and navigate to the frontend:

```bash
cd frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

To run on Chrome:

```bash
flutter run -d chrome
```

---

## 🔥 Firebase Configuration

The application uses Firebase for:

* Google authentication
* User authentication
* Caption history
* Favorite captions
* User-specific data

To configure Firebase for your own environment:

```bash
flutterfire configure
```

Then configure Google Sign-In and Firebase Authentication in the Firebase Console.

For Android builds, make sure the appropriate SHA-1 and SHA-256 fingerprints are registered in the Firebase project.

---

## 🌐 Backend API

The Flutter application communicates with the Flask backend through a REST API.

### Generate Caption

```http
POST /caption
```

### Request

The endpoint accepts multipart form data containing:

```text
image
style
language
platform
```

Example:

```text
image = image file
style = Funny
language = English
platform = Instagram
```

### Response

The API returns generated caption information that can be displayed by the Flutter application.

---

## ☁️ Deployment

### Backend

The Flask backend is deployed as a web service using Render.

The backend is configured to run with Gunicorn in production.

Example production start command:

```bash
gunicorn server:app
```

### Frontend

The Flutter Web application is automatically built and deployed to GitHub Pages using GitHub Actions.

Every push to the configured branch can trigger the deployment workflow.

---

## 🔐 Security

Sensitive configuration files should never be committed to the repository.

Make sure files such as:

```text
.env
```

are included in `.gitignore`.

Example:

```gitignore
.env
*.key
*.pem
```

Do not expose API keys or private credentials in Flutter source code or public GitHub repositories.

---

## 🧪 Building the Android APK

To create a release APK:

```bash
cd frontend
flutter clean
flutter pub get
flutter build apk --release
```

The generated APK can be found at:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 📸 Application Workflow

```text
User
 │
 ▼
Select Image
 │
 ▼
Choose Style / Language / Platform
 │
 ▼
Flutter Frontend
 │
 ▼
Flask REST API
 │
 ▼
AI Caption Generation
 │
 ▼
Caption + Hashtags + Emojis
 │
 ├──► Display Result
 ├──► Copy
 ├──► Share
 ├──► Favorite
 └──► Save to Firebase
```

---

## 🎯 Project Goals

The main goal of Caption Generator AI is to simplify social media content creation by automatically generating context-aware captions from uploaded images.

The application combines:

* Computer vision / image understanding
* Generative AI
* Mobile application development
* REST API development
* Cloud deployment
* Authentication
* Cloud database management

---

## 🔮 Future Improvements

Possible future enhancements include:

* 📊 Caption analytics
* 🧠 Improved image understanding
* 🎨 AI-generated post templates
* 🖼️ AI image editing
* 📅 Social media scheduling
* 📈 Caption performance analysis
* 🔗 Direct social media publishing
* 🎤 Voice-based caption generation
* 🌍 Additional language support

---

## 👨‍💻 Author

**KARTHI-77**

GitHub:
https://github.com/KARTHI-77

---

## 📄 License

This project is intended for educational and academic purposes.
