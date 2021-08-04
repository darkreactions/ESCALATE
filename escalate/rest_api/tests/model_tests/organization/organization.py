from ..model_tests_utils import (
    status_codes,
    DELETE,
    PUT,
    POST,
    GET,
    ERROR,
    random_model_dict,
    check_status_code,
    compare_data
)
from core.models import (
    Organization
)

org_test_data = {
    'org_test_0':{
        'org0': {
                    "description": "Test",
                    "full_name": "Test",
                    "short_name": "Test",
                    "address1": "Test",
                    "address2": "Test",
                    "city": "Test",
                    "state_province": "TT",
                    "zip": "21345",
                    "country": "Test",
                    "website_url": "www.test.com",
                    "phone": "1231231",
                    "parent": None
                },
        'org1': {
                    "description": "Test12",
                    "full_name": "Test12",
                    "short_name": "Test12",
                    "address1": "Test",
                    "address2": "Test",
                    "city": "Test",
                    "state_province": "TT",
                    "zip": "21345",
                    "country": "Test",
                    "website_url": "www.test.com",
                    "phone": "1231231",
                    "parent": "org0__url"
                },
        'org0_update_0': {
                    "description": "test_update",
                    "full_name": "test_update",
                    "short_name": "test_update",
                    "address1": "test_update",
                    "address2": "test_update",
                    "city": "test_update",
                    "state_province": "TF",
                    "zip": "213453",
                    "country": "test_update",
                    "website_url": "www.test_update.com",
                    "phone": "12312313",
                    "parent": "org1__url"
                },
    }
}



org_tests = [

##----TEST 0----##
#creates an organization
#creates an organization that is the child of the previous org
#updates the first organization to be a child of the second (both are parent orgs)
#gets the first org
#deletes the first org
#gets the first org (should return error)
    [       
        {
            'name': 'org0',
            'method': POST,
            'endpoint': 'organization-list',
            'body': random_model_dict(Organization),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST
                }
            }
        },
        {
            'name': 'org1',
            'method': POST,
            'endpoint': 'organization-list',
            'body': (request_body := random_model_dict(Organization, parent='org0__url')),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'status_code': POST,
                    'request_body': request_body
                }
            }
        },
        {
            'name': 'org0_update_0',
            'method': PUT,
            'endpoint': 'organization-detail',
            'body': (request_body := random_model_dict(Organization, parent='org1__url')),
            'args': [
                'org0__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'status_code': PUT,
                    'request_body': request_body
                }
            }
        },
        {
            'name': 'org0_get_0',
            'method': GET,
            'endpoint': 'organization-detail',
            'body': {},
            'args': [
                'org0__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': GET
                }
            }
        },        
        {
            'name': 'org0_delete_0',
            'method': DELETE,
            'endpoint': 'organization-detail',
            'body': {},
            'args': [
                'org0__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': DELETE
                }
            }
        },
        {
            'name': 'org0_get_1',
            'method': GET,
            'endpoint': 'organization-detail',
            'body': {},
            'args': [
                'org0__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': ERROR
                }
            }
        },
    ],
]