### `mobile/task-instructions.md`

```markdown
# Task Instructions - Mobile App Implementation
**Target Engine:** AI Coding Agent / Flutter Developer  
**Framework:** Flutter (Dart 3.x)  
**State Management:** flutter_riverpod  
**Networking & Cache:** dio, hive_flutter  

---

## Phase 1: Environment Setup & Core Foundations
- [x] Tambahkan dependencies di `pubspec.yaml`:
  - `flutter_riverpod`, `riverpod_annotation`
  - `dio`
  - `hive`, `hive_flutter`, `path_provider`
  - `geolocator`, `local_auth`, `image_picker`, `flutter_image_compress`
  - `firebase_core`, `firebase_messaging`
  - `intl`, `google_fonts`
- [x] Inisialisasi Hive di `main.dart` dan buat wrapper storage service.
- [x] Setup Dio Client (`lib/core/network/dio_client.dart`):
  - Base URL dari environment config.
  - Interceptor untuk menyematkan Bearer token dari storage.
  - Logging interceptor (debug only).
  - Error interceptor terpusat.
- [x] Konfigurasi FCM background messaging handler dan initial notification permission.
- [x] Buat konstanta tema warna resmi (`lib/core/constants/app_colors.dart`):
  - Charcoal Black (`#121214`), Slate Gray (`#2B2D31`), Soft Gray (`#6B7280`), Sky Blue (`#54A3FF`), Pure White (`#FFFFFF`).

## Phase 2: Authentication & Session Management
- [x] Bangun model data `User` dan `AuthResponse` dengan Hive TypeAdapter untuk caching user profil.
- [x] Implementasikan `AuthRepository`:
  - `login(identifier, password)`
  - `logout()`
  - `saveFCMToken(token)`
- [x] Buat `authController` menggunakan Riverpod `AsyncNotifier`.
- [x] Bangun UI `LoginPage`:
  - Form input Identifier + Password.
  - Indikator loading dan error snackbar.
  - Redirect otomatis ke `EventListPage` saat login sukses.

## Phase 3: Events & Offline-First Rundown Cache
- [x] Buat model data dan Hive TypeAdapter untuk `Event` dan `RundownItem`.
- [x] Implementasikan `EventRepository`:
  - Ambil event aktif dari API dan simpan ke box Hive lokal (`events_box`).
  - Fallback ke data Hive jika koneksi offline.
- [x] Bangun UI `RundownTimelinePage`:
  - List item rundown yang disusun kronologis.
  - Badge penanda status: `PENDING`, `ACTIVE` (highlight Sky Blue kontras tinggi), `COMPLETED`.
  - Tampilkan nama PIC dan estimasi waktu.
- [x] Integrasikan FCM Listener: Saat pesan data bertipe `RUNDOWN_CUE_UPDATE` diterima, perbarui state Riverpod rundown secara instan.

## Phase 4: Client-Side Geofence & Attendance Module
- [x] Buat helper `GeofenceService`:
  - Panggil `Geolocator.getCurrentPosition()`.
  - Hitung `distanceMeters = Geolocator.distanceBetween(lat1, lng1, eventLat, eventLng)`.
  - Tentukan boolean `isWithinGeofence = distanceMeters <= eventRadius`.
- [x] Buat helper `BiometricService`:
  - Periksa ketersediaan hardware (`local_auth`).
  - Eksekusi autentikasi sidik jari atau Face ID.
- [x] Bangun UI `AttendanceSheet / AttendancePage`:
  - Tampilkan widget status jarak geofence secara visual (Jarak aktual vs Radius batas).
  - Pilihan 2 tombol metode:
    1. **"Presensi Biometrik"**: Trigger `local_auth` -> jika berhasil, kirim payload `method: 'BIOMETRIC'`.
    2. **"Presensi Foto"**: Buka kamera selfie -> kompres foto -> kirim via FormData `method: 'PHOTO'`.
- [x] Tangani penolakan atau presensi di luar radius dengan konfirmasi dialog peringatan.

## Phase 5: Logistics & Inventory Checklist
- [x] Buat model data dan Hive adapter untuk `LogisticsChecklist` dan `ChecklistItem`.
- [x] Bangun UI `LogisticsScreen` dengan tab navigasi: `Load-In`, `Load-Out`, dan `Post-Event`.
- [x] Buat bottom-sheet verifikasi item:
  - Input jumlah fisik aktual (`quantity_actual`).
  - Radio button kondisi: `Baik`, `Rusak`, `Hilang`.
  - Tombol kamera untuk melampirkan foto bukti kondisi fisik barang.
- [x] Eksekusi request `PATCH /checklists/items/:id/verify` via Dio FormData.