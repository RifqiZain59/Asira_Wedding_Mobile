import 'package:asira/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = Get.find<HomeController>();
  final Color primaryTeal = const Color(0xFF00BFA5);

  late DateTime _currentTime;
  late Timer _timer;

  // State lokal untuk getaran
  bool _isVibrating = false;

  final List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  final List<String> _months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);

    // Listener: Jika Controller mendeteksi SOS (dari server), picu getaran
    ever(controller.isEmergency, (bool isEmergency) {
      if (isEmergency) {
        _triggerHapticFeedback();
      } else {
        _stopHapticFeedback();
      }
    });

    // Cek kondisi awal saat aplikasi dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.isEmergency.value) {
        _triggerHapticFeedback();
      }
    });
  }

  void _updateTime(Timer timer) {
    if (mounted) setState(() => _currentTime = DateTime.now());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // --- LOGIKA GETARAN (HAPTIC) ---
  void _stopHapticFeedback() {
    if (_isVibrating) {
      if (mounted) {
        setState(() {
          _isVibrating = false;
        });
      }
      HapticFeedback.vibrate();
    }
  }

  void _triggerHapticFeedback() async {
    if (_isVibrating) return;

    if (mounted) setState(() => _isVibrating = true);

    const Duration minimalDelay = Duration(milliseconds: 500);

    while (_isVibrating && mounted) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();

      await Future.delayed(minimalDelay);

      // Jika status di controller sudah false (dimatikan admin lain), stop getar
      if (!controller.isEmergency.value) {
        _stopHapticFeedback();
        break;
      }
    }
  }

  // --- UI COMPONENTS ---

  Widget _buildCurrentTimeCard() {
    final now = _currentTime;
    final timeHoursMinutes =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final timeSeconds = now.second.toString().padLeft(2, '0');
    final dayName = _days[now.weekday - 1];
    final monthName = _months[now.month - 1];
    final dateString = '$dayName, ${now.day} $monthName ${now.year}';
    const Color blackColor = Colors.black;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Waktu Sekarang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    timeHoursMinutes,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: blackColor,
                    ),
                  ),
                  const Text(
                    ':',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: blackColor,
                    ),
                  ),
                  Text(
                    timeSeconds,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: blackColor,
                    ),
                  ),
                ],
              ),
              Text(
                dateString,
                style: const TextStyle(
                  fontSize: 14,
                  color: blackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Rundown Pernikahan Anda',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
              SizedBox(height: 4),
              Text(
                "Acara Utama",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          Obx(() {
            bool hasLiveEvent =
                controller.akadRundownList.any((e) => e['status'] == 'Live') ||
                controller.resepsiRundownList.any((e) => e['status'] == 'Live');

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: hasLiveEvent
                    ? primaryTeal.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasLiveEvent ? primaryTeal : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.circle,
                    color: hasLiveEvent ? primaryTeal : Colors.grey,
                    size: 8,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Event Live',
                    style: TextStyle(
                      color: hasLiveEvent ? primaryTeal : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // [UPDATED] Tombol OK sekarang mematikan Alarm ke Server
  Widget _buildOkButton() {
    return GestureDetector(
      onTap: () async {
        // 1. Matikan getar lokal dulu agar user tenang
        _stopHapticFeedback();
        // 2. Panggil API untuk mematikan status darurat di server (Admin)
        await controller.stopEmergencySignal();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.stop_circle_outlined,
              color: Colors.red.shade700,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Matikan Alarm & Lapor Aman',
              style: TextStyle(
                color: Colors.red.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final Color color = task['color'] as Color;
    final bool isEmergency = task['type'] == 'Emergency';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: isEmergency ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ikon berdenyut jika SOS
              isEmergency
                  ? TweenAnimationBuilder(
                      tween: Tween<double>(begin: 1.0, end: 1.2),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, scale, child) {
                        return Transform.scale(scale: scale, child: child);
                      },
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: color,
                        size: 30,
                      ),
                    )
                  : Icon(task['icon'], color: color, size: 24),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: isEmergency ? 16 : 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task['description'],
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: isEmergency
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_isVibrating && isEmergency) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildOkButton()],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUrgentTaskCard() {
    return Obx(() {
      Map<String, dynamic> currentTask;
      String headerTitle;
      Color cardColor;
      Color textColor;

      if (controller.isEmergency.value) {
        // --- TAMPILAN SOS / DARURAT ---
        headerTitle = "⚠️ STATUS DARURAT ⚠️";
        cardColor = Colors.red.shade50;
        textColor = Colors.red.shade800;

        currentTask = {
          'type': 'Emergency',
          'title': 'SOS / PERINGATAN',
          'description': controller.emergencyMessage.value.isNotEmpty
              ? controller.emergencyMessage.value
              : "Terjadi kondisi darurat. Segera berkumpul.",
          'icon': Icons.warning_amber_rounded,
          'color': Colors.red.shade700,
        };
      } else {
        // --- TAMPILAN AMAN (NORMAL) ---
        headerTitle = "Status Keamanan";
        cardColor = Colors.white;
        textColor = Colors.green.shade800;

        currentTask = {
          'type': 'Safe',
          'title': 'Tidak Ada Darurat',
          'description': 'Situasi saat ini aman terkendali.',
          'icon': Icons.verified_user_rounded,
          'color': Colors.green.shade600,
        };
      }

      return Container(
        margin: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: controller.isEmergency.value
              ? Border.all(color: Colors.red.shade200)
              : Border.all(color: Colors.green.shade100),
          boxShadow: [
            BoxShadow(
              color: controller.isEmergency.value
                  ? Colors.red.withOpacity(0.2)
                  : Colors.green.withOpacity(0.05),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              headerTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 15),
            _buildTaskItem(currentTask),
          ],
        ),
      );
    });
  }

  Widget _buildRundownSelector() {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _buildSelectionChip('Akad Nikah Pagi', 'pagi')),
          Expanded(child: _buildSelectionChip('Resepsi Malam', 'malam')),
        ],
      ),
    );
  }

  Widget _buildSelectionChip(String label, String value) {
    return Obx(() {
      final bool isSelected = controller.selectedRundownType.value == value;
      return GestureDetector(
        onTap: () => controller.changeRundownType(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? primaryTeal : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildRundownItem(Map<String, dynamic> item, int index) {
    final bool isLiveEvent = (item['status'] ?? '') == 'Live';
    Color timeColor = isLiveEvent ? primaryTeal : Colors.black;

    Widget rowContent = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['time'] as String,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: timeColor,
                ),
              ),
              const SizedBox(height: 4),
              if (isLiveEvent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Live',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const SizedBox(height: 18),
            ],
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['activity'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200, width: 1),
                ),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 14,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['detail'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    if (isLiveEvent) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20.0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: primaryTeal.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryTeal, width: 1.5),
        ),
        child: rowContent,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: rowContent,
    );
  }

  Widget _buildRundownSection() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rundown Acara',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, size: 20, color: Colors.grey),
                onPressed: () => controller.fetchRundownData(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildRundownSelector(),
          const SizedBox(height: 15),
          Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            final List<Map<String, dynamic>> currentRundown =
                controller.selectedRundownType.value == 'pagi'
                ? controller.akadRundownList
                : controller.resepsiRundownList;
            if (currentRundown.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Center(
                  child: Text(
                    "Belum ada data acara.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }
            return Column(
              children: List.generate(
                currentRundown.length,
                (index) => _buildRundownItem(currentRundown[index], index),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(),
                _buildCurrentTimeCard(),
                _buildUrgentTaskCard(),
                _buildRundownSection(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
