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
    Edocument
)

edocument_data = {}

edocument_tests = [
##----TEST 0----##
#create edocument
#get edocument
#update edocument
#get
#delete
#get (should return error)
    [
        {
            'name': 'edocument',
            'method': POST,
            'endpoint': 'edocument-list',
            'body': random_model_dict(Edocument),
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
            'name': 'edocument_get',
            'method': GET,
            'endpoint': 'edocument-detail',
            'body': {},
            'args': [
                'edocument__uuid'
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
            'name': 'edocument_update',
            'method': PUT,
            'endpoint': 'edocument-detail',
            'body': random_model_dict(Edocument),
            'args': [
                'edocument__uuid'
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
            'name': 'edocument_update_get',
            'method': GET,
            'endpoint': 'edocument-detail',
            'body': {},
            'args': [
                'edocument__uuid'
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
            'name': 'edocument_update_del',
            'method': DELETE,
            'endpoint': 'edocument-detail',
            'body': {},
            'args': [
                'edocument__uuid'
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
            'name': 'propery_def_update_del_get',
            'method': GET,
            'endpoint': 'edocument-detail',
            'body': {},
            'args': [
                'edocument__uuid'
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
# creates a property def and checks if the response data matches the
# request data
    [
        {
            'name': 'edocument',
            'method': POST,
            'endpoint': 'edocument-list',
            'body': (request_body := random_model_dict(Edocument)),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body': request_body
                }
            }
        },
    ]
]