# UI Design Guide & Screen Specifications
**Project Name:** CrewSync Mobile  
**Typography:** Poppins (Google Fonts)  
**Theme:** High-Contrast Field Operations (Dark Mode Native)  

---

## 1. Typography & Global Design Tokens

### A. Font Family: `Poppins`
Semua teks antarmuka menggunakan font keluarga **Poppins**:
* **Display / Headline:** Poppins SemiBold (600) / Bold (700)
* **Title & Subhead:** Poppins Medium (500) / SemiBold (600)
* **Body & Input:** Poppins Regular (400)
* **Button & Badges:** Poppins Medium (500) / SemiBold (600)
* **Captions & Metadata:** Poppins Regular (400) / Light (300)

### B. Color Tokens
* **Background Canvas:** `CHARCOAL BLACK` (`#121214`)
* **Card & Surface Container:** `SLATE GRAY` (`#2B2D31`)
* **Muted / Borders / Secondary Text:** `SOFT GRAY` (`#6B7280`)
* **Primary Brand / Action Accent:** `SKY BLUE` (`#54A3FF`)
* **High-Contrast Text / Headlines:** `PURE WHITE` (`#FFFFFF`)
* **Status Berhasil / Geofence / Cue Aktif:** `EMERALD GREEN` (`#10B981`) & Tint Hijau Lembut (`rgba(16, 185, 129, 0.15)`)
* **Status Bahaya / Rusak:** `CRIMSON RED` (`#EF4444`)
* **Status Peringatan / Hilang:** `AMBER ORANGE` (`#F59E0B`)

---

## 2. Layar 1: Login & Autentikasi (`/login` - `LoginPage`)

### Layout Specifications:
1. **Top Area:**
   * **Subtle Brand Mark:** Ikon monokrom minimalis dengan teks pendamping kecil: `"CrewSync - Field Ops"`.
   * **Clean Headline:** `"Masuk ke Akun Kru"` (Poppins Bold 24sp, Pure White).
   * **Secondary Helper Text:** `"Gunakan nomor HP atau email yang didaftarkan vendor"` (Poppins Regular 14sp, Soft Gray).
2. **Input Form (Single Column, Flat Cards):**
   * **Input 1:** `"Nomor WhatsApp / Email"` dengan placeholder teks yang subtil, border flat 1px Slate/Soft Gray, background Slate Gray.
   * **Input 2:** `"Kata Sandi"` dengan trailing eye icon untuk toggle visibilitas sandi.
3. **Actions:**
   * **Primary Button (Full-width):** `"Masuk"` (Tinggi min 52px, Poppins SemiBold 16sp, rounded-xl 12px, warna Sky Blue `#54A3FF` dengan teks Charcoal Black atau Pure White berbobot tebal).
   * **Text Link (Below Button):** `"Lupa kata sandi? Hubungi Koordinator"` (Poppins Regular 13sp, Soft Gray, centered).
4. **Design Rules:**
   * Dilarang menggunakan ilustrasi latar belakang (*no background illustrations*) atau grafik mengambang (*no floating graphics*).
   * *Clean vertical rhythm* dengan whitespace yang lapang dan teratur.

---

## 3. Layar 2: Live Rundown & FCM Cue (`RundownTimelinePage`)

### Header & Context:
* **Compact Top Bar:**
  * Tombol kembali (Back arrow).
  * Judul acara: `"Pernikahan Rian & Sasa"` (Poppins SemiBold 18sp, Pure White).
  * Indikator cache: Pill subtil `"[Offline Siap ✓]"` berlatar Slate Gray dengan teks Soft Gray/Emerald Green.
* **Sub-Bar:**
  * Lokasi venue: `"Grand Ballroom Hotel Mulia"` (Poppins Medium 13sp, Soft Gray).
  * Tanggal acara: `"11 Okt 2026"` (Poppins Regular 12sp, Soft Gray).

### Main Content (Vertical Chronological Timeline):
* Garis vertikal bersih (*clean vertical line*, 2px Soft Gray `#2B2D31`) yang menghubungkan setiap node waktu.
* **Item 1 (Past / Finished):**
  * Teks warna abu-abu redup (Muted Soft Gray), teks dicoret halus (*strike-through*) atau diiringi ikon centang subtil.
  * Waktu: `"07:00 - 08:00 WIB"` | Judul: `"Load-In Sound & HT"` | Status Pill: `[Selesai]` (Background Slate Gray, teks Soft Gray).
* **Item 2 (CURRENT ACTIVE CUE - Prominent Focus):**
  * Kartu kontras tinggi (White/Elevated Card) dengan **border 1.5px Emerald Green (`#10B981`)** dan indikator titik hijau (*green dot indicator*).
  * Waktu: `"08:00 - 09:00 WIB"` (Poppins Bold 15sp, Pure White/Dark contrast).
  * Judul: `"Akad Nikah"` (Poppins Bold 18sp).
  * Zone & PIC: `"Ruang Utama • PIC: Budi (Stage Manager)"` (Poppins Regular 13sp).
  * Live status pill: `[SEDANG BERLANGSUNG]` berlatar tint hijau lembut (*muted green tint*).
* **Item 3 (Next Upcoming):**
  * Flat Card Slate Gray dengan border 1px lembut.
  * Waktu: `"09:00 - 10:00 WIB"` | Judul: `"Kirab Pengantin & Masuk Pelaminan"` | Zone: `"Foyer Utama"`.
  * Status Pill: `[Berikutnya]` (Muted tag).

### Bottom Floating Bar:
* Tombol aksi cepat tertambat di bawah (*docked at bottom*):
  * Teks: `"Buka Presensi Hari Ini"` disertai ikon GPS Pin.
  * Background tombol: Slate Gray ber-border 1.5px Sky Blue atau tombol Sky Blue berkontras tinggi.

---

## 4. Layar 3: Presensi Kehadiran Geofence & Dual-Method (`AttendanceSheet`)

### Top Section (Geofence Status Radar):
* Handle drag di tengah atas (*drag handle line*).
* Judul: `"Presensi Lapangan"` (Poppins SemiBold 18sp, Pure White).
* **Geofence Status Card (Flat Slate Box, 1px Border):**
  * Sisi Kiri: Ikon Radar / Lokasi Pin dengan titik hijau solid (*solid green dot*).
  * Sisi Kanan: Teks judul `"Lokasi Terverifikasi"` (Poppins Bold 15sp, Pure White) dan subteks pendukung `"Jarak Anda: 8 meter dari venue (Maks. radius: 100m)"` (Poppins Regular 12sp, Soft Gray).
  * Indikator Pill: `[Di Dalam Radius ✓]` berwarna hijau lembut (*soft green*).

### Selection Section (Dual Verification Methods):
* Header Bagian: `"PILIH METODE VERIFIKASI"` (Poppins Medium 11sp, huruf kapital kecil / uppercase, Soft Gray).
* **Option Card A (Biometrik):**
  * Kartu dengan target sentuh besar (*touch target* min 56px, Flat Slate Box).
  * Ikon: Sidik jari / Face ID.
  * Judul: `"Presensi Biometrik"` (Poppins SemiBold 15sp) dengan deskripsi `"Gunakan sidik jari atau Face ID perangkat"` (Poppins Regular 12sp, Soft Gray).
  * Trailing: Ikon panah kanan (*chevron arrow*).
* **Option Card B (Foto Swafoto):**
  * Kartu dengan target sentuh besar (*touch target* min 56px, Flat Slate Box).
  * Ikon: Kamera.
  * Judul: `"Presensi Swafoto"` (Poppins SemiBold 15sp) dengan deskripsi `"Ambil foto diri di area venue"` (Poppins Regular 12sp, Soft Gray).
  * Trailing: Ikon panah kanan (*chevron arrow*).

### Design Rules:
* Sangat mudah dipindai secara visual (*highly scannable*).
* Target sentuh ramah operasional lapangan (tinggi komponen interaktif minimal 56px).
* Garis tepi bersih (*clean borders*), tanpa gradien (*no gradients*), tata letak strictly fungsional.

---

## 5. Layar 4: Checklist Logistik Lapangan (`LogisticsScreen`)

### Top Navigation:
* **Segmented Control / Flat Tab Bar:**
  * Tab 1: `[Load-In (Aktif)]` (Border bawah atau background pill Sky Blue `#54A3FF`)
  * Tab 2: `[Load-Out]`
  * Tab 3: `[Pasca Acara]`

### Progress Summary:
* Ringkasan teks minimalis: `"14 dari 16 Barang Terverifikasi (88%)"` (Poppins Medium 13sp, Pure White).
* Indikator progress: Linear progress bar ramping dengan tinggi **4px** (Warna aktif Sky Blue atau Emerald Green).

### Checklist Card Feed:
* **Item Card 1 (Verified Good):**
  * Judul Barang: `"HT Motorola GP328 (10 Unit)"` (Poppins SemiBold 15sp, Pure White).
  * Subteks: `"Dicek oleh Dimas • Fisik: Baik"` (Poppins Regular 12sp, Soft Gray).
  * Trailing State: Ikon centang hijau (*green checkmark icon* `#10B981`).
* **Item Card 2 (Unverified / Attention Needed):**
  * Judul Barang: `"Kabel Roll 50m (4 Unit)"` (Poppins SemiBold 15sp, Pure White).
  * Baris Input Counter: `"Target: 4 Unit | Aktual: [ -  3  + ]"` dengan tombol minus dan plus responsif.
  * Pilihan Kondisi (Pill Selector): `[Baik]` | `[Rusak]` | `[Hilang]`.
  * Tombol Ikon Kamera: Untuk melampirkan foto bukti kondisi fisik barang.
  * Tombol Aksi: Outline button kompak `"Verifikasi"` (Poppins SemiBold 12sp).

### Design Constraints:
* Pemisah kartu minimalis (*minimalist card separators*), ukuran font mudah dibaca sekilas.
* Jarak antar komponen kompak (*compact spacing*) tanpa polusi visual (*no visual clutter*).
