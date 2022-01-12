from __future__ import annotations
from typing import Any

from django.forms import formset_factory, BaseFormSet
from django.http.request import HttpRequest
from django.views.generic import TemplateView
from django.shortcuts import render
from core.utilities.experiment_utils import get_action_parameter_querysets
from core.models import (
    Actor,
    ExperimentTemplate,
    ReagentTemplate,
    ReagentMaterialTemplate,
    ReagentMaterialValueTemplate,
    MaterialType,
    ReactionParameter,
    Vessel,
)
from core.forms.custom_types import (
    BaseReagentFormSet,
    ReagentForm,
    ReactionParameterForm,
    VesselForm,
    SingleValForm,
    ExperimentNameForm,
    RobotForm,
)
from core.custom_types import Val


class SelectReagentsView(TemplateView):
    template_name = "core/experiment/create/base_create.html"

    ReagentFormSet: BaseFormSet = formset_factory(
        ReagentForm, extra=0, formset=BaseReagentFormSet
    )

    def get(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        return render(request, self.template_name, context)

    def post(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        self.request = request
        exp_uuid = request.POST["select_experiment_template"]
        request.session["experiment_template_uuid"] = exp_uuid
        context["selected_exp_template"] = ExperimentTemplate.objects.get(uuid=exp_uuid)
        context["experiment_name_form"] = ExperimentNameForm()
        context = self.get_forms(context["selected_exp_template"], context)

        if (num_automated_exp := int(request.POST["automated"])) >= 0:
            context["automated"] = num_automated_exp

        if (num_manual_exp := int(request.POST["manual"])) >= 0:
            context["manual"] = num_manual_exp
            context["robot_file_upload_form"] = RobotForm()
            context["robot_file_upload_form_helper"] = RobotForm.get_helper()

        return render(request, self.template_name, context)

    def get_forms(self, exp_template: ExperimentTemplate, context: dict[str, Any]):
        context = self.get_reagent_forms(context)
        context = self.get_dead_volume_form(context)
        context = self.get_vessel_form(context)
        # context = self.get_reaction_parameter_forms(context)
        context["colors"] = self.get_colors(len(context["reagent_formset"]))
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
        ):  # type: ignore
            reagent_template_names.append(reagent_template.description)
            mat_types_list = []
            initial_data: list[Any] = []
            reagent_material_template: ReagentMaterialTemplate
            for reagent_material_template in reagent_template.reagent_material_template_rt.all().order_by("description"):  # type: ignore
                reagent_material_value_template: ReagentMaterialValueTemplate
                # type: ignore
                for (
                    reagent_material_value_template
                ) in reagent_material_template.reagent_material_value_template_rmt.filter(
                    description="concentration"
                ):
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

        return context

    def get_dead_volume_form(self, context: dict[str, Any]) -> dict[str, Any]:
        # Dead volume form
        initial: dict[str, Val] = {
            "value": Val.from_dict({"value": 4000, "unit": "uL", "type": "num"})
        }
        dead_volume_form = SingleValForm(prefix="dead_volume", initial=initial)
        context["dead_volume_form"] = dead_volume_form
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
