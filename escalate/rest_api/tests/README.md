The tests are split up by models. Each model's test data is in a correspondingly named file 
in the /models_tests/ directory. New model tests must be imported into /models_tests/__init__.py 
in order to be run by pytest. 


Shape of any test suite (REQUIRED)
A test suite is a list of lists of dictionaries. Each list in the whole list
represents 1 test case. Each list's element is a dictionary. The name of the 
test suite variable must end with '_tests'. The entire shape:

<model_name>_tests = [
    [
        {
            'name': <request reference name>,
            'method': <Http verb>,
            'endpoint' <Api endpoint>,
            'body': standard_data[<arbitrary test name>][<request reference name>],
            'args': [...],
            'query_params': [...],
            'is_valid_response': {
                'function': foo,
                'args': [...],
                'kwargs' {...}
            }
        },
        ...
    ]
]

1)  'name' should some unique string among this test CASE. This string helps
    act as a reference for the response of a request so that future requests 
    within a test case may reference values from earlier responses
2)  The possible choices for <Http verb> can be found in /model_tests/http_status_codes.py
3)  'endpoint' is the api endpoint name defined in django. Ex: 'systemtool-list'
4)  'args' is a list of arguements for that request's endpoint
5)  'body' is a dictionary mimicking the json that will be in the request body
6)  'query_params' is a list of filter fields ex: ['first_name=Gary',]
7)  'is_valid_response' is a dictionary that contains a function that will be used 
    to validate this request. 'args' and 'kwargs' are the extra arguements to be 
    passed. The definition of foo must have at least 1 required arguement which is
    the response. It also takes in the previous responses data of a test case as a
    kwarg
    Ex:     
            def foo(resp, *args, **kwargs):
                return resp.status_code == 200
            'is_valid_response': {
                'function': foo,
                'args': [],
                'kwargs' {}
            }

            
We store the body of the requests for a test case inside the standard_data dictionary.
Each model's file may have a data dictionary for inline declaration of the bodies
for each test case. This helps separate the test cases from the request bodies
But, if you would like to write the request bodies inline somewhere else feel free
to do so.

Its shape:

standard_data = {
    '<arbitrary test name>': {
        '<request reference name>': {
            Dictionary representation of a model instance 
            Keys should be the field names as in a model
            Values are the the value for that field
                If the value should be from a model instance that was posted
            in <request reference name>, a request made earlier within this test case,
            then the format for the value is 
            '<request reference name>__<field name with desired value from previous response>'
            if the value is a foreign key, the format is 
            '<request reference name>__url'
            if the value is the value for a many to many field, the format is
            ['req0__url','req1__url',....]
        }
    }
}

Alternatively, there is a function called random_model_dict that takes in a model
class and generates a dictionary with appropriate field names and random 
valid values. Fields such as non-null foreign keys/non-null OneToOneFields and 
ManyToManyFields are not auto-generated. The function also takes in key word 
arguements so that you can add/overwrite a field with a desired value.
Example:
some_org = random_model_dict(core.models.Organization,
                            parent='other_org__url',
                            short_name='abc')
The function will create a dictionary that looks like 
{
    full_name: '...',
    short_name: '...',
    ...
}
Then, it takes parent and short_name and adds/overwrites the key-value pair in 
the dictionary

template for a model's test suite: 

some_model_tests = [
    [
        {
            'name': '',
            'method': '',
            'endpoint': '',
            'body': {},
            'args': [],
            'query_params': [],
            'is_valid_response': {
                'function': foo,
                'args': [],
                'kwargs': {}
            }
        },
    ],
]