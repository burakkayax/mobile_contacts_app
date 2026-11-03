from rest_framework import generics
from .models import Person
from .serializers import PersonSerializer


# GET /api/persons (Liste) ve POST /api/persons (Yeni Kayıt)
class PersonListCreateAPIView(generics.ListCreateAPIView):
    queryset = Person.objects.all()
    serializer_class = PersonSerializer


# GET, PUT ve DELETE /api/persons/{id}
class PersonDetailAPIView(generics.RetrieveUpdateDestroyAPIView):
    queryset = Person.objects.all()
    serializer_class = PersonSerializer
