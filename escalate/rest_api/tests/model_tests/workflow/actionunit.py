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
    ActionUnit,
    Action,
    BaseBomMaterial,
)

actionunit_test_data = {}

actionunit_tests = [

##----TEST 0----##
#creates two basebommaterials
#creates a parameter def
#creates an action
#creates an actionunit with all of the previous entries as foreign keys
#gets the action
#puts the action
#gets the updated systemtooltype
#deletes the updated systemtooltype
#gets the systemtooltype (should return error)
    [      
        {
            'name': 'basebommaterial0',
            'method': POST,
            'endpoint': 'basebommaterial-list',
            'body': random_model_dict(BaseBomMaterial),
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
            'name': 'basebommaterial1',
            'method': POST,
            'endpoint': 'basebommaterial-list',
            'body': random_model_dict(BaseBomMaterial),
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
            'name': 'action0',
            'method': POST,
            'endpoint': 'action-list',
            'body': random_model_dict(Action),
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
            'name': 'actionunit0',
            'method': POST,
            'endpoint': 'actionunit-list',
            'body': random_model_dict(ActionUnit, action='action0__url',
                                                source_material='basebommaterial0__url',
                                                destination_material='basebommaterial1__url'), 
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
            'name': 'actionunit0_get_0',
            'method': GET,
            'endpoint': 'actionunit-detail',
            'body': {},
            'args': [
                'actionunit0__uuid'
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
            'name': 'actionunit0_update_0',
            'method': PUT,
            'endpoint': 'actionunit-detail',
            'body': random_model_dict(ActionUnit, destination_material='basebommaterial0__url',
                                                source_material='basebommaterial1__url'),
            'args': [
                'actionunit0__uuid'
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
            'name': 'actionunit0_get_1',
            'method': GET,
            'endpoint': 'actionunit-detail',
            'body': {},
            'args': [
                'actionunit0__uuid'
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
            'name': 'actionunit0_delete_0',
            'method': DELETE,
            'endpoint': 'actionunit-detail',
            'body': {},
            'args': [
                'actionunit0__uuid'
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
            'name': 'actionunit0_get_2',
            'method': GET,
            'endpoint': 'actionunit-detail',
            'body': {},
            'args': [
                'actionunit0__uuid'
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
#creates a systemtooltype and checks that the response data matches the 
#request data stored in the body entry
    [   
        {
            'name': 'actionunit0',
            'method': POST,
            'endpoint': 'actionunit-list',
            'body': (actionunit_posted := random_model_dict(ActionUnit)),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body': actionunit_posted
                }
            }
        },
    ]
]