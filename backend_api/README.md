# Kişi Yönetim Sistemi — Backend API (Django REST Framework)

Bu klasör, Mobil Programlama Dersi Vize Projesi kapsamında geliştirilen **Django REST Framework (DRF)** tabanlı sunucu katmanını (`/backend_api`) içerir.

## 1. Gereksinimler

- Python 3.10 veya üzeri
- pip (Python paket yöneticisi)

## 2. Yerelde Kurulum Adımları

1. Terminalde `backend_api` dizinine gidin:
   ```bash
   cd backend_api
   ```

2. Sanal ortam (virtual environment) oluşturun ve aktif edin:
   ```bash
   # Windows (PowerShell)
   python -m venv venv
   .\venv\Scripts\Activate.ps1

   # macOS / Linux
   python3 -m venv venv
   source venv/bin/activate
   ```

3. Bağımlılıkları yükleyin:
   ```bash
   pip install -r requirements.txt
   ```

4. Veritabanı tablolarını ve başlangıç (örnek) kişi verilerini oluşturun:
   ```bash
   python manage.py migrate
   ```

5. Geliştirme sunucusunu tüm ağ arayüzlerinden erişilebilir şekilde başlatın:
   ```bash
   python manage.py runserver 0.0.0.0:8000
   ```

Sunucu varsayılan olarak `http://127.0.0.1:8000` (Android Emülatör için `http://10.0.2.2:8000`) adresinde çalışacaktır.

## 3. REST API Uç Noktaları (Endpoints)

| Metot | Uç Nokta | Açıklama |
| :--- | :--- | :--- |
| `GET` | `/api/persons` | Tüm kişileri JSON dizi (array) formatında listeler. |
| `GET` | `/api/persons/{id}` | Belirtilen ID'ye sahip kişinin tüm detaylarını döner. |
| `POST` | `/api/persons` | Yeni kişi kaydı oluşturur (JSON gövdesi). |
| `PUT` | `/api/persons/{id}` | Kişinin tüm bilgilerini günceller. |
| `DELETE` | `/api/persons/{id}` | İlgili kaydı veritabanından kalıcı olarak siler. |

### Örnek JSON Veri Şeması (Payload)

```json
{
  "id": 1,
  "fullName": "Ahmet Yılmaz",
  "department": "Yazılım Geliştirme",
  "photoUrl": "https://randomuser.me/api/portraits/men/32.jpg",
  "birthPlace": "Adana",
  "birthDate": "1994-04-12",
  "email": "ahmet.yilmaz@sirket.com",
  "phone": "+905550123456"
}
```

## 4. Testleri Çalıştırma

API uç noktalarının birim testlerini doğrulamak için:
```bash
python manage.py test persons
```
