from __future__ import annotations
from django.forms import formset_factory, ValidationError
from django.forms.formsets import formset_factory
from django.shortcuts import render
from django.http import HttpResponseRedirect
from django.core.exceptions import MultipleObjectsReturned
from django.contrib import messages
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
    Vessel,
    VesselTemplate,
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

    def get(self, request, *args, **kwargs):
        org_id = self.request.session.get("current_org_id", None)
        if not org_id:
            messages.error(request, "Please select a lab to continue")
            return HttpResponseRedirect(reverse("main_menu"))
        return super().get(request, *args, **kwargs)

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
                colors = get_colors(data["num_outcomes"])

                kwargs = {"form_kwargs": {"colors": colors}} #color data for UI forms

                return kwargs

        if step == ADD_MATERIALS:
            
            data = self.get_cleaned_data_for_step(INITIALIZE)
            if data is not None:
                colors = get_colors(data["num_reagents"])

                kwargs = {"form_kwargs": {"colors": colors}} #color data for UI forms

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


        reagents = self.get_cleaned_data_for_step(ADD_REAGENTS) #obtain reagent form data
        
        #for each reagent:
        reagent_templates = []
        vessel_templates = []
        for r in reagents: 
            #generate list of reagent-level properties, combining drop-down selection and those entered manually as text
            properties = r['properties']
            reagent = self.create_reagent_template(r["reagent_template_name"], properties) #create a reagent template
            reagent_templates.append(reagent)
            materials = []
            properties = []
            for i in self.get_cleaned_data_for_step(ADD_MATERIALS): #get list of materials associated with the reagent
                if i['name'] == r["reagent_template_name"]:
                    for key, val in i.items():
                        if 'select_mt' in key:
                            materials.append(val)
                        if 'properties' in key:
                            properties.append(val)
            self.add_materials(reagent.uuid, materials, properties[0]) #associate materials with reagent     
                      
            vessel = self.create_vessel_template(r["reagent_template_name"], outcome=False) #create a vessel template for the reagent
            vessel_templates.append(vessel)
        
        #outcome vessel
        ov = self.create_vessel_template(description="Outcome vessel", outcome=True) 
        vessel_templates.append(ov)
        
        outcomes = self.get_cleaned_data_for_step(ADD_OUTCOMES) #obtain outcome form data
        
        #for each outcome:
        outcome_templates = []
        for o in outcomes:
            outcome_description = o["define_outcomes"]
            outcome_type = o["outcome_type"]
            outcome = self.add_outcomes(outcome_description, outcome_type) #create outcome template and add to exp template
            outcome_templates.append(outcome)
        #create outcome vessel template
        
        
        exp_template_uuid = self.create_template(data) #create an experiment template with name provided
        exp_template = ExperimentTemplate.objects.get(uuid=exp_template_uuid)

        #associate reagents, vessels, and outcomes with the template
        for rt in reagent_templates:
            exp_template.reagent_templates.add(
                rt)
        for vt in vessel_templates:
            exp_template.vessel_templates.add(
                vt)
        for ot in outcome_templates:
            exp_template.outcome_templates.add(
                ot)
            ot.experiment = exp_template
            ot.save()

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

    def create_property_template(self, property):
        ''' helper function to generate a property template 
        that can be associated with a reagent, material, etc
        '''
        
        default_val = {"value": 0, "unit": "mL", "type": "num"}

        default_data = {
            "description": "Zero",
            "nominal_value": default_val,
            "actual_value": default_val,
        }

        try:
            default_val, created = DefaultValues.objects.get_or_create(
                **default_data
            )
        except MultipleObjectsReturned:
            default_val = DefaultValues.objects.filter(**default_data).first()


        # Create property template
        prop_template, created = PropertyTemplate.objects.get_or_create(
            **{
                "description": property.description,
                "property_def_class": "extrinsic",
                "default_value": default_val,
            }
        )
        
        return prop_template

    
    def create_reagent_template(self, name, properties):
        '''[summary]
        Args:
            name([str]): description of reagent template to create
            properties(list): contains PropertyTemplate objects to associate with a reagent; can be blank if none are specified

        Returns:
            [str]: uuid of new reagent template with specified name and properties
        '''

        reagent_template = ReagentTemplate(description=name)
        reagent_template.save()

        rt = ReagentTemplate.objects.get(uuid=reagent_template.uuid)


        # Create property templates for each reagent
        for p in properties:
            

            prop = PropertyTemplate.objects.filter(description=p).first()
            prop_template = self.create_property_template(prop) 
            rt.properties.add(prop_template)
        
        return rt

    def create_vessel_template(self, description, outcome=False):
        #exp_template = ExperimentTemplate.objects.get(uuid=exp_template_uuid)
        
        default_vessel, created = Vessel.objects.get_or_create(
                                description="Generic vessel"
                            )
        
        (vessel_template,
            created,
        ) = VesselTemplate.objects.get_or_create(
            description= description,
            outcome_vessel=outcome,
            default_vessel=default_vessel,
        )
        
        #exp_template.vessel_templates.add(
           # vessel_template)
        
        return vessel_template
        

    def add_materials(self, reagent, material_types, properties):
        '''[summary]
        Args:
            reagent[(str)]: uuid of reagent template
            materials([list]): list of uuid's of material types to be added to reagent template
            properties(list): contains PropertyTemplate objects to associate with each material
        
        Returns:
            N/A
            associates material types with reagent and adds desired properties 
        '''
        reagent_template = ReagentTemplate.objects.get(uuid=reagent)


        for num, r in enumerate(material_types):
            mt = MaterialType.objects.get(uuid=r)
            #mt, created = MaterialType.objects.get_or_create(description=r)
            # reagent_template.material_type.add(mt)

            rmt = ReagentMaterialTemplate.objects.create(
                **{
                    "description": f"{reagent_template.description}: {mt.description} {num}",
                    "reagent_template": reagent_template,
                    "material_type": mt,
                }
            )

            #for rv, default in reagent_values.items():
            for p in properties:
                prop = PropertyTemplate.objects.filter(description=p).first()
                prop_template = self.create_property_template(prop)
                rmt.properties.add(prop_template) #rmv_template)


    def add_outcomes(self,  outcome_description, outcome_type):
        '''[summary]
        Args:
            exp_template_uuid([str]): uuid of experiment template
            outcome_description([str]): description of outcome 
            outcome_type: TypeDef object specifying data type for default outcome value

        Returns:
            N/A
            associates outcome template with experiment template
        '''
        #exp_template = ExperimentTemplate.objects.get(uuid=exp_template_uuid)
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
            #experiment=exp_template,
            # instance_labels=well_list,
            default_value=default_score,
        )
        ot.save()
        return ot
