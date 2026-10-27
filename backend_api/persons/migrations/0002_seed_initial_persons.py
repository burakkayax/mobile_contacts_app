from django.db import migrations


def seed_persons(apps, schema_editor):
    Person = apps.get_model('persons', 'Person')
    if Person.objects.exists():
        return

    initial_data = [
        {
            'full_name': 'Ahmet Yılmaz',
            'department': 'Yazılım Geliştirme',
            'photo_url': 'https://randomuser.me/api/portraits/men/32.jpg',
            'birth_place': 'Adana',
            'birth_date': '1994-04-12',
            'email': 'ahmet.yilmaz@sirket.com',
            'phone': '+905550123456',
        },
        {
            'full_name': 'Ayşe Kaya',
            'department': 'İnsan Kaynakları',
            'photo_url': 'https://randomuser.me/api/portraits/women/44.jpg',
            'birth_place': 'İstanbul',
            'birth_date': '1996-08-21',
            'email': 'ayse.kaya@sirket.com',
            'phone': '+905559876543',
        },
        {
            'full_name': 'Mehmet Demir',
            'department': 'Bilgi Teknolojileri',
            'photo_url': 'https://randomuser.me/api/portraits/men/46.jpg',
            'birth_place': 'Ankara',
            'birth_date': '1991-11-05',
            'email': 'mehmet.demir@sirket.com',
            'phone': '+905553216549',
        },
        {
            'full_name': 'Zeynep Çelik',
            'department': 'Ürün Yönetimi',
            'photo_url': 'https://randomuser.me/api/portraits/women/68.jpg',
            'birth_place': 'İzmir',
            'birth_date': '1995-02-18',
            'email': 'zeynep.celik@sirket.com',
            'phone': '+905554443322',
        },
        {
            'full_name': 'Caner Aydın',
            'department': 'Siber Güvenlik',
            'photo_url': 'https://randomuser.me/api/portraits/men/75.jpg',
            'birth_place': 'Bursa',
            'birth_date': '1993-07-30',
            'email': 'caner.aydin@sirket.com',
            'phone': '+905557778899',
        },
    ]

    for item in initial_data:
        Person.objects.create(**item)


def unseed_persons(apps, schema_editor):
    Person = apps.get_model('persons', 'Person')
    Person.objects.all().delete()


class Migration(migrations.Migration):
    dependencies = [
        ('persons', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(seed_persons, unseed_persons),
    ]
