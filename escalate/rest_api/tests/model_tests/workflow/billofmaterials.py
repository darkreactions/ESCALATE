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
    BillOfMaterials,
    Experiment
)

billofmaterials_test_data = {}

billofmaterials_tests = [

##----TEST 0----##
#creates an experiment
#creates an billofmaterials with experiment as a foreign key
#gets the billofmaterials
#puts the billofmaterials
#gets the updated billofmaterials
#deletes the updated billofmaterials
#gets the billofmaterials (should return error)
    [      
        {
            'name': 'experiment0',
            'method': POST,
            'endpoint': 'experiment-list',
            'body': random_model_dict(Experiment),
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
            'name': 'billofmaterials0',
            'method': POST,
            'endpoint': 'billofmaterials-list',
            'body': random_model_dict(BillOfMaterials, experiment='experiment0__url'),
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
            'name': 'billofmaterials0_get_0',
            'method': GET,
            'endpoint': 'billofmaterials-detail',
            'body': {},
            'args': [
                'billofmaterials0__uuid'
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
            'name': 'billofmaterials0_update_0',
            'method': PUT,
            'endpoint': 'billofmaterials-detail',
            'body': random_model_dict(BillOfMaterials),
            'args': [
                'billofmaterials0__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': PUT
                }
            }
        },
        {
            'name': 'billofmaterials0_get_1',
            'method': GET,
            'endpoint': 'billofmaterials-detail',
            'body': {},
            'args': [
                'billofmaterials0__uuid'
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
            'name': 'billofmaterials0_delete_0',
            'method': DELETE,
            'endpoint': 'billofmaterials-detail',
            'body': {},
            'args': [
                'billofmaterials0__uuid'
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
            'name': 'billofmaterials0_get_2',
            'method': GET,
            'endpoint': 'billofmaterials-detail',
            'body': {},
            'args': [
                'billofmaterials0__uuid'
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

##----TEST 1----##
#creates an billofmaterials and checks that the response data matches the 
#request data stored in the body entry
    [   
        {
            'name': 'billofmaterials0',
            'method': POST,
            'endpoint': 'billofmaterials-list',
            'body': (billofmaterials_posted := random_model_dict(BillOfMaterials)),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body': billofmaterials_posted
                }
            }
        },
    ]
]