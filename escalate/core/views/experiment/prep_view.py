from sys import prefix
from django.views.generic import TemplateView
from django.forms import formset_factory
from django.shortcuts import render
from django.urls import reverse
from django.http import HttpResponseRedirect

from core.models.view_tables import (
    ExperimentInstance,
    # ReagentMaterialValue,
    Property,
)
from core.forms.custom_types import BaseReagentFormSet, ReagentRMVIForm
from core.utilities.utils import get_colors



class ExperimentReagentPrepView(TemplateView):
    template_name = "core/experiment_reagent_prep.html"
    # form_class = ExperimentTemplateForm
    # ReagentFormSet = formset_factory(ReagentForm, extra=0, formset=BaseReagentFormSet)
    '''ReagentPropertyFormSet= formset_factory(
        PropertyForm,
        extra=0,
        formset=BaseReagentFormSet,
    )
    
    ReagentFormSet = formset_factory(
        ReagentValueForm,
        extra=0,
        formset=BaseReagentFormSet,
    )'''

    rmviFormSet = formset_factory(
        #PropertyForm,
        ReagentRMVIForm,
        extra=0,
        formset= BaseReagentFormSet,
    )


    def get(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        pk = kwargs["pk"]
        experiment = ExperimentInstance.objects.get(pk=pk)
        context = self.get_reagent_forms(experiment, context)
        return render(request, self.template_name, context)

    def get_reagent_forms(self, experiment, context):
        
        rmvi_formsets = []
        form_kwargs = {
            "disabled_fields": []#["material", "material_type",] #"nominal_value"],
        }
        context["form_helper"] = ReagentRMVIForm.get_helper(
            #readonly_fields=[]#["material", "material_type",], #"nominal_value"]
            )
        context["form_helper"].form_tag = False
        
        initial = []
        reagent_template_names=[]

        for index, reagent in enumerate(experiment.reagent_ei.all()):
            reagent_template_names.append(reagent.template.description)
            reagent_initial = {}
            #for j, prop in enumerate(rt.properties.all()):
            for i, prop in enumerate(reagent.property_r.all()):
                reagent_initial.update(
                    {
                        f"reagent_prop_uuid_{i}": prop.uuid,
                        f"nominal_reagent_prop_{i}": prop.nominal_value,
                    }
                )

            reagent_materials = reagent.reagent_material_r.filter(
                property_rm__template__description="amount"
            )
            for j, rmi in enumerate(reagent_materials):
                #rmt: ReagentMaterialTemplate
                initial_data = {
                    f"material_{j}": str(rmi.material),
                    f"material_type_{j}": str(rmi.template.material_type),
                }
                #for k, prop in enumerate(rmi.properties.all()):
                for k, rmvi in enumerate(rmi.property_rm.all()):
                    rmvi: Property
                    initial_data[
                        f"nominal_reagent_material_prop_{j}_{k}"
                    ] = prop.nominal_value
                    initial_data[f"reagent_material_prop_uuid_{j}_{k}"] = rmvi.uuid
                reagent_initial.update(initial_data)
            initial.append(reagent_initial)
        #return initial

            fset = self.rmviFormSet(
                    prefix=f"reagent_{index}", initial=initial, form_kwargs=form_kwargs
                )
            rmvi_formsets.append(fset)

        context["rmvi_formsets"] = rmvi_formsets
        #context["rmvi_formsets"] = rmvi_formsets
        context["reagent_template_names"] = reagent_template_names
        context["colors"] = get_colors(len(rmvi_formsets))
        
        
        
        
        
        
        '''reagent_material_formsets = []
        mat_form_kwargs = {
            "disabled_fields": ["material", "material_type",] #"nominal_value"],
        }
        context["material_form_helper"] = ReagentValueForm.get_helper(
            readonly_fields=["material", "material_type",], #"nominal_value"]
            )
        context["material_form_helper"].form_tag = False
        rmvi_formsets = []
        
        
        reagent_property_formsets=[]
        reagent_names = []
        reagent_template_names = []
        #reagent_total_volume_forms = []
        prop_form_kwargs = {"disabled_fields": ["uuid"]}

        context["property_form_helper"] = PropertyForm.get_helper()
        context["property_form_helper"].form_tag = False'''

        # for index, reagent_template in enumerate(reagent_templates):
        '''for index, reagent in enumerate(experiment.reagent_ei.all()):
            #get reagent template and name
            reagent_template_names.append(reagent.template.description)
            #get reagent materials for the reagent
            reagent_materials = reagent.reagent_material_r.filter(
                property_rm__template__description="amount"
            )
            #reagent_property_forms.append([])
            #get all reagent-level properties
            initial=[]
            for i, prop in enumerate(reagent.property_r.all()):
                initial.append(
                {
                    "instance": prop,
                    "nominal_value_label": f"Desired {prop.template.description}",
                    "value_label":f"Measured {prop.template.description}",
                    #"disabled_fields":["nominal_value"],
                    "prefix":f"reagent_total_{index}",
                    #"uuid": prop.uuid
                })
                
            fset = self.ReagentPropertyFormSet(
                prefix=f"reagent_total_{index}", initial=initial, form_kwargs=prop_form_kwargs
            )
            reagent_property_formsets.append(fset)

            #get data for all materials in the reagent and all of their properties
            initial_material_data = []
            for reagent_material in reagent_materials:

                reagent_names.append(reagent_material.description)

                #nominal_vals=[]
                #actual_vals=[]
                #uuids = []

                initial_material_data.append(
                    {
                    "material_type": reagent_material.template.material_type.description,
                    "material": reagent_material.material,
                    #"nominal_value": nominal_vals,
                    #"actual_value": actual_vals,
                    #"uuid":uuids,
                })

                initial_rmvi_data=[]
                for i, rmvi in enumerate(reagent_material.property_rm.all()):
                     
                    initial_rmvi_data.append(
                    {
                        "instance": rmvi,
                        "nominal_value_label": f"Desired {rmvi.template.description}",
                        "value_label":f"Measured {rmvi.template.description}",
                        #"disabled_fields":["nominal_value"],
                        "prefix":f"reagent_{i}",
                        "uuid": rmvi.uuid
                    })

                fset = self.rmviFormSet(
                prefix=f"reagent_{index}", initial=initial_rmvi_data, form_kwargs=prop_form_kwargs)

                rmvi_formsets.append(fset)

            fset = self.ReagentFormSet(
            prefix=f"reagent_{index}", initial=initial_material_data, form_kwargs=mat_form_kwargs)


            reagent_material_formsets.append(fset)
            
                    
                   # nominal_vals.append({f"Desired {rmvi.template.description}": rmvi.nominal_value})
                   # actual_vals.append({f"Measured {rmvi.template.description}": rmvi.value})
                    #uuids.append(rmvi.uuid)'''
                
        ''' initial.append(
                {
                    "material_type": reagent_material.template.material_type.description,
                    "material": reagent_material.material,
                    "nominal_value": nominal_vals,
                    "actual_value": actual_vals,
                    "uuid":uuids,
                }
                )'''
            
        '''context["reagent_formsets"] = zip(reagent_material_formsets, rmvi_formsets, reagent_property_formsets)
        #context["rmvi_formsets"] = rmvi_formsets
        context["reagent_template_names"] = reagent_template_names
        context["colors"] = get_colors(len(reagent_material_formsets))

        return context'''

    def post(self, request, *args, **kwargs):
        context = self.get_context_data(**kwargs)
        experiment_instance_uuid = request.resolver_match.kwargs["pk"]
        experiment = ExperimentInstance.objects.get(uuid=experiment_instance_uuid)
        # reagent_templates = experiment.parent.reagent_templates.all()
        reagents = experiment.reagent_ei.all()
        formsets = []
        valid_forms = True
        for index, reagent in enumerate(reagents):
            '''material_count= int(request.POST[f"reagent_{index}-TOTAL_FORMS"])
            for i in range(material_count):
                property_count= len(request.POST[f'reagent_{index}-{i}-uuid'].split(','))
                for j in range(property_count):
                    prop_uuid = request.POST[f"reagent_{index}-{i}-uuid_{j}"]
                    rmvi = Property.objects.get(uuid=prop_uuid)
                    rmvi_form = ReagentValueForm(
                        request.POST,
                        prefix=f"reagent_{index}_{i}",
                        #instance=rmvi,
                    )
                    if rmvi_form.is_valid():
                        rmvi.actual_value = form.cleaned_data["actual_value"]
                        rmvi_form.save()
                    else:
                        valid_forms = False'''
            fset = self.ReagentFormSet(request.POST, prefix=f"reagent_total_{index}")
            formsets.append(fset)
            if fset.is_valid():
                for form in fset:
                    # rmvi = ReagentMaterialValue.objects.get(
                    #    uuid=form.cleaned_data["uuid"]
                    # )
                    property_count=int(request.POST[f'reagent_{index}_1-TOTAL_FORMS'])
                    for i in range(property_count):
                        prop = Property.objects.get(uuid=form.cleaned_data["uuid"])
                        prop.actual_value = form.cleaned_data["actual_value"]
                        prop.save()
            else:
                valid_forms = False

        if valid_forms:
            return HttpResponseRedirect(reverse("experiment_instance_list"))
        else:
            return render(request, self.template_name, context)
