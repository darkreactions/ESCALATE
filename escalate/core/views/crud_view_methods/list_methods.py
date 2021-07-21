import core.models


methods = {
    'Actor': {
        'model': core.models.view_tables.Actor,
        'context_object_name': 'actors',
        'table_columns': ['Name', 'Organization', 'Systemtool', 'Status', ],
        'column_necessary_fields': {
            'Name': ['person.first_name', 'person.last_name'],
            'Organization': ['organization.full_name'],
            'Systemtool': ['systemtool.systemtool_name'],
            'Status': ['status.description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },

    'Inventory': {
        'model': core.models.view_tables.Inventory,
        'context_object_name': 'inventorys',
        'table_columns': ['Description', 'Owner', 'Operator', 'Lab', 'Status'],
        'column_necessary_fields': {
            'Description': ['description'],
            'Owner': ['owner'],
            'Operator': ['operator'],
            'Lab': ['lab'],
            'Status': ['status.description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'Material': {
        'model': core.models.view_tables.Material,
        'context_object_name': 'materials',
        'table_columns': ['Chemical Name', 'Other Names', 'Type', 'Status'],
        'column_necessary_fields': {
            'Chemical Name': ['description'],
            'Other Names': ['identifier'],
            'Type': ['material_type'],
            'Status': ['status.description']
        },
        'ordering': ['description'],
        'field_contains': ''

    },
    'Systemtool': {
        'model': core.models.view_tables.Systemtool,
        'context_object_name': 'systemtools',
        'table_columns': ['Name', 'Description', 'Systemtool Type', 'Vendor Organization', ],
        'column_necessary_fields': {
            'Name': ['systemtool_name'],
            'Description': ['description'],
            'Systemtool Type': ['systemtool_type'],
            'Vendor Organization': ['vendor_organization']
        },
        'ordering': ['systemtool_name'],
        'field_contains': ''
    },
    'MaterialType': {
        'model': core.models.view_tables.MaterialType,
        'context_object_name': 'material_types',
        'table_columns': ['Description', ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'Organization': {
        'model': core.models.view_tables.Organization,
        'context_object_name': 'organizations',
        'table_columns': ['Full Name', 'Address', 'Website', ],
        'column_necessary_fields': {
            'Full Name': ['full_name'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Website': ['website_url']
        },
        'ordering': ['full_name'],
        'field_contains': ''
    },
    'Person': {
        'model': core.models.view_tables.Person,
        'context_object_name': 'persons',
        'table_columns': ['Name', 'Address', 'Email', ],
        'column_necessary_fields': {
            'Name': ['first_name', 'middle_name', 'last_name'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Email': ['email']
        },
        'ordering': ['first_name', 'middle_name', 'last_name'],
        'field_contains': ''
    },
    'Status': {
        'model': core.models.view_tables.Status,
        'context_object_name': 'statuss',
        'table_columns': ['Description', ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'SystemtoolType': {
        'model': core.models.view_tables.SystemtoolType,
        'context_object_name': 'systemtool_types',
        'table_columns': ['Description', ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'Tag': {
        'model': core.models.view_tables.Tag,
        'context_object_name': 'tags',
        'table_columns': ['Name', 'Description', 'Actor', 'Tag Type', ],
        'column_necessary_fields': {
            'Name': ['display_text'],
            'Description': ['description'],
            'Actor': ['actor_description'],
            'Tag Type': ['tag_type']
        },
        'ordering': ['display_text'],
        'field_contains': ''
    },
    'TagType': {
        'model': core.models.view_tables.TagType,
        'context_object_name': 'tag_types',
        'table_columns': ['Type', 'Description', ],
        'column_necessary_fields': {
            'Type': ['type'],
            'Description': ['description']
        },
        'ordering': ['type'],
        'field_contains': ''
    },
    'UdfDef': {
        'model': core.models.view_tables.UdfDef,
        'context_object_name': 'udf_defs',
        'table_columns': ['Description', 'Value Type', ],
        'column_necessary_fields': {
            'Description': ['description'],
            'Value Type': ['val_type_description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    # 'Edocument': {
    #     'model': core.models.Edocument,
    #     'context_object_name': 'edocuments',
    #     'table_columns': ['Title', 'UUID', ],  # 'File Type' 'Version'
    #     'column_necessary_fields': {
    #         'Title': ['title'],
    #         # 'File Type':['doc_type_description'],
    #         'UUID': ['uuid'],
    #         # 'Version': ['doc_ver'],
    #     },
    #     'ordering': ['description'],
    #     'field_contains': '',
    # },
    'InventoryMaterial': {
        'model': core.models.view_tables.InventoryMaterial,
        'context_object_name': 'inventory_materials',

        'table_columns': ['Description', 'Material', 'Amount On Hand', 'Expiration Date', 'Location', ],
        'column_necessary_fields': {
            'Description': ['description'],
            'Material': ['material.description'],
            'Amount On Hand': ['onhand_amt'],
            'Expiration Date': ['expiration_date'],
            'Location': ['location'],
        },
        'ordering': ['description'],
        'field_contains': '',
        'org_related_path': 'inventory__lab__organization'
    },
    'Vessel': {
        'model': core.models.view_tables.Vessel,
        'context_object_name': 'vessels',

        'table_columns': ['Plate Name', 'Well Number', ],
        'column_necessary_fields': {
            'Plate Name': ['plate_name'],
            'Well Number': ['well_number'],
        },
        'ordering': ['plate_name'],
        'field_contains': ''
    },





}
