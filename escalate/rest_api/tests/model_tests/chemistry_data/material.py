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
    Material,
    MaterialIdentifier,
    MaterialIdentifierDef,
    MaterialType
)

material_test_data = {}

material_tests = [

##----TEST 0----##
#creates a materialidentifierdef
#creates materialidentifier with the previous entry as a manytomany key
#creates a materialtype
#creates a material with the most recent two entries as manytomany keys
#gets the material
#updates the material to no longer have manytomany keys
#gets the material
#deletes the material
#gets the material (should return error)
    [      
        {
            'name': 'materialidentifierdef0',
            'method': POST,
            'endpoint': 'materialidentifierdef-list',
            'body': random_model_dict(MaterialIdentifierDef),
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
            'name': 'materialidentifier0',
            'method': POST,
            'endpoint': 'materialidentifier-list',
            'body': random_model_dict(MaterialIdentifier, material_identifier_def='materialidentifierdef0__url'),
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
            'name': 'materialtype0',
            'method': POST,
            'endpoint': 'materialtype-list',
            'body': random_model_dict(MaterialType),
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
            'body': random_model_dict(Material, identifier=['materialidentifier0__url'], material_type=['materialtype0__url']),
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
            'name': 'material0_get_0',
            'method': GET,
            'endpoint': 'material-detail',
            'body': {},
            'args': [
                'material0__uuid'
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
            'name': 'material0_update_0',
            'method': PUT,
            'endpoint': 'material-detail',
            'body': random_model_dict(Material),
            'args': [
                'material0__uuid'
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
            'name': 'material0_get_1',
            'method': GET,
            'endpoint': 'material-detail',
            'body': {},
            'args': [
                'material0__uuid'
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
            'name': 'material0_delete_0',
            'method': DELETE,
            'endpoint': 'material-detail',
            'body': {},
            'args': [
                'material0__uuid'
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
            'name': 'material0_get_2',
            'method': GET,
            'endpoint': 'material-detail',
            'body': {},
            'args': [
                'material0__uuid'
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
#creates a material and checks that the response data matches the 
#request data stored in the body entry
    [   
        {
            'name': 'material0',
            'method': POST,
            'endpoint': 'material-list',
            'body': (request_body := random_model_dict(Material)),
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': compare_data,
                'args': [],
                'kwargs': {
                    'request_body':request_body,
                }
            }
        },
    ]
]