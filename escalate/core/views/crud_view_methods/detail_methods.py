import core.models

methods = {
    "Material": {
        "model": core.models.view_tables.Material,
        "detail_fields": [
            "Chemical Name",
            "Identifiers",
            "Properties",
            "Material Type",
            "Status",
        ],
        "detail_fields_need_fields": {
            "Chemical Name": ["description"],
            "Identifiers": ["identifier"],
            "Properties": ["property_m"],
            "Material Type": ["material_type"],
            "Status": ["status.description"],
        },
    },
    "Systemtool": {
        "model": core.models.view_tables.Systemtool,
        "detail_fields": [
            "Systemtool Name",
            "Systemtool Description",
            "Systemtool Type",
            "Systemtool Vendor",
            "Systemtool Model",
            "Systemtool Serial",
            "Systemtool Version",
        ],
        "detail_fields_need_fields": {
            "Systemtool Name": ["systemtool_name"],
            "Systemtool Description": ["description"],
            "Systemtool Type": ["systemtool_type.description"],
            "Systemtool Vendor": ["vendor_organization.full_name"],
            "Systemtool Model": ["model"],
            "Systemtool Serial": ["serial"],
            "Systemtool Version": ["ver"],
        },
    },
    "MaterialType": {
        "model": core.models.view_tables.MaterialType,
        "detail_fields": ["Description", "Add Date", "Last Modification Date"],
        "detail_fields_need_fields": {
            "Description": ["description"],
            "Add Date": ["add_date"],
            "Last Modification Date": ["mod_date"],
        },
    },
    "MaterialIdentifier": {
        "model": core.models.view_tables.MaterialIdentifier,
        "detail_fields": ["Description", "Identifier Type"],
        "detail_fields_need_fields": {
            "Description": ["description"],
            "Identifier Type": ["full_description"],
        },
    },
    "Organization": {
        "model": core.models.view_tables.Organization,
        "detail_fields": [
            "Full Name",
            "Short Name",
            "Description",
            "Address",
            "Website",
            "Phone",
            "Parent Organization",
            "Add Date",
            "Last Modification Date",
        ],
        "detail_fields_need_fields": {
            "Full Name": ["full_name"],
            "Short Name": ["short_name"],
            "Description": ["description"],
            "Address": [
                "address1",
                "address2",
                "zip",
                "city",
                "state_province",
                "country",
            ],
            "Website": ["website_url"],
            "Phone": ["phone"],
            "Parent Organization": ["parent.full_name"],
            "Add Date": ["add_date"],
            "Last Modification Date": ["mod_date"],
        },
    },
    "Status": {
        "model": core.models.view_tables.Status,
        "detail_fields": ["Description", "Add Date", "Last Modification Date"],
        "detail_fields_need_fields": {
            "Description": ["description"],
            "Add Date": ["add_date"],
            "Last Modification Date": ["mod_date"],
        },
    },
    "Tag": {
        "model": core.models.view_tables.Tag,
        "detail_fields": [
            "Tag Name",
            "Description",
            "Add Date",
            "Last Modification Date",
            "Tag Type",
        ],
        "detail_fields_need_fields": {
            "Tag Name": ["display_text"],
            "Description": ["description"],
            "Add Date": ["add_date"],
            "Last Modification Date": ["mod_date"],
            "Tag Type": ["tag_type.type"],
        },
    },
    "InventoryMaterial": {
        "model": core.models.view_tables.InventoryMaterial,
        "detail_fields": [
            "Description",
            "Inventory",
            "Material",
            "Part Number",
            "Phase",
            "On hand amount",
            "Expiration Date",
            "Inventory Location",
            "Status",
        ],
        "detail_fields_need_fields": {
            "Description": ["description"],
            "Inventory": ["inventory.description"],
            "Material": ["material"],
            "Part Number": ["part_no"],
            "Phase": ["phase"],
            "On hand amount": ["onhand_amt"],
            "Expiration Date": ["expiration_date"],
            "Inventory Location": ["location"],
            "Status": ["status.description"],
        },
    },
    "Vessel": {
        "model": core.models.view_tables.Vessel,
        "detail_fields": [
            "Description",
            "Parent",
            "Total Volume",
            "Well Count"
            "Status",
        ],
        "detail_fields_need_fields": {
            "Description": ["description"],
            "Parent": ["parent.description"],
            "Total Volume": ["total_volume"],
            "Well Count": ["well_number"],
            "Status": ["status.description"],
        },
    },
    "ActionDef": {
        "model": core.models.view_tables.ActionDef,
        "detail_fields": [
            "Description",
            "Parameters",
        ],
        "detail_fields_need_fields": {
            "Description": ["description"],
            "Parameters": ["parameter_def"],
        },
    },
    "ParameterDef": {
        "model": core.models.view_tables.ParameterDef,
        "detail_fields": [
            "Description",
            "Default Value",
            "Unit Type",
        ],
        "detail_fields_need_fields": {
            "Description": ["description"],
            "Default Value": ["default_val"],
            "Unit Type": ["unit_type"],
        },
    },
    "PropertyTemplate": {
        "model": core.models.view_tables.PropertyTemplate,
        "detail_fields": [
            "Description",
        ],
        "detail_fields_need_fields": {
            "Description": ["description"],
        },
    },
    "ExperimentTemplate": {
        "model": core.models.view_tables.ExperimentTemplate,
        "detail_fields": [
            "Description",
            "Reagent Templates",
            "Outcome Templates",
            "Action Templates",
            "Vessel Templates",
        ],
        "detail_fields_need_fields": {
            "Description": ["description"],
            "Reagent Templates": ["reagent_templates"],
            "Outcome Templates": ["outcome_templates"],
            "Action Templates": ["action_templates"],
            "Vessel Templates": ["vessel_templates"],
        },
    },
}
