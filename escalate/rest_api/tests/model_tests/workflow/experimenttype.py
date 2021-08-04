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
    ExperimentType,
)

experimenttype_test_data = {}

experimenttype_tests = [

##----TEST 0----##
#creates an experimenttype
#gets the action
#puts the experimenttype adding the other parameterdef to the manytomany field
#gets the updated experimenttype
#deletes the updated experimenttype
#gets the experimenttype (should return error)
    [      
        {
            'name': 'experimenttype0',
            'method': POST,
            'endpoint': 'experimenttype-list',
            'body': (request_body := random_model_dict(ExperimentType)), 
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
            'name': 'experimenttype0_get_0',
            'method': GET,
            'endpoint': 'experimenttype-detail',
            'body': {},
            'args': [
                'experimenttype0__uuid'
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
            'name': 'experimenttype0_update_0',
            'method': PUT,
            'endpoint': 'experimenttype-detail',
            'body': (request_body := random_model_dict(ExperimentType)),
            'args': [
                'experimenttype0__uuid'
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
            'name': 'experimenttype0_get_1',
            'method': GET,
            'endpoint': 'experimenttype-detail',
            'body': {},
            'args': [
                'experimenttype0__uuid'
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
            'name': 'experimenttype0_delete_0',
            'method': DELETE,
            'endpoint': 'experimenttype-detail',
            'body': {},
            'args': [
                'experimenttype0__uuid'
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
            'name': 'experimenttype0_get_2',
            'method': GET,
            'endpoint': 'experimenttype-detail',
            'body': {},
            'args': [
                'experimenttype0__uuid'
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