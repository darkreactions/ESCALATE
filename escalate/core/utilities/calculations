import requests
from IPython.display import display, HTML

import pint
from pint import UnitRegistry
units = UnitRegistry()
Q_ = units.Quantity


def generate_input_f(reagent, MW, density):
    """ A helper function to properly formate input for concentration-to-amount calculations.
    Returns a dictionary where each key is a reagent component and each value is a sub-dictionary
    containing concentration, phase, molecular weight, and density.
    
    reagent - a list of reagent-instance-value dictionaries
    MW - material definition URL for molecular weight
    density - material definition URL for density
    
    """
    
    input_data={} #instantiate dictionary to fill with data

    for component in reagent: #component = one of the reagent instance values inside the reagent 

        conc_val=component['nominal_value']['value'] #desired concentration
        conc_unit=component['nominal_value']['unit'] #concentration unit 
        
        if units(conc_unit)!=units('molar'): #concentration must be in molarity. otherwise code breaks
            print('Concentration must be a molarity. Please convert and re-enter.')
            break
        else:
            conc=Q_(conc_val, conc_unit) #store in proper Pint format

        phase=requests.get(component['material']).json()['phase'] #phase/state of matter

        #extract associated material URL
        r=requests.get(component['material']).json()['material'] 
        mat=requests.get(r).json()
        material=mat['description']
        #loop through properties of the material to get MW and density
        for prop in mat['identifier']: 
            r=requests.get(prop).json()
            if r['material_identifier_def']==MW: #url must match that of MW material identifier def
                mw= r['description']
                mag=float(mw.split()[0])
                unit= str(mw.split()[1])
                mw=Q_(mag, unit).to(units.g/units.mol) #convert to g/mol and store in proper Pint format
                
            if r['material_identifier_def']==density: #url must match that of density material identifier def
                d= r['description']
                mag=float(d.split()[0])
                unit= str(d.split()[1])
                d=Q_(mag, unit).to(units.g/units.ml) #convert to g/mL and store in proper Pint format

        input_data[material]={'concentration': conc, 'phase': phase, 'molecular weight': mw, 'density': d}


    return input_data  


def calculate_amounts(input_data, total_vol):
    
    """ 
    Given input data from helper function and a total volume (string with units), 
    returns amounts of each reagent component needed to achieve desired concentrations.
    For solids/solutes, amounts will be reported in grams.
    For liquid/solvent, amount will be reported in mL.
    
    """
    
    #input_data comes from helper function above
    #total vol must be input as a string with units

    amounts={} 
    
    #convert volume to mL and store in proper Pint format
    mag=float(total_vol.split()[0])
    unit= str(total_vol.split()[1])
    total_vol = Q_(mag, unit).to(units.ml)

    for key, val in input_data.items():
        if val['phase']=='solid': #for all solids 
            grams=total_vol*val['concentration'].to(units.mol/units.ml) * val['molecular weight'] 
            #convert concentration to moles to mass
            amounts[key]=grams 

    for substance, amount in amounts.items(): #for all solids
        total_vol-=amount/input_data[substance]['density'] #find the volume 
        #find the volume. subtract from total volume - this is how much liquid will be needed 

    for key, val in input_data.items():
        if val['phase']=='liquid': #for the solvent
            amounts[key]=total_vol #amount is the remaining available volume

    for key, val in amounts.items(): #convert amounts from Pint format to strings with val and unit
        num=val.magnitude
        unit=val.units
        value=str(num) + ' ' + str(unit)
        amounts[key]=value
    
    return amounts
