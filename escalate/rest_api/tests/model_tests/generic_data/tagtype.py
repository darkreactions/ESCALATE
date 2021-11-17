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
    TagType,
)

tagtype_test_data = {}

tagtype_tests = [
    ##----TEST 0----##
    # creates an tagtype
    # gets the action
    # puts the tagtype adding the other parameterdef to the manytomany field
    # gets the updated tagtype
    # deletes the updated tagtype
    # gets the tagtype (should return error)
    [
        {
            "name": "tagtype0",
            "method": POST,
            "endpoint": "tagtype-list",
            "body": (request_body := random_model_dict(TagType)),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": POST, "request_body": request_body},
            },
        },
        {
            "name": "tagtype0_get_0",
            "method": GET,
            "endpoint": "tagtype-detail",
            "body": {},
            "args": ["tagtype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "tagtype0_update_0",
            "method": PUT,
            "endpoint": "tagtype-detail",
            "body": (request_body := random_model_dict(TagType)),
            "args": ["tagtype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "tagtype0_get_1",
            "method": GET,
            "endpoint": "tagtype-detail",
            "body": {},
            "args": ["tagtype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "tagtype0_delete_0",
            "method": DELETE,
            "endpoint": "tagtype-detail",
            "body": {},
            "args": ["tagtype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "tagtype0_get_2",
            "method": GET,
            "endpoint": "tagtype-detail",
            "body": {},
            "args": ["tagtype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
