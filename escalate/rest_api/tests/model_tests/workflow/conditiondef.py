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
    ConditionDef,
    CalculationDef,
)

conditiondef_test_data = {}

conditiondef_tests = [
    ##----TEST 0----##
    # creates two calculationdefs
    # creates an conditiondef with one of the calculationdefs in the manytomany field
    # gets the conditiondef
    # updates the conditiondef with the other calculationdef
    # gets the conditiondef
    # deletes the conditiondef
    # gets the conditiondef (should return error)
    [
        # {
        #     'name': 'calculationdef0',
        #     'method': POST,
        #     'endpoint': 'calculationdef-list',
        #     'body': random_model_dict(CalculationDef),
        #     'args': [],
        #     'query_params': [],
        #     'is_valid_response': {
        #         'function': check_status_code,
        #         'args': [],
        #         'kwargs': {
        #             'status_code': POST
        #         }
        #     }
        # },
        # {
        #     'name': 'calculationdef1',
        #     'method': POST,
        #     'endpoint': 'calculationdef-list',
        #     'body': random_model_dict(CalculationDef),
        #     'args': [],
        #     'query_params': [],
        #     'is_valid_response': {
        #         'function': check_status_code,
        #         'args': [],
        #         'kwargs': {
        #             'status_code': POST
        #         }
        #     }
        # },
        {
            "name": "conditiondef0",
            "method": POST,
            "endpoint": "conditiondef-list",
            "body": (
                request_body := random_model_dict(
                    ConditionDef,  # calculation_def=['calculationdef0__url']
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
            "name": "conditiondef0_get_0",
            "method": GET,
            "endpoint": "conditiondef-detail",
            "body": {},
            "args": ["conditiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "conditiondef0_update_0",
            "method": PUT,
            "endpoint": "conditiondef-detail",
            "body": (
                request_body := random_model_dict(
                    ConditionDef,  # calculation_def=['calculationdef1__url']
                )
            ),
            "args": ["conditiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "conditiondef0_get_1",
            "method": GET,
            "endpoint": "conditiondef-detail",
            "body": {},
            "args": ["conditiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "conditiondef0_delete_0",
            "method": DELETE,
            "endpoint": "conditiondef-detail",
            "body": {},
            "args": ["conditiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "conditiondef0_get_2",
            "method": GET,
            "endpoint": "conditiondef-detail",
            "body": {},
            "args": ["conditiondef0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
