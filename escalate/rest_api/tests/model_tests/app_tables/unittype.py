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
from core.models import UnitType

unittype_test_data = {}

unittype_tests = [
    ##----TEST 0----##
    # creates an unittype
    # gets the unittype
    # puts the unittype
    # gets the updated unittype
    # deletes the updated unittype
    # gets the unittype (should return error)
    [
        {
            "name": "unittype0",
            "method": POST,
            "endpoint": "unittype-list",
            "body": (request_body := random_model_dict(UnitType)),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": POST, "request_body": request_body},
            },
        },
        {
            "name": "unittype0_get_0",
            "method": GET,
            "endpoint": "unittype-detail",
            "body": {},
            "args": ["unittype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "unittype0_update_0",
            "method": PUT,
            "endpoint": "unittype-detail",
            "body": (request_body := random_model_dict(UnitType)),
            "args": ["unittype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "unittype0_get_1",
            "method": GET,
            "endpoint": "unittype-detail",
            "body": {},
            "args": ["unittype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "unittype0_delete_0",
            "method": DELETE,
            "endpoint": "unittype-detail",
            "body": {},
            "args": ["unittype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "unittype0_get_2",
            "method": GET,
            "endpoint": "unittype-detail",
            "body": {},
            "args": ["unittype0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
