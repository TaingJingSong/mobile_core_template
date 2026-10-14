import 'package:app_base/register.dart';

class AppToastBinding implements ToastBinding {
  BuildContext? _context;

  @override
  void attach(BuildContext context) {
    _context = context;
  }

  @override
  void show(String message) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  void error(String message) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
    }
  }

  @override
  void success(String message) {
    if (_context != null && _context!.mounted) {
      ScaffoldMessenger.of(_context!).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green));
    }
  }
}
