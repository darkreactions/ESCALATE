# %%
import requests
import json
import timeit

base_url = "http://localhost:8000/api"

login_data = {"username": "vshekar", "password": "copperhead123"}
r_login = requests.post(f"{base_url}/login", data=login_data)
token = r_login.json()["token"]
token_header = {"Authorization": f"Token {token}", "content-type": "application/json"}


def post_data(url_path, data, headers):
    r = requests.post(f"{base_url}/{url_path}/", data=json.dumps(data), headers=headers)
    return r.json()


# %%

# Insert org
org_data = {
    "description": "Schrierwirtshaus",
    "full_name": "Schrierwirtshaus GmbH",
    "short_name": "SWH",
    "address": "100 Fancy Apartment Ave",
    "city": "New York",
    "state_province": "NY",
    "zip": "99999",
}
r_org = post_data("organization", org_data, token_header)

print(r_org)

# %%
person_data = {
    "last_name": "Schrier",
    "first_name": "Joshua",
    "address1": "100 Fancy Apartment Ave",
    "city": "New York",
    "state_province": "NY",
    "zip": "99999",
}
r_person = requests.post(
    f"{base_url}/person/", data=json.dumps(person_data), headers=token_header
)
r_person = post_data("person", person_data, token_header)
print(r_person)

# %%
actor = requests.get(
    f"{base_url}/actor/?person__first_name=Joshua&person__last_name=Schrier&organization__isnull=True"
).json()["results"][0]
print(actor)

# %%
material_types = [
    {"description": "stock solution"},
    {"description": "human prepared"},
    {"description": "solute"},
]
r_material_types = {}
for material_type in material_types:
    try:
        r = post_data("materialtype", material_type, token_header)
    except:
        url = requests.utils.requote_uri(
            f'{base_url}/materialtype/?description={material_type["description"]}'
        )
        r = requests.get(url).json()["results"][0]
    r_material_types[material_type["description"]] = r
print(r_material_types)

# %%
print(material_types)
for mat_type in material_types:
    url = requests.utils.requote_uri(
        f'{base_url}/materialtype/?description={mat_type["description"]}'
    )
    print(url)
    r = requests.get(url).json()["results"][0]
    r_material_types[mat_type["description"]] = r

print(r_material_types)

# %%
dev_test_status = requests.get(f"{base_url}/status/?description=dev_test").json()[
    "results"
][0]
material_fields = ["description", "consumable", "actor_uuid", "status_uuid"]
materials = [
    ["Cocktail Shaker", False, actor["uuid"], dev_test_status["uuid"]],
    ["Highball Glass", False, actor["uuid"], dev_test_status["uuid"]],
    ["Lime Slice", True, actor["uuid"], dev_test_status["uuid"]],
    ["Lime Juice", True, actor["uuid"], dev_test_status["uuid"]],
    ["Mint Leaf", True, actor["uuid"], dev_test_status["uuid"]],
    ["White Rum", True, actor["uuid"], dev_test_status["uuid"]],
    ["Granulated Sugar", True, actor["uuid"], dev_test_status["uuid"]],
    ["Simple Syrup", True, actor["uuid"], dev_test_status["uuid"]],
    ["Ice Cube", True, actor["uuid"], dev_test_status["uuid"]],
    ["Club Soda", True, actor["uuid"], dev_test_status["uuid"]],
]
r_materials = {}
for mat in materials:
    material = dict(zip(material_fields, mat))
    r = post_data("material", material, token_header)
    r_materials[r["description"]] = r
print(r_materials)

# %%

water = requests.get(f"{base_url}/material/?description=Water").json()["results"][0]
print(water)

# %%
# -- add the components to the composite

material_composite_fields = ["composite", "component", "addressable", "actor", "status"]
material_composites = [
    [
        r_materials["Simple Syrup"]["url"],
        r_materials["Granulated Sugar"]["url"],
        False,
        actor["url"],
        dev_test_status["url"],
    ],
    [
        r_materials["Simple Syrup"]["url"],
        water["url"],
        False,
        actor["url"],
        dev_test_status["url"],
    ],
]

r_material_composites = {}
for mat in material_composites:
    material_composite = dict(zip(material_composite_fields, mat))
    r = post_data("mixture", material_composite, token_header)
    r = requests.get(r["url"]).json()
    r_material_composites[(r["composite_description"], r["component_description"])] = r
print(r_material_composites)

# %%
# -- add material_type to materials
print(r_material_types.keys())
solute_type = requests.get(f"{base_url}/materialtype/?description=solute").json()[
    "results"
][0]
solvent_type = requests.get(f"{base_url}/materialtype/?description=solvent").json()[
    "results"
][0]
material_type_assign_fields = ["material", "material_type"]
material_type_assign = [
    [r_materials["Simple Syrup"]["url"], r_material_types["stock solution"]["url"]],
    [r_materials["Simple Syrup"]["url"], r_material_types["human prepared"]["url"]],
    [
        r_material_composites[("Simple Syrup", "Granulated Sugar")]["url"],
        solute_type["url"],
    ],
    [r_material_composites[("Simple Syrup", "Water")]["url"], solvent_type["url"]],
]
# r_material_type_assign = {}
for mat_type in material_type_assign:
    mat_type_assign = dict(zip(material_type_assign_fields, mat_type))
    r = requests.post(
        f"{base_url}/materialtypeassign/",
        data=json.dumps(mat_type_assign),
        headers=token_header,
    ).json()
    r = post_data("materialtypeassign", mat_type_assign, token_header)

# %%
# -- add component properties
conc_def = requests.get(
    f"{base_url}/propertydef/?short_description=concentration"
).json()["results"][0]

material_property_data = {
    "material": r_material_composites[("Simple Syrup", "Granulated Sugar")]["url"],
    "property_def": conc_def["url"],
    "value": json.dumps({"value": 1, "unit": "vol/vol", "type": "int"}),
    #'actor': actor['url'],
    "status": dev_test_status["url"],
}
r_material_property = post_data(
    "materialproperty", material_property_data, token_header
)

# %%
# define action def

action_def_fields = ["description", "actor", "status"]
action_def_data = [
    ["dispense_floz", actor["url"], dev_test_status["url"]],
    ["shake", actor["url"], dev_test_status["url"]],
    ["muddle", actor["url"], dev_test_status["url"]],
    ["strain_all", actor["url"], dev_test_status["url"]],
    ["transfer_discrete", actor["url"], dev_test_status["url"]],
]
r_action_def = {}
for action_def in action_def_data:
    action_def = dict(zip(action_def_fields, action_def))
    r = requests.post(
        f"{base_url}/actiondef/", data=json.dumps(action_def), headers=token_header
    ).json()
    r_action_def[r["description"]] = r

# %%
# define parameterdef
parameter_def_fields = ["description", "default_val", "actor", "status"]
parameter_def_data = [
    [
        "duration_qualitative",
        {"value": "briefly", "unit": "", "type": "text"},
        actor["url"],
        dev_test_status["url"],
    ],
    [
        "intensity_qualitative",
        {"value": "gently", "unit": "", "type": "text"},
        actor["url"],
        dev_test_status["url"],
    ],
    [
        "volume_floz",
        {"value": 0, "unit": "floz", "type": "num"},
        actor["url"],
        dev_test_status["url"],
    ],
    [
        "count",
        {"value": 0, "unit": "count", "type": "int"},
        actor["url"],
        dev_test_status["url"],
    ],
    [
        "amount_qualitative",
        {"value": "all", "unit": "", "type": "text"},
        actor["url"],
        dev_test_status["url"],
    ],
]
r_parameter_def = {}
for param_def in parameter_def_data:
    param_def = dict(zip(parameter_def_fields, param_def))
    r = requests.post(
        f"{base_url}/parameterdef/", data=json.dumps(param_def), headers=token_header
    ).json()
    r_parameter_def[r["description"]] = r

# %%
apda_fields = ["action_def", "parameter_def"]
apda_data = [
    [r_action_def["shake"]["url"], r_parameter_def["duration_qualitative"]["url"]],
    [r_action_def["muddle"]["url"], r_parameter_def["intensity_qualitative"]["url"]],
    [r_action_def["dispense_floz"]["url"], r_parameter_def["volume_floz"]["url"]],
    [r_action_def["transfer_discrete"]["url"], r_parameter_def["count"]["url"]],
    [r_action_def["strain_all"]["url"], r_parameter_def["amount_qualitative"]["url"]],
]
r_apda = {}
for apda in apda_data:
    apda = dict(zip(apda_fields, apda))
    r = requests.post(f"")
# %%
