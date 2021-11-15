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
from core.models import ActionSequenceType, ExperimentTemplate, ActionSequence

actionsequence_test_data = {}

actionsequence_tests = [
    ##----TEST 0----##
    # creates an experiment
    # creates a actionsequencetype
    # creates a actionsequence
    # creates an actionsequence with the previous three entries as foreign keys/manytomanyfields
    # gets the actionsequence
    # puts the actionsequence adding the other parameterdef to the manytomany field
    # gets the updated actionsequence
    # deletes the updated actionsequence
    # gets the actionsequence (should return error)
    [
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
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "actionsequencetype-list",
                "body": random_model_dict(ActionSequenceType),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["actionsequencetype0", "actionsequencetype1"]
        ],
        {
            "name": "actionsequence0",
            "method": POST,
            "endpoint": "actionsequence-list",
            "body": (
                request_body := random_model_dict(
                    ActionSequence,
                    parent="actionsequence0__url",
                    action_sequence_type="actionsequencetype0__url",
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
            "name": "actionsequence0_get_0",
            "method": GET,
            "endpoint": "actionsequence-detail",
            "body": {},
            "args": ["actionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "actionsequence0_update_0",
            "method": PUT,
            "endpoint": "actionsequence-detail",
            "body": (
                request_body := random_model_dict(
                    ActionSequence,
                    parent="actionsequence1__url",
                    action_sequence_type="actionsequencetype1__url",
                )
            ),
            "args": ["actionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "actionsequence0_get_1",
            "method": GET,
            "endpoint": "actionsequence-detail",
            "body": {},
            "args": ["actionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "actionsequence0_delete_0",
            "method": DELETE,
            "endpoint": "actionsequence-detail",
            "body": {},
            "args": ["actionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "actionsequence0_get_2",
            "method": GET,
            "endpoint": "actionsequence-detail",
            "body": {},
            "args": ["actionsequence0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
