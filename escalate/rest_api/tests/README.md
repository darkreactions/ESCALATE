The tests are split up by models. Each model's test data is in a correspondingly named file 
in the /models_tests/ directory. New model tests must be imported into /models_tests/__init__.py 
in order to be run by pytest. 


Shape of any test suite
A test suite is a list of lists of dictionaries. Each list in the whole list
represents 1 test case. Each list's element is a dictionary. The entire shape:

test_suite = [
    [
        {
            'method': <Http verb>,
            'endpoint' <Api endpoint>,
            'body': standard_data[<arbitrary test name>][<request reference name>],
            'args': [...],
            'name': <request reference name>,
            'response': < Http response> 
        },
        ...
    ]
]

1)  The possible choices for <Http verb> can be found in /model_tests/http_status_codes.py
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