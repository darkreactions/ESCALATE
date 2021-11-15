from rest_api.tests.post_put_delete_tests import add_prev_endpoint_data_2
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
from core.models import MaterialIdentifier, MaterialIdentifierDef, Status

material_identifier_data = {}

material_identifier_tests = [
    ##----TEST 0----##
    # creates 2 material identifier def
    # creates 2 statuses
    # creates a material identifier with one of material identifer def and status
    # gets it
    # puts the material identifier with the other material identifier def and status
    # gets it
    # deletes it
    # gets it (should error)
    [
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "materialidentifierdef-list",
                "body": random_model_dict(MaterialIdentifierDef),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["mat_iden_def0", "mat_iden_def1"]
        ],
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "status-list",
                "body": random_model_dict(Status),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["status0", "status1"]
        ],
        {
            "name": "mat_iden",
            "method": POST,
            "endpoint": "materialidentifier-list",
            "body": (
                request_body := random_model_dict(
                    MaterialIdentifier,
                    material_identifier_def="mat_iden_def0__url",
                    status="status0__url",
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
            "name": "mat_iden_get",
            "method": GET,
            "endpoint": "materialidentifier-detail",
            "body": {},
            "args": ["mat_iden__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "mat_iden_update",
            "method": PUT,
            "endpoint": "materialidentifier-detail",
            "body": (
                request_body := random_model_dict(
                    MaterialIdentifier,
                    material_identifier_def="mat_iden_def1__url",
                    status="status1__url",
                )
            ),
            "args": ["mat_iden__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "mat_iden_update_get",
            "method": GET,
            "endpoint": "materialidentifier-detail",
            "body": {},
            "args": ["mat_iden__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "mat_iden_update_del",
            "method": DELETE,
            "endpoint": "materialidentifier-detail",
            "body": {},
            "args": ["mat_iden__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "mat_iden_update_del_get",
            "method": GET,
            "endpoint": "materialidentifier-detail",
            "body": {},
            "args": ["mat_iden__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
