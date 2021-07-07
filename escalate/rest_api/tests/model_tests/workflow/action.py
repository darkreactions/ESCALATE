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
    ActionDef,
    Workflow,
    ParameterDef,
    Action
)

action_test_data = {}

action_tests = [

##----TEST 0----##
#creates an actiondef
#creates a parameterdef
#creates a second parameterdef
#creates a workflow
#creates a calculationdef
#creates an action with all of the previous entries as foreign keys (one of the two parameterdefs is put in the manytomanyfield)
#gets the action
#puts the action adding the other parameterdef to the manytomany field
#gets the updated systemtooltype
#deletes the updated systemtooltype
#gets the systemtooltype (should return error)
    [      
        {
            'name': 'actiondef0',
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
        },
        {
            'name': 'parameterdef0',
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
        {
            'name': 'parameterdef1',
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
        {
            'name': 'workflow0',
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
        },
        {
            'name': 'parameterdef0',
            'method': POST,
            'endpoint': 'parameterdef-list',
            'body': {},
            'args': [
                'systemtooltype0__uuid'
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
        # {
        #     'name': 'systemtooltype0_update_0',
        #     'method': PUT,
        #     'endpoint': 'systemtooltype-detail',
        #     'body': random_model_dict(SystemtoolType),
        #     'args': [
        #         'systemtooltype0__uuid'
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
        #     'name': 'systemtooltype0_get_1',
        #     'method': GET,
        #     'endpoint': 'systemtooltype-detail',
        #     'body': {},
        #     'args': [
        #         'systemtooltype0__uuid'
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
        #     'name': 'systemtooltype0_delete_0',
        #     'method': DELETE,
        #     'endpoint': 'systemtooltype-detail',
        #     'body': {},
        #     'args': [
        #         'systemtooltype0__uuid'
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
        #     'name': 'systemtooltype0_get_2',
        #     'method': GET,
        #     'endpoint': 'systemtooltype-detail',
        #     'body': {},
        #     'args': [
        #         'systemtooltype0__uuid'
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
#creates a systemtooltype and checks that the response data matches the 
#request data stored in the body entry
    # [   
    #     {
    #         'name': 'systemtooltype0',
    #         'method': POST,
    #         'endpoint': 'systemtooltype-list',
    #         'body': (systemtooltype_posted := random_model_dict(SystemtoolType)),
    #         'args': [],
    #         'query_params': [],
    #         'is_valid_response': {
    #             'function': compare_data,
    #             'args': [],
    #             'kwargs': {
    #                 'request_body': systemtooltype_posted
    #             }
    #         }
    #     },
    # ]
]