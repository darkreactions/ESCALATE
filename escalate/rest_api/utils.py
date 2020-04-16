import re


def camel_case(text):
    #data = re.findall(r'[A-Z](?:[a-z]+|[A-Z]*(?=[A-Z]|$))', text)
    # if data[0] == 'View':
    #    data[0] = 'vw'
    data = text.lower()
    if 'view' in data[:4]:
        data = data[4:]

    # return '_'.join(data).lower()
    return data


def camel_case_uuid(text):
    text = camel_case(text)
    # return '_'.join([text, 'uuid'])
    return text


view_names = ['Systemtool', 'SystemtoolType', 'Actor', 'Inventory', 'InventoryMaterial',
              'LatestSystemtool', 'Calculation', 'CalculationDef',
              'Material', 'MaterialDescriptor', 'MaterialRefnameType',
              'MaterialType', 'Note', 'Organization', 'Person',
              'Status', 'Tag', 'TagType']

custom_serializer_views = ['Edocument']
