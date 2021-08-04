'''
Created on May 10, 2021

@author: jpannizzo
'''

import pytest
from django.test import RequestFactory as rf
from django.test import Client
from django.urls import reverse
from rest_framework.test import force_authenticate
from core.models.app_tables import CustomUser
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient
from django.urls import reverse
from rest_api.utils import rest_experiment_views, snake_case
import json

pytestmark = pytest.mark.django_db
client = Client()

view_names = rest_experiment_views
exceptions = []
view_names = [name for name in view_names if name not in exceptions]

api_view_names = []
for method_name in view_names:
    api_view_names.append(method_name.lower()+'-list')

@pytest.fixture
def api_client():
    client = APIClient()
    resp = client.post('/api/login', data={'username': 'jpannizzo', 'password':'password1'}, format='json')
    client.credentials(HTTP_AUTHORIZATION=f'Token {resp.json()["token"]}')
    return client

@pytest.mark.api_experiment_details
@pytest.mark.parametrize("name", api_view_names)
def test_all_form_parameters_get(name):
    response = client.get(reverse(name))
    assert response.status_code == 200
    