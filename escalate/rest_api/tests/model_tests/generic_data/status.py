from ..model_tests_utils import (
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
    Status
)

status_data = {}

status_tests = [
##----TEST 0----##
# creates a status
# gets it
# puts it
# gets it
# deletes it 
# gets it (should error)
    [
        {
            'name': 'status',
            'method': POST,
            'endpoint': 'status-list',
            'body': (request_body := random_model_dict(Status)),
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
            'name': 'status_get',
            'method': GET,
            'endpoint': 'status-detail',
            'body': {},
            'args': [
                'status__uuid'
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
            'name': 'status_update',
            'method': PUT,
            'endpoint': 'status-detail',
            'body': (request_body := random_model_dict(Status)),
            'args': [
                'status__uuid'
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
            'name': 'status_update_get',
            'method': GET,
            'endpoint': 'status-detail',
            'body': {},
            'args': [
                'status__uuid'
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
            'name': 'status_update_del',
            'method': DELETE,
            'endpoint': 'status-detail',
            'body': {},
            'args': [
                'status__uuid'
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
            'name': 'status_update_del_get',
            'method': GET,
            'endpoint': 'status-detail',
            'body': {},
            'args': [
                'status__uuid'
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