import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String kBaseUrl = 'http://192.168.0.135:8088/api'; // development
  // static const String kBaseUrl = 'http://160.187.80.165:8080/api'; // production
  // static const String kBaseUrl = 'http://192.168.0.135:5175/api'; // Dhruvbhai debugging
  static const String kBaseUrl =
      'http://192.168.0.145:5111/api'; // Dhruvilbhai debugging

  static Future<dynamic> getRequest({
    required String endpoint,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      final url = Uri.parse(
        '$kBaseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      headers ??= {'Content-Type': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 204) {
        return null;
      }

      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/pdf')) {
        return response.bodyBytes;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        var errorResponse = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'error': 'Unknown error occurred'};
        throw errorResponse['error'] ??
            'Failed to load. Please try again later.';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  static Future<dynamic> postRequest({
    required String endpoint,
    required Map<String, dynamic> requestBody,
    Map<String, String>? queryParams,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      Uri url = Uri.parse('$kBaseUrl$endpoint');

      if (queryParams != null && queryParams.isNotEmpty) {
        url = url.replace(queryParameters: queryParams);
      }

      headers ??= {'Content-Type': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 204) {
        return null;
      }

      final contentType = response.headers['content-type'];
      if (contentType != null && contentType.contains('application/pdf')) {
        return response.bodyBytes;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }

      var errorResponse = response.body.isNotEmpty
          ? json.decode(response.body)
          : {'error': 'Unknown error occurred'};

      if (response.statusCode == 403) {
        throw {'status': 403, 'message': errorResponse['error']};
      }

      if (response.statusCode == 402) {
        throw {'status': 402, 'message': errorResponse['error']};
      }

      throw {
        'status': response.statusCode,
        'message':
            errorResponse['error'] ??
            'Failed to process request. Please try again later.',
      };
    } catch (e) {
      if (e is Map<String, dynamic>) {
        rethrow;
      }
      throw {'status': 500, 'message': e.toString()};
    }
  }

  static Future<dynamic> postFormData({
    required String endpoint,
    required Map<String, String> fields,
    required List<http.MultipartFile> files,
    Map<String, String>? headers,
    String? token,
  }) async {
    try {
      Uri url = Uri.parse('$kBaseUrl$endpoint');

      var request = http.MultipartRequest('POST', url);

      headers ??= {};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
      request.headers.addAll(headers);

      request.fields.addAll(fields);

      request.files.addAll(files);

      final response = await request.send();

      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(responseBody);
      } else {
        var errorResponse = responseBody.isNotEmpty
            ? json.decode(responseBody)
            : {'error': 'Unknown error occurred'};

        throw {
          'status': response.statusCode,
          'message': errorResponse['error'] ?? 'Failed to process request.',
        };
      }
    } catch (e) {
      throw {'status': 500, 'message': e.toString()};
    }
  }
}
