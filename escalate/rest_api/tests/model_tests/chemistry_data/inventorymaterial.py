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
    InventoryMaterial,
    Inventory,
    Material
)

inventorymaterial_test_data = {}

inventorymaterial_tests = [

##----TEST 0----##
#creates an inventory
#creates a material
#creates an inventorymaterial with all of the previous entries as foreign keys
#gets the action
#puts the inventorymaterial adding the other parameterdef to the manytomany field
#gets the updated inventorymaterial
#deletes the updated inventorymaterial
#gets the inventorymaterial (should return error)
    [      
        {
            'name': 'inventory0',
            'method': POST,
            'endpoint': 'inventory-list',
            'body': random_model_dict(Inventory),
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
            'name': 'material0',
            'method': POST,
            'endpoint': 'material-list',
            'body': random_model_dict(Material),
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
            'name': 'inventorymaterial0',
            'method': POST,
            'endpoint': 'inventorymaterial-list',
            'body': (request_body := random_model_dict(InventoryMaterial, inventory='inventory0__url',
                                                #material='material0__url'
                                                )), 
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
            'name': 'inventorymaterial0_get_0',
            'method': GET,
            'endpoint': 'inventorymaterial-detail',
            'body': {},
            'args': [
                'inventorymaterial0__uuid'
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
            'name': 'inventorymaterial0_update_0',
            'method': PUT,
            'endpoint': 'inventorymaterial-detail',
            'body': (request_body := random_model_dict(InventoryMaterial)),
            'args': [
                'inventorymaterial0__uuid'
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
            'name': 'inventorymaterial0_get_1',
            'method': GET,
            'endpoint': 'inventorymaterial-detail',
            'body': {},
            'args': [
                'inventorymaterial0__uuid'
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
            'name': 'inventorymaterial0_delete_0',
            'method': DELETE,
            'endpoint': 'inventorymaterial-detail',
            'body': {},
            'args': [
                'inventorymaterial0__uuid'
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
            'name': 'inventorymaterial0_get_2',
            'method': GET,
            'endpoint': 'inventorymaterial-detail',
            'body': {},
            'args': [
                'inventorymaterial0__uuid'
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