from django.urls import reverse_lazy

import core.models
import core.forms.forms as forms

methods = {
    "Actor": {
        "model": core.models.view_tables.Actor,
        "form_class": forms.ActorForm,
        "success_url": reverse_lazy("actor_list"),
    },
    "Inventory": {
        "model": core.models.view_tables.Inventory,
        "form_class": forms.InventoryForm,
        "success_url": reverse_lazy("inventory_list"),
    },
    "Material": {
        "model": core.models.view_tables.Material,
        "form_class": forms.MaterialForm,
        "success_url": reverse_lazy("material_list"),
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
    "Person": {
        "model": core.models.view_tables.Person,
        "form_class": forms.PersonForm,
        "success_url": reverse_lazy("person_list"),
    },
    "Status": {
        "model": core.models.view_tables.Status,
        "form_class": forms.StatusForm,
        "success_url": reverse_lazy("status_list"),
    },
    "SystemtoolType": {
        "model": core.models.view_tables.SystemtoolType,
        "form_class": forms.StatusForm,
        "success_url": reverse_lazy("systemtool_type_list"),
    },
    "Tag": {
        "model": core.models.view_tables.Tag,
        "form_class": forms.TagForm,
        "success_url": reverse_lazy("tag_list"),
    },
    "TagType": {
        "model": core.models.view_tables.TagType,
        "form_class": forms.TagTypeForm,
        "success_url": reverse_lazy("tag_type_list"),
    },
    "UdfDef": {
        "model": core.models.view_tables.UdfDef,
        "form_class": forms.UdfDefForm,
        "success_url": reverse_lazy("udf_def_list"),
    },
    "Edocument": {
        "model": core.models.Edocument,
        "form_class": forms.UploadEdocForm,
        "success_url": reverse_lazy("edocument_list"),
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
}
