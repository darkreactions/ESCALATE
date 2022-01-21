import pandas as pd
import tempfile
import re
import math
from core.models.view_tables import ReactionParameter, Reagent
from core.models import ExperimentTemplate


def make_well_labels_list(well_count=96, column_order=None, robot="True"):
    if well_count not in [24, 96]:
        if well_count is None:
            well_labels = [1]
        else:
            well_labels = [i for i in range(1, well_count + 1)]

    else:
        num_rows = math.ceil((well_count * 3 / 2) ** (1 / 2))
        # num_cols = math.ceil(well_count/num_rows)

        if robot == "True":
            if well_count == 96:
                if column_order is None:
                    column_order = ["A", "C", "E", "G", "B", "D", "F", "H"]
            if well_count == 24:
                if column_order is None:
                    column_order = ["A", "C", "B", "D"]

            total_columns = len(column_order)
            row_limit = math.ceil(well_count / total_columns)
            well_labels = [
                f"{col}{row}" for row in range(1, row_limit + 1) for col in column_order
            ][:well_count]

        else:  # chronological order for outcomes
            if well_count == 96:
                column_order = ["A", "B", "C", "D", "E", "F", "G", "H"]
            if well_count == 24:
                column_order = ["A", "B", "C", "D"]
            well_labels = [
                f"{col}{row}" for col in column_order for row in range(1, num_rows + 1)
            ][:well_count]

    return well_labels


def make_well_list(
    container_name,
    well_count,
    column_order=[
        "A",
        "C",
        "E",
        "G",
        "B",
        "D",
        "F",
        "H",
    ],  # order is set by how the robot draws from the solvent wells
    # column_order=['A', 'C', 'B', 'D'], # 24 well plate
    # total_columns=8,
):
    # row_limit = math.ceil(well_count / total_columns)  # 8 columns in a 96 plate
    # well_names = [
    # f"{col}{row}" for row in range(1, row_limit + 1) for col in column_order
    # ][:well_count]
    well_names = make_well_labels_list(well_count, column_order, robot="True")
    vial_df = pd.DataFrame({"Vial Site": well_names, "Labware ID:": container_name})
    return vial_df


def generate_robot_file(reaction_volumes, reaction_parameters, plate_name, well_count):
    #'Temperature (C):'-> vw_action_parameter.parameter_value_nominal (text)
    #'Stir Rate (rpm):'->vw_action_parameter.parameter_value_nominal (text)

    # Will use default WF1 parameters until we clean up our parameter UI
    reaction_parameters = None
    if reaction_parameters is None:
        rxn_parameters = pd.DataFrame(
            {
                "Reaction Parameters": [
                    "Temperature (C):",
                    "Stir Rate (rpm):",
                    "Mixing time1 (s):",
                    "Mixing time2 (s):",
                    "Reaction time (s):",
                    "Preheat Temperature (C):",
                ],
                "Parameter Values": [105, 750, 900, 1200, 21600, 85],
            }
        )
    else:
        reaction_params = reaction_parameters.keys()
        parameter_vals = reaction_parameters.values()
        # q1 = pd.DataFrame.from_dict(reaction_parameters)
        rxn_parameters = pd.DataFrame(
            {"Reaction Parameters": reaction_params, "Parameter Values": parameter_vals}
        )

    df_tray = make_well_list(plate_name, well_count)
    reagent_colnames = [
        "Reagent1 (ul)",
        "Reagent2 (ul)",
        "Reagent3 (ul)",
        "Reagent4 (ul)",
        "Reagent5 (ul)",
        "Reagent6 (ul)",
        "Reagent7 (ul)",
        "Reagent8 (ul)",
        "Reagent9 (ul)",
    ]
    reaction_volumes_output = pd.DataFrame(
        {reagent_col: [0] * len(df_tray) for reagent_col in reagent_colnames}
    )
    if reaction_volumes is not None:
        reaction_volumes_output = pd.concat(
            [df_tray["Vial Site"], reaction_volumes_output], axis=1
        )
        # Keep this Acid Volume 1/Acid Volume 2, do not change to acid vol
        REAG_MAPPING = {
            "Stock A": 2,
            "Stock B": 3,
            "Solvent": 1,
            "Acid Volume 1": 6,
            "Acid Volume 2": 7,
        }

        for current_reaction_volume in reaction_volumes:
            # this_value = current_reaction_volume.parameter_value.value
            object_value = current_reaction_volume.parameter_value.value
            object_description = current_reaction_volume.object_description
            if object_description != None and "Dispense" in object_description:
                try:
                    source_material = get_source_name(object_description)
                except:
                    print(object_description)
                vial_site = get_vial_site(object_description)
                reag_num = REAG_MAPPING.get(source_material)
                reag_name = f"Reagent{reag_num} (ul)"
                reaction_volumes_output.loc[
                    reaction_volumes_output["Vial Site"] == vial_site, reag_name
                ] = object_value

    rxn_conditions = pd.DataFrame(
        {
            "Reagents": [
                "Reagent1",
                "Reagent2",
                "Reagent3",
                "Reagent4",
                "Reagent5",
                "Reagent6",
                "Reagent7",
                "Reagent8",
                "Reagent9",
            ],
            "Reagent identity": ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
            "Liquid Class": [
                "HighVolume_Water_DispenseJet_Empty",
                "HighVolume_Water_DispenseJet_Empty",
                "HighVolume_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "StandardVolume_Water_DispenseJet_Empty",
                "StandardVolume_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
            ],
            "Reagent Temperature": [45] * 9,
        }
    )

    outframe = pd.concat(
        [  # df_tray['Vial Site'],
            reaction_volumes_output,
            df_tray["Labware ID:"],
            rxn_parameters,
            rxn_conditions,
        ],
        sort=False,
        axis=1,
    )
    temp = tempfile.TemporaryFile()
    # xlwt is no longer maintained and will be removed from pandas in future versions
    # use io.excel.xls.writer as the engine once xlwt is removed
    outframe.to_excel(temp, sheet_name="NIMBUS_reaction", index=False, engine="xlwt")
    temp.seek(0)
    return temp


# regex for perovskite demo to retrieve source name
# needs to be replaced
def get_source_name(dispense_string):
    return re.search(
        "^(Perovskite Demo: )?Dispense ([A-Za-z0-9 ]+):", dispense_string
    ).group(2)


# regex for perovskite demo to retrieve vial site
# needs to be replaced
def get_vial_site(dispense_string):
    return re.search("Plate well#: ([A-Z][0-9])", dispense_string).group(1)


def generate_general_robot_file(
    reaction_volumes, reaction_parameters, plate_name, well_count
):
    reaction_parameters = ReactionParameter.objects.filter(
        experiment_uuid=reaction_volumes[0].experiment_uuid
    )
    if reaction_parameters is None:
        rxn_parameters = pd.DataFrame(
            {
                "Reaction Parameters": [
                    "Temperature (C):",
                    "Stir Rate (rpm):",
                    "Mixing time1 (s):",
                    "Mixing time2 (s):",
                    "Reaction time (s):",
                    "Preheat Temperature (C):",
                ],
                "Parameter Values": [105, 750, 900, 1200, 21600, 85],
            }
        )
    else:
        # to check for duplicate reaction parameters while trying to fix loadscript issue
        last_param = None
        # enumerate to map
        rp_keys = []
        rp_values = []
        for i, reaction_parameter in enumerate(reaction_parameters):
            if last_param == reaction_parameter.description:
                continue
            rp_keys.append(reaction_parameter.description)
            rp_values.append(reaction_parameter.value)
            last_param = reaction_parameter.description

        rxn_parameters = pd.DataFrame(
            {"Reaction Parameters": rp_keys, "Parameter Values": rp_values}
        )
    df_tray = make_well_list(
        plate_name, well_count, column_order=["A", "C", "E", "G", "B", "D", "F", "H"],
    )
    reagent_colnames = []
    reagents = ExperimentTemplate.objects.get(
        uuid=reaction_volumes[0].experiment_uuid
    ).reagent_templates.all()
    for r in reagents:
        reagent_colnames.append(r.description)

    reaction_volumes_output = pd.DataFrame(
        {reagent_col: [0] * len(df_tray) for reagent_col in reagent_colnames}
    )

    if reaction_volumes is not None:
        reaction_volumes_output = pd.concat(
            [df_tray["Vial Site"], reaction_volumes_output], axis=1
        )

    rxn_conditions = pd.DataFrame(
        {
            "Reagents": [i for i in reagent_colnames],
            "Reagent identity": [str(i + 1) for i in range(len(reagent_colnames))],
            "Liquid class": [
                "StandardVolume_Water_DispenseJet_Empty"
                for i in range(len(reagent_colnames))
            ],
            "Temperature": ["45" for i in range(len(reagent_colnames))],
        }
    )

    outframe = pd.concat(
        [  # df_tray['Vial Site'],
            reaction_volumes_output,
            df_tray["Labware ID:"],
            rxn_parameters,
            rxn_conditions,
        ],
        sort=False,
        axis=1,
    )
    temp = tempfile.TemporaryFile()
    # xlwt is no longer maintained and will be removed from pandas in future versions
    # use io.excel.xls.writer as the engine once xlwt is removed
    outframe.to_excel(temp, sheet_name="NIMBUS_reaction", index=False, engine="xlwt")
    temp.seek(0)
    return temp


def generate_robot_file_wf1(
    reaction_volumes, reaction_parameters, plate_name, well_count
):
    #'Temperature (C):'-> vw_action_parameter.parameter_value_nominal (text)
    #'Stir Rate (rpm):'->vw_action_parameter.parameter_value_nominal (text)

    # Will use default WF1 parameters until we clean up our parameter UI
    # reaction_parameters = None
    reaction_parameters = ReactionParameter.objects.filter(
        experiment_uuid=reaction_volumes[0].experiment_uuid
    )
    if reaction_parameters is None:
        rxn_parameters = pd.DataFrame(
            {
                "Reaction Parameters": [
                    "Temperature (C):",
                    "Stir Rate (rpm):",
                    "Mixing time1 (s):",
                    "Mixing time2 (s):",
                    "Reaction time (s):",
                    "Preheat Temperature (C):",
                ],
                "Parameter Values": [105, 750, 900, 1200, 21600, 85],
            }
        )
    else:
        # to check for duplicate reaction parameters while trying to fix loadscript issue
        last_param = None
        # enumerate to map
        rp_keys = []
        rp_values = []
        for i, reaction_parameter in enumerate(reaction_parameters):
            if last_param == reaction_parameter.description:
                continue
            rp_keys.append(reaction_parameter.description)
            rp_values.append(reaction_parameter.value)
            last_param = reaction_parameter.description

        rxn_parameters = pd.DataFrame(
            {"Reaction Parameters": rp_keys, "Parameter Values": rp_values}
        )

    df_tray = make_well_list(
        plate_name,
        well_count,
        column_order=["A", "C", "E", "G", "B", "D", "F", "H"],
        # total_columns=8,
    )
    reagent_colnames = [
        "Reagent1 (ul)",
        "Reagent2 (ul)",
        "Reagent3 (ul)",
        "Reagent4 (ul)",
        "Reagent5 (ul)",
        "Reagent6 (ul)",
        "Reagent7 (ul)",
        "Reagent8 (ul)",
        "Reagent9 (ul)",
    ]
    reaction_volumes_output = pd.DataFrame(
        {reagent_col: [0] * len(df_tray) for reagent_col in reagent_colnames}
    )

    if reaction_volumes is not None:
        reaction_volumes_output = pd.concat(
            [df_tray["Vial Site"], reaction_volumes_output], axis=1
        )
        # Keep this Acid Volume 1/Acid Volume 2, do not change to acid vol
        REAG_MAPPING = {
            "Dispense Stock A": 2,
            "Dispense Stock B": 3,
            "Dispense Solvent": 1,
            "Dispense Acid Volume 1": 6,
            "Dispense Acid Volume 2": 7,
        }

        # source material -> Reagent number, vial_site -> row name

        for action_name, reagent_num in REAG_MAPPING.items():
            action_units = reaction_volumes.filter(object_description=action_name)
            for au in action_units:
                reaction_volumes_output.loc[
                    reaction_volumes_output["Vial Site"] == au.action_unit_destination,
                    f"Reagent{reagent_num} (ul)",
                ] = au.parameter_value.value

    rxn_conditions = pd.DataFrame(
        {
            "Reagents": [
                "Reagent1",
                "Reagent2",
                "Reagent3",
                "Reagent4",
                "Reagent5",
                "Reagent6",
                "Reagent7",
                "Reagent8",
                "Reagent9",
            ],
            "Reagent identity": ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
            "Liquid Class": [
                "HighVolume_Water_DispenseJet_Empty",
                "HighVolume_Water_DispenseJet_Empty",
                "HighVolume_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "StandardVolume_Water_DispenseJet_Empty",
                "StandardVolume_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
            ],
            "Reagent Temperature": [45] * 9,
        }
    )

    outframe = pd.concat(
        [  # df_tray['Vial Site'],
            reaction_volumes_output,
            df_tray["Labware ID:"],
            rxn_parameters,
            rxn_conditions,
        ],
        sort=False,
        axis=1,
    )
    temp = tempfile.TemporaryFile()
    # xlwt is no longer maintained and will be removed from pandas in future versions
    # use io.excel.xls.writer as the engine once xlwt is removed
    outframe.to_excel(temp, sheet_name="NIMBUS_reaction", index=False, engine="xlwt")
    temp.seek(0)
    return temp
