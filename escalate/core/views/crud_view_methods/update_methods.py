from django.urls import reverse_lazy

import core.models
import core.forms.forms as forms

methods = {
    'Actor': {
        'model': core.models.view_tables.Actor,
        'context_object_name': 'actor',
        'form_class': forms.ActorForm,
        'success_url': reverse_lazy('actor_list'),
    },
    'Inventory': {
        'model': core.models.view_tables.Inventory,
        'context_object_name': 'inventory',
        'form_class': forms.InventoryForm,
        'success_url': reverse_lazy('inventory_list'),
    },
    'Material': {
        'model': core.models.view_tables.Material,
        'context_object_name': 'material',
        'form_class': forms.MaterialForm,
        'success_url': reverse_lazy('material_list'),
    },
    'Systemtool': {
        'model': core.models.view_tables.Systemtool,
        'context_object_name': 'systemtool',
        'form_class': forms.LatestSystemtoolForm,
        'success_url': reverse_lazy('systemtool_list'),
    },
    'MaterialType': {
        'model': core.models.view_tables.MaterialType,
        'context_object_name': 'material_type',
        'form_class': forms.MaterialTypeForm,
        'success_url': reverse_lazy('material_type_list'),
    },
    'Organization': {
        'model': core.models.view_tables.Organization,
        'context_object_name': 'organization',
        'form_class': forms.OrganizationForm,
        'success_url': reverse_lazy('organization_list'),
    },
    'Person': {
        'model': core.models.view_tables.Person,
        'context_object_name': 'person',
        'form_class': forms.PersonForm,
        'success_url': reverse_lazy('person_list'),
    },
    'Status': {
        'model': core.models.view_tables.Status,
        'context_object_name': 'status',
        'form_class': forms.StatusForm,
        'success_url': reverse_lazy('status_list'),
    },
    'SystemtoolType': {
        'model': core.models.view_tables.SystemtoolType,
        'context_object_name': 'systemtool_type',
        'form_class': forms.StatusForm,
        'success_url': reverse_lazy('systemtool_type_list'),
    },
    'Tag': {
        'model': core.models.view_tables.Tag,
        'context_object_name': 'tag',
        'form_class': forms.TagForm,
        'success_url': reverse_lazy('tag_list'),
    },
    'TagType': {
        'model': core.models.view_tables.TagType,
        'context_object_name': 'tag_type',
        'form_class': forms.TagTypeForm,
        'success_url': reverse_lazy('tag_type_list'),
    },
    'UdfDef': {
        'model': core.models.view_tables.UdfDef,
        'context_object_name': 'udf_def',
        'form_class': forms.UdfDefForm,
        'success_url': reverse_lazy('udf_def_list'),
    },
    'Edocument': {
        'model': core.models.Edocument,
        'context_object_name': 'edocument',
        'form_class': forms.UploadEdocForm,
        'success_url': reverse_lazy('edocument_list'),
    },

    'InventoryMaterial': {
        'model': core.models.view_tables.InventoryMaterial,
        'context_object_name': 'inventory_material',
        'form_class': forms.InventoryMaterialForm,
        'success_url': reverse_lazy('inventory_material_list'),
    },
    'Experiment': {
        'model': core.models.view_tables.Experiment,
        'context_object_name': 'experiment',
        'form_class': forms.InventoryMaterialForm,
        'success_url': reverse_lazy('experiment_list'),
    },
}
