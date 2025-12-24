import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // =======================================================================
  // KONFIGURASI KONEKSI
  // Ganti URL ini dengan URL Ngrok/IP Lokal terbaru Anda
  // Pastikan akhiran URL adalah '/api/mobile' sesuai setting di Flask
  // =======================================================================
  static const String baseUrl =
      ' https://undepraved-jaiden-nonflexibly.ngrok-free.dev';

  // Getter header standar
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // =======================================================================
  // 1. AUTH CREW (LOGIN)
  // =======================================================================

  // Endpoint: /api/mobile/crew/login
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

  // =======================================================================
  // 2. DASHBOARD
  // =======================================================================

  // Endpoint: /api/mobile/dashboard
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

  // =======================================================================
  // 3. MANAJEMEN TAMU (GUEST BOOK)
  // =======================================================================

  // Endpoint: /api/mobile/tamu (GET)
  // Mendukung filter pencarian nama & kategori
  Future<List<dynamic>> getTamu({String? search, String? kategori}) async {
    List<String> queryParams = [];

    if (search != null && search.isNotEmpty) {
      queryParams.add('search=${Uri.encodeComponent(search)}');
    }
    if (kategori != null && kategori.isNotEmpty) {
      queryParams.add('kategori=${Uri.encodeComponent(kategori)}');
    }

    String queryString = '';
    if (queryParams.isNotEmpty) {
      queryString = '?${queryParams.join('&')}';
    }

    // Menggunakan helper _getListData
    return await _getListData('$baseUrl/tamu$queryString');
  }

  // Endpoint: /api/mobile/tamu (POST)
  Future<Map<String, dynamic>> addTamu(
    String nama,
    String noHp, {
    String kategori = 'Reguler',
    String meja = '-',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tamu'),
        headers: _headers,
        body: jsonEncode({
          'nama': nama,
          'no_hp': noHp,
          'kategori': kategori,
          'meja': meja,
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal tambah tamu: $e'};
    }
  }

  // =======================================================================
  // 4. SCAN QR CODE & CHECK-IN
  // =======================================================================

  // Endpoint: /api/mobile/scan
  Future<Map<String, dynamic>> scanQr(String qrContent) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/scan'),
        headers: _headers,
        body: jsonEncode({'qr_content': qrContent}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Error Scan: $e'};
    }
  }

  // =======================================================================
  // 5. RUNDOWN ACARA
  // =======================================================================

  // Endpoint: /api/mobile/rundown
  Future<List<dynamic>> getRundown() async {
    return await _getListData('$baseUrl/rundown');
  }

  // =======================================================================
  // 6. HADIAH (GIFTS)
  // =======================================================================

  // Endpoint: /api/mobile/gifts (GET)
  Future<List<dynamic>> getGifts() async {
    return await _getListData('$baseUrl/gifts');
  }

  // Endpoint: /api/mobile/gifts (POST)
  Future<Map<String, dynamic>> addGift({
    required String noAmplop,
    required String namaPengirim,
    String jenis = 'Amplop',
    String keterangan = '',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/gifts'),
        headers: _headers,
        body: jsonEncode({
          'no_amplop': noAmplop,
          'nama_pengirim': namaPengirim,
          'jenis': jenis,
          'keterangan': keterangan,
        }),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal simpan hadiah: $e'};
    }
  }

  // =======================================================================
  // HELPER INTERNAL (PRIVATE)
  // =======================================================================

  // Helper untuk mengambil data List (Array)
  Future<List<dynamic>> _getListData(String url) async {
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);

      // Cek jika response HTML (bukan JSON) - biasanya error server/ngrok
      if (response.body.trim().startsWith("<")) return [];

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Backend Asira mengembalikan format {status: success, data: [...]}
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

  // Tambahkan ini di dalam class ApiService
  // Di dalam api_service.dart

  Future<Map<String, dynamic>> loginByPhone(String phoneNumber) async {
    try {
      // PERHATIKAN BARIS INI:
      // Pastikan ada '/api/mobile' sebelum '/login-phone'
      // Gunakan .trim() untuk membuang spasi tidak sengaja
      final url = Uri.parse('$baseUrl/login-phone'.trim());

      // Jika Anda menulis URL manual (Hardcode), pastikan formatnya:
      // 'https://url-ngrok-anda.ngrok-free.app/api/mobile/login-phone'

      print("Mencoba login ke: $url"); // Cek di console apakah URL sudah benar

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({'phone_number': phoneNumber}),
      );
      return _processResponse(response);
    } catch (e) {
      return {'status': 'error', 'message': 'Gagal login: $e'};
    }
  }

  // Helper untuk memproses respon Object/Map
  Map<String, dynamic> _processResponse(http.Response response) {
    // Cek error HTML/Server Down
    if (response.body.isEmpty || response.body.trim().startsWith("<")) {
      return {
        'status': 'error',
        'message': 'Server Error (Status: ${response.statusCode})',
      };
    }

    try {
      final data = jsonDecode(response.body);

      // Jika status code bukan 200/201, paksa return error jika backend belum handle
      if (response.statusCode >= 400 && data['status'] != 'error') {
        return {
          'status': 'error',
          'message':
              data['message'] ??
              'Terjadi kesalahan (Code: ${response.statusCode})',
        };
      }

      return data;
    } catch (e) {
      return {'status': 'error', 'message': 'Format respon tidak valid: $e'};
    }
  }
}
