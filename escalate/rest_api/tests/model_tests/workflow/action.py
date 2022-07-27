from ..model_tests_utils import (
    status_codes,
    DELETE,
    PUT,
    POST,
    GET,
    ERROR,
    random_model_dict,
    check_status_code,
    compare_data,
)
from core.models import (
    ActionDef,
    ParameterDef,
    # CalculationDef,
    Action,
)

action_test_data = {}

action_tests = [
    ##----TEST 0----##
    # creates an actiondef
    # creates a parameterdef
    # creates a second parameterdef
    # creates a action_sequence
    # creates a calculationdef
    # creates an action with all of the previous entries as foreign keys (one of the two parameterdefs is put in the manytomanyfield)
    # gets the action
    # puts the action adding the other parameterdef to the manytomany field
    # gets the updated action
    # deletes the updated action
    # gets the action (should return error)
    [
        {
            "name": "actiondef0",
            "method": POST,
            "endpoint": "actiondef-list",
            "body": random_model_dict(ActionDef),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "parameterdef0",
            "method": POST,
            "endpoint": "parameterdef-list",
            "body": random_model_dict(ParameterDef),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "action0",
            "method": POST,
            "endpoint": "action-list",
            "body": (
                request_body := random_model_dict(
                    Action,
                )
            ),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": POST, "request_body": request_body},
            },
        },
        {
            "name": "action0_get_0",
            "method": GET,
            "endpoint": "action-detail",
            "body": {},
            "args": ["action0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "action0_update_0",
            "method": PUT,
            "endpoint": "action-detail",
            "body": (request_body := random_model_dict(Action)),
            "args": ["action0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "action0_get_1",
            "method": GET,
            "endpoint": "action-detail",
            "body": {},
            "args": ["action0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "action0_delete_0",
            "method": DELETE,
            "endpoint": "action-detail",
            "body": {},
            "args": ["action0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "action0_get_2",
            "method": GET,
            "endpoint": "action-detail",
            "body": {},
            "args": ["action0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]

"""
{
            'name': 'calculationdef0',
            'method': POST,
            'endpoint': 'calculationdef-list',
            'body': random_model_dict(CalculationDef, parameter_def=['parameterdef0__url']),
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
"""
