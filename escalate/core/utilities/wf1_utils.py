import pandas as pd
import tempfile

def make_well_list(container_name, 
              well_count, 
              column_order=['A', 'C', 'E', 'G', 'B', 'D', 'F', 'H'], # order is set by how the robot draws from the solvent wells
              total_rows=8):
    row_limit = int(well_count / total_rows) # 8 rows in a 96 plate
    well_names = [f'{col}{row}' for row in range(1, row_limit+1) for col in column_order][:well_count]
    vial_df = pd.DataFrame({'Vial Site': well_names, 'Labware ID:': container_name})
    return vial_df

def generate_robot_file(reaction_volumes=None, reaction_parameters=None,
                        plate_name='Symyx_96_well_0003', well_count=96):
    #'Temperature (C):'-> vw_action_parameter.parameter_value_nominal (text)
    #'Stir Rate (rpm):'->vw_action_parameter.parameter_value_nominal (text)
    if reaction_parameters is None:
        rxn_parameters = pd.DataFrame({
                'Reaction Parameters': ['Temperature (C):', 
                                        'Stir Rate (rpm):',
                                        'Mixing time1 (s):',
                                        'Mixing time2 (s):',
                                        'Reaction time (s):',
                                        'Preheat Temperature (C):',
                                        ],
                'Parameter Values': [105, 750, 900, 1200, 21600, 85],
        })
    df_tray = make_well_list(plate_name, well_count)
    if reaction_volumes is None:
        reagent_colnames = ['Reagent1 (ul)', 'Reagent2 (ul)', 'Reagent3 (ul)', 
                            'Reagent4 (ul)', 'Reagent5 (ul)', 'Reagent6 (ul)',
                            'Reagent7 (ul)', 'Reagent8 (ul)', 'Reagent9 (ul)']
        reaction_volumes = pd.DataFrame({
            reagent_col: [0]*len(df_tray) for reagent_col in reagent_colnames
        })
    rxn_conditions = pd.DataFrame({
        'Reagents': ['Reagent1', 'Reagent2', 'Reagent3', 'Reagent4', 'Reagent5', 'Reagent6', 'Reagent7', 'Reagent8', 'Reagent9', ],
        'Reagent identity': ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
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
    
    outframe = pd.concat([df_tray['Vial Site'], reaction_volumes, 
                          df_tray['Labware ID:'], rxn_parameters, 
                          rxn_conditions], sort=False, axis=1)
    temp = tempfile.TemporaryFile()
    outframe.to_excel(temp, sheet_name='NIMBUS_reaction', index=False)
    temp.seek(0)
    return temp
