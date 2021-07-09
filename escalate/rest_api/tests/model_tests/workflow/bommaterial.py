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
    BomMaterial,
)

bommaterial_test_data = {}

bommaterial_tests = [

##----TEST 0----##
#creates a bommaterial
#gets the bommaterial
#puts the bommaterial adding the other parameterdef to the manytomany field
#gets the updated bommaterial
#deletes the updated bommaterial
#gets the bommaterial (should return error)
    [      
        {
            'name': 'bommaterial0',
            'method': POST,
            'endpoint': 'bommaterial-list',
            'body': random_model_dict(BomMaterial), 
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
            'name': 'bommaterial0_get_0',
            'method': GET,
            'endpoint': 'bommaterial-detail',
            'body': {},
            'args': [
                'bommaterial0__uuid'
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
            'name': 'bommaterial0_update_0',
            'method': PUT,
            'endpoint': 'bommaterial-detail',
            'body': random_model_dict(BomMaterial),
            'args': [
                'bommaterial0__uuid'
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
            'name': 'bommaterial0_get_1',
            'method': GET,
            'endpoint': 'bommaterial-detail',
            'body': {},
            'args': [
                'bommaterial0__uuid'
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
            'name': 'bommaterial0_delete_0',
            'method': DELETE,
            'endpoint': 'bommaterial-detail',
            'body': {},
            'args': [
                'bommaterial0__uuid'
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
            'name': 'bommaterial0_get_2',
            'method': GET,
            'endpoint': 'bommaterial-detail',
            'body': {},
            'args': [
                'bommaterial0__uuid'
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
#creates an bommaterial and checks that the response data matches the 
#request data stored in the body entry
    [   
        {
            'name': 'bommaterial0',
            'method': POST,
            'endpoint': 'bommaterial-list',
            'body': (bommaterial_posted := random_model_dict(BomMaterial)),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body': bommaterial_posted
                }
            }
        },
    ]
]