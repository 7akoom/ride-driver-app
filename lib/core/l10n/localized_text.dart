/// Text the backend keeps in the three languages (help articles, support
/// categories). The captain's language is chosen when shown; a missing one falls back
/// to English, then to any that is there.
final class LocalizedText {
  const LocalizedText({this.en = '', this.ar = '', this.ku = ''});

  final String en;
  final String ar;
  final String ku;

  String of(String languageCode) {
    final own = switch (languageCode) {
      'ar' => ar,
      'ku' => ku,
      _ => en,
    };

    if (own.isNotEmpty) {
      return own;
    }

    return [en, ar, ku].firstWhere((text) => text.isNotEmpty, orElse: () => '');
  }
}
