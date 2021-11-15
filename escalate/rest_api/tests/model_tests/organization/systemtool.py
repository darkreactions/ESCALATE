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
from core.models import Systemtool, SystemtoolType, Organization

systemtool_test_data = {}

systemtool_tests = [
    ##----TEST 0----##
    # creates a systemtool type
    # creates a second systemtool type
    # creates an organization
    # creates a second organization
    # creates a systemtool with vendor_organization as the 1st organization and systemtool_type as the 1st systemtool_type
    # gets the systemtool
    # puts the systemtool with vendor_organization as the 2nd organization and systemtool_type as the 2nd systemtool_type
    # gets the updated systemtool
    # deletes the updated systemtool
    # gets the systemtool (should return error)
    [
        {
            "name": "systemtool_type0",
            "method": POST,
            "endpoint": "systemtooltype-list",
            "body": random_model_dict(SystemtoolType),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "systemtool_type1",
            "method": POST,
            "endpoint": "systemtooltype-list",
            "body": random_model_dict(SystemtoolType),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "org0",
            "method": POST,
            "endpoint": "organization-list",
            "body": random_model_dict(Organization),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "org1",
            "method": POST,
            "endpoint": "organization-list",
            "body": random_model_dict(Organization),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "systemtool0",
            "method": POST,
            "endpoint": "systemtool-list",
            "body": (
                request_body := random_model_dict(
                    Systemtool,
                    vendor_organization="org0__url",
                    systemtool_type="systemtool_type0__url",
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
            "name": "get_systemtool0",
            "method": GET,
            "endpoint": "systemtool-detail",
            "body": {},
            "args": ["systemtool0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "systemtool0_update0",
            "method": PUT,
            "endpoint": "systemtool-detail",
            "body": (
                request_body := random_model_dict(
                    Systemtool,
                    vendor_organization="org1__url",
                    systemtool_type="systemtool_type1__url",
                )
            ),
            "args": ["systemtool0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "get_systemtool0_update0",
            "method": GET,
            "endpoint": "systemtool-detail",
            "body": {},
            "args": ["systemtool0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "systemtool0_update0_delete",
            "method": DELETE,
            "endpoint": "systemtool-detail",
            "body": {},
            "args": ["systemtool0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "get_systemtool0_update0_delete",
            "method": GET,
            "endpoint": "systemtool-detail",
            "body": {},
            "args": ["systemtool0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
