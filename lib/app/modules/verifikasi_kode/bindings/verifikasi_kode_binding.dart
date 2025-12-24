import 'package:get/get.dart';

import '../controllers/verifikasi_kode_controller.dart';

class VerifikasiKodeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerifikasiKodeController>(
      () => VerifikasiKodeController(),
    );
  }
}
