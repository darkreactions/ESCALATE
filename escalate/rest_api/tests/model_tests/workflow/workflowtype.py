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
    ActionSequenceType,
)

actionsequencetype_test_data = {}

actionsequencetype_tests = [
    ##----TEST 0----##
    # creates an actionsequencetype
    # gets the action
    # puts the actionsequencetype adding the other parameterdef to the manytomany field
    # gets the updated actionsequencetype
    # deletes the updated actionsequencetype
    # gets the actionsequencetype (should return error)
    [
        {
            "name": "actionsequencetype0",
            "method": POST,
            "endpoint": "actionsequencetype-list",
            "body": (request_body := random_model_dict(ActionSequenceType)),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": POST, "request_body": request_body},
            },
        },
        {
            "name": "actionsequencetype0_get_0",
            "method": GET,
            "endpoint": "actionsequencetype-detail",
            "body": {},
            "args": ["actionsequencetype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "actionsequencetype0_update_0",
            "method": PUT,
            "endpoint": "actionsequencetype-detail",
            "body": (request_body := random_model_dict(ActionSequenceType)),
            "args": ["actionsequencetype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "actionsequencetype0_get_1",
            "method": GET,
            "endpoint": "actionsequencetype-detail",
            "body": {},
            "args": ["actionsequencetype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "actionsequencetype0_delete_0",
            "method": DELETE,
            "endpoint": "actionsequencetype-detail",
            "body": {},
            "args": ["actionsequencetype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "actionsequencetype0_get_2",
            "method": GET,
            "endpoint": "actionsequencetype-detail",
            "body": {},
            "args": ["actionsequencetype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
