import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String? _googleMapsApiKey;

  static String get googleMapsApiKey => _googleMapsApiKey ?? '';

  static Future<void> loadEnv() async {
    try {
      await dotenv.load(fileName: ".env");
      _googleMapsApiKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    } catch (e) {
      print('Error loading .env file: $e');
      // Fallback - you can remove this in production
      _googleMapsApiKey = '';
    }
  }
}
