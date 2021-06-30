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
    Organization,
    Person,
    Actor
)

person_test_data = {
    'person_test_0':{
        'org0': {
                    "description": "Test",
                    "full_name": "Test",
                    "short_name": "Test",
                    "address1": "Test",
                    "address2": "Test",
                    "city": "Test",
                    "state_province": "TT",
                    "zip": "21345",
                    "country": "Test",
                    "website_url": "www.test.com",
                    "phone": "1231231",
                    "parent": None
                },
        'org1': {
                    "description": "Test12",
                    "full_name": "Test12",
                    "short_name": "Test12",
                    "address1": "Test",
                    "address2": "Test",
                    "city": "Test",
                    "state_province": "TT",
                    "zip": "21345",
                    "country": "Test",
                    "website_url": "www.test.com",
                    "phone": "1231231",
                    "parent": None
                },
        'person': {
                    "first_name": "Test",
                    "last_name": "Test",
                    "middle_name": "Test",
                    "address1": "Test",
                    "address2": "Test",
                    "city": "Test",
                    "state_province": "TT",
                    "zip": "123124",
                    "country": "Test",
                    "phone": "123123123",
                    "email": "test@test.com",
                    "title": "Test",
                    "suffix": "",
                },
        'person_update0': {
                    "first_name":"updated_first_name",
                    "last_name":"updated_last_name",
                    "middle_name": "updated_middle_name",
                    "address1": "updated_address1",
                    "address2": "updated_address2",
                    "city": "updated_city",
                    "state_province": "bb",
                    "zip": "111111",
                    "country": "updated_country",
                    "phone": "1111111111",
                    "email": "updated@test.com",
                    "title": "updated_title",
                    "suffix": "updated_suffix",
                    "added_organization": ['org0__url','org1__url']
        },
        'person_update1': {
            "first_name":"updated_first_name",
            "last_name":"updated_last_name",
            "middle_name": "updated_middle_name",
            "address1": "updated_address1",
            "address2": "updated_address2",
            "city": "updated_city",
            "state_province": "bb",
            "zip": "111111",
            "country": "updated_country",
            "phone": "1111111111",
            "email": "updated@test.com",
            "title": "updated_title",
            "suffix": "updated_suffix",
            "added_organization": ['org0__url']
        }
    }
}



person_tests = [
##----TEST 0----##
#creates an organization
#creates a person
#creates an actor with the person and organization as foreign keys
    #this will populate the added_organization field in person with
    #the corresponding organization in the actor table
#deletes the actor
    #empties the added_organization field
#gets the person
#updates person
#gets person
#deletes person
#gets person (should return error)
    [   
        {
            'name': 'org0',
            'method': POST,
            'endpoint': 'organization-list',
            'body': random_model_dict(Organization),
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
            'name': 'person0',
            'method': POST,
            'endpoint': 'person-list',
            'body': random_model_dict(Person),
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
            'name': 'actor0',
            'method': POST,
            'endpoint': 'actor-list',
            'body': random_model_dict(Actor, organization='org0__url', person='person0__url'),
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
            'name': 'actor0_delete_0',
            'method': DELETE,
            'endpoint': 'actor-detail',
            'body': {},
            'args': [
                'actor0__uuid'
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
            'name': 'person0_get_0',
            'method': GET,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                'person0__uuid'
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
            'name': 'person0_update_0',
            'method': PUT,
            'endpoint': 'person-detail',
            'body': random_model_dict(Person),
            'args': [
                'person0__uuid'
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
            'name': 'person0_get_1',
            'method': GET,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                'person0__uuid'
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
            'name': 'person0_delete_0',
            'method': DELETE,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                'person0__uuid'
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
            'name': 'person0_get_3',
            'method': GET,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                'person0__uuid'
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
#creates a person and checks that the response data matches the 
#request data stored in the body entry
    [   
        {
            'name': 'person0',
            'method': POST,
            'endpoint': 'person-list',
            'body': (request_body := random_model_dict(Person)),
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


