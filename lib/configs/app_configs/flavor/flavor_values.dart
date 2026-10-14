/// ════════════════════════════════════════════════════════════
/// FLAVOR VALUES
/// ════════════════════════════════════════════════════════════
/// Typed container for a single flavor's values. One instance
/// per environment. No magic strings, no null casts.
class FlavorValues {
  const FlavorValues({required this.name, required this.url, required this.firebaseRoot, required this.distance, this.socketUrl});

  /// Short name, e.g. 'dev', 'qas', 'pre', ''.
  final String name;

  /// API base URL.
  final String url;

  /// Optional websocket URL.
  final String? socketUrl;

  /// Firebase remote-config root.
  final String firebaseRoot;

  /// Geofencing distance (or similar).
  final int distance;
}
