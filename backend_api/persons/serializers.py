from urllib.parse import quote
from rest_framework import serializers
from .models import Person


class PersonSerializer(serializers.ModelSerializer):
    """
    Modeldeki snake_case alanları yönergedeki camelCase JSON şemasına bağlar:
    fullName, department, photoUrl, birthPlace, birthDate (YYYY-MM-DD), email, phone
    """
    fullName = serializers.CharField(source='full_name', max_length=150)
    photoUrl = serializers.CharField(
        source='photo_url',
        max_length=500,
        allow_blank=True,
        required=False,
        default='',
    )
    birthPlace = serializers.CharField(source='birth_place', max_length=100)
    birthDate = serializers.DateField(
        source='birth_date',
        format='%Y-%m-%d',
        input_formats=['%Y-%m-%d', 'iso-8601'],
    )

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

    def validate(self, attrs):
        # Fotoğraf URL boş bırakılırsa kişinin baş harflerinden otomatik avatar URL üretilir
        photo_url = attrs.get('photo_url', '').strip()
        full_name = attrs.get('full_name') or getattr(self.instance, 'full_name', 'Person')
        if not photo_url or 'ui-avatars.com/api/' in photo_url:
            encoded_name = quote(full_name)
            attrs['photo_url'] = (
                f"https://ui-avatars.com/api/?name={encoded_name}&background=1E88E5&color=fff&size=256"
            )
        return attrs
