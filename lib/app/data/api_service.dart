import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // =======================================================================
  // KONFIGURASI KONEKSI
  // [PERBAIKAN]:
  // 1. Hapus spasi di depan 'https'
  // 2. Pastikan path '/api/mobile' ada di akhir
  // =======================================================================
  static const String baseUrl =
      'https://undepraved-jaiden-nonflexibly.ngrok-free.dev/api/mobile';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // --- 1. Login Crew ---
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

  // --- 2. Login Phone ---
  Future<Map<String, dynamic>> loginByPhone(String phoneNumber) async {
    try {
      final url = Uri.parse('$baseUrl/login-phone');
      print("Mencoba login ke: $url");
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'phone_number': phoneNumber}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal koneksi: $e'};
    }
  }

  // --- 3. Rundown (Ini yang bikin Error 404 jika Endpoint di Python tidak ada) ---
  Future<List<dynamic>> getRundown() async {
    return await _getListData('$baseUrl/rundown');
  }

  // --- 4. Dashboard Stats ---
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: _headers,
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal memuat dashboard: $e'};
    }
  }

  // --- Helper Internal ---
  Future<List<dynamic>> _getListData(String url) async {
    try {
      print("Fetching list from: $url");
      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.body.trim().startsWith("<")) {
        print("HTML Response (Error 404/500): ${response.body}");
        return [];
      }

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json is Map<String, dynamic> && json['status'] == 'success') {
          return json['data'] ?? [];
        }
      }
      return [];
    } catch (e) {
      print("Error fetching list: $e");
      return [];
    }
  }

  Map<String, dynamic> _processResponse(http.Response response) {
    if (response.body.isEmpty || response.body.trim().startsWith("<")) {
      return {
        'status': 'error',
        'message': 'Server Error (Code: ${response.statusCode})',
      };
    }
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode >= 400 && data['status'] != 'error') {
        return {
          'status': 'error',
          'message': data['message'] ?? 'Terjadi kesalahan',
        };
      }
      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Format respon tidak valid: $e'};
    }
  }
}
