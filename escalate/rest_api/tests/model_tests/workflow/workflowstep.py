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
    createSystemtool,
)
from core.models import (
    ActionSequence,
    Action,
    ActionSequenceStep,
    ActionSequenceObject,
)

workflowstep_test_data = {}

workflowstep_tests = [
    ##----TEST 0----##
    # creates a workflow
    # creates a workflowactionset
    # creates a workflowstep
    # creates a workflowobject
    # creates an workflowstep with the previous three entries as foreign keys
    # gets the workflowstep
    # puts the workflowstep adding the other parameterdef to the manytomany field
    # gets the updated workflowstep
    # deletes the updated workflowstep
    # gets the workflowstep (should return error)
    [
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "workflow-list",
                "body": random_model_dict(ActionSequence),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["workflow0", "workflow1"]
        ],
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "action-list",
                "body": random_model_dict(Action),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {
                        "status_code": POST,
                    },
                },
            }
            for name in ["action0", "action1"]
        ],
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "workflowobject-list",
                "body": random_model_dict(ActionSequenceObject),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {
                        "status_code": POST,
                    },
                },
            }
            for name in ["workflowobject0", "workflowobject1"]
        ],
        {
            "name": "workflowstep0",
            "method": POST,
            "endpoint": "workflowstep-list",
            "body": (
                request_body := random_model_dict(
                    ActionSequenceStep,
                    workflow="workflow0__url",
                    parent="workflow1__url",
                    action="action0__url",
                    workflow_object="workflowobject0__url",
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
            "name": "workflowstep0_get_0",
            "method": GET,
            "endpoint": "workflowstep-detail",
            "body": {},
            "args": ["workflowstep0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "workflowstep0_update_0",
            "method": PUT,
            "endpoint": "workflowstep-detail",
            "body": (
                request_body := random_model_dict(
                    ActionSequenceStep,
                    workflow="workflow1__url",
                    parent="workflow0__url",
                    action="action1__url",
                    workflow_object="workflowobject1__url",
                )
            ),
            "args": ["workflowstep0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "workflowstep0_get_1",
            "method": GET,
            "endpoint": "workflowstep-detail",
            "body": {},
            "args": ["workflowstep0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "workflowstep0_delete_0",
            "method": DELETE,
            "endpoint": "workflowstep-detail",
            "body": {},
            "args": ["workflowstep0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "workflowstep0_get_2",
            "method": GET,
            "endpoint": "workflowstep-detail",
            "body": {},
            "args": ["workflowstep0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
