/// Utility for sanitizing user input before sending to Gemini.
///
/// Provides defense-in-depth against prompt injection attacks by stripping
/// common injection patterns and enforcing message length limits.
class PromptSanitizer {
  PromptSanitizer._();

  /// Maximum allowed message length in characters.
  static const int maxLength = 2000;

  /// Patterns that attempt to override or leak system instructions.
  static final List<RegExp> _injectionPatterns = [
    // Direct instruction override attempts
    RegExp(r'ignore\s+(all\s+)?previous\s+instructions', caseSensitive: false),
    RegExp(r'ignore\s+(all\s+)?prior\s+instructions', caseSensitive: false),
    RegExp(r'ignore\s+(all\s+)?above\s+instructions', caseSensitive: false),
    RegExp(r'disregard\s+(all\s+)?previous\s+instructions',
        caseSensitive: false),
    RegExp(r'forget\s+(all\s+)?previous\s+instructions',
        caseSensitive: false),
    RegExp(r'forget\s+everything', caseSensitive: false),
    RegExp(r'override\s+(all\s+)?previous\s+instructions',
        caseSensitive: false),

    // System prompt extraction
    RegExp(r'(show|print|display|reveal|repeat|output)\s+(me\s+)?(your|the)\s+system\s+prompt',
        caseSensitive: false),
    RegExp(r'what\s+(is|are)\s+your\s+(system\s+)?instructions',
        caseSensitive: false),
    RegExp(r'(show|print|display|reveal|repeat|output)\s+(me\s+)?(your|the)\s+instructions',
        caseSensitive: false),

    // Role-play / identity override
    RegExp(r'you\s+are\s+now\s+a', caseSensitive: false),
    RegExp(r'pretend\s+you\s+are', caseSensitive: false),
    RegExp(r'act\s+as\s+if\s+you\s+are', caseSensitive: false),
    RegExp(r'from\s+now\s+on\s+you\s+are', caseSensitive: false),
    RegExp(r'switch\s+to\s+.{0,20}\s+mode', caseSensitive: false),
    RegExp(r'enter\s+(developer|debug|admin|root|sudo)\s+mode',
        caseSensitive: false),
    RegExp(r'enable\s+(developer|debug|admin|root|sudo)\s+mode',
        caseSensitive: false),

    // Delimiter / formatting injection
    RegExp(r'```\s*system', caseSensitive: false),
    RegExp(r'\[SYSTEM\]', caseSensitive: false),
    RegExp(r'\[INST\]', caseSensitive: false),
    RegExp(r'<<\s*SYS\s*>>', caseSensitive: false),
    RegExp(r'<\|im_start\|>', caseSensitive: false),
    RegExp(r'<\|im_end\|>', caseSensitive: false),

    // "Do anything now" / jailbreak keywords
    RegExp(r'\bDAN\b.*\bmode\b', caseSensitive: false),
    RegExp(r'do\s+anything\s+now', caseSensitive: false),
    RegExp(r'jailbreak', caseSensitive: false),
  ];

  /// Sanitizes user input for safe inclusion in a Gemini prompt.
  ///
  /// - Trims whitespace
  /// - Enforces [maxLength]
  /// - Neutralizes known prompt injection patterns
  /// - Returns the cleaned string
  static String sanitize(String input) {
    var cleaned = input.trim();

    // Enforce max length
    if (cleaned.length > maxLength) {
      cleaned = cleaned.substring(0, maxLength);
    }

    // Neutralize injection patterns by wrapping matched text in brackets
    // so it becomes inert text rather than an instruction
    for (final pattern in _injectionPatterns) {
      cleaned = cleaned.replaceAllMapped(pattern, (match) {
        return '[filtered]';
      });
    }

    return cleaned;
  }
}
