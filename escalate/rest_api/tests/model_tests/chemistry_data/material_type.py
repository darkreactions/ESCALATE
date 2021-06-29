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
    MaterialType,
)

material_type_data = {}

material_type_tests = [
##----TEST 0----##
# creates a material type
# gets it
# puts it
# gets it
# deletes it
# gets it (should error)
    [
        {
            'name': 'mat_type',
            'method': POST,
            'endpoint': 'materialtype-list',
            'body': random_model_dict(MaterialType),
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
            'name': 'mat_type_get',
            'method': GET,
            'endpoint': 'materialtype-detail',
            'body': {},
            'args': [
                'mat_type__uuid'
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
            'name': 'mat_type_update',
            'method': PUT,
            'endpoint': 'materialtype-detail',
            'body': random_model_dict(MaterialType),
            'args': [
                'mat_type__uuid'
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
            'name': 'mat_type_update_get',
            'method': GET,
            'endpoint': 'materialtype-detail',
            'body': {},
            'args': [
                'mat_type__uuid'
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
            'name': 'mat_type_update_del',
            'method': DELETE,
            'endpoint': 'materialtype-detail',
            'body': {},
            'args': [
                'mat_type__uuid'
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
            'name': 'mat_type_del_get',
            'method': GET,
            'endpoint': 'materialtype-detail',
            'body': {},
            'args': [
                'mat_type__uuid'
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
# creates a material type and compares request body with response body
    [
        {
            'name': 'mat_iden_def',
            'method': POST,
            'endpoint': 'materialidentifierdef-list',
            'body': (request_body := random_model_dict(MaterialType)),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body': request_body
                }
            }
        } 
    ]
]