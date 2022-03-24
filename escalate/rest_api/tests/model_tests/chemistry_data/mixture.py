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
from core.models import Mixture, Material, MaterialType

mixture_test_data = {}

mixture_tests = [
    ##----TEST 0----##
    # creates a material
    # creates a second material
    # creates a materialtype
    # creates a mixture with materialtype as a manytomany key and the two materials as foreign keys
    # gets the mixture
    # updates the mixture to no longer have manytomany/foreign keys
    # gets the mixture
    # deletes the mixture
    # gets the mixture (should return error)
    [
        {
            "name": "material0",
            "method": POST,
            "endpoint": "material-list",
            "body": random_model_dict(Material),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "material1",
            "method": POST,
            "endpoint": "material-list",
            "body": random_model_dict(Material),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "materialtype0",
            "method": POST,
            "endpoint": "materialtype-list",
            "body": random_model_dict(MaterialType),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "mixture0",
            "method": POST,
            "endpoint": "mixture-list",
            "body": (
                request_body := random_model_dict(
                    Mixture,
                    composite="material0__url",
                    component="material1__url",
                    material_type=["materialtype0__url"],
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
            "name": "mixture0_get_0",
            "method": GET,
            "endpoint": "mixture-detail",
            "body": {},
            "args": ["mixture0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "mixture0_update_0",
            "method": PUT,
            "endpoint": "mixture-detail",
            "body": (request_body := random_model_dict(Mixture)),
            "args": ["mixture0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "mixture0_get_1",
            "method": GET,
            "endpoint": "mixture-detail",
            "body": {},
            "args": ["mixture0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "mixture0_delete_0",
            "method": DELETE,
            "endpoint": "mixture-detail",
            "body": {},
            "args": ["mixture0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "mixture0_get_2",
            "method": GET,
            "endpoint": "mixture-detail",
            "body": {},
            "args": ["mixture0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
