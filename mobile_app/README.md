# Kişi Yönetim Sistemi — Mobil İstemci (Flutter)

Bu klasör, Kişi Yönetim Sistemi projesinin **Flutter (Dart)** ile geliştirilen mobil istemci katmanını (`/mobile_app`) içerir.

## Kullanılan Kütüphaneler (`pubspec.yaml`)

- **`http` (`package:http/http.dart`)**: Backend REST API servisine asenkron `GET`, `POST`, `PUT` ve `DELETE` istekleri göndermek için kullanılır.
- **`url_launcher` (`package:url_launcher/url_launcher.dart`)**: Kişi detay sayfasındaki telefon (`tel:`) ve e-posta (`mailto:`) satırlarına tıklandığında işletim sisteminin arama ve e-posta gönderme niyetlerini (Intent) tetiklemek için kullanılır.

## Çalıştırma Komutları

```bash
flutter pub get
flutter run
```

## APK Derleme

```bash
flutter build apk --release --split-per-abi
```
Hazır derlenmiş APK paketi `release/kisi_yonetim_sistemi.apk` dizininde yer almaktadır.
