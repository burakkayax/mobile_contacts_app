from django.test import TestCase
from rest_framework import status
from rest_framework.test import APIClient
from .models import Person


class PersonAPITests(TestCase):
    def setUp(self):
        self.client = APIClient()

    def test_get_persons_list(self):
        response = self.client.get('/api/persons')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertIsInstance(response.data, list)
        self.assertGreaterEqual(len(response.data), 3)
        first = response.data[0]
        expected_keys = {
            'id',
            'fullName',
            'department',
            'photoUrl',
            'birthPlace',
            'birthDate',
            'email',
            'phone',
        }
        self.assertEqual(set(first.keys()), expected_keys)

    def test_create_get_update_delete_person(self):
        payload = {
            'fullName': 'Test Kullanıcı',
            'department': 'Ar-Ge',
            'photoUrl': 'https://cdn.site/p/104.png',
            'birthPlace': 'Antalya',
            'birthDate': '1998-05-20',
            'email': 'test@sirket.com',
            'phone': '+905551112233',
        }
        create_res = self.client.post('/api/persons', payload, format='json')
        self.assertEqual(create_res.status_code, status.HTTP_201_CREATED)
        person_id = create_res.data['id']
        self.assertEqual(create_res.data['fullName'], 'Test Kullanıcı')

        detail_res = self.client.get(f'/api/persons/{person_id}')
        self.assertEqual(detail_res.status_code, status.HTTP_200_OK)
        self.assertEqual(detail_res.data['birthPlace'], 'Antalya')

        updated_payload = {
            **payload,
            'department': 'Kıdemli Ar-Ge',
            'phone': '+905559998877',
        }
        update_res = self.client.put(f'/api/persons/{person_id}', updated_payload, format='json')
        self.assertEqual(update_res.status_code, status.HTTP_200_OK)
        self.assertEqual(update_res.data['department'], 'Kıdemli Ar-Ge')
        self.assertEqual(update_res.data['phone'], '+905559998877')

        delete_res = self.client.delete(f'/api/persons/{person_id}')
        self.assertEqual(delete_res.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(Person.objects.filter(pk=person_id).exists())
