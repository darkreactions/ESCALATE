import core.models


methods = {
    'Actor': {
        'model': core.models.view_tables.Actor,
        'column_names': [
            'Person First Name',
            'Person Middle Name',
            'Person Last Name',
            'Organization',
            'Systemtool',
            'Status', ],
        'column_necessary_fields': {
            'Person First Name': ['person.first_name'],
            'Person Middle Name': ['person.middle_name'],
            'Person Last Name': ['person.last_name'],
            'Organization': ['organization.full_name'],
            'Systemtool': ['systemtool.systemtool_name'],
            'Status': ['status.description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },

    'Inventory': {
        'model': core.models.view_tables.Inventory,
        'column_names': ['Description', 'Owner', 'Operator', 'Lab', 'Status'],
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
        'column_names': ['Chemical Name', 'Other Names', 'Type', 'Status'],
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
        'column_names': ['Name', 'Description', 'Systemtool Type', 'Vendor Organization', ],
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
        'column_names': ['Description', ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'Organization': {
        'model': core.models.view_tables.Organization,
        'column_names': [
            'Full Name',
            'Short Name',
            'Address1',
            'Address2',
            'Zip',
            'City',
            'State/Province',
            'Country'
            'Website',
            'Parent Organization'    
        ],
        'column_necessary_fields': {
            'Full Name': ['full_name'],
            'Short Name': ['short_name'],
            'Address1': ['address1'],
            'Address2': ['address2'],
            'Zip': ['zip'],
            'City': ['city'],
            'State/Province': ['state_province'],
            'Country': ['country'],
            'Website': ['website_url'],
            'Parent Organization': ['parent.full_name']
        },
        'ordering': ['full_name'],
        'field_contains': ''
    },
    'Person': {
        'model': core.models.view_tables.Person,
        'column_names': [
            'First Name',
            'Middle Name',
            'Last Name',
            'Address1',
            'Address2',
            'Zip',
            'City',
            'State/Province',
            'Country',
            'Email',
            'Title',
            'Suffix',
            'Organization',
            'Added Organization'
        ],
        'column_necessary_fields': {
            'First Name': ['first_name'],
            'Middle Name': ['middle_name'],
            'Last Name': ['Last Name'],
            'Address1': ['address1'],
            'Address2': ['address2'],
            'Zip': ['zip'],
            'City': ['city'],
            'State/Province': ['state_province'],
            'Country': ['country'],
            'Email': ['email'],
            'Title': ['title'],
            'Suffix': ['suffix'],
            'Organization': ['organization.full_name'],
            'Added Organization': ['added_organization']
        },
        'ordering': ['first_name', 'middle_name', 'last_name'],
        'field_contains': ''
    },
    'Status': {
        'model': core.models.view_tables.Status,
        'column_names': ['Description', ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'SystemtoolType': {
        'model': core.models.view_tables.SystemtoolType,
        'column_names': ['Description', ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'ordering': ['description'],
        'field_contains': ''
    },
    'Tag': {
        'model': core.models.view_tables.Tag,
        'column_names': ['Name', 'Description', 'Tag Type', ],
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
        'column_names': ['Type', 'Description', ],
        'column_necessary_fields': {
            'Type': ['type'],
            'Description': ['description']
        },
        'ordering': ['type'],
        'field_contains': ''
    },
    'UdfDef': {
        'model': core.models.view_tables.UdfDef,
        'column_names': ['Description', 'Value Type', ],
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
    #     'column_names': ['Title', 'UUID', ],  # 'File Type' 'Version'
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
        'column_names': ['Description', 'Inventory', 'Material', 'Amount On Hand', 'Expiration Date', 'Location', ],
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
        'column_names': ['Plate Name', 'Well Number', ],
        'column_necessary_fields': {
            'Plate Name': ['plate_name'],
            'Well Number': ['well_number'],
        },
        'ordering': ['plate_name'],
        'field_contains': ''
    },
}
