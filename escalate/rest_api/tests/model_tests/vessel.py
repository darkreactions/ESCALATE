from .model_tests_utils import (
    status_codes,
    DELETE,
    PUT,
    POST,
    GET,
    ERROR,
    random_model_dict
)
from core.models import (
    Vessel,
    Actor,
    Status
)

vessel_test_data = {}



#creates new actor
#creates a new status
#creates a vessel with the status as a foreign key
#gets the vessel
vessel_tests = [
    [       
        {
            'method': POST,
            'endpoint': 'actor-list',
            'body': random_model_dict(Actor),
            'args': [],
            'name': 'actor0',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[POST]
        },
        {
            'method': POST,
            'endpoint': 'status-list',
            'body': random_model_dict(Status),
            'args': [],
            'name': 'status0',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[POST]
        },
        {
            'method': POST,
            'endpoint': 'vessel-list',
            'body': random_model_dict(Vessel, status='status0__url'),
            'args': [],
            'name': 'vessel0',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[POST]
        },
        {
            'method': GET,
            'endpoint': 'vessel-detail',
            'body': {},
            'args': [
                'vessel0__uuid'
            ],
            'name': 'vessel0_get_0',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[GET]
        },
        {
            'method': PUT,
            'endpoint': 'vessel-detail',
            'body': random_model_dict(Vessel, actor='actor0__url', status=None),
            'args': [
                'vessel0__uuid'
            ],
            'name': 'vessel0_update_0',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[PUT]
        },
        {
            'method': GET,
            'endpoint': 'vessel-detail',
            'body': {},
            'args': [
                'vessel0__uuid'
            ],
            'name': 'vessel0_get_1',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[GET]
        },
        {
            'method': DELETE,
            'endpoint': 'vessel-detail',
            'body': {},
            'args': [
                'vessel0__uuid'
            ],
            'name': 'vessel0_delete_0',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[DELETE]
        },
        {
            'method': GET,
            'endpoint': 'vessel-detail',
            'body': {},
            'args': [
                'vessel0__uuid'
            ],
            'name': 'vessel0_get_2',
            'is_valid_response': lambda resp, _: resp.status_code == status_codes[ERROR]
        },
    ],
]