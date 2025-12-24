import 'package:asira/app/modules/login/controllers/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi Controller
    final controller = Get.put(LoginController());

    // Warna & Aset
    final Color primaryGold = const Color(0xFFEFBF04);
    const String assetImagePath = 'assets/logo asira 2.png';

    // --- Header ---
    Widget buildHeader() {
      return Column(
        children: [
          Image.asset(
            assetImagePath,
            height: 60,
            errorBuilder: (c, o, s) => const SizedBox(),
          ),
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: Obx(
              () => Text(
                controller.userName.value.isNotEmpty
                    ? 'Halo, ${controller.userName.value}'
                    : 'Selamat Datang',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: primaryGold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Masuk menggunakan nomor terdaftar.',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
        ],
      );
    }

    // --- Input Nomor HP ---
    Widget buildPhoneInput() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Nomor Telepon",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.phoneC,
            keyboardType: TextInputType.phone,
            onChanged: (val) {
              if (controller.isCodeVisible.value) controller.resetState();
            },
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: '0812xxxx',
              filled: true,
              fillColor: Colors.grey.shade50, // Warna Putih/Abu terang
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryGold, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    // --- Input Kode (DI BAWAH HP) ---
    Widget buildCodeInput() {
      return Obx(() {
        if (!controller.isCodeVisible.value) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Kode Akses",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                InkWell(
                  onTap: () => controller.resetState(),
                  child: Text(
                    "Bukan Anda?",
                    style: TextStyle(color: Colors.red.shade300, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller.codeC,
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'KODE',
                filled: true,
                // [PERBAIKAN] Disamakan dengan inputan nomor HP (sebelumnya orange)
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: primaryGold, width: 2),
                ),
                prefixIcon: Icon(Icons.vpn_key_rounded, color: primaryGold),
              ),
            ),
          ],
        );
      });
    }

    // --- Tombol Aksi ---
    Widget buildActionButton() {
      return Obx(
        () => SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: controller.isLoading.value
                ? null
                : () => controller.onMainButtonPressed(),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGold,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    height: 25,
                    width: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : Text(
                    controller.isCodeVisible.value ? 'Masuk' : 'Cek Nomor',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        // [PERBAIKAN] Navbar HP menjadi Putih
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const SizedBox(height: 40),
                buildHeader(),
                const SizedBox(height: 40),
                buildPhoneInput(),
                buildCodeInput(),
                const SizedBox(height: 40),
                buildActionButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
