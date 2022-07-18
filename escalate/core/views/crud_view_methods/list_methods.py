import core.models


methods = {
    "Material": {
        "model": core.models.view_tables.Material,
        "table_columns": [
            "Chemical Name",
            "Identifiers",
            "Properties",
            "Type",
            "Status",
        ],
        "column_necessary_fields": {
            "Chemical Name": ["description"],
            "Identifiers": ["identifier"],
            "Properties": ["property_m"],
            "Type": ["material_type"],
            "Status": ["status.description"],
        },
        "ordering": ["description"],
        "field_contains": "",
    },
    "MaterialIdentifier": {
        "model": core.models.view_tables.MaterialIdentifier,
        "table_columns": ["Description", "Identifier Type"],
        "column_necessary_fields": {
            "Description": ["description"],
            "Identifier Type": ["full_description"],
        },
        "ordering": ["full_description"],
        "field_contains": "",
    },
    "Vessel": {
        "model": core.models.view_tables.Vessel,
        "table_columns": ["Description", "Total Volume", "Well Count"],
        "column_necessary_fields": {
            "Description": ["description"],
            "Total Volume": ["total_volume"],
            "Well Count": ["well_number"],
        },
        "ordering": ["description"],
        "field_contains": "",
        "default_filter_kwargs": {"parent__isnull": True},
    },
    "Systemtool": {
        "model": core.models.view_tables.Systemtool,
        "table_columns": [
            "Name",
            "Description",
            "Systemtool Type",
            "Vendor Organization",
        ],
        "column_necessary_fields": {
            "Name": ["systemtool_name"],
            "Description": ["description"],
            "Systemtool Type": ["systemtool_type.description"],
            "Vendor Organization": ["vendor_organization.full_name"],
        },
        "ordering": ["systemtool_name"],
        "field_contains": "",
    },
    "MaterialType": {
        "model": core.models.view_tables.MaterialType,
        "table_columns": [
            "Description",
        ],
        "column_necessary_fields": {"Description": ["description"]},
        "ordering": ["description"],
        "field_contains": "",
    },
    "Organization": {
        "model": core.models.view_tables.Organization,
        "table_columns": [
            "Full Name",
            "Address",
            "Website",
        ],
        "column_necessary_fields": {
            "Full Name": ["full_name"],
            "Address": [
                "address1",
                "address2",
                "zip",
                "city",
                "state_province",
                "country",
            ],
            "Website": ["website_url"],
        },
        "ordering": ["full_name"],
        "field_contains": "",
    },
    "Status": {
        "model": core.models.view_tables.Status,
        "table_columns": [
            "Description",
        ],
        "column_necessary_fields": {"Description": ["description"]},
        "ordering": ["description"],
        "field_contains": "",
    },
    "SystemtoolType": {
        "model": core.models.view_tables.SystemtoolType,
        "table_columns": [
            "Description",
        ],
        "column_necessary_fields": {"Description": ["description"]},
        "ordering": ["description"],
        "field_contains": "",
    },
    "Tag": {
        "model": core.models.view_tables.Tag,
        "table_columns": [
            "Name",
            "Description",
            "Tag Type",
        ],
        "column_necessary_fields": {
            "Name": ["display_text"],
            "Description": ["description"],
            "Tag Type": ["tag_type.type"],
        },
        "ordering": ["display_text"],
        "field_contains": "",
    },
    "TagType": {
        "model": core.models.view_tables.TagType,
        "table_columns": ["Type"],
        "column_necessary_fields": {"Type": ["type"]},
        "ordering": ["type"],
    },
    "InventoryMaterial": {
        "model": core.models.view_tables.InventoryMaterial,
        "table_columns": [
            "Description",
            "Inventory",
            "Material",
            "Phase",
            "Amount On Hand",
            "Expiration Date",
            "Location",
        ],
        "column_necessary_fields": {
            "Description": ["description"],
            "Inventory": ["inventory.description"],
            "Material": ["material.description"],
            "Phase": ["phase"],
            "Amount On Hand": ["onhand_amt"],
            "Expiration Date": ["expiration_date"],
            "Location": ["location"],
        },
        "ordering": ["description"],
        "field_contains": "",
        "org_related_path": "inventory__lab__organization",
    },
    "ActionDef": {
        "model": core.models.view_tables.ActionDef,
        "table_columns": [
            "Description",
            "Parameters",
        ],
        "column_necessary_fields": {
            "Description": ["description"],
            "Parameters": ["parameter_def"],
        },
        "ordering": ["description"],
        "field_contains": "",
    },
    "ParameterDef": {
        "model": core.models.view_tables.ParameterDef,
        "table_columns": [
            "Description",
            "Default Value",
            "Unit Type",
        ],
        "column_necessary_fields": {
            "Description": ["description"],
            "Default Value": ["default_val"],
            "Unit Type": ["unit_type"],
        },
        "ordering": ["description"],
        "field_contains": "",
    },
    "PropertyTemplate": {
        "model": core.models.view_tables.PropertyTemplate,
        "table_columns": [
            "Description",
        ],
        "column_necessary_fields": {
            "Description": ["description"],
        },
        "ordering": ["description"],
        "field_contains": "",
    },
    "ExperimentInstance": {
        "model": core.models.view_tables.ExperimentInstance,
        "table_columns": [
            "Experiment Name",
            "Date Queued",
            "Submitted By",
            "Status",
            "Priority",
        ],
        "column_necessary_fields": {
            "Experiment Name": ["description"],
            #'Experiment Template': ['workflow'],
            "Date Queued": ["add_date"],
            "Submitted By": ["operator.description"],
            "Status": ["completion_status"],
            "Priority": ["priority"],
        },
        "ordering": ["description"],
        "field_contains": "",
        "org_related_path": "lab__organization",
        "default_filter_kwargs": {"template__isnull": False},
    },
    "ExperimentPendingInstance": {
        "model": core.models.view_tables.ExperimentPendingInstance,
        "table_columns": [
            "Experiment Name",
            "Date Queued",
            "Submitted By",
            "Status",
            "Priority",
        ],
        "column_necessary_fields": {
            "Experiment Name": ["description"],
            #'Experiment Template': ['workflow'],
            "Date Queued": ["add_date"],
            "Submitted By": ["operator.description"],
            "Status": ["completion_status"],
            "Priority": ["priority"],
        },
        "ordering": ["description"],
        "field_contains": "",
        "org_related_path": "lab__organization",
        "default_filter_kwargs": {"template__isnull": False},
    },
    "ExperimentCompletedInstance": {
        "model": core.models.view_tables.ExperimentCompletedInstance,
        "table_columns": [
            "Experiment Name",
            "Date Queued",
            "Submitted By",
            "Status",
            "Priority",
        ],
        "column_necessary_fields": {
            "Experiment Name": ["description"],
            #'Experiment Template': ['workflow'],
            "Date Queued": ["add_date"],
            "Submitted By": ["operator.description"],
            "Status": ["completion_status"],
            "Priority": ["priority"],
        },
        "ordering": ["description"],
        "field_contains": "",
        "org_related_path": "lab__organization",
        "default_filter_kwargs": {"template__isnull": False},
    },
    "ExperimentTemplate": {
        "model": core.models.view_tables.ExperimentTemplate,
        "table_columns": [
            "Template Name",
            "Reagent Templates",
            "Vessel Templates",
            # "Action Templates",
            "Outcome Templates",
        ],
        "column_necessary_fields": {
            "Template Name": ["description"],
            "Reagent Templates": ["reagent_templates"],
            "Vessel Templates": ["vessel_templates"],
            # "Action Templates": ["action_templates"],
            "Outcome Templates": ["outcome_templates"],
        },
        "ordering": ["description"],
        "field_contains": "",
        "org_related_path": "lab__organization",
        # "default_filter_kwargs": {"template__isnull": False},
    },
}
