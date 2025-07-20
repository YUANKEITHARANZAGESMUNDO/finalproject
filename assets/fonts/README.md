# Fonts Directory

## TikTokSans Font Setup

To use the TikTokSans font in this Flutter app:

1. **Download the font file:**
   - Obtain the `TikTokSans-Regular.ttf` file from the official TikTok brand resources
   - Or download from a trusted font repository

2. **Replace the placeholder:**
   - Replace `TikTokSans-Regular.ttf` in this directory with the actual font file
   - Make sure the filename matches exactly: `TikTokSans-Regular.ttf`

3. **Verify the setup:**
   - Run `flutter pub get` to update dependencies
   - The font will be available as `TikTokSans` family in your app

## Usage in Flutter

To use the TikTokSans font in your widgets:

```dart
Text(
  'Hello World',
  style: TextStyle(
    fontFamily: 'TikTokSans',
    fontSize: 16,
  ),
)
```

Or set it globally in your app's theme:

```dart
ThemeData(
  fontFamily: 'TikTokSans',
  // ... other theme properties
)
``` 