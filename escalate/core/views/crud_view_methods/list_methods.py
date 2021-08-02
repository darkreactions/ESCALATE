import core.models


methods = {
    'Actor': {
        'model': core.models.view_tables.Actor,
        'table_columns': ['Person', 'Organization', 'Systemtool', 'Status', ],
        'column_necessary_fields': {
            'Person': ['person.first_name', 'person.middle_name', 'person.last_name'],
            'Organization': ['organization.full_name'],
            'Systemtool': ['systemtool.systemtool_name'],
            'Status': ['status.description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },

    'Inventory': {
        'model': core.models.view_tables.Inventory,
        'table_columns': ['Description', 'Owner', 'Operator', 'Lab', 'Status'],
        'column_necessary_fields': {
            'Description': ['description'],
            'Owner': ['owner.description'],
            'Operator': ['operator.description'],
            'Lab': ['lab.description'],
            'Status': ['status.description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'Material': {
        'model': core.models.view_tables.Material,
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
        'table_columns': ['Name', 'Description', 'Systemtool Type', 'Vendor Organization', ],
        'column_necessary_fields': {
            'Name': ['systemtool_name'],
            'Description': ['description'],
            'Systemtool Type': ['systemtool_type.description'],
            'Vendor Organization': ['vendor_organization.full_name']
        },
        'ordering': ['systemtool_name'],
        'field_contains': ''
    },
    'MaterialType': {
        'model': core.models.view_tables.MaterialType,
        'table_columns': ['Description', ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'Organization': {
        'model': core.models.view_tables.Organization,
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
        'table_columns': ['Name', 'Address', 'Email', 'Organization', 'Added Organization'],
        'column_necessary_fields': {
            'Name': ['first_name', 'middle_name', 'last_name'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Email': ['email'],
            'Organization': ['organization.full_name'],
            'Added Organization': ['added_organization']
        },
        'ordering': ['first_name', 'middle_name', 'last_name'],
        'field_contains': ''
    },
    'Status': {
        'model': core.models.view_tables.Status,
        'table_columns': ['Description', ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'SystemtoolType': {
        'model': core.models.view_tables.SystemtoolType,
        'table_columns': ['Description', ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'Tag': {
        'model': core.models.view_tables.Tag,
        'table_columns': ['Name', 'Description', 'Tag Type', ],
        'column_necessary_fields': {
            'Name': ['display_text'],
            'Description': ['description'],
            'Tag Type': ['tag_type.type']
        },
        'ordering': ['display_text'],
        'field_contains': ''
    },
    'TagType': {
        'model': core.models.view_tables.TagType,
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
        'table_columns': ['Description', 'Value Type', ],
        'column_necessary_fields': {
            'Description': ['description'],
            'Value Type': ['val_type.category', 'val_type.description']
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
        'table_columns': ['Description', 'Inventory', 'Material', 'Amount On Hand', 'Expiration Date', 'Location', ],
        'column_necessary_fields': {
            'Description': ['description'],
            'Inventory': ['inventory.description'],
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
        'table_columns': ['Plate Name', 'Well Number', ],
        'column_necessary_fields': {
            'Plate Name': ['plate_name'],
            'Well Number': ['well_number'],
        },
        'ordering': ['plate_name'],
        'field_contains': ''
    },
    'Experiment': {
        'model': core.models.view_tables.Experiment,
        'table_columns': ['Description'],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': '',
        'org_related_path': 'lab__organization',
        'default_filter_kwargs': {
            'parent__isnull': False
        }
    }
}
