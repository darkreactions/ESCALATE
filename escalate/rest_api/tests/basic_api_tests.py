import pytest
from django.test import RequestFactory as rf
from django.test import Client
from django.urls import reverse


from rest_api.utils import rest_viewset_views
from bs4 import BeautifulSoup

pytestmark = pytest.mark.django_db
client = Client()

view_names = rest_viewset_views
exceptions = []
view_names = [name for name in view_names if name not in exceptions]

api_view_names = []
for method_name in view_names:
    api_view_names.append(camel_case(method_name)+'-list')


@pytest.mark.parametrize("name", api_view_names)
def test_api_list_views(name):
    response = client.get(reverse(name))
    assert response.status_code == 200
