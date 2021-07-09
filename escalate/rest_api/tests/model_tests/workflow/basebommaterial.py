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
    BaseBomMaterial,
    InventoryMaterial,
    BomMaterial,
    Mixture,
    BillOfMaterials
)

basebommaterial_test_data = {}

basebommaterial_tests = [

##----TEST 0----##
#creates a billofmaterials
#creates an inventorymaterial
#creates a bommaterial
#creates a mixture
#creates a basebommaterial with all of the previous entries as foreign keys
#gets the basebommaterial
#puts the basebommaterial adding the other parameterdef to the manytomany field
#gets the updated basebommaterial
#deletes the updated basebommaterial
#gets the basebommaterial (should return error)
    [      
        {
            'name': 'billofmaterials0',
            'method': POST,
            'endpoint': 'billofmaterials-list',
            'body': random_model_dict(BillOfMaterials),
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
        ##THIS NEEDS TO BE DEBUGGED##
        {
            'name': 'inventorymaterial0',
            'method': POST,
            'endpoint': 'inventorymaterial-list',
            'body': random_model_dict(InventoryMaterial),
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
            'name': 'bommaterial',
            'method': POST,
            'endpoint': 'bommaterial-list',
            'body': random_model_dict(BomMaterial),
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
            'name': 'mixture0',
            'method': POST,
            'endpoint': 'mixture-list',
            'body': random_model_dict(Mixture),
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
            'name': 'basebommaterial0',
            'method': POST,
            'endpoint': 'basebommaterial-list',
            'body': random_model_dict(BaseBomMaterial, bom='billofmaterials0__url',
                                                inventory_material='inventorymaterial0__url',
                                                bom_material='bommaterial0__url',
                                                mixture='mixture0__url'), 
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
            'name': 'basebommaterial0_get_0',
            'method': GET,
            'endpoint': 'basebommaterial-detail',
            'body': {},
            'args': [
                'basebommaterial0__uuid'
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
            'name': 'basebommaterial0_update_0',
            'method': PUT,
            'endpoint': 'basebommaterial-detail',
            'body': random_model_dict(BaseBomMaterial),
            'args': [
                'basebommaterial0__uuid'
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
            'name': 'basebommaterial0_get_1',
            'method': GET,
            'endpoint': 'basebommaterial-detail',
            'body': {},
            'args': [
                'basebommaterial0__uuid'
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
            'name': 'basebommaterial0_delete_0',
            'method': DELETE,
            'endpoint': 'basebommaterial-detail',
            'body': {},
            'args': [
                'basebommaterial0__uuid'
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
            'name': 'basebommaterial0_get_2',
            'method': GET,
            'endpoint': 'basebommaterial-detail',
            'body': {},
            'args': [
                'basebommaterial0__uuid'
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
#creates an basebommaterial and checks that the response data matches the 
#request data stored in the body entry
    [   
        {
            'name': 'basebommaterial0',
            'method': POST,
            'endpoint': 'basebommaterial-list',
            'body': (basebommaterial_posted := random_model_dict(BaseBomMaterial)),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body': basebommaterial_posted
                }
            }
        },
    ]
]