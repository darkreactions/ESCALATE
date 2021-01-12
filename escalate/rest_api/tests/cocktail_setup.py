# %%
import requests
import json
import timeit
base_url = 'http://localhost:8000/api'

login_data = {
    'username': 'vshekar',
    'password': 'copperhead123'
}
r_login = requests.post(f'{base_url}/login', data=login_data)
token = r_login.json()['token']
token_header = {'Authorization': f'Token {token}',
                'content-type': 'application/json'}

# %%

# Insert org
org_data = {
    'description': 'Schrierwirtshaus',
    'full_name': 'Schrierwirtshaus GmbH',
    'short_name': 'SWH',
    'address': '100 Fancy Apartment Ave',
    'city': 'New York', 
    'state_province': 'NY',
    'zip': '99999',
}
r_org = requests.post(f'{base_url}/organization/', 
                      data=json.dumps(org_data), 
                      headers=token_header)

print(r_org.json())

# %%
person_data = {
    'last_name': 'Schrier',
    'first_name': 'Joshua',
    'address1': '100 Fancy Apartment Ave',
    'city': 'New York',
    'state_province': 'NY',
    'zip': '99999'
}
r_person = requests.post(f'{base_url}/person/', 
                         data=json.dumps(person_data),
                         headers=token_header)
print(r_person)
actor = r_person.json()

# %%
actor = requests.get(f'{base_url}/actor/?person__first_name=Joshua&person__last_name=Schrier&organization__isnull=True').json()['results'][0]
print(actor)

# %%
material_types = [
    {'description': 'stock solution'},
    {'description': 'human prepared'},
    {'description': 'solute'},
]
r_material_types = {}
for material_type in material_types:
    r = requests.post(f'{base_url}/materialtype/',
                        data=json.dumps(material_type),
                        headers=token_header)
    r_material_types[material_type['description']] = r.json()
print(r_material_types)

# %%
for mat_type in material_types:
    url = requests.utils.requote_uri(f'{base_url}/materialtype/?description={mat_type["description"]}')
    r = requests.get(url).json()['results'][0]
    r_material_types[mat_type['description']] = r

print(r_material_types)

# %%
dev_test_status = requests.get(f'{base_url}/status/?description=dev_test').json()['results'][0]
material_fields = ['description', 'consumable', 'actor_uuid', 'status_uuid']
materials = [
    ['Cocktail Shaker', False, actor['uuid'], dev_test_status['uuid']],
    ['Highball Glass', False, actor['uuid'], dev_test_status['uuid']],
    ['Lime Slice', True, actor['uuid'], dev_test_status['uuid']],
    ['Lime Juice', True, actor['uuid'], dev_test_status['uuid']],
    ['Mint Leaf', True, actor['uuid'], dev_test_status['uuid']],
    ['White Rum', True, actor['uuid'], dev_test_status['uuid']],
    ['Granulated Sugar', True, actor['uuid'], dev_test_status['uuid']],
    ['Simple Syrup', True, actor['uuid'], dev_test_status['uuid']],
    ['Ice Cube', True, actor['uuid'], dev_test_status['uuid']],
    ['Club Soda', True, actor['uuid'], dev_test_status['uuid']],
]
r_materials = {}
for mat in materials:
    material = dict(zip(material_fields, mat))
    r = requests.post(f'{base_url}/material/',
                        data=json.dumps(material),
                        headers=token_header).json()
    r_materials[r['description']] = r
print(r_materials)

# %%

water = requests.get(f'{base_url}/material/?description=Water').json()['results'][0]
print(water)

# %%
# -- add the components to the composite
"""
{
    "composite_flg": false,
    "addressable": false,
    "composite": 'e0cf5a2b-e8cc-4398-a464-b24c073ef809',
    "component": '39fdb157-e969-4f1d-9dbc-b7943d113aca',
    "actor": '6f4c6ff8-a1f4-4cda-b05e-42e7011e45e7',
    "status": '33f0aa7c-a92f-4564-b306-fcdcbbc7000a'
}
"""

material_composite_fields = ['composite', 'component', 'addressable',
                             'actor', 'status']
material_composites = [
    [r_materials['Simple Syrup']['url'], r_materials['Granulated Sugar']['url'], False, actor['url'], dev_test_status['url']],
    [r_materials['Simple Syrup']['url'], water['url'], False, actor['url'], dev_test_status['url']]
]

r_material_composites = {}
for mat in material_composites:
    material_composite = dict(zip(material_composite_fields, mat))
    print(json.dumps(material_composite))
    r = requests.post(f'{base_url}/compositematerial/',
                    data=json.dumps(material_composite),
                    headers=token_header).json()
    r = requests.get(r['url']).json()
    r_material_composites[(r['composite_description'], r['component_description'])] = r
print(r_material_composites)

# %%
# -- add material_type to materials
print(r_material_composites.keys())
solute_type = requests.get(f'{base_url}/materialtype/?description=solute').json()['results'][0]
solvent_type = requests.get(f'{base_url}/materialtype/?description=solvent').json()['results'][0]
material_type_assign_fields = ['material', 'material_type']
material_type_assign = [
    [r_materials['Simple Syrup']['url'], r_material_types['stock solution']['url']],
    [r_materials['Simple Syrup']['url'], r_material_types['human prepared']['url']],
    [r_material_composites[('Simple Syrup', 'Granulated Sugar')]['url'], solute_type['url']],
    [r_material_composites[('Simple Syrup', 'Water')]['url'], solvent_type['url']],
]
#r_material_type_assign = {}
for mat_type in material_type_assign:
    mat_type_assign = dict(zip(material_type_assign_fields, mat_type))
    r = requests.post(f'{base_url}/materialtypeassign/',
                    data=json.dumps(mat_type_assign),
                    headers=token_header).json()

# %%
# -- add component properties
conc_def = requests.get(f'{base_url}/propertydef/?short_description=concentration').json()['results'][0]

material_property_data = {
    'material': r_material_composites[('Simple Syrup', 'Granulated Sugar')]['url'],
    'property_def': conc_def['url'],
    'value': {
                'value': 1,
                'unit': "vol/vol",
                'type': "int"
            },
    'actor': actor['url'],
    'status': dev_test_status['url']
}
print(material_property_data)
r_material_property = requests.post(f'{base_url}/materialproperty/',
                    data=json.dumps(material_property_data),
                    headers=token_header).json()

# %%
