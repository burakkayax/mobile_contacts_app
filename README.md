# Kişi Yönetim Sistemi (Client-Server REST Mimarisi)

**Mobil Programlama Dersi — Vize Sınavı Proje Çalışması (2026-2027 Güz)**

Bu proje, **Flutter (Dart)** tabanlı mobil istemci (`/mobile_app`) ile **Django REST Framework (Python)** tabanlı bağımsız web servisinin (`/backend_api`) HTTP/REST protokolü ve JSON veri formatı üzerinden tam entegre (CRUD) çalışmasını sağlar.

---

## 1. Proje Dizin Yapısı

```text
.
├── backend_api/               # Django REST Framework Sunucu Katmanı (Python + SQLite)
│   ├── config/                # Django proje ayarları, CORS ve ana URL yönlendirmeleri
│   ├── persons/               # Person modeli, Serializer, APIView uç noktaları ve testler
│   ├── manage.py              # Django yönetim betiği
│   └── requirements.txt       # Python bağımlılık listesi
│
├── mobile_app/                # Flutter Mobil İstemci Katmanı (Dart)
│   ├── lib/
│   │   ├── main.dart          # Uygulama giriş noktası ve Material 3 tema yapılandırması
│   │   ├── models/
│   │   │   └── person.dart    # JSON <-> Dart veri modeli (fromJson / toJson)
│   │   ├── services/
│   │   │   └── api_service.dart # Asenkron HTTP istekleri (GET, POST, PUT, DELETE)
│   │   ├── screens/
│   │   │   ├── person_list_screen.dart   # 1. Kişi Listesi (Ana Sayfa + FAB)
│   │   │   ├── person_detail_screen.dart # 2. Kişi Detay Sayfası (Intent + Düzenle/Sil)
│   │   │   └── person_form_screen.dart   # Yeni Kişi Kayıt ve Güncelleme Formu
│   │   └── widgets/
│   │       └── person_avatar.dart        # Dairesel ağ profil fotoğrafı bileşeni
│   └── pubspec.yaml           # Flutter paket bağımlılıkları (http, url_launcher)
│
└── README.md                  # Kurulum, çalıştırma ve test kılavuzu
```

---

## 2. Backend API Servisinin Yerelde Kurulumu (`/backend_api`)

### Ön Gereksinimler
- **Python 3.10+** ve `pip`

### Adım Adım Kurulum ve Çalıştırma

1. Terminal açarak `backend_api` klasörüne geçin:
   ```bash
   cd backend_api
   ```

2. Python sanal ortamı (virtual environment) oluşturun ve etkinleştirin:
   ```bash
   # Windows (PowerShell)
   python -m venv venv
   .\venv\Scripts\Activate.ps1

   # macOS / Linux
   python3 -m venv venv
   source venv/bin/activate
   ```

3. Gerekli Python paketlerini (`django`, `djangorestframework`, `django-cors-headers`) yükleyin:
   ```bash
   pip install -r requirements.txt
   ```

4. SQLite veritabanı tablolarını ve başlangıç örnek kişi kayıtlarını oluşturun:
   ```bash
   python manage.py migrate
   ```

5. API sunucusunu başlatın:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```
   > **Not:** `0.0.0.0:8000` parametresi sayesinde hem yerel makineden (`http://127.0.0.1:8000`), hem Android Emülatörden (`http://10.0.2.2:8000`), hem de aynı Wi-Fi ağındaki fiziksel cihazlardan erişim sağlanır.

6. Backend birim testlerini çalıştırmak için:
   ```bash
   python manage.py test persons
   ```

---

## 3. REST Veri Şeması ve Uç Noktalar

| HTTP Metodu | Uç Nokta | İşlem / Görev Açıklaması |
| :--- | :--- | :--- |
| `GET` | `/api/persons` | Tüm kişileri dizi (`array`) formatında listeler. |
| `GET` | `/api/persons/{id}` | Belirtilen ID'ye sahip kişinin tüm detaylarını döner. |
| `POST` | `/api/persons` | Yeni kişi kaydı oluşturur (Form body JSON). |
| `PUT` | `/api/persons/{id}` | Kişinin iletişim ve unvan bilgilerini günceller. |
| `DELETE` | `/api/persons/{id}` | İlgili kaydı veritabanından kalıcı olarak siler. |

### Örnek Kişi JSON Şeması (Payload)

```json
{
  "id": 104,
  "fullName": "Ahmet Yılmaz",
  "department": "Yazılım Geliştirme",
  "photoUrl": "https://cdn.site/p/104.png",
  "birthPlace": "Adana",
  "birthDate": "1994-04-12",
  "email": "ahmet.yilmaz@sirket.com",
  "phone": "+905550123456"
}
```

---

## 4. Mobil Uygulama Kurulum ve Test Kılavuzu (`/mobile_app`)

### Ön Gereksinimler
- **Flutter SDK (3.x+)**

### Adım Adım Çalıştırma

1. Yeni bir terminalde `mobile_app` klasörüne gidin:
   ```bash
   cd mobile_app
   ```

2. Paket bağımlılıklarını indirin:
   ```bash
   flutter pub get
   ```

3. Uygulamayı aktif emülatör veya cihazda başlatın:
   ```bash
   flutter run
   ```

### Sunucu Bağlantı Adresi Yapılandırması
- **Android Emülatör:** Otomatik olarak `http://10.0.2.2:8000/api/persons` adresini kullanır.
- **Masaüstü / iOS Simülatör / Web:** Otomatik olarak `http://127.0.0.1:8000/api/persons` adresini kullanır.
- **Fiziksel Cihaz:** Uygulama üst çubuğundaki (AppBar) ağ ayarları ikonuna tıklayarak bilgisayarınızın yerel IP adresini (örn. `http://192.168.1.50:8000/api/persons`) çalışma zamanında girebilirsiniz.

### Çalıştırılabilir APK Derleme Komutu
Android test paketi (`.apk`) üretmek için:
```bash
cd mobile_app
flutter build apk --release --split-per-abi
```
Derlenen mimari bazlı optimize APK dosyaları `mobile_app/build/app/outputs/flutter-apk/` dizininde (`app-arm64-v8a-release.apk`, `app-x86_64-release.apk`) oluşturulur.
