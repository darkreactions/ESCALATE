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
    return r.json()

def get_data(url_path, data, headers, all=False):
    resp = requests.get(f'{base_url}/{url_path}/', params=data, headers=headers)
    if all:
        return resp.json()['results']
    return resp.json()['results'][0]

actor = get_data('actor',{'organization__isnull':True, 'description__contains': 'Shekar'}, headers=token_header)
print(actor)
test_status = get_data('status', {'description':'test'}, headers=token_header)
print(test_status)

# %%
## 48 well plate
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
    well_comp_entry = post_data('compositematerial', data=mat_comp, headers=token_header)
    well_comp_entry = get_data('compositematerial', data={'component_description': well_entry['description']}, headers=token_header)
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
