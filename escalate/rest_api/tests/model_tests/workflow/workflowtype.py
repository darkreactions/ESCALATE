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
    WorkflowType,
)

workflowtype_test_data = {}

workflowtype_tests = [

##----TEST 0----##
#creates an workflowtype
#gets the action
#puts the workflowtype adding the other parameterdef to the manytomany field
#gets the updated workflowtype
#deletes the updated workflowtype
#gets the workflowtype (should return error)
    [      
        {
            'name': 'workflowtype0',
            'method': POST,
            'endpoint': 'workflowtype-list',
            'body': (request_body := random_model_dict(WorkflowType)), 
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
            'name': 'workflowtype0_get_0',
            'method': GET,
            'endpoint': 'workflowtype-detail',
            'body': {},
            'args': [
                'workflowtype0__uuid'
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
            'name': 'workflowtype0_update_0',
            'method': PUT,
            'endpoint': 'workflowtype-detail',
            'body': (request_body := random_model_dict(WorkflowType)),
            'args': [
                'workflowtype0__uuid'
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
            'name': 'workflowtype0_get_1',
            'method': GET,
            'endpoint': 'workflowtype-detail',
            'body': {},
            'args': [
                'workflowtype0__uuid'
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
            'name': 'workflowtype0_delete_0',
            'method': DELETE,
            'endpoint': 'workflowtype-detail',
            'body': {},
            'args': [
                'workflowtype0__uuid'
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
            'name': 'workflowtype0_get_2',
            'method': GET,
            'endpoint': 'workflowtype-detail',
            'body': {},
            'args': [
                'workflowtype0__uuid'
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