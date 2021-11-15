# %%
import pandas as pd
from django.core.management.base import BaseCommand
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
    ExperimentWorkflow,
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
    Workflow,
    WorkflowType,
)

data = pd.read_csv(
    "../data_model/dataload_csv/load_chem_inventory.txt", sep="\t"
).fillna("")
# %%
class Command(BaseCommand):
    help = "Loads initial data from load tables after a datebase refresh"

    def handle(self, *args, **options):
        self.stdout.write(self.style.NOTICE("Loading load tables"))
        self._load_chem_inventory()

    def _load_chem_inventory(self):
        active_status = Status.objects.get_or_create(description="active")

        total = 0
        col_to_mat_iden = {
            "ChemicalName": MaterialIdentifierDef.objects.get_or_create(
                description="Chemical Name"
            )[0],
            "ChemicalAbbreviation": MaterialIdentifierDef.objects.get_or_create(
                description="Abbreviation"
            )[0],
            "InChI": MaterialIdentifierDef.objects.get_or_create(description="InChI")[
                0
            ],
            "InChIKey": MaterialIdentifierDef.objects.get_or_create(
                description="InChIKey"
            )[0],
            "CanonicalSMILES": MaterialIdentifierDef.objects.get_or_create(
                description="SMILES"
            )[0],
            "MolecularFormula": MaterialIdentifierDef.objects.get_or_create(
                description="Molecular Formula"
            )[0],
        }

        for i, row in data.iterrows():
            chemical = row["ChemicalName"]
            if chemical:
                material, created = Material.objects.get_or_create(description=chemical)
                material_types = [
                    MaterialType.objects.get_or_create(description=mtype.strip())[0]
                    for mtype in row["ChemicalCategory"].split(",")
                    if mtype
                ]
                material.material_type.add(*material_types)
                for col, mat_iden in col_to_mat_iden.items():
                    (
                        new_material_identifier,
                        created,
                    ) = MaterialIdentifier.objects.get_or_create(
                        description=row[col],
                        material_identifier_def=mat_iden,
                        status=active_status[0],
                    )
                    if created:
                        material.identifier.add(new_material_identifier)

                total += 1 if created else 0
        self.stdout.write(self.style.SUCCESS(f"Added {total} new Materials"))


# %%
