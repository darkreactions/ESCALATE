from django.urls import reverse_lazy

import core.models
import core.forms

methods = {
    "Material": {
        "model": core.models.view_tables.Material,
        "success_url": reverse_lazy("material_list"),
    },
    "Systemtool": {
        "model": core.models.view_tables.Systemtool,
        "success_url": reverse_lazy("systemtool_list"),
    },
    "MaterialType": {
        "model": core.models.view_tables.MaterialType,
        "success_url": reverse_lazy("material_type_list"),
    },
    "MaterialIdentifier": {
        "model": core.models.view_tables.MaterialIdentifier,
        "success_url": reverse_lazy("material_identifier_list"),
    },
    "Organization": {
        "model": core.models.view_tables.Organization,
        "success_url": reverse_lazy("organization_list"),
    },
    "Status": {
        "model": core.models.view_tables.Status,
        "success_url": reverse_lazy("status_list"),
    },
    "Tag": {
        "model": core.models.view_tables.Tag,
        "success_url": reverse_lazy("tag_list"),
    },
    "InventoryMaterial": {
        "model": core.models.view_tables.InventoryMaterial,
        "success_url": reverse_lazy("inventory_material_list"),
    },
    "ExperimentInstance": {
        "model": core.models.view_tables.ExperimentInstance,
        "success_url": reverse_lazy("experiment_pending_instance_list"),
    },
    "ExperimentPendingInstance": {
        "model": core.models.view_tables.ExperimentPendingInstance,
        "success_url": reverse_lazy("experiment_pending_instance_list"),
    },
    "ExperimentCompletedInstance": {
        "model": core.models.view_tables.ExperimentCompletedInstance,
        "success_url": reverse_lazy("experiment_completed_instance_list"),
    },
    "Vessel": {
        "model": core.models.view_tables.Vessel,
        "success_url": reverse_lazy("vessel_list"),
    },
    "ActionDef": {
        "model": core.models.view_tables.ActionDef,
        "success_url": reverse_lazy("action_def_list"),
    },
    "ParameterDef": {
        "model": core.models.view_tables.ParameterDef,
        "success_url": reverse_lazy("parameter_def_list"),
    },
    "PropertyTemplate": {
        "model": core.models.view_tables.PropertyTemplate,
        "success_url": reverse_lazy("property_template_list"),
    },
    "Property": {
        "model": core.models.Property,
        "success_url": reverse_lazy("material_list"),
    },
    "ReagentTemplate": {
        "model": core.models.ReagentTemplate,
        "success_url": reverse_lazy("experiment_template_list"),
    },
    "VesselTemplate": {
        "model": core.models.VesselTemplate,
        "success_url": reverse_lazy("experiment_template_list"),
    },
    "OutcomeTemplate": {
        "model": core.models.OutcomeTemplate,
        "success_url": reverse_lazy("experiment_template_list"),
    },
}
