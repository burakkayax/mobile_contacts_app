from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = []

    operations = [
        migrations.CreateModel(
            name='Person',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('fullName', models.CharField(max_length=150)),
                ('department', models.CharField(max_length=150)),
                ('photoUrl', models.CharField(blank=True, default='', max_length=500)),
                ('birthPlace', models.CharField(max_length=100)),
                ('birthDate', models.DateField()),
                ('email', models.EmailField(max_length=150)),
                ('phone', models.CharField(max_length=30)),
            ],
            options={
                'ordering': ['id'],
            },
        ),
    ]
