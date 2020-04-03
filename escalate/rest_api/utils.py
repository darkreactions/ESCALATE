import re


def camel_case(text):
    data = re.findall(r'[A-Z](?:[a-z]+|[A-Z]*(?=[A-Z]|$))', text)
    if data[0] == 'View':
        data[0] = 'vw'
    return '_'.join(data).lower()


def camel_case_uuid(text):
    text = camel_case(text)
    return '_'.join([text, 'uuid'])


# model_names = ['Person', 'Organization', 'Inventory',
#               'MDescriptor', 'MDescriptorClass', 'MDescriptorDef',
#               'MaterialType',
#               'Measure', 'MeasureType', 'Status', 'Systemtool',
#               'SystemtoolType', 'Tag', 'TagType']
model_names = ['Organization', 'Person',
               'Systemtool', 'SystemtoolType', 'ViewMaterialRaw']

view_names = ['ViewInventory', 'ViewActor',
              'Material', 'Actor', 'Status', 'ViewMaterial', 'ViewLatestSystemtool',
              'ViewLatestSystemtoolActor', 'ViewMDescriptorDef', 'MDescriptorDef',
              'ViewMDescriptor', 'MDescriptor', 'Note', 'ViewMaterialRefnameType',
              'ViewMaterialDescriptorRaw', 'ViewMaterialDescriptor', 'ViewInventoryMaterial',
              'ViewInventoryMaterialDescriptor', 'ViewMaterialRaw']
