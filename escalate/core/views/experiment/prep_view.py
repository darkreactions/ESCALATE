from sys import prefix
from django.views.generic import TemplateView
from django.forms import formset_factory
from django.shortcuts import render
from django.urls import reverse
from django.http import HttpResponseRedirect

from core.models.view_tables import (
    ExperimentInstance,
    # ReagentMaterialValue,
    ReagentMaterialTemplate,
    PropertyTemplate,
    ReagentTemplate,
    Property,
    Reagent,
    ReagentMaterial,
)
from core.forms.custom_types import BaseIndexedFormSet, ReagentRMVIForm
from core.utilities.utils import get_colors
from django.db.models import QuerySet


class ExperimentReagentPrepView(TemplateView):
    template_name = "core/experiment_reagent_prep.html"

    rmviFormSet = formset_factory(
        # PropertyForm,
        ReagentRMVIForm,
        extra=0,
        formset=BaseIndexedFormSet,
    )

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        pk = kwargs["pk"]
        self.experiment: ExperimentInstance = ExperimentInstance.objects.get(pk=pk)
        context = self.get_reagent_forms(self.experiment, context)
        return render(request, self.template_name, context)

    def get_form_initial(self):
        initial = []
        for i, reagent in enumerate(self.experiment.reagent_ei.all()):
            reagent_initial = {"reagent_uuid": str(reagent.uuid)}
            for j, prop in enumerate(reagent.property_r.all()):
                prop: Property
                reagent_initial.update(
                    {
                        f"reagent_prop_uuid_{j}": prop.uuid,
                        f"reagent_prop_nom_{j}": prop.nominal_value,
                        f"reagent_prop_{j}": prop.value,
                    }
                )
            for j, rmt in enumerate(reagent.reagent_material_r.all()):
                rmt: ReagentMaterial
                initial_data = {
                    f"material_{j}": rmt.material,
                    f"reagent_material_uuid_{j}": str(rmt.uuid),
                    f"material_type_{j}": str(rmt.material.description),
                }
                for k, prop in enumerate(rmt.property_rm.all()):
                    prop: Property
                    initial_data[
                        f"reagent_material_prop_nom_{j}_{k}"
                    ] = prop.nominal_value
                    initial_data[f"reagent_material_prop_{j}_{k}"] = prop.value
                    initial_data[f"reagent_material_prop_uuid_{j}_{k}"] = prop.uuid
                reagent_initial.update(initial_data)
            initial.append(reagent_initial)
        return initial

    def get_form_kwargs(self):
        """
        Returns the kwargs related to reagent forms
        """

        reagents: "QuerySet[Reagent]" = self.experiment.reagent_ei.all()
        # Creating a form_kwargs key because that's what gets passed into the
        # FormSet. "form_data" key represents data for all reagents and other keys
        # on the same level e.g. "lab_uuid" can be used to pass other parameters
        kwargs = {
            "form_kwargs": {
                "form_data": {},
                "lab_uuid": self.request.session["current_org_id"],
            }
        }
        kwargs["form_kwargs"]["experiment_instance"] = self.experiment
        colors = get_colors(len(reagents))
        for i, rt in enumerate(reagents):
            kwargs["form_kwargs"]["form_data"][str(i)] = {
                "description": rt.description,
                "color": colors[i],
            }
            mat_types_list = []
            for j, rmt in enumerate(
                rt.reagent_material_r.all().order_by(
                    "template__material_type__description"
                )
            ):
                mat_types_list.append(rmt.template.material_type.description)

            kwargs["form_kwargs"]["form_data"][str(i)][
                "mat_types_list"
            ] = mat_types_list
            kwargs["form_kwargs"]["form_data"][str(i)]["reagent_template"] = rt

        return kwargs

    def get_reagent_forms(self, experiment, context):
        reagent_template_names = []
        rmvi_formsets = self.rmviFormSet(
            # prefix=f"reagent_{index}",
            initial=self.get_form_initial(),
            form_kwargs=self.get_form_kwargs(),
        )
        # rmvi_formsets.append(fset)
        context["rmvi_formsets"] = rmvi_formsets
        context["reagent_template_names"] = reagent_template_names
        context["colors"] = get_colors(rmvi_formsets.total_form_count())

        return context

    def post(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        experiment_instance_uuid = request.resolver_match.kwargs["pk"]
        self.experiment = ExperimentInstance.objects.get(uuid=experiment_instance_uuid)

        reagents = self.experiment.reagent_ei.all()
        formset = self.rmviFormSet(request.POST, form_kwargs=self.get_form_kwargs())
        if formset.is_valid():
            for form in formset:
                form.cleaned_data
                for k in form.cleaned_data:
                    if "reagent_prop_uuid" in k:
                        index = k.split("_")[-1]  # Last token of split is the index
                        prop = Property.objects.get(uuid=form.cleaned_data[k])
                        prop.value = form.cleaned_data[f"reagent_prop_{index}"]
                        prop.save()

                    elif "reagent_material_prop_uuid" in k:
                        primary_index = k.split("_")[-2]
                        secondary_index = k.split("_")[-1]
                        prop = Property.objects.get(uuid=form.cleaned_data[k])
                        prop.value = form.cleaned_data[
                            f"reagent_material_prop_{primary_index}_{secondary_index}"
                        ]
                        prop.save()

            return HttpResponseRedirect(reverse("experiment_instance_list"))
        else:
            context["rmvi_formsets"] = formset
            return render(request, self.template_name, context)
