/// ════════════════════════════════════════════════════════════
/// DEEP LINK SERVICE CONTRACT
/// ════════════════════════════════════════════════════════════
abstract interface class DeepLinkService {
  void initialize();
  void dispose();
}

/// Default no-op deep link service implementation.
/// Replace or extend per project with app_links, uni_links, etc.
class DeepLinkServiceImpl implements DeepLinkService {
  @override
  void initialize() {}

  @override
  void dispose() {}
}
