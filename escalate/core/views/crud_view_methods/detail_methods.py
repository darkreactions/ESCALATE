import core.models

methods = {
    'Actor': {
        'model': core.models.view_tables.Actor,
        'model_name': 'actor',
        'detail_fields': ['Actor Description', 'Status', 'Organization', 'Person', 'Person Organization',
                          'Systemtool', 'Systemtool description', 'Systemtool type', 'Systemtool vendor',
                          'Systemtool model', 'Systemtool serial', 'Systemtool version'],
        'detail_fields_need_fields': {
            'Actor Description': ['description'],
            'Status': ['status.description'],
            'Organization': ['organization.full_name'],
            'Person': ['person.first_name', 'person.last_name'],
            'Person Organization': ['person.organization.full_name'],
            'Systemtool': ['systemtool.systemtool_name'],
            'Systemtool description': ['systemtool.description'],
            'Systemtool type': ['systemtool.systemtool_type.description'],
            'Systemtool vendor': ['systemtool.vendor_organization.full_name'],
            'Systemtool model': ['systemtool.model'],
            'Systemtool serial': ['systemtool.serial'],
            'Systemtool version': ['systemtool.ver']
        },
    },
    'Inventory': {
        'model': core.models.view_tables.Inventory,
        'model_name': 'inventory',
        'detail_fields': ['Description', 'Owner', 'Operator', 'Lab', 'Status', 'Actor'],
        'detail_fields_need_fields': {
            'Description': ['description'],
            'Owner': ['owner'],
            'Operator': ['operator'],
            'Lab': ['lab'],
            'Status': ['status.description'],
            'Actor': ['actor']
        },
    },
    'Material': {
        'model': core.models.view_tables.Material,
        'model_name': 'material',
        'detail_fields': ['Chemical Name', 'Other Names', 'Type', 'Material Class','Create Date', 'Last Modification Date', 'Status'],
        # 'detail_fields': ['Create Date', 'Status'],
        'detail_fields_need_fields': {
            'Chemical Name': ['description'],
            'Other Names': ['identifier'],
            'Type': ['material_type'],
            'Material Class': ['material_class'],
            'Create Date': ['add_date'],
            'Last Modification Date': ['mod_date'],
            'Status': ['status.description']
        },
    },
    'Systemtool': {
        'model': core.models.view_tables.Systemtool,
        'model_name': 'systemtool',
        'detail_fields': ['Systemtool Name', 'Systemtool Description', 'Systemtool Type',
                          'Systemtool Vendor', 'Systemtool Model', 'Systemtool Serial',
                          'Systemtool Version'],
        'detail_fields_need_fields': {
            'Systemtool Name': ['systemtool_name'],
            'Systemtool Description': ['description'],
            'Systemtool Type': ['systemtool_type.description'],
            'Systemtool Vendor': ['vendor_organization.full_name'],
            'Systemtool Model': ['model'],
            'Systemtool Serial': ['serial'],
            'Systemtool Version': ['ver']
        },
    },
    'MaterialType': {
        'model': core.models.view_tables.MaterialType,
        'model_name': 'material_type',
        'detail_fields': ['Description', 'Add Date', 'Last Modification Date'],
        'detail_fields_need_fields': {
            'Description': ['description'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'Organization': {
        'model': core.models.view_tables.Organization,
        'model_name': 'organization',
        'detail_fields': ['Full Name', 'Short Name', 'Description', 'Address', 'Website',
                          'Phone', 'Parent Organization', 'Add Date', 'Last Modification Date'],
        'detail_fields_need_fields': {
            'Full Name': ['full_name'],
            'Short Name': ['short_name'],
            'Description': ['description'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Website': ['website_url'],
            'Phone': ['phone'],
            'Parent Organization': ['parent.full_name'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'Person': {
        'model': core.models.view_tables.Person,
        'model_name': 'person',
        'detail_fields': ['Full Name', 'Address', 'Phone', 'Email', 'Title',
                          'Suffix', 'Organization', 'Added Organization', 'Add Date', 'Last Modification Date'],
        'detail_fields_need_fields': {
            'Full Name': ['first_name', 'middle_name', 'last_name'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Phone': ['phone'],
            'Email': ['email'],
            'Title': ['title'],
            'Suffix': ['suffix'],
            'Organization': ['organization.full_name'],
            'Added Organization': ['added_organization'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'Status': {
        'model': core.models.view_tables.Status,
        'model_name': 'status',
        'detail_fields': ['Description', 'Add Date', 'Last Modification Date'],
        'detail_fields_need_fields': {
            'Description': ['description'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'SystemtoolType': {
        'model': core.models.view_tables.SystemtoolType,
        'model_name': 'systemtool_type',
        'detail_fields': ['Description', 'Add Date', 'Last Modification Date'],
        'detail_fields_need_fields': {
            'Description': ['description'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'Tag': {
        'model': core.models.view_tables.Tag,
        'model_name': 'tag',
        'detail_fields': ['Tag Name', 'Description', 'Add Date', 'Last Modification Date',
                          'Tag Type'],
        'detail_fields_need_fields': {
            'Tag Name': ['display_text'],
            'Description': ['description'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date'],
            'Tag Type': ['tag_type.type']
        },
    },
    'TagType': {
        'model': core.models.view_tables.TagType,
        'model_name': 'tag_type',
        'detail_fields': ['Type', 'Long Description', 'Add Date',
                          'Last Modification Date'],
        'detail_fields_need_fields': {
            'Type': ['type'],
            'Long Description': ['description'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'UdfDef': {
        'model': core.models.view_tables.UdfDef,
        'model_name': 'udf_def',
        'detail_fields': ['Description', 'Value Type',
                          'Add Date', 'Last Modification Date'],
        'detail_fields_need_fields': {
            'Description': ['description'],
            'Value Type': ['val_type_description'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'Edocument':{
        'model': core.models.Edocument,
        'model_name': 'edocument',
        'detail_fields': ['Title', 'Description', 'Source', 'Status', #, 'Document Type'
                          'Add Date', 'Last Modification Date'],
        'detail_fields_need_fields': {
            'Title':['title'],
            'Description': ['description'],
            'Source':['source'],
            # 'Document Type':['doc_type_description'],
            'Status': ['status_description'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'InventoryMaterial': {
        'model': core.models.view_tables.InventoryMaterial,
        'model_name': 'inventory_material',
        'detail_fields': ['Description', 'Inventory', 'Material', 
                            'Part Number', 'On hand amount', 'Expiration Date',
                            'Inventory Location', 'Status',],
        'detail_fields_need_fields': {
            'Description': ['description'],
            'Inventory': ['inventory.description'],
            'Material' : ['material'],
            'Part Number' : ['part_no'],
            'On hand amount' : ['onhand_amt'],
            'Expiration Date': ['expiration_date'],
            'Inventory Location' : ['location'],
            'Status': ['status.description']
        },
    },
    'Experiment': {
        'model': core.models.view_tables.Experiment,
        'model_name': 'experiment',
        'detail_fields': ['Description', 'Status',],
        'detail_fields_need_fields': {
            'Description': ['description'],
            'Status': ['status.description']
        },
    },
    'Vessel': {
        'model': core.models.view_tables.Vessel,
        'model_name': 'vessel',
        'detail_fields': ['Plate Name', 'Well Number', 'Status', 'Date Added','Last Modified'],
        'detail_fields_need_fields': {
            'Plate Name': ['plate_name'],
            'Well Number': ['well_number'],
            'Status': ['status.description'],
            'Date Added': ['add_date'],
            'Last Modified': ['mod_date'],
        },
    },

}
