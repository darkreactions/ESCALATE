import random
import string
from rest_api.tests.post_put_delete_tests import add_prev_endpoint_data_2
from django.db.models.fields.related import ManyToManyField
import core
import datetime


GET = 'GET'
POST = 'POST'
PUT = 'PUT'
DELETE = 'DELETE'
ERROR = 'ERROR'

status_codes = {
        POST: 201,
        PUT: 200,
        DELETE: 204,
        GET: 200,
        ERROR: 404
    }

def random_model_dict(model, **kwargs):
    fields = [f for f in model._meta.fields]
    manytomany = [f for f in model._meta.many_to_many]

    all_fields = [*fields, *manytomany]
    _field_names = set([f.name for f in all_fields])

    can_generate_random_val = lambda field: not(
        field.__class__.__name__ == 'RetUUIDField' or
        field.name == 'add_date' or
        field.name == 'mod_date' or
        field.__class__.__name__ == 'ManyToManyField' or
        field.__class__.__name__ == 'ForeignKey' or 
        field.__class__.__name__ == 'OneToOneField'
        )
    dict_fields = {f.name:f for f in filter(can_generate_random_val, all_fields)}
    model_dict = {}
    for field_name, field_obj in dict_fields.items():
        field_class_name = field_obj.__class__.__name__
        if field_obj.choices != None:
            choice_idx = random.randint(0, len(field_obj.choices)-1)
            model_dict[field_name] = field_obj.choices[choice_idx][0]
        else:
            if field_class_name == "CharField":
                length = field_obj.max_length // 3 + 1
                rand_alpha = ''.join(random.choices(string.ascii_lowercase + string.ascii_uppercase, k = length))
                model_dict[field_name] = rand_alpha
            elif field_class_name == "EmailField":
                length = field_obj.max_length // 3 + 1
                rand_alpha = ''.join(random.choices(string.ascii_lowercase + string.ascii_uppercase, k = length))
                model_dict[field_name] = f'{rand_alpha}@test.com'
            elif field_class_name == "DateTimeField":
                rand_year = random.randint(2000, int(str(datetime.datetime.today()).split()[0]))
                rand_month = rand.randint(1,12)
                if rand_month == 2:
                    rand_day = random.randint(1, 28 if rand_year % 4 != 0 else 29)
                else:
                    rand_day = random.randint(1, 30 if rand_month % 2 == 0 else 31)
                model_dict[field_name] = f'{rand_year}-{rand_month}-{rand_day}'
            elif field_class_name == "FloatField" or field_class_name == "BigIntegerField":
                model_dict[field_name] = random.randint(0,255)
            elif field_class_name == "BooleanField":
                model_dict[field_name] = True if random.uniform(0,1) > 0.5 else False
            elif field_class_name == "ValField":
                type_choices = ['text', 'num', 'int', 'array_int', 'array_num', 'bool']
                rand_type = type_choices[random.randint(0, len(type_choices) - 1)]
                rand_unit = ''.join(random.choices(string.ascii_lowercase + string.ascii_uppercase, k = 3))
                if rand_type == 'text':
                    rand_value = ''.join(random.choices(string.ascii_lowercase + string.ascii_uppercase, k = 10))
                elif rand_type == 'num':
                    rand_value = round(random.uniform(0,100),4)
                elif rand_type == 'int':
                    rand_value = random.randint(0,100)
                elif rand_type == 'array_int':
                    rand_value = [random.randint(0,100) for i in range(10)]
                elif rand_type == 'array_num':
                    rand_value = [round(random.uniform(0,100),4) for i in range (10)]
                elif rand_type == 'bool':
                    rand_value = True if random.uniform(0,1) > 0.5 else False
                else:
                    rand_value = ''.join(random.choices(string.ascii_lowercase + string.ascii_uppercase, k = 20))
                model_dict[field_name] = {'type':rand_type, 'unit':rand_unit, 'value':rand_value}
            else:
                print(field_name, field_obj.__class__.__name__)
                length = random.randint(0,25)
                rand_alpha = ''.join(random.choices(string.ascii_lowercase + string.ascii_uppercase, k = length))
                model_dict[field_name] = rand_alpha
    for field_name, value in kwargs.items():
        assert field_name in _field_names, f"invalid field name: {field_name}"
        model_dict[field_name] = value
    return model_dict

def check_status_code(resp, **kwargs):
    http_res_code = kwargs['status_code']
    return resp.status_code == status_codes[http_res_code]


def compare_data(resp, **kwargs):
    body = kwargs['request_body']
    response_data = kwargs['response_data']
    add_prev_endpoint_data_2(body, response_data)

    for key, value in resp.json().items():
        if key in body.keys():
            if value != body[key]:
                print(f'expected: {key} {body[key]}')
                print(f'got: {key} {value}')
                return False
    return True