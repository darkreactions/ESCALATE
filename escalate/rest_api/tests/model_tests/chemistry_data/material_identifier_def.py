from rest_api.tests.post_put_delete_tests import add_prev_endpoint_data_2
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
    MaterialIdentifierDef,
)

material_identifier_def_data = {}

material_identifier_def_tests = [
##----TEST 0----##
# creates a material identifier def
# gets it
# puts it
# gets it
# deletes it
# gets it (should error)
    [
        {
            'name': 'mat_iden_def',
            'method': POST,
            'endpoint': 'materialidentifierdef-list',
            'body': random_model_dict(MaterialIdentifierDef),
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
            'name': 'mat_iden_def_get',
            'method': GET,
            'endpoint': 'materialidentifierdef-detail',
            'body': {},
            'args': [
                'mat_iden_def__uuid'
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
            'name': 'mat_iden_def_update',
            'method': PUT,
            'endpoint': 'materialidentifierdef-detail',
            'body': random_model_dict(MaterialIdentifierDef),
            'args': [
                'mat_iden_def__uuid'
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
            'name': 'mat_iden_def_update_get',
            'method': GET,
            'endpoint': 'materialidentifierdef-detail',
            'body': {},
            'args': [
                'mat_iden_def__uuid'
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
            'name': 'mat_iden_def_update_del',
            'method': DELETE,
            'endpoint': 'materialidentifierdef-detail',
            'body': {},
            'args': [
                'mat_iden_def__uuid'
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
            'name': 'mat_iden_def_del_get',
            'method': GET,
            'endpoint': 'materialidentifierdef-detail',
            'body': {},
            'args': [
                'mat_iden_def__uuid'
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
# creates a material identifier def and compares request body with response body
    [
        {
            'name': 'mat_iden_def',
            'method': POST,
            'endpoint': 'materialidentifierdef-list',
            'body': (request_body := random_model_dict(MaterialIdentifierDef)),
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