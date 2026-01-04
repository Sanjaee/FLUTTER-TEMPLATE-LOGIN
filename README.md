# Flutter Template Login - Zacode

Flutter template untuk autentikasi dengan struktur yang clean dan mudah di-maintain.

## 📋 Struktur Project

```
lib/
 ├── main.dart
 ├── app.dart
 ├── core/
 │    ├── constants/
 │    │     ├── colors.dart
 │    │     └── text_styles.dart
 │    ├── utils/
 │    │     └── validators.dart
 │    └── widgets/
 │          ├── primary_button.dart
 │          └── input_field.dart
 │
 ├── data/
 │    ├── models/
 │    ├── services/
 │    └── repository/
 │
 ├── features/
 │    ├── auth/
 │    │     ├── pages/
 │    │     ├── controllers/
 │    │     └── widgets/
 │    └── home/
 │          ├── pages/
 │          ├── controllers/
 │          └── widgets/
 │
 └── routes/
       └── app_routes.dart
```

**Prinsip Struktur:**
- ✅ Sedikit folder, tidak bikin pusing
- ✅ Scalable, mirip pola Clean Architecture tapi versi ringan
- ✅ Setiap fitur terpisah (auth, home, dashboard)
- ✅ Reusable, widget & helper tidak campur dengan fitur
- ✅ Mudah dibaca, developer lain langsung paham

## 🚀 Setup Project

### Prerequisites

- Flutter SDK (3.0 atau lebih tinggi)
- Dart SDK
- Android Studio / VS Code dengan Flutter extension
- API Backend (Express Template Login di Vercel)

### 1. Install Dependencies

```bash
flutter pub get
```

### 2. Setup API Configuration

Buka file `lib/core/constants/api_endpoints.dart` dan sesuaikan base URL API:

```dart
class ApiEndpoints {
  // Base URL - sesuaikan dengan backend server
  // Untuk development lokal, gunakan IP address atau localhost
  static const String baseUrl = 'https://express-template-login.vercel.app';
  
  // Atau gunakan URL local untuk development
  // static const String baseUrl = 'http://192.168.194.248:5000';
  
  // API version prefix
  static const String apiV1 = '$baseUrl/api/v1';
  
  // Semua endpoint lainnya menggunakan apiV1 sebagai prefix
  // Contoh: static const String register = '$apiV1/auth/register';
}
```

**Catatan:**
- Untuk production: Gunakan URL Vercel `https://express-template-login.vercel.app`
- Untuk development local: Uncomment dan gunakan IP local (contoh: `http://192.168.194.248:5000`)
- Pastikan URL menggunakan `https://` untuk production (lebih aman)
- Pastikan URL menggunakan `http://` untuk development local

### 3. Setup Network Security (Android)

File `android/app/src/main/res/xml/network_security_config.xml` sudah dikonfigurasi untuk:
- ✅ Mengizinkan HTTPS ke domain Vercel
- ✅ Trust SSL certificates yang valid
- ✅ Block cleartext traffic (HTTP) di production

**File sudah ada dan tidak perlu diubah jika menggunakan Vercel.**

Jika ingin menggunakan local development dengan HTTP, edit `network_security_config.xml`:

```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <!-- Development: Allow HTTP untuk local server -->
    <domain-config cleartextTrafficPermitted="true">
        <domain>192.168.194.248</domain>
        <domain>localhost</domain>
        <domain>10.0.2.2</domain> <!-- Android Emulator -->
    </domain-config>
    
    <!-- Production: Hanya HTTPS -->
    <domain-config cleartextTrafficPermitted="false">
        <domain includeSubdomains="true">express-template-login.vercel.app</domain>
        <domain includeSubdomains="true">*.vercel.app</domain>
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </domain-config>
    
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
            <certificates src="user" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

### 4. Verifikasi AndroidManifest

Pastikan `android/app/src/main/AndroidManifest.xml` sudah memiliki:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        android:label="Zacode"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false"
        android:networkSecurityConfig="@xml/network_security_config">
        <!-- ... -->
    </application>
</manifest>
```

**Penting:**
- `uses-permission INTERNET` harus ada untuk koneksi network
- `networkSecurityConfig` harus mengarah ke file XML yang sudah dibuat
- `usesCleartextTraffic="false"` untuk production (hanya HTTPS)

### 5. Run Aplikasi

```bash
# Development
flutter run

# Build APK Release
flutter build apk --release

# Build App Bundle (untuk Play Store)
flutter build appbundle --release
```

## 🔌 Menghubungkan ke API Vercel

### Setup untuk Production (Vercel)

1. **Pastikan API sudah deployed di Vercel:**
   - URL: `https://express-template-login.vercel.app`
   - Status: Active dan accessible

2. **Update API Config:**
   ```dart
   // lib/core/constants/api_endpoints.dart
   static const String baseUrl = 'https://express-template-login.vercel.app';
   ```

3. **Rebuild aplikasi:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

### Setup untuk Development (Local)

1. **Jalankan Express API local:**
   ```bash
   cd express
   npm install
   npm run dev
   # Server berjalan di http://localhost:5000
   ```

2. **Dapatkan IP local:**
   - Windows: `ipconfig` → cari IPv4 Address
   - Mac/Linux: `ifconfig` → cari inet
   - Contoh: `192.168.194.248`

3. **Update API Config:**
   ```dart
   // lib/core/constants/api_endpoints.dart
   static const String baseUrl = 'http://192.168.194.248:5000';
   ```

4. **Update Network Security Config** (jika perlu HTTP):
   - Edit `network_security_config.xml`
   - Tambahkan IP local di `domain-config` dengan `cleartextTrafficPermitted="true"`

5. **Restart aplikasi:**
   ```bash
   flutter run
   ```

### Testing Koneksi

1. **Test API endpoint:**
   ```bash
   # Test dengan curl atau browser
   curl https://express-template-login.vercel.app/
   
   # Expected response:
   # {"message":"API Server is running"}
   ```

2. **Test dari aplikasi:**
   - Jalankan aplikasi Flutter
   - Coba register atau login
   - Cek network logs di console
   - Pastikan request berhasil dan mendapat response

## 🛠️ Troubleshooting

### Error: "Connection refused" atau "Failed host lookup"

**Penyebab:** URL API tidak bisa diakses atau salah.

**Solusi:**
1. Pastikan URL di `api_endpoints.dart` benar
2. Test URL dengan browser atau Postman
3. Pastikan API server sudah running (jika local)
4. Pastikan device/emulator dan server dalam network yang sama (jika local)

### Error: "HandshakeException" atau SSL Error

**Penyebab:** Masalah dengan SSL certificate atau HTTPS configuration.

**Solusi:**
1. Pastikan menggunakan `https://` untuk Vercel
2. Pastikan `network_security_config.xml` sudah benar
3. Pastikan AndroidManifest mengarah ke network security config
4. Rebuild aplikasi setelah mengubah config

### Error: "Cleartext HTTP traffic not permitted"

**Penyebab:** Aplikasi mencoba akses HTTP tapi network security config tidak mengizinkan.

**Solusi:**
1. Untuk production: Gunakan HTTPS, jangan HTTP
2. Untuk development local: Edit `network_security_config.xml`:
   ```xml
   <domain-config cleartextTrafficPermitted="true">
       <domain>192.168.194.248</domain>
   </domain-config>
   ```
3. Atau set `usesCleartextTraffic="true"` di AndroidManifest (tidak disarankan untuk production)

### Error: "Network is unreachable" (Android Emulator)

**Penyebab:** Emulator tidak bisa akses localhost dari host machine.

**Solusi:**
- Gunakan `10.0.2.2` sebagai IP untuk localhost di emulator
- Contoh: `http://10.0.2.2:5000` (bukan `localhost:5000`)

### API Response Error 404 atau 500

**Penyebab:** Endpoint API salah atau server error.

**Solusi:**
1. Pastikan endpoint di Flutter match dengan Express API
2. Cek Express API logs untuk error
3. Test endpoint langsung dengan Postman
4. Pastikan API sudah deployed (jika production)

## 📝 Penjelasan Folder

### ✔️ core/
Hal-hal yang bisa dipakai di seluruh aplikasi
- `constants/` → warna, text style, API config
- `utils/` → validator, helper functions
- `widgets/` → reusable widgets (Button, InputField)

### ✔️ data/
Semua yang berkaitan dengan data
- `models/` → data models (User, AuthResponse, dll)
- `services/` → API service calls
- `repository/` → data repository pattern

### ✔️ features/
Folder utama berisi fitur
- `auth/` → Login, Register, OTP Verification
- `home/` → Home page, Dashboard
- Masing-masing punya:
  - `pages/` → UI screens
  - `controllers/` → state management
  - `widgets/` → widget khusus fitur

### ✔️ routes/
Semua routing aplikasi di satu file
- `app_routes.dart` → route definitions

## 📚 Endpoint API yang Digunakan

- `POST /api/v1/auth/register` - Register user baru
- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/verify-otp` - Verify OTP
- `POST /api/v1/auth/resend-otp` - Resend OTP
- `POST /api/v1/auth/forgot-password` - Request reset password
- `POST /api/v1/auth/verify-reset-password` - Verify reset password
- `POST /api/v1/auth/reset-password` - Reset password
- `GET /api/v1/auth/me` - Get current user (dengan Bearer token)

## 🔐 Environment Configuration

Untuk development dan production yang berbeda, bisa gunakan:

```dart
class ApiEndpoints {
  static const bool isProduction = bool.fromEnvironment('dart.vm.product');
  
  static String get baseUrl {
    if (isProduction) {
      return 'https://express-template-login.vercel.app';
    } else {
      return 'http://192.168.194.248:5000';
    }
  }
  
  static String get apiV1 => '$baseUrl/api/v1';
  // Update semua endpoint lainnya untuk menggunakan apiV1
}
```

Atau gunakan environment variables dengan package `flutter_dotenv`.

## 📱 Build untuk Release

```bash
# Clean build
flutter clean

# Get dependencies
flutter pub get

# Build APK
flutter build apk --release

# Build App Bundle (Play Store)
flutter build appbundle --release

# Build IPA (iOS - butuh Mac + Xcode)
flutter build ipa --release
```

## 🆘 Butuh Bantuan?

- Pastikan semua prerequisites sudah terinstall
- Cek network connection
- Pastikan API server accessible
- Cek logs di Flutter console untuk error detail
- Review troubleshooting section di atas

---

**Happy Coding! 🚀**
