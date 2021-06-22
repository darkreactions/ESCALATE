from api_docs import status_codes, DELETE, PUT, POST, GET, ERROR


delete_test_data = {
    'delete_test_0':{
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

    }
}

delete_tests =  [
    [
        {
            'method': POST,
            'endpoint': 'organization',
            'body': delete_test_data['delete_test_0']['org0'],
            'args': [],
            'name': 'org0',
            'status_code': status_codes[POST]

        },
        {
            'method': DELETE,
            'endpoint': 'organization',
            'body': {},
            'args': [
                'org0__uuid'
            ],
            'name': 'org_delete',
            'status_code': status_codes[DELETE]
        },
        
    ]
]
     