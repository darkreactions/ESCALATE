import core.models


methods = {
    'Actor': {
        'model': core.models.Actor,
        'context_object_name': 'actors',
        'table_columns': ['Name', 'Organization', 'Systemtool', 'Status', 'Actions'],
        'column_necessary_fields': {
            'Name': ['person_first_name', 'person_last_name'],
            'Organization': ['org_full_name'],
            'Systemtool': ['systemtool_name'],
            'Status': ['status_description']
        },
        'order_field': 'description',
        'field_contains': '',
    },

    'Inventory': {
        'model': core.models.Inventory,
        'context_object_name': 'inventorys',
        'table_columns': ['Description', 'Status', 'Material', 'On Hand Amount', 'Actions'],
        'column_necessary_fields': {
            'Description': ['inventory_description'],
            'Status': ['status_description'],
            'Material': ['material_description'],
            'On Hand Amount': ['onhand_amt']
        },
        'order_field': 'inventory_description',
        'field_contains': '',
    },
    'Material': {
        'model': core.models.Material,
        'context_object_name': 'materials',
        'table_columns': ['Chemical Name', 'Abbreviation', 'Status', 'Actions'],
        'column_necessary_fields': {
            'Chemical Name': ['chemical_name'],
            'Abbreviation': ['abbreviation'],
            'Status': ['material_status_description']
        },
        'order_field': 'chemical_name',
        'field_contains': '',

    },
    'Systemtool': {
        'model': core.models.Systemtool,
        'context_object_name': 'systemtools',
        'table_columns': ['Name', 'Description',
                          'System Tool Type', 'Vendor Organization', 'Actions'],
        'column_necessary_fields': {
            'Name': ['systemtool_name'],
            'Description': ['description'],
            'System Tool Type': ['systemtool_type_uuid'],
            'Vendor Organization': ['vendor_organization_uuid']
        },
        'order_field': 'systemtool_name',
        'field_contains': '',
    },
    'MaterialType': {
        'model': core.models.MaterialType,
        'context_object_name': 'material_types',
        'table_columns': ['Description', 'Actions'],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'order_field': 'description',
        'field_contains': '',
    },
    'Organization': {
        'model': core.models.Organization,
        'context_object_name': 'organizations',
        'table_columns': ['Full Name', 'Address', 'Website', 'Actions'],
        'column_necessary_fields': {
            'Full Name': ['full_name'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Website': ['website_url']
        },
        'order_field': 'full_name',
        'field_contains': '',
    },
    'Person': {
        'model': core.models.Person,
        'context_object_name': 'persons',
        'table_columns': ['Name', 'Address', 'Title', 'Email', 'Actions'],
        'column_necessary_fields': {
            'Name': ['first_name', 'middle_name', 'last_name'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Title': ['title'],
            'Email': ['email']
        },
        'order_field': 'first_name',
        'field_contains': '',
    },
    'Status': {
        'model': core.models.Status,
        'context_object_name': 'statuss',
        'table_columns': ['Description', 'Actions'],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'order_field': 'description',
        'field_contains': '',
    },
    'SystemtoolType': {
        'model': core.models.SystemtoolType,
        'context_object_name': 'systemtool_types',
        'table_columns': ['Description', 'Actions'],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'order_field': 'description',
        'field_contains': '',
    },
    'Tag': {
        'model': core.models.Tag,
        'context_object_name': 'tags',
        'table_columns': ['Name', 'Description', 'Actor', 'Tag Type', 'Actions'],
        'column_necessary_fields': {
            'Name': ['display_text'],
            'Description': ['description'],
            'Actor': ['actor_description'],
            'Tag Type': ['tag_type_uuid']
        },
        'order_field': 'display_text',
        'field_contains': '',
    },
    'TagType': {
        'model': core.models.TagType,
        'context_object_name': 'tag_types',
        'table_columns': ['Short Description', 'Description', 'Actions'],
        'column_necessary_fields': {
            'Short Description': ['type'],
            'Description': ['description']
        },
        'order_field': 'type',
        'field_contains': '',
    },
    'UdfDef': {
        'model': core.models.UdfDef,
        'context_object_name': 'udf_defs',
        'table_columns': ['Description', 'Value Type', 'Actions'],
        'column_necessary_fields': {
            'Description': ['description'],
            'Value Type': ['val_type_description']
        },
        'order_field': 'description',
        'field_contains': '',
    },

}
