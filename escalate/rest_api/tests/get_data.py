from api_docs import status_codes, DELETE, PUT, POST, GET, ERROR
from post_data import post_tests


get_test_data = {
    'get_test_0':{
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

get_tests =  [
    [
        #get_test0
        #creates an organization and gets it
        {
            'method': POST,
            'endpoint': 'organization-list',
            'body': get_test_data['get_test_0']['org0'],
            'args': [],
            'name': 'org0',
            'status_code': status_codes[POST]

        },
        {
            'method': GET,
            'endpoint': 'organization-detail',
            'body': {},
            'args': [
                'org0__uuid'
                ],
            'name': 'org0_get',
            'status_code': status_codes[GET]
        },
        
    ]
]

# adds all the post tests from the post_data file and then gets after
for post_test in post_tests:
    post_test_last_req_name = post_test[len(post_test) - 1]['name']
    get_after_post_test = [
        *post_test,
        {
            'method': GET,
            'endpoint': 'person-detail',
            'body': {},
            'args': [
                f'{post_test_last_req_name}__uuid'
                ],
            'name': 'get_after_post',
            'status_code': status_codes[GET]
        }
    ]
    get_tests.append(get_after_post_test)
     