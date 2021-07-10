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
    ParameterDef,
    TypeDef
)

parameter_def_data = {}

parameter_def_tests = [
##----TEST 0----##
# creates a parameter_def
# gets it
# puts it
# gets it
# deletes it
# gets it (should error)
    [
        {
            'name': 'parameterdef',
            'method': POST,
            'endpoint': 'parameterdef-list',
            'body': (request_body := random_model_dict(ParameterDef)),
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
            'name': 'parameterdef_get',
            'method': GET,
            'endpoint': 'parameterdef-detail',
            'body': {},
            'args': [
                'parameterdef__uuid'
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
            'name': 'parameterdef_update',
            'method': PUT,
            'endpoint': 'parameterdef-detail',
            'body': (request_body := random_model_dict(ParameterDef)),
            'args': [
                'parameterdef__uuid'
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
            'name': 'parameterdef_update_get',
            'method': GET,
            'endpoint': 'parameterdef-detail',
            'body': {},
            'args': [
                'parameterdef__uuid'
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
            'name': 'parameterdef_update_del',
            'method': DELETE,
            'endpoint': 'parameterdef-detail',
            'body': {},
            'args': [
                'parameterdef__uuid'
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
            'name': 'properydef_update_del_get',
            'method': GET,
            'endpoint': 'parameterdef-detail',
            'body': {},
            'args': [
                'parameterdef__uuid'
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