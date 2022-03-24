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
from core.models import ActionUnit, Action, BaseBomMaterial, ActionDef

actionunit_test_data = {}

actionunit_tests = [
    ##----TEST 0----##
    # creates two basebommaterials
    # creates a parameter def
    # creates an action
    # creates an actionunit with all of the previous entries as foreign keys
    # gets the action
    # puts the action
    # gets the updated systemtooltype
    # deletes the updated systemtooltype
    # gets the systemtooltype (should return error)
    [
        # *[{
        #     'name': name,
        #     'method': POST,
        #     'endpoint': 'basebommaterial-list',
        #     'body': random_model_dict(BaseBomMaterial),
        #     'args': [],
        #     'query_params': [],
        #     'is_valid_response': {
        #         'function': check_status_code,
        #         'args': [],
        #         'kwargs': {
        #             'status_code': POST
        #         }
        #     }
        # } for name in ['basebommaterial0', 'basebommaterial1']],
        {
            "name": "basebommaterial0",
            "method": POST,
            "endpoint": "basebommaterial-list",
            "body": random_model_dict(BaseBomMaterial),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "basebommaterial1",
            "method": POST,
            "endpoint": "basebommaterial-list",
            "body": random_model_dict(BaseBomMaterial),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        {
            "name": "actiondef0",
            "method": POST,
            "endpoint": "actiondef-list",
            "body": random_model_dict(ActionDef),
            "args": [],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": POST},
            },
        },
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "action-list",
                "body": random_model_dict(Action, action_def="actiondef0__url"),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["action0", "action1"]
        ],
        {
            "name": "actionunit0",
            "method": POST,
            "endpoint": "actionunit-list",
            "body": (
                request_body := random_model_dict(
                    ActionUnit,
                    action="action0__url",
                    source_material="basebommaterial0__url",
                    destination_material="basebommaterial1__url",
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
            "name": "actionunit0_get_0",
            "method": GET,
            "endpoint": "actionunit-detail",
            "body": {},
            "args": ["actionunit0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "actionunit0_update_0",
            "method": PUT,
            "endpoint": "actionunit-detail",
            "body": (
                request_body := random_model_dict(
                    ActionUnit,
                    action="action1__url",
                    destination_material="basebommaterial0__url",
                    source_material="basebommaterial1__url",
                )
            ),
            "args": ["actionunit0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "actionunit0_get_1",
            "method": GET,
            "endpoint": "actionunit-detail",
            "body": {},
            "args": ["actionunit0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "actionunit0_delete_0",
            "method": DELETE,
            "endpoint": "actionunit-detail",
            "body": {},
            "args": ["actionunit0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "actionunit0_get_2",
            "method": GET,
            "endpoint": "actionunit-detail",
            "body": {},
            "args": ["actionunit0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
