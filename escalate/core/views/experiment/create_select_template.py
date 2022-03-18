from __future__ import annotations

from typing import Any
from django import forms
from django.forms import formset_factory, BaseFormSet
from django.http.request import HttpRequest
from django.http import HttpResponseRedirect
from django.views.generic import TemplateView
from django.shortcuts import render
from django.urls import reverse

from django.contrib import messages
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.models import (
    ExperimentTemplate,
    ReagentTemplate,
    ReagentMaterialTemplate,
    # ReagentMaterialValueTemplate,
    MaterialType,
    Vessel,
)
from core.forms.custom_types import (
    BaseReagentFormSet,
    ReagentForm,
    ReactionParameterForm,
    VesselForm,
    SingleValForm,
    ExperimentNameForm,
    ManualSpecificationForm,
)
from core.custom_types import Val


class SelectReagentsView(TemplateView):
    template_name = "core/experiment/create/base_create.html"

    ReagentFormSet: BaseFormSet = formset_factory(
        ReagentForm, extra=0, formset=BaseReagentFormSet
    )
    # VesselFormSet = formset_factory(VesselForm, extra=0)

    def get(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        return render(request, self.template_name, context)

    def post(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        self.request = request
        if "select_experiment_template" in request.POST:
            exp_uuid = request.POST["select_experiment_template"]
            vessel = request.POST.get("value")
            request.session["experiment_template_uuid"] = exp_uuid
            request.session["selected_vessel"] = vessel
        else:
            exp_uuid = request.session["experiment_template_uuid"]
        context["selected_exp_template"] = ExperimentTemplate.objects.get(uuid=exp_uuid)
        context["experiment_name_form"] = ExperimentNameForm()
        context = self.get_forms(context["selected_exp_template"], context)

        if (num_automated_exp := int(request.POST["automated"])) >= 0:
            context["automated"] = num_automated_exp

        if (num_manual_exp := int(request.POST["manual"])) >= 0:
            context["manual"] = num_manual_exp
            request.session["manual"] = num_manual_exp
            context["spec_file_upload_form"] = ManualSpecificationForm(
                request.POST, request.FILES
            )
            context[
                "spec_file_upload_form_helper"
            ] = ManualSpecificationForm.get_helper()

        # get vessel`
        if "value" in request.POST.keys():
            context["vessel"] = Vessel.objects.get(uuid=request.POST["value"])
            vessel_uuid = str(context["vessel"].uuid)
            request.session["vessel"] = vessel_uuid
            if context["vessel"].well_number is not None:
                if num_automated_exp + num_manual_exp > context["vessel"].well_number:
                    # make sure # of desired experiments does not exceed vessel's well count
                    messages.error(
                        request,
                        "Error: Number of total experiments exceeds well count of selected vessel",
                    )
        return render(request, self.template_name, context)

    def get_forms(self, exp_template: ExperimentTemplate, context: dict[str, Any]):
        context = self.get_reagent_forms(context)
        context = self.get_volume_forms(context)
        context = self.get_vessel_forms(context)
        context["colors"] = self.get_colors(len(context["reagent_formset"]))
        return context

    def get_vessel_forms(self, context: dict[str, Any]) -> dict[str, Any]:
        exp_template = ExperimentTemplate.objects.get(
            pk=self.request.session["experiment_template_uuid"]
        )
        vt_names = []
        vessel_forms = []
        for index, vt in enumerate(
            exp_template.vessel_templates.all().order_by("description")
        ):
            vt_names.append(vt.description)
            vessel_forms.append(
                VesselForm(
                    prefix=f"vessel_{index}", initial={"value": vt.default_vessel}
                )
            )
        """
        vessel_templates = set()
        for asq in exp_template.action_sequence.all():
            for at in asq.action_template_as.all():
                if at.source_vessel_template:
                    vessel_templates.add(at.source_vessel_template)
                if at.dest_vessel_template:
                    vessel_templates.add(at.dest_vessel_template)

        vt_names = []
        forms = []
        for index, vt in enumerate(
            sorted(list(vessel_templates), key=lambda x: x.description)
        ):
            
        """
        context["vessel_template_names"] = vt_names
        context["vessel_forms"] = vessel_forms
        return context

    def get_reagent_forms(self, context: dict[str, Any]) -> dict[str, Any]:
        exp_template = ExperimentTemplate.objects.get(
            pk=self.request.session["experiment_template_uuid"]
        )
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
        else:
            org_id = None
        reagent_template_names = []
        formsets: list[Any] = []

        reagent_template: ReagentTemplate
        for index, reagent_template in enumerate(
            exp_template.reagent_templates.all().order_by("description")
        ):
            reagent_template_names.append(reagent_template.description)
            mat_types_list = []
            initial_data: list[Any] = []
            reagent_material_template: ReagentMaterialTemplate
            for reagent_material_template in reagent_template.reagent_material_template_rt.all().order_by("description"):  # type: ignore
                # reagent_material_value_template:
                for (
                    reagent_material_value_template
                ) in reagent_material_template.properties.filter(
                    description="concentration"
                ):
                    material_type: MaterialType
                    material_type = reagent_material_template.material_type
                    mat_types_list.append(material_type)
                    initial_data.append(
                        {
                            "reagent_template_uuid": reagent_material_template.uuid,
                            "material_type": material_type.uuid,
                            "desired_concentration": reagent_material_value_template.default_value.nominal_value,
                        }
                    )

            if mat_types_list:
                fset = self.ReagentFormSet(
                    prefix=f"reagent_{index}",
                    initial=initial_data,
                    form_kwargs={
                        "lab_uuid": org_id,
                        "mat_types_list": mat_types_list,
                        "reagent_index": index,
                    },
                )
                formsets.append(fset)

        context["reagent_formset_helper"] = ReagentForm.get_helper()
        context["reagent_formset_helper"].form_tag = False
        context["reagent_formset"] = formsets
        context["reagent_template_names"] = reagent_template_names

        return context

    def get_volume_forms(self, context: dict[str, Any]) -> dict[str, Any]:
        # Dead volume form
        initial: dict[str, Val] = {
            "value": Val.from_dict({"value": 4000, "unit": "uL", "type": "num"})
        }
        dead_volume_form = SingleValForm(prefix="dead_volume", initial=initial)
        context["dead_volume_form"] = dead_volume_form

        # Total volume form
        initial: dict[str, Val] = {
            "value": Val.from_dict({"value": 800, "unit": "uL", "type": "num"})
        }
        total_volume_form = SingleValForm(prefix="total_volume", initial=initial)
        context["total_volume_form"] = total_volume_form

        return context

    def get_vessel_form(self, context: dict[str, Any]) -> dict[str, Any]:
        # get vessel data for selection
        v_query = Vessel.objects.all()
        initial_vessel = VesselForm(initial={"value": v_query[0]})
        context["vessel_form"] = initial_vessel
        return context

    def get_reaction_parameter_forms(self, context: dict[str, Any]) -> dict[str, Any]:
        # reaction parameter form
        exp_template = ExperimentTemplate.objects.get(
            pk=self.request.session["experiment_template_uuid"]
        )
        rp_wfs = get_action_parameter_querysets(exp_template.uuid)
        rp_labels = []
        index = 0
        for rp in rp_wfs:
            rp_label = (
                str(rp.object_def_description)
                + ": "
                + str(rp.parameter_def_description)
            )
            if "dispense" in rp_label.lower():
                continue
            else:
                try:
                    initial = {
                        "value": Val.from_dict(
                            {
                                "value": rp.parameter_value.value,
                                "unit": rp.parameter_value.unit,
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
        return context

    def get_colors(
        self,
        number_of_colors: int,
        colors: list[str] = [
            "lightblue",
            "teal",
            "powderblue",
            "skyblue",
            "steelblue",
            "pastelblue",
            "verdigris",
            "cornflowerblue",
        ],
    ) -> list[str]:
        """Colors for forms that display on UI"""
        factor = int(number_of_colors / len(colors))
        remainder = number_of_colors % len(colors)
        total_colors = colors * factor + colors[:remainder]
        return total_colors
