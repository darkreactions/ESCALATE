from django.urls import reverse_lazy

import core.models
import core.forms

methods = {
    'Actor': {
        'model': core.models.view_tables.Actor,
        'success_url': reverse_lazy('actor_list'),
    },
    'Inventory': {
        'model': core.models.view_tables.Inventory,
        'success_url': reverse_lazy('inventory_list'),
    },
    'Material': {
        'model': core.models.view_tables.Material,
        'success_url': reverse_lazy('material_list'),
    },
    'Systemtool': {
        'model': core.models.view_tables.Systemtool,
        'success_url': reverse_lazy('systemtool_list'),
    },
    'MaterialType': {
        'model': core.models.view_tables.MaterialType,
        'success_url': reverse_lazy('material_type_list'),
    },
    'Organization': {
        'model': core.models.view_tables.Organization,
        'success_url': reverse_lazy('organization_list'),
    },
    'Person': {
        'model': core.models.view_tables.Person,
        'success_url': reverse_lazy('person_list'),
    },
    'Status': {
        'model': core.models.view_tables.Status,
        'success_url': reverse_lazy('status_list'),
    },
    'SystemtoolType': {
        'model': core.models.view_tables.SystemtoolType,
        'success_url': reverse_lazy('systemtool_type_list'),
    },
    'Tag': {
        'model': core.models.view_tables.Tag,
        'success_url': reverse_lazy('tag_list'),
    },
    'TagType': {
        'model': core.models.view_tables.TagType,
        'success_url': reverse_lazy('tag_type_list'),
    },
    'UdfDef': {
        'model': core.models.view_tables.UdfDef,
        'success_url': reverse_lazy('udf_def_list'),
    },
    'Edocument': {
        'model': core.models.Edocument,
        'success_url': reverse_lazy('edocument_list'),
    },
    'InventoryMaterial': {
        'model': core.models.view_tables.InventoryMaterial,
        'success_url': reverse_lazy('inventory_material_list'),
    },
    'Experiment': {
        'model': core.models.view_tables.Experiment,
        'success_url': reverse_lazy('experiment_list'),
    },
    'Vessel': {
        'model': core.models.view_tables.Vessel,
        'success_url': reverse_lazy('vessel_list'),
    },

}
