from .model_tests_utils import (
    status_codes,
    DELETE,
    PUT,
    POST,
    GET,
    ERROR
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
            'body': person_test_data['person_test_0']['org0'],
            'args': [],
            'name': 'org0',
            'status_code': status_codes[POST]
        },
        {
            'method': POST,
            'endpoint': 'organization-list',
            'body': person_test_data['person_test_0']['org1'],
            'args': [],
            'name': 'org1',
            'status_code': status_codes[POST]
        },
        {
            'method': POST,
            'endpoint': 'person-list',
            'body': person_test_data['person_test_0']['person'],
            'args': [],
            'name': 'person',
            'status_code': status_codes[POST]
        },
        {
            'method': GET,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                'person__uuid'
            ],
            'name': 'get_person',
            'status_code': status_codes[GET]
        },
        {
            'method': PUT,
            'endpoint': 'person-detail',
            'body': person_test_data['person_test_0']['person_update0'],
            'args': [
                'get_person__uuid'
            ],
            'name': 'person_update0',
            'status_code': status_codes[PUT]
        },
        {
            'method': GET,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                'person_update0__uuid'
            ],
            'name': 'get_person_update0',
            'status_code': status_codes[GET]
        },
                {
            'method': PUT,
            'endpoint': 'person-detail',
            'body': person_test_data['person_test_0']['person_update1'],
            'args': [
                'get_person_update0__uuid'
            ],
            'name': 'person_update1',
            'status_code': status_codes[PUT]
        },
        {
            'method': GET,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                'person_update1__uuid'
            ],
            'name': 'get_person_update1',
            'status_code': status_codes[GET]
        },
        {
            'method': DELETE,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                'get_person_update1__uuid'
            ],
            'name': 'delete_person_update1',
            'status_code': status_codes[DELETE]
        },
        {
            'method': GET,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                'get_person_update1__uuid'
            ],
            'name': 'error_get_person_update1',
            'status_code': status_codes[ERROR]
        },
    ]
]