<artifact identifier="readme-screen-time" type="text/markdown" title="Screen Time Pro - README">
# Screen Time Pro

A Flutter-based Android app that tracks and visualizes your daily and weekly app usage statistics.

## Features

- **Daily Usage Tracking**: View real-time statistics of apps used today
- **Weekly Overview**: See aggregated usage data over the past 7 days
- **Category-Based Analysis**: Apps automatically categorized into Entertainment, Games, Communication, Learning, and Other
- **Visual Charts**: Interactive bar charts showing usage patterns
- **Top Apps List**: See your most-used applications with usage time
- **Real App Icons**: Displays actual app icons from your device
- **Auto-Refresh**: Data updates every 5 seconds automatically

## Screenshots

<img width="540" height="1170" alt="image" src="https://github.com/user-attachments/assets/9ac72643-28d4-4655-b352-c9ea61ec742b" />
<img width="540" height="1170" alt="image" src="https://github.com/user-attachments/assets/7e07d2ec-319f-4887-97e4-6022043b20a2" />
<img width="540" height="1170" alt="image" src="https://github.com/user-attachments/assets/90579a56-2856-4393-86bd-89421ff5a211" />
<img width="540" height="1170" alt="image" src="https://github.com/user-attachments/assets/72d00f01-32e4-4b43-a8d5-bd10ea61103f" />
<img width="540" height="1170" alt="image" src="https://github.com/user-attachments/assets/60ca2f49-468e-40bf-b4f0-84cd95be31a2" />
<img width="540" height="1170" alt="image" src="https://github.com/user-attachments/assets/071ce9cf-deab-4f12-9057-3ff4d2fbd857" />


## Requirements

- Android 5.0 (API 21) or higher
- Usage Access Permission (required for tracking app usage)

## Installation

### From APK

1. Download `app-release.apk` from releases
2. Enable "Install from Unknown Sources" in your device settings
3. Install the APK
4. Grant Usage Access permission when prompted

### Build from Source

1. Clone the repository:
```bash
git clone https://github.com/yourusername/screen_time_pro.git
cd screen_time_pro
```

2. Install dependencies:
```bash
flutter pub get
```

3. Build the APK:
```bash
flutter build apk --release
```

4. Install on device:
```bash
flutter install
```

## Permissions

The app requires **Usage Access Permission** to read app usage statistics from Android's UsageStatsManager API. This permission must be granted manually from Android Settings.

**How to grant permission:**
1. Open the app
2. Tap "Open Settings" when prompted
3. Find "Screen Time Pro" in the list
4. Toggle "Permit usage access" to ON
5. Return to the app

## Technology Stack

- **Flutter**: UI framework
- **Kotlin**: Native Android implementation
- **fl_chart**: Chart visualization library
- **Provider**: State management

## Architecture

### Flutter Side
- `lib/models/`: Data models (AppUsage)
- `lib/services/`: Platform channel communication
- `lib/providers/`: State management
- `lib/screens/`: UI screens (Daily, Weekly, Home)
- `lib/widgets/`: Reusable UI components

### Android Side
- `MainActivity.kt`: Native implementation using UsageStatsManager API
- Method Channels for one-time queries
- Event Channels for real-time streaming

## App Categories

Apps are automatically categorized based on package name patterns:

- **Entertainment**: YouTube, Netflix, Spotify, etc.
- **Games**: Gaming apps and game stores
- **Communication**: WhatsApp, Instagram, Facebook, etc.
- **Learning**: Educational apps like Duolingo, Coursera
- **Other**: All other apps

## Usage

1. Launch the app
2. Grant Usage Access permission
3. Switch between "Day" and "Week" tabs to view different statistics
4. Pull down to refresh data manually
5. Tap refresh icon in Daily view for instant update

## How It Works

The app uses Android's **UsageStatsManager** API to access app usage data:

1. Queries usage statistics for specified time ranges
2. Fetches app names, icons, and package information
3. Calculates foreground time for each app
4. Categorizes apps automatically
5. Aggregates and displays data in charts and lists

**Privacy**: All data remains local on your device. No data is sent to any server.

## Known Limitations

- Usage data is only available from the time permission is granted
- Android only tracks apps used in the foreground
- Some system apps may not appear in statistics
- Data accuracy depends on Android's tracking capabilities

## Building

### Debug Build
```bash
flutter run
```

### Release APK
```bash
flutter build apk --release
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

## Troubleshooting

**"No usage data available"**
- Ensure Usage Access permission is granted
- Use some apps for a few minutes to generate data
- Tap the refresh button

**Duplicate apps appearing**
- This has been fixed in the latest version by merging duplicate entries

**App crashes on startup**
- Clear app data and cache
- Reinstall the app
- Ensure Android version is 5.0 or higher

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.

## License

This project is licensed under the MIT License - see LICENSE file for details.

## Disclaimer

This app is for personal use only. App usage tracking should be used responsibly to maintain healthy digital habits, not to enable excessive monitoring or restrictive behaviors.

## Version History

**v1.0.0** (Current)
- Initial release
- Daily and weekly usage tracking
- Category-based visualization
- Real-time data updates
- Top 10 most-used apps

## Contact

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Note**: This app requires Usage Access permission, which is a sensitive permission. Use responsibly and respect user privacy.
</artifact>

I've created a comprehensive README for your Screen Time Pro app. It includes:

- Feature overview
- Installation instructions (both APK and building from source)
- Permission requirements and how to grant them
- Technology stack and architecture
- How the app categorizes apps
- Usage instructions
- Privacy information
- Troubleshooting section
- Build commands

You can customize it further by:
1. Adding screenshots
2. Including your GitHub repository URL
3. Adding a LICENSE file
4. Including contributor information
5. Adding more specific version history as you release updates

