import base64
import json
import sys
import requests
import pandas as pd
import os
from escalateclient import ESCALATEClient
import importlib

module_path = os.path.abspath(os.path.join('../../../'))
if module_path not in sys.path:
    sys.path.append(module_path)

'''
This script leverages the ESCALATE Client Rest API found here: https://github.com/darkreactions/ESCALATEClient
This script attempts to convert the DARPA SD2 experimental data from v2 into the v3 database.
Unfortunately this script is not complete, however, it can be used as a basis for completing the task described above. 
This document is heavily documented to provide as much assistance as possible. API calls will be commented out to avoid breaking the script. Some API examples are taken from the Escalate Client Documentation
Full WF1 API example can be found here: https://github.com/darkreactions/ESCALATEClient/blob/master/examples/haverford/workflow1/perovskite_setup.ipynb
'''

confirm = input("This script runs from a specific experiment top-level folder. For example, 1-Dev in .../Science/1-Dev/. If this script is located in the correct folder type yes. If not type no")

if lower(confirm) in ["yes", "y"]:
    confirm = input("Is this a local version of ESCALATE?[y/n]")
    
    #get api path
    if lower(confirm) in ["yes", "y"]:
        api = 'http://localhost:8000/api/'
        confirm = input("Local API url is: " + api + " Is this correct?[y/n]")
        if lower(confirm) in ["yes", "y"]:
            api = 'http://localhost:8000/api/'
        else:
            api = input("What is the api url?")
    else:
        api = input("What is the api url? Haverford College ESCALATE url is escalate.cs.haverford.edu/api/")
    
    #connect to api
    '''
    importlib.reload(escalateclient)
    server_url = api
    username = 'vshekar'
    password = 'copperhead123'
    client = escalateclient.ESCALATEClient(server_url, username, password)
    
    #get HC lab from api
    haverford_lab_response = client.get(endpoint='actor', data={'description': 'Haverford College', 'person__isnull': True, 'systemtool__isnull': True})[0]
    '''
    
    #get workflow for experiments
    wf = ''
    while wf != 'wf1' and wf != 'wf3':
        wf = input('Which Workflow is this experiment? [wf1/wf3]')
        wf = lower(wf)
    
    #wf1/wf3 connection
    '''
    if wf in 'wf1':
        template_response = client.get_or_create(endpoint='experiment-template', data={'description': 'Workflow 1', 'ref_id': 'workflow_1', 'lab': haverford_lab_response['url']})[0]
    elif wf in 'wf3':
        template_response = client.get_or_create(endpoint='experiment-template', data={'description': 'Workflow 3', 'ref_id': 'workflow_3', 'lab': haverford_lab_response['url']})[0]
    else:
        print("Invalid workflow for this script. Please re-run")
        sys.exit()
    '''
    
    #start folder recursion
    #current directory
    parent_dir = os.getcwd()
    #gets subdirectories and files
    for subdir, dirs, files in os.walk(parent_dir):
        #find image folder. might need to oswalk again to do so
        for dir in dirs:
            #csv list
            csv_list = []
            #image list
            image_list = []
            im_b64_list = []
            #oswalk each subdirectory
            for subdir_1, dirs_1, files_1 in os.walk(dir):
                for dir_1 in dirs_1:
                    #find images folder
                    if dir_1 in "images":
                        image_folder = dir_1
                        for image_subdir, image_dirs, image_files in os.walk(image_folder):
                            for image_file in image_files:
                                #push image file into list      
                                image_list.append(image_file)
                                #decode image file
                                with open(image_file, "rb") as f:
                                    im_bytes = f.read()                                        
                                im_b64 = base64.b64encode(im_bytes).decode("utf8")
                                #add to list to use later in conjunction with image_list. this is the list with the actual image file in b64 format
                                im_b64_list.append(im_b64)
                                #image packed in json and post
                                #this needs to be changed for our api. below was test code. should wait to post all data at once so you can associate the experiment with the images
                                '''
                                headers = {'Content-type': 'application/json', 'Accept': 'text/plain'}
                                payload = json.dumps({"image": im_b64, "other_key": "value"})
                                
                                response = requests.post(api, data=payload, headers=headers)
                                try:
                                    data = response.json()     
                                    print(data)                
                                except requests.exceptions.RequestException:
                                    print(response.text)   
                                '''
                    #find subdata folder with csvs
                    if dir_1 in "_subdata":
                        csv_folder = dir_1
                        for csv_subdir, csv_dirs, csv_files in os.walk(csv_folder):
                            #find csv files.
                            for csv_file in csv_files:
                                if csv_file in glob(os.path.join(path, "*.csv")):
                                    #push csv onto stack.
                                    csv_list.append(csv_file)
                                    #start csv parsing
                                    #most data can be found in the xlsx files in each experiment folder. I will keep this here in case csv parsing is needed
                #start xlsx parsing
                for file_1 in files_1:
                    if file_1 in "_preparation_interface":
                        #general experiment specifications can be taken from here
                        df_prep_interface = pd.read_excel(file_1, sheet_name=0)
                    else if file_1 in "_observation_interface":
                        #image mapping can be done from here
                        df_obs_interface = pd.read_excel(file_1, sheet_name=0)
    
    #API Experiment Creation
    #create reagent templates
    # Reagent templates can be defined as a dictionary of reagent template name as keys and a list of chemical types as value
    # If the chemical type does not exist, it is automatically created 
    '''
    reagent_templates = {
                "Reagent 1 - Solvent": ["solvent"],
                "Reagent 2 - Stock A": ["organic", "solvent"],
                "Reagent 3 - Stock B": ["inorganic", "organic", "solvent"],
                "Reagent 7 - Acid": ["acid"],
            }

    reagent_template_responses = client.create_reagent_templates(data=reagent_templates)
    '''
    
    #create default values
    '''
    volume_value = {"value": 0, "unit": "ml", "type": "num"}
    zero_ml_data = {"description": "Zero ml", "nominal_value": volume_value, "actual_value": volume_value,}
    zero_ml_response = client.get_or_create(endpoint='default-values', data=zero_ml_data)[0]
    '''
    
    # Defining Reagent Template properties of total reagent volume and dead volume and associate a default volume
    '''
    total_volume_prop_template_data  = {
                    "description": "total volume",
                    "property_def_class": "extrinsic",
                    "short_description": "volume",
                    "default_value": zero_ml_response['url'],
                }
    total_volume_prop_template = client.get_or_create(endpoint='property-template', data=total_volume_prop_template_data)[0]

    dead_volume_prop_template_data = {
                    "description": "dead volume",
                    "property_def_class": "extrinsic",
                    "short_description": "dead volume",
                    "default_value": zero_ml_response['url'],
                }
    dead_volume_prop_template = client.get_or_create(endpoint='property-template', data=dead_volume_prop_template_data)[0]
    '''
    
    #defining dispense action example
    '''
    data = {'description': 'dispense'}
    dispense_action_def_response = client.get_or_create(endpoint='action-def', data=data)[0]
    
    data = {'description': 'volume', 'default_value': {"type": "num", "unit": "mL", "value": 0.0}}
    volume_parameter_def_response = client.get_or_create(endpoint='parameter-def', data=data)[0]

    action_parameter_def = {
                "dispense": [("volume",{"type": "num", "unit": "mL", "value": 0.0})],
                "bring_to_temperature": [("temperature", {"type": "num", "unit": "degC", "value": 0.0})],
                "stir": [("duration", {"type": "num", "unit": "seconds", "value": 0.0}),  ("speed", {"type": "num", "unit": "rpm", "value": 0.0})],
            }
    '''
else:
    print("Please move this script to the correct folder and run again")
    sys.exit()