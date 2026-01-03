import 'dart:math';
import '../database/database.dart';

class IdGenerator {
  static final _random = Random();
  static const _userIdKey = 'user_id';

  /// Generates a user ID in format: ABC-123 (3 uppercase letters - 3 digits)
  static String _generateNewId() {
    final letters = List.generate(
      3,
      (_) => String.fromCharCode(65 + _random.nextInt(26)), // A-Z
    ).join();

    final digits = List.generate(
      3,
      (_) => _random.nextInt(10).toString(), // 0-9
    ).join();

    return '$letters-$digits';
  }

  /// Gets or creates a persistent user ID using Drift database
  static Future<String> getUserId(AppDatabase database) async {
    String? userId = await database.getSetting(_userIdKey);

    if (userId == null) {
      userId = _generateNewId();
      await database.setSetting(_userIdKey, userId);
    }

    return userId;
  }

  /// Resets the user ID (for testing or user request)
  static Future<void> resetUserId(AppDatabase database) async {
    final newId = _generateNewId();
    await database.setSetting(_userIdKey, newId);
  }
}
