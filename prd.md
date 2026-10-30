# Product Requirement Document (PRD) - Mobile App
**Project Name:** CrewSync Mobile App  
**Target Platform:** Android & iOS (Cross-Platform)  
**Framework:** Flutter (Dart 3.x)  
**Architecture:** Feature-First Clean Architecture  
**Key Libraries:** flutter_riverpod, dio, hive / hive_flutter, firebase_messaging, geolocator, local_auth, image_picker  

---

## 1. Executive Summary & Objective
CrewSync Mobile adalah aplikasi lapangan yang dirancang khusus untuk kru operasional acara (Stage Manager, Runner, LO, Kru Katering/Dekor). Aplikasi ini memprioritaskan performa cepat di venue, kemampuan kerja offline (*offline-first cache* via Hive), evaluasi mandiri radius geofence di perangkat, fleksibilitas metode absensi (Biometrik atau Foto), serta pembaruan rundown real-time berbasis notifikasi data FCM.

---

## 2. User Personas & Use Cases
* **Koordinator Lapangan / Stage Manager:** Memantau alur waktu rundown dari menit ke menit di tengah ballroom, menerima cue sesi, serta mengecek checklist inventaris.
* **Kru Pelaksana (Runner / Usher / Katering / Sound):** Melakukan absensi mandiri saat tiba di venue (menggunakan FaceID/Fingerprint atau Swafoto), melihat penugasan shift, dan mengecek daftar barang bawaan.

---

## 3. Core Feature Specifications

### 3.1 Authentication & Session Management
* Login langsung menggunakan kredensial: Nomor Telepon atau Email + Password.
* Simpan token JWT dan info user di secure local storage (Hive / FlutterSecureStorage).
* Interceptor Dio menyisipkan Bearer token secara otomatis pada setiap request dan menangani token kedaluwarsa (401 -> Logout).
* Pendaftaran FCM device token ke backend saat sesi login berhasil.

### 3.2 Offline-First Event Caching (Hive)
* Saat terhubung internet, aplikasi mengunduh dan menyimpan data event, parameter venue (`venue_lat`, `venue_lng`, `geofence_radius_meters`), dan item rundown ke dalam Hive box lokal.
* Saat sinyal di venue/basement drop, aplikasi tetap menampilkan rundown dan jadwal secara penuh tanpa layar blank atau error koneksi.

### 3.3 Client-Side Geofence & Dual-Method Attendance
* **Evaluasi Geofence Lokal:**
  * Menggunakan package `geolocator` untuk mendapatkan koordinat GPS perangkat kru (`client_lat`, `client_lng`).
  * Menghitung jarak ke venue secara lokal menggunakan formula jarak `Geolocator.distanceBetween()`.
  * Menentukan status: `is_within_geofence = distance <= event.geofenceRadiusMeters`.
  * Menampilkan indikator visual langsung ke kru (misal: "Anda berada 15m dari venue - Dalam Radius" atau "Anda berada 350m dari venue - Di Luar Radius").
* **Metode Presensi 1: Biometrik (`BIOMETRIC`)**
  * Memanfaatkan hardware biometrik perangkat via `local_auth` (Fingerprint / Face ID).
  * Jika lolos, kirim payload data ke backend tanpa mengunggah file foto.
* **Metode Presensi 2: Foto Swafoto (`PHOTO`)**
  * Kru mengambil foto selfie di lokasi menggunakan kamera perangkat via `image_picker`.
  * Kompresi gambar di sisi klien (maksimal ~300KB) sebelum dikirimkan via FormData Dio.

### 3.4 Live Rundown & FCM Topic Cue
* Aplikasi otomatis subscribe ke topik FCM `event_{eventId}` saat kru membuka acara yang ditugaskan kepadanya.
* Menerima payload background dan foreground notifikasi saat status sesi rundown berubah menjadi `ACTIVE`.
* Mengubah highlight item rundown secara otomatis dan memunculkan banner cue suara/getar singkat agar kru bersiap ke posisi masing-masing.

### 3.5 Logistics & Checklist Verification
* Menampilkan daftar barang per stage: `Load-In`, `Load-Out`, `Post-Event`.
* Kru dapat memperbarui jumlah aktual yang tiba di venue, memilih kondisi barang (`GOOD`, `DAMAGED`, `MISSING`), dan melampirkan foto bukti kondisi fisik via kamera.

---

## 4. Clean Architecture Directory Structure

Struktur direktori mengadopsi pola Feature-First:

lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/             # App colors, styles, storage keys, API endpoints
│   ├── errors/                # Failure & Exception classes
│   ├── network/               # Dio client instance, interceptors, error handler
│   ├── services/              # FCM service, Geolocation service, LocalAuth service
│   ├── storage/               # Hive box helpers & initializers
│   └── utils/                 # Date formatters (WIB), geofence distance calculator
├── features/
│   ├── auth/
│   │   ├── data/              # Auth remote data source, models, repo implementation
│   │   ├── domain/            # Auth entities, repo interfaces
│   │   └── presentation/      # Login page, auth riverpod controllers
│   ├── events/
│   │   ├── data/              # Event remote & local (Hive) data sources, models
│   │   ├── domain/            # Event & Rundown entities
│   │   └── presentation/      # Event detail page, rundown timeline widget, cue listener
│   ├── attendance/
│   │   ├── data/              # Attendance remote data source, FormData builder
│   │   ├── domain/            # Attendance submission entity & validation rules
│   │   └── presentation/      # Attendance dialog, Geofence status radar, selfie screen
│   └── logistics/
│       ├── data/              # Checklist API & Hive cache
│       ├── domain/            # Checklist item models
│       └── presentation/      # Checklist tab screen, condition updater sheet
└── shared/
    └── widgets/               # Reusable buttons, badges, app bars, loading indicators


## 5. Non-Functional Requirements
- Battery & Data Efficiency: Pembacaan GPS hanya dipanggil ketika user membuka halaman presensi (tidak melakukan background location tracking tanpa henti).
- Ukuran Gambar Terkendali: Setiap foto selfie atau bukti logistik wajib dikompresi ke format JPEG dengan kualitas 70-80% sebelum diunggah melalui Dio (Maks 100 KB)
- UI High-Contrast & Color Palette: Tampilan aplikasi dioptimalkan dengan kontras warna tinggi bertema dark-mode agar mudah dibaca di venue redup (ballroom pesta pernikahan). Palet warna resmi:
  - **Charcoal Black** (`#121214`): Background utama / Canvas dasar
  - **Slate Gray** (`#2B2D31`): Surface / Container / Card / BottomSheet
  - **Soft Gray** (`#6B7280`): Teks sekunder / Border / Inactive elements
  - **Sky Blue** (`#54A3FF`): Primary Accent / Live Cue Highlight / Tombol Utama
  - **Pure White** (`#FFFFFF`): Teks primer / Heading / Ikon kontras tinggi