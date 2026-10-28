import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl =
      "https://maddie-prejournalistic-unconvincedly.ngrok-free.dev/service_api/";

  static const Map<String, String> jsonHeaders = {
    "ngrok-skip-browser-warning": "true",
    "Content-Type": "application/json",
  };

  static const Map<String, String> getHeaders = {
    "ngrok-skip-browser-warning": "true",
  };

  static const Map<String, String> formHeaders = {
    "ngrok-skip-browser-warning": "true",
    "Content-Type": "application/x-www-form-urlencoded",
  };

  static Map<String, dynamic> _parseResponse(http.Response response) {
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Server returned status ${response.statusCode}. '
        'Check that your ngrok tunnel is running.',
      );
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw Exception('Unexpected response format from server.');
    } on FormatException {
      throw Exception(
        'Server did not return valid JSON. '
        'The ngrok tunnel may be offline or the PHP script has an error.',
      );
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}login.php'),
            headers: formHeaders,
            body: {"email": email, "password": password},
          )
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again.');
    } on FormatException {
      throw Exception('Bad response from server.');
    }
  }

  static Future<Map<String, dynamic>> adminLogin(
    String username,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}admin_login.php'),
            headers: formHeaders,
            body: {"username": username, "password": password},
          )
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again.');
    } on FormatException {
      throw Exception('Bad response from server.');
    }
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}register.php'),
            headers: formHeaders,
            body: {
              "name": name,
              "email": email,
              "password": password,
              "phone": phone,
              "address": address,
            },
          )
          .timeout(const Duration(seconds: 15));

      print("=== REGISTER DEBUG ===");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");
      print("=====================");

      return _parseResponse(response);
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again.');
    } on FormatException {
      throw Exception('Bad response from server.');
    }
  }

  static Future<http.Response> _getWithRetry(String url, {int retries = 3}) async {
    for (int i = 0; i < retries; i++) {
      try {
        final response = await http
            .get(Uri.parse(url), headers: getHeaders)
            .timeout(const Duration(seconds: 15));
        return response;
      } on http.ClientException catch (e) {
        if (i == retries - 1) rethrow; // last attempt, throw it
        await Future.delayed(Duration(seconds: 2 * (i + 1))); // wait 2s, 4s, 6s
      }
    }
    throw Exception('Failed after $retries retries');
  }

  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _getWithRetry('${baseUrl}category');
      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}.');
      }
      final decoded = jsonDecode(response.body);
      // Response: {"category": [...]}
      final List<dynamic> list = decoded['category'] ?? [];
      return list.cast<Map<String, dynamic>>();
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again.');
    } on FormatException {
      throw Exception('Bad response from server.');
    }
  }

  static Future<List<Map<String, dynamic>>> getServicesByCategory(int categoryId) async {
    try {
      final response = await _getWithRetry('${baseUrl}category/$categoryId');
      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}.');
      }
      final decoded = jsonDecode(response.body);
      // Response: {"category": {"services": [...]}}
      final List<dynamic> list =
          decoded['category']?['services'] ?? decoded['services'] ?? [];
      return list.cast<Map<String, dynamic>>();
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again.');
    } on FormatException {
      throw Exception('Bad response from server.');
    }
  }

  static Future<List<Map<String, dynamic>>> getBookingHistory(
    int userId,
  ) async {
    try {
      final response = await http
          .get(
            Uri.parse('${baseUrl}get_booking_history.php?user_id=$userId'),
            headers: getHeaders,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Server returned status ${response.statusCode}.');
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['success'] == true) {
        final list = decoded['bookings'];
        if (list is List) {
          return list.cast<Map<String, dynamic>>();
        }
      }
      return []; // returns empty list if no bookings
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again.');
    } on FormatException {
      throw Exception('Bad response from server.');
    }
  }

  static Future<Map<String, dynamic>> createBooking({
    required int userId,
    required String bookingDate,
    required String bookingTime,
    required String phone,
    required String address,
    required double totalAmount,
    required List<Map<String, dynamic>> services,
    String status = 'Pending',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}create_booking.php'),
            headers: jsonHeaders,
            body: jsonEncode({
              'user_id': userId,
              'booking_date': bookingDate,
              'booking_time': bookingTime,
              'phone': phone,
              'address': address,
              'status': status,
              'total_amount': totalAmount,
              'services': services,
            }),
          )
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again.');
    } on FormatException {
      throw Exception('Bad response from server.');
    }
  }

  static Future<Map<String, dynamic>> cancelBooking(String bookingId) async {
    try {
      final response = await http
          .post(
            Uri.parse('${baseUrl}cancel_booking.php'),
            headers: jsonHeaders,
            body: jsonEncode({'booking_id': bookingId}),
          )
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again.');
    }
  }

  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
      final response = await http
          .get(
            Uri.parse('${baseUrl}get_user_profile.php?user_id=$userId'),
            headers: getHeaders,
          )
          .timeout(const Duration(seconds: 15));
      return _parseResponse(response);
    } on SocketException {
      throw Exception('No internet connection.');
    } on HttpException {
      throw Exception('Could not reach the server. Try again.');
    } on FormatException {
      throw Exception('Bad response from server.');
    }
  }
}
