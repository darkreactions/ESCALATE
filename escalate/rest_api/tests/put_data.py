from api_docs import status_codes, DELETE, PUT, POST, GET, ERROR


put_test_data = {
    'put_test_0':{
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
            'person_update': {
                        "first_name":"update_test",
                        "last_name":"update_test2",
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
                        "added_organization": ['org0__url','org1__url']
        },
    }
}

put_tests =  [
    [
        {
            'method': POST,
            'endpoint': 'organization',
            'body': put_test_data['put_test_0']['org0'],
            'args': [],
            'name': 'org0',
            'status_code': status_codes[POST]

        },
        {
            'method': POST,
            'endpoint': 'organization',
            'body': put_test_data['put_test_0']['org1'],
            'args': [],
            'name': 'org1',
            'status_code': status_codes[POST]
        },
        {
            'method': POST,
            'endpoint': 'person',
            'body': put_test_data['put_test_0']['person'],
            'args': [],
            'name': 'person',
            'status_code': status_codes[POST]
        },
        {
            'method': PUT,
            'endpoint': 'person',
            'body': put_test_data['put_test_0']['person_update'],
            'args': [
                'person__uuid'
                ],
            'name': 'person_update',
            'status_code': status_codes[PUT]
        }
    ]
]
     