import csv
import json
import math
import os
from typing import Any, Dict, List

import pandas as pd
from core.custom_types import Val
from core.models import (  # ExperimentType,; ReagentMaterialValueTemplate,
    Action,
    ActionDef,
    ActionTemplate,
    ActionUnit,
    Actor,
    BaseBomMaterial,
    BillOfMaterials,
    BomMaterial,
    DefaultValues,
    DescriptorTemplate,
    ExperimentTemplate,
    Inventory,
    InventoryMaterial,
    Material,
    MaterialIdentifier,
    MaterialIdentifierDef,
    MaterialType,
    MolecularDescriptor,
    Organization,
    OutcomeTemplate,
    Parameter,
    ParameterDef,
    Property,
    PropertyTemplate,
    ReagentMaterialTemplate,
    ReagentTemplate,
    Status,
    Systemtool,
    Type,
    TypeDef,
    Vessel,
    VesselTemplate,
    VesselType,
)
from django.core.management.base import BaseCommand, CommandError
from django.db.models import Q


class Command(BaseCommand):
    help = "Loads initial data from load tables after a datebase refresh"

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("Loading Nielson tables"))
        df = pd.read_csv("../data_model/dataload_csv/Chemicals List.csv").fillna(0)
        # self._load_inventory()
        # self._load_materials_and_descriptors(df)
        self._load_inventory(df)
        self._load_experiment()

    def _load_materials_and_descriptors(self, df):
        col_names = "BDE of adduct,Metal density,chalc density,avg density,product density,metal electroneg,chalc electroneg,electroneg diff,m.p of metal,m.p. of chalc,metal atomic #,chalc atomic #,ionization energy of metal,ionization energy of chalc,electron affinity of metal,electron affinity of chalcogen,minimum change in chemical potential,maximum change in chemical potential".split(
            ","
        )
        dts = {}
        for col_name in col_names:
            dt, created = DescriptorTemplate.objects.get_or_create(
                description=col_name, human_description=col_name
            )
            dts[col_name] = dt

        for i, row in df.iterrows():
            fields = {
                "description": row["Product expected"],
            }
            material_instance, created = Material.objects.get_or_create(**fields)
            for col_name in col_names:
                val = row[col_name]
                # print(val)
                dt = dts[col_name]
                md, created = MolecularDescriptor.objects.get_or_create(
                    material=material_instance,
                    template=dt,
                    value=Val.from_dict({"value": val, "unit": "", "type": "num"}),
                )

    def _load_inventory(self, df):
        neilson_org, created = Organization.objects.get_or_create(
            full_name="Neilson Lab", description="Neilson Lab"
        )
        self.neilson_lab_actor, created = Actor.objects.get_or_create(
            description="Neilson Lab", organization=neilson_org
        )
        inventory_relevant_fields = [
            "description",
            "owner",
            "operator",
            "lab",
            "status",
        ]
        active_status = Status.objects.get(description="active")
        inventory_data = [
            [
                "Neilson Lab",
                Actor.objects.get(description="Mike Tynes"),
                Actor.objects.get(description="Mike Tynes"),
                self.neilson_lab_actor,
                active_status,
            ],
        ]
        inventory_to_add = [
            dict(zip(inventory_relevant_fields, data)) for data in inventory_data
        ]
        for fields_bunch in inventory_to_add:
            inventory_instance, created = Inventory.objects.get_or_create(
                **fields_bunch
            )

        """BarCode,Chemical Name,Inventory Name,CAS Num,Phase,Purity,Vendor,Material type,molar mass"""
        for i, row in df.iterrows():
            mat, created = Material.objects.get_or_create(
                description=row["Chemical Name"]
            )
            mat_type_string = row["Material type"]
            for mat_type in mat_type_string.strip('"').split(","):
                material_type, created = MaterialType.objects.get_or_create(
                    description=mat_type.strip().lower()
                )
                mat.material_type.add(material_type)
            mat.save()
            property_template, created = PropertyTemplate.objects.get_or_create(
                description="MolecularWeight"
            )
            print(row["molar mass"])
            mol_wt_val = Val.from_dict(
                {"type": "num", "value": row["molar mass"], "unit": "g/mol"}
            )
            prop, created = Property.objects.get_or_create(
                template=property_template, value=mol_wt_val, material=mat
            )
            InventoryMaterial.objects.get_or_create(
                description=mat.description, inventory=inventory_instance, material=mat
            )

    def _load_experiment(self):
        neilson_org, created = Organization.objects.get_or_create(
            description="Neilson Lab"
        )
        lab = self.neilson_lab_actor

        reagent_templates = {
            "Reagent 1 - Nitride Precursors": {"chemical_types": ["nitride"]},
            "Reagent 2 - Oxide Precursors": {"chemical_types": ["oxide"]},
            "Reagent 3 - Fluxes": {"chemical_types": ["flux"]},
        }
        reagent_template_responses = {}

        for reagent_template_name, template_data in reagent_templates.items():
            reagent_template_data = {"description": reagent_template_name}

            rt, created = ReagentTemplate.objects.get_or_create(**reagent_template_data)
            reagent_template_responses[reagent_template_name] = rt
            rmt_responses = []

            # if "chemical_types" in template_data:
            #    chem_types = template_data["chemical_types"]
            if chem_types := template_data.get("chemical_types", []):
                for chem_type in chem_types:
                    chemical_type_data = {"description": chem_type}
                    chemical_type, created = MaterialType.objects.get_or_create(
                        **chemical_type_data
                    )
                    reagent_template_material_data = {
                        "description": f"{reagent_template_name}: {chem_type}",
                        "reagent_template": rt,
                        "material_type": chemical_type,
                    }
                    (
                        rmt_response,
                        created,
                    ) = ReagentMaterialTemplate.objects.get_or_create(
                        **reagent_template_material_data,
                    )
                    rmt_responses.append(rmt_response)

        # Default values
        zero_g_value = {"value": 0, "unit": "g", "type": "num"}
        zero_g_data = {
            "description": "Zero g",
            "nominal_value": zero_g_value,
            "actual_value": zero_g_value,
        }

        zero_g_response, created = DefaultValues.objects.get_or_create(**zero_g_data)

        nitride = reagent_template_responses["Reagent 1 - Nitride Precursors"]
        oxide = reagent_template_responses["Reagent 2 - Oxide Precursors"]
        flux = reagent_template_responses["Reagent 3 - Fluxes"]

        data = {"description": "amount", "default_value": zero_g_response}
        prop_amount, created = PropertyTemplate.objects.get_or_create(**data)
        nitride.properties.add(prop_amount)
        nitride.save()

        oxide.properties.add(prop_amount)
        oxide.save()

        flux.properties.add(prop_amount)
        flux.save()

        action_parameter_def = {
            "dispense": [("volume", {"type": "num", "unit": "uL", "value": 0.0})],
            "bring_to_temperature": [
                ("temperature", {"type": "num", "unit": "degC", "value": 0.0})
            ],
            "dwell": [("duration", {"type": "num", "unit": "seconds", "value": 0.0})],
            "cool_to_temperature": [
                ("temperature", {"type": "num", "unit": "degC", "value": 0.0})
            ],
        }

        action_def_response: Dict[str, Any] = {}
        action_parameter_response: Dict[str, Any] = {}

        for action_def, parameter_def_list in action_parameter_def.items():
            ap_data_list: List[Dict[str, Any]] = []
            for (parameter_def, default_value) in parameter_def_list:
                ap_data = {"description": parameter_def, "default_val": default_value}
                (
                    action_parameter_response[parameter_def],
                    created,
                ) = ParameterDef.objects.get_or_create(**ap_data)
                ap_data_list.append(action_parameter_response[parameter_def])

            ad_response, created = ActionDef.objects.get_or_create(
                **{"description": action_def}
            )
            for ap in ap_data_list:
                ad_response.parameter_def.add(ap)
            ad_response.save()
            action_def_response[action_def] = ad_response

        vessel_templates = {}
        for vessel_template_description, outcome_vessel in [
            ("Nitride Vessel", False),
            ("Oxide Vessel", False),
            ("Flux Vessel", False),
            ("Neilson Outcome vessel", True),
        ]:
            (
                vessel_templates[vessel_template_description],
                created,
            ) = VesselTemplate.objects.get_or_create(
                **{
                    "description": vessel_template_description,
                    "outcome_vessel": outcome_vessel,
                }
            )

        outcome, created = OutcomeTemplate.objects.get_or_create(
            description="Neilson Experiment Outcome"
        )

        experiment_template, created = ExperimentTemplate.objects.get_or_create(
            description="Neilson Experiment",
            lab=lab,
            # vessel_templates=list(vessel_templates.values()),
            # reagent_templates=list(reagent_template_responses.values()),
            # outcome_templates=[outcome]
        )

        for vt in vessel_templates.values():
            experiment_template.vessel_templates.add(vt)

        for rt in reagent_template_responses.values():
            experiment_template.reagent_templates.add(rt)

        experiment_template.outcome_templates.add(outcome)

        experiment_template.save()

        # Create action templates
        dispense_nitrides_data = {
            "description": "Dispense Nitrides",
            "source_vessel_decomposable": False,
            "dest_vessel_decomposable": False,
            "experiment_template": experiment_template,
            "action_def": action_def_response["dispense"],
            "source_vessel_template": vessel_templates["Nitride Vessel"],
            "dest_vessel_template": vessel_templates["Neilson Outcome vessel"],
        }
        dispense_nitrides_at, created = ActionTemplate.objects.get_or_create(
            **dispense_nitrides_data
        )

        dispense_oxides_data = {
            "description": "Dispense Oxides",
            "source_vessel_decomposable": False,
            "dest_vessel_decomposable": False,
            "experiment_template": experiment_template,
            "action_def": action_def_response["dispense"],
            "source_vessel_template": vessel_templates["Oxide Vessel"],
            "dest_vessel_template": vessel_templates["Neilson Outcome vessel"],
        }
        dispense_oxides_at, created = ActionTemplate.objects.get_or_create(
            **dispense_oxides_data
        )
        dispense_oxides_at.parent.add(dispense_nitrides_at)
        dispense_oxides_at.save()

        dispense_flux_data = {
            "description": "Dispense Flux",
            "source_vessel_decomposable": False,
            "dest_vessel_decomposable": False,
            "experiment_template": experiment_template,
            "action_def": action_def_response["dispense"],
            "source_vessel_template": vessel_templates["Flux Vessel"],
            "dest_vessel_template": vessel_templates["Neilson Outcome vessel"],
        }
        dispense_flux_at, created = ActionTemplate.objects.get_or_create(
            **dispense_flux_data
        )
        dispense_flux_at.parent.add(dispense_oxides_at)
        dispense_flux_at.save()

        heat_to_t_data = {
            "description": "Heat to T",
            "source_vessel_decomposable": False,
            "dest_vessel_decomposable": False,
            "experiment_template": experiment_template,
            "action_def": action_def_response["bring_to_temperature"],
            "source_vessel_template": None,
            "dest_vessel_template": vessel_templates["Neilson Outcome vessel"],
        }
        heat_to_t_at, created = ActionTemplate.objects.get_or_create(**heat_to_t_data)
        heat_to_t_at.parent.add(dispense_flux_at)
        heat_to_t_at.save()

        dwell_at_t_data = {
            "description": "Dwell at T",
            "source_vessel_decomposable": False,
            "dest_vessel_decomposable": False,
            "experiment_template": experiment_template,
            "action_def": action_def_response["dwell"],
            "source_vessel_template": None,
            "dest_vessel_template": vessel_templates["Neilson Outcome vessel"],
            # "parent": [heat_to_t_data["url"]],
        }
        dwell_at_t_at, created = ActionTemplate.objects.get_or_create(**dwell_at_t_data)
        dwell_at_t_at.parent.add(heat_to_t_at)
        dwell_at_t_at.save()

        cool_to_t_data = {
            "description": "Cool to T",
            "source_vessel_decomposable": False,
            "dest_vessel_decomposable": False,
            "experiment_template": experiment_template,
            "action_def": action_def_response["cool_to_temperature"],
            "source_vessel_template": None,
            "dest_vessel_template": vessel_templates["Neilson Outcome vessel"],
            # "parent": [dwell_at_t_data["url"]],
        }
        cool_to_t_at, created = ActionTemplate.objects.get_or_create(**cool_to_t_data)
        cool_to_t_at.parent.add(dwell_at_t_at)
        cool_to_t_at.save()
