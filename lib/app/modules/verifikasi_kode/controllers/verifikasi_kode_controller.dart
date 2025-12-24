import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Pastikan import ini mengarah ke file ApiService Anda yang sudah ada .trim()-nya
import 'package:asira/app/data/api_service.dart';
// Jika Anda punya file routes, import juga (opsional)
// import 'package:asira/app/routes/app_pages.dart';

class VerifikasiKodeController extends GetxController {
  // Instance ApiService
  final ApiService _apiService = ApiService();

  // Controller untuk Input TextField Nomor HP
  final TextEditingController phoneController = TextEditingController();

  // Variable Observable untuk status loading
  var isLoading = false.obs;

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  // Fungsi untuk memverifikasi nomor HP
  Future<void> verifikasiNomor() async {
    // Tambahan .trim() di sini juga untuk keamanan ganda
    String phoneNumber = phoneController.text.trim();

    // 1. Validasi input kosong
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        "Peringatan",
        "Nomor HP harus diisi",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
      );
      return;
    }

    try {
      isLoading.value = true; // Mulai loading

      // Debug: Cek di console apa yang dikirim
      print("Mengirim request login untuk: $phoneNumber");

      // 2. Panggil API
      final response = await _apiService.loginByPhone(phoneNumber);

      isLoading.value = false; // Selesai loading

      // Debug: Cek respon mentah dari backend
      print("Response dari Server: $response");

      // 3. Cek Status Response
      if (response['status'] == 'success') {
        // --- JIKA BERHASIL ---

        // Ambil data user dari respon (sesuai struktur JSON Python tadi)
        final userData = response['data'];
        final String namaUser = userData != null ? userData['nama'] : 'Crew';

        Get.snackbar(
          "Login Berhasil",
          "Selamat datang, $namaUser!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );

        // --- SIMPAN SESSION & NAVIGASI ---
        // TODO: Simpan data user ke penyimpanan lokal (GetStorage/SharedPreferences) jika perlu

        // Jeda sebentar agar user sempat baca snackbar sebelum pindah
        await Future.delayed(const Duration(seconds: 1));

        // Pindah ke Dashboard (Hapus history halaman login agar tidak bisa back)
        // Ganti '/dashboard' dengan nama route halaman utama Anda (misal: Routes.HOME)
        Get.offAllNamed('/dashboard');
      } else {
        // --- JIKA GAGAL (Status Error dari Backend) ---
        _showErrorPopup(response['message'] ?? "Nomor HP tidak terdaftar.");
      }
    } catch (e) {
      isLoading.value = false;
      // Menampilkan error jika koneksi putus atau masalah teknis lain
      _showErrorPopup("Gagal terhubung ke server.\nDetail: $e");
      print("Error Exception: $e");
    }
  }

  // Helper untuk menampilkan Pop Up Error
  void _showErrorPopup(String message) {
    Get.defaultDialog(
      title: "Verifikasi Gagal",
      titleStyle: const TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black87),
        ),
      ),
      textConfirm: "Coba Lagi",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        Get.back(); // Tutup dialog
      },
      barrierDismissible: false,
      radius: 15,
    );
  }
}
