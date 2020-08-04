from django.urls import reverse_lazy

import core.models
import core.forms

methods = {
    'Actor': {
        'model': core.models.Actor,
        'success_url': reverse_lazy('actor_list'),
    },
    'Inventory': {
        'model': core.models.Inventory,
        'success_url': reverse_lazy('inventory_list'),
    },
    'Material': {
        'model': core.models.Material,
        'success_url': reverse_lazy('material_list'),
    },
    'Systemtool': {
        'model': core.models.LatestSystemtool,
        'success_url': reverse_lazy('systemtool_list'),
    },
    'MaterialType': {
        'model': core.models.MaterialType,
        'success_url': reverse_lazy('material_type_list'),
    },
    'Organization': {
        'model': core.models.Organization,
        'success_url': reverse_lazy('organization_list'),
    },
    'Person': {
        'model': core.models.Person,
        'success_url': reverse_lazy('person_list'),
    },
    'Status': {
        'model': core.models.Status,
        'success_url': reverse_lazy('status_list'),
    },
    'SystemtoolType': {
        'model': core.models.SystemtoolType,
        'success_url': reverse_lazy('systemtool_type_list'),
    },
    'Tag': {
        'model': core.models.Tag,
        'success_url': reverse_lazy('tag_list'),
    },
    'TagType': {
        'model': core.models.TagType,
        'success_url': reverse_lazy('tag_type_list'),
    },
    'UdfDef': {
        'model': core.models.UdfDef,
        'success_url': reverse_lazy('udf_def_list'),
    },

}
