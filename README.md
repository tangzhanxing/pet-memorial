# Pet Memorial

A mobile app that brings your departed pets back as 3D digital companions.

## Features

- **Photo to 3D Model** - Upload photos of your pet and generate a 3D digital representation
- **Voice Cloning** - Clone your pet's voice from historical videos
- **Interactive Companion** - Call your pet's name, give commands, and see them respond
- **Animations** - Watch your digital pet sit, sleep, wag their tail, and more
- **Memory Preservation** - Save photos, dates, and heartfelt memorial notes

## Tech Stack

- **Framework**: Flutter 3.24.0
- **3D Rendering**: model_viewer_plus (Three.js based)
- **State Management**: Provider
- **3D Generation**: Meshy AI / Tripo3D API
- **Voice Cloning**: ElevenLabs API

## Getting Started

### Prerequisites

- Flutter 3.24.0+
- Android Studio (for local development)
- API keys for 3D generation services (optional for demo mode)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd pet-memorial

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### API Configuration

To enable full functionality, configure API keys in:

- `lib/services/model_gen_service.dart` - Meshy AI key
- `lib/services/sound_clone_service.dart` - ElevenLabs key

Get free API keys:
- Meshy AI: https://meshyt.ai
- ElevenLabs: https://elevenlabs.io

## Project Structure

```
lib/
├── main.dart              # App entry point
├── models/
│   └── pet_data.dart      # Pet data model
├── screens/
│   ├── home_screen.dart       # Main pet view
│   ├── create_pet_screen.dart # Create new pet
│   ├── pet_detail_screen.dart # Pet details
│   └── settings_screen.dart   # App settings
└── services/
    ├── storage_service.dart     # Local storage
    ├── model_gen_service.dart   # 3D generation
    └── sound_clone_service.dart # Voice cloning
```

## Building

### Local Build (requires Android SDK)

```bash
flutter build apk --debug
flutter build apk --release
```

### Cloud Build (GitHub Actions)

Push to GitHub and the APK will be built automatically.

Download the APK from:
- Go to **Actions** tab → Latest workflow run → **Artifacts**

## Download APK

Pre-built debug APKs are available in the Releases section.

## Privacy

- All photos and data are stored locally on your device
- 3D model generation uses cloud services (Meshy AI)
- Voice cloning uses ElevenLabs API
- We do not sell or share your personal data

## License

MIT License

---

*Made with love for pets who have crossed the rainbow bridge* 🐾