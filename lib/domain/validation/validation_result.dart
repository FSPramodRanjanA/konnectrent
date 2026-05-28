/// Sealed result of input validation. Never throws, never returns null.
sealed class ValidationResult {
  const ValidationResult();
}

/// All fields are valid.
final class Valid extends ValidationResult {
  const Valid();
}

/// One or more fields are invalid. [fieldErrors] maps field name → error message.
final class Invalid extends ValidationResult {
  const Invalid(this.fieldErrors);
  final Map<String, String> fieldErrors;
}
