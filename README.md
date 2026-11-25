# ⛅ Aplikasi Cuaca (Responsi Pemrograman Mobile)

Aplikasi ramalan cuaca modern, responsif, dan berbasis data real-time yang dibangun menggunakan **Flutter** dan **Dart**. Aplikasi ini menerapkan arsitektur **MVVM (Model-View-ViewModel)** secara murni dan tegas, memanfaatkan state management **Provider (`ChangeNotifier`)**, integrasi HTTP REST API dengan **Open-Meteo API** tanpa API key, serta penyimpanan lokal persisten menggunakan **SharedPreferences**.

---

## 🌟 Fitur Utama

1. **Cuaca Real-Time Berdasarkan Lokasi**:
   - Menampilkan kondisi cuaca terkini (cerah, berawan, gerimis, hujan, badai, dll.) dengan deskripsi bahasa Indonesia dan ikon Material Design.
   - Suhu saat ini (besar & menonjol) dan suhu terasa (*apparent temperature*).
   - Metrik lengkap: kelembapan udara (`%`), kecepatan angin (`km/h`), peluang hujan hari ini (`%`), dan curah hujan terkini (`mm`).
2. **Prakiraan Cuaca 7 Hari ke Depan**:
   - Menampilkan ramalan cuaca harian dari hari ini hingga 7 hari mendatang.
   - Format tanggal bahasa Indonesia (misal: "Hari ini", "Senin, 25 Nov").
   - Menampilkan ikon kondisi cuaca, peluang hujan (`%`), serta rentang suhu maksimum dan minimum.
3. **Pencarian Kota Real-Time & Debounce (~500 ms)**:
   - Pencarian kota di seluruh dunia secara langsung ke Geocoding API Open-Meteo.
   - Fitur *debounce* 500ms mencegah pemborosan request jaringan saat pengguna sedang mengetik.
4. **Pengelolaan Lokasi Favorit**:
   - Simpan kota-kota favorit dengan satu sentuhan pada tombol bintang (⭐).
   - Akses cepat untuk melihat cuaca di kota favorit kapan saja.
5. **Riwayat Pencarian (Search History)**:
   - Menyimpan otomatis hingga 10 lokasi terakhir yang pernah dicari tanpa duplikasi.
   - Fitur hapus riwayat secara individual maupun tombol "Hapus Semua".
6. **Penyimpanan Lokasi Terakhir**:
   - Menyimpan kota terakhir yang sedang aktif dibuka pengguna. Saat aplikasi ditutup total dan dibuka kembali, cuaca kota tersebut langsung dimuat secara otomatis.
   - Saat pertama kali dibuka (belum ada riwayat), aplikasi secara cerdas mencari kota default **"Purwokerto"** via Geocoding API secara dinamis (tanpa koordinat hardcode).
7. **Pengalaman Pengguna (UX) & State Lengkap**:
   - Penanganan state yang solid: `Initial`, `Loading`, `Success`, `Empty`, dan `Error`.
   - Menampilkan pesan error ramah pengguna jika terjadi gangguan jaringan (*SocketException*), waktu habis (*TimeoutException*), atau kesalahan format (*FormatException*), dilengkapi tombol **"Coba Lagi"**.
   - Mendukung **Pull-to-Refresh** (*RefreshIndicator*) serta tombol refresh pada AppBar.
8. **Desain Material Design 3 & Responsif**:
   - Menggunakan `useMaterial3: true` dengan palet warna modern berbasis *Color Scheme* yang konsisten.
   - Layout responsif dengan `ConstrainedBox` (lebar konten terjaga rapi pada layar smartphone kecil, tablet, hingga web/desktop).

---

## 📁 Struktur Folder & Arsitektur Project

Proyek ini menerapkan pemisahan tugas yang tegas sesuai kaidah arsitektur MVVM:

```text
lib/
│
├── main.dart                          # Titik masuk aplikasi, inisialisasi DI & MultiProvider
│
├── core/                              # Konfigurasi inti dan helper aplikasi
│   ├── app_theme.dart                 # Konfigurasi ThemeData (Material 3, ColorScheme, Typography)
│   └── weather_code_helper.dart       # Mapping kode WMO cuaca ke deskripsi ID, ikon, & format tanggal
│
├── models/                            # MODEL: Data structures & JSON serialization
│   ├── location_model.dart            # Model lokasi (id, nama kota, latitude, longitude, negara, admin1)
│   └── weather_model.dart             # Model CurrentWeather, DailyForecast, & WeatherData
│
├── services/                          # SERVICE: Akses langsung ke API eksternal & Storage
│   ├── weather_api_service.dart       # HTTP client untuk Open-Meteo Geocoding & Forecast API
│   └── local_storage_service.dart     # Service SharedPreferences (baca/tulis JSON string)
│
├── repositories/                      # REPOSITORY: Single Source of Truth bagi ViewModel
│   └── weather_repository.dart        # Jembatan antara ViewModel dengan API Service & Local Storage
│
├── viewmodels/                        # VIEWMODEL: Logika bisnis & state management (ChangeNotifier)
│   ├── weather_viewmodel.dart         # Pengelolaan state cuaca kota terpilih (bebas dari import widget UI)
│   └── search_viewmodel.dart          # Pengelolaan pencarian kota, favorit, & riwayat (debounce 500ms)
│
└── views/                             # VIEW: Tampilan antarmuka pengguna (UI murni)
    ├── home_screen.dart               # Layar utama menampilkan cuaca kota aktif & forecast 7 hari
    ├── search_screen.dart             # Layar pencarian kota, daftar favorit, & riwayat pencarian
    └── widgets/                       # Widget modular dan reusable
        ├── current_weather_card.dart  # Kartu gradien cuaca saat ini & suhu besar
        ├── weather_info_tile.dart     # Petak info tambahan (kelembapan, angin, hujan)
        ├── daily_forecast_item.dart   # Item baris perkiraan cuaca harian
        ├── location_list_tile.dart    # ListTile untuk hasil pencarian, favorit, & riwayat
        ├── loading_view.dart          # Indikator loading ramah pengguna
        ├── error_view.dart            # Tampilan error dengan tombol "Coba Lagi"
        └── empty_view.dart            # Tampilan data kosong yang informatif
```

---

## 🌐 Implementasi API (Open-Meteo)

Aplikasi menggunakan REST API publik dari [Open-Meteo](https://open-meteo.com/) yang tidak memerlukan API key. Panggilan HTTP dibuat menggunakan package `http` standar dengan `Uri.https()`.

### 1. Geocoding API (Pencarian Kota)
- **Endpoint**:
  `GET https://geocoding-api.open-meteo.com/v1/search`
- **Query Parameters**:
  - `name`: Kata kunci nama kota (contoh: "Jakarta", "Purwokerto")
  - `count`: `10`
  - `language`: `id` (Bahasa Indonesia)
  - `format`: `json`
- **Field JSON yang Dipakai**:
  - `id`: ID unik kota
  - `name`: Nama kota
  - `latitude` & `longitude`: Koordinat lokasi
  - `country`: Nama negara
  - `admin1`: Provinsi atau wilayah administratif

### 2. Weather Forecast API (Ramalan Cuaca)
- **Endpoint**:
  `GET https://api.open-meteo.com/v1/forecast`
- **Query Parameters**:
  - `latitude` & `longitude`: Koordinat lokasi kota
  - `current`: `temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m`
  - `daily`: `weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max`
  - `timezone`: `auto`
  - `forecast_days`: `7`
- **Field JSON yang Dipakai**:
  - `current.temperature_2m`: Suhu udara saat ini (°C)
  - `current.apparent_temperature`: Suhu yang terasa (°C)
  - `current.relative_humidity_2m`: Tingkat kelembapan udara (%)
  - `current.wind_speed_10m`: Kecepatan angin (km/h)
  - `current.precipitation`: Curah hujan saat ini (mm)
  - `current.weather_code`: Kode WMO kondisi cuaca
  - `daily.time[]`: Tanggal-tanggal prakiraan harian
  - `daily.weather_code[]`: Kode cuaca harian
  - `daily.temperature_2m_max[]`: Suhu tertinggi per hari
  - `daily.temperature_2m_min[]`: Suhu terendah per hari
  - `daily.precipitation_probability_max[]`: Peluang terjadinya hujan per hari (%)

### Alur Aliran Data:
```text
[Open-Meteo REST API]
         │ (HTTP GET via package:http)
         ▼
[WeatherApiService]
         │ (Parsing JSON ke Model Dart)
         ▼
[WeatherRepository]
         │ (Menyediakan data bersih & abstraksi)
         ▼
[WeatherViewModel / SearchViewModel]
         │ (Mengelola State: loading, success, error, empty)
         ▼
[Views (HomeScreen / SearchScreen)]
         │ (Menampilkan UI ke pengguna via Consumer / context.watch)
         ▼
[Pengguna]
```

---

## 🏛️ Penerapan Arsitektur MVVM

Pada proyek ini, arsitektur **MVVM** dipisahkan dengan sangat tegas:

1. **Model (`lib/models/`)**:
   - Berisi kelas entitas murni data (`LocationModel`, `CurrentWeather`, `DailyForecast`, `WeatherData`).
   - Bertanggung jawab melakukan serialisasi dan deserialisasi JSON (`fromJson` dan `toJson`).
   - *Tidak memiliki dependensi ke UI atau bisnis logika.*

2. **ViewModel (`lib/viewmodels/`)**:
   - Menggunakan `ChangeNotifier` dari Flutter foundation.
   - `WeatherViewModel`: Mengelola kota yang sedang dipilih, memuat cuaca dari repository, mengontrol state (`initial`, `loading`, `success`, `empty`, `error`), serta mengekspos data cuaca ke UI.
   - `SearchViewModel`: Mengelola proses pencarian kota dengan debounce 500ms, mengelola daftar lokasi favorit, serta riwayat pencarian.
   - *Bebas dari import widget Flutter (tanpa `BuildContext`, tanpa `Widget`).*

3. **View (`lib/views/`)**:
   - Menangani murni tampilan antarmuka (UI).
   - Membaca state dari ViewModel menggunakan `Consumer<ViewModel>` atau `context.watch<ViewModel>()`.
   - Mengirim aksi pengguna (misal: tombol ditekan, refresh, submit teks) dengan memanggil method di ViewModel via `context.read<ViewModel>()`.
   - *Dilarang keras melakukan HTTP request atau akses SharedPreferences langsung di dalam View.*

---

## 💾 State Management & Local Storage

### State Management (Provider)
Aplikasi menggunakan **Provider** dengan pola `ChangeNotifierProvider` dan enum status yang konsisten:
- `ViewState.initial`: Keadaan awal sebelum data diminta.
- `ViewState.loading`: Sedang memuat data dari jaringan/penyimpanan (menampilkan `LoadingView`).
- `ViewState.success`: Data berhasil diperoleh dan siap dirender di UI.
- `ViewState.empty`: Data kosong, misalnya kota tidak ditemukan (menampilkan `EmptyView`).
- `ViewState.error`: Terjadi kegagalan jaringan atau server (menampilkan `ErrorView` + tombol retry).

### Local Storage (SharedPreferences)
Data disimpan dalam bentuk JSON string sehingga persisten walaupun aplikasi ditutup atau dimatikan total:

| Key SharedPreferences | Tipe Data Disimpan | Deskripsi |
| :--- | :--- | :--- |
| `last_selected_location` | `String` (JSON Object) | Menyimpan data `LocationModel` dari kota terakhir yang dipilih pengguna |
| `favorite_locations` | `String` (JSON Array) | Menyimpan daftar list kota favorit pengguna (`List<LocationModel>`) |
| `search_history` | `String` (JSON Array) | Menyimpan maksimal 10 riwayat lokasi pencarian terakhir tanpa duplikasi |

---

## 🚀 Cara Menjalankan Aplikasi

Pastikan Flutter SDK (minimal versi 3.13) dan perangkat Android/Emulator telah terkonfigurasi.

1. **Clone atau buka direktori proyek**:
   ```bash
   cd responsi2_pemmob
   ```

2. **Ambil semua dependency package**:
   ```bash
   flutter pub get
   ```

3. **Verifikasi kode dengan analisis statis (harus 0 issues)**:
   ```bash
   flutter analyze
   ```

4. **Jalankan unit/widget test**:
   ```bash
   flutter test
   ```

5. **Jalankan aplikasi di Emulator atau Device Android**:
   ```bash
   flutter run
   ```

---

## 📸 Tangkapan Layar (Screenshots)

| Layar Utama (Home) | Layar Pencarian (Search) | Daftar Favorit & Riwayat |
| :---: | :---: | :---: |
| ![Home Screen](docs/screenshots/home.png) | ![Search Screen](docs/screenshots/search.png) | ![Favorites Screen](docs/screenshots/favorit.png) |

*(Catatan: Gambar screenshot dapat diletakkan pada folder `docs/screenshots/`)*

---

## 🔗 Tautan Repository & Video Demonstrasi

- **Repository GitHub**: `https://github.com/ErgiSinaga/Responsi2PrakPemmob_H1D024072`
- **Link Video Penjelasan Kode & Demo**: `https://youtube.com/watch?v=...` *(Dapat disesuaikan)*

---

*Dibuat untuk memenuhi Tugas RESPONSI Praktikum Pemrograman Mobile.*
