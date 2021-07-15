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
    Measure
)

measure_test_data = {}

measure_tests = [

##----TEST 0----##
#creates an measuretype
#creates a measure
#creates a measuredef
#creates a measure
#gets the measure
#puts the measure
#gets the updated measure
#deletes the updated measure
#gets the measure (should return error)
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
            'endpoint': 'measuredef-list',
            'body': (request_body := random_model_dict(MeasureDef)), 
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
        } for name in ['measuredef0', 'measuredef1']],
        *[{
            'name': name,
            'method': POST,
            'endpoint': 'measure-list',
            'body': (request_body := random_model_dict(Measure,  measure_def='measuredef0__url')), 
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
        } for name in ['measure0', 'measure1']],
        {
            'name': 'measure0',
            'method': POST,
            'endpoint': 'measure-list',
            'body': (request_body := random_model_dict(Measure, measure_type='measuretype0__url',
                                                    ref_measure='measure0__url', measure_def='measuredef0__url')), 
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
            'name': 'measure0_get_0',
            'method': GET,
            'endpoint': 'measure-detail',
            'body': {},
            'args': [
                'measure0__uuid'
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
            'name': 'measure0_update_0',
            'method': PUT,
            'endpoint': 'measure-detail',
            'body': (request_body := random_model_dict(Measure, measure_type='measuretype1__url',
                                                    ref_measure='measure1__url', measure_def='measuredef1__url')),
            'args': [
                'measure0__uuid'
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
            'name': 'measure0_get_1',
            'method': GET,
            'endpoint': 'measure-detail',
            'body': {},
            'args': [
                'measure0__uuid'
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
            'name': 'measure0_delete_0',
            'method': DELETE,
            'endpoint': 'measure-detail',
            'body': {},
            'args': [
                'measure0__uuid'
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
            'name': 'measure0_get_2',
            'method': GET,
            'endpoint': 'measure-detail',
            'body': {},
            'args': [
                'measure0__uuid'
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