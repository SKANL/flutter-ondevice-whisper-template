/// Supported languages for Whisper transcription.
enum WhisperLanguage {
  english('en', 'English'),
  spanish('es', 'Español'),
  french('fr', 'Français'),
  german('de', 'Deutsch'),
  italian('it', 'Italiano'),
  portuguese('pt', 'Português'),
  dutch('nl', 'Nederlands'),
  japanese('ja', '日本語'),
  chinese('zh', '中文'),
  russian('ru', 'Русский');

  const WhisperLanguage(this.code, this.label);

  final String code;
  final String label;

  static WhisperLanguage fromCode(String code) {
    return WhisperLanguage.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => WhisperLanguage.english,
    );
  }
}
