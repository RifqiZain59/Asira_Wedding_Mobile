import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // GANTI URL INI DENGAN URL NGROK/HOSTING ANDA
  static const String baseUrl =
      'https://undepraved-jaiden-nonflexibly.ngrok-free.dev/api/mobile';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // 1. LOGIN CREW
  Future<Map<String, dynamic>> loginCrew(String kodeAkses) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/crew/login'),
        headers: _headers,
        body: jsonEncode({'kode_akses': kodeAkses}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal login: $e'};
    }
  }

  // 2. LOGIN PHONE
  Future<Map<String, dynamic>> loginByPhone(String phoneNumber) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login-phone'),
        headers: _headers,
        body: jsonEncode({'phone_number': phoneNumber}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal koneksi: $e'};
    }
  }

  // 3. GET RUNDOWN
  Future<List<dynamic>> getRundown() async {
    return await _getListData('$baseUrl/rundown');
  }

  // 4. DASHBOARD & STATUS DARURAT
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: _headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': '$e'};
    }
  }

  // 5. STOP EMERGENCY (Matikan Alarm)
  Future<bool> stopEmergency() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/emergency/stop'),
        headers: _headers,
      );
      final data = _processResponse(response);
      return data['status'] == 'success';
    } catch (e) {
      print("Error stopping emergency: $e");
      return false;
    }
  }

  // HELPER
  Future<List<dynamic>> _getListData(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map && json['status'] == 'success') {
          return json['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.body.isEmpty || response.body.trim().startsWith("<")) {
      return {'status': 'error', 'message': 'Server Error / HTML Response'};
    }
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 400) {
        return {'status': 'error', 'message': data['message'] ?? 'Error'};
      }
      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Format salah: $e'};
    }
  }
}
