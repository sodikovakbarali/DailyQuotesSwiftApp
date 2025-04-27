
# 📖 DailyQuotesSwiftApp

A simple, beautiful iOS app that shows a new motivational quote each day.  
Built with **SwiftUI** and **MVVM architecture**.

---

## 📱 App Features
- View daily motivational quotes
- Swipe left/right to see more quotes
- Save favorite quotes
- View and manage your favorites list
- Share quotes with friends through other apps
- Beautiful random background color animations

---

## 🏗️ Project Structure
```
DailyQuotesSwiftApp/
├── DailyQuotesSwiftAppApp.swift         # App entry point
├── Models/
│   └── Quote.swift                      # Data model for quotes
├── ViewModels/
│   └── QuoteViewModel.swift             # App logic and state management
├── Views/
│   ├── ContentView.swift                # Main screen showing daily quotes
│   ├── FavoritesView.swift              # Favorites list screen
│   └── QuoteCardView.swift              # Quote UI component
├── Resources/
│   └── quotes.json                      # Pre-loaded list of motivational quotes
```

---

## 🚀 How to Run the App

1. Open `DailyQuotesSwiftApp.xcodeproj` in **Xcode 15** or newer.
2. Make sure the deployment target is iOS 16.0 or later.
3. Build and run the app using an iPhone Simulator (or a real device).
4. Enjoy daily motivation! 🌟

---

## 🔨 Key Swift/SwiftUI Concepts Used
- **SwiftUI Views & Navigation**
- **State Management** using `@StateObject` and `@ObservedObject`
- **MVVM Design Pattern**
- **Codable** for loading quotes from JSON
- **UserDefaults** for simple data persistence (favorites)
- **UIKit Integration** for sharing quotes (`UIActivityViewController`)
- **Animations** and **Dynamic Colors**

---

## 🎯 Requirements
- Xcode 15+
- iOS 16.0+

---

## 📸 Screenshots
| Daily Quote | Favorites List | Share a Quote |
|:---:|:---:|:---:|
| ![daily](https://via.placeholder.com/150) | ![favorites](https://via.placeholder.com/150) | ![share](https://via.placeholder.com/150) |

_(Replace screenshots later with real ones!)_

---

## ✨ Authors
- Team Name: Ralokkuz
- Members:
  - Akbarali Sodikov
  - Ulugbek Muslitdinov
  - Javokhir Kakhorov

---

## 📚 Acknowledgments
- Quotes adapted from various public domain sources.
- Thanks to the CSc 372 Spring 2025 course for this awesome project!

---
