from django.urls import re_path
from .views import PersonListCreateAPIView, PersonDetailAPIView

urlpatterns = [
    re_path(r'^persons/?$', PersonListCreateAPIView.as_view(), name='person-list-create'),
    re_path(r'^persons/(?P<pk>\d+)/?$', PersonDetailAPIView.as_view(), name='person-detail'),
]
