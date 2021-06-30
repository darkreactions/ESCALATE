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
    Inventory,
    Actor,
    Status
)

inventory_test_data = {}

inventory_tests = [
##----TEST 0----##
# creates 6 actors
# creates 2 statuses
# creates an inventory with 3 of the actors and a status
# gets it
# updates inventory with 3 other actors and the other status
# gets it
# deletes it 
# gets it (should error)
    [
        *[{
            'name': name,
            'method': POST,
            'endpoint': 'actor-list',
            'body': random_model_dict(Actor),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST,
                }
            }
        } for name in ['owner0','operator0','lab0','owner1','operator1','lab1']
        ],
        *[{
            'name': name,
            'method': POST,
            'endpoint': 'status-list',
            'body': random_model_dict(Status),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST,
                }
            }
        } for name in ['status0','status1']
        ],
        {
            'name': 'inventory',
            'method': POST,
            'endpoint': 'inventory-list',
            'body': (request_body := random_model_dict(Inventory,
                                                       owner='owner0__url',
                                                       operator='operator0__url',
                                                       lab='lab0__url',
                                                       status='status0__url')),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST,
                }
            }
        },
        {
            'name': 'inventory_get',
            'method': GET,
            'endpoint': 'inventory-detail',
            'body': {},
            'args': [
                'inventory__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': GET,
                }
            }
        },
        {
            'name': 'inventory_update',
            'method': PUT,
            'endpoint': 'inventory-detail',
            'body': (request_body := random_model_dict(Inventory,
                                                       owner='owner1__url',
                                                       operator='operator1__url',
                                                       lab='lab1__url',
                                                       status='status1__url')),
            'args': [
                'inventory__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': PUT,
                }
            }
        },
        {
            'name': 'inventory_update_get',
            'method': GET,
            'endpoint': 'inventory-detail',
            'body': {},
            'args': [
                'inventory__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': GET,
                }
            }
        },
        {
            'name': 'inventory_update_del',
            'method': DELETE,
            'endpoint': 'inventory-detail',
            'body': {},
            'args': [
                'inventory__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': DELETE,
                }
            }
        },
        {
            'name': 'inventory_update_del_get',
            'method': GET,
            'endpoint': 'inventory-detail',
            'body': {},
            'args': [
                'inventory__uuid'
            ],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': ERROR,
                }
            }
        },
    ],
##----TEST 1----##
#creates a inventory and checks that the response data matches the 
#request data stored in the body entry
    [
        *[{
            'name': name,
            'method': POST,
            'endpoint': 'actor-list',
            'body': random_model_dict(Actor),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST,
                }
            }
        } for name in ['owner', 'operator', 'lab']],
        {
            'name': 'status',
            'method': POST,
            'endpoint': 'status-list',
            'body': random_model_dict(Status),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': check_status_code,
                'args': [],
                'kwargs': {
                    'status_code': POST,
                }
            }
        },
        {
            'name': 'inventory',
            'method': POST,
            'endpoint': 'inventory-list',
            'body': (request_body := random_model_dict(Inventory,
                                                       owner='owner__url',
                                                       operator='operator__url',
                                                       lab='lab__url',
                                                       status='status__url')),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body': request_body,
                }
            }
        },
    ]
]