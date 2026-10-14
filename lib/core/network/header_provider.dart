/// Provides headers for outgoing requests.
/// The app implements this using its own auth/token storage.
abstract interface class HeaderProvider {
  Future<Map<String, dynamic>> build({bool isFormData = false});
}
