from django.urls import path
from .views import PersonListCreateAPIView, PersonDetailAPIView

urlpatterns = [
    path('persons', PersonListCreateAPIView.as_view()),
    path('persons/<int:pk>', PersonDetailAPIView.as_view()),
]
