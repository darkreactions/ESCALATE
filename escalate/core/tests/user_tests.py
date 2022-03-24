from __future__ import annotations
from typing import Any
import pytest

from django.test import RequestFactory as rf
from django.test import Client
from django.urls import reverse


pytestmark = pytest.mark.django_db
client = Client()

data: list[dict[str, Any]] = [
    {
        "username": "testuser1000",
        "password1": "C0mplic@tedpwd",
        "password2": "C0mplic@tedpwd",
        "email": "test@test.com",
        "first_name": "Test First Name",
        "middle_name": "M Name",
        "last_name": "Test Last Name",
        "suffix": "Jr",
        "address1": "Add 1",
        "address2": "Add 2",
        "city": "City",
        "state_province": "ST",
        "zip": "123",
        "country": "Bermuda",
        "phone": "111",
    },
    {},
]


def test_create_user():
    # uuid = get_organization(organization)
    response = client.post(reverse("create_user"), data[0], follow=True)
    print(response)
    assert response.redirect_chain
