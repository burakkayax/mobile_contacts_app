from django.db import migrations


def seed_persons(apps, schema_editor):
    Person = apps.get_model('persons', 'Person')
    if Person.objects.exists():
        return

    initial_data = [
        {
            'fullName': 'Ahmet Yılmaz',
            'department': 'Yazılım Geliştirme',
            'photoUrl': 'https://randomuser.me/api/portraits/men/32.jpg',
            'birthPlace': 'Adana',
            'birthDate': '1994-04-12',
            'email': 'ahmet.yilmaz@sirket.com',
            'phone': '+905550123456',
        },
        {
            'fullName': 'Ayşe Kaya',
            'department': 'İnsan Kaynakları',
            'photoUrl': 'https://randomuser.me/api/portraits/women/44.jpg',
            'birthPlace': 'İstanbul',
            'birthDate': '1996-08-21',
            'email': 'ayse.kaya@sirket.com',
            'phone': '+905559876543',
        },
        {
            'fullName': 'Mehmet Demir',
            'department': 'Bilgi Teknolojileri',
            'photoUrl': 'https://randomuser.me/api/portraits/men/46.jpg',
            'birthPlace': 'Ankara',
            'birthDate': '1991-11-05',
            'email': 'mehmet.demir@sirket.com',
            'phone': '+905553216549',
        },
        {
            'fullName': 'Zeynep Çelik',
            'department': 'Ürün Yönetimi',
            'photoUrl': 'https://randomuser.me/api/portraits/women/68.jpg',
            'birthPlace': 'İzmir',
            'birthDate': '1995-02-18',
            'email': 'zeynep.celik@sirket.com',
            'phone': '+905554443322',
        },
        {
            'fullName': 'Caner Aydın',
            'department': 'Siber Güvenlik',
            'photoUrl': 'https://randomuser.me/api/portraits/men/75.jpg',
            'birthPlace': 'Bursa',
            'birthDate': '1993-07-30',
            'email': 'caner.aydin@sirket.com',
            'phone': '+905557778899',
        },
    ]

    for item in initial_data:
        Person.objects.create(**item)


class Migration(migrations.Migration):
    dependencies = [
        ('persons', '0001_initial'),
    ]

    operations = [
        migrations.RunPython(seed_persons),
    ]
