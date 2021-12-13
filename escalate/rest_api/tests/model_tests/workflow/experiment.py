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
    ExperimentType,
    TypeDef,
    Actor,
    ActionSequence,
    ExperimentTemplate,
)

experiment_test_data = {}

experiment_tests = [
    ##----TEST 0----##
    # creates an experiment type
    # creates a typedef
    # creates three actors
    # creates an experiment with all of the previous entries as foreign keys (one of the two parameterdefs is put in the manytomanyfield)
    # gets the experiment
    # puts the experiment adding the other parameterdef to the manytomany field
    # gets the updated experiment
    # deletes the updated experiment
    # gets the experiment (should return error)
    [
        {
            "name": "experimenttype0",
            "method": POST,
            "endpoint": "experimenttype-list",
            "body": random_model_dict(ExperimentType),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "experiment0",
            "method": POST,
            "endpoint": "experimenttemplate-list",
            "body": random_model_dict(ExperimentTemplate),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {
                    "status_code": POST,
                },
            },
        },
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "actor-list",
                "body": random_model_dict(Actor),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["actor0", "actor1", "actor2"]
        ],
        {
            "name": "experiment1",
            "method": POST,
            "endpoint": "experimenttemplate-list",
            "body": (
                request_body := random_model_dict(
                    ExperimentTemplate,
                    experiment_type="experimenttype0__url",
                    # parent='experiment0__url',
                    owner="actor0__url",
                    operator="actor1__url",
                    lab="actor2__url",
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
            "name": "experiment1_get_0",
            "method": GET,
            "endpoint": "experimenttemplate-detail",
            "body": {},
            "args": ["experiment1__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "experiment1_update_0",
            "method": PUT,
            "endpoint": "experimenttemplate-detail",
            "body": (request_body := random_model_dict(ExperimentTemplate)),
            "args": ["experiment1__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "experiment1_get_1",
            "method": GET,
            "endpoint": "experimenttemplate-detail",
            "body": {},
            "args": ["experiment1__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "experiment1_delete_0",
            "method": DELETE,
            "endpoint": "experimenttemplate-detail",
            "body": {},
            "args": ["experiment1__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "experiment1_get_2",
            "method": GET,
            "endpoint": "experimenttemplate-detail",
            "body": {},
            "args": ["experiment1__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
