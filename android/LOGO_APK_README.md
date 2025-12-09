# Lokasi Logo APK (App Icon)

Logo APK (App Icon) untuk aplikasi Android berada di folder berikut:

## 📁 Lokasi File Logo

```
android/app/src/main/res/
├── mipmap-mdpi/
│   └── ic_launcher.png      (48x48 px)
├── mipmap-hdpi/
│   └── ic_launcher.png      (72x72 px)
├── mipmap-xhdpi/
│   └── ic_launcher.png      (96x96 px)
├── mipmap-xxhdpi/
│   └── ic_launcher.png      (144x144 px)
└── mipmap-xxxhdpi/
    └── ic_launcher.png      (192x192 px)
```

## 🎨 Cara Mengganti Logo

1. **Siapkan logo** dengan ukuran yang sesuai untuk setiap folder:
   - `mipmap-mdpi`: 48x48 px
   - `mipmap-hdpi`: 72x72 px
   - `mipmap-xhdpi`: 96x96 px
   - `mipmap-xxhdpi`: 144x144 px
   - `mipmap-xxxhdpi`: 192x192 px

2. **Ganti file** `ic_launcher.png` di setiap folder dengan logo baru Anda

3. **Rebuild aplikasi**:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## 💡 Tips

- Gunakan format PNG dengan background transparan
- Pastikan logo terlihat jelas di berbagai ukuran
- Test logo di device dengan berbagai ukuran layar
- Logo akan otomatis di-round oleh Android (adaptive icon)

## 🔧 Menggunakan Flutter Launcher Icons (Opsional)

Untuk memudahkan, Anda bisa menggunakan package `flutter_launcher_icons`:

1. Install package:
   ```bash
   flutter pub add dev:flutter_launcher_icons
   ```

2. Tambahkan konfigurasi di `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     image_path: "assets/icon/icon.png"
   ```

3. Generate icons:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

