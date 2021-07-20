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
    ConditionDef,
    Condition
)

condition_test_data = {}

condition_tests = [

##----TEST 0----##
#creates a conditiondef
#creates a condition with the previous entry as a foreign key
#gets the condition
#puts the condition
#gets the updated condition
#deletes the updated condition
#gets the condition (should return error)
    [    
        {
            'name': 'conditiondef0',
            'method': POST,
            'endpoint': 'conditiondef-list',
            'body': random_model_dict(ConditionDef),
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
            'name': 'condition0',
            'method': POST,
            'endpoint': 'condition-list',
            'body': (request_body := random_model_dict(Condition, condition_def='conditiondef0__url')),
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
            'name': 'condition0_get_0',
            'method': GET,
            'endpoint': 'condition-detail',
            'body': {},
            'args': [
                'condition0__uuid'
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
            'name': 'condition0_update_0',
            'method': PUT,
            'endpoint': 'condition-detail',
            'body': (request_body := random_model_dict(Condition)),
            'args': [
                'condition0__uuid'
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
            'name': 'condition0_get_1',
            'method': GET,
            'endpoint': 'condition-detail',
            'body': {},
            'args': [
                'condition0__uuid'
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
            'name': 'condition0_delete_0',
            'method': DELETE,
            'endpoint': 'condition-detail',
            'body': {},
            'args': [
                'condition0__uuid'
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
            'name': 'condition0_get_2',
            'method': GET,
            'endpoint': 'condition-detail',
            'body': {},
            'args': [
                'condition0__uuid'
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