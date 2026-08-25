/// UAE Dirham currency formatting.
///
/// Uses the dirham *symbol*, not the ISO letters "AED". The official new
/// dirham sign has no Unicode codepoint available in fonts yet (scheduled for
/// Unicode 18.0 / September 2026), so we use the widely-supported symbols:
/// - [aedSymbol] "د.إ" — Arabic UI.
/// - [aedSymbolLatin] "Dh" — Latin documents (PDF uses built-in Latin fonts
///   that cannot render Arabic glyphs).
const String aedSymbol = 'د.إ';
const String aedSymbolLatin = 'Dh';

String _fixed(num value) => value.toDouble().toStringAsFixed(2);

/// Formats a numeric amount as "1,234.56 د.إ" (Arabic UI).
String formatAED(num value) => '${_fixed(value)} $aedSymbol';

/// Formats a numeric amount as "1,234.56 Dh" (Latin documents/PDF).
String formatAEDLatin(num value) => '${_fixed(value)} $aedSymbolLatin';
