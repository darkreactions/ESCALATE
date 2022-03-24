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
from core.models import UdfDef, TypeDef

udfdef_test_data = {}

udfdef_tests = [
    ##----TEST 0----##
    # creates a typedef
    # creates a udfdef with typedef as a foreign key
    # gets the udfdef
    # puts the udfdef
    # gets the updated udfdef
    # deletes the updated udfdef
    # gets the udfdef (should return error)
    [
        {
            "name": "typedef0",
            "method": POST,
            "endpoint": "typedef-list",
            "body": random_model_dict(TypeDef),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {
                    "status_code": POST,
                },
            },
        },
        {
            "name": "udfdef0",
            "method": POST,
            "endpoint": "udfdef-list",
            "body": (
                request_body := random_model_dict(UdfDef, val_type="typedef0__url")
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
            "name": "udfdef0_get_0",
            "method": GET,
            "endpoint": "udfdef-detail",
            "body": {},
            "args": ["udfdef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "udfdef0_update_0",
            "method": PUT,
            "endpoint": "udfdef-detail",
            "body": (request_body := random_model_dict(UdfDef)),
            "args": ["udfdef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "udfdef0_get_1",
            "method": GET,
            "endpoint": "udfdef-detail",
            "body": {},
            "args": ["udfdef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "udfdef0_delete_0",
            "method": DELETE,
            "endpoint": "udfdef-detail",
            "body": {},
            "args": ["udfdef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "udfdef0_get_2",
            "method": GET,
            "endpoint": "udfdef-detail",
            "body": {},
            "args": ["udfdef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
