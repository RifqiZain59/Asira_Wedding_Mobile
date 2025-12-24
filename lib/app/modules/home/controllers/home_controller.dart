import 'dart:async';
import 'package:asira/app/data/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  // State Rundown
  var isLoading = false.obs;
  var selectedRundownType = 'pagi'.obs;
  var akadRundownList = <Map<String, dynamic>>[].obs;
  var resepsiRundownList = <Map<String, dynamic>>[].obs;

  // State Darurat
  var isEmergency = false.obs;
  var emergencyMessage = ''.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    fetchRundownData(isBackground: false);
    checkEmergencyStatus();
    startAutoRefresh();
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startAutoRefresh() {
    // Refresh data setiap 5 detik
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      fetchRundownData(isBackground: true);
      checkEmergencyStatus();
    });
  }

  // --- CEK STATUS DARI DASHBOARD ---
  void checkEmergencyStatus() async {
    try {
      var response = await _apiService.getDashboardStats();

      if (response['status'] == 'success') {
        var data = response['data'];

        bool newStatus = data['is_emergency'] ?? false;
        String newMsg = data['emergency_message'] ?? '';

        // Update state reactive
        isEmergency.value = newStatus;
        emergencyMessage.value = newMsg;
      }
    } catch (e) {
      print("Error checking emergency: $e");
    }
  }

  // --- MATIKAN DARURAT (AKSI USER) ---
  Future<void> stopEmergencySignal() async {
    bool success = await _apiService.stopEmergency();
    if (success) {
      isEmergency.value = false;
      emergencyMessage.value = '';
      Get.snackbar(
        "Aman",
        "Mode Darurat telah dimatikan.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(20),
      );
    } else {
      Get.snackbar("Gagal", "Gagal menghubungi server.");
    }
  }

  void fetchRundownData({bool isBackground = false}) async {
    if (!isBackground) isLoading.value = true;

    try {
      List<dynamic> data = await _apiService.getRundown();

      List<Map<String, dynamic>> tempAkad = [];
      List<Map<String, dynamic>> tempResepsi = [];

      if (data.isNotEmpty) {
        for (var item in data) {
          var mappedItem = {
            'id': item['id'],
            'time': item['waktu'] ?? '--:--',
            'activity': item['judul'] ?? 'Tanpa Judul',
            'detail': item['deskripsi'] ?? '-',
            'status': item['status'] ?? 'Upcoming',
            'icon': _getIconForActivity(item['judul'] ?? ''),
          };

          String timeStr = item['waktu'].toString();
          int hour = 0;
          if (timeStr.contains(':')) {
            hour = int.tryParse(timeStr.split(':')[0]) ?? 0;
          } else if (timeStr.length >= 2) {
            hour = int.tryParse(timeStr.substring(0, 2)) ?? 0;
          }

          if (hour < 14) {
            tempAkad.add(mappedItem);
          } else {
            tempResepsi.add(mappedItem);
          }
        }

        tempAkad.sort((a, b) => a['time'].compareTo(b['time']));
        tempResepsi.sort((a, b) => a['time'].compareTo(b['time']));
      }

      akadRundownList.assignAll(tempAkad);
      resepsiRundownList.assignAll(tempResepsi);
    } catch (e) {
      print("Error fetching rundown: $e");
    } finally {
      if (!isBackground) isLoading.value = false;
    }
  }

  IconData _getIconForActivity(String title) {
    title = title.toLowerCase();
    if (title.contains('foto')) return Icons.camera_alt_outlined;
    if (title.contains('makan') || title.contains('prasmanan'))
      return Icons.restaurant;
    if (title.contains('masuk') ||
        title.contains('kirab') ||
        title.contains('datang'))
      return Icons.door_front_door;
    if (title.contains('rias') ||
        title.contains('makeup') ||
        title.contains('persiapan'))
      return Icons.palette;
    if (title.contains('akad') || title.contains('janji'))
      return Icons.favorite_border;
    if (title.contains('tamu') || title.contains('salaman'))
      return Icons.people_alt_outlined;
    if (title.contains('doa')) return Icons.volunteer_activism;
    return Icons.access_time_filled;
  }

  void changeRundownType(String type) {
    selectedRundownType.value = type;
  }
}
