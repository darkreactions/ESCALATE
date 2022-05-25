from plugins.robot.base_robot_plugin import RobotPlugin
from uuid import UUID
from django.db.models import QuerySet
import core.models.view_tables as vt
from core.models.core_tables import TypeDef
import pandas as pd
from core.utilities.utils import make_well_labels_list
import tempfile


class NimbusWF1RobotPlugin(RobotPlugin):
    name = "NIMBUS Robot for WF1"

    def __init__(self):
        super().__init__()

    @property
    def validation_errors(self):
        return self._error_message

    def validate(self, experiment_instance: "vt.ExperimentInstance"):
        # if experiment_instance.
        return True

    def robot_file(self, experiment_instance: "vt.ExperimentInstance"):
        robotfile_blob = self._generate_robot_file_wf1(experiment_instance)
        doc_type = TypeDef.objects.get(category="file", description="text")
        robotfile_edoc, created = vt.Edocument.objects.get_or_create(
            title=f"Nimbus Robot file for WF1: {experiment_instance.description}",
            filename=f"{experiment_instance.uuid}_{experiment_instance.description}_RobotInput.xls",
            ref_edocument_uuid=experiment_instance.uuid,
            edoc_type_uuid=doc_type,
        )
        robotfile_edoc.edocument = robotfile_blob.read()
        robotfile_edoc.save()
        robotfile_uuid = robotfile_edoc.pk

        return robotfile_uuid, ""

    def _generate_robot_file_wf1(self, experiment_instance: "vt.ExperimentInstance"):
        parameters = experiment_instance.get_action_parameters(decomposable=False)
        volume_parameters = experiment_instance.get_action_parameters(decomposable=True)

        rp_keys = []
        rp_values = []
        for i, au in enumerate(parameters):
            for param in au.parameter_au.all():
                rp_keys.append(param.parameter_def.description)
                rp_values.append(param.parameter_val_nominal.value)

        rxn_parameters = pd.DataFrame(
            {"Reaction Parameters": rp_keys, "Parameter Values": rp_values}
        )

        well_names = make_well_labels_list(
            96,
            column_order=["A", "C", "E", "G", "B", "D", "F", "H"],
            robot="True",
        )
        df_tray = pd.DataFrame(
            {"Vial Site": well_names, "Labware ID:": "Symyx_96_well_0003"}
        )

        reagent_colnames = [f"Reagent{i} (ul)" for i in range(1, 9)]
        reaction_volumes_output = pd.DataFrame(
            {reagent_col: [0] * len(df_tray) for reagent_col in reagent_colnames}
        )

        if volume_parameters is not None:
            reaction_volumes_output = pd.concat(
                [df_tray["Vial Site"], reaction_volumes_output], axis=1
            )
            # Keep this Acid Volume 1/Acid Volume 2, do not change to acid vol
            REAG_MAPPING = {
                "Dispense Reagent 2 - Stock A": 2,
                "Dispense Reagent 3 - Stock B": 3,
                "Dispense Reagent 1 - Solvent": 1,
                "Dispense Reagent 7 - Acid Volume 1": 6,
                "Dispense Reagent 7 - Acid Volume 2": 7,
            }
            # source material -> Reagent number, vial_site -> row name
            for action_name, reagent_num in REAG_MAPPING.items():

                action_units = volume_parameters.filter(
                    action__template__description=action_name
                )
                for au in action_units:
                    reaction_volumes_output.loc[
                        reaction_volumes_output["Vial Site"]
                        == au.destination_material.vessel.vessel.description,
                        f"Reagent{reagent_num} (ul)",
                    ] = au.parameter_au.get(
                        parameter_def__description="volume"
                    ).parameter_val_nominal.value

        rxn_conditions = pd.DataFrame(
            {
                "Reagents": [f"Reagent{i}" for i in range(1, 10)],
                "Reagent identity": [f"{i}" for i in range(1, 10)],
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
        outframe.to_excel(
            temp, sheet_name="NIMBUS_reaction", index=False, engine="xlwt"
        )
        temp.seek(0)
        return temp