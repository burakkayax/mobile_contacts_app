from django.db import models


class Person(models.Model):
    fullName = models.CharField(max_length=150)
    department = models.CharField(max_length=150)
    photoUrl = models.CharField(max_length=500, blank=True, default='')
    birthPlace = models.CharField(max_length=100)
    birthDate = models.DateField()
    email = models.EmailField(max_length=150)
    phone = models.CharField(max_length=30)

    class Meta:
        ordering = ['id']

    def __str__(self):
        return self.fullName
