from django.contrib import admin
from .models import Person


@admin.register(Person)
class PersonAdmin(admin.ModelAdmin):
    list_display = ('id', 'full_name', 'department', 'email', 'phone')
    search_fields = ('full_name', 'department', 'email')
