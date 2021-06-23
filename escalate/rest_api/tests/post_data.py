import core
from rest_api.utils import camel_case
from api_docs import status_codes, DELETE, PUT, POST, GET, ERROR

# This dictionary contains standard data for a particular endpoint
# so that it can be re-used multiple times in different tests without 
# repetition
standard_data = {
    'material': {
                    "description": "TestMaterial2",
                    "consumable": False,
                    "composite_flg": False,
                    "material_class": "model",
                    "actor": None,
                    "status": None
                },
    'actiondef': {
                        "description": "Test Action Def",
                        "actor": None,
                        "status": None
                    },
    'parameterdef': {
                        "description": "Test Parameter Def",
                        "default_val": {
                                            "value": 12.0,
                                            "unit": "M",
                                            "type": "num"
                                        },
                        "required": True,
                        "unit_type": None,
                        #"val_type": None,
                        "actor": None,
                        "status": None
                    },
    'organization': {
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
    'systemtooltype':  { "description": "Test tool type" },
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
                    "uuid": "person__uuid",
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
    },

    'systemtool': {
                                "systemtool_name": "Test tool",
                                "description": "Testing",
                                "model": "Test model",
                                "serial": "1231231",
                                "ver": "1.1",
                                "vendor_organization": 'organization__url',
                                "systemtool_type": 'systemtooltype__url'
                            },
    'workflowtype': { "description": 'Test workflow type' },
    'workflow': {
                    "description": "Test",
                    "parent": None,
                    "workflow_type": 'workflowtype__url',
                    "actor": None,
                    "status": None
                },
    'action': {
                "description": "Test",
                "duration": "10",
                "repeating": 1,
                "action_def": 'actiondef__url',
                "workflow": 'workflow__url',
                "status": None
            },
    'vessel': {
                    "description": "test_desc",
                    "plate_name": "test",
                    "well_number": "test",
                    "actor":None,
                    "status":None,
                },
    'mixture': {
                    "composite": "material__url",
                    "component": "material__url",
                    "actor": None,
                    "status": None
    }
}

post_test_data = {
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
        'org1':  {
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
    }
}


# Simple posts are stored as a list of lists
# Each element of the outer list is a separate test
# The first element of the inner list is the api endpoint
# Second element of the inner list is the post data
simple_post_data = [
    ['material', standard_data['material']],
    ['actiondef', standard_data['actiondef']],
    ['parameterdef', standard_data['parameterdef']],
    ['organization', standard_data['organization']],
    ['systemtooltype', standard_data['systemtooltype']],
    ['person', standard_data['person']],
    ['vessel', standard_data['vessel']]
]

# Complex post data involves setting up multiple posts to endpoints before 
# setting up the final endpoint to be tested
# This is a 3D list
# Elements of the outer list are separate tests
# Elements of dim 2 are all the endpoints to post in order, the last element 
# should be the endpoint to be tested
# Any endpoint that needs results from a previous endpoints has to be a string
# with 2 underscores. The underscores will split the string into 
# <endpoint_name>__<field_name>. It will be replaced by the appropriate data
complex_post_data = [
                        [
                            ['actiondef', standard_data['actiondef']],
                            ['parameterdef', standard_data['parameterdef']],
#                            ['actionparameterdefassign', standard_data['actionparameterdefassign']]                                    
                        ],
                        [
                            ['organization', standard_data['organization']],
                            ['systemtooltype', standard_data['systemtooltype']],
                            ['systemtool', standard_data['systemtool']]
                        ],
                        [
                            ['workflowtype', standard_data['workflowtype']],
                            ['workflow', standard_data['workflow']],
                        ],
                        [   ['actiondef', standard_data['actiondef']],
                            ['workflowtype', standard_data['workflowtype']],
                            ['workflow', standard_data['workflow']],
                            ['action', standard_data['action']]
                        ],
                        [   ['material', standard_data['material']],
                            ['mixture', standard_data['mixture']]
                        ]
                    ]
post_tests =  [
    [
        #post_test0
        #creates 2 organizations
        #creates a person that is a part of these 2 organizations
        #tests creating person with manytomany already
        {
            'method': POST,
            'endpoint': 'organization-list',
            'body': post_test_data['put_test_0']['org0'],
            'args': [],
            'name': 'org0',
            'status_code': status_codes[POST]

        },
        {
            'method': POST,
            'endpoint': 'organization-list',
            'body': post_test_data['put_test_0']['org1'],
            'args': [],
            'name': 'org1',
            'status_code': status_codes[POST]
        },
        {
            'method': POST,
            'endpoint': 'person-list',
            'body': post_test_data['put_test_0']['person'],
            'args': [],
            'name': 'person',
            'status_code': status_codes[POST]
        },
    ]
]
                