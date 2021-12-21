from __future__ import annotations
from django.http.request import HttpRequest
from django.http import HttpResponseRedirect

from django.views.generic import TemplateView
from django.shortcuts import render
from django.contrib import messages
from django.urls import reverse

from core.models import DefaultValues, ReagentTemplate

from core.models.view_tables import (
    ExperimentTemplate,
    Actor,
    ReagentTemplate,
    ReagentMaterialTemplate,
    MaterialType,
    OutcomeTemplate,
    ExperimentActionSequence,
    ActionSequence,
)
from core.forms.custom_types import (
    ReagentSelectionForm,
    ActionSequenceSelectionForm,
    MaterialTypeSelectionForm,
)
from core.forms.custom_types import (
    ExperimentTemplateCreateForm,
    ReagentTemplateCreateForm,
)
from core.models.view_tables.generic_data import PropertyTemplate


class CreateReagentTemplate(TemplateView):
    template_name = "core/create_reagent_template.html"
    form_class = ReagentTemplateCreateForm

    def get_context_data(self, **kwargs):
        # Select materials that belong to the current lab
        context = super().get_context_data(**kwargs)
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            lab = Actor.objects.get(organization=org_id, person__isnull=True)
            # self.all_materials = InventoryMaterial.inventory.objects.filter(lab=lab)
            context["lab"] = lab
        # self.all_materials = InventoryMaterial.objects.all()
        # context['all_materials'] = self.all_materials
        return context

    def create_template(self, context):
        reagent_template = ReagentTemplate(description=context["name"],)
        # ref_uid=context['name'],)
        # lab=context['lab'])
        reagent_template.save()
        # exp_uuid = ExperimentTemplate.objects.get(description=context['name'])
        # context['exp_uuid']=exp_template.uuid
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

    def add_materials(self, context):
        reagent_template = ReagentTemplate.objects.get(uuid=context["rt_uuid"])

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

        for r in context["material_types"]:
            mt = MaterialType.objects.get(uuid=r)
            # reagent_template.material_type.add(mt)

            rmt = ReagentMaterialTemplate.objects.get_or_create(
                **{
                    "description": f"{reagent_template.description}: {mt.description}",
                    "reagent_template": reagent_template,
                    "material_type": mt,
                }
            )

    def get(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)

        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            context["reagent_template_create_form"] = ReagentTemplateCreateForm(
                org_id=org_id
            )
            return render(request, self.template_name, context)

        else:
            # context = self.get_context_data(**kwargs)
            # self.template_name = "core/main_menu.html"
            org_id = None
            messages.error(request, "Please select a lab to continue")
            return HttpResponseRedirect(reverse("main_menu"))

    # if 'current_org_id' in self.request.session:
    #   org_id = self.request.session['current_org_id']
    # else:
    #  org_id = None

    # context['reagent_template_create_form'] = ReagentTemplateCreateForm(org_id=org_id)
    # return render(request, self.template_name, context)

    def post(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        if "create_template" in request.POST:
            form = MaterialTypeSelectionForm(request.POST)
            if form.is_valid():
                temp = form.cleaned_data.get("select_mt")
                context["material_types"] = temp
            context["name"] = request.POST["template_name"]
            self.create_template(context)
            self.add_materials(context)

        return render(request, self.template_name, context)


class CreateExperimentTemplate(TemplateView):
    template_name = "core/create_exp_template.html"
    form_class = ExperimentTemplateCreateForm
    # MaterialFormSet: Type[BaseFormSet] = formset_factory(InventoryMaterialForm, extra=0)
    # ReagentFormSet: Type[BaseFormSet] = formset_factory(ReagentForm, extra=0, formset=BaseReagentFormSet)

    def get_context_data(self, **kwargs):
        # Select materials that belong to the current lab
        context = super().get_context_data(**kwargs)
        if "current_org_id" in self.request.session:
            org_id = self.request.session["current_org_id"]
            lab = Actor.objects.get(organization=org_id, person__isnull=True)
            # self.all_materials = InventoryMaterial.inventory.objects.filter(lab=lab)
            context["lab"] = lab
        # self.all_materials = InventoryMaterial.objects.all()
        # context['all_materials'] = self.all_materials
        return context

    def create_template(self, context):
        exp_template = ExperimentTemplate(
            description=context["name"], ref_uid=context["name"], lab=context["lab"]
        )
        exp_template.save()
        # exp_uuid = ExperimentTemplate.objects.get(description=context['name'])
        context["exp_uuid"] = exp_template.uuid
        return context

    def add_reagents(self, context, reagents):
        exp_template = ExperimentTemplate.objects.get(uuid=context["exp_uuid"])
        for r in reagents:
            rt = ReagentTemplate.objects.get(uuid=r)
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

    def add_outcomes(self, context, outcome_type, well_num):
        exp_template = ExperimentTemplate.objects.get(uuid=context["exp_uuid"])
        outcome_val = {"value": 0, "unit": "", "type": "text"}
        default_score, created = DefaultValues.objects.get_or_create(
            **{
                "description": "Zero outcome val",
                "nominal_value": outcome_val,
                "actual_value": outcome_val,
            }
        )
        well_list = make_well_labels_list(well_num, robot="False")

        ot, created = OutcomeTemplate.objects.get_or_create(
            description=outcome_type,
            experiment=exp_template,
            instance_labels=well_list,
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
            return render(request, self.template_name, context)

        else:
            # context = self.get_context_data(**kwargs)
            # self.template_name = "core/main_menu.html"
            org_id = None
            messages.error(request, "Please select a lab to continue")
            return HttpResponseRedirect(reverse("main_menu"))

    def post(self, request: HttpRequest, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        if "create_template" in request.POST:
            context["name"] = request.POST["template_name"]
            # context['outcome_type'] =request.POST['define_outcomes']
            self.create_template(context)
            form = ReagentSelectionForm(request.POST)
            if form.is_valid():
                # temp = form.cleaned_data.get('select_rt')
                self.add_reagents(context, form.cleaned_data.get("select_rt"))
                # context['reagents'] = temp
            form2 = ActionSequenceSelectionForm(request.POST)
            if form2.is_valid():
                # temp = form2.cleaned_data.get('select_actions')
                self.add_actions(context, form2.cleaned_data.get("select_actions"))
                # context['action_sequences'] = temp
            # context['name'] = request.POST['template_name']
            # context['reagents'] = request.POST['select_rt']
            # context['plate'] = request.POST['select_vessel']
            # context['cols'] = request.POST['column_order']
            # context['rows'] = int(request.POST['rows'])
            # context['reagent_number'] = int(request.POST['reagent_num'])
            # self.create_template(context)
            # self.add_reagents(context)
            # self.add_actions(context)
            self.add_outcomes(
                context, request.POST["define_outcomes"], int(request.POST["well_num"])
            )

        return render(request, self.template_name, context)
