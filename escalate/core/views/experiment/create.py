from __future__ import annotations
import re
import traceback
from math import e, exp
from typing import Any, Type
import json
import pandas as pd
from django.forms.forms import Form
from django.http.response import FileResponse
from django.http.request import HttpRequest
from django.http import HttpResponseRedirect

from django.views.generic import TemplateView
from django.forms import formset_factory, BaseFormSet
from django.shortcuts import render, redirect
from django.contrib import messages
from django.urls import reverse

from core.models.view_tables import (
    ExperimentTemplate,
    Actor,
    ReagentMaterial,
    InventoryMaterial,
    Vessel,
    VesselType,
    ExperimentActionSequence,
    Action,
    ActionUnit,
    BaseBomMaterial,
)

from core.models.app_tables import ActionSequenceDesign

from core.forms.custom_types import (
    SingleValForm,
    InventoryMaterialForm,
    NominalActualForm,
    ExperimentNameForm,
    ExperimentTemplateForm,
    ReagentForm,
    BaseReagentFormSet,
    VesselForm,
    ReactionParameterForm,
    RobotForm,
)

from core.utilities.utils import experiment_copy
from core.utilities.experiment_utils import (
    get_action_parameter_querysets,
    get_material_querysets,
    prepare_reagents,
    generate_experiments_and_save,
    save_reaction_parameters,
    save_manual_volumes,
    save_manual_parameters,
    save_parameter,
)
from core.utilities.calculations import conc_to_amount
from core.utilities.utils import make_well_labels_list
from core.models.view_tables.generic_data import Parameter
from core.views.experiment.create_select_template import SelectReagentsView
from .misc import save_forms_q1, save_forms_q_material

import core.models
import core.experiment_templates


SUPPORTED_CREATE_WFS = [
    mod for mod in dir(core.experiment_templates) if "__" not in mod
]


class SetupExperimentView(TemplateView):
    template_name = "core/create_experiment.html"

    def get(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        org_id = self.request.session.get("current_org_id", None)
        if org_id:
            context["experiment_template_select_form"] = ExperimentTemplateForm(
                org_id=org_id
            )
            context["vessel_form"] = VesselForm()
        else:
            messages.error(request, "Please select a lab to continue")
            return HttpResponseRedirect(reverse("main_menu"))

        return render(request, self.template_name, context)


class CreateExperimentView(TemplateView):
    template_name = "core/experiment/create/base_create.html"
    form_class = ExperimentTemplateForm
    MaterialFormSet: Type[BaseFormSet] = formset_factory(InventoryMaterialForm, extra=0)
    NominalActualFormSet: Type[BaseFormSet] = formset_factory(
        NominalActualForm, extra=0
    )
    ReagentFormSet: Type[BaseFormSet] = formset_factory(
        ReagentForm, extra=0, formset=BaseReagentFormSet
    )
    ReactionParameterFormset: Type[BaseFormSet] = formset_factory(
        ReactionParameterForm, extra=0
    )

    def get_context_data(self, **kwargs):
        # Select templates that belong to the current lab
        context = super().get_context_data(**kwargs)
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            lab = Actor.objects.get(organization=org_id, person__isnull=True)
            self.all_experiments = ExperimentTemplate.objects.filter(lab=lab)
        else:
            org_id = None
            self.all_experiments = ExperimentTemplate.objects.all()
        # lab = Actor.objects.get(organization=org_id, person__isnull=True)
        # self.all_experiments = ExperimentTemplate.objects.filter(lab=lab)
        context["all_experiments"] = self.all_experiments
        return context

    def post(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        exp_template = ExperimentTemplate.objects.get(
            uuid=request.session["experiment_template_uuid"]
        )
        exp_name_form = ExperimentNameForm(request.POST)

        if exp_name_form.is_valid():
            context["new_exp_name"] = exp_name_form.cleaned_data["exp_name"]
        try:
            num_automated = int(request.POST.get("automated", 0))
            num_manual = int(request.POST.get("manual", 0))
            context["vessel"] = Vessel.objects.get(
                description=request.POST.get("vessel")
            )

            if num_automated:
                context = self.process_automated_formsets(request, context)
            if num_manual:
                context = self.process_manual_formsets(exp_template, request, context)

            context = self.populate_links(
                context, exp_template, context["exp_uuid"], context["new_exp_name"]
            )

        except Exception as e:
            # If there is an issue with the form above, redirect back to previous step
            traceback.print_exc()
            srv = SelectReagentsView()
            response = srv.post(request)
            response["HX-Trigger"] = json.dumps({"showMessage": {"message": str(e)}})
            return response
        return render(request, self.template_name, context)

    def save_reagents(
        self,
        exp_template: ExperimentTemplate,
        vessel,
        request: HttpRequest,
        org_id: str,
    ) -> tuple[Any]:
        formsets = []
        reagent_template_names = []
        for index, form in enumerate(
            exp_template.reagent_templates.all().order_by("description")
        ):
            reagent_template_names.append(form.description)
            mat_types_list = []
            for (
                reagent_material_template
            ) in form.reagent_material_template_rt.all().order_by("description"):
                for (
                    reagent_material_value_template
                ) in reagent_material_template.reagent_material_value_template_rmt.filter(
                    description="concentration"
                ):
                    mat_types_list.append(reagent_material_template.material_type)
            formsets.append(
                self.ReagentFormSet(
                    request.POST,
                    prefix=f"reagent_{index}",
                    form_kwargs={
                        "lab_uuid": org_id,
                        "mat_types_list": mat_types_list,
                        "reagent_index": index,
                    },
                )
            )
        exp_name_form = ExperimentNameForm(request.POST)

        if exp_name_form.is_valid():
            exp_name = exp_name_form.cleaned_data["exp_name"]

            self.generate_action_units(exp_template, vessel)

            # make the experiment copy: this will be our new experiment
            experiment_copy_uuid = experiment_copy(
                str(exp_template.uuid), exp_name, vessel
            )
            reagentDefs = []
            for reagent_formset in formsets:
                if reagent_formset.is_valid():

                    self.save_forms_reagent(reagent_formset, experiment_copy_uuid)
                    # try:
                    rd = prepare_reagents(reagent_formset)
                    if rd not in reagentDefs:
                        reagentDefs.append(rd)
                    # except TypeError as te:
                    # messages.error(request, str(te))

            dead_volume_form = SingleValForm(request.POST, prefix="dead_volume")
            if dead_volume_form.is_valid():
                dead_volume = dead_volume_form.cleaned_data["value"]
            else:
                dead_volume = None

            total_volume_form = SingleValForm(request.POST, prefix="total_volume")
            if total_volume_form.is_valid():
                total_volume = total_volume_form.cleaned_data["value"]
            else:
                total_volume = None
        return (
            experiment_copy_uuid,
            exp_name_form,
            dead_volume,
            total_volume,
            reagent_template_names,
            reagentDefs,
            # vessel,
        )

    def generate_action_units(self, exp_template, vessel):
        action_sequences = []
        eas = ExperimentActionSequence.objects.filter(experiment_template=exp_template)
        for i in eas:
            action_sequences.append(i.action_sequence)

        for i in action_sequences:
            actions = ActionSequenceDesign.objects.filter(action_sequence=i)
        if actions.exists():
            for a in actions:
                action = Action.objects.filter(
                    description=a.description, action_sequence=i
                )[0]

                # source = a.properties.split(":")[1].split(",")[0]
                # destination = a.properties.split(":")[2].split("}")[0]
                if a.source is not None:
                    source_bbm = BaseBomMaterial.objects.create(description=a.source)
                else:
                    source_bbm = None

                if "wells" in a.destination:  # individual well-level actions
                    plate = Vessel.objects.get(uuid=vessel.uuid)
                    # plate = Vessel.objects.get(description=destination.split(" -")[0])
                    # plate, created = Vessel.objects.get_or_create(
                    # description=destination.split("wells")[0]
                    # )
                    # well_count = int(destination.split(" ")[0])
                    well_list = make_well_labels_list(
                        well_count=plate.well_number,
                        column_order=plate.column_order,
                        robot="True",
                    )
                    plate_wells = {}
                    for well in well_list:
                        plate_wells[well] = Vessel.objects.create(
                            parent=plate, description=well
                        )
                    for well_desc, well_vessel in plate_wells.items():
                        destination_bbm = BaseBomMaterial.objects.create(
                            description=f"{plate.description} : {well_desc}",
                            vessel=well_vessel,
                        )
                        if source_bbm:
                            description = f"{action.description} : {source_bbm.description} -> {destination_bbm.description}"
                        else:
                            description = (
                                f"{action.description} : {destination_bbm.description}"
                            )
                        au = ActionUnit.objects.get_or_create(
                            action=action,
                            source_material=source_bbm,
                            destination_material=destination_bbm,
                            description=action.description,
                        )
                        # au.save()
                else:
                    vessel_types = []
                    for vt in VesselType.objects.all():
                        vessel_types.append(vt.description)
                    # if "plate" in destination:  # plate-level actions
                    if a.destination in vessel_types:

                        vessel = Vessel.objects.get(uuid=vessel.uuid)

                        # if "plate" in destination:  # plate-level actions
                        # plate, created = Vessel.objects.get_or_create(
                        # description=destination
                        # )
                        destination_bbm = BaseBomMaterial.objects.create(
                            description=vessel.description, vessel=vessel
                        )
                        if source_bbm:
                            description = f"{action.description} : {source_bbm.description} -> {destination_bbm.description}"
                        else:
                            description = (
                                f"{action.description} : {destination_bbm.description}"
                            )

                        au = ActionUnit.objects.get_or_create(
                            action=action,
                            source_material=source_bbm,
                            description=description,
                            destination_material=destination_bbm,
                        )
                        # au.save()

                    else:
                        # if destination is not a vessel
                        destination_bbm = BaseBomMaterial.objects.create(
                            description=a.destination
                        )
                        if source_bbm:
                            description = f"{action.description} : {source_bbm.description} -> {destination_bbm.description}"
                        else:
                            description = (
                                f"{action.description} : {destination_bbm.description}"
                            )
                        au = ActionUnit.objects.get_or_create(
                            action=action,
                            source_material=source_bbm,
                            description=description,
                            destination_material=destination_bbm,
                        )

                        # au.save()

    def save_reaction_parameters(
        self, request, experiment_copy_uuid, exp_name_form, exp_template
    ):
        if exp_name_form.is_valid():
            # post reaction parameter form
            # get label here and get form out of label, use label for description
            rp_wfs = get_action_parameter_querysets(exp_template.uuid)
            index = 0
            for rp in rp_wfs:
                rp_label = str(rp.object_description)
                if "Dispense" in rp_label:
                    continue
                else:
                    rp_form = ReactionParameterForm(
                        request.POST, prefix=f"reaction_parameter_{index}"
                    )
                    if rp_form.is_valid:
                        rp_value = rp_form.data[f"reaction_parameter_{index}-value_0"]
                        rp_unit = rp_form.data[f"reaction_parameter_{index}-value_1"]
                        rp_type = rp_form.data[f"reaction_parameter_{index}-value_2"]
                        rp_uuid = rp_form.data[f"reaction_parameter_{index}-uuid"]
                        save_reaction_parameters(
                            exp_template,
                            rp_value,
                            rp_unit,
                            rp_type,
                            rp_label,
                            experiment_copy_uuid,
                        )
                        # The rp_uuid is not being generated from the loadscript for some parameters
                        # This issue stems from the data being loaded in. This function will work once we fix loading issues
                        if rp_uuid != "":
                            save_parameter(rp_uuid, rp_value, rp_unit)
                    index += 1

    def process_manual_formsets(self, exp_uuid, request, context):
        # context["robot_file_upload_form"] = UploadFileForm()
        # context["robot_file_upload_form_helper"] = UploadFileForm.get_helper()

        # context["robot_file_upload_form"] = RobotForm(
        #    request.POST, request.FILES)
        # context["robot_file_upload_form_helper"] = RobotForm.get_helper()

        exp_template = ExperimentTemplate.objects.get(uuid=exp_uuid)
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
        else:
            org_id = None

        vessel = context["vessel"]
        (
            experiment_copy_uuid,
            exp_name_form,
            dead_volume,
            total_volume,
            reagent_template_names,
            reagentDefs,
            # vessel,
        ) = self.save_reagents(exp_template, vessel, request, org_id)

        # self.save_reaction_parameters(
        # request, experiment_copy_uuid, exp_name_form, exp_template
        # )
        context["exp_uuid"] = experiment_copy_uuid

        file_form = RobotForm(request.POST, request.FILES)
        if file_form.is_valid():
            df = pd.read_excel(file_form.cleaned_data["file"])
            # df = pd.read_excel(request.FILES["file"])
        # self.process_robot_file(df)

        save_manual_volumes(
            df, experiment_copy_uuid, reagent_template_names, dead_volume
        )

        save_manual_parameters(df, exp_template, experiment_copy_uuid)

        conc_to_amount(experiment_copy_uuid)

        return context

    def save_forms_reagent(self, formset, exp_uuid):
        form: Form
        for form in formset:
            if form.has_changed():
                data = form.cleaned_data
                reagent_template_uuid = data["reagent_template_uuid"]
                reagent_instance = ReagentMaterial.objects.get(
                    template=reagent_template_uuid, reagent__experiment=exp_uuid,
                )
                reagent_instance.material = (
                    InventoryMaterial.objects.get(uuid=data["chemical"])
                    if data["chemical"]
                    else None
                )
                reagent_instance.save()
                reagent_material_value = reagent_instance.reagent_material_value_rmi.get(
                    template__description="concentration"
                )
                reagent_material_value.nominal_value = data["desired_concentration"]
                reagent_material_value.save()

    def process_automated_formsets(self, request: HttpRequest, context: dict[str, Any]):
        # get the experiment template uuid and name
        try:
            exp_template = ExperimentTemplate.objects.get(
                pk=context["selected_exp_template"].uuid
            )
        except KeyError:
            exp_template = ExperimentTemplate.objects.get(
                pk=request.session["experiment_template_uuid"]
            )

        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
        else:
            org_id = None

        vessel = context["vessel"]

        (
            experiment_copy_uuid,
            exp_name_form,
            dead_volume,
            total_volume,
            reagent_template_names,
            reagentDefs,
            # vessel,
        ) = self.save_reagents(exp_template, vessel, request, org_id)

        context["exp_uuid"] = experiment_copy_uuid

        if not exp_name_form.is_valid():
            return context

        exp_name = exp_name_form.cleaned_data["exp_name"]
        # self.save_reaction_parameters(
        # request, experiment_copy_uuid, exp_name_form, exp_template
        # )
        # generate desired volume for current reagent
        try:
            exp_number = int(request.POST["automated"])

            generate_experiments_and_save(
                exp_template,
                experiment_copy_uuid,
                reagent_template_names,
                reagentDefs,
                exp_number,
                dead_volume,
                total_volume,
                vessel,
            )
        except ValueError as ve:
            messages.error(request, str(ve))
            # return context
            raise
            # return HttpResponseRedirect(reverse("experiment"))

        return context

    def populate_links(self, context, exp_template, experiment_copy_uuid, exp_name):
        # robotfile generation
        q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)
        if exp_template.ref_uid in SUPPORTED_CREATE_WFS:
            template_function = getattr(core.experiment_templates, exp_template.ref_uid)
            new_lsr_pk, lsr_msg = template_function(
                None, q1, experiment_copy_uuid, exp_name, exp_template
            )

            if str(self.request.session["current_org_name"]) != "TestCo":
                context["lsr_download_link"] = None
            elif new_lsr_pk is not None:
                context["lsr_download_link"] = reverse(
                    "edoc_download", args=[new_lsr_pk]
                )
            else:
                messages.error(
                    self.request, f'LSRGenerator failed with message: "{lsr_msg}"'
                )
        # links for info about specific experiment

        context["experiment_link"] = reverse(
            "experiment_instance_view", args=[experiment_copy_uuid]
        )
        context["reagent_prep_link"] = reverse(
            "reagent_prep", args=[experiment_copy_uuid]
        )
        context["outcome_link"] = reverse("outcome", args=[experiment_copy_uuid])
        context["new_exp_name"] = exp_name
        return context


# end: class CreateExperimentView()
