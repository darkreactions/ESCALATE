import core.models 

methods = {
    'Actor':{
        'model': core.models.view_tables.Actor,
        'column_names': [
            'First Name',
            'Last Name',
            'Person Organization',
            'Organization',
            'Systemtool',
            'Status'
            ],
        'column_necessary_fields': {
            'First Name': ['person.first_name'],
            'Last Name': ['person.last_name'],
            'Person Organization': ['person.organization.full_name'],
            'Organization': ['organization.full_name'],
            'Systemtool': ['systemtool.systemtool_name'],
            'Status': ['status.description']
        },
        'field_contains': '',
        'ordering': ['description']
    },
    'Inventory':{
        'model': core.models.view_tables.Inventory,
        'column_names': [
            'Description',
            'Owner',
            'Operator',
            'Lab',
            'Status'
            ],
        'column_necessary_fields': {
            'Description': ['description'],
            'Owner': ['owner.description'],
            'Operator': ['operator.description'],
            'Lab': ['lab.description'],
            'Status': ['status.description']
        },
        'field_contains': '',
        'ordering': ['description']
    },
    'Material':{
        'model': core.models.view_tables.Material,
        'column_names': [
            'Chemical Name',
            'Consumable',
            'Material Class',
            'Identifier',
            'Material Type',
            'Status'
            ],
        'column_necessary_fields': {
            'Chemical Name': ['description'],
            'Consumable': ['consumable'],
            'Material Class': ['material_class'],
            'Identifier': ['identifier'],
            'Material Type': ['material_type'],
            'Status': ['status.description']
        },
        'field_contains': '',
        'ordering': ['description']
    },
    'Systemtool':{
        'model': core.models.view_tables.Systemtool,
        'column_names': [
            'Name',
            'Description',
            'Vendor',
            'Type',
            'Model',
            'Serial',
            'Version'
            ],
        'column_necessary_fields': {
            'Name': ['systemtool_name'],
            'Description': ['description'],
            'Vendor': ['vendor_organization.full_name'],
            'Type': ['systemtool_type.description'],
            'Model': ['model'],
            'Serial': ['serial'],
            'Version': ['ver']
        },
        'field_contains': '',
        'ordering': ['systemtool_name']
    },
    'MaterialType':{
        'model': core.models.view_tables.MaterialType,
        'column_names': [
            'Description',
            ],
        'column_necessary_fields': {
            'Description': ['description']
        },
        'field_contains': '',
        'material_type': ['description']
    },
    'Organization':{
        'model': core.models.view_tables.Organization,
        'column_names': [
            'Name',
            'Description',
            'Address 1',
            'Address 2',
            'City',
            'State/Province',
            'Zipcode',
            'Country',
            'Website',
            'Phone',
            'Parent Organization'
            ],
        'column_necessary_fields': {
            'Name': ['full_name'],
            'Description': ['description'],
            'Address 1': ['address1'],
            'Address 2': ['address2'],
            'City': ['city'],
            'State/Province': ['state_province'],
            'Zipcode': ['zip'],
            'Country': ['country'],
            'Website': ['website_url'],
            'Phone': ['phone'],
            'Parent Organization': ['parent.full_name']
        },
        'field_contains': '',
        'ordering': ['full_name']
    },
    'Person':{
        'model': core.models.view_tables.Person,
        'column_names': [
            'First Name',
            'Middle Name',
            'Last Name',
            'Address 1',
            'Address 2',
            'City',
            'State/Province',
            'Zipcode',
            'Country',
            'Phone',
            'Email',
            'Title',
            'Organization',
            'Added Organization'
            ],
        'column_necessary_fields': {
            'First Name': ['first_name'],
            'Middle Name': ['middle_name'],
            'Last Name': ['last_name'],
            'Address 1': ['address1'],
            'Address 2': ['address2'],
            'City': ['city'],
            'State/Province': ['state_province'],
            'Zipcode': ['zip'],
            'Country': ['country'],
            'Phone': ['phone'],
            'Email': ['email'],
            'Title': ['title'],
            'Organization': ['organization.full_name'],
            'Added Organization': ['added_organization']
        },
        'field_contains': '',
        'ordering': ['first_name', 'middle_name', 'last_name']
    },
    'Status':{
        'model': core.models.view_tables.Status,
        'column_names': [
            'Description'
            ],
        'column_necessary_fields': {
            'Description': ['description'],
        },
        'field_contains': '',
        'ordering': ['description']
    },
    'SystemtoolType':{
        'model': core.models.view_tables.SystemtoolType,
        'column_names': [
            'Description',
            ],
        'column_necessary_fields': {
            'Description': ['description'],
        },
        'field_contains': '',
        'ordering': ['description']
    },
    'Tag':{
        'model': core.models.view_tables.Tag,
        'column_names': [
            'Display Text',
            'Description',
            'Tag Type',
            'Tag Type Description',
            ],
        'column_necessary_fields': {
            'Display Text': ['display_text'],
            'Description': ['description'],
            'Tag Type': ['type'],
            'Tag Type Description': ['type_description'],
        },
        'field_contains': '',
        'ordering': ['display_text']
    },
    'TagType':{
        'model': core.models.view_tables.TagType,
        'column_names': [
            'Type',
            'Description',
            ],
        'column_necessary_fields': {
            'Type': ['type'],
            'Description': ['description'],
        },
        'field_contains': '',
        'ordering': ['type']
    },
    'UdfDef':{
        'model': core.models.view_tables.UdfDef,
        'column_names': [
            'Description',
            'Value Type',
            'Value Type Description',
            'Unit'
            ],
        'column_necessary_fields': {
            'Description': ['description'],
            'Value Type': ['val_type'],
            'Value Type Description': ['val_type_description'],
            'Unit': ['unit']
        },
        'field_contains': '',
        'ordering': ['description']
    },
    'InventoryMaterial':{
        'model': core.models.view_tables.InventoryMaterial,
        'column_names': [
            'Description',
            'Inventory',
            'Material',
            'Part Number',
            'On Hand Amount',
            'Expiration Date',
            'Location',
            'Status'
            ],
        'column_necessary_fields': {
            'Description': ['description'],
            'Inventory': ['inventory.description'],
            'Material': ['material.description'],
            'Part Number': ['part_no'],
            'On Hand Amount': ['onhand_amt'],
            'Expiration Date': ['expiration_date'],
            'Location': ['location'],
            'Status': ['status.description']
        },
        'field_contains': '',
        'ordering': ['description'],
        'org_related_path': 'inventory__lab__organization'
    },
    'Vessel':{
        'model': core.models.view_tables.Vessel,
        'column_names': [
            'Plate Name',
            'Well Number',
            'Status'
            ],
        'column_necessary_fields': {
            'Plate Name': ['plate_name'],
            'Well Number': ['well_number'],
            'Status': ['status.description']
        },
        'field_contains': '',
        'ordering': ['plate_name']
    }, 
}