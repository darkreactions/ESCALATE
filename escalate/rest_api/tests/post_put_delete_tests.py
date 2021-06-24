import pytest
from django.test import RequestFactory as rf
from django.test import Client
from django.urls import reverse
from rest_framework.test import force_authenticate
from core.models.app_tables import CustomUser
from rest_framework.authtoken.models import Token
from rest_framework.test import APIClient
from django.urls import reverse
import json
import copy
#from model_tests.person import person_tests as model_tests
import model_tests

pytestmark = pytest.mark.django_db

# def add_prev_endpoint_data(post_data, response_data):
#     final_endpoint, final_data = post_data
#     for key, value in final_data.items():
#         if isinstance(value, str):
#             x = value.split('__')
#             if len(x) == 2:
#                 prev_endpoint, prev_key = x
#                 final_data[key] = response_data[prev_endpoint][prev_key]
#     return final_endpoint, final_data, response_data

# def add_prev_endpoint_data_2(request_data, response_data):
#     final_endpoint, final_data = request_data['url'], request_data['data']
#     for key, value in final_data.items():
#         if isinstance(value, str):
#             x = value.split('__')
#             if len(x) == 2:
#                 prev_response_data, prev_key = x
#                 final_data[key] = response_data[prev_response_data][prev_key]
#     return final_endpoint, final_data, response_data

def add_prev_endpoint_data_2(dictionary, response_data):
    for key, value in dictionary.items():
        if isinstance(value, str):
            x = value.split('__')
            if len(x) == 2:
                prev_response_data_name, prev_key = x
                dictionary[key] = response_data[prev_response_data_name][prev_key]
        elif isinstance(value, list):
            for i in range(len(value)):
                assert(isinstance(value[i], str))
                x = value[i].split('__')
                if len(x) == 2:
                    prev_response_name, prev_key = x
                    dictionary[key][i] = response_data[prev_response_name][prev_key]
    return dictionary

def add_prev_endpoint_data_to_args(args_list, response_data):
    # turn args list to dict with key as index as string and value as list element
    args_list_dict = {str(index): val for index, val in enumerate(args_list)}

    # add prev endpoint data to args_list_dict
    add_prev_endpoint_data_2(args_list_dict, response_data)

    # take key value pairs and put it in list
    args_list_dict_items_as_list = [x for x in args_list_dict.items()]

    # sort key value pairs by index
    args_list_dict_items_as_list.sort(key= lambda key_val: int(key_val[0]))

    # replace elements in original args list with values from prev endpoints
    for i in range(len(args_list_dict_items_as_list)):
        args_list[i] = args_list_dict_items_as_list[i][1]
        
    return args_list

def run_test(api_client, tests):
    response_data = {}
    #need to deep copy b/c we change nested elements of complex_post_data
    #and those change should not persist from one test to the next
    #Ex: workflow_type : workflowtype__url is used for multiple test
    #cases, but workflowtype__url is changed to <url> and should be reverted
    #back to workflowtype_url for future test cases that use it
    request_data_deep_copy = copy.deepcopy(tests)
    
    for request_data in request_data_deep_copy:
        endpoint, method, body, args, name, is_valid_response = [request_data[key] for key \
            in ['endpoint', 'method', 'body', 'args', 'name', 'is_valid_response']]
        
        add_prev_endpoint_data_2(body, response_data)
        
        add_prev_endpoint_data_to_args(args, response_data)
        
        if(method == 'POST'):
            resp = api_client.post(reverse(endpoint, args=args), json.dumps(body), content_type='application/json')
            response_data[name] = resp.json()
        elif(method == 'PUT'):
            resp = api_client.put(reverse(endpoint, args=args), json.dumps(body), content_type='application/json')
            response_data[name] = resp.json()
        elif(method == 'GET'):
            resp = api_client.get(reverse(endpoint, args=args))
            response_data[name] = resp.json()
        elif(method == 'DELETE'):
            resp = api_client.delete(reverse(endpoint, args=args))
        else:
            assert False, 'Invalid Http method'
        assert is_valid_response(resp, response_data), method + ' ' + name

@pytest.fixture
def api_client():
    client = APIClient()
    resp = client.post('/api/login', data={'username': 'vshekar', 'password':'copperhead123'}, format='json')
    client.credentials(HTTP_AUTHORIZATION=f'Token {resp.json()["token"]}')
    return client

# @pytest.mark.api_post
# @pytest.mark.parametrize("post_data", simple_post_data)
# def test_simple_post(api_client, post_data):
#     endpoint, data = post_data
#     resp = api_client.post(reverse(f'{endpoint}-list'), json.dumps(data), content_type='application/json')
#     assert resp.status_code == 201

# @pytest.mark.api_post
# @pytest.mark.parametrize("post_data", simple_post_data)
# def test_simple_post_and_delete(api_client, post_data):
#     endpoint, data = post_data
#     resp = api_client.post(reverse(f'{endpoint}-list'), json.dumps(data), content_type='application/json')
#     resp = api_client.delete(reverse(f'{endpoint}-detail', args=[resp.data["uuid"]]))
#     assert resp.status_code == 204


def add_pytest_test(value):
    @pytest.mark.api_delete
    @pytest.mark.parametrize("model_test", value)
    def f23123(api_client, model_test):
        run_test(api_client, model_test)
    return f23123

for key, value in vars(model_tests).items():
    if str(key).endswith('_tests'):
        model_name = key.split('_')[0]
        globals()[f'test_{model_name}'] = add_pytest_test(value)


