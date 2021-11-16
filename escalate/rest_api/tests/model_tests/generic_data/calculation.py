from ..model_tests_utils import (
    createSystemtool,
    status_codes,
    DELETE,
    PUT,
    POST,
    GET,
    ERROR,
    random_model_dict,
    check_status_code,
    compare_data,
    createSystemtool,
)
from core.models import Calculation, CalculationDef, ParameterDef

calculation_test_data = {}

calculation_tests = [
    ##----TEST 0----##
    # creates a systemtool
    # creates a calculationdef
    # creates a calculation with the previous entries as a foreign key
    # gets the calculation
    # puts the calculation
    # gets the updated calculation
    # deletes the updated calculation
    # gets the calculation (should return error)
    [
        *createSystemtool(2),
        {
            "name": "parameterdef0",
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
        },
        {
            "name": "calculationdef0",
            "method": POST,
            "endpoint": "calculationdef-list",
            "body": random_model_dict(
                CalculationDef, parameter_def=["parameterdef0__url"]
            ),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "calculation0",
            "method": POST,
            "endpoint": "calculation-list",
            "body": (
                request_body := random_model_dict(
                    Calculation,
                    systemtool="systemtool0__url",
                    calculation_def="calculationdef0__url",
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
            "name": "calculation0_get_0",
            "method": GET,
            "endpoint": "calculation-detail",
            "body": {},
            "args": ["calculation0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "calculation0_update_0",
            "method": PUT,
            "endpoint": "calculation-detail",
            "body": (
                request_body := random_model_dict(
                    Calculation, systemtool="systemtool0__url"
                )
            ),
            "args": ["calculation0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "calculation0_get_1",
            "method": GET,
            "endpoint": "calculation-detail",
            "body": {},
            "args": ["calculation0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "calculation0_delete_0",
            "method": DELETE,
            "endpoint": "calculation-detail",
            "body": {},
            "args": ["calculation0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "calculation0_get_2",
            "method": GET,
            "endpoint": "calculation-detail",
            "body": {},
            "args": ["calculation0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
