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
from core.models import Tag, TagType

tag_test_data = {}

tag_tests = [
    ##----TEST 0----##
    # creates a tagtype
    # creates a tag with tag type as a foreign key
    # gets the tag
    # puts the tag
    # gets the updated tag
    # deletes the updated tag
    # gets the tag (should return error)
    [
        {
            "name": "tagtype0",
            "method": POST,
            "endpoint": "tagtype-list",
            "body": random_model_dict(TagType),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST,},
            },
        },
        {
            "name": "tag0",
            "method": POST,
            "endpoint": "tag-list",
            "body": (request_body := random_model_dict(Tag, tag_type="tagtype0__url")),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": POST, "request_body": request_body},
            },
        },
        {
            "name": "tag0_get_0",
            "method": GET,
            "endpoint": "tag-detail",
            "body": {},
            "args": ["tag0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "tag0_update_0",
            "method": PUT,
            "endpoint": "tag-detail",
            "body": (request_body := random_model_dict(Tag)),
            "args": ["tag0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "tag0_get_1",
            "method": GET,
            "endpoint": "tag-detail",
            "body": {},
            "args": ["tag0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "tag0_delete_0",
            "method": DELETE,
            "endpoint": "tag-detail",
            "body": {},
            "args": ["tag0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "tag0_get_2",
            "method": GET,
            "endpoint": "tag-detail",
            "body": {},
            "args": ["tag0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
