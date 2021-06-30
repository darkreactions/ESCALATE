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
    PropertyDef
)

property_def_data = {}

property_def_tests = [
##----TEST 0----##
    [
        {
            'name': 'property_def',
            'method': POST,
            'endpoint': 'propertydef-list',
            'body': random_model_dict(PropertyDef),
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
            'name': 'property_def_get',
            'method': GET,
            'endpoint': 'propertydef-detail',
            'body': {},
            'args': [
                'property_def__uuid'
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
            'name': 'property_def_update',
            'method': PUT,
            'endpoint': 'propertydef-detail',
            'body': random_model_dict(PropertyDef),
            'args': [
                'property_def__uuid'
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
            'name': 'property_def_update_get',
            'method': GET,
            'endpoint': 'propertydef-detail',
            'body': {},
            'args': [
                'property_def__uuid'
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
            'name': 'property_def_update_del',
            'method': DELETE,
            'endpoint': 'propertydef-detail',
            'body': {},
            'args': [
                'property_def__uuid'
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
            'endpoint': 'propertydef-detail',
            'body': {},
            'args': [
                'property_def__uuid'
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
            'name': 'propery_def',
            'method': POST,
            'endpoint': 'propertydef-list',
            'body': (request_body := random_model_dict(PropertyDef)),
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