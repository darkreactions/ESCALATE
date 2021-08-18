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
    Experiment,
    Workflow
)

workflow_test_data = {}

workflow_tests = [

##----TEST 0----##
#creates an experiment
#creates a workflowtype
#creates a workflow
#creates an workflow with the previous three entries as foreign keys/manytomanyfields
#gets the workflow
#puts the workflow adding the other parameterdef to the manytomany field
#gets the updated workflow
#deletes the updated workflow
#gets the workflow (should return error)
    [      
        *[{
            'name': name,
            'method': POST,
            'endpoint': 'workflow-list',
            'body': random_model_dict(Workflow),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST
                }
            }
        } for name in ['workflow0', 'workflow1']],
        *[{
            'name': name,
            'method': POST,
            'endpoint': 'workflowtype-list',
            'body': random_model_dict(WorkflowType),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST
                }
            }
        } for name in ['workflowtype0', 'workflowtype1']],
        {
            'name': 'workflow0',
            'method': POST,
            'endpoint': 'workflow-list',
            'body': (request_body := random_model_dict(Workflow, parent='workflow0__url', workflow_type='workflowtype0__url')), 
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
            'name': 'workflow0_get_0',
            'method': GET,
            'endpoint': 'workflow-detail',
            'body': {},
            'args': [
                'workflow0__uuid'
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
            'name': 'workflow0_update_0',
            'method': PUT,
            'endpoint': 'workflow-detail',
            'body': (request_body := random_model_dict(Workflow, parent='workflow1__url', workflow_type='workflowtype1__url')),
            'args': [
                'workflow0__uuid'
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
            'name': 'workflow0_get_1',
            'method': GET,
            'endpoint': 'workflow-detail',
            'body': {},
            'args': [
                'workflow0__uuid'
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
            'name': 'workflow0_delete_0',
            'method': DELETE,
            'endpoint': 'workflow-detail',
            'body': {},
            'args': [
                'workflow0__uuid'
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
            'name': 'workflow0_get_2',
            'method': GET,
            'endpoint': 'workflow-detail',
            'body': {},
            'args': [
                'workflow0__uuid'
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
