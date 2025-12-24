import 'package:asira/app/data/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // Text Controllers
  final phoneC = TextEditingController();
  final codeC = TextEditingController();

  // State Variables
  var isLoading = false.obs;
  var isCodeVisible = false.obs;
  var userName = ''.obs;

  final ApiService _apiService = ApiService();
  final Color primaryGold = const Color(0xFFEFBF04);

  @override
  void onClose() {
    phoneC.dispose();
    codeC.dispose();
    super.onClose();
  }

  // --- Fungsi Utama Tombol ---
  Future<void> onMainButtonPressed() async {
    if (isCodeVisible.value) {
      await _verifyCodeAndLogin();
    } else {
      await _checkPhone();
    }
  }

  // --- Langkah 1: Cek Nomor HP ---
  Future<void> _checkPhone() async {
    String phoneInput = phoneC.text.trim();

    if (phoneInput.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Nomor HP wajib diisi',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      String cleanNumber = phoneInput.replaceAll(RegExp(r'\D'), '');

      final response = await _apiService.loginByPhone(cleanNumber);

      if (response['status'] == 'success') {
        // [BERHASIL] Tampilkan Input Kode
        isCodeVisible.value = true;
        if (response['data'] != null) {
          userName.value = response['data']['nama'] ?? '';
        }
      } else if (response['status'] == 'not_found') {
        // [GAGAL] Pop Up Nomor Salah
        _showErrorDialog(
          title: "Nomor Tidak Dikenal",
          message:
              "Nomor ini belum terdaftar di sistem undangan kami. Pastikan nomor sudah benar.",
        );
      } else {
        // Error lain
        _showErrorDialog(
          title: "Gagal Memuat",
          message: response['message'] ?? "Terjadi kesalahan sistem.",
        );
      }
    } catch (e) {
      _showErrorDialog(title: "Error Koneksi", message: "Gagal terhubung: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Langkah 2: Verifikasi Kode & Masuk ---
  Future<void> _verifyCodeAndLogin() async {
    String codeInput = codeC.text.trim();

    if (codeInput.isEmpty) {
      Get.snackbar(
        'Perhatian',
        'Kode akses tidak boleh kosong',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await _apiService.loginCrew(codeInput);

      if (response['status'] == 'success') {
        // [SUKSES LOGIN]
        Get.offAllNamed('/home');
        Get.snackbar(
          'Login Berhasil',
          'Selamat datang ${userName.value}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(20),
          borderRadius: 20,
        );
      } else {
        // [GAGAL KODE] Pop Up Kode Salah (Pengganti Navbar/Snackbar)
        _showErrorDialog(
          title: "Kode Akses Salah",
          message:
              "Kode yang Anda masukkan tidak cocok. Silakan periksa kembali.",
        );
      }
    } catch (e) {
      _showErrorDialog(title: "Error", message: "Gagal verifikasi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Reset jika ingin ganti nomor
  void resetState() {
    isCodeVisible.value = false;
    codeC.clear();
    userName.value = '';
  }

  // =======================================================
  // CUSTOM POP UP (DIALOG) YANG LEBIH BAGUS
  // =======================================================
  void _showErrorDialog({required String title, required String message}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon Error Keren
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.red.shade400,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),

              // Judul
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Pesan
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol Tutup
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () => Get.back(), // Tutup Dialog
                  child: const Text(
                    "Coba Lagi",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false, // User wajib klik tombol untuk tutup
    );
  }
}
