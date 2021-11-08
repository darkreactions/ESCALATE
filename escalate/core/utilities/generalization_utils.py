import pandas as pd
import tempfile
import re
import math
from core.models.view_tables import (ReactionParameter)

def make_site_list(container_name, 
              well_count, 
              column_order=['A', 'C', 'E', 'G', 'B', 'D', 'F', 'H'], # order is set by how the robot draws from the solvent wells
              total_columns=12): #default is 96 well plate
    if container_name==str and well_count>1: #well plate
        row_limit = math.ceil(well_count / total_columns) # 8 columns in a 96 plate
        well_names = [f'{col}{row}' for row in range(1, row_limit+1) for col in column_order][:well_count]
        vial_df = pd.DataFrame({'Site': well_names, 'Labware ID:': container_name})
        return vial_df
    else: #generic container
        index=[i for i in range(len(container_name))]
        site_df = pd.DataFrame({'Site': index, 'Labware ID:': container_name})
        return site_df

def generate_generic_robot_file(reaction_volumes, reaction_parameters,
                        container_name, well_count):

    if reaction_parameters is None:
        rxn_parameters = pd.DataFrame({
                'Reaction Parameters': ['Temperature:', 
                                        'Volume:',
                                        'Stir rate:',
                                        'Mixing time:',
                                        'Reaction time:',
                                        ],
                'Parameter Values': [0, 0, 0, 0, 0],
                'Parameter Units': ['C', 'uL', 'rpm', 's', 's'],
    })
    else:
        reaction_params = reaction_parameters.keys()
        parameter_vals = reaction_parameters.values()
        #q1 = pd.DataFrame.from_dict(reaction_parameters)
        rxn_parameters = pd.DataFrame({
            'Reaction Parameters': reaction_params,
            'Parameter Values': parameter_vals
        })
    
    df_tray = make_site_list(container_name, well_count)
    
    reagent_colnames = ['Reagent 1', 'Reagent 2', 'Reagent 3', 
                            'Reagent 4', 'Reagent 5', 'Reagent 6',
                            'Reagent 7', 'Reagent 8', 'Reagent 9']
    
    reaction_volumes_output = pd.DataFrame({
            reagent_col: [0]*len(df_tray) for reagent_col in reagent_colnames
        })
    
    reaction_volumes_output = pd.concat([df_tray['Site'], reaction_volumes_output], axis=1)

    rxn_conditions = pd.DataFrame({
        'Reagents': ['Reagent 1', 'Reagent 2', 'Reagent 3', 'Reagent 4', 'Reagent 5', 'Reagent 6', 'Reagent 7', 'Reagent 8', 'Reagent 9' ],
        'Reagent identity': ['']*9,
        'Liquid Class': ['HighVolume_Water_DispenseJet_Empty', 
                         'HighVolume_Water_DispenseJet_Empty', 
                         'HighVolume_Water_DispenseJet_Empty',
                         'Tip_50ul_Water_DispenseJet_Empty',
                         'Tip_50ul_Water_DispenseJet_Empty',
                         'StandardVolume_Water_DispenseJet_Empty',
                         'StandardVolume_Water_DispenseJet_Empty',
                         'Tip_50ul_Water_DispenseJet_Empty',
                         'Tip_50ul_Water_DispenseJet_Empty',],
        'Reagent Temperature': [45]*9
    })
    
    outframe = pd.concat(#df_tray['Vial Site'],
                          [reaction_volumes_output, 
                          df_tray['Labware ID:'], rxn_parameters, 
                          rxn_conditions], sort=False, axis=1)
    temp = tempfile.TemporaryFile()
    #xlwt is no longer maintained and will be removed from pandas in future versions
    #use io.excel.xls.writer as the engine once xlwt is removed
    outframe.to_excel(temp, sheet_name='NIMBUS_reaction', index=False, engine="xlwt")
    temp.seek(0)
    return temp

def generate_action_reagent_map(reagents, action_sequences):
    ar_map={}
    for key, val in reagents.items():
        count=0
        for i in action_sequences:
            if key.split('-')[1] in i:
                count+=1
        for i in action_sequences:
            if key.split('-')[1] in i:
                frac=1/count
                ar_map[i]=(key.split('-')[0], frac)
    return ar_map

def generate_reagent_action_map(reagents, action_sequences):
    ra_map={}
    for key, val in reagents.items():
        for i in action_sequences:
            if str(val) in i:
                ra_map[key]=(i)
    return ra_map