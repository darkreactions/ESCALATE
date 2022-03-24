from django.core.management.base import BaseCommand
from chemdescriptor.generator.rdkit import RDKitDescriptorGenerator as rdg

from escalate.core.models.view_tables.chemistry_data import Material
import pandas as pd

from escalate.core.models.view_tables.descriptors import DescriptorTemplate
from escalate.rest_api.tests.model_tests.chemistry_data import material_type


def get_command_dict(one_type, application):

    csv_file = "../../../../data_model/dataload_csv/type_command.csv"
    command_type_df = pd.read_csv(csv_file)
    if one_type == "any":
        commands_df = command_type_df[
            (command_type_df["actor_systemtool_name"] == application)
        ]
    else:
        commands_df = command_type_df[
            (command_type_df["input"] == one_type)
            & (command_type_df["actor_systemtool_name"] == application)
        ]
    my_descriptor_dict = {}
    for command in commands_df.itertuples():
        column_name = f"_feat_{command.short_name}"
        my_descriptor_dict[command.short_name] = {}

        # 'space' (i.e, ' ') removal
        templist = command.calc_definition.split(" ")
        str_list = list(filter(None, templist))
        my_descriptor_dict[command.short_name]["command"] = str_list
        my_descriptor_dict[command.short_name]["column_names"] = [column_name]
        my_descriptor_dict[command.short_name][
            "alternative_input"
        ] = command.alternative_input

    command_dict = {}
    command_dict["descriptors"] = my_descriptor_dict
    command_dict[
        "ph_descriptors"
    ] = {}  # possibly useful, see chemdescriptor for more details
    if len(command_dict["descriptors"].keys()) == 0:
        return None
    else:
        return command_dict


class Command(BaseCommand):
    help = "Generates RDKit descriptors based on the materials in the database"

    def handle(self, *args, **options):
        try:
            import rdkit

            self._generate_rdkit()
        except:
            self.stdout.write(self.style.NOTICE("rdkit not found"))

    def _generate_rdkit(self):
        materials = Material.objects.filter(
            identifier__material_identifier__description="SMILES"
        ).select_related("material_type")
        descriptor_templates = DescriptorTemplate.objects.all()

        for mat_type in ["organic", "solvent", "inorganic", "all"]:
            mat_of_specific_types = materials.filter(
                material_type__description=mat_type
            )
            smiles_list = []
            for mat in mat_of_specific_types:
                smiles_identifier = mat.identifier.get(
                    material_identifier__description="SMILES"
                )
                smiles_list.append(smiles_identifier.description)

            rdkit_command_dict = get_command_dict(mat_type, "RDKit")
            rdkit_features = rdg(
                smiles_list,
                whitelist=rdkit_command_dict,
                command_dict=rdkit_command_dict["descriptors"],
                logfile=f"RDKIT_LOG.txt",
            )
            df = rdkit_features.generate("test.csv", dataframe=True)
            for i, row in df.itterrows():
                mat_of_specific_types.get(description=row["Compound"])
