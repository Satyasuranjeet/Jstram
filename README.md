
<div align="center">
  <img src="https://your-image-link.com/logo.png" width="120" alt="JStream Logo">
  <h1>🎵 JStream</h1>
  <p>Stream and discover your favorite songs seamlessly — powered by Saavn API</p>
</div>

---

## 📱 Screenshots

| Home Screen | Search Results | Song Playback |
|-------------|----------------|----------------|
| ![Home](https://your-image-link.com/home.png) | ![Search](https://your-image-link.com/search.png) | ![Player](https://your-image-link.com/player.png) |

---

## 🚀 Features

- 🔍 **Search Songs** — Instantly find songs via Saavn API.
- 🎧 **Play Music** — Stream 320kbps quality MP3s.
- 📀 **Song Info** — View artist, thumbnail, and title.
- 🎨 **Modern UI** — Clean and responsive Flutter interface.
- 💾 **Playlist Support** *(Upcoming)*

---

## 🔧 Setup Instructions

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/jstream.git
   cd jstream
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Update API URL**
   > In `main.dart`, replace the placeholder with your server URL:
   ```dart
   http.get(Uri.parse('http://yourserver.com/songs?query=$query'));
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## 📦 Backend Setup (Optional)

If you want to use the provided Python backend:

1. Install dependencies:
   ```bash
   pip install flask requests flask-cors
   ```

2. Run the Flask server:
   ```bash
   python app.py
   ```

3. Make sure the Flutter app points to this backend:
   ```
   http://localhost:5000/songs?query=Believer
   ```

---

## 📁 Folder Structure

```
jstream/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   └── song.dart
│   └── services/
│       └── api_service.dart
├── assets/
│   └── logo.png
├── README.md
└── pubspec.yaml
```

---

## 🛠 Built With

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [Saavn API](https://saavn.dev/)
- [Flask](https://flask.palletsprojects.com/) (Backend)

---

## 🤝 Contributing

Contributions are welcome! Feel free to open issues or submit pull requests for features, bug fixes, or improvements.

---

## 🧑‍💻 Author

**Satya Suranjeet Jena**  
📫 [LinkedIn](https://www.linkedin.com/in/satya-suranjeet-jena) • 🌐 [Portfolio](https://yourportfolio.com)

---

## ⚖️ License

This project is licensed under the [MIT License](LICENSE).

---

<div align="center">
  <strong>🎶 Made with ❤️ for music lovers.</strong>
</div>

---