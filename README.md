# WedMaster Crew App 📱

Aplikasi mobile pendamping untuk platform **WedMaster SaaS**. Aplikasi ini digunakan oleh tim lapangan (Crew EO/WO) untuk operasional acara pernikahan secara *real-time*. Dibangun menggunakan **Flutter** dengan manajemen state **GetX** yang ringkas dan performa tinggi.

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue) ![State](https://img.shields.io/badge/State-GetX-red) ![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-grey)

## 🔥 Fitur Utama

* **⚡ Fast QR Scanner:** Scan tiket tamu dalam hitungan milidetik (menggunakan `mobile_scanner`).
* **📳 Haptic & Vibration Alert:** Getaran pola khusus saat tamu VIP atau VVIP di-scan (Fitur *Silent Communication*).
* **📡 Real-time Sync:** Data check-in langsung sinkron ke server pusat & layar proyektor venue.
* **📂 Offline Mode:** Tetap bisa scan tamu meskipun sinyal di gedung buruk (Sinkronisasi otomatis saat online kembali).
* **📋 Digital Rundown:** Jadwal acara yang sinkron dengan Admin Pusat.

## 🛠️ Tech Stack & Library

* **Framework:** Flutter SDK
* **State Management:** [GetX](https://pub.dev/packages/get) (Route, State, Dependency Injection)
* **Local Storage:** [GetStorage](https://pub.dev/packages/get_storage) (untuk Token & Cache data tamu)
* **Networking:** Dio (HTTP Client)
* **Scanner:** mobile_scanner
* **Vibration:** vibration

## 📂 Struktur Project (GetX Pattern)

Project ini menggunakan pola **GetX Pattern** untuk memisahkan Logic, View, dan Data.

```text
lib/
├── app/
│   ├── data/
│   │   ├── models/         # Data Model (GuestModel, EventModel)
│   │   ├── providers/      # API Client (Dio/Connect)
│   │   └── services/       # Service global (AuthService, StorageService)
│   ├── modules/            # Pages / Screens
│   │   ├── login/
│   │   │   ├── login_binding.dart
│   │   │   ├── login_controller.dart
│   │   │   └── login_view.dart
│   │   ├── home/
│   │   └── scanner/
│   │       ├── scanner_controller.dart  # Logic getar & validasi ada di sini
│   │       └── scanner_view.dart
│   └── routes/             # AppPages & AppRoutes
├── main.dart
└── config.dart             # Base URL Configuration
````

## 🚀 Setup & Development

### 1\. Clone Repository

```bash
git clone [https://github.com/username/wedmaster-crew-app.git](https://github.com/username/wedmaster-crew-app.git)
cd wedmaster-crew-app
```

### 2\. Konfigurasi Endpoint API

Buka file `lib/config.dart` dan arahkan ke server backend Flask kamu (pastikan IP address bisa diakses dari HP, bukan `localhost`).

```dart
// lib/config.dart
class Config {
  // Ganti dengan IP Laptop/Server kamu
  static const String baseUrl = "[http://192.168.1.5:5000/api](http://192.168.1.5:5000/api)"; 
}
```

### 3\. Get Dependencies

```bash
flutter pub get
```

### 4\. Run App

```bash
flutter run
```

## 📱 Logic Penting (Snippet)

**Controller untuk Scan & Getar (GetX):**

```dart
// scanner_controller.dart
void onScan(String code) async {
  var result = await repository.checkInGuest(code);
  
  if (result.isVip) {
    // Pola getar untuk VIP: Panjang
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(pattern: [500, 1000, 500, 1000]);
    }
    Get.snackbar("VIP ARRIVAL", "Sambut ${result.name} di Pintu Utama!", 
      backgroundColor: Colors.red, colorText: Colors.white);
  } else {
    // Getar pendek untuk tamu biasa
    Vibration.vibrate(duration: 200);
    Get.snackbar("Success", "Welcome ${result.name}");
  }
}
```

## 📝 Catatan Rilis

  * **v1.0.0:** Rilis awal (Login, List Event, Scan QR, VIP Vibration).
  * **Next:** Integrasi FCM (Firebase Cloud Messaging) untuk notifikasi broadcast.

-----

*Built with 💙 using Flutter & GetX*