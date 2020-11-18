import pytest
from django.test import RequestFactory as rf
from django.test import Client
from django.urls import reverse

from core.views import *
from core.views.list_methods import methods as list_methods
from core.utils import camel_to_snake
from bs4 import BeautifulSoup

pytestmark = pytest.mark.django_db
client = Client()

list_names = []
for method_name in list_methods:
    list_names.append(camel_to_snake(method_name)+'_list')


@pytest.fixture
def login():
    client.post('', {'username': 'ikhovryak', 'password': 'safari77'})


def test_details():
    response = client.get(reverse('create_user'))
    assert response.status_code == 200


@pytest.mark.parametrize("name", list_names)
def test_list_views(login, name):
    response = client.get(reverse(name))
    assert response.status_code == 200


@pytest.mark.parametrize("name", list_names)
def test_detail_views(login, name):
    response = client.get(reverse(name))
    soup = BeautifulSoup(response.content, 'html.parser')
    view_link = soup.select('.view-detail')[0]['href']
    response = client.get(view_link)
    assert response.status_code == 200


@pytest.mark.parametrize("name", list_names)
def test_update_views(login, name):
    response = client.get(reverse(name))
    soup = BeautifulSoup(response.content, 'html.parser')
    view_link = soup.select('.view-update')[0]['href']
    response = client.get(view_link)
    assert response.status_code == 200


@pytest.mark.parametrize("name", list_names)
def test_add_views(login, name):
    response = client.get(reverse(name))
    soup = BeautifulSoup(response.content, 'html.parser')
    view_link = soup.select('.view-add')[0]['href']
    response = client.get(view_link)
    assert response.status_code == 200
