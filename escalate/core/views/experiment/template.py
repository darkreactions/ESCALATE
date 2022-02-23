from __future__ import annotations
from django.forms.formsets import formset_factory
from django.http.request import HttpRequest
from django.http import HttpResponseRedirect

from django.views.generic import TemplateView
from django.shortcuts import render
from django.db import IntegrityError
from django.contrib import messages
from django.urls import reverse

from core.models import DefaultValues, ReagentTemplate

from core.models.view_tables import (
    ExperimentTemplate,
    Actor,
    ReagentTemplate,
    ReagentMaterialTemplate,
    ReagentMaterialValueTemplate,
    MaterialType,
    OutcomeTemplate,
    ExperimentActionSequence,
    ActionSequence,
)
from core.forms.custom_types import (
    OutcomeDefinitionForm,
    ExperimentTemplateCreateForm,
    ReagentTemplateCreateForm,
    ExperimentTemplateNameForm,
)

from core.models.view_tables.generic_data import PropertyTemplate
from django.forms import formset_factory


class CreateExperimentTemplate(TemplateView):
    template_name = "core/create_exp_template.html"
    form_class = ExperimentTemplateCreateForm

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            lab = Actor.objects.get(organization=org_id, person__isnull=True)
            context["lab"] = lab

        return context

    def create_template(self, context):
        exp_template = ExperimentTemplate(
            description=context["new_template_name"],
            ref_uid=context["new_template_name"],
            lab=context["lab"],
        )
        exp_template.save()
        context["exp_uuid"] = exp_template.uuid
        return context

    def create_reagent_template(self, name):
        # reagent_template = ReagentTemplate(description=context["new_template_name"],)
        reagent_template = ReagentTemplate(description=name)
        # ref_uid=context['name'],)
        # lab=context['lab'])
        reagent_template.save()
        # exp_uuid = ExperimentTemplate.objects.get(description=context['name'])
        # context['exp_uuid']=exp_template.uuid
        context = {}
        context["rt_uuid"] = reagent_template.uuid
        rt = ReagentTemplate.objects.get(uuid=context["rt_uuid"])

        volume_val = {"value": 0, "unit": "ml", "type": "num"}
        dead_vol_val = {"value": 4000, "unit": "uL", "type": "num"}

        # Create default values
        default_volume, created = DefaultValues.objects.get_or_create(
            **{
                "description": "Zero ml",
                "nominal_value": volume_val,
                "actual_value": volume_val,
            }
        )
        default_dead_volume, created = DefaultValues.objects.get_or_create(
            **{
                "description": "WF1 dead volume",
                "nominal_value": dead_vol_val,
                "actual_value": dead_vol_val,
            }
        )

        # Create total volume and dead volume property templates for each reagent
        total_volume_prop, created = PropertyTemplate.objects.get_or_create(
            **{
                "description": "total volume",
                "property_def_class": "extrinsic",
                "short_description": "volume",
                "default_value": default_volume,
            }
        )
        dead_volume_prop, created = PropertyTemplate.objects.get_or_create(
            **{
                "description": "dead volume",
                "property_def_class": "extrinsic",
                "short_description": "dead volume",
                "default_value": default_dead_volume,
            }
        )
        rt.properties.add(total_volume_prop)
        rt.properties.add(dead_volume_prop)
        return context

    def add_materials(self, reagent, material_types):
        reagent_template = ReagentTemplate.objects.get(uuid=reagent)

        amount_val = {"value": 0, "unit": "g", "type": "num"}

        conc_val = {"value": 0, "unit": "M", "type": "num"}

        default_amount, created = DefaultValues.objects.get_or_create(
            **{
                "description": "Zero g",
                "nominal_value": amount_val,
                "actual_value": amount_val,
            }
        )

        default_conc, created = DefaultValues.objects.get_or_create(
            **{
                "description": "Zero M",
                "nominal_value": conc_val,
                "actual_value": conc_val,
            }
        )

        # Concentration and amount data to be stored for each reagent material
        reagent_values = {"concentration": default_conc, "amount": default_amount}

        for r in material_types:
            mt = MaterialType.objects.get(uuid=r)
            # reagent_template.material_type.add(mt)

            (rmt, created) = ReagentMaterialTemplate.objects.get_or_create(
                **{
                    "description": f"{reagent_template.description}: {mt.description}",
                    "reagent_template": reagent_template,
                    "material_type": mt,
                }
            )

            for rv, default in reagent_values.items():
                (
                    rmv_template,
                    created,
                ) = ReagentMaterialValueTemplate.objects.get_or_create(
                    **{
                        "description": rv,
                        "reagent_material_template": rmt,
                        "default_value": default,
                    }
                )

    def add_reagent(self, context, reagent):
        exp_template = ExperimentTemplate.objects.get(uuid=context["exp_uuid"])
        # for r in reagents:
        rt = ReagentTemplate.objects.get(uuid=reagent)
        exp_template.reagent_templates.add(rt)
        # rt= ReagentTemplate.objects.get(uuid=context['reagents'])
        # exp_template.reagent_templates.add(rt)

    def add_actions(self, context, action_sequences):
        exp_template = ExperimentTemplate.objects.get(uuid=context["exp_uuid"])
        for i, a in enumerate(action_sequences):
            ac_sq = ActionSequence.objects.get(uuid=a)
            eas = ExperimentActionSequence(
                experiment_template=exp_template,
                experiment_action_sequence_seq=i,
                action_sequence=ac_sq,
            )
            eas.save()

    def add_outcomes(self, context, outcome_description, outcome_type):
        exp_template = ExperimentTemplate.objects.get(uuid=context["exp_uuid"])
        outcome_val = {"value": 0.0, "unit": " ", "type": outcome_type}
        default_score, created = DefaultValues.objects.get_or_create(
            **{
                "description": outcome_type,
                "nominal_value": outcome_val,
                "actual_value": outcome_val,
            }
        )

        ot, created = OutcomeTemplate.objects.get_or_create(
            description=outcome_description,
            experiment=exp_template,
            # instance_labels=well_list,
            default_value=default_score,
        )
        ot.save()
        exp_template.outcome_templates.add(ot)

    def get(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)

        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            context["experiment_template_create_form"] = ExperimentTemplateCreateForm(
                org_id=org_id
            )
        else:
            # context = self.get_context_data(**kwargs)
            # self.template_name = "core/main_menu.html"
            org_id = None
            messages.error(request, "Please select a lab to continue")
            return HttpResponseRedirect(reverse("main_menu"))

        return render(request, self.template_name, context)

    def post(self, request: HttpRequest, *args, **kwargs):

        if "create_template" in request.POST:
            context = self.get_context_data(**kwargs)

            context["num_reagents"] = int(request.POST.get("num_reagents"))
            context["num_outcomes"] = int(request.POST.get("num_outcomes"))

            context["name_form"] = ExperimentTemplateNameForm()

            ReagentCreateFormset = formset_factory(
                ReagentTemplateCreateForm, extra=context["num_reagents"]
            )

            context["reagent_forms"] = ReagentCreateFormset(prefix="reagent_forms")

            OutcomeDefinitionFormset = formset_factory(
                OutcomeDefinitionForm, extra=context["num_outcomes"]
            )

            context["outcome_definition_forms"] = OutcomeDefinitionFormset(
                prefix="outcome_forms"
            )

        if "submit_template" in request.POST:
            context = self.get_context_data(**kwargs)
            # context['outcome_type'] =request.POST['define_outcomes']
            context["new_template_name"] = request.POST["exp_template_name"]
            try:
                self.create_template(context)
            except IntegrityError:
                # return render(request, "core/create_exp_template.html", {"message": e})
                ie = "Experiment template name already exists. Please enter a different name"
                messages.error(request, ie)

                context = self.get_context_data(**kwargs)
                context["name_form"] = ExperimentTemplateNameForm()

                num_reagents = 0
                for key in request.POST:
                    if "reagent_template_name" in key:
                        num_reagents += 1
                ReagentCreateFormset = formset_factory(
                    ReagentTemplateCreateForm, extra=num_reagents
                )(request.POST, prefix="reagent_forms")

                context["reagent_forms"] = ReagentCreateFormset

                num_outcomes = 0
                for key in request.POST:
                    if "define_outcomes" in key:
                        num_outcomes += 1

                OutcomeDefinitionFormset = formset_factory(
                    OutcomeDefinitionForm, extra=num_outcomes
                )(request.POST, prefix="outcome_forms")
                context["outcome_definition_forms"] = OutcomeDefinitionFormset

                return render(request, self.template_name, context)

            num_reagents = 0
            for key in request.POST:
                if "reagent_template_name" in key:
                    num_reagents += 1
            temp_formset = formset_factory(
                ReagentTemplateCreateForm, extra=num_reagents
            )(request.POST, prefix="reagent_forms")
            if temp_formset.is_valid():
                for i in temp_formset.cleaned_data:
                    reagent = self.create_reagent_template(i["reagent_template_name"])
                    self.add_materials(reagent["rt_uuid"], i["select_mt"])
                    self.add_reagent(context, reagent["rt_uuid"])

            num_outcomes = 0
            for key in request.POST:
                if "define_outcomes" in key:
                    num_outcomes += 1

            temp_formset = formset_factory(OutcomeDefinitionForm, extra=num_outcomes)(
                request.POST, prefix="outcome_forms"
            )
            if temp_formset.is_valid():
                for i in temp_formset.cleaned_data:
                    outcome_description = i["define_outcomes"]
                    outcome_type = i["outcome_type"]
                    self.add_outcomes(context, outcome_description, outcome_type)

            context["workflow_link"] = reverse(
                "action_sequence", args=[str(context["exp_uuid"])]
            )

        return render(request, self.template_name, context)

