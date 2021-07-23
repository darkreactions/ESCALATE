from .misc import FrozenDict

def get_all_related_fields_backward(model):
    def _get_all_fields_rec(model, all_related_fields, parent_model=None, parent_field_name=None):
        # key is name of a field, value is the name of foreign key field in the model that has the field in the key
        model_fields = model._meta.get_fields()
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
                field_rel_class = getattr(field_obj, 'rel_class', None)
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
            field_rel_class = getattr(field_obj, 'rel_class', None)
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