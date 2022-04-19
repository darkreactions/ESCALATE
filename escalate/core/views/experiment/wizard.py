from __future__ import annotations
from distutils.command.clean import clean
from keyword import kwlist
import os
from typing import List, Any
from formtools.wizard.views import SessionWizardView
from django.contrib.auth.mixins import LoginRequiredMixin
from core.forms.wizard import (
    ExperimentTemplateSelectForm,
    NumberOfExperimentsForm,
    BaseReagentFormSet,
    ReagentForm,
    VesselForm,
    ManualExperimentForm,
    ActionParameterForm,
    AutomatedSpecificationForm,
    PostProcessForm,
)
from django.shortcuts import render
from django.forms import BaseFormSet, formset_factory
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponseRedirect
from django.db.models import Prefetch, QuerySet
from django.urls import reverse
from core.models.view_tables import (
    ExperimentTemplate,
    ReagentTemplate,
    ExperimentInstance,
    BillOfMaterials,
    ReagentMaterialTemplate,
    VesselTemplate,
    ReagentMaterial,
    InventoryMaterial,
    ParameterDef,
    Parameter,
    ActionUnit,
    Actor,
    VesselInstance,
    PropertyTemplate,
)
from core.models.app_tables import CustomUser
from django.contrib import messages
from django.core.exceptions import ObjectDoesNotExist
from core.utilities.utils import experiment_copy, get_colors
import pandas as pd

#steps with names to display in UI
SELECT_TEMPLATE = "Select Experiment Template"
NUM_OF_EXPS = "Set Number of Experiments"
MANUAL_SPEC = "Specify Manual Experiments"
AUTOMATED_SPEC = "Specify Automated Experiments"
REAGENT_PARAMS = "Specify Reagent Parameters"
SELECT_VESSELS = "Select Vessels"
ACTION_PARAMS = "Specify Action Parameters"
POSTPROCESS = "Select Postprocessors"


class CreateExperimentWizard(LoginRequiredMixin, SessionWizardView):
    file_storage = FileSystemStorage(
        location=os.path.join(settings.MEDIA_ROOT, "uploaded_files")
    )
    form_list = [
        (SELECT_TEMPLATE, ExperimentTemplateSelectForm),
        (
            SELECT_VESSELS,
            formset_factory(
                VesselForm,
                extra=0,
                formset=BaseReagentFormSet,
            ),
        ),
        (
            REAGENT_PARAMS,
            formset_factory(
                ReagentForm,
                extra=0,
                formset=BaseReagentFormSet,
            ),
        ),
        (
            ACTION_PARAMS,
            formset_factory(
                ActionParameterForm,
                extra=0,
                formset=BaseReagentFormSet,
            ),
        ),
        (AUTOMATED_SPEC, AutomatedSpecificationForm),
        (MANUAL_SPEC, ManualExperimentForm),
        (
            POSTPROCESS,
            formset_factory(
                PostProcessForm,
                extra=1,
                formset=BaseReagentFormSet,
            ),
        ),
    ]
    initial_dict: "dict[str, Any]"

    def __init__(self, *args, **kwargs):
        self._experiment_template = None
        super().__init__(*args, **kwargs)

    def get(self, request, *args, **kwargs):

        org_id = self.request.session.get("current_org_id", None)
        if not org_id:
            messages.error(request, "Please select a lab to continue")
            return HttpResponseRedirect(reverse("main_menu"))
        return super().get(request, *args, **kwargs)

    @property
    def experiment_template(self) -> "ExperimentTemplate":
        form_data = self.get_cleaned_data_for_step("select_template")
        if form_data:
            exp_template_uuid: str = form_data["select_experiment_template"]
            self._experiment_template = ExperimentTemplate.objects.get(
                uuid=exp_template_uuid
            )
        return self._experiment_template

    def get_form_initial(self, step: str) -> List[Any]:
        if step == REAGENT_PARAMS:
            reagent_props = self.experiment_template.get_reagent_templates()
            initial = []
            for i, rt in enumerate(reagent_props):
                reagent_initial = {}
                for j, prop in enumerate(rt.properties.all()):
                    reagent_initial.update(
                        {
                            f"reagent_template_uuid_{i}_{j}": str(prop.uuid),
                            f"reagent_prop_{i}_{j}": prop.default_value.nominal_value,
                        }
                    )
                for j, rmt in enumerate(rt.reagent_material_template_rt.all()):
                    rmt: ReagentMaterialTemplate
                    initial_data = {
                        f"reagent_material_template_uuid_{i}_{j}": str(rmt.uuid),
                        f"material_type_{i}_{j}": str(rmt.material_type.uuid),
                        # f"desired_concentration_{i}_{j}": rmt.properties.get(
                        #    description="concentration"
                        # ).default_value.nominal_value,
                    }
                    for prop in rmt.properties.all():
                        prop: PropertyTemplate
                        initial_data[
                            f"{prop.description}_{i}_{j}"
                        ] = prop.default_value.nominal_value
                    reagent_initial.update(initial_data)
                initial.append(reagent_initial)
            return initial
        if step == ACTION_PARAMS:
            action_templates = self.experiment_template.get_action_templates(
                source_vessel_decomposable=False, dest_vessel_decomposable=False
            )
            initial = []
            for i, at in enumerate(action_templates):
                action_initial = {}
                for j, param_def in enumerate(at.action_def.parameter_def.all()):
                    param_initial = {
                        "action_parameter_{i}_{j}": param_def.uuid,
                        "value_{i}_{j}": param_def.default_val,
                    }
                    action_initial.update(param_initial)
                initial.append(action_initial)

            return initial

        return super().get_form_initial(step)

    def get_form_kwargs(self, step=None) -> "dict[str, Any]":
        if step == SELECT_TEMPLATE:
            org_id = self.request.session.get("current_org_id", None)
            return {"org_id": org_id}
        if step == NUM_OF_EXPS:
            return self._get_num_exps_form_kwargs()
        if step == REAGENT_PARAMS:
            return self._get_reagent_form_kwargs()
        if step == SELECT_VESSELS:
            return self._get_vessel_form_kwargs()
        if step == ACTION_PARAMS:
            return self._get_action_parameters_kwargs()
        if step == MANUAL_SPEC:
            return self._get_manual_spec_kwargs()
        if step == AUTOMATED_SPEC:
            return self._get_automated_spec_kwargs()
        if step == POSTPROCESS:
            return self._get_post_processor_kwargs()

        return {}

    def get_template_names(self) -> List[str]:
        return ["core/experiment/create/wizard.html"]

    def process_step(self, form):
        if self.steps.current == MANUAL_SPEC:
            form_data = self.get_form_step_data(form)
        return super().process_step(form)

    def done(self, form_list, **kwargs):
        cleaned_data = self.get_cleaned_data_for_step(SELECT_TEMPLATE)
        assert isinstance(cleaned_data, dict)
        exp_template_uuid: str = cleaned_data["select_experiment_template"]
        exp_name = cleaned_data["experiment_name"]

        vessels = {}
        vessel_form_data = self.get_cleaned_data_for_step(SELECT_VESSELS)
        assert isinstance(vessel_form_data, list)
        for vf_data in vessel_form_data:
            vt = VesselTemplate.objects.get(uuid=vf_data["template_uuid"])
            vessels[vt.description] = vf_data["value"]

        instance_uuid = experiment_copy(exp_template_uuid, exp_name, vessels)
        self._save_forms(instance_uuid)
        experiment_instance = ExperimentInstance.objects.get(uuid=instance_uuid)
        context = {
            "new_exp_name": experiment_instance.description,
            "experiment_link": reverse(
                "experiment_instance_view", args=[experiment_instance.uuid]
            ),
            "reagent_prep_link": reverse(
                "reagent_prep", args=[experiment_instance.uuid]
            ),
            "outcome_link": reverse("outcome", args=[experiment_instance.uuid]),
        }

        return render(self.request, "core/experiment/create/done.html", context=context)

    def _get_post_processor_kwargs(self) -> "dict[str, Any]":
        kwargs = {"form_kwargs": {"experiment_template": self.experiment_template}}
        # kwargs = {}
        return kwargs

    def _get_automated_spec_kwargs(self) -> "dict[str, Any]":
        vessel_form_data = self.get_cleaned_data_for_step(SELECT_VESSELS)
        kwargs = {"form_kwargs": {"vessel_form_data": vessel_form_data}}
        return kwargs

    def _get_manual_spec_kwargs(self) -> "dict[str, Any]":
        vessel_form_data = self.get_cleaned_data_for_step(SELECT_VESSELS)
        assert isinstance(vessel_form_data, list)
        vessel_dict_data = {}
        for vessel_data in vessel_form_data:
            vessel_dict_data[vessel_data["template_uuid"]] = str(
                vessel_data["value"].uuid
            )

        self.request.session["experiment_create_form_data"] = {
            "vessels": vessel_dict_data,
            "experiment_template": self.get_cleaned_data_for_step(SELECT_TEMPLATE),
        }
        return {
            "vessels": vessel_form_data,
            "experiment_template": self.get_cleaned_data_for_step(SELECT_TEMPLATE),
        }

    def _get_num_exps_form_kwargs(self) -> "dict[str, Any]":
        kwargs = {"form_kwargs": {"experiment_template": self.experiment_template}}
        return kwargs

    def _get_vessel_form_kwargs(self) -> "dict[str, Any]":
        kwargs = {"form_kwargs": {"vt_names": []}}
        self.initial_dict[SELECT_VESSELS] = []

        for vt in self.experiment_template.vessel_templates.all():
            kwargs["form_kwargs"]["vt_names"].append(vt.description)
            self.initial_dict[SELECT_VESSELS].append(
                {"value": vt.default_vessel, "template_uuid": str(vt.uuid)}
            )
        colors = get_colors(self.experiment_template.vessel_templates.count())
        kwargs["form_kwargs"]["colors"] = colors
        return kwargs

    def _get_reagent_form_kwargs(self) -> "dict[str, Any]":
        """
        Returns the kwargs related to reagent forms
        """

        reagent_templates: "QuerySet[ReagentTemplate]" = (
            self.experiment_template.get_reagent_templates()
        )
        # Creating a form_kwargs key because that's what gets passed into the
        # FormSet. "form_data" key represents data for all reagents and other keys
        # on the same level e.g. "lab_uuid" can be used to pass other parameters
        kwargs = {
            "form_kwargs": {
                "form_data": {},
                "lab_uuid": self.request.session["current_org_id"],
            }
        }
        kwargs["form_kwargs"]["experiment_template"] = self.experiment_template
        colors = get_colors(len(reagent_templates))
        for i, rt in enumerate(reagent_templates):
            kwargs["form_kwargs"]["form_data"][str(i)] = {
                "description": rt.description,
                "color": colors[i],
            }
            mat_types_list = []
            for j, rmt in enumerate(rt.reagent_material_template_rt.all()):
                mat_types_list.append(rmt.material_type.description)

            kwargs["form_kwargs"]["form_data"][str(i)][
                "mat_types_list"
            ] = mat_types_list
            kwargs["form_kwargs"]["form_data"][str(i)]["reagent_template"] = rt

        return kwargs

    def _get_action_parameters_kwargs(self):
        kwargs = {
            "form_kwargs": {
                "form_data": {},
                "lab_uuid": self.request.session["current_org_id"],
            }
        }
        action_templates = self.experiment_template.get_action_templates(
            source_vessel_decomposable=False, dest_vessel_decomposable=False
        )

        colors = get_colors(len(action_templates))

        for i, at in enumerate(action_templates):
            action_parameter_list = []
            for j, pd in enumerate(at.action_def.parameter_def.all()):
                action_parameter_list.append(pd.uuid)
            kwargs["form_kwargs"]["form_data"][str(i)] = {
                "description": at.description,
                "color": colors[i],
                "action_parameter_list": action_parameter_list,
            }

        return kwargs

    def _save_forms(self, instance_uuid: str):
        exp_instance = ExperimentInstance.objects.select_related().get(
            uuid=instance_uuid
        )
        # Get the operator and save
        user: CustomUser = self.request.user  # type: ignore
        operator = Actor.objects.get(
            person=user.person,
            organization__uuid=self.request.session["current_org_id"],
        )
        exp_instance.operator = operator
        exp_instance.save()
        # Save data from reagent_params, action_params and manual_spec
        self._save_vessels(exp_instance)
        self._save_reagents(exp_instance)
        self._save_action_params(exp_instance)
        self._save_manual_experiments(exp_instance)

    def _save_vessels(self, exp_instance: ExperimentInstance) -> None:
        cleaned_data = self.get_cleaned_data_for_step(SELECT_VESSELS)
        assert isinstance(cleaned_data, list)
        for vessel_data in cleaned_data:
            vessel = vessel_data["value"]
            vessel_template_uuid = vessel_data["template_uuid"]
            vessel_template = VesselTemplate.objects.get(uuid=vessel_template_uuid)
            VesselInstance.objects.create(
                vessel=vessel,
                vessel_template=vessel_template,
                experiment_instance=exp_instance,
            )

    def _save_manual_experiments(self, exp_instance):
        cleaned_data = self.get_cleaned_data_for_step(MANUAL_SPEC)
        assert isinstance(cleaned_data, dict)
        if cleaned_data["file"] is not None:
            df_data = pd.read_excel(cleaned_data["file"], sheet_name=None)
            reverse_meta_data = dict(
                zip(df_data["meta_data"]["values"], df_data["meta_data"]["keys"])
            )
            meta_data = dict(
                zip(df_data["meta_data"]["keys"], df_data["meta_data"]["values"])
            )
            manual_data = df_data[exp_instance.template.description]
            action_units = ActionUnit.objects.filter(
                action__experiment=exp_instance
            ).prefetch_related("parameter_au")

            # Find the action unit corresponding to the excel cell
            for action in exp_instance.action_ei.filter(
                template__dest_vessel_decomposable=True
            ).prefetch_related("template__action_def__parameter_def"):
                # reconstruct columns name
                action_column_name = reverse_meta_data[str(action.template.uuid)]
                for param_def in action.template.action_def.parameter_def.all():
                    # Get the expected value and unit column names from meta_data
                    param_value_column_name = reverse_meta_data[
                        f"value:{param_def.uuid}:{action.template.uuid}"
                    ]
                    param_unit_column_name = reverse_meta_data[
                        f"unit:{param_def.uuid}:{action.template.uuid}"
                    ]

                    # Loop through every row (destination vessel), get the value and unit from dataframe
                    # and then store it in the appropriate action unit parameter in the database
                    for i, dest_vessel_name in enumerate(
                        manual_data[action_column_name]
                    ):
                        dest_vessel_uuid = meta_data[dest_vessel_name]
                        au = action_units.get(
                            destination_material__vessel__uuid=dest_vessel_uuid,
                            action__template=action.template,
                        )
                        param = au.parameter_au.get(parameter_def=param_def)
                        param.parameter_val_nominal.value = manual_data[
                            param_value_column_name
                        ].iloc[i]
                        param.parameter_val_nominal.unit = manual_data[
                            param_unit_column_name
                        ].iloc[i]
                        param.save()

    def _save_action_params(self, exp_instance: ExperimentInstance):
        cleaned_data = self.get_cleaned_data_for_step(REAGENT_PARAMS)
        assert isinstance(cleaned_data, list)
        for action_param_data in cleaned_data:
            for key, value in action_param_data.items():
                if key.startswith("parameter_uuid"):
                    action_num, param_num = key.split("_")[-2:]
                    param_def = ParameterDef.objects.get(uuid=value)
                    param = Parameter.objects.get(
                        parameter_def=param_def,
                        action_unit__action__experiment=exp_instance,
                    )
                    param.value = action_param_data[f"value_{action_num}_{param_num}"]
                    param.save()

    def _save_reagents(
        self,
        exp_instance: ExperimentInstance,
    ):
        cleaned_data = self.get_cleaned_data_for_step(REAGENT_PARAMS)
        assert isinstance(cleaned_data, list)
        for reagent_data in cleaned_data:
            for key, value in reagent_data.items():
                if key.startswith("reagent_material_template_uuid"):
                    reagent_num, reagent_material_num = key.split("_")[-2:]
                    rmt = ReagentMaterialTemplate.objects.get(uuid=value)
                    rm = ReagentMaterial.objects.get(
                        template=rmt, reagent__experiment=exp_instance
                    )
                    rm.material = InventoryMaterial.objects.get(
                        uuid=reagent_data[
                            f"material_{reagent_num}_{reagent_material_num}"
                        ]
                    )
                    rm.save()
                    # TODO: generalize concentration to any property that a reagentmaterial has
                    suffix = f"_{reagent_num}_{reagent_material_num}"
                    for k in reagent_data:
                        if k.endswith(suffix):
                            prop_name = k[: -len(suffix)]
                            try:
                                prop = rm.property_rm.get(
                                    template__description=prop_name
                                )
                                prop.nominal_value = reagent_data[k]
                                prop.save()
                            except ObjectDoesNotExist:
                                continue
