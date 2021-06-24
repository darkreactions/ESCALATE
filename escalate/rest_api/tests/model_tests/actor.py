from escalate.rest_api.tests.post_put_delete_tests import add_prev_endpoint_data_2
from .model_tests_utils import (
    status_codes,
    DELETE,
    PUT,
    POST,
    GET,
    ERROR,
    random_model_dict
)
from core.models import (
    Organization,
    Systemtool,
    Person
)

def actor_check(resp, **kwargs):
    actor_field = kwargs['field']
    url = actor_field + '__url'
    previous_resp_data = kwargs['prev_response_data']
    filter_method = lambda actor: actor[actor_field]==add_prev_endpoint_data_2({'a':url}, previous_resp_data)['a']
    return len(filter(filter_method, resp.json()['results'])) == 1
    

actor_tests = [
    [       
        {
            'method': POST,
            'endpoint': 'organization-list',
            'body': random_model_dict(Organization),
            'args': [],
            'name': 'org0',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[POST]
        },
        {
            'method': GET,
            'endpoint': 'actor-list',
            'body': {},
            'args': [],
            'name': 'org0_get_0',
            'is_valid_response': actor_check

        },   
        {
            'method': POST,
            'endpoint': 'organization-list',
            'body': org_test_data['org_test_0']['org1'],
            'args': [],
            'name': 'org1',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[POST]
        },
    
    
    
    
    lambda resp, prev_resp_data : len(filter(lambda actor: actor['organization']==add_prev_endpoint({'a':organization__url}, prev_resp_data)['a'], resp.json()['results']))==1
