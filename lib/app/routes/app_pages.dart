import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/verifikasi_kode/bindings/verifikasi_kode_binding.dart';
import '../modules/verifikasi_kode/views/verifikasi_kode_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.VERIFIKASI_KODE;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.VERIFIKASI_KODE,
      page: () => const VerifikasiKodeView(),
      binding: VerifikasiKodeBinding(),
    ),
  ];
}
