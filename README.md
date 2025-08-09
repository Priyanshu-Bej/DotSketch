# DotSketch 🎨

A modern image-to-text art generator app built with Flutter. Instantly convert your images into beautiful dotted, ASCII, outline, or Unicode art for easy sharing anywhere.

## 📱 Overview

DotSketch is a user-friendly Flutter app that transforms any image into stylish text art. Choose from multiple art styles, adjust output width, and copy your creation with a single tap. Perfect for sharing on social media, messaging, or as creative comments.

## ✨ Features

- 🖼️ **Image to Text Art**: Convert images to Dots, ASCII, Outline, or Unicode art
- 🎨 **Multiple Art Styles**: Dots Only, ASCII Art, Outline Only, Unicode Art
- 📏 **Customizable Output**: Adjust width for more or less detail
- 📋 **Copy to Clipboard**: One-tap copy for easy sharing
- 🖌️ **Modern UI**: Clean, responsive, and mobile-friendly design
- 🔒 **Permissions**: Secure image access with required permissions

## 🛠️ Technical Stack

- **Framework**: Flutter
- **Image Picker**: image_picker
- **Clipboard**: Flutter Clipboard API
- **UI**: Custom modern widgets, responsive layout
- **Platforms**: Android, iOS

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable)
- Dart SDK
- Android Studio / Xcode
- Git

### Installation

Clone the repository:

```sh
git clone https://github.com/Priyanshu-Bej/DotSketch.git
cd DotSketch
```

Install dependencies:

```sh
flutter pub get
```

Run the app:

```sh
flutter run
```

## 🏗️ Project Structure

```
lib/
├── main.dart                # Main app logic & UI
├── ui/
│   ├── modern_app_bar.dart  # Custom AppBar
│   ├── modern_card.dart     # Card widget
│   ├── modern_dropdown.dart # Dropdown widget
│   ├── modern_slider.dart   # Slider widget
│   ├── image_preview.dart   # Image preview
│   └── theme.dart           # App theme
├── ...
```

## 🔧 Configuration

- Android: Permissions in `android/app/src/main/AndroidManifest.xml`
- iOS: Permissions in `ios/Runner/Info.plist`
- App icon: `assets/images/app_logo.jpg`

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Developer

Built by Priyanshu Bej

- LinkedIn: [@priyanshubej](https://linkedin.com/in/priyanshubej)

## 📞 Support

For support and questions, please contact:

- Email: priyanshubej2001@gmail.com
- Website: [My Portfolio](https://www.priyanshubej.com/)

Built with ❤️ using Flutter
