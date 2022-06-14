from __future__ import annotations
import os
from typing import List, Any, Type, Dict
from formtools.wizard.views import SessionWizardView
from django.contrib.auth.mixins import LoginRequiredMixin
from core.forms.wizard import (
    ExperimentTemplateSelectForm,
    BaseReagentFormSet,
    ReagentForm,
    VesselForm,
    ManualExperimentForm,
    ActionParameterForm,
    AutomatedSpecificationForm,
    SamplerParametersForm,
    PostProcessForm,
)
from django.shortcuts import render
from django.forms import Form, ValidationError, formset_factory
from django.conf import settings
from django.core.files.storage import FileSystemStorage
from django.http import HttpResponseRedirect
from django.db.models import QuerySet
from django.urls import reverse

from core.models.view_tables import (
    ExperimentTemplate,
    ReagentTemplate,
    ReagentMaterialTemplate,
    PropertyTemplate,
)
from core.dataclass import (
    ExperimentData,
    SELECT_TEMPLATE,
    NUM_OF_EXPS,
    MANUAL_SPEC,
    AUTOMATED_SPEC,
    REAGENT_PARAMS,
    SELECT_VESSELS,
    ACTION_PARAMS,
    POSTPROCESS,
    AUTOMATED_SAMPLER_SPEC,
)
from django.contrib import messages
from core.utilities.utils import get_colors
import pandas as pd

from plugins.sampler.base_sampler_plugin import BaseSamplerPlugin
from plugins.sampler import *


import logging


def check_sampler_selected(wizard):
    # if wizard.steps.current != AUTOMATED_SAMPLER_SPEC:
    cleaned_data = wizard.get_cleaned_data_for_step(AUTOMATED_SPEC) or {}
    return cleaned_data.get("select_experiment_sampler", False)


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
        (AUTOMATED_SAMPLER_SPEC, SamplerParametersForm),
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
    condition_dict = {AUTOMATED_SAMPLER_SPEC: check_sampler_selected}
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
        form_data: Dict[str, Any] = self.get_cleaned_data_for_step(SELECT_TEMPLATE)
        # assert isinstance(form_data, dict)
        if form_data:
            exp_template_uuid: str = form_data["select_experiment_template"]
            self._experiment_template = ExperimentTemplate.objects.get(
                uuid=exp_template_uuid
            )
        return self._experiment_template

    @property
    def all_form_data(self) -> Dict[str, Any]:
        form_data = {
            SELECT_TEMPLATE: self.get_cleaned_data_for_step(SELECT_TEMPLATE),
            SELECT_VESSELS: self.get_cleaned_data_for_step(SELECT_VESSELS),
            ACTION_PARAMS: self.get_cleaned_data_for_step(ACTION_PARAMS),
            REAGENT_PARAMS: self.get_cleaned_data_for_step(REAGENT_PARAMS),
            AUTOMATED_SPEC: self.get_cleaned_data_for_step(AUTOMATED_SPEC),
            # AUTOMATED_SAMPLER_SPEC: self.get_cleaned_data_for_step(
            #    AUTOMATED_SAMPLER_SPEC
            # ),
        }
        return form_data

    def get_form_initial(self, step: str) -> "List[Any]|Dict[str, Any]":
        if step == REAGENT_PARAMS:
            reagent_props = self.experiment_template.get_reagent_templates()
            initial = []
            for i, rt in enumerate(reagent_props):
                reagent_initial = {"reagent_template_uuid": str(rt.uuid)}
                for j, prop in enumerate(rt.properties.all()):
                    reagent_initial.update(
                        {
                            f"reagent_prop_uuid_{j}": prop.uuid,
                            f"reagent_prop_{j}": prop.default_value.nominal_value,
                        }
                    )
                for j, rmt in enumerate(rt.reagent_material_template_rt.all()):
                    rmt: ReagentMaterialTemplate
                    initial_data = {
                        f"reagent_material_template_uuid_{j}": str(rmt.uuid),
                        f"material_type_{j}": str(rmt.material_type.uuid),
                    }
                    for k, prop in enumerate(rmt.properties.all()):
                        prop: PropertyTemplate
                        initial_data[
                            f"reagent_material_prop_{j}_{k}"
                        ] = prop.default_value.nominal_value
                        initial_data[f"reagent_material_prop_uuid_{j}_{k}"] = prop.uuid
                    reagent_initial.update(initial_data)
                initial.append(reagent_initial)
            return initial
        if step == ACTION_PARAMS:
            action_templates = self.experiment_template.get_action_templates(
                source_vessel_decomposable=False, dest_vessel_decomposable=False
            )
            initial = []
            for i, at in enumerate(action_templates):
                action_initial = {"action_template_uuid": at.uuid}
                for j, param_def in enumerate(at.action_def.parameter_def.all()):
                    param_initial = {
                        "action_parameter_{j}": param_def.uuid,
                        "value_{j}": param_def.default_val,
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
        if step == AUTOMATED_SAMPLER_SPEC:
            return self._get_automated_sampler_spec_kwargs()
        if step == POSTPROCESS:
            return self._get_post_processor_kwargs()

        return {}

    def get_template_names(self) -> List[str]:
        return ["core/experiment/create/wizard.html"]

    def get_form(self, step=None, data=None, files=None):
        """Work-around for not having a hook in WizardView.post() before form.is_valid() is called.
        This is done specifically for the sampler but is called after sampler variables are specified,
        if applicable. If the sampler code is run on this step,
        and it fails, the function will add the error to the automated spec form and re-render it. This is not
        possible in the default implementation of WizardView.post()

        Args:
            step (_type_, optional): _description_. Defaults to None.
            data (_type_, optional): _description_. Defaults to None.
            files (_type_, optional): _description_. Defaults to None.

        Returns:
            _type_: _description_
        """
        form = super().get_form(step, data, files)
        """
        if step == None and form.is_valid():
            # form = super().get_form(self.steps.prev, data, files)
            if (
                self.steps.prev != MANUAL_SPEC
                and self.steps.current == AUTOMATED_SAMPLER_SPEC
            ):
                form = self._validate_automated_form(form)
            if self.steps.current == MANUAL_SPEC:
                form = self._validate_manual_form(form)
            # if self.steps.current == POSTPROCESS:
            #    form = self._validate_postprocess_form(form)
        """
        return form

    def _validate_postprocess_form(self, form):
        post_processor_form_data = form.cleaned_data
        return form

    def _validate_manual_form(self, form):
        if "experiment_data" not in self.request.session:
            form.add_error(  # type: ignore
                "file",
                error=ValidationError(
                    "Automated experiments not generated. Please upload a manual file"
                ),
            )
        return form

    def _validate_automated_form(self, form):

        return form

    def process_step(self, form: Form):
        if self.steps.current == AUTOMATED_SAMPLER_SPEC:
            if "experiment_data" in form.cleaned_data:
                self.request.session["experiment_data"] = form.cleaned_data[
                    "experiment_data"
                ]
        if self.steps.current == MANUAL_SPEC:
            experiment_data: ExperimentData = self.request.session["experiment_data"]
            if form.cleaned_data["file"]:
                df_dict = pd.read_excel(form.cleaned_data["file"], sheet_name=None)
                experiment_data.parse_manual_file(df_dict)
            experiment_instance = experiment_data.experiment_instance
            self.request.session["experiment_data"] = experiment_data
        return super().process_step(form)

    def done(self, form_list, **kwargs):
        experiment_data: ExperimentData = self.request.session["experiment_data"]
        experiment_instance = experiment_data.experiment_instance
        # self._run_post_processors(experiment_instance=experiment_instance)
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

    def _get_automated_sampler_spec_kwargs(self) -> "dict[str, Any]":
        automated_spec_form_data = self.get_cleaned_data_for_step(AUTOMATED_SPEC)
        kwargs = {}
        if isinstance(automated_spec_form_data, dict):
            SamplerPlugin: Type[BaseSamplerPlugin] = globals()[
                automated_spec_form_data["select_experiment_sampler"]
            ]
            kwargs["form_kwargs"] = {}
            kwargs["form_kwargs"]["sampler"] = SamplerPlugin
            kwargs["form_kwargs"]["automated_spec_form_data"] = automated_spec_form_data
            kwargs["form_kwargs"]["all_form_data"] = self.all_form_data
            kwargs["form_kwargs"]["request"] = self.request
        return kwargs

    def _get_post_processor_kwargs(self) -> "dict[str, Any]":
        kwargs = {
            "form_kwargs": {
                "experiment_template": self.experiment_template,
                "experiment_data": self.request.session["experiment_data"],
            }
        }
        return kwargs

    def _get_automated_spec_kwargs(self) -> "dict[str, Any]":
        vessel_form_data = self.get_cleaned_data_for_step(SELECT_VESSELS)
        kwargs = {
            "form_kwargs": {
                "vessel_form_data": vessel_form_data,
            }
        }
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

        if self.experiment_template:
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
            for j, rmt in enumerate(
                rt.reagent_material_template_rt.all().order_by(
                    "material_type__description"
                )
            ):
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
                "action_template_uuid": at.uuid,
                "description": at.description,
                "color": colors[i],
                "action_parameter_list": action_parameter_list,
            }

        return kwargs
