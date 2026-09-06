import '../core/syntax/ast.dart';
import '../core/syntax/parser.dart';

class ValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int? errorOffset;
  final AstNode? rootNode;

  const ValidationResult.valid(this.rootNode)
      : isValid = true,
        errorMessage = null,
        errorOffset = null;

  const ValidationResult.invalid(this.errorMessage, [this.errorOffset])
      : isValid = false,
        rootNode = null;

  factory ValidationResult.fromParseResult(ParseResult parseResult) {
    if (parseResult.isValid) {
      return ValidationResult.valid(parseResult.root);
    } else {
      return ValidationResult.invalid(
        parseResult.errorMessage ?? 'Syntax Error',
        parseResult.errorOffset,
      );
    }
  }

  @override
  String toString() => isValid ? 'ValidationResult(Valid)' : 'ValidationResult(Invalid: $errorMessage)';
}
