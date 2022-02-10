from core.models.view_tables import Edocument
from core.models.core_tables import TypeDef
import tempfile
import pandas as pd
from core.models.view_tables import ReactionParameter
from core.utilities.wf1_utils import make_well_list

#


def workflow_3(data, q1, experiment_copy_uuid, exp_name, exp_template):
    robotfile_blob = generate_robot_file_wf3(q1, data, "Symyx_96_well_0003", 96)
    doc_type = TypeDef.objects.get(category="file", description="text")
    robotfile_edoc = Edocument(
        title=f"{experiment_copy_uuid}_{exp_name}_RobotInput.xls",
        filename=f"{experiment_copy_uuid}_{exp_name}_RobotInput.xls",
        ref_edocument_uuid=experiment_copy_uuid,
        edocument=robotfile_blob.read(),
        edoc_type_uuid=doc_type,
    )
    robotfile_edoc.save()
    robotfile_uuid = robotfile_edoc.pk

    return robotfile_uuid, ""


def generate_robot_file_wf3(
    reaction_volumes, reaction_parameters, plate_name, well_count
):
    reaction_parameters = ReactionParameter.objects.filter(
        experiment_uuid=reaction_volumes[0].experiment_uuid
    )
    if len(reaction_parameters) == 0:
        rxn_parameters = pd.DataFrame(
            {
                "Reaction Parameters": [
                    "Temperature (C):",
                    "Stir Rate (rpm):",
                    "Mixing time1 (s):",
                ],
                "Parameter Values": [70, 750, 900],
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
            "Dispense Reagent 1 - Solvent": 1,
            "Dispense Reagent 2 - Stock A": 2,
            "Dispense Reagent 3 - Stock B": 3,
            "Dispense Reagent 7 - Acid Volume 1": 7,
            "Dispense Reagent 9 - Antisolvent": 9,
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
                "StandardVolume_Water_DispenseJet_Empty",
                "StandardVolume_Water_DispenseJet_Empty",
                "StandardVolume_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "Tip_50ul_Water_DispenseJet_Empty",
                "StandardVolume_Water_DispenseJet_Empty",
                "HighVolume_Water_DispenseJet_Empty",
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
