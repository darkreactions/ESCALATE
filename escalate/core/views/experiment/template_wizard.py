from __future__ import annotations
from django.forms import formset_factory
from django.forms.formsets import formset_factory
from django.shortcuts import render
from django.core.exceptions import MultipleObjectsReturned

from typing import List
from formtools.wizard.views import SessionWizardView

from django.urls import reverse

from core.models import DefaultValues, ReagentTemplate

from core.models.view_tables import (
    ExperimentTemplate,
    Actor,
    ReagentTemplate,
    ReagentMaterialTemplate,
    MaterialType,
    OutcomeTemplate,
)
from core.forms.template_wizard import (
    OutcomeDefinitionForm,
    ExperimentTemplateCreateForm,
    ReagentTemplateCreateForm,
    ReagentTemplateMaterialAddForm,
)
from core.utilities.utils import get_colors
from core.models.view_tables.generic_data import PropertyTemplate

from core.forms.wizard import BaseReagentFormSet

#steps with names to display in UI
INITIALIZE = "Create Experiment Template"
ADD_REAGENTS = "Define Reagents"
ADD_MATERIALS = "Define Reagent Materials"
ADD_OUTCOMES = "Define Outcomes"


class CreateTemplateWizard(SessionWizardView):
    
    #list steps in order, where each step is a tuple: (step name, form/formset)
    form_list = [
        (INITIALIZE, ExperimentTemplateCreateForm),
        (
            ADD_REAGENTS,
            formset_factory(
                ReagentTemplateCreateForm, extra=0, formset=BaseReagentFormSet,
            ),
        ),
        (
            ADD_MATERIALS,
            formset_factory(
                ReagentTemplateMaterialAddForm, extra=0,  formset=BaseReagentFormSet,
            ),
        ),
        (
            ADD_OUTCOMES,
            formset_factory(
                OutcomeDefinitionForm, extra=0, formset=BaseReagentFormSet,
            ),
        ),
    ]

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

    def get_form_initial(self, step):
        if step == ADD_REAGENTS:
            initial = []
            data = self.get_cleaned_data_for_step(INITIALIZE)
            if data is not None:
                #pass number of reagents as initial data to determine form count
                num_reagents = int(data["num_reagents"])
                for i in range(num_reagents):
                    initial.append({})
            return initial

        if step == ADD_MATERIALS:
            initial = []
            data = self.get_cleaned_data_for_step(ADD_REAGENTS)
            if data is not None:
                #pass reagent name and nunber of materials as initial data to determine form count
                for form in data:
                    material_initial = {}
                    forms_initial = []
                    name = form["reagent_template_name"]
                    num_materials = int(form["num_materials"])

                    for i in range(num_materials):
                        forms_initial.append({})
                    material_initial.update({name: forms_initial})
                    initial.append(material_initial)
            return initial

        if step == ADD_OUTCOMES:
            initial = []
            data = self.get_cleaned_data_for_step(INITIALIZE)
            if data is not None:
                #pass number of outcomes as initial data to determine form count
                num_outcomes = int(data["num_outcomes"])
                for i in range(num_outcomes):
                    initial.append({})
            return initial

    def get_form_kwargs(self, step=None):
        if step == INITIALIZE:
            org_id = self.request.session.get("current_org_id", None)
            return {"org_id": org_id}
        if step == ADD_REAGENTS:
            data = self.get_cleaned_data_for_step(INITIALIZE)
            if data is not None:
                colors = get_colors(data["num_reagents"])

                kwargs = {"form_kwargs": {"colors": colors}} #color data for UI forms

                return kwargs

        if step == ADD_OUTCOMES:
            data = self.get_cleaned_data_for_step(INITIALIZE)
            if data is not None:
                colors = self._get_colors(data["num_outcomes"])

                kwargs = {"form_kwargs": {"colors": colors}} #color data for UI forms

                return kwargs

        if step == ADD_MATERIALS:
            
            data = self.get_cleaned_data_for_step(INITIALIZE)
            if data is not None:
                colors = get_colors(data["num_reagents"])

                kwargs = {"form_kwargs": {"colors": colors}} #color data for UI forms

            ''' kwargs = {"form_kwargs": {"materials": {}}}
            num_reagents = self.get_cleaned_data_for_step(INITIALIZE)["num_reagents"]
            data = self.get_cleaned_data_for_step(ADD_REAGENTS)
            for i in range(int(num_reagents)):
                material_initial = {}
                mat_initial = []
                name = data[i]["reagent_template_name"]
                num_materials = data[i]["num_materials"]
                for i in range(num_materials):
                    mat_initial.append({})
                material_initial.update({name: mat_initial})
                kwargs["form_kwargs"]["materials"].update(material_initial)'''

            return kwargs

        return {}

    def get_template_names(self) -> List[str]:
        return ["core/experiment/create/wizard.html"]

    def done(self, form_list, **kwargs):
        #upon submitting last form...

        data = self.get_cleaned_data_for_step(INITIALIZE)
        org_id = self.get_form_kwargs(INITIALIZE)["org_id"]
        lab = Actor.objects.get(organization=org_id, person__isnull=True)
        data["lab"] = lab

        exp_template_uuid = self.create_template(data) #create an experiment template with name provided

        reagents = self.get_cleaned_data_for_step(ADD_REAGENTS) #obtain reagent form data
        
        #for each reagent:
        for r in reagents: 
            reagent = self.create_reagent_template(r["reagent_template_name"]) #create a reagent template
            materials = []
            for i in self.get_cleaned_data_for_step(ADD_MATERIALS): #get list of materials associated with the reagent
                if i['name'] == r["reagent_template_name"]:
                    for key, val in i.items():
                        if 'select_mt' in key:
                            materials.append(val)
            self.add_materials(reagent.uuid, materials) #associate materials with reagent
            self.add_reagent(exp_template_uuid, reagent.uuid) #associate reagent template with experiment template

        outcomes = self.get_cleaned_data_for_step(ADD_OUTCOMES) #obtain outcome form data
        
        #for each outcome:
        for o in outcomes:
            outcome_description = o["define_outcomes"]
            outcome_type = o["outcome_type"]
            self.add_outcomes(exp_template_uuid, outcome_description, outcome_type) #create outcome template and add to exp template

        #unique action template creation link for each exp template uuid
        workflow_link = reverse("action_template", args=[str(exp_template_uuid)])

        return render(
            self.request,
            "core/experiment/create/done.html",
            {
                "form_data": [form.cleaned_data for form in form_list],
                "workflow_link": workflow_link,
                "template_name": data["template_name"],
            },
        )

    def create_template(self, data):
        '''[summary]
        Args:
            data: form data from ExperimentTemplateCreateForm

        Returns:
            [str]: uuid of new experiment template created from data
        '''
        exp_template = ExperimentTemplate(
            description=data["template_name"],
            ref_uid=data["template_name"],
            lab=data["lab"],
        )
        exp_template.save()

        return exp_template.uuid

    def create_reagent_template(self, name):
        '''[summary]
        Args:
            name([str]): description of reagent template to create

        Returns:
            [str]: uuid of new reagent template with specified name
                ***NOTE default properties of total volume and dead volume are automatically added to template
        '''

        reagent_template = ReagentTemplate(description=name)
        reagent_template.save()

        rt = ReagentTemplate.objects.get(uuid=reagent_template.uuid)

        volume_val = {"value": 0, "unit": "ml", "type": "num"}
        dead_vol_val = {"value": 4000, "unit": "uL", "type": "num"}

        default_volume_data = {
            "description": "Zero ml",
            "nominal_value": volume_val,
            "actual_value": volume_val,
        }
        try:
            default_volume, created = DefaultValues.objects.get_or_create(
                **default_volume_data
            )
        except MultipleObjectsReturned:
            default_volume = DefaultValues.objects.filter(**default_volume_data).first()

        default_dead_volume_data = {
            "description": "WF1 dead volume",
            "nominal_value": dead_vol_val,
            "actual_value": dead_vol_val,
        }
        try:
            default_dead_volume, created = DefaultValues.objects.get_or_create(
                **default_dead_volume_data
            )
        except MultipleObjectsReturned:
            default_dead_volume = DefaultValues.objects.filter(
                **default_dead_volume
            ).first()

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
        return rt

    def add_materials(self, reagent, material_types):
        '''[summary]
        Args:
            reagent[(str)]: uuid of reagent template
            materials([list]): list of uuid's of material types to be added to reagent templae
        
        Returns:
            N/A
            associates material types with reagent and adds default properties (amount and concentration)
        '''
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
                (rmv_template, created,) = PropertyTemplate.objects.get_or_create(
                    **{
                        "description": rv,
                        # "reagent_material_template": rmt,
                        "default_value": default,
                    }
                )
                rmt.properties.add(rmv_template)

    def add_reagent(self, exp_template_uuid, reagent):
        '''[summary]
        Args:
            exp_template_uuid([str]): uuid of experiment template
            reagent([str]): uuid of reagent template

        Returns:
            N/A
            associates reagent template with experiment template
        '''
        exp_template = ExperimentTemplate.objects.get(uuid=exp_template_uuid)
        rt = ReagentTemplate.objects.get(uuid=reagent)
        exp_template.reagent_templates.add(rt)

    def add_outcomes(self, exp_template_uuid, outcome_description, outcome_type):
        '''[summary]
        Args:
            exp_template_uuid([str]): uuid of experiment template
            outcome_description([str]): description of outcome 
            outcome_type: TypeDef object specifying data type for default outcome value

        Returns:
            N/A
            associates outcome template with experiment template
        '''
        exp_template = ExperimentTemplate.objects.get(uuid=exp_template_uuid)
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