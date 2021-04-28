import core.models


methods = {
    'Actor': {
        'model': core.models.view_tables.Actor,
        'context_object_name': 'actors',
        'table_columns': ['Name', 'Organization', 'Systemtool', 'Status', 'Actions'],
        'column_necessary_fields': {
            'Name': ['person_first_name', 'person_last_name'],
            'Organization': ['org_full_name'],
            'Systemtool': ['systemtool_name'],
            'Status': ['status_description']
        },
        'ordering': ['description'],
        'field_contains': '',
    },

    'Inventory': {
        'model': core.models.view_tables.Inventory,
        'context_object_name': 'inventorys',
        'table_columns': ['Description', 'Owner', 'Operator', 'Lab', 'Status', 'Actor'],
        'column_necessary_fields': {
            'Description': ['description'],
            'Owner': ['owner'],
            'Operator': ['operator'],
            'Lab': ['lab'],
            'Status': ['status_description'],
            'Actor': ['actor']
        },
        'ordering': ['description'],
        'field_contains': '',
    },
    'Material': {
        'model': core.models.view_tables.Material,
        'context_object_name': 'materials',
        'table_columns': ['Chemical Name', 'Consumable', 'Composite', 'Actions'],
        # 'table_columns': ['Status', 'Actions'],
        'column_necessary_fields': {
            'Chemical Name': ['description'],
            'Consumable': ['consumable'],
            'Composite': ['composite_flg'],
            'Status': ['status_description']
        },
        'ordering': ['status_description'],
        'field_contains': '',

    },
    'Systemtool': {
        'model': core.models.view_tables.Systemtool,
        'context_object_name': 'systemtools',
        'table_columns': ['Name', 'Description',
                          'System Tool Type', 'Vendor Organization', 'Actions'],
        'column_necessary_fields': {
            'Name': ['systemtool_name'],
            'Description': ['description'],
            'System Tool Type': ['systemtool_type'],
            'Vendor Organization': ['vendor_organization']
        },
        'ordering': ['systemtool_name'],
        'field_contains': '',
    },
    'MaterialType': {
        'model': core.models.view_tables.MaterialType,
        'context_object_name': 'material_types',
        'table_columns': ['Description', 'Actions'],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': '',
    },
    'Organization': {
        'model': core.models.view_tables.Organization,
        'context_object_name': 'organizations',
        'table_columns': ['Full Name', 'Address', 'Website', 'Actions'],
        'column_necessary_fields': {
            'Full Name': ['full_name'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Website': ['website_url']
        },
        'ordering': ['full_name'],
        'field_contains': '',
    },
    'Person': {
        'model': core.models.view_tables.Person,
        'context_object_name': 'persons',
        'table_columns': ['Name', 'Address', 'Title', 'Email', 'Actions'],
        'column_necessary_fields': {
            'Name': ['first_name', 'middle_name', 'last_name'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Title': ['title'],
            'Email': ['email']
        },
        'ordering': ['first_name'],
        'field_contains': '',
    },
    'Status': {
        'model': core.models.view_tables.Status,
        'context_object_name': 'statuss',
        'table_columns': ['Description', 'Actions'],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': '',
    },
    'SystemtoolType': {
        'model': core.models.view_tables.SystemtoolType,
        'context_object_name': 'systemtool_types',
        'table_columns': ['Description', 'Actions'],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': '',
    },
    'Tag': {
        'model': core.models.view_tables.Tag,
        'context_object_name': 'tags',
        'table_columns': ['Name', 'Description', 'Actor', 'Tag Type', 'Actions'],
        'column_necessary_fields': {
            'Name': ['display_text'],
            'Description': ['description'],
            'Actor': ['actor_description'],
            'Tag Type': ['tag_type']
        },
        'ordering': ['display_text'],
        'field_contains': '',
    },
    'TagType': {
        'model': core.models.view_tables.TagType,
        'context_object_name': 'tag_types',
        'table_columns': ['Short Description', 'Description', 'Actions'],
        'column_necessary_fields': {
            'Short Description': ['type'],
            'Description': ['description']
        },
        'ordering': ['type'],
        'field_contains': '',
    },
    'UdfDef': {
        'model': core.models.view_tables.UdfDef,
        'context_object_name': 'udf_defs',
        'table_columns': ['Description', 'Value Type', 'Actions'],
        'column_necessary_fields': {
            'Description': ['description'],
            'Value Type': ['val_type_description']
        },
        'ordering': ['description'],
        'field_contains': '',
    },
    'InventoryMaterial': {
        'model': core.models.view_tables.InventoryMaterial,
        'context_object_name': 'inventory_materials',

        'table_columns': ['Description', 'Material','Amount On Hand', 'Expiration Date', 'Location', 'Composite', 'Consumable', 'Actions'],
        'column_necessary_fields': {
            'Description': ['description'], 
            'Material': ['material_description'], 
            'Composite': ['material_composite_flg'], 
            'Consumable': ['material_consumable'], 
            'Amount On Hand': ['onhand_amt'], 
            'Expiration Date': ['expiration_date'], 
            'Location': ['location'],
        },
        'ordering': ['description'],
        'field_contains': '',
        'org_related_path': 'inventory__lab__organization'
    },
    



}
