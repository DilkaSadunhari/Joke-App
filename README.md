# **Jokes App** 🤣

A Flutter-based jokes app that fetches a collection of fun jokes from an API, displays them beautifully and works offline by caching fetched jokes. This app provides a simple and elegant user experience with a vibrant purple theme.

---

## **Features**
- 🎭 Fetch a collection of jokes (limited to 5 at a time).
- 💾 Offline functionality with cached jokes.
- 🌐 Connectivity status detection.
- 🖌️ Stylish UI with a blue gradient theme.
- 📦 Built with Flutter and Dart.

---


## **Installation**

1. **Go to folder**  
   ```bash
   cd jokes-app

2. **Install dependencies**  
   ```bash
   flutter pub get

3. **Run the app**  
   ```bash
   flutter run

4. **Ensure you have the following prerequisites installed:**  
- Flutter SDK: Download Flutter
- Dart SDK (comes with Flutter)
- Android Studio/VS Code for IDE support.

---

## **Packages Used**

- connectivity_plus: To detect internet connectivity status.
- shared_preferences: To cache jokes locally.
- dio: For API requests.

---

## **API Integration**

This app uses the JokeService class to fetch jokes from an external jokes API. Make sure the API endpoint is active and reachable. Update the API URL in joke_service.dart if necessary.

---

## **How to Use**

1. Open the app.

2. Tap the "Get Jokes" button to fetch a list of jokes.

3. If offline, you’ll see a stylish offline message, and previously cached jokes will be displayed.
