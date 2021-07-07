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
            'name': 'parameter_def',
            'method': POST,
            'endpoint': 'parameterdef-list',
            'body': random_model_dict(ParameterDef),
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
        # {
        #     'name': 'parameter_def_get',
        #     'method': GET,
        #     'endpoint': 'parameterdef-detail',
        #     'body': {},
        #     'args': [
        #         'parameter_def__uuid'
        #     ],
        #     'query_params': [],
        #     'is_valid_response': {
        #         'function': check_status_code,
        #         'args': [],
        #         'kwargs': {
        #             'status_code': GET
        #         }
        #     }
        # },
        # {
        #     'name': 'parameter_def_update',
        #     'method': PUT,
        #     'endpoint': 'parameterdef-detail',
        #     'body': random_model_dict(ParameterDef),
        #     'args': [
        #         'parameter_def__uuid'
        #     ],
        #     'query_params': [],
        #     'is_valid_response': {
        #         'function': check_status_code,
        #         'args': [],
        #         'kwargs': {
        #             'status_code': PUT
        #         }
        #     }
        # },
        # {
        #     'name': 'parameter_def_update_get',
        #     'method': GET,
        #     'endpoint': 'parameterdef-detail',
        #     'body': {},
        #     'args': [
        #         'parameter_def__uuid'
        #     ],
        #     'query_params': [],
        #     'is_valid_response': {
        #         'function': check_status_code,
        #         'args': [],
        #         'kwargs': {
        #             'status_code': GET
        #         }
        #     }
        # },
        # {
        #     'name': 'parameter_def_update_del',
        #     'method': DELETE,
        #     'endpoint': 'parameterdef-detail',
        #     'body': {},
        #     'args': [
        #         'parameter_def__uuid'
        #     ],
        #     'query_params': [],
        #     'is_valid_response': {
        #         'function': check_status_code,
        #         'args': [],
        #         'kwargs': {
        #             'status_code': DELETE
        #         }
        #     }
        # },
        # {
        #     'name': 'propery_def_update_del_get',
        #     'method': GET,
        #     'endpoint': 'parameterdef-detail',
        #     'body': {},
        #     'args': [
        #         'parameter_def__uuid'
        #     ],
        #     'query_params': [],
        #     'is_valid_response': {
        #         'function': check_status_code,
        #         'args': [],
        #         'kwargs': {
        #             'status_code': ERROR
        #         }
        #     }
        # },
    ],
##----TEST 1----##
# creates a property def and checks if the response data matches the
# request data
    # [
    #     {
    #         'name': 'parameter_def',
    #         'method': POST,
    #         'endpoint': 'parameterdef-list',
    #         'body': (request_body := random_model_dict(ParameterDef)),
    #         'args': [],
    #         'query_params': [],
    #         'is_valid_response': {
    #             'function': compare_data,
    #             'args': [],
    #             'kwargs': {
    #                 'request_body': request_body
    #             }
    #         }
    #     },
    # ]
]