from django.urls import reverse_lazy

import core.models
import core.forms

methods = {
    'Actor': {
        'model': core.models.Actor,
        'context_object_name': 'actor',
        'form_class': core.forms.ActorForm,
        'success_url': reverse_lazy('actor_list'),
    },
    'Inventory': {
        'model': core.models.Inventory,
        'context_object_name': 'inventory',
        'form_class': core.forms.InventoryForm,
        'success_url': reverse_lazy('inventory_list'),
    },
    'Material': {
        'model': core.models.Material,
        'context_object_name': 'material',
        'form_class': core.forms.MaterialForm,
        'success_url': reverse_lazy('material_list'),
    },
    'Systemtool': {
        'model': core.models.Systemtool,
        'context_object_name': 'systemtool',
        'form_class': core.forms.LatestSystemtoolForm,
        'success_url': reverse_lazy('systemtool_list'),
    },
    'MaterialType': {
        'model': core.models.MaterialType,
        'context_object_name': 'material_type',
        'form_class': core.forms.MaterialTypeForm,
        'success_url': reverse_lazy('material_type_list'),
    },
    'Organization': {
        'model': core.models.Organization,
        'context_object_name': 'organization',
        'form_class': core.forms.OrganizationForm,
        'success_url': reverse_lazy('organization_list'),
    },
    'Person': {
        'model': core.models.Person,
        'context_object_name': 'person',
        'form_class': core.forms.PersonForm,
        'success_url': reverse_lazy('person_list'),
    },
    'Status': {
        'model': core.models.Status,
        'context_object_name': 'status',
        'form_class': core.forms.StatusForm,
        'success_url': reverse_lazy('status_list'),
    },
    'SystemtoolType': {
        'model': core.models.SystemtoolType,
        'context_object_name': 'systemtool_type',
        'form_class': core.forms.StatusForm,
        'success_url': reverse_lazy('systemtool_type_list'),
    },
    'Tag': {
        'model': core.models.Tag,
        'context_object_name': 'tag',
        'form_class': core.forms.TagForm,
        'success_url': reverse_lazy('tag_list'),
    },
    'TagType': {
        'model': core.models.TagType,
        'context_object_name': 'tag_type',
        'form_class': core.forms.TagTypeForm,
        'success_url': reverse_lazy('tag_type_list'),
    },
    'UdfDef': {
        'model': core.models.UdfDef,
        'context_object_name': 'udf_def',
        'form_class': core.forms.UdfDefForm,
        'success_url': reverse_lazy('udf_def_list'),
    },
    'Edocument': {
        'model': core.models.Edocument,
        'context_object_name': 'edocument',
        'form_class': core.forms.UploadEdocForm,
        'success_url': reverse_lazy('edocument_list'),
    },

}
