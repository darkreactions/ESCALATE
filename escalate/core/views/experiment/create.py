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
    ManualSpecificationForm,
)

from core.utilities.utils import experiment_copy
from core.utilities.experiment_utils import (
    get_action_parameter_querysets,
    prepare_reagents,
    generate_experiments_and_save,
    save_reaction_parameters,
    save_manual_volumes,
    save_manual_parameters,
    save_parameter,
)
from core.utilities.calculations import conc_to_amount
from core.utilities.utils import make_well_labels_list
from core.views.experiment.create_select_template import SelectReagentsView

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
        context["all_experiments"] = self.all_experiments
        return context

    def post(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        exp_template = ExperimentTemplate.objects.get(
            uuid=request.session["experiment_template_uuid"]
        )
        context["exp_template"] = exp_template

        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
        else:
            org_id = None

        try:
            # Collect form data
            vessel = Vessel.objects.get(description=request.POST.get("vessel"))
            context["vessel"] = vessel

            (dead_volume, total_volume) = self.save_volumes(request, vessel)

            num_automated = int(request.POST.get("automated", 0))
            num_manual = int(request.POST.get("manual", 0))

            exp_name_form = ExperimentNameForm(request.POST)

            if exp_name_form.is_valid():
                context["new_exp_name"] = exp_name_form.cleaned_data["exp_name"]

                self.generate_action_units(exp_template, vessel)

                # Make the experiment copy: this will be our new experiment
                experiment_copy_uuid = experiment_copy(
                    str(exp_template.uuid), context["new_exp_name"], vessel
                )

            # Obtain and save reagent names and concentration data
            (reagent_template_names, reagentDefs,) = self.save_reagents(
                exp_template, experiment_copy_uuid, request, org_id
            )

            context["experiment_copy_uuid"] = experiment_copy_uuid
            context["dead_volume"] = dead_volume
            context["total_volume"] = total_volume
            context["reagent_template_names"] = reagent_template_names
            context["reagentDefs"] = reagentDefs

            # Generate and save mass/volume amounts
            if num_manual > 0:
                context = self.process_manual_formsets(request, context)
            
            if num_automated > 0:
                context = self.process_automated_formsets(request, context)

            if num_automated & num_manual <= 0:
                raise NoExperimentException()

            conc_to_amount(experiment_copy_uuid)

            # Experiment detail/reagent prep/outcome links
            context = self.populate_links(context)

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
        experiment_copy_uuid,
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

        reagentDefs = []
        for reagent_formset in formsets:
            if reagent_formset.is_valid():

                self.save_forms_reagent(reagent_formset, experiment_copy_uuid)
                # try:
                rd = prepare_reagents(reagent_formset)
                # if rd not in reagentDefs:
                reagentDefs.append(rd)
                # except TypeError as te:
                # messages.error(request, str(te))

        return (
            reagent_template_names,
            reagentDefs,
        )

    def save_volumes(self, request, vessel):
        # get dead volume value
        dead_volume_form = SingleValForm(request.POST, prefix="dead_volume")
        if dead_volume_form.is_valid():
            dead_volume = dead_volume_form.cleaned_data["value"]
        else:
            dead_volume = None

        # get total volume value
        total_volume_form = SingleValForm(request.POST, prefix="total_volume")
        if total_volume_form.is_valid():
            total_volume = total_volume_form.cleaned_data["value"]
        else:
            total_volume = None

        if (
            vessel.total_volume.value is not None
        ):  # check that target volume does not exceed vessel capacity
            if total_volume.value > vessel.total_volume.value:
                raise ValueError(
                    "Target volume exceeds capacity of {} for the specified vessel".format(
                        vessel.total_volume
                    )
                )

        return (dead_volume, total_volume)

    def generate_action_units(self, exp_template, vessel):
        """For a chosen ExperimentTemplate, this function obtains the action sequences and generates appropriate action units
        corresponding to the chosen vessel. Used for experiment templates created through the UI"""

        # get the action sequences
        action_sequences = []
        eas = ExperimentActionSequence.objects.filter(
            experiment_template=exp_template
        )  # get ExperimentActionSequence
        for i in eas:
            action_sequences.append(i.action_sequence)

        # look up stored ActionSequenceDesign objects from UI workflow generator
        # for templates generated through API/scripts, these objects will not exist (the script already creates action units)
        for i in action_sequences:
            actions = ActionSequenceDesign.objects.filter(action_sequence=i)
        if actions.exists():
            for a in actions:
                action = Action.objects.filter(
                    description=a.description, action_sequence=i
                )[
                    0
                ]  # action

                if a.source is not None:  # create source BOM
                    source_bbm = BaseBomMaterial.objects.create(description=a.source)
                else:
                    source_bbm = None

                # creaate destination BOM
                if "wells" in a.destination:  # individual well-level actions
                    plate = Vessel.objects.get(uuid=vessel.uuid)

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
                else:
                    vessel_types = []
                    for vt in VesselType.objects.all():
                        vessel_types.append(vt.description)

                    if a.destination in vessel_types:  # plate-level actions

                        vessel = Vessel.objects.get(uuid=vessel.uuid)
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

    def save_reaction_parameters(
        self, request, experiment_copy_uuid, exp_name_form, exp_template
    ):
        """ This function saves specific reaction data in a seperate table for faster access. Does not need to call the model table to prepopulate reaction parameters. POST saves to both the model table and reaction parameter table"""
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

    def process_manual_formsets(self, request: HttpRequest, context: dict[str, Any]):
        """This function parses the manual specification form for the experiment and saves volume/parameter volumes."""

        # parse manual spec form and convert to pandas dataframe
        file_form = ManualSpecificationForm(request.POST, request.FILES)
        if file_form.is_valid():
            df = pd.read_excel(file_form.cleaned_data["file"])

        # save volumes
        save_manual_volumes(
            df,
            context["experiment_copy_uuid"],
            context["reagent_template_names"],
            context["dead_volume"],
            context["vessel"],
        )

        # save parameters
        save_manual_parameters(
            df, context["exp_template"], context["experiment_copy_uuid"]
        )

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
        """This function calls the random sampler to generate volume data for the requested number of automated experiments"""

        try:
            exp_number_auto = int(request.POST["automated"])
            exp_number_manual = int(request.POST["manual"])

            generate_experiments_and_save(
                context["exp_template"],
                context["experiment_copy_uuid"],
                context["reagent_template_names"],
                context["reagentDefs"],
                exp_number_auto,
                exp_number_manual,
                context["dead_volume"],
                context["total_volume"],
                context["vessel"],
            )
        except ValueError as ve:
            messages.error(request, str(ve))
            # return context
            # return HttpResponseRedirect(reverse("experiment"))

        return context

    def populate_links(self, context):
        # robotfile generation
        q1 = get_action_parameter_querysets(
            context["experiment_copy_uuid"], template=False
        )
        if context["exp_template"].ref_uid in SUPPORTED_CREATE_WFS:
            template_function = getattr(
                core.experiment_templates, context["exp_template"].ref_uid
            )
            new_lsr_pk, lsr_msg = template_function(
                None,
                q1,
                context["experiment_copy_uuid"],
                context["new_exp_name"],
                context["exp_template"],
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
            "experiment_instance_view", args=[context["experiment_copy_uuid"]]
        )
        context["reagent_prep_link"] = reverse(
            "reagent_prep", args=[context["experiment_copy_uuid"]]
        )
        context["outcome_link"] = reverse(
            "outcome", args=[context["experiment_copy_uuid"]]
        )

        return context


# end: class CreateExperimentView()

class NoExperimentException(Exception):
    """ Exception raised when manual and automated experiment is 0"""
    def __init__(self,message="Please insert a positive number for either automated or manual experiment. Both fields can't be left at 0."):
        self.message=message
        super().__init__(self.message)