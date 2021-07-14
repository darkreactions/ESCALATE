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
    ExperimentWorkflow,
    Experiment,
    Workflow
)

experimentworkflow_test_data = {}

experimentworkflow_tests = [

##----TEST 0----##
#creates an experiment
#creates a workflow
#creates an experimentworkflow with the previous two entries as foreign keys
#gets the experimentworkflow
#puts the experimentworkflow adding the other parameterdef to the manytomany field
#gets the updated experimentworkflow
#deletes the updated experimentworkflow
#gets the experimentworkflow (should return error)
    [      
        *[{
            'name': name,
            'method': POST,
            'endpoint': 'experiment-list',
            'body': random_model_dict(Experiment),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST
                }
            }
        } for name in ['experiment0', 'experiment1']],
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
        {
            'name': 'experimentworkflow0',
            'method': POST,
            'endpoint': 'experimentworkflow-list',
            'body': (request_body := random_model_dict(ExperimentWorkflow, experiment='experiment0__url',
                                                workflow='workflow0__url')), 
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
            'name': 'experimentworkflow0_get_0',
            'method': GET,
            'endpoint': 'experimentworkflow-detail',
            'body': {},
            'args': [
                'experimentworkflow0__uuid'
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
            'name': 'experimentworkflow0_update_0',
            'method': PUT,
            'endpoint': 'experimentworkflow-detail',
            'body': (request_body := random_model_dict(ExperimentWorkflow, experiment='experiment1__url',
                                                workflow='workflow1__url')),
            'args': [
                'experimentworkflow0__uuid'
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
            'name': 'experimentworkflow0_get_1',
            'method': GET,
            'endpoint': 'experimentworkflow-detail',
            'body': {},
            'args': [
                'experimentworkflow0__uuid'
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
            'name': 'experimentworkflow0_delete_0',
            'method': DELETE,
            'endpoint': 'experimentworkflow-detail',
            'body': {},
            'args': [
                'experimentworkflow0__uuid'
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
            'name': 'experimentworkflow0_get_2',
            'method': GET,
            'endpoint': 'experimentworkflow-detail',
            'body': {},
            'args': [
                'experimentworkflow0__uuid'
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