# Technical Design Document - Mobile App Architecture
**Project Name:** CrewSync Mobile  
**Tech Stack:** Flutter, Riverpod, Dio, Hive, FCM  

---

## 1. Clean Architecture Layering


┌─────────────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER                          │
│  - Flutter UI Widgets (Pages, Sheets, Dialogs)              │
│  - Riverpod State Notifiers (AsyncNotifierProvider)         │
└──────────────────────────────┬──────────────────────────────┘
                               │ Calls
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                   DOMAIN LAYER                              │
│  - Pure Entities & Value Objects                            │
│  - Repository Interfaces (Contracts)                        │
└──────────────────────────────▲──────────────────────────────┘
                               │ Implements
┌──────────────────────────────┴──────────────────────────────┐
│                    DATA LAYER                               │
│  - Repository Implementations                               │
│  - Remote Data Source (Dio HTTP Client)                     │
│  - Local Data Source (Hive Boxes - Offline Cache)           │
│  - Device Hardware Adapters (Geolocator, LocalAuth, Camera) │
└─────────────────────────────────────────────────────────────┘

## 2. State Management Strategy (Riverpod)
Plaintext
┌─────────────────────┐
│    authProvider     │ ── State: AsyncValue<User?>
└─────────────────────┘
           │
┌──────────▼──────────┐
│   eventListProvider │ ── Mengambil daftar acara yang ditugaskan ke kru
└──────────┬──────────┘
           │
           ├───────────────────────────────┐
           ▼                               ▼
┌─────────────────────┐         ┌─────────────────────┐
│   rundownProvider   │         │ attendanceProvider  │
│ - Listen ke Hive    │         │ - Baca GPS kru      │
│ - Listen FCM Topic  │         │ - Hitung Geofence   │
│ - Highlight Live Cue│         │ - Eksekusi Absensi  │
└─────────────────────┘         └─────────────────────┘

## 3. Data Flow: Client-Side Geofence & Attendance
Plaintext
[ Kru Buka Layar Presensi ]
            │
            ▼
[ Geolocator: Ambil GPS Kru ]
  (lat: -6.23615, lng: 106.82845)
            │
            ▼
[ Ambil Koordinat Venue dari Event ]
  (venueLat: -6.23612, venueLng: 106.82841, radius: 100m)
            │
            ▼
[ Komputasi Jarak Lokal ]
  Geolocator.distanceBetween(...) ──> Hasil: 5.2 meter
  isWithinGeofence = 5.2 <= 100 ───> TRUE
            │
            ▼
[ Tampilkan Status Aktif (Sky Blue) di Layar: "Anda Berada di Venue (5m)" ]
            │
            ├── Kru Memilih: BIOMETRIK
            │     └─ LocalAuth.authenticate()
            │     └─ Kirim JSON via Dio ke POST /attendances
            │
            └── Kru Memilih: FOTO
                  └─ ImagePicker: Ambil Swafoto
                  └─ Kompresi Gambar ke JPEG (~250KB)
                  └─ Kirim FormData via Dio ke POST /attendances
## 4. Hive Box Storage Scheme
Tiga box utama Hive diinisialisasi saat aplikasi startup:

auth_box: Menyimpan data sesi token dan model User.

events_box: Menyimpan objek Event aktif (termasuk koordinat venue & radius).

rundowns_box: Menyimpan list RundownItem terindeks per eventId sebagai cache offline saat di basement/ballroom.

## 5. UI Layout Wireframes
### A. Live Rundown Screen (RundownTimelinePage)
Plaintext
┌──────────────────────────────────────────────┐
│ [←] Pernikahan Rian & Sasa         [Offline✓]│
│ Venue: Grand Ballroom Mulia | 11 Okt 2026   │
├──────────────────────────────────────────────┤
│ 07:00 - 08:00                                │
│ [✓] Loading Perlengkapan Sound     (Selesai) │
├──────────────────────────────────────────────┤
│ 08:00 - 09:00                                │
│ [▶] Akad Nikah                     (SEDANG)  │ <== Border Sky Blue (#54A3FF)
│ Lokasi: Ruang Utama | PIC: Budi              │     Pulse Animasi
├──────────────────────────────────────────────┤
│ 09:00 - 10:00                                │
│ [ ] Kirab Pengantin & Masuk        (Berikut) │
│ Lokasi: Koridor Utama | PIC: Laras           │
└──────────────────────────────────────────────┘
### B. Attendance Bottom Sheet (AttendanceSheet)
Plaintext
┌──────────────────────────────────────────────┐
│            Presensi Kehadiran                │
├──────────────────────────────────────────────┤
│  RADAR STATUS GEOFENCE:                      │
│  [ ● ] Berada di Lokasi Venue                │
│  Jarak: 8 meter (Maksimum radius: 100m)     │
├──────────────────────────────────────────────┤
│  Pilih Metode Verifikasi:                    │
│                                              │
│  [  (👆) Verifikasi Biometrik (Face/Sidik)  ]│
│                                              │
│  [  (📷) Ambil Swafoto di Venue            ]│
└──────────────────────────────────────────────┘
## 6. Implementasi Kunci: Evaluasi Geofence & Submit Presensi
Dart
// lib/features/attendance/data/attendance_repository.dart
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class AttendanceRepository {
  final Dio _dio;

  AttendanceRepository(this._dio);

  Future<Response> submitAttendance({
    required String eventId,
    required String type, // 'CHECK_IN' | 'CHECK_OUT'
    required String method, // 'BIOMETRIC' | 'PHOTO'
    required Position currentPosition,
    required double venueLat,
    required double venueLng,
    required int allowedRadiusMeters,
    String? photoPath,
  }) async {
    // 1. Evaluasi Geofence secara lokal
    final double distanceInMeters = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      venueLat,
      venueLng,
    );
    final bool isWithinGeofence = distanceInMeters <= allowedRadiusMeters;

    // 2. Siapkan FormData untuk Dio
    final Map<String, dynamic> data = {
      'type': type,
      'method': method,
      'clientLat': currentPosition.latitude,
      'clientLng': currentPosition.longitude,
      'clientDistanceMeters': distanceInMeters.round(),
      'isWithinGeofence': isWithinGeofence,
    };

    if (method == 'BIOMETRIC') {
      data['biometricTokenRef'] = 'local_auth_verified_ok';
    } else if (method == 'PHOTO' && photoPath != null) {
      data['photo'] = await MultipartFile.fromFile(
        photoPath,
        filename: 'attendance_\${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
    }

    final formData = FormData.fromMap(data);

    // 3. Kirim ke Endpoint Backend
    return await _dio.post('/events/\$eventId/attendances', data: formData);
  }
}

---

## 7. Color Palette & High-Contrast Design System

Aplikasi menggunakan tema **High-Contrast Dark Mode** yang dirancang untuk kenyamanan visual kru di venue/ballroom yang minim cahaya serta efisiensi konsumsi daya layar:

### Palet Warna Resmi
| Nama Warna | Kode Hex | Nilai Flutter (`Color`) | Peran & Semantik UI |
|---|---|---|---|
| **CHARCOAL BLACK** | `#121214` | `Color(0xFF121214)` | Background utama aplikasi (`Scaffold background`), canvas dasar |
| **SLATE GRAY** | `#2B2D31` | `Color(0xFF2B2D31)` | Surface container, Card, BottomSheet, Dialog background, baris timeline |
| **SOFT GRAY** | `#6B7280` | `Color(0xFF6B7280)` | Teks sekunder, subtitle, label waktu, divider/border, icon non-aktif |
| **SKY BLUE** | `#54A3FF` | `Color(0xFF54A3FF)` | Warna aksen utama (*primary accent*), highlight sesi aktif (Active Cue), tombol aksi utama, indikator geofence valid |
| **PURE WHITE** | `#FFFFFF` | `Color(0xFFFFFFFF)` | Teks primer/judul, icon aktif, teks tombol berkontras tinggi |

### Spesifikasi Kode: `lib/core/constants/app_colors.dart`
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette
  static const Color charcoalBlack = Color(0xFF121214);
  static const Color slateGray = Color(0xFF2B2D31);
  static const Color softGray = Color(0xFF6B7280);
  static const Color skyBlue = Color(0xFF54A3FF);
  static const Color pureWhite = Color(0xFFFFFFFF);

  // Semantic Design Tokens
  static const Color background = charcoalBlack;
  static const Color surface = slateGray;
  static const Color primary = skyBlue;
  static const Color textPrimary = pureWhite;
  static const Color textSecondary = softGray;
  static const Color border = softGray;
  static const Color activeCue = skyBlue;
  static const Color geofenceValid = skyBlue;
}
```