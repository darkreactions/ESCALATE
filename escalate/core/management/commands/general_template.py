lab_id = 'Haverford College'

reagents = {'Reagent 3 - Stock B':['organic', 'solvent'], 
            'Reagent 7 - Acid':['acid'], 
            'Reagent 2 - Stock A':['inorganic', 'organic', 'solvent'], 
            'Reagent 1 - Solvent':['solvent']}

column_order='ACEGBDFH'
rows = 12
plate_name= '96 Well Plate well'


action_seq = [
            'Preheat Temperature (C)', 
            'Mixing time1 (s)',
            'Mixing time2 (s)',
            'Temperature (C)',
            'Stir Rate (rpm)',
            'Reaction time (s)',
            'Dispense Solvent',
            'Dispense Stock A',
            'Dispense Stock B',
            'Dispense Acid Volume 1',
            'Dispense Acid Volume 2',
  ]

action_parameter_def = {
            'dispense': ('volume',),
            'bring_to_temperature': ('temperature',),
            'stir': ('temperature', 'duration', 'speed'),
            'heat': ('temperature', 'duration'),
            'temperature': ('temperature'),
        }
