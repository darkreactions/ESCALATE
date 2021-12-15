from chemdescriptor.generator.rdkit import RDKitDescriptorGenerator as RDG
from .commands import get_command_dict
from typing import Any


def get_rdkit_descriptors(input_molecules: "list[str]"):

    rdkit_command_dict = get_command_dict("acid", "RDKit")
    try:
        rdkit_features = RDG(
            input_molecules,
            whitelist=rdkit_command_dict,
            command_dict=rdkit_command_dict["descriptors"],
            logfile="log.txt",
        )
        type_features_df = rdkit_features.generate("./text.csv", dataframe=True)
    except Exception as e:
        print(f"RDKIT error: {e}")
