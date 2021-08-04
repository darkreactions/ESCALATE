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
    Vessel,
    Actor,
    Status
)

vessel_test_data = {}

vessel_tests = [

##----TEST 0----##
#creates new actor
#creates a new status
#creates a vessel with the status as a foreign key
#gets the vessel
#updates the vessel to have the previously defined actor as a foreign key
#gets the vessel
#deletes the vessel
#gets the vessel (should return error)
    [       
        {
            'name': 'actor0',
            'method': POST,
            'endpoint': 'actor-list',
            'body': random_model_dict(Actor),
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
            'name': 'status0',
            'method': POST,
            'endpoint': 'status-list',
            'body': random_model_dict(Status),
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
            'name': 'vessel0',
            'method': POST,
            'endpoint': 'vessel-list',
            'body': (request_body := random_model_dict(Vessel, status='status0__url')),
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
            'name': 'vessel0_get_0',
            'method': GET,
            'endpoint': 'vessel-detail',
            'body': {},
            'args': [
                'vessel0__uuid'
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
            'name': 'vessel0_update_0',
            'method': PUT,
            'endpoint': 'vessel-detail',
            'body': (request_body := random_model_dict(Vessel, actor='actor0__url')),
            'args': [
                'vessel0__uuid'
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
            'name': 'vessel0_get_1',
            'method': GET,
            'endpoint': 'vessel-detail',
            'body': {},
            'args': [
                'vessel0__uuid'
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
            'name': 'vessel0_delete_0',
            'method': DELETE,
            'endpoint': 'vessel-detail',
            'body': {},
            'args': [
                'vessel0__uuid'
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
            'name': 'vessel0_get_2',
            'method': GET,
            'endpoint': 'vessel-detail',
            'body': {},
            'args': [
                'vessel0__uuid'
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