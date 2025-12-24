import 'package:asira/app/data/api_service.dart';
import 'package:asira/app/modules/verifikasi_kode/views/verifikasi_kode_view.dart'; // Pastikan import ini ada
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  // 1. Text Controller
  final phoneC = TextEditingController();

  // 2. State Loading
  var isLoading = false.obs;

  // 3. Instance Service
  final ApiService _apiService = ApiService();

  // Warna Brand
  final Color primaryGold = const Color(0xFFEFBF04);

  @override
  void onClose() {
    phoneC.dispose();
    super.onClose();
  }

  // --- Fungsi Validasi & Login ---
  Future<void> login() async {
    // A. Validasi Input
    String rawInput = phoneC.text.trim();

    if (rawInput.isEmpty) {
      Get.snackbar(
        'Error',
        'Nomor HP tidak boleh kosong',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    String cleanNumber = rawInput.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.length < 9) {
      Get.snackbar(
        'Error',
        'Nomor HP terlalu pendek (min 9 digit)',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }

    String finalPhoneNumber = "62$cleanNumber";

    // B. Proses Login API
    isLoading.value = true;

    try {
      // --- SIMULASI RESPON API ---
      await Future.delayed(const Duration(seconds: 2));
      final response = {
        'status': finalPhoneNumber == '6281234567890' ? 'not_found' : 'success',
        'message': finalPhoneNumber == '6281234567890'
            ? 'User belum terdaftar'
            : 'Login Berhasil',
      };
      // ---------------------------

      // C. Cek Respon
      if (response['status'] == 'success') {
        // KASUS 1: SUKSES LOGIN
        // Pop Up dihapus, langsung pindah halaman
        Get.to(() => const VerifikasiKodeView());
      } else if (response['status'] == 'not_found') {
        // KASUS 2: BELUM TERDAFTAR (Pop Up ini tetap ada)
        await _showUnregisteredDialog(finalPhoneNumber);
      } else {
        // KASUS 3: ERROR LAINNYA
        Get.snackbar(
          'Gagal',
          response['message'] ?? 'Login Gagal',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- Dialog Belum Terdaftar (Tetap Ada) ---
  Future<void> _showUnregisteredDialog(String phone) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(25),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_alt_1_rounded,
                color: Colors.orange,
                size: 50,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nomor Belum Terdaftar',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Nomor +$phone belum terdaftar di sistem kami. Apakah Anda ingin mendaftar?',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),

            // Tombol Daftar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  Get.back(); // Tutup dialog
                  Get.snackbar("Info", "Arahkan ke halaman Register disini");
                },
                child: const Text(
                  'Daftar Sekarang',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Tombol Batal
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: true,
    );
  }
}
