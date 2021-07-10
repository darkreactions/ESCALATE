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
    Condition,
    WorkflowStep,
    ConditionPath
)

conditionpath_test_data = {}

conditionpath_tests = [

##----TEST 0----##
#cretaes a condition
#creates a workflowstep
#creates a conditionpath with the previous two entries as foreign keys
#gets the conditionpath
#updates the conditionpath with the other calculationdef
#gets the conditionpath
#deletes the conditionpath
#gets the conditionpath (should return error)
    [      
        
        {
            'name': 'condition0',
            'method': POST,
            'endpoint': 'condition-list',
            'body': random_model_dict(Condition),
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
            'name': 'workflowstep0',
            'method': POST,
            'endpoint': 'workflowstep-list',
            'body': random_model_dict(WorkflowStep),
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
            'name': 'conditionpath0',
            'method': POST,
            'endpoint': 'conditionpath-list',
            'body': random_model_dict(ConditionPath, #calculation_def=['calculationdef0__url']
            ),
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
            'name': 'conditionpath0_get_0',
            'method': GET,
            'endpoint': 'conditionpath-detail',
            'body': {},
            'args': [
                'conditionpath0__uuid'
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
            'name': 'conditionpath0_update_0',
            'method': PUT,
            'endpoint': 'conditionpath-detail',
            'body': random_model_dict(ConditionPath, #calculation_def=['calculationdef1__url']
            ),
            'args': [
                'conditionpath0__uuid'
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
            'name': 'conditionpath0_get_1',
            'method': GET,
            'endpoint': 'conditionpath-detail',
            'body': {},
            'args': [
                'conditionpath0__uuid'
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
            'name': 'conditionpath0_delete_0',
            'method': DELETE,
            'endpoint': 'conditionpath-detail',
            'body': {},
            'args': [
                'conditionpath0__uuid'
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
            'name': 'conditionpath0_get_2',
            'method': GET,
            'endpoint': 'conditionpath-detail',
            'body': {},
            'args': [
                'conditionpath0__uuid'
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
#creates a calculationdef
#creates an conditionpath with the calculation def in the manytomany field
#and checks that the response data matches the request data stored in the body entry
    [   
        {
            'name': 'conditionpath0',
            'method': POST,
            'endpoint': 'conditionpath-list',
            'body': (conditionpath_posted := random_model_dict(ConditionPath, #calculation_def=['calculationdef0__url']
            )),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body': conditionpath_posted
                }
            }
        },
    ]
]