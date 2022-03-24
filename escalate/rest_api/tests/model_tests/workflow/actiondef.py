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
)

actiondef_test_data = {}

actiondef_tests = [
    ##----TEST 0----##
    # creates two parameterdefs
    # creates an actiondef with one of the parameterdefs in the manytomany field
    # gets the actiondef
    # updates the actiondef with the other parameterdef
    # gets the actiondef
    # deletes the actiondef
    # gets the actiondef (should return error)
    [
        *[
            {
                "name": name,
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
            }
            for name in ["parameterdef0", "parameterdef1"]
        ],
        {
            "name": "actiondef0",
            "method": POST,
            "endpoint": "actiondef-list",
            "body": (
                request_body := random_model_dict(
                    ActionDef, parameter_def=["parameterdef0__url"]
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
            "name": "actiondef0_get_0",
            "method": GET,
            "endpoint": "actiondef-detail",
            "body": {},
            "args": ["actiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "actiondef0_update_0",
            "method": PUT,
            "endpoint": "actiondef-detail",
            "body": (
                request_body := random_model_dict(
                    ActionDef, parameter_def=["parameterdef1__url"]
                )
            ),
            "args": ["actiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "actiondef0_get_1",
            "method": GET,
            "endpoint": "actiondef-detail",
            "body": {},
            "args": ["actiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "actiondef0_delete_0",
            "method": DELETE,
            "endpoint": "actiondef-detail",
            "body": {},
            "args": ["actiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "actiondef0_get_2",
            "method": GET,
            "endpoint": "actiondef-detail",
            "body": {},
            "args": ["actiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
