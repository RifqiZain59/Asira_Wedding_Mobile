import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Pastikan path import ini sesuai dengan struktur folder Anda
import '../controllers/verifikasi_kode_controller.dart';

class VerifikasiKodeView extends GetView<VerifikasiKodeController> {
  const VerifikasiKodeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Definisi warna emas kustom
    const Color goldPrimary = Color(0xFFD4AF37); // Emas Metalik
    const Color goldLight = Color(0xFFFFDF00); // Emas Terang
    const Color darkBackground = Color(0xFF1A1A1A); // Latar gelap

    return Scaffold(
      backgroundColor: darkBackground,
      appBar: AppBar(
        title: const Text(
          'Verifikasi Akun',
          style: TextStyle(color: goldPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: goldPrimary),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- Ikon Mahkota/Kunci di atas ---
                const Icon(
                  Icons.verified_user_outlined,
                  size: 80,
                  color: goldPrimary,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Masukkan Nomor HP Terdaftar",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 30),

                // --- INPUT FIELD (PHONE NUMBER) ---
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: goldPrimary.withOpacity(0.3), // Efek glow emas
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    // 1. TERHUBUNG KE CONTROLLER
                    controller: controller.phoneController,
                    keyboardType:
                        TextInputType.phone, // Keyboard khusus Angka/HP
                    style: const TextStyle(
                      color: goldPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                    textAlign: TextAlign.center,
                    cursorColor: goldPrimary,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF2C2C2C),
                      hintText: '08xx-xxxx-xxxx', // Hint nomor HP
                      hintStyle: TextStyle(color: goldPrimary.withOpacity(0.3)),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 20,
                      ),
                      // Border saat tidak diklik
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: goldPrimary,
                          width: 1.5,
                        ),
                      ),
                      // Border saat diklik (Fokus)
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: const BorderSide(
                          color: goldLight,
                          width: 2.5,
                        ),
                      ),
                      prefixIcon: const Icon(
                        Icons.phone_android,
                        color: goldPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // --- TOMBOL KONFIRMASI DENGAN OBX (LOADING STATE) ---
                Obx(() {
                  // Mengambil status loading dari controller
                  bool isLoading = controller.isLoading.value;

                  return Container(
                    width: double.infinity,
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLoading
                            ? [
                                Colors.grey,
                                Colors.grey.shade700,
                              ] // Warna saat loading
                            : [goldPrimary, goldLight], // Warna Emas normal
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: (isLoading ? Colors.grey : goldLight)
                              .withOpacity(0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null // Tombol mati saat loading
                          // 2. AKSI SAAT TOMBOL DITEKAN
                          : () => controller.verifikasiNomor(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                color: darkBackground,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'VERIFIKASI SEKARANG',
                              style: TextStyle(
                                color: darkBackground,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
