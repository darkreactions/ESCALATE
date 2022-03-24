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
from core.models import ExperimentActionSequence, ExperimentTemplate, ActionSequence

experimentactionsequence_test_data = {}

experimentactionsequence_tests = [
    ##----TEST 0----##
    # creates an experiment
    # creates a actionsequence
    # creates an experimentactionsequence with the previous two entries as foreign keys
    # gets the experimentactionsequence
    # puts the experimentactionsequence adding the other parameterdef to the manytomany field
    # gets the updated experimentactionsequence
    # deletes the updated experimentactionsequence
    # gets the experimentactionsequence (should return error)
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
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "actionsequence-list",
                "body": random_model_dict(ActionSequence),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["actionsequence0", "actionsequence1"]
        ],
        {
            "name": "experimentactionsequence0",
            "method": POST,
            "endpoint": "experimentactionsequence-list",
            "body": (
                request_body := random_model_dict(
                    ExperimentActionSequence,
                    experiment_template="experiment0__url",
                    action_sequence="actionsequence0__url",
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
            "name": "experimentactionsequence0_get_0",
            "method": GET,
            "endpoint": "experimentactionsequence-detail",
            "body": {},
            "args": ["experimentactionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "experimentactionsequence0_update_0",
            "method": PUT,
            "endpoint": "experimentactionsequence-detail",
            "body": (
                request_body := random_model_dict(
                    ExperimentActionSequence,
                    experiment_template="experiment1__url",
                    action_sequence="actionsequence1__url",
                )
            ),
            "args": ["experimentactionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "experimentactionsequence0_get_1",
            "method": GET,
            "endpoint": "experimentactionsequence-detail",
            "body": {},
            "args": ["experimentactionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "experimentactionsequence0_delete_0",
            "method": DELETE,
            "endpoint": "experimentactionsequence-detail",
            "body": {},
            "args": ["experimentactionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "experimentactionsequence0_get_2",
            "method": GET,
            "endpoint": "experimentactionsequence-detail",
            "body": {},
            "args": ["experimentactionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
