"""
Tables/Entities to update
- material_type
For each material (eg. Plate, chemical etc.) do
- property_def
- material
- material_property

For composite materials do
- vw_material
- vw_material_composite
- vw_material_type_assign
- vw_material_property

Put all the above into vw_inventory_material

For actions
- vw_calculation_def
- vw_parameter_def
- vw_action_def
- vw_action_parameter_def_assign

For calculations
- vw_parameter_def
- vw_calculation_def
- vw_calculation_parameter_def
- vw_calculation

For experiment
- vw_experiment
- vw_bom
- vw_bom_material

For workflow
- vw_workflow
- vw_experiment_workflow
- vw_workflow_action_set
- vw_action

"""

# %%
import requests
import json
import timeit

from requests.api import post
base_url = 'http://localhost:8000/api'

login_data = {
    'username': 'vshekar',
    'password': 'copperhead123'
}
r_login = requests.post(f'{base_url}/login', data=login_data)
token = r_login.json()['token']
token_header = {'Authorization': f'Token {token}',
                'content-type': 'application/json'}

def post_data(url_path, data, headers):
    r = requests.post(f'{base_url}/{url_path}/', 
                      data=json.dumps(data), 
                      headers=headers)
    print(r.json())
    return r.json()

def get_data(url_path, data, headers, all=False):
    resp = requests.get(f'{base_url}/{url_path}/', params=data, headers=headers)
    print(resp)
    if all:
        return resp.json()['results']
    return resp.json()['results'][0]

actor = get_data('actor',{'organization__isnull':True, 'description__contains': 'Shekar'}, headers=token_header)
print(actor)
test_status = get_data('status', {'description':'test'}, headers=token_header)
print(test_status)

# %%
## 96 well plate
data = {
    'description': 'Plate: 96 well',
    'consumable': False,
    'actor': actor['url'],
    'status': test_status['url']
}
r_plate96 = post_data('material', data=data, headers=token_header)

# %%
plate_96 = get_data('material', data={'description': 'Plate: 96 well',}, headers=token_header)
print(plate_96)
# %%
well_loc_prop_def = get_data('propertydef', {'short_description': 'well_loc'}, headers=token_header)
well_vol_prop_def = get_data('propertydef', {'short_description': 'well_vol'}, headers=token_header)
well_ord_prop_def = get_data('propertydef', {'short_description': 'well_ord'}, headers=token_header)
# %%
from itertools import product
letters = 'ABCDEFGH'
numbers = [1,2,3,4,5,6,7,8,9,10,11,12]
well_names = list(product(numbers, 'ABCDEFGH'))
print(len(well_names))
# %%
# Add 96 wells to material
for ord, well in enumerate(well_names):
    mat_data = {'description': f'96 well plate: {well[1]}{well[0]}',
                'consumable': False,
                'actor': actor['url'],
                'status': test_status['url']
    }
    well_entry = post_data('material', data=mat_data, headers=token_header)
    well_entry = get_data('material', data={'description': mat_data['description']}, headers=token_header)
    mat_comp = {'composite': plate_96['url'],
                'component': well_entry['url'],
                'addressable': True,
                'actor': actor['url'],
                'status': test_status['url']
                }
    well_comp_entry = post_data('mixture', data=mat_comp, headers=token_header)
    well_comp_entry = get_data('mixture', data={'component_description': well_entry['description']}, headers=token_header)
    mat_prop = {'material': well_entry['url'],
                'property_def': well_ord_prop_def['url'],
                'property_value': str(ord),
                'value': json.dumps({"value":ord,"unit": "","type": "int"}),
                'actor': actor['url'],
                'status': test_status['url']}
    well_num = post_data('materialproperty', data=mat_prop, headers=token_header)
    #well_num = get_data('materialproperty', data={'property_description': well_ord_prop_def['description']}, headers=token_header)
    
    mat_prop['property_def'] = well_loc_prop_def['url']
    mat_prop['property_value'] = f"{well[1]}{well[0]}"
    well_loc = post_data('materialproperty', data=mat_prop, headers=token_header)
    #well_loc = get_data('materialproperty', data={'property_description': well_loc_prop_def['description']}, headers=token_header)

    mat_prop['property_def'] = well_vol_prop_def['url']
    mat_prop['value'] = '{10,500}'
    well_loc = post_data('materialproperty', data=mat_prop, headers=token_header)
    #well_loc = get_data('materialproperty', data=mat_prop, headers=token_header)
    

# %%
# Material types
material_types = [
    {'description': 'stock solution'},
    {'description': 'human prepared'},
    {'description': 'solute'},
    {'description': 'acid'},
    {'description': 'organic'},
    {'description': 'inorganic'},
    {'description': 'solvent'},
    {'description': 'template'},
]
r_material_types = {}
for material_type in material_types:
    try:
        r = post_data('materialtype', material_type, token_header)
    except:
        url = requests.utils.requote_uri(f'{base_url}/materialtype/?description={material_type["description"]}')
        r = requests.get(url).json()['results'][0]
    r_material_types[material_type['description']] = r
print(r_material_types)
# %%
r_materials = {}
r_materials['organic'] = get_data('material', {'description': '4-Hydroxyphenethylammonium iodide'}, headers=token_header)
r_materials['inorganic'] = get_data('material', {'description': 'Lead Diiodide'}, headers=token_header)
r_materials['solvent'] = get_data('material', {'description': 'Dimethylformamide'}, headers=token_header)
r_materials['acid'] = get_data('material', {'description': 'Formic Acid'}, headers=token_header)

material_fields = ['description', 'consumable', 'composite_flg', 'material_class']
material_data = [
    ['Reagent1', True, True, 'template'],
    ['Reagent2', True, True, 'template'],
    ['Reagent3', True, True, 'template'],
    ['Reagent7', True, True, 'template'],
    ]

for mat in material_data:
    material = dict(zip(material_fields, mat))
    r = post_data('material', material, token_header)
    r_materials[r['description']] = r
print(r_materials)

# %%
# Composite materials
material_composite_fields = ['composite', 'component', 'addressable', 'composite_class']
material_composites = [
    [r_materials['Reagent1']['url'], r_materials['solvent']['url'], False, 'template'],
    [r_materials['Reagent2']['url'], r_materials['inorganic']['url'], False, 'template'],
    [r_materials['Reagent2']['url'], r_materials['organic']['url'], False, 'template'],
    [r_materials['Reagent2']['url'], r_materials['solvent']['url'], False, 'template'],
    [r_materials['Reagent3']['url'], r_materials['organic']['url'], False, 'template'],
    [r_materials['Reagent3']['url'], r_materials['solvent']['url'], False, 'template'],
    [r_materials['Reagent7']['url'], r_materials['acid']['url'], False, 'template'],
]

r_material_composites = {}
for mat in material_composites:
    material_composite = dict(zip(material_composite_fields, mat))
    r = post_data('mixture', material_composite, token_header)
    r = requests.get(r['url']).json()
    r_material_composites[(r['composite_description'], r['component_description'])] = r
print(r_material_composites)
# %%
r_material_composites.keys()

# %%
solute_type = get_data('materialtype', {'description': 'solute'}, token_header)
solvent_type = get_data('materialtype', {'description': 'solvent'}, token_header)
material_type_assign_fields = ['material', 'material_type']
material_type_assign = [
    [r_materials['Reagent1']['url'], r_material_types['stock solution']['url']],
    [r_materials['Reagent2']['url'], r_material_types['stock solution']['url']],
    [r_materials['Reagent3']['url'], r_material_types['stock solution']['url']],
    [r_materials['Reagent7']['url'], r_material_types['stock solution']['url']],
]
#r_material_type_assign = {}
for mat_type in material_type_assign:
    mat_type_assign = dict(zip(material_type_assign_fields, mat_type))
    r = requests.post(f'{base_url}/materialtypeassign/',
                    data=json.dumps(mat_type_assign),
                    headers=token_header).json()
    r = post_data('materialtypeassign', mat_type_assign, token_header)
# %%
conc_def = get_data('propertydef', {'short_description': 'concentration'}, token_header)
material_prop_data = {
    'material': r_materials[('Reagent1', 'Dimethylformamide')]['url'],
    'property_def': conc_def['url'],
    'value': json.dumps({"value": 0, "unit": "mL", 'type': "num"})
}
