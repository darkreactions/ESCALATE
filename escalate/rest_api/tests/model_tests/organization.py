from .model_tests_utils import (
    status_codes,
    DELETE,
    PUT,
    POST,
    GET,
    ERROR,
    random_model_dict
)
from core.models import (
    Organization
)

org_test_data = {
    'org_test_0':{
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
                    "parent": "org0__url"
                },
        'org0_update_0': {
                    "description": "test_update",
                    "full_name": "test_update",
                    "short_name": "test_update",
                    "address1": "test_update",
                    "address2": "test_update",
                    "city": "test_update",
                    "state_province": "TF",
                    "zip": "213453",
                    "country": "test_update",
                    "website_url": "www.test_update.com",
                    "phone": "12312313",
                    "parent": "org1__url"
                },
    }
}

org_tests = [
    [       
        #creates 2 organizations
        #creates a person that is a part of these 2 organizations
        #gets that person
        #updates person
        #gets person
        #updates person by deleting from 1 added organization
        #gets person
        #deletes person
        #gets person (should return error)
        #tests creating person with manytomany already
        {
            'method': POST,
            'endpoint': 'organization-list',
            'body': org_test_data['org_test_0']['org0'],
            'args': [],
            'name': 'org0',
            'status_code': status_codes[POST]
        },
        {
            'method': POST,
            'endpoint': 'organization-list',
            'body': org_test_data['org_test_0']['org1'],
            'args': [],
            'name': 'org1',
            'status_code': status_codes[POST]
        },
        {
            'method': PUT,
            'endpoint': 'organization-detail',
            'body': org_test_data['org_test_0']['org0_update_0'],
            'args': [
                'org0__uuid'
            ],
            'name': 'org0_update_0',
            'status_code': status_codes[PUT]
        },
        {
            'method': GET,
            'endpoint': 'organization-detail',
            'body': {},
            'args': [
                'org0__uuid'
            ],
            'name': 'org0_get_0',
            'status_code': status_codes[GET]
        },
        {
            'method': DELETE,
            'endpoint': 'organization-detail',
            'body': {},
            'args': [
                'org0__uuid'
            ],
            'name': 'org0_delete_0',
            'status_code': status_codes[DELETE]
        },
        {
            'method': GET,
            'endpoint': 'organization-detail',
            'body': {},
            'args': [
                'org0__uuid'
            ],
            'name': 'org0_get_1',
            'status_code': status_codes[ERROR]
        },
    ],
    [
        {
            'method': POST,
            'endpoint': 'organization-list',
            'body': random_model_dict(Organization),
            'args': [],
            'name': 'org1',
            'status_code': status_codes[POST]
        },
    ]
]