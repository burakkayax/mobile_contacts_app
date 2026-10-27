from django.db import models


class Person(models.Model):
    full_name = models.CharField(max_length=150)
    department = models.CharField(max_length=150)
    photo_url = models.CharField(max_length=500, blank=True, default='')
    birth_place = models.CharField(max_length=100)
    birth_date = models.DateField()
    email = models.EmailField(max_length=150)
    phone = models.CharField(max_length=30)

    class Meta:
        ordering = ['id']

    def __str__(self):
        return f"{self.full_name} ({self.department})"
