import functools
import random
import string
import copy
import json
import collections.abc


def rsetattr(obj, attr, val):
    pre, _, post = attr.rpartition('.')
    return setattr(rgetattr(obj, pre) if pre else obj, post, val)


def rgetattr(obj, attr, *args):
    def _getattr(obj, attr):
        if obj == None:
            return None
        else:
            return getattr(obj, attr, *args)
    return functools.reduce(_getattr, [obj] + attr.split('.'))


def getattr_or_none(obj, attr):
    try:
        return getattr(obj, attr)
    except:
        return None


def get_all_related_fields_backward(model):
    def _get_all_fields_rec(model, all_related_fields, parent_model=None, parent_field_name=None):
        # key is name of a field, value is the name of foreign key field in the model that has the field in the key
        model_fields = [*model._meta.fields, *model._meta.many_to_many]
        for field_obj in model_fields:
            field_details = FrozenDict(**{
                'model': model,
                'field_name': field_obj.name
            })
            parent_field_details = FrozenDict(**{
                'model': parent_model,
                'field_name': parent_field_name
            })
            if field_details not in all_related_fields:
                field_rel_class = getattr_or_none(field_obj, 'rel_class')
                if field_rel_class:
                    # not flat field
                    #fk or oneToOne or manyToMany
                    field_rel_class_name = field_rel_class.__name__
                    if field_rel_class_name != 'ManyToManyRel':
                        # some sort of fk field
                        all_related_fields[field_details] = parent_field_details
                        _get_all_fields_rec(field_obj.related_model,
                                            all_related_fields,
                                            parent_model=model,
                                            parent_field_name=field_obj.name)
                else:
                    all_related_fields[field_details] = parent_field_details
    all_related_fields = {FrozenDict(**{
        'model': None,
        'field_name': None
    })}
    _get_all_fields_rec(model, all_related_fields)
    return all_related_fields

# builds a trie structure to map out all of a model's fields and all of its foreign key models' fields


def get_all_related_fields(top_level_model):
    all_related_fields = {}

    def get_all_related_fields_rec(model, parent_model=None):
        model_fields = [*model._meta.fields, *model._meta.many_to_many]
        for field_obj in model_fields:
            field_name = field_obj.name
            field_details = FrozenDict(**{
                'model': model,
                'field_name': field_name
            })
            field_rel_class = getattr_or_none(field_obj, 'rel_class')
            if field_rel_class:
                field_rel_class_name = field_rel_class.__name__
                if field_rel_class_name != 'ManyToManyRel':
                    related_model = field_obj.related_model
                    all_related_fields[field_details] = related_model
                    if related_model != parent_model:
                        get_all_related_fields_rec(
                            field_obj.related_model, parent_model=model)
                else:
                    all_related_fields[field_details] = None
            else:
                all_related_fields[field_details] = None
    get_all_related_fields_rec(top_level_model)
    return all_related_fields


def get_model_of_related_field(model, full_related_field, all_related_fields=None):
    # Ex: full_related_field = a__b__c__...d where a is a field of model
    field_relations_order = full_related_field.split('__')
    if len(field_relations_order) == 1:
        return model

    if all_related_fields == None:
        all_related_fields = get_all_related_fields(model)
    # traverse through all related_fields
    cur_model = model
    cur_field_details = None
    for field_name in field_relations_order:
        if cur_model == None:
            print('should never reach here')
            break
        cur_field_details = FrozenDict(**{
            'model': cur_model,
            'field_name': field_name
        })
        cur_model = all_related_fields[cur_field_details]
    return cur_field_details['model']


class FrozenDict(collections.abc.Mapping):
    '''
    Frozen dictionary class to use if needed
    item assignment is disabled
    new attribute assignment is disabled since it doesn't extend dict directly
    '''
    __is_frozen = False

    def __init__(self, *args, **kwargs):
        self._d = dict(*args, **kwargs)
        self._hash = None
        self.__is_frozen = True

    def __iter__(self):
        return iter(self._d)

    def __len__(self):
        return len(self._d)

    def __getitem__(self, key):
        return self._d[key]

    def __str__(self):
        return str(self._d)

    def __repr__(self):
        return str(self._d)

    def __hash__(self):
        if self._hash is None:
            hash_ = 0
            for pair in sorted(self.items()):
                hash_ ^= hash(pair)
            self._hash = hash_
        return self._hash

    def __setattr__(self, key, value):
        if self.__is_frozen and not hasattr(self, key):
            raise Exception(
                f'{self} is a frozen class. Cannot set new attribute {key}')
        object.__setattr__(self, key, value)
