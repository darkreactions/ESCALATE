from ..model_tests_utils import (
    DELETE,
    PUT,
    POST,
    GET,
    ERROR,
    random_model_dict,
    check_status_code,
    compare_data,
)

from core.models import PropertyTemplate

property_def_data = {}

property_def_tests = [
    ##----TEST 0----##
    [
        {
            "name": "property_def",
            "method": POST,
            "endpoint": "propertytemplate-list",
            "body": (request_body := random_model_dict(PropertyTemplate)),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": POST, "request_body": request_body},
            },
        },
        {
            "name": "property_def_get",
            "method": GET,
            "endpoint": "propertytemplate-detail",
            "body": {},
            "args": ["property_def__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "property_def_update",
            "method": PUT,
            "endpoint": "propertytemplate-detail",
            "body": (request_body := random_model_dict(PropertyTemplate)),
            "args": ["property_def__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "property_def_update_get",
            "method": GET,
            "endpoint": "propertytemplate-detail",
            "body": {},
            "args": ["property_def__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "property_def_update_del",
            "method": DELETE,
            "endpoint": "propertytemplate-detail",
            "body": {},
            "args": ["property_def__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "propery_def_update_del_get",
            "method": GET,
            "endpoint": "propertytemplate-detail",
            "body": {},
            "args": ["property_def__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
