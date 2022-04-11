from plugins.sampler.base_sampler_plugin import SamplerPlugin
from uuid import UUID
import core.models.view_tables as vt
from core.models.core_tables import TypeDef
import pandas as pd
from core.utilities.utils import make_well_labels_list
from core.utilities.randomSampling import generateExperiments
from core.utilities.experiment_utils import get_action_parameter_querysets
import tempfile


class WF1SamplerPlugin(SamplerPlugin):
    name = "Statespace sampler for WF1"

    def __init__(self):
        super().__init__()

    @property
    def validation_errors(self):
        pass

    def validate(self, *args, **kwargs):
        return True

    def sample_experiments(self, *args, **kwargs):
        pass
        """
        desired_volume = generateExperiments(
            reagent_template_names,
            reagentDefs,
            num_of_automated_experiments,
            finalVolume=str(total_volume.value) + " " + total_volume.unit,
        )

        # retrieve q1 information to update
        q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)

        # This loop sums the volume of all generated experiment for each reagent and saves to database
        # Also saves dead volume if passed to function
        reagents = Reagent.objects.filter(experiment=experiment_copy_uuid)
        for reagent in reagents:
            # label = reagent_template_reagent_map[reagent.template.description]
            prop = reagent.property_r.get(template__description__icontains="total volume")
            prop.nominal_value.value += sum(desired_volume[reagent.template.description])
            prop.nominal_value.unit = "uL"
            prop.save()
            if dead_volume is not None:
                dv_prop = reagent.property_r.get(
                    template__description__icontains="dead volume"
                )
                dv_prop.nominal_value = dead_volume
                dv_prop.save()

        # This loop adds individual well volmes to each action in the database
        # without overwriting manual entries for experiments that have both automated and manual components

        # for action_description, (reagent_name, mult_factor) in action_reagent_map.items():
        well_list = make_well_labels_list(
            well_count=vessel.well_number,
            column_order=vessel.column_order,
            robot="True",
        )

        for reagent_name in reagent_template_names:
            saved_actions = []
            for i, vial in enumerate(well_list):
                action = (
                    q1.filter(action_unit_description__icontains=reagent_name)
                    .filter(action_unit_description__icontains="dispense")
                    .filter(action_unit_description__endswith=vial)
                    .first()
                )

                # get actions from q1 based on keys in action_reagent_map

                # If number of experiments requested is < actions only choose the first n actions
                # Otherwise choose all
                # actions = actions[:num_of_experiments] if num_of_experiments < len(actions) else actions
                # for i, action in enumerate(actions):
                if action is not None:
                    saved_actions.append(action)

            for i, action in enumerate(saved_actions[num_of_manual_experiments:]):

                parameter = Parameter.objects.get(uuid=action.parameter_uuid)
                # action.parameter_value.value = desired_volume[reagent_name][i] * mult_factor
                try:
                    parameter.parameter_val_nominal.value = desired_volume[reagent_name][
                        i
                    ]  # * mult_factor
                except IndexError:
                    parameter.parameter_val_nominal.value = 0.0
                parameter.save()

        # conc_to_amount(experiment_copy_uuid)

        return q1
        """
