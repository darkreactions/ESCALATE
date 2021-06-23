import random
import string
import core


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

def random_model_dict(model_name, **kwargs):
    model_class_name = ''.join([x.capitalize() for x in model_name.split("_")])
    model = getattr(core.models, model_class_name)
    fields = [f for f in model._meta.fields]

    _field_names = set([f.name for f in fields])

    is_flat = lambda field: not(
        field.__class__.__name__ == 'RetUUIDField' or
        field.name == 'add_date' or
        field.name == 'mod_date' or
        field.__class__.__name__ == 'ManyToManyField' or
        (field.__class__.__name__ == 'ForeignKey' and not field.null) or 
        (field.__class__.__name__ == 'OneToOneField' and not field.null)
        )
    dict_fields = {f.name:f for f in filter(is_flat, fields)}
    model_dict = {}
    for field_name, field_obj in dict_fields.items():
        field_class_name = field_obj.__class__.__name__
        if field_obj.choices != None:
            choice_idx = random.randint(0, len(field_obj.choices))
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
            elif field_class_name == "ForeignKey":
                model_dict[field_name] = None
            elif field_class_name == "BooleanField":
                model_dict[field_name] = True if random.uniform(0,1) > 0.5 else False
            else:
                length = field_obj.max_length // 3 + 1
                rand_alpha = ''.join(random.choices(string.ascii_lowercase + string.ascii_uppercase, k = length))
                model_dict[field_name] = rand_alpha
    for field_name, value in kwargs.items():
        assert field_name in _field_names, "invalid field name"
        model_dict[field_name] = value
    return model_dict