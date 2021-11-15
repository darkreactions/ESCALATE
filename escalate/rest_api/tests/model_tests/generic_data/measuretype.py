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
    MeasureType,
)

measuretype_test_data = {}

measuretype_tests = [
    ##----TEST 0----##
    # creates an measuretype
    # gets the action
    # puts the measuretype adding the other parameterdef to the manytomany field
    # gets the updated measuretype
    # deletes the updated measuretype
    # gets the measuretype (should return error)
    [
        {
            "name": "measuretype0",
            "method": POST,
            "endpoint": "measuretype-list",
            "body": (request_body := random_model_dict(MeasureType)),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": POST, "request_body": request_body},
            },
        },
        {
            "name": "measuretype0_get_0",
            "method": GET,
            "endpoint": "measuretype-detail",
            "body": {},
            "args": ["measuretype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "measuretype0_update_0",
            "method": PUT,
            "endpoint": "measuretype-detail",
            "body": (request_body := random_model_dict(MeasureType)),
            "args": ["measuretype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "measuretype0_get_1",
            "method": GET,
            "endpoint": "measuretype-detail",
            "body": {},
            "args": ["measuretype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "measuretype0_delete_0",
            "method": DELETE,
            "endpoint": "measuretype-detail",
            "body": {},
            "args": ["measuretype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "measuretype0_get_2",
            "method": GET,
            "endpoint": "measuretype-detail",
            "body": {},
            "args": ["measuretype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
