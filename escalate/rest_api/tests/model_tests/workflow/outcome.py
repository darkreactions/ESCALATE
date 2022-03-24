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
    OutcomeTemplate,
    ExperimentTemplate,
)

outcome_test_data = {}

outcome_tests = [
    ##----TEST 0----##
    # creates an experiment
    # creates an outcome with the previous two entries as foreign keys
    # gets the outcome
    # puts the outcome adding the other parameterdef to the manytomany field
    # gets the updated outcome
    # deletes the updated outcome
    # gets the outcome (should return error)
    [
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "experimenttemplate-list",
                "body": random_model_dict(ExperimentTemplate),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["experiment0", "experiment1"]
        ],
        {
            "name": "outcome0",
            "method": POST,
            "endpoint": "outcometemplate-list",
            "body": (
                request_body := random_model_dict(
                    OutcomeTemplate, experiment="experiment0__url"
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
            "name": "outcome0_get_0",
            "method": GET,
            "endpoint": "outcometemplate-detail",
            "body": {},
            "args": ["outcome0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "outcome0_update_0",
            "method": PUT,
            "endpoint": "outcometemplate-detail",
            "body": (
                request_body := random_model_dict(
                    OutcomeTemplate, experiment="experiment0__url"
                )
            ),
            "args": ["outcome0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "outcome0_get_1",
            "method": GET,
            "endpoint": "outcometemplate-detail",
            "body": {},
            "args": ["outcome0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "outcome0_delete_0",
            "method": DELETE,
            "endpoint": "outcometemplate-detail",
            "body": {},
            "args": ["outcome0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "outcome0_get_2",
            "method": GET,
            "endpoint": "outcometemplate-detail",
            "body": {},
            "args": ["outcome0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
