from ..model_tests_utils import (
    status_codes,
    DELETE,
    PUT,
    POST,
    GET,
    ERROR,
    random_model_dict,
    check_status_code,
    compare_data,
    createSystemtool
)
from core.models import (
    WorkflowActionSet,
    Workflow,
    ActionDef,
    ParameterDef,
    Calculation
)

workflowactionset_test_data = {}

workflowactionset_tests = [

##----TEST 0----##
#creates an experiment
#creates a workflowactionsettype
#creates a workflowactionset
#creates an workflowactionset with the previous three entries as foreign keys/manytomanyfields
#gets the workflowactionset
#puts the workflowactionset adding the other parameterdef to the manytomany field
#gets the updated workflowactionset
#deletes the updated workflowactionset
#gets the workflowactionset (should return error)
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
            'endpoint': 'actiondef-list',
            'body': random_model_dict(ActionDef),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST
                }
            }
        } for name in ['actiondef0', 'actiondef1']],
        *[{
            'name': name,
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
        } for name in ['parameterdef0', 'parameterdef1']],
        *createSystemtool(1),
        *[{
            'name': f'calculation{number}',
            'method': POST,
            'endpoint': 'calculation-list',
            'body': random_model_dict(Calculation, systemtool=f'systemtool{number}__url'),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST
                }
            }
        } for number in range(2)],

        {
            'name': 'workflowactionset0',
            'method': POST,
            'endpoint': 'workflowactionset-list',
            'body': (request_body := random_model_dict(WorkflowActionSet, workflow='workflow0__url', action_def='actiondef0__url',
                                                        parameter_def='parameterdef0__url', calculation='calculation0__url')), 
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
            'name': 'workflowactionset0_get_0',
            'method': GET,
            'endpoint': 'workflowactionset-detail',
            'body': {},
            'args': [
                'workflowactionset0__uuid'
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
            'name': 'workflowactionset0_update_0',
            'method': PUT,
            'endpoint': 'workflowactionset-detail',
           'body': (request_body := random_model_dict(WorkflowActionSet, workflow='workflow1__url', action_def='actiondef1__url',
                                                        parameter_def='parameterdef1__url', calculation='calculation1__url')), 
            'args': [
                'workflowactionset0__uuid'
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
            'name': 'workflowactionset0_get_1',
            'method': GET,
            'endpoint': 'workflowactionset-detail',
            'body': {},
            'args': [
                'workflowactionset0__uuid'
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
            'name': 'workflowactionset0_delete_0',
            'method': DELETE,
            'endpoint': 'workflowactionset-detail',
            'body': {},
            'args': [
                'workflowactionset0__uuid'
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
            'name': 'workflowactionset0_get_2',
            'method': GET,
            'endpoint': 'workflowactionset-detail',
            'body': {},
            'args': [
                'workflowactionset0__uuid'
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