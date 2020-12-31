from coreapi import Client, Document
import requests
import json
import timeit
import coreapi

# outcome, workflow.workflow.step.workflow_object.action, bill_of_materials

omit_cols = "omit=edocs,tags,notes,add_date,mod_date,status,status_description"
expand_cols = "expand=bill_of_materials.bom_material"
full_expand_cols = "expand=bill_of_materials.bom_material,workflow.step.workflow_object,outcome"

def expand_list(url_list):
    data_list = []
    for url in url_list:
        req = requests.get(f'{url}?{omit_cols}')
        bom_data = json.loads(req.text)
        data_list.append(bom_data)
    return data_list


def expand_instance(instance, col_name):
    url = instance[col_name]
    req = requests.get(f'{url}?{omit_cols}')
    base_data = json.loads(req.text)
    instance[col_name] = base_data
    return instance


def expand_dict(data_dict, col_name):
    base_col = col_name[0]
    for dat in data_dict:
        dat = expand_instance(dat, base_col)
        for col in col_name[1:]:
            dat[base_col] = expand_instance(dat[base_col], col)
    return data_dict


def run_all():
    r = requests.get(f'http://localhost:8000/api/experiment/cdc46d6b-e801-465f-87fc-c38b0ed7a7e1/?{expand_cols}&{omit_cols}')

    data = json.loads(r.text)
    data['outcome'] = expand_list(data['outcome'])
    data['workflow'] = expand_list(data['workflow'])
    #data['workflow'] = expand_dict(data['workflow'], ['workflow'])
    #data['bill_of_materials'] = expand_list(data['bill_of_materials'])

    for workflow in data['workflow']:
        #workflow['step'] = expand_list(workflow['step'])
        workflow['step'] = expand_dict(workflow['step'], ['workflow_object', 'action'])
    
    #data['bill_of_materials']['bom_material'] = expand_dict(data['bill_of_materials'], ['bom_material'])
    

    json.dump(data, open('data_dump.json', 'w'), indent=4)


# print(timeit.timeit(lambda: run_all(), number=1))
print(timeit.timeit(lambda: requests.get(f'http://localhost:8000/api/experiment/cdc46d6b-e801-465f-87fc-c38b0ed7a7e1/?{full_expand_cols}'), number=20))
