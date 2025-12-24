import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
// Asumsi path ke LoginView yang sudah kita buat sebelumnya
// import 'package:asira/app/modules/login/views/login_view.dart'; // Sudah tidak digunakan lagi

// =============================================================================
// 🔥 DATA DUMMY (Global Scope yang TIDAK BERUBAH)
// =============================================================================

// Data untuk Akad Nikah / Pagi
final List<Map<String, dynamic>> akadRundown = [
  {
    'time': '07:00',
    'activity': 'Persiapan & Rias Pengantin',
    'detail': 'Lokasi: Bridal Suite A',
    'icon': Icons.access_time_filled,
  },
  {
    'time': '08:00',
    'activity': 'Sesi Foto Keluarga Inti',
    'detail': 'Fotografer & EO memastikan semua sudah hadir.',
    'icon': Icons.camera_alt_outlined,
  },
  {
    'time': '09:00',
    'activity': 'Upacara Pemberkatan / Ijab Kabul',
    'detail': 'Pembacaan janji suci dan penukaran cincin.',
    'icon': Icons.church,
  },
  {
    'time': '11:00',
    'activity': 'Resepsi Sesi Siang',
    'detail': 'Penyambutan tamu & jamuan makan siang.',
    'icon': Icons.people_alt_outlined,
  },
];

// Data untuk Resepsi / Malam
final List<Map<String, dynamic>> resepsiRundown = [
  {
    'time': '18:0:0',
    'activity': 'Persiapan & Touch-up (Makeup)',
    'detail': 'Lokasi: Ruang Ganti VIP',
    'icon': Icons.palette,
  },
  {
    'time': '19:00',
    'activity': 'Pembukaan Pintu Resepsi Malam',
    'detail': 'Tamu mulai memasuki Grand Ballroom.',
    'icon': Icons.door_front_door,
  },
  {
    'time': '19:30',
    'activity': 'Prosesi Masuk Pengantin',
    'detail': 'Diiringi alunan musik orkestra.',
    'icon': Icons.favorite_border,
  },
  {
    'time': '21:00',
    'activity': 'Penutup dan Foto Bersama',
    'detail': 'Sesi terakhir dengan sahabat dan kolega.',
    'icon': Icons.camera_alt_outlined,
  },
];

// Data dummy untuk daftar Tugas Mendesak (BASE DATA)
final List<Map<String, dynamic>> initialUrgentTasks = [
  {
    'type': 'Emergency',
    'title': 'Konfirmasi Final Jumlah Tamu',
    'description': 'Batas waktu hari ini jam 17:00 untuk katering.',
    'icon': Icons.gpp_bad_rounded,
    'color': Colors.red.shade700, // MERAH
    'isCompleted': false, // Status Awal
  },
  {
    'type': 'Warning',
    'title': 'Pelunasan Vendor Dekorasi',
    'description': 'Pembayaran jatuh tempo besok pagi. Segera transfer!',
    'icon': Icons.schedule,
    'color': Colors.amber.shade700, // KUNING (Amber)
    'isCompleted': false, // Status Awal
  },
];

// =============================================================================
// KLAS UTAMA
// =============================================================================

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wedding Planner UI Clone',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.cyan)
            .copyWith(
              primary: const Color(0xFF00BFA5), // Menggunakan primaryTeal
              secondary: Colors.tealAccent,
            ),
        useMaterial3: true,
        canvasColor: Colors.white,
      ),
      home: const HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final Color primaryTeal = const Color(0xFF00BFA5);

  String _selectedRundownType = 'pagi'; // Nilai default

  // STATE BARU UNTUK WAKTU REALTIME
  late DateTime _currentTime;
  late Timer _timer;

  // Data tugas disimpan sebagai STATE lokal
  late List<Map<String, dynamic>> _urgentTasks;

  // VARIABEL BARU UNTUK KONTROL GETARAN
  bool _isVibrating = false;

  // --- Helper untuk format tanggal/waktu manual (tanpa paket intl) ---
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
  // -------------------------------------------------------------------

  // =========================================================================
  // 🚀 LOGIKA VIBRASI & WAKTU
  // =========================================================================

  @override
  void initState() {
    super.initState();
    // Inisialisasi data tugas dari data mentah (Membuat Salinan)
    _urgentTasks = initialUrgentTasks
        .map((task) => Map<String, dynamic>.from(task))
        .toList();

    // INISIALISASI WAKTU DAN TIMER
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), _updateTime);

    // Memanggil _triggerHapticFeedback setelah frame pertama selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _triggerHapticFeedback();
    });
  }

  // FUNGSI UNTUK MENGUPDATE WAKTU SETIAP DETIK
  void _updateTime(Timer timer) {
    if (mounted) {
      setState(() {
        _currentTime = DateTime.now();
      });
    }
  }

  @override
  void dispose() {
    // PENTING: Hentikan timer saat widget di-dispose
    _timer.cancel();
    super.dispose();
  }

  // Fungsi untuk menghentikan getaran dan menandai tugas selesai (dipanggil saat klik OK)
  void _stopHapticFeedback() {
    if (_isVibrating) {
      if (mounted) {
        setState(() {
          _isVibrating = false;
          // Tandai tugas pertama (yang memicu getaran) sebagai selesai
          if (_urgentTasks.isNotEmpty) {
            _urgentTasks[0]['isCompleted'] = true;
          }
        });
      }
      print('DEBUG: Getaran Dihentikan oleh Pengguna (Tombol OK/Selesai)');
      // Memberi getaran balik (feedback) saat tombol OK diklik
      HapticFeedback.vibrate();
    }
  }

  // Logika Getaran...
  void _triggerHapticFeedback() async {
    // Cek apakah tugas sudah selesai atau daftar kosong
    if (_urgentTasks.isEmpty || (_urgentTasks[0]['isCompleted'] as bool))
      return;

    final Map<String, dynamic> currentTask = _urgentTasks[0];
    final Color taskColor = currentTask['color'] as Color;

    await Future.delayed(const Duration(milliseconds: 100));

    // Aktifkan status getaran
    if (mounted) {
      setState(() {
        _isVibrating = true;
      });
    }

    int repeatCount = 0;

    // Jeda sangat kecil (50ms) untuk mencegah overload, tapi tetap terasa padat
    const Duration minimalDelay = Duration(milliseconds: 50);
    const int veryLongDurationInRepeats = 50000;

    // --- LOGIKA UTAMA GETARAN ---
    if (taskColor == Colors.red.shade700) {
      repeatCount = veryLongDurationInRepeats;
      print(
        'DEBUG: Memulai getaran berulang (Merah - SIMULASI PANJANG - ${repeatCount}x Heavy Impact)',
      );
      for (int i = 0; i < repeatCount && _isVibrating; i++) {
        try {
          await HapticFeedback.heavyImpact();
        } catch (e) {
          HapticFeedback.vibrate();
        }
        if (_isVibrating) {
          await Future.delayed(minimalDelay);
        }
      }
    } else if (taskColor == Colors.amber.shade700) {
      repeatCount = veryLongDurationInRepeats ~/ 2;
      print(
        'DEBUG: Memulai getaran berulang (Kuning - SIMULASI PANJANG - ${repeatCount}x Medium Impact)',
      );
      for (int i = 0; i < repeatCount && _isVibrating; i++) {
        try {
          await HapticFeedback.mediumImpact();
        } catch (e) {
          HapticFeedback.vibrate();
        }

        if (_isVibrating) {
          await Future.delayed(minimalDelay);
        }
      }
    } else {
      HapticFeedback.lightImpact();
      print('DEBUG: Light Impact Triggered');
    }

    // Matikan status getaran setelah loop selesai
    if (mounted) {
      setState(() {
        _isVibrating = false;
        if (_urgentTasks.isNotEmpty &&
            !(_urgentTasks[0]['isCompleted'] as bool)) {
          _urgentTasks[0]['isCompleted'] = true;
        }
      });
    }
    print('DEBUG: Simulasi Getaran Selesai');
  }

  // =========================================================================
  // WIDGET BARU: KARTU JAM/WAKTU
  // =========================================================================

  Widget _buildCurrentTimeCard() {
    final now = _currentTime;

    // Format Waktu Jam dan Menit: HH:MM
    final timeHoursMinutes =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Format Detik: SS
    final timeSeconds = now.second.toString().padLeft(2, '0');

    // Format Tanggal: NamaHari, DD NamaBulan YYYY
    final dayName = _days[now.weekday - 1];
    final monthName = _months[now.month - 1];
    final dateString = '$dayName, ${now.day} $monthName ${now.year}';

    const Color blackColor = Colors.black;

    return Container(
      // 🔥 PERUBAHAN DI SINI: bottom margin menjadi 5
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, // Latar belakang putih
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
                    timeHoursMinutes, // Jam dan Menit (Font Besar)
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: blackColor,
                    ),
                  ),
                  // Pemisah Titik Dua untuk Detik
                  const Text(
                    ':',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: blackColor,
                    ),
                  ),
                  // TAMPILAN DETIK (Font Besar, menyatu dengan jam/menit)
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

  // =========================================================================
  // WIDGET LAIN (Dipertahankan)
  // =========================================================================

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
          // Event Live Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: primaryTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: primaryTeal),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, color: primaryTeal, size: 8),
                const SizedBox(width: 6),
                Text(
                  'Event Live',
                  style: TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOkButton() {
    return GestureDetector(
      onTap: _stopHapticFeedback, // Panggil fungsi stop yang menandai selesai
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
    if (_urgentTasks.isEmpty) {
      return const SizedBox.shrink();
    }

    final Map<String, dynamic> currentTask = _urgentTasks[0];

    return Container(
      // 🔥 PERUBAHAN DI SINI: top dan bottom margin menjadi 5
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
    final bool isSelected = _selectedRundownType == value;
    final Color selectedColor = primaryTeal;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRundownType = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
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
  }

  Widget _buildRundownItem(Map<String, dynamic> item, int index) {
    final List<Map<String, dynamic>> currentList =
        _selectedRundownType == 'pagi' ? akadRundown : resepsiRundown;

    final bool isLiveEvent = index == 0 && _selectedRundownType != 'malam';

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
              if (isLiveEvent && currentList.isNotEmpty)
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
                    Expanded(
                      child: Text(
                        item['detail'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          color: iconAndDetailColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
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
    final List<Map<String, dynamic>> currentRundown =
        _selectedRundownType == 'pagi' ? akadRundown : resepsiRundown;

    return Container(
      // 🔥 PERUBAHAN DI SINI: top margin menjadi 5
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
          const Text(
            'Rundown Acara',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          _buildRundownSelector(),
          const SizedBox(height: 15),

          Column(
            children: List.generate(currentRundown.length, (index) {
              return _buildRundownItem(currentRundown[index], index);
            }),
          ),
        ],
      ),
    );
  }

  // --- Implementasi Scaffold ---
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
                // KARTU WAKTU REALTIME
                _buildCurrentTimeCard(),

                // KARTU TUGAS MENDESAK (Jarak di atasnya kini 5)
                if (_urgentTasks.isNotEmpty) _buildUrgentTaskCard(),

                // KARTU RUNDOWN (Jarak di atasnya kini 5)
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
