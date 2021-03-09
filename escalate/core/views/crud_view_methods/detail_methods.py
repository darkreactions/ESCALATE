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
            'Status': ['status_description'],
            'Organization': ['org_full_name'],
            'Person': ['person_first_name', 'person_last_name'],
            'Person Organization': ['person_org'],
            'Systemtool': ['systemtool_name'],
            'Systemtool description': ['systemtool_description'],
            'Systemtool type': ['systemtool_type'],
            'Systemtool vendor': ['systemtool_vendor'],
            'Systemtool model': ['systemtool_model'],
            'Systemtool serial': ['systemtool_serial'],
            'Systemtool version': ['systemtool_version']
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
            'Status': ['status'],
            'Actor': ['actor']
        },
    },
    'Material': {
        'model': core.models.view_tables.Material,
        'model_name': 'material',
        # 'detail_fields': ['Chemical Name', 'Abbreviation', 'Molecular Formula', 'InChI',
        #                  'InChI Key', 'Smiles', 'Create Date', 'Status'],
        'detail_fields': ['Create Date', 'Status'],
        'detail_fields_need_fields': {
            # 'Chemical Name': ['chemical_name'],
            # 'Abbreviation': ['abbreviation'],
            # 'Molecular Formula': ['molecular_formula'],
            # 'InChI': ['inchi'],
            # 'InChI Key': ['inchikey'],
            # 'Smiles': ['smiles'],
            'Create Date': ['add_date'],
            'Status': ['status_description']
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
            'Systemtool Type': ['systemtool_type_description'],
            'Systemtool Vendor': ['organization_fullname'],
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
            'Parent Organization': ['parent_org_full_name'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'Person': {
        'model': core.models.view_tables.Person,
        'model_name': 'person',
        'detail_fields': ['Full Name', 'Address', 'Phone', 'Email', 'Title',
                          'Suffix', 'Organization', 'Add Date', 'Last Modification Date'],
        'detail_fields_need_fields': {
            'Full Name': ['first_name', 'middle_name', 'last_name'],
            'Address': ['address1', 'address2', 'zip', 'city', 'state_province', 'country'],
            'Phone': ['phone'],
            'Email': ['email'],
            'Title': ['title'],
            'Suffix': ['suffix'],
            'Organization': ['organization_full_name'],
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
        'detail_fields': ['Tag Name', 'Description', 'Actor', 'Add Date', 'Last Modification Date',
                        #   'Tag Type', 
                          'Tag Type Description'],
        'detail_fields_need_fields': {
            'Tag Name': ['display_text'],
            'Description': ['description'],
            'Actor': ['description'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date'],
            'Tag Type': ['type'],
            'Tag Type Description': ['type_description']
        },
    },
    'TagType': {
        'model': core.models.view_tables.TagType,
        'model_name': 'tag_type',
        'detail_fields': ['Type', 'Long Description', 'Add Date',
                          'Last Modification Date'],
        'detail_fields_need_fields': {
            'Short Description': ['type'],
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
        'detail_fields': ['Title', 'Description', 'Source', 'Document Type', 'Status',
                          'Add Date', 'Last Modification Date'],
        'detail_fields_need_fields': {
            'Title':['title'],
            'Description': ['description'],
            'Source':['source'],
            'Document Type':['doc_type_description'],
            'Status': ['status_description'],
            'Add Date': ['add_date'],
            'Last Modification Date': ['mod_date']
        },
    },
    'InventoryMaterial': {
        'model': core.models.view_tables.InventoryMaterial,
        'model_name': 'inventory_material',
        'detail_fields': ['Description', 'Inventory', 'Material', 
                            'Consumable', 'Composite Material', 
                            'Part Number', 'On hand amount', 'Expiration Date',
                            'Inventory Location', 'Status',],
        'detail_fields_need_fields': {
            'Description': ['description'],
            'Material' : ['material'],
            'Actor': ['actor'],
            'Part Number' : ['part_no'],
            'On hand amount' : ['onhand_amt'],
            'Expiration Date': ['expiration_date'],
            'Inventory Location' : ['location'],
            'Consumable': ['material_consumable'],
            'Composite Material': ['material_composite_flg'],
            'Inventory': ['inventory'],
            'Status': ['status']
        },
    },

}
