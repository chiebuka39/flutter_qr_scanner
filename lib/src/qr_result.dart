class QrResult {
  final String code;
  final bool success;
  final String message;

  QrResult(this.code, this.success, this.message);

  @override
  String toString() {
    return 'QrResult{code: $code, success: $success, mesaage: $message}';
  }
}