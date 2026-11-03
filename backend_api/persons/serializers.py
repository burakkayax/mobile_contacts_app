from rest_framework import serializers
from .models import Person


class PersonSerializer(serializers.ModelSerializer):
    """Modeldeki snake_case alanları yönergedeki camelCase JSON şemasına bağlar."""
    fullName = serializers.CharField(source='full_name')
    photoUrl = serializers.CharField(
        source='photo_url',
        allow_blank=True,
        required=False,
    )
    birthPlace = serializers.CharField(source='birth_place')
    birthDate = serializers.DateField(source='birth_date')

    class Meta:
        model = Person
        fields = [
            'id',
            'fullName',
            'department',
            'photoUrl',
            'birthPlace',
            'birthDate',
            'email',
            'phone',
        ]
