import pytest
from django.test import RequestFactory as rf
from django.test import Client
from django.urls import reverse

from core.utilities.utils import view_names, camel_to_snake
pytestmark = pytest.mark.django_db

from bs4 import BeautifulSoup
import re

client = Client()

list_names = []
for method_name in view_names:
    list_names.append(camel_to_snake(method_name)+'_list')

def get_testco(login=False):
    """
    Gets the value of Testco based on the dropdown menu in a specific page
    """
    if not login:
        select_id = 'org_select'
        page = 'main_menu'
    else:
        select_id = 'id_organization'
        page = 'user_profile'
    response = client.get(reverse(page))
    soup = BeautifulSoup(response.content, 'html.parser')
    return soup.find(id=select_id).find_all('option', text=re.compile('TestCo'))[0]['value']


@pytest.fixture
def login():
    """
    Logs user in and adds the organization to the user
    """
    client.post('', {'username': 'vshekar', 'password': 'copperhead123'})
    client.post(reverse('user_profile'), {'add_org': 'add_org', 'organization': get_testco(login=True), 'password': 'test'})


def test_details():
    """
    Opens create_user page
    """
    response = client.get(reverse('create_user'))
    assert response.status_code == 200

@pytest.mark.ui_basic_tests
@pytest.mark.parametrize("name", list_names)
def test_list_views(login, name):
    """
    Opens all list_views looping through list_names
    """
    response = client.get(reverse(name))
    assert response.status_code == 200

@pytest.mark.ui_basic_tests
@pytest.mark.parametrize("name", list_names)
def test_detail_views(login, name):
    """
    Opens detail page for each model in list_names
    """
    testco_uuid = get_testco()
    response = client.post(reverse('main_menu'), {'select_org':'select_org', 'org_select':testco_uuid})
    response = client.get(reverse(name))
    soup = BeautifulSoup(response.content, 'html.parser')
    view_link = soup.select('.view-detail')[0]['href']
    response = client.get(view_link)
    assert response.status_code == 200

@pytest.mark.ui_basic_tests 
@pytest.mark.parametrize("name", list_names)
def test_update_views(login, name):
    """
    Opens update page for each model in list_names
    """
    testco_uuid = get_testco()
    response = client.post(reverse('main_menu'), {'select_org':'select_org', 'org_select':testco_uuid})
    response = client.get(reverse(name))
    soup = BeautifulSoup(response.content, 'html.parser')
    view_link = soup.select('.view-update')[0]['href']
    response = client.get(view_link)
    assert response.status_code == 200

@pytest.mark.ui_basic_tests
@pytest.mark.parametrize("name", list_names)
def test_add_views(login, name):
    """
    Opens add page for each model in list_names
    """
    response = client.get(reverse(name))
    soup = BeautifulSoup(response.content, 'html.parser')
    view_link = soup.select('.view-add')[0]['href']
    response = client.get(view_link)
    assert response.status_code == 200
