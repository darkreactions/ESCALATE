from django.urls import reverse_lazy

import core.models

# import core.forms.forms as forms
import core.forms.models as forms

methods = {
    "Material": {
        "model": core.models.view_tables.Material,
        "form_class": forms.MaterialForm,
        "success_url": reverse_lazy("material_list"),
    },
    "MaterialIdentifier": {
        "model": core.models.view_tables.MaterialIdentifier,
        "form_class": forms.MaterialIdentifierForm,
        "success_url": reverse_lazy("material_identifier_list"),
    },
    "Systemtool": {
        "model": core.models.view_tables.Systemtool,
        "form_class": forms.LatestSystemtoolForm,
        "success_url": reverse_lazy("systemtool_list"),
    },
    "MaterialType": {
        "model": core.models.view_tables.MaterialType,
        "form_class": forms.MaterialTypeForm,
        "success_url": reverse_lazy("material_type_list"),
    },
    "Organization": {
        "model": core.models.view_tables.Organization,
        "form_class": forms.OrganizationForm,
        "success_url": reverse_lazy("organization_list"),
    },
    "Status": {
        "model": core.models.view_tables.Status,
        "form_class": forms.StatusForm,
        "success_url": reverse_lazy("status_list"),
    },
    "Tag": {
        "model": core.models.view_tables.Tag,
        "form_class": forms.TagForm,
        "success_url": reverse_lazy("tag_list"),
    },
    "TagType": {
        "model": core.models.TagType,
        "form_class": forms.TagTypeForm,
        "success_url": reverse_lazy("tag_type_list"),
    },
    "InventoryMaterial": {
        "model": core.models.view_tables.InventoryMaterial,
        "form_class": forms.InventoryMaterialForm,
        "success_url": reverse_lazy("inventory_material_list"),
    },
    "Vessel": {
        "model": core.models.view_tables.Vessel,
        "form_class": forms.VesselForm,
        "success_url": reverse_lazy("vessel_list"),
    },
    "ActionDef": {
        "model": core.models.view_tables.ActionDef,
        "form_class": forms.ActionDefForm,
        "success_url": reverse_lazy("action_def_list"),
    },
    "ParameterDef": {
        "model": core.models.view_tables.ParameterDef,
        "form_class": forms.ParameterDefForm,
        "success_url": reverse_lazy("parameter_def_list"),
    },
    "PropertyTemplate": {
        "model": core.models.view_tables.PropertyTemplate,
        "form_class": forms.PropertyTemplateForm,
        "success_url": reverse_lazy("property_template_list"),
    },
    "Property": {
        "model": core.models.view_tables.Property,
        "form_class": forms.PropertyForm,
        "success_url": reverse_lazy("property_template_list"),
    },
    "ReagentTemplate": {
        "model": core.models.view_tables.ReagentTemplate,
        "form_class": forms.ReagentTemplateForm,
        "success_url": reverse_lazy("experiment_template_list"),
    },
    "VesselTemplate": {
        "model": core.models.view_tables.VesselTemplate,
        "form_class": forms.VesselTemplateForm,
        "success_url": reverse_lazy("experiment_template_list"),
    },
    "OutcomeTemplate": {
        "model": core.models.OutcomeTemplate,
        "form_class": forms.OutcomeTemplateForm,
        "success_url": reverse_lazy("experiment_template_list"),
    },
}
