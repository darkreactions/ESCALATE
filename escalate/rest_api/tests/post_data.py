import core
from rest_api.utils import camel_case

GET = 'GET'
POST = 'POST'
PUT = 'PUT'
DELETE = 'DELETE'

'''
Shape of any test suite
A test suite is a list of lists of dictionaries. Each list in the whole list
represents 1 test case. Each list's element is a dictionary. The entire shape:

test_suite = [
    [
        {
            'method': <Http verb>,
            'endpoint' <Api endpoint prefix>,
            'body': standard_data[<arbitrary test name>][<request reference name>],
            'args': [...],
            'name': <request reference name> 
        },
        ...
    ]
]

1)  The possible choices for <Http verb> are at the top of the file
2)  Api endpoint prefix example 'systemtool-list' or 'systemtool-detail' -> 'systemtool'
3)  Args is a list of arguements for that request
4)  Name should some unique string among this test CASE. This string helps
    act as a reference for the response of a request so that future requests 
    within a test case may reference values from earlier responses
5)  body is a dictionary mimicking the json that will be in the request body

We store the body of the requests for a test case inside the standard_data dictionary
Its shape:

standard_data = {
    '<arbitrary test name>': {
        '<request reference name>': {
            Dictionary representation of a model instance 
            Keys should be the field names as in a model
            Values are the the value for that field
                If the value should be from a model instance that was posted
            in <request reference name>, a request make earlier within this test case,
            then the format for the value is 
            '<request reference name>__<field name with desired value from previous response>'
            if the value is a foreign key, the format is 
            '<request reference name>__url'
            if the value is the value for a many to many field, the format is
            ['req0__url','req1__url',....]
        }
    }
}
'''

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

test_data = {
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

put_tests =  [
    [
        {
            'method': POST,
            'endpoint': 'organization',
            'body': test_data['put_test_0']['org0'],
            'args': [],
            'name': 'org0'
        },
        {
            'method': POST,
            'endpoint': 'organization',
            'body': test_data['put_test_0']['org1'],
            'args': [],
            'name': 'org1'
        },
        {
            'method': POST,
            'endpoint': 'person',
            'body': test_data['put_test_0']['person'],
            'args': [],
            'name': 'person'
        },
        {
            'method': PUT,
            'endpoint': 'person',
            'body': test_data['put_test_0']['person_update'],
            'args': [
                'person__uuid'
                ],
            'name': 'person_update'
        }
    ]
]
                