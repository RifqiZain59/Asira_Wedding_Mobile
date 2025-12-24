import 'package:asira/app/modules/home/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:get/get.dart';

// Data dummy tugas
final List<Map<String, dynamic>> initialUrgentTasks = [
  {
    'type': 'Emergency',
    'title': 'Konfirmasi Final Jumlah Tamu',
    'description': 'Batas waktu hari ini jam 17:00 untuk katering.',
    'icon': Icons.gpp_bad_rounded,
    'color': Colors.red.shade700,
    'isCompleted': false,
  },
  {
    'type': 'Warning',
    'title': 'Pelunasan Vendor Dekorasi',
    'description': 'Pembayaran jatuh tempo besok pagi. Segera transfer!',
    'icon': Icons.schedule,
    'color': Colors.amber.shade700,
    'isCompleted': false,
  },
];

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final HomeController controller = Get.put(HomeController());
  final Color primaryTeal = const Color(0xFF00BFA5);

  late DateTime _currentTime;
  late Timer _timer;
  late List<Map<String, dynamic>> _urgentTasks;
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
    _urgentTasks = initialUrgentTasks
        .map((task) => Map<String, dynamic>.from(task))
        .toList();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerHapticFeedback();
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

  void _stopHapticFeedback() {
    if (_isVibrating) {
      if (mounted) {
        setState(() {
          _isVibrating = false;
          if (_urgentTasks.isNotEmpty) _urgentTasks[0]['isCompleted'] = true;
        });
      }
      HapticFeedback.vibrate();
    }
  }

  void _triggerHapticFeedback() async {
    if (_urgentTasks.isEmpty || (_urgentTasks[0]['isCompleted'] as bool))
      return;
    final Map<String, dynamic> currentTask = _urgentTasks[0];
    final Color taskColor = currentTask['color'] as Color;

    await Future.delayed(const Duration(milliseconds: 100));
    if (mounted) setState(() => _isVibrating = true);

    int repeatCount = 0;
    const Duration minimalDelay = Duration(milliseconds: 50);
    const int veryLongDurationInRepeats = 50000;

    if (taskColor == Colors.red.shade700) {
      repeatCount = veryLongDurationInRepeats;
      for (int i = 0; i < repeatCount && _isVibrating; i++) {
        try {
          await HapticFeedback.heavyImpact();
        } catch (e) {
          HapticFeedback.vibrate();
        }
        if (_isVibrating) await Future.delayed(minimalDelay);
      }
    } else if (taskColor == Colors.amber.shade700) {
      repeatCount = veryLongDurationInRepeats ~/ 2;
      for (int i = 0; i < repeatCount && _isVibrating; i++) {
        try {
          await HapticFeedback.mediumImpact();
        } catch (e) {
          HapticFeedback.vibrate();
        }
        if (_isVibrating) await Future.delayed(minimalDelay);
      }
    } else {
      HapticFeedback.lightImpact();
    }

    if (mounted) {
      setState(() {
        _isVibrating = false;
        if (_urgentTasks.isNotEmpty &&
            !(_urgentTasks[0]['isCompleted'] as bool)) {
          _urgentTasks[0]['isCompleted'] = true;
        }
      });
    }
  }

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

  Widget _buildOkButton() {
    return GestureDetector(
      onTap: _stopHapticFeedback,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.green.shade600,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'OK / Selesai',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final Color color = task['color'] as Color;
    final bool isCompleted = task['isCompleted'] as bool;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.grey.shade200 : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCompleted ? Colors.grey.shade400 : color.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCompleted ? Icons.check_circle : task['icon'] as IconData,
                color: isCompleted ? Colors.green : color,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'] as String,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.black54 : color,
                        fontSize: 14,
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task['description'] as String,
                      style: TextStyle(
                        color: isCompleted ? Colors.black38 : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_isVibrating && !isCompleted) ...[
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
    if (_urgentTasks.isEmpty) return const SizedBox.shrink();
    final Map<String, dynamic> currentTask = _urgentTasks[0];
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tugas Mendesak',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 15),
          _buildTaskItem(currentTask),
        ],
      ),
    );
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
    const Color activityTitleColor = Colors.black;
    const Color iconAndDetailColor = Colors.black;

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
                      letterSpacing: 0.5,
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
                  color: activityTitleColor,
                ),
                overflow: TextOverflow.ellipsis,
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
                      color: iconAndDetailColor,
                    ),
                    const SizedBox(width: 8),
                    // ============================================
                    // [PERBAIKAN] Bagian Deskripsi Agar Tidak Terpotong
                    // ============================================
                    Expanded(
                      child: Text(
                        item['detail'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: iconAndDetailColor,
                        ),
                        overflow: TextOverflow
                            .visible, // Biarkan terlihat semua (wrap)
                        // atau gunakan marquee jika pakai package
                        maxLines: 2, // Batasi 2 baris agar rapi
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
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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
            if (controller.isLoading.value)
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              );
            final List<Map<String, dynamic>> currentRundown =
                controller.selectedRundownType.value == 'pagi'
                ? controller.akadRundownList
                : controller.resepsiRundownList;
            if (currentRundown.isEmpty)
              return const Padding(
                padding: EdgeInsets.all(30.0),
                child: Center(
                  child: Text(
                    "Belum ada data acara.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
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
                if (_urgentTasks.isNotEmpty) _buildUrgentTaskCard(),
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
