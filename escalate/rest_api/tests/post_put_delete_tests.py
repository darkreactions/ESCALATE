import pytest
from django.test import RequestFactory as rf
from django.test import Client
from django.urls import reverse
from rest_framework.test import force_authenticate
from core.models.app_tables import CustomUser
from post_data import simple_post_data, complex_post_data, complex_put_data
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient
from django.urls import reverse
import json
import copy

pytestmark = pytest.mark.django_db

def add_prev_endpoint_data(post_data, response_data):
    final_endpoint, final_data = post_data
    for key, value in final_data.items():
        if isinstance(value, str):
            x = value.split('__')
            if len(x) == 2:
                prev_endpoint, prev_key = x
                final_data[key] = response_data[prev_endpoint][prev_key]
    return final_endpoint, final_data, response_data

def add_prev_endpoint_data_2(request_data, response_data):
    final_endpoint, final_data = request_data['url'], request_data['data']
    for key, value in final_data.items():
        if isinstance(value, str):
            x = value.split('__')
            if len(x) == 2:
                prev_response_data, prev_key = x
                final_data[key] = response_data[prev_response_data][prev_key]
    return final_endpoint, final_data, response_data

@pytest.fixture
def api_client():
    client = APIClient()
    resp = client.post('/api/login', data={'username': 'vshekar', 'password':'copperhead123'}, format='json')
    client.credentials(HTTP_AUTHORIZATION=f'Token {resp.json()["token"]}')
    return client

@pytest.mark.api_post
@pytest.mark.parametrize("post_data", simple_post_data)
def test_simple_post(api_client, post_data):
    endpoint, data = post_data
    resp = api_client.post(reverse(f'{endpoint}-list'), json.dumps(data), content_type='application/json')
    assert resp.status_code == 201

@pytest.mark.api_post
@pytest.mark.parametrize("post_data", simple_post_data)
def test_simple_post_and_delete(api_client, post_data):
    endpoint, data = post_data
    resp = api_client.post(reverse(f'{endpoint}-list'), json.dumps(data), content_type='application/json')
    resp = api_client.delete(reverse(f'{endpoint}-detail', args=[resp.data["uuid"]]))
    assert resp.status_code == 204


@pytest.mark.api_post
@pytest.mark.parametrize("post_data", complex_post_data)
def test_complex_post(api_client, post_data):
    response_data = {}

    #need to deep copy b/c we change nested elements of complex_post_data
    #and those change should not persist from one test to the next
    #Ex: workflow_type : workflowtype__url is used for multiple test
    #cases, but workflowtype__url is changed to <url> and should be reverted
    #back to workflowtype_url for future test cases that use it
    post_data_deep_copy = copy.deepcopy(post_data)
    
    for data in post_data_deep_copy:
        #resp = api_client.post(reverse(f'{endpoint}-list'), json.dumps(data), content_type='application/json')
        endpoint, final_data, response_data = add_prev_endpoint_data(data, response_data)
        resp = api_client.post(reverse(f'{endpoint}-list'), json.dumps(final_data), content_type='application/json')
        response_data[endpoint] = resp.json()
    assert resp.status_code == 201

@pytest.mark.api_post
@pytest.mark.parametrize("post_data", complex_put_data)
def test_complex(api_client, post_data):
    response_data = {}

    #need to deep copy b/c we change nested elements of complex_post_data
    #and those change should not persist from one test to the next
    #Ex: workflow_type : workflowtype__url is used for multiple test
    #cases, but workflowtype__url is changed to <url> and should be reverted
    #back to workflowtype_url for future test cases that use it
    post_data_deep_copy = copy.deepcopy(post_data)
    
    for request_data in post_data_deep_copy:
        #resp = api_client.post(reverse(f'{endpoint}-list'), json.dumps(data), content_type='application/json')
        endpoint, final_data, response_data = add_prev_endpoint_data_2(request_data, response_data)
        if(request_data['method'] == 'POST'):
            resp = api_client.post(reverse(f'{endpoint}-list'), json.dumps(final_data), content_type='application/json')
        elif(request_data['method'] == 'PUT'):
            uuid_to_put = final_data['uuid']
            final_data.pop('uuid')
            resp = api_client.put(reverse(f'{endpoint}-detail', args=[uuid_to_put]), json.dumps(final_data), content_type='application/json')
        response_data[endpoint] = resp.json()
    assert resp.status_code == 200