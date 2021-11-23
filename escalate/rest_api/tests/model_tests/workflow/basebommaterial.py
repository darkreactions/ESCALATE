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
    BaseBomMaterial,
    InventoryMaterial,
    BomMaterial,
    Mixture,
    BillOfMaterials,
    Inventory,
    Material,
)

basebommaterial_test_data = {}

basebommaterial_tests = [
    ##----TEST 0----##
    # creates a billofmaterials
    # creates an inventorymaterial
    # creates a bommaterial
    # creates a mixture
    # creates a basebommaterial with all of the previous entries as foreign keys
    # gets the basebommaterial
    # puts the basebommaterial adding the other parameterdef to the manytomany field
    # gets the updated basebommaterial
    # deletes the updated basebommaterial
    # gets the basebommaterial (should return error)
    [
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "billofmaterials-list",
                "body": random_model_dict(BillOfMaterials),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["billofmaterials0", "billofmaterials1"]
        ],
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "inventory-list",
                "body": random_model_dict(Inventory),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["inventory0", "inventory1"]
        ],
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "material-list",
                "body": (request_body := random_model_dict(Material)),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": compare_data,
                    "args": [],
                    "kwargs": {"status_code": POST, "request_body": request_body},
                },
            }
            for name in ["material0", "material1"]
        ],
        *[
            {
                "name": "inventorymaterial" + str(i),
                "method": POST,
                "endpoint": "inventorymaterial-list",
                "body": (
                    request_body := random_model_dict(
                        InventoryMaterial,
                        inventory="inventory" + str(i) + "__url",
                        material="material" + str(i) + "__url",
                    )
                ),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": compare_data,
                    "args": [],
                    "kwargs": {"status_code": POST, "request_body": request_body},
                },
            }
            for i in range(2)
        ],
        *[
            {
                "name": "bommaterial" + str(i),
                "method": POST,
                "endpoint": "bommaterial-list",
                "body": random_model_dict(
                    BomMaterial,
                    inventory_material="inventorymaterial" + str(i) + "__url",
                ),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for i in range(2)
        ],
        *[
            {
                "name": name,
                "method": POST,
                "endpoint": "mixture-list",
                "body": random_model_dict(Mixture),
                "args": [],
                "query_params": [],
                "is_valid_response": {
                    "function": check_status_code,
                    "args": [],
                    "kwargs": {"status_code": POST},
                },
            }
            for name in ["mixture0", "mixture1"]
        ],
        {
            "name": "basebommaterial0",
            "method": POST,
            "endpoint": "basebommaterial-list",
            "body": (
                request_body := random_model_dict(
                    BaseBomMaterial,
                    bom="billofmaterials0__url",
                    inventory_material="inventorymaterial0__url",
                    # bom_material='bommaterial0__url',
                    mixture="mixture0__url",
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
            "name": "basebommaterial0_get_0",
            "method": GET,
            "endpoint": "basebommaterial-detail",
            "body": {},
            "args": ["basebommaterial0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "basebommaterial0_update_0",
            "method": PUT,
            "endpoint": "basebommaterial-detail",
            "body": (
                request_body := random_model_dict(
                    BaseBomMaterial,
                    bom="billofmaterials1__url",
                    inventory_material="inventorymaterial1__url",
                    # bom_material='bommaterial1__url',
                    mixture="mixture1__url",
                )
            ),
            "args": ["basebommaterial0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": compare_data,
                "args": [],
                "kwargs": {"status_code": PUT, "request_body": request_body},
            },
        },
        {
            "name": "basebommaterial0_get_1",
            "method": GET,
            "endpoint": "basebommaterial-detail",
            "body": {},
            "args": ["basebommaterial0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": GET},
            },
        },
        {
            "name": "basebommaterial0_delete_0",
            "method": DELETE,
            "endpoint": "basebommaterial-detail",
            "body": {},
            "args": ["basebommaterial0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": DELETE},
            },
        },
        {
            "name": "basebommaterial0_get_2",
            "method": GET,
            "endpoint": "basebommaterial-detail",
            "body": {},
            "args": ["basebommaterial0__uuid"],
            "query_params": [],
            "is_valid_response": {
                "function": check_status_code,
                "args": [],
                "kwargs": {"status_code": ERROR},
            },
        },
    ],
]
