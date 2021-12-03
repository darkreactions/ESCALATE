from __future__ import annotations
from math import e
from typing import Any, Type
import json
import pandas as pd
from django.forms.forms import Form
from django.http.response import FileResponse
from django.http.request import HttpRequest
from django.http import HttpResponseRedirect

from django.views.generic import TemplateView
from django.forms import formset_factory, BaseFormSet
from django.shortcuts import render
from django.contrib import messages
from django.urls import reverse


from core.models.view_tables import (
    ExperimentTemplate,
    Actor,
    ReagentMaterial,
    ReagentTemplate,
    InventoryMaterial,
    ReactionParameter,
    ReagentMaterialTemplate,
    ReagentMaterialValueTemplate,
    MaterialType,
)
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
    UploadFileForm,
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
    save_parameter,
)
from core.utilities.calculations import conc_to_amount
from core.utilities.wf1_utils import generate_robot_file_wf1
from core.models.view_tables.generic_data import Parameter

from .misc import get_action_parameter_form_data, save_forms_q1, save_forms_q_material

import core.models
from core.custom_types import Val
import core.experiment_templates
from core.utilities.wf1_utils import generate_robot_file


SUPPORTED_CREATE_WFS = [
    mod for mod in dir(core.experiment_templates) if "__" not in mod
]


class CreateExperimentView(TemplateView):
    template_name = "core/create_experiment.html"
    form_class = ExperimentTemplateForm
    MaterialFormSet: Type[BaseFormSet] = formset_factory(InventoryMaterialForm, extra=0)
    NominalActualFormSet: Type[BaseFormSet] = formset_factory(NominalActualForm, extra=0)
    ReagentFormSet: Type[BaseFormSet] = formset_factory(ReagentForm, extra=0, formset=BaseReagentFormSet)
    ReactionParameterFormset: Type[BaseFormSet] = formset_factory(ReactionParameterForm, extra=0)

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
        #lab = Actor.objects.get(organization=org_id, person__isnull=True)
        #self.all_experiments = ExperimentTemplate.objects.filter(lab=lab)
        context["all_experiments"] = self.all_experiments
        return context

    def get_material_forms(
        self, exp_uuid: str, context: dict[str, Any]
    ) -> dict[str, Any]:
        q1 = get_material_querysets(exp_uuid)
        initial_q1: list = [
            {
                "value": row.inventory_material,
                "uuid": json.dumps([f"{row.object_description}"]),
            }
            for row in q1
        ]
        q1_details: list = [f"{row.object_description}" for row in q1]

        form_kwargs: dict[str, Any] = {
            "org_uuid": self.request.session["current_org_id"]
        }
        context["q1_material_formset"] = self.MaterialFormSet(
            initial=initial_q1, prefix="q1_material", form_kwargs=form_kwargs
        )
        context["q1_material_details"] = q1_details

        return context

    def get_colors(
        self,
        number_of_colors: int,
        colors: list[str] = [
            "lightblue", 
            "teal", 
            "powderblue", 
            "skyblue", 
            "pastelblue", 
            "verdigris", 
            "steelblue", 
            "cornflowerblue",
        ],
    ) -> list[str]:
        factor = int(number_of_colors / len(colors))
        remainder = number_of_colors % len(colors)
        total_colors = colors * factor + colors[:remainder]
        return total_colors

    def get_reagent_forms(
        self, exp_template: ExperimentTemplate, context: dict[str, Any]
    ):
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
        else:
            org_id = None
        formsets: list[Any] = []
        reagent_template_names = []

        reagent_template: Type[ReagentTemplate]
        for index, reagent_template in enumerate(exp_template.reagent_templates.all().order_by("description")):  # type: ignore
            reagent_template_names.append(reagent_template.description)
            mat_types_list = []
            initial_data: list[Any] = []
            reagent_material_template: Type[ReagentMaterialTemplate]
            for reagent_material_template in reagent_template.reagent_material_template_rt.all().order_by("description"):  # type: ignore
                reagent_material_value_template: Type[ReagentMaterialValueTemplate]
                for reagent_material_value_template in reagent_material_template.reagent_material_value_template_rmt.filter(description="concentration"):  # type: ignore
                    material_type: MaterialType
                    material_type = reagent_material_template.material_type  # type: ignore
                    mat_types_list.append(material_type)
                    initial_data.append(
                        {
                            "reagent_template_uuid": reagent_material_template.uuid,
                            "material_type": material_type.uuid,
                            "desired_concentration": reagent_material_value_template.default_value.nominal_value,
                        }
                    )  # type: ignore

            if mat_types_list:
                fset = self.ReagentFormSet(
                    prefix=f"reagent_{index}",
                    initial=initial_data,
                    form_kwargs={
                        "lab_uuid": org_id,
                        "mat_types_list": mat_types_list,
                        "reagent_index": index,
                    },
                )  # type: ignore
                formsets.append(fset)
        # for form in formset:
        #    form.fields[]
        context["reagent_formset_helper"] = ReagentForm.get_helper()
        context["reagent_formset_helper"].form_tag = False
        context["reagent_formset"] = formsets
        context["reagent_template_names"] = reagent_template_names

        # get vessel data for selection
        v_query = core.models.view_tables.Vessel.objects.all()
        initial_vessel = VesselForm(initial={"value": v_query[0]})
        context["vessel_form"] = initial_vessel

        # Dead volume form
        initial: dict[str, Val] = {
            "value": Val.from_dict({"value": 4000, "unit": "uL", "type": "num"})
        }
        dead_volume_form = SingleValForm(prefix="dead_volume", initial=initial)
        context["dead_volume_form"] = dead_volume_form

        # reaction parameter form
        rp_wfs = get_action_parameter_querysets(exp_template.uuid)
        rp_labels = []
        index = 0
        for rp in rp_wfs:
            rp_label = str(rp.object_description)  # type: ignore
            if "Dispense" in rp_label:
                continue
            else:
                try:
                    rp_object = (
                        ReactionParameter.objects.filter(description=rp_label)
                        .order_by("add_date")
                        .first()
                    )
                    initial = {
                        "value": Val.from_dict(
                            {
                                "value": rp_object.value,
                                "unit": rp_object.unit,
                                "type": "num",
                            }
                        ),
                        "uuid": rp.parameter_uuid,
                    }
                except AttributeError:
                    initial = {
                        "value": Val.from_dict({"value": 0, "unit": "", "type": "num"}),
                        "uuid": rp.parameter_uuid,
                    }

                rp_form = ReactionParameterForm(
                    prefix=f"reaction_parameter_{index}", initial=initial
                )
                rp_labels.append((rp_label, rp_form))
                index += 1
        context["reaction_parameter_labels"] = rp_labels

        context["colors"] = self.get_colors(len(formsets))

        return context

    def get_action_parameter_forms(
        self, exp_uuid: str, context: dict[str, Any], template: bool = True
    ):
        initial_q1: list[Any]
        q1_details: list[Any]
        initial_q1, q1_details = get_action_parameter_form_data(
            exp_uuid=exp_uuid, template=template
        )
        context["q1_param_formset"] = self.NominalActualFormSet(
            initial=initial_q1, prefix="q1_param",
        )
        context["q1_param_details"] = q1_details
        return context

    def get(self, request: HttpRequest, *args, **kwargs):
        #try:
            #context = self.get_context_data(**kwargs)
        #except KeyError:
            #messages.error(request, 'Please select a lab')
            #org_id=None
            #context = self.get_context_data(**kwargs)
            #return context
        if 'current_org_id' in self.request.session:
            context = self.get_context_data(**kwargs)
            org_id = self.request.session['current_org_id']
            context['experiment_template_select_form'] = ExperimentTemplateForm(org_id=org_id)
        else:
            context = self.get_context_data(**kwargs)
            #self.template_name = "core/main_menu.html"
            org_id=None
            messages.error(request, 'Please select a lab to continue')
            return HttpResponseRedirect(reverse("main_menu"))
            #try:
                #context['experiment_template_select_form'] = ExperimentTemplateForm(org_id=org_id)
            #except ValueError as ve:
               # messages.error(request, str(ve))
        #context['experiment_template_select_form'] = ExperimentTemplateForm(org_id=org_id)
        #context['robot_file_upload_form'] = UploadFileForm()
        #context['robot_file_upload_form_helper'] = UploadFileForm.get_helper()
        return render(request, self.template_name, context)

    def post(self, request: HttpRequest, *args, **kwargs):
        #try:
        context = self.get_context_data(**kwargs)
        #except ValueError as ve:
            #messages.error(request, str(ve))
        if 'select_experiment_template' in request.POST:
            #if 'current_org_id' in self.request.session:
               # org_id= self.request.session['current_org_id']
           # else:
               # messages.error(request, 'Please select a lab')
            exp_uuid: str = request.POST['select_experiment_template']
            if exp_uuid:
                request.session["experiment_template_uuid"] = exp_uuid
                context["selected_exp_template"] = ExperimentTemplate.objects.get(
                    uuid=exp_uuid
                )
                if int(request.POST["manual"])>=0:
                    context["manual"] = int(request.POST["manual"])
                else:
                    messages.error(request, "Number of experiments cannot be negative")
                    return render(request, self.template_name, context)
                if int(request.POST["automated"])>=0:
                    context["automated"] = int(request.POST["automated"])
                else:
                    messages.error(request, "Number of experiments cannot be negative")
                    return render(request, self.template_name, context)
                context["experiment_name_form"] = ExperimentNameForm()
                context = self.get_action_parameter_forms(exp_uuid, context)

                if context["manual"]:
                    context = self.get_material_forms(exp_uuid, context)
                    context["robot_file_upload_form"] = RobotForm()
                    context["robot_file_upload_form_helper"] = RobotForm.get_helper()
                    context = self.get_reagent_forms(
                        context["selected_exp_template"], context
                    )
                if context["automated"]:
                    context = self.get_reagent_forms(
                            context["selected_exp_template"], context
                        )
            else:
                request.session["experiment_template_uuid"] = None
        # begin: create experiment
        elif "create_exp" in request.POST:
            if "automated" in request.POST:
                context = self.process_automated_formsets(request, context)
            # elif "manual" in request.POST:
            # context=self.process_robot_formsets(request.session['experiment_template_uuid'], request, context)
        elif "robot_download" in request.POST:
            return self.download_robot_file(request.session["experiment_template_uuid"])
        elif "robot_upload" in request.POST:
            # return self.process_robot_formsets(request.session['experiment_template_uuid'], request, context)
            context = self.process_robot_formsets(
                request.session["experiment_template_uuid"], request, context
            )
        return render(request, self.template_name, context)

    # def process_robot_file(self, df):
    # data= df.to_html()
    # data.save()
    # return HttpResponse(data)

    def download_robot_file(self, exp_uuid: str):
        q1 = get_action_parameter_querysets(exp_uuid)  # volumes
        f = generate_robot_file_wf1(q1, {}, "Symyx_96_well_0003", 96)
        response = FileResponse(f, as_attachment=True, filename=f"robot_{exp_uuid}.xls")
        return response

    def process_robot_formsets(self, exp_uuid, request, context):
        context["robot_file_upload_form"] = UploadFileForm()
        context["robot_file_upload_form_helper"] = UploadFileForm.get_helper()

        exp_template = ExperimentTemplate.objects.get(uuid=exp_uuid)
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
        else:
            org_id = None
        
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
            # experiment name
            exp_name = exp_name_form.cleaned_data["exp_name"]

            # make the experiment copy: this will be our new experiment
            experiment_copy_uuid = experiment_copy(str(exp_template.uuid), exp_name)
            exp_concentrations = {}
            for reagent_formset in formsets:
                if reagent_formset.is_valid():
                    vector = self.save_forms_reagent(reagent_formset, experiment_copy_uuid, exp_concentrations)
                    #try:
                    exp_concentrations = prepare_reagents(
                            reagent_formset, exp_concentrations
                        )
                    #except TypeError as te:
                       # messages.error(request, str(te))
            
            dead_volume_form = SingleValForm(request.POST, prefix="dead_volume")
            if dead_volume_form.is_valid():
                dead_volume = dead_volume_form.cleaned_data['value']
            else:
                dead_volume = None

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
        
        
        
        df = pd.read_excel(request.FILES["file"])
        # self.process_robot_file(df)
        save_manual_volumes(df, experiment_copy_uuid, dead_volume)

        conc_to_amount(experiment_copy_uuid)

        context["experiment_link"] = reverse(
            "experiment_instance_view", args=[experiment_copy_uuid]
        )
        context["reagent_prep_link"] = reverse(
            "reagent_prep", args=[experiment_copy_uuid]
        )
        context["outcome_link"] = reverse("outcome", args=[experiment_copy_uuid])
        context["new_exp_name"] = exp_name

        return context

    def save_forms_q1(self, queries, formset, fields):
        """Saves custom formset into queries

        Args:
            queries ([Queryset]): List of queries into which the forms values are saved
            formset ([Formset]): Formset
            fields (dict): Dictionary to map the column in queryset with field in formset
        """
        for form in formset:
            if form.has_changed():
                data = form.cleaned_data
                desc = json.loads(data["uuid"])
                if len(desc) == 2:
                    object_desc, param_def_desc = desc
                    query = queries.get(
                        object_description=object_desc,
                        parameter_def_description=param_def_desc,
                    )
                else:
                    query = queries.get(object_description=desc[0])
                parameter = Parameter.objects.get(uuid=query.parameter_uuid)
                for db_field, form_field in fields.items():
                    setattr(parameter, db_field, data[form_field])
                parameter.save(update_fields=list(fields.keys()))
        # queries.save()

    def save_forms_q_material(self, queries, formset, fields):
        """
        Saves custom formset into queries
        Args:
            queries ([Queryset]): List of queries into which the forms values are saved
            formset ([Formset]): Formset
            fields (dict): Dictionary to map the column in queryset with field in formset
        """
        for form in formset:
            if form.has_changed():
                data = form.cleaned_data
                desc = json.loads(data["uuid"])
                if len(desc) == 2:
                    object_desc, param_def_desc = desc
                    query = queries.get(
                        object_description=object_desc,
                        parameter_def_description=param_def_desc,
                    )
                else:
                    query = queries.get(object_description=desc[0])

                for db_field, form_field in fields.items():
                    setattr(query, db_field, data[form_field])

                query.save(update_fields=list(fields.keys()))

    def save_forms_reagent(self, formset, exp_uuid, exp_concentrations):

        """
        need a way to query the db table rows. in material and q1 we query
        based on description however we only have the chemical uuid and
        desired concentration
        in the form. we can pass the copy experiment uuid and call that p
        otentially to get the reagentinstance/reagentinstancevalue uuid
        once this is finished test to make sure the data is saved correctly in the db.
        """
        positions = {"organic": 0, "solvent": 1, "acid": 2, "inorganic": 3}
        vector = [0, 0, 0, 0]
        form: Form
        for form in formset:  # type: ignore
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
                mat_type = reagent_instance.template.material_type
                vector[positions[mat_type.description]] = data["desired_concentration"]
        return vector

    def process_formsets(
        self, request: HttpRequest, context: dict[str, Any]
    ) -> dict[str, Any]:
        """Creates formsets and gets data from the post request.

        Args:
            request ([Django Request]): Should be the POST request
            context (dict): Context dictionary

        Returns:
            context [dict]: Context dict, returned to the page
        """
        # get the experiment template uuid and name
        exp_template = ExperimentTemplate.objects.get(
            pk=request.session["experiment_template_uuid"]
        )
        template_name = exp_template.description
        # ref_uid will be used to identify python functions specifically for this
        # ref_uid should follow function naming rules for Python
        template_ref_uid = exp_template.ref_uid
        # construct all formsets
        exp_name_form = ExperimentNameForm(request.POST)
        q1_formset = self.NominalActualFormSet(request.POST, prefix="q1_param")
        q1_material_formset = self.MaterialFormSet(
            request.POST,
            prefix="q1_material",
            form_kwargs={"org_uuid": self.request.session["current_org_id"]},
        )
        if all(
            [
                exp_name_form.is_valid(),
                q1_formset.is_valid(),
                q1_material_formset.is_valid(),
            ]
        ):

            exp_name = exp_name_form.cleaned_data["exp_name"]
            # make the experiment copy: this will be our new experiment
            experiment_copy_uuid: str = experiment_copy(
                str(exp_template.uuid), exp_name
            )
            # get the elements of the new experiment that we need to update with the form values
            q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)
            q1_material = get_material_querysets(experiment_copy_uuid, template=False)

            save_forms_q1(
                q1,
                q1_formset,
                {
                    "parameter_val_nominal": "value",
                    "parameter_val_actual": "actual_value",
                },
            )
            save_forms_q_material(
                q1_material, q1_material_formset, {"inventory_material": "value"}
            )

            # begin: template-specific logic
            if template_ref_uid in SUPPORTED_CREATE_WFS:
                data = {}  # Stick form data into this dict
                form: Form
                for i, form in enumerate(q1_formset):  # type: ignore
                    if form.is_valid():
                        query = q1[i]
                        data[query.parameter_def_description] = form.cleaned_data[
                            "value"
                        ].value

                # Scans experiment_templates and picks up functions that have the same name as template_name
                template_function = getattr(core.experiment_templates, template_ref_uid)
                new_lsr_pk, lsr_msg = template_function(
                    data, q1, experiment_copy_uuid, exp_name, exp_template
                )

                if new_lsr_pk is not None:
                    context["xls_download_link"] = reverse(
                        "edoc_download", args=[new_lsr_pk]
                    )
                if str(self.request.session["current_org_name"]) != "TestCo":
                    context["lsr_download_link"] = None
                elif new_lsr_pk is not None:
                    context["lsr_download_link"] = reverse(
                        "edoc_download", args=[new_lsr_pk]
                    )
                else:
                    messages.error(
                        request, f'LSRGenerator failed with message: "{lsr_msg}"'
                    )
                context["experiment_link"] = reverse(
                    "experiment_instance_view", args=[experiment_copy_uuid]
                )
                context["reagent_prep_link"] = reverse(
                    "reagent_prep", args=[experiment_copy_uuid]
                )
                context["outcome_link"] = reverse(
                    "outcome", args=[experiment_copy_uuid]
                )
                context["new_exp_name"] = exp_name
        return context

    """
        this function should only save the data to the db tables. refactor all other logic
    """

    def process_automated_formsets(self, request: HttpRequest, context: dict[str, Any]):
        # get the experiment template uuid and name
        exp_template = ExperimentTemplate.objects.get(
            pk=request.session["experiment_template_uuid"]
        )
        # template_name = exp_template.description
        # construct all formsets
        exp_name_form = ExperimentNameForm(request.POST)

        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
        else:
            org_id = None
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
        if exp_name_form.is_valid():
            # experiment name
            exp_name = exp_name_form.cleaned_data["exp_name"]
            # retrieve # of experiments to be generated (# of vial locations)
            exp_number = int(request.POST["automated"])

            # make the experiment copy: this will be our new experiment
            experiment_copy_uuid: str = experiment_copy(
                str(exp_template.uuid), exp_name
            )
            exp_concentrations = {}
            reagent_formset: BaseFormSet
            for reagent_formset in formsets:
                if reagent_formset.is_valid():
                    vector = self.save_forms_reagent(
                        reagent_formset, experiment_copy_uuid, exp_concentrations
                    )
                    #try:
                    exp_concentrations = prepare_reagents(
                        reagent_formset, exp_concentrations
                        )
                    #except TypeError as te:
                       # messages.error(request, str(te))
                       # return context
                        #return HttpResponseRedirect(reverse("experiment_instance_add"))

            # Save dead volumes should probably be in a separate function
            dead_volume_form = SingleValForm(request.POST, prefix="dead_volume")
            if dead_volume_form.is_valid():
                dead_volume=dead_volume_form.cleaned_data['value']
                #dead_volume = dead_volume_form.value
            else:
                dead_volume = None

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
            
            
            
            #generate desired volume for current reagent
            try:
                generate_experiments_and_save(experiment_copy_uuid, exp_concentrations, exp_number, dead_volume)
            except ValueError as ve:
                messages.error(request, str(ve))
                return context
                #return HttpResponseRedirect(reverse("experiment"))
            
            q1 = get_action_parameter_querysets(experiment_copy_uuid, template=False)

            # robotfile generation
            if exp_template.ref_uid in SUPPORTED_CREATE_WFS:
                template_function = getattr(
                    core.experiment_templates, exp_template.ref_uid
                )
                new_lsr_pk, lsr_msg = template_function(
                    None, q1, experiment_copy_uuid, exp_name, exp_template
                )

                if new_lsr_pk is not None:
                    context["xls_download_link"] = reverse(
                        "edoc_download", args=[new_lsr_pk]
                    )
                if str(self.request.session["current_org_name"]) != "TestCo":
                    context["lsr_download_link"] = None
                elif new_lsr_pk is not None:
                    context["lsr_download_link"] = reverse(
                        "edoc_download", args=[new_lsr_pk]
                    )
                else:
                    messages.error(
                        request, f'LSRGenerator failed with message: "{lsr_msg}"'
                    )
                context["experiment_link"] = reverse(
                    "experiment_instance_view", args=[experiment_copy_uuid]
                )
                context["reagent_prep_link"] = reverse(
                    "reagent_prep", args=[experiment_copy_uuid]
                )
                context["outcome_link"] = reverse(
                    "outcome", args=[experiment_copy_uuid]
                )
                context["new_exp_name"] = exp_name
        return context


# end: class CreateExperimentView()
