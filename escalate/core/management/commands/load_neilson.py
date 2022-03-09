from django.core.management.base import BaseCommand, CommandError
from django.db.models import Q
from core.models import (
    Actor,
    Action,
    ActionDef,
    ActionUnit,
    BaseBomMaterial,
    BomMaterial,
    BillOfMaterials,
    DefaultValues,
    ExperimentTemplate,
    ExperimentType,
    ExperimentActionSequence,
    Inventory,
    InventoryMaterial,
    Material,
    MaterialType,
    MaterialIdentifier,
    MaterialIdentifierDef,
    Mixture,
    ParameterDef,
    PropertyTemplate,
    Property,
    Status,
    Systemtool,
    TypeDef,
    Vessel,
    ActionSequence,
    ActionSequenceType,
    ReagentTemplate,
    ReagentMaterialTemplate,
    ReagentMaterialValueTemplate,
    OutcomeTemplate,
    Parameter,
    DescriptorTemplate,
    MolecularDescriptor,
    VesselType,
)
from core.custom_types import Val
import csv
import os
import json
import math

import pandas as pd


class Command(BaseCommand):
    help = "Loads initial data from load tables after a datebase refresh"

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("Loading Nielson tables"))
        df = pd.read_csv("../data_model/dataload_csv/MetalChalcogenideRxns.csv").fillna(
            0
        )
        # self._load_inventory()
        self._load_materials_and_descriptors(df)

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
            material_instance, created = Material.objects.get_or_create(
                **fields)
            for col_name in col_names:
                val = row[col_name]
                print(val)
                dt = dts[col_name]
                md, created = MolecularDescriptor.objects.get_or_create(
                    material=material_instance,
                    template=dt,
                    value=Val.from_dict(
                        {"value": val, "unit": "", "type": "num"}),
                )

    def _load_inventory(self):
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
                "Nielson Lab",
                Actor.objects.get(description="Mike Tynes"),
                Actor.objects.get(description="Mike Tynes"),
                Actor.objects.get(description="TestCo"),
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
