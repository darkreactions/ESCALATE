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
    Workflow,
    Action,
    Condition,
    ConditionDef,
    WorkflowObject,
)

workflowobject_test_data = {}

workflowobject_tests = [

##----TEST 0----##
#creates an experiment
#creates a workflowobjecttype
#creates a workflowobject
#creates an workflowobject with the previous three entries as foreign keys/manytomanyfields
#gets the workflowobject
#puts the workflowobject adding the other parameterdef to the manytomany field
#gets the updated workflowobject
#deletes the updated workflowobject
#gets the workflowobject (should return error)
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
            'endpoint': 'conditiondef-list',
            'body': random_model_dict(ConditionDef),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST
                }
            }
        } for name in ['conditiondef0', 'conditiondef1']], 
        *[{
            'name': 'condition' + str(i),
            'method': POST,
            'endpoint': 'condition-list',
            'body': random_model_dict(Condition, condition_def='conditiondef'+str(i)+'__url'),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST
                }
            }
        } for i in range(2)],
        {
            'name': 'workflowobject0',
            'method': POST,
            'endpoint': 'workflowobject-list',
            'body': (request_body := random_model_dict(WorkflowObject, workflow='workflow0__url',
                                                        condition='condition0__url')), 
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
            'name': 'workflowobject0_get_0',
            'method': GET,
            'endpoint': 'workflowobject-detail',
            'body': {},
            'args': [
                'workflowobject0__uuid'
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
            'name': 'workflowobject0_update_0',
            'method': PUT,
            'endpoint': 'workflowobject-detail',
           'body': (request_body := random_model_dict(WorkflowObject, workflow='workflow1__url',
                                                        condition='condition1__url')), 
            'args': [
                'workflowobject0__uuid'
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
            'name': 'workflowobject0_get_1',
            'method': GET,
            'endpoint': 'workflowobject-detail',
            'body': {},
            'args': [
                'workflowobject0__uuid'
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
            'name': 'workflowobject0_delete_0',
            'method': DELETE,
            'endpoint': 'workflowobject-detail',
            'body': {},
            'args': [
                'workflowobject0__uuid'
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
            'name': 'workflowobject0_get_2',
            'method': GET,
            'endpoint': 'workflowobject-detail',
            'body': {},
            'args': [
                'workflowobject0__uuid'
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