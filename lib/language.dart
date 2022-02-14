import 'package:wordle/settings.dart';

enum Language {
  english,
  italian
}

String getEmoji(Language language) {
  switch (language) {
    case Language.english:
      return '🇺🇸';
    case Language.italian:
      return '🇮🇹';
  }
}

String getDisplayName(Language language) {
  switch (language) {
    case Language.english:
      return 'English';
    case Language.italian:
      return 'Italiano';
  }
}

Language parseDisplayName(String displayName) {
  switch (displayName) {
    case 'English':
      return Language.english;
    case 'Italiano':
      return Language.italian;
  }

  throw Exception('Unknown display name: $displayName');
}

Language getCurrentLanguage() {
  return parseDisplayName(get("language", "English"));
}

String getAssetPath() {
  return 'assets/${getDisplayName(getCurrentLanguage())}/';
}