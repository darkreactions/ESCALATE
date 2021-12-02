from django.views.generic import TemplateView
from django.forms import formset_factory
from django.shortcuts import render
from django.urls import reverse
from django.http import HttpResponseRedirect

from core.models.view_tables import (
    ExperimentInstance,
    ReagentMaterialValue,
)
from core.forms.custom_types import ReagentValueForm
from core.forms.custom_types import BaseReagentFormSet, PropertyForm


class ExperimentReagentPrepView(TemplateView):
    template_name = "core/experiment_reagent_prep.html"
    # form_class = ExperimentTemplateForm
    # ReagentFormSet = formset_factory(ReagentForm, extra=0, formset=BaseReagentFormSet)
    ReagentFormSet = formset_factory(
        ReagentValueForm, extra=0, formset=BaseReagentFormSet,
    )

    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        pk = kwargs["pk"]
        experiment = ExperimentInstance.objects.get(pk=pk)
        context = self.get_reagent_forms(experiment, context)
        return render(request, self.template_name, context)

    def get_colors(
        self,
        number_of_colors,
        colors=[
            "lightblue",
            "teal",
            "powderblue",
            "skyblue",
            "pastelblue",
            "verdigris",
            "steelblue",
            "cornflowerblue",
        ],
    ):
        factor = int(number_of_colors / len(colors))
        remainder = number_of_colors % len(colors)
        total_colors = colors * factor + colors[:remainder]
        return total_colors

    def get_reagent_forms(self, experiment, context):
        formsets = []
        reagent_names = []
        reagent_template_names = []
        reagent_total_volume_forms = []
        form_kwargs = {
            "disabled_fields": ["material", "material_type", "nominal_value"],
        }

        context["helper"] = ReagentValueForm.get_helper(
            readonly_fields=["material", "material_type", "nominal_value"]
        )
        context["helper"].form_tag = False

        context["volume_form_helper"] = PropertyForm.get_helper()
        context["volume_form_helper"].form_tag = False

        # for index, reagent_template in enumerate(reagent_templates):
        for index, reagent in enumerate(experiment.reagent_ei.all()):
            reagent_template_names.append(reagent.template.description)
            reagent_materials = reagent.reagent_material_r.filter(
                reagent_material_value_rmi__description="amount"
            )
            #  template__reagent_template=)
            property = reagent.property_r.get(
                property_template__description__iexact="total volume"
            )
            reagent_total_volume_forms.append(
                PropertyForm(
                    instance=property,
                    nominal_value_label="Calculated Volume",
                    value_label="Measured Volume",
                    disabled_fields=["nominal_value"],
                )
            )
            initial = []
            for reagent_material in reagent_materials:

                reagent_names.append(reagent_material.description)
                rmvi = reagent_material.reagent_material_value_rmi.all().get(
                    template__description="amount"
                )
                initial.append(
                    {
                        "material_type": reagent_material.template.material_type.description,
                        "material": reagent_material.material,
                        "nominal_value": rmvi.nominal_value,
                        "actual_value": rmvi.actual_value,
                        "uuid": rmvi.uuid,
                    }
                )

            fset = self.ReagentFormSet(
                prefix=f"reagent_{index}", initial=initial, form_kwargs=form_kwargs
            )
            formsets.append(fset)

        context["reagent_formsets"] = zip(formsets, reagent_total_volume_forms)
        context["reagent_template_names"] = reagent_template_names
        context["colors"] = self.get_colors(len(formsets))

        return context

    def post(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        experiment_instance_uuid = request.resolver_match.kwargs["pk"]
        experiment = ExperimentInstance.objects.get(uuid=experiment_instance_uuid)
        reagent_templates = experiment.parent.reagent_templates.all()
        formsets = []
        valid_forms = True
        for index in range(len(reagent_templates)):
            property_form = PropertyForm(request.POST)
            if property_form.is_valid():
                property_form.save()
            else:
                valid_forms = False
            fset = self.ReagentFormSet(request.POST, prefix=f"reagent_{index}")
            formsets.append(fset)
            if fset.is_valid():
                for form in fset:
                    rmvi = ReagentMaterialValue.objects.get(
                        uuid=form.cleaned_data["uuid"]
                    )
                    rmvi.actual_value = form.cleaned_data["actual_value"]
                    rmvi.save()
            else:
                valid_forms = False

        if valid_forms:
            return HttpResponseRedirect(reverse("experiment_instance_list"))
        else:
            return render(request, self.template_name, context)
