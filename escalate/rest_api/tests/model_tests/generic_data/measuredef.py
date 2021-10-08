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
    MeasureDef,
    MeasureType,
    PropertyTemplate
)

measuredef_test_data = {}

measuredef_tests = [

##----TEST 0----##
#creates an measuretype
#creats a proportydef
#creates a measuredef with the previous two entries as foreign keys
#gets the measuredef
#puts the measuredef
#gets the updated measuredef
#deletes the updated measuredef
#gets the measuredef (should return error)
    [   
        *[{
            'name': name,
            'method': POST,
            'endpoint': 'measuretype-list',
            'body': (request_body := random_model_dict(MeasureType)), 
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
        } for name in ['measuretype0', 'measuretype1']],
        *[{
            'name': name,
            'method': POST,
            'endpoint': 'propertytemplate-list',
            'body': (request_body := random_model_dict(PropertyTemplate)), 
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
        } for name in ['propertydef0', 'propertydef1']],
        {
            'name': 'measuredef0',
            'method': POST,
            'endpoint': 'measuredef-list',
            'body': (request_body := random_model_dict(MeasureDef, default_measure_type='measuretype0__url',
                                                        property_def='propertydef0__url')), 
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
            'name': 'measuredef0_get_0',
            'method': GET,
            'endpoint': 'measuredef-detail',
            'body': {},
            'args': [
                'measuredef0__uuid'
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
            'name': 'measuredef0_update_0',
            'method': PUT,
            'endpoint': 'measuredef-detail',
            'body': (request_body := random_model_dict(MeasureDef, default_measure_type='measuretype1__url',
                                                        property_def='propertydef1__url')), 
            'args': [
                'measuredef0__uuid'
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
            'name': 'measuredef0_get_1',
            'method': GET,
            'endpoint': 'measuredef-detail',
            'body': {},
            'args': [
                'measuredef0__uuid'
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
            'name': 'measuredef0_delete_0',
            'method': DELETE,
            'endpoint': 'measuredef-detail',
            'body': {},
            'args': [
                'measuredef0__uuid'
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
            'name': 'measuredef0_get_2',
            'method': GET,
            'endpoint': 'measuredef-detail',
            'body': {},
            'args': [
                'measuredef0__uuid'
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