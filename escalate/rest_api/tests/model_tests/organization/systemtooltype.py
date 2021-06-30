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
    SystemtoolType
)

systemtooltype_test_data = {}

systemtooltype_tests = [

##----TEST 0----##
#creates a systemtooltype
#gets the systemtooltype
#puts the systemtooltype with vendor_organization as the 2nd organization and systemtooltype_type as the 2nd systemtooltype_type
#gets the updated systemtooltype
#deletes the updated systemtooltype
#gets the systemtooltype (should return error)
    [      
        {
            'name': 'systemtooltype0',
            'method': POST,
            'endpoint': 'systemtooltype-list',
            'body': random_model_dict(SystemtoolType),
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
            'name': 'systemtooltype0_get_0',
            'method': GET,
            'endpoint': 'systemtooltype-detail',
            'body': {},
            'args': [
                'systemtooltype0__uuid'
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
            'name': 'systemtooltype0_update_0',
            'method': PUT,
            'endpoint': 'systemtooltype-detail',
            'body': random_model_dict(SystemtoolType),
            'args': [
                'systemtooltype0__uuid'
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
            'name': 'systemtooltype0_get_1',
            'method': GET,
            'endpoint': 'systemtooltype-detail',
            'body': {},
            'args': [
                'systemtooltype0__uuid'
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
            'name': 'systemtooltype0_delete_0',
            'method': DELETE,
            'endpoint': 'systemtooltype-detail',
            'body': {},
            'args': [
                'systemtooltype0__uuid'
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
            'name': 'systemtooltype0_get_2',
            'method': GET,
            'endpoint': 'systemtooltype-detail',
            'body': {},
            'args': [
                'systemtooltype0__uuid'
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
#creates a systemtooltype and checks that the response data matches the 
#request data stored in the body entry
    [   
        {
            'name': 'systemtooltype0',
            'method': POST,
            'endpoint': 'systemtooltype-list',
            'body': (systemtooltype_posted := random_model_dict(SystemtoolType)),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body': systemtooltype_posted
                }
            }
        },
    ]
]