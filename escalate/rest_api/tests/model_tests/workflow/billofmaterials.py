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
    BillOfMaterials,
    ExperimentTemplate
)

billofmaterials_test_data = {}

billofmaterials_tests = [

##----TEST 0----##
#creates an experiment
#creates an billofmaterials with experiment as a foreign key
#gets the billofmaterials
#puts the billofmaterials
#gets the updated billofmaterials
#deletes the updated billofmaterials
#gets the billofmaterials (should return error)
    [      
        {
            'name': 'experiment0',
            'method': POST,
            'endpoint': 'experimenttemplate-list',
            'body': random_model_dict(ExperimentTemplate),
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
            'name': 'billofmaterials0',
            'method': POST,
            'endpoint': 'billofmaterials-list',
            'body': (request_body := random_model_dict(BillOfMaterials, experiment='experiment0__url')),
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
            'name': 'billofmaterials0_get_0',
            'method': GET,
            'endpoint': 'billofmaterials-detail',
            'body': {},
            'args': [
                'billofmaterials0__uuid'
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
            'name': 'billofmaterials0_update_0',
            'method': PUT,
            'endpoint': 'billofmaterials-detail',
            'body': (request_body := random_model_dict(BillOfMaterials)),
            'args': [
                'billofmaterials0__uuid'
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
            'name': 'billofmaterials0_get_1',
            'method': GET,
            'endpoint': 'billofmaterials-detail',
            'body': {},
            'args': [
                'billofmaterials0__uuid'
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
            'name': 'billofmaterials0_delete_0',
            'method': DELETE,
            'endpoint': 'billofmaterials-detail',
            'body': {},
            'args': [
                'billofmaterials0__uuid'
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
            'name': 'billofmaterials0_get_2',
            'method': GET,
            'endpoint': 'billofmaterials-detail',
            'body': {},
            'args': [
                'billofmaterials0__uuid'
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