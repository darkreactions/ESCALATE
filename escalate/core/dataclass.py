import json
import tempfile
from dataclasses import dataclass, field

# from dacite.core import from_dict
from itertools import product
from typing import Any, Dict, List, Optional, Tuple
from uuid import UUID

#from types import NoneType
from typing import List, Dict, Any, Optional, Tuple
from django.db.models import QuerySet
import pandas as pd
from django.db.models import QuerySet

from core.custom_types import Val
from core.models.view_tables import (
    Action,
    ActionDef,
    ActionTemplate,
    ActionUnit,
    BaseBomMaterial,
    BillOfMaterials,
    ExperimentInstance,
    ExperimentTemplate,
    InventoryMaterial,
    MaterialType,
    Outcome,
    Parameter,
    ParameterDef,
    Property,
    PropertyTemplate,
    Reagent,
    ReagentMaterial,
    ReagentMaterialTemplate,
    ReagentTemplate,
    Vessel,
    VesselInstance,
    VesselTemplate,
)
from core.utilities.utils import make_well_labels_list

# steps with names to display in UI
SELECT_TEMPLATE = "Select Experiment Template"
NUM_OF_EXPS = "Set Number of Experiments"
MANUAL_SPEC = "Specify Manual Experiments"
AUTOMATED_SPEC = "Specify Automated Experiments"
AUTOMATED_SPEC_VARS = "Specify Variables for Automated Sampler"
REAGENT_PARAMS = "Specify Reagent Parameters"
SELECT_VESSELS = "Select Vessels"
ACTION_PARAMS = "Specify Action Parameters"
POSTPROCESS = "Select Postprocessors"
AUTOMATED_SAMPLER_SPEC = "Specify Sampler parameters"

# Meta data label
METADATA = "metadata"


@dataclass
class VesselData:
    vessel: Vessel
    vessel_template: VesselTemplate


@dataclass
class ActionUnitData:
    dest_vessel: Optional[VesselData]
    nominal_value: Optional[Val]
    source_vessel: Optional[VesselData] = field(default=None)


@dataclass
class ActionData:
    parameters: Dict[ParameterDef, List[ActionUnitData]]


@dataclass
class ReagentMaterialPropertyData:
    inventory_material: InventoryMaterial
    material_type: MaterialType
    properties: Dict[PropertyTemplate, Val]


@dataclass
class ReagentPropertyData:
    properties: Dict[PropertyTemplate, Val]
    reagent_materials: Dict[
        ReagentMaterialTemplate, ReagentMaterialPropertyData
    ] = field(default_factory=dict)


def custom_pairing(source_vessels, dest_vessels):
    raise NotImplementedError


@dataclass
class ExperimentData:
    experiment_name: str
    experiment_template: ExperimentTemplate
    vessel_data: Dict[VesselTemplate, Vessel] = field(default_factory=dict, repr=False)
    action_parameters: Dict[ActionTemplate, ActionData] = field(
        default_factory=dict, repr=False
    )
    reagent_properties: Dict[ReagentTemplate, ReagentPropertyData] = field(
        default_factory=dict, repr=False
    )
    num_of_sampled_experiments: int = 0
    _experiment_instance: Optional[ExperimentInstance] = field(
        init=False, repr=False, default=None
    )
    _experiment_instance_uuid: "Optional[UUID|str]" = field(init=False, default=None)
    _current_operator: Any = field(init=False, default=None)

    @property
    def experiment_instance(self):
        if (
            not isinstance(self._experiment_instance, ExperimentInstance)
            and self._experiment_instance_uuid is None
        ):
            self._experiment_instance = self._create_experiment()
        elif self._experiment_instance_uuid and self._experiment_instance is None:
            self._experiment_instance = ExperimentInstance.objects.get(
                uuid=self._experiment_instance_uuid
            )
        return self._experiment_instance

    @property
    def current_operator(self):
        return self._current_operator

    @current_operator.setter
    def current_operator(self, operator):
        self._current_operator = operator

    def generate_manual_spec_file(self):
        outframe, meta_dataframe = self._generate_manual_spec_dataframes()
        temp = tempfile.TemporaryFile()
        with pd.ExcelWriter(temp, engine="openpyxl") as excel_writer:
            excel_writer: pd.ExcelWriter
            outframe.to_excel(
                excel_writer=excel_writer,
                sheet_name=self.experiment_template.description,
                index=False,
            )
            meta_dataframe.to_excel(
                excel_writer,
                sheet_name=METADATA,
                index=False,
            )
            # Protect meta_data sheet from edits
            ws = excel_writer.sheets[METADATA]
            ws.protection.sheet = True

            # Freeze first row of outframe
            ws = excel_writer.sheets[self.experiment_template.description]
            ws.freeze_panes = "A2"

        # excel_writer.save()
        temp.seek(0)
        return temp

    def parse_manual_file(self, df_dict: Dict[str, pd.DataFrame]):
        outframe = df_dict[self.experiment_template.description]
        table_data = outframe.to_dict()
        meta_dataframe = df_dict[METADATA]
        metadata_raw = meta_dataframe.to_dict()
        metadata = {}
        for index, key in metadata_raw["keys"].items():
            value = metadata_raw["values"][index]
            metadata[key] = value

        for key in table_data:
            if "action" in key:
                _, pdef_uuid, at_uuid = json.loads(metadata[key])
                action_template: ActionTemplate = ActionTemplate.objects.get(
                    uuid=at_uuid
                )
                param_def: ParameterDef = ParameterDef.objects.get(uuid=pdef_uuid)
                action_data = self.action_parameters[action_template]
                au_data_list: List[ActionUnitData] = []
                for index, vessel_string in table_data[key].items():
                    _, plate, well = json.loads(vessel_string)
                    vessel = Vessel.objects.get(uuid=metadata[vessel_string])
                    vd = VesselData(
                        vessel=vessel,
                        vessel_template=action_template.dest_vessel_template,
                    )
                    value = table_data[
                        json.dumps(
                            [
                                "value",
                                param_def.description,
                                action_template.description,
                            ]
                        )
                    ][index]
                    unit = table_data[
                        json.dumps(
                            ["unit", param_def.description, action_template.description]
                        )
                    ][index]
                    val_type = table_data[
                        json.dumps(
                            ["type", param_def.description, action_template.description]
                        )
                    ][index]
                    val = Val.from_dict(
                        {"value": value, "unit": unit, "type": val_type}
                    )
                    au = ActionUnitData(dest_vessel=vd, nominal_value=val)
                    au_data_list.append(au)
                action_data.parameters[param_def] = au_data_list

    def _generate_blank_action_template(self, action_template):
        action_data_dict: Dict[ParameterDef, List[ActionUnitData]] = {}
        pdef: ParameterDef
        for pdef in action_template.action_def.parameter_def.all():
            aus = []
            for child in self.vessel_data[
                action_template.dest_vessel_template
            ].children.all():
                child_vd = VesselData(
                    vessel=child,
                    vessel_template=action_template.dest_vessel_template,
                )
                aus.append(
                    ActionUnitData(dest_vessel=child_vd, nominal_value=pdef.default_val)
                )
            action_data_dict[pdef] = aus
        self.action_parameters[action_template] = ActionData(action_data_dict)

    def _generate_manual_spec_dataframes(self):
        exp_template = self.experiment_template
        # Get the form data entered in the wizard
        table_data = {}
        meta_data = {}
        # Loop through every action template
        for action_template in exp_template.action_template_et.filter(
            dest_vessel_decomposable=True
        ):
            action_def: ActionDef = action_template.action_def
            # If actions have been generated by a sampler in the prev step
            # Otherwise generate blank data
            if action_template not in self.action_parameters:
                self._generate_blank_action_template(action_template)

            action_data = self.action_parameters[action_template]

            parameter_defs: QuerySet[ParameterDef] = action_def.parameter_def.all()
            dest_vessel = self.vessel_data[action_template.dest_vessel_template]
            # For every parameter def in the action def,
            # Save uuids to meta data dictionary
            # Add default data to table dictionary
            for pdef in parameter_defs:
                description_str = json.dumps(
                    ["action", pdef.description, action_template.description]
                )
                value_str = json.dumps(
                    ["value", pdef.description, action_template.description]
                )
                unit_str = json.dumps(
                    ["unit", pdef.description, action_template.description]
                )
                type_str = json.dumps(
                    ["type", pdef.description, action_template.description]
                )

                meta_data[description_str] = json.dumps(
                    [
                        "action",
                        str(pdef.uuid),
                        str(action_template.uuid),
                    ]
                )
                meta_data[value_str] = json.dumps(
                    ["value", str(pdef.uuid), str(action_template.uuid)]
                )
                meta_data[unit_str] = json.dumps(
                    ["unit", str(pdef.uuid), str(action_template.uuid)]
                )
                meta_data[type_str] = json.dumps(
                    ["type", str(pdef.uuid), str(action_template.uuid)]
                )

                table_data[description_str] = []
                table_data[value_str] = []
                table_data[unit_str] = []
                table_data[type_str] = []

                if dest_vessel.children.count() == 0:
                    # If the destination vessel has no children, just add 1 row
                    dest_description_str = json.dumps(
                        ["vessel", dest_vessel.description]
                    )
                    table_data[description_str].append(dest_description_str)
                    table_data[value_str].append(f"{pdef.default_val.value}")
                    table_data[unit_str].append(f"{pdef.default_val.unit}")
                    table_data[type_str].append(
                        f"{pdef.default_val.val_type.description}"
                    )
                    meta_data[dest_description_str] = dest_vessel.uuid

                else:
                    # Add as many rows there are as children
                    child_list = []

                    #if well order is specified in metadata, use that order
                    if 'well_order' in dest_vessel.metadata.keys():
                        well_order = dest_vessel.metadata['well_order']
                        for well in well_order:
                            child = (
                                dest_vessel.children.all().filter(description=well).first()
                            )
                            child_list.append(child)
                    #otherwise, try using a function to generate a standard well order
                    else:
                        try:
                            well_order = make_well_labels_list(
                                len(dest_vessel.children.all()), robot="True"
                            )
                            for well in well_order:
                                child = (
                                    dest_vessel.children.all().filter(description=well).first()
                                )
                                child_list.append(child)
                        #for non-standard vessels, simply list wells in arbitrary order
                        except AttributeError:

                            for i in range(len(dest_vessel.children.all())):
                                child=dest_vessel.children.all()[i]
                                child_list.append(child)

                    for i, child in enumerate(child_list):
                        automated_sampled_data = action_data.parameters[pdef]
                        # Set default values first, if there are no sampled experiments, continue
                        nominal_value = pdef.default_val.value
                        nominal_unit = pdef.default_val.unit
                        nominal_type = pdef.default_val.val_type.description
                        if i < len(automated_sampled_data):
                            value = automated_sampled_data[i].nominal_value
                            if isinstance(value, Val):
                                nominal_value = value.value
                                nominal_unit = value.unit
                                nominal_type = value.val_type.description

                        dest_description_str = json.dumps(
                            ["vessel", dest_vessel.description, child.description]
                        )
                        table_data[description_str].append(dest_description_str)
                        table_data[value_str].append(f"{nominal_value}")
                        table_data[unit_str].append(f"{nominal_unit}")
                        table_data[type_str].append(f"{nominal_type}")
                        meta_data[dest_description_str] = child.uuid

        outframe = pd.DataFrame(data=table_data)
        m_data = {"keys": list(meta_data.keys()), "values": list(meta_data.values())}
        meta_dataframe = pd.DataFrame(data=m_data)

        return outframe, meta_dataframe

    def _get_vessel_list(self, at: ActionTemplate, dest=True) -> List[Vessel]:
        vessel_list = []
        if dest:
            vt = at.dest_vessel_template
            decomposable = at.dest_vessel_decomposable
        else:
            vt = at.source_vessel_template
            decomposable = at.source_vessel_decomposable

        if vt:
            vt: VesselTemplate
            base_vessel = self.vessel_data[vt]
            if decomposable:
                vessel_list = list(base_vessel.children.all())
            else:
                vessel_list = [base_vessel]
        return vessel_list

    def _pair_vessels(self, source_vessels, dest_vessels):
        if not source_vessels:
            vessel_pairs = product([None], dest_vessels)
        elif len(source_vessels) == 1:
            vessel_pairs = product(source_vessels, dest_vessels)
        elif len(source_vessels) == len(dest_vessels):
            vessel_pairs = zip(source_vessels, dest_vessels)
        else:
            vessel_pairs = custom_pairing(source_vessels, dest_vessels)
        return vessel_pairs

    def _create_bbm(
        self,
        vessel_data: "VesselData|None",
        bom_vessels: Dict[str, BaseBomMaterial],
        bom: BillOfMaterials,
    ) -> Tuple[Optional[BaseBomMaterial], Dict[str, BaseBomMaterial]]:
        """Create a base Bom Material (usually vessel) based on vessel provided

        Args:
            vessel (Vessel|None): Vessel to be saved
            bom_vessels (Dict[str, BaseBomMaterial]): Dict of bom materials
            bom (BillOfMaterials): Bill of materials

        Returns:
            _type_: _description_
        """
        bbm = None
        if vessel_data is not None:
            if vessel_data.vessel.description not in bom_vessels:
                vessel_instance, created = VesselInstance.objects.get_or_create(
                    vessel_template=vessel_data.vessel_template,
                    vessel=vessel_data.vessel,
                    experiment_instance=bom.experiment_instance,
                )
                bom_vessels[
                    vessel_data.vessel.description
                ] = BaseBomMaterial.objects.create(
                    bom=bom,
                    vessel=vessel_instance,
                    description=vessel_data.vessel.description,
                )
            bbm = bom_vessels[vessel_data.vessel.description]
        return bbm, bom_vessels

    def _save_properties(
        self,
        data: "ReagentPropertyData|ReagentMaterialPropertyData",
        model: "Reagent|ReagentMaterial",
    ):
        """Saves property stored in a dataclass into the correspondong django model

        Args:
            data (ReagentPropertyData|ReagentMaterialPropertyData): Dataclass to be saved
            model (Reagent|ReagentMaterial): Django model to be saved into
        """
        if isinstance(model, Reagent):
            related_prop = "property_r"
        else:
            related_prop = "property_rm"
        for prop_template, val in data.properties.items():
            prop_set = getattr(model, related_prop)
            prop = prop_set.get(template=prop_template)
            prop.nominal_value = val
            prop.save()

    def _create_experiment(self) -> ExperimentInstance:
        # Get parent Experiment from template_experiment_uuid
        # experiment row creation, overwrites original experiment template object with new experiment object.
        # Makes an experiment template object parent
        exp_instance = ExperimentInstance.objects.create(
            ref_uid=self.experiment_template.ref_uid,
            template=self.experiment_template,
            owner=self.experiment_template.owner,
            # operator=self.experiment_template.operator,
            operator=self.current_operator,
            lab=self.experiment_template.lab,
            description=self.experiment_name
            if self.experiment_name
            else f"Copy of {self.experiment_template.description}",
        )
        self._experiment_instance_uuid = exp_instance.uuid

        bom = BillOfMaterials.objects.create(experiment_instance=exp_instance)

        # Get all action sequences related to this experiment template
        # for asq in exp_template.action_sequence.all():
        # for at in self.experiment_template.action_template_et.all():
        for at, action_data in self.action_parameters.items():
            action = Action.objects.create(
                description=at.action_def.description,
                # parent=
                experiment=exp_instance,
                template=at,
            )

            # Create a list of all source vessels
            # source_vessels = self._get_vessel_list(at, dest=False)

            # Create a list of all destination vessels
            # dest_vessels = self._get_vessel_list(at)

            # Pair source and dest vessels
            # vessel_pairs = self._pair_vessels(source_vessels, dest_vessels)
            # sv: "None|Vessel"
            # dv: "None|Vessel"
            # for sv, dv in vessel_pairs:
            bom_vessels = {}
            # aunits: Dict[ActionUnit] = {}
            parameters = []

            for p_def, au_data in action_data.parameters.items():
                # if isinstance(au_data, list):
                for a in au_data:
                    dest_bbm, bom_vessels = self._create_bbm(
                        a.dest_vessel, bom_vessels, bom
                    )
                    source_bbm, bom_vessels = self._create_bbm(
                        a.source_vessel, bom_vessels, bom
                    )
                    au, created = ActionUnit.objects.get_or_create(
                        description=f"{action.description} : {source_bbm} -> {dest_bbm}",
                        action=action,
                        destination_material=dest_bbm,
                        source_material=source_bbm,
                    )
                    au: ActionUnit
                    if a.nominal_value:
                        nominal_value = a.nominal_value
                    else:
                        nominal_value = p_def.default_val
                    p = au.parameter_au.get(parameter_def=p_def)
                    p.parameter_val_nominal = nominal_value
                    parameters.append(p)
                # aunits.append(au)
            # ActionUnit.objects.bulk_create(aunits)
            Parameter.objects.bulk_update(parameters, ["parameter_val_nominal"])

        # Iterate over all reagent-templates and create reagentintances and properties

        for reagent_template, reagent_data in self.reagent_properties.items():
            reagent: Reagent = Reagent.objects.create(
                experiment=exp_instance, template=reagent_template
            )
            self._save_properties(reagent_data, reagent)

            reagent_material_data: ReagentMaterialPropertyData
            for (
                reagent_material_template,
                reagent_material_data,
            ) in reagent_data.reagent_materials.items():
                reagent_material: ReagentMaterial = ReagentMaterial.objects.create(
                    template=reagent_material_template,
                    material=reagent_material_data.inventory_material,
                    reagent=reagent,
                    description=f"{exp_instance.description} : {reagent_template.description} : {reagent_material_template.description}",
                )
                self._save_properties(reagent_material_data, reagent_material)

        for outcome_template in self.experiment_template.outcome_templates.all():
            for vt in self.experiment_template.vessel_templates.all():
                if vt.outcome_vessel:
                    selected_vessel = self.vessel_data[vt]
                    for child in selected_vessel.children.all():
                        outcome_instance = Outcome(
                            outcome_template=outcome_template,
                            experiment_instance=exp_instance,
                            description=child.description,
                        )
                        outcome_instance.save()

        return exp_instance

    @classmethod
    def parse_form_data(cls, form_data: Dict[str, Any]):
        """Creates an Experiment dataclass instance based on the form data
        collected up to the automated experiment creation

        Args:
            form_data (Dict[str, Any]): _description_

        Returns:
            _type_: _description_
        """
        experiment_name = form_data[SELECT_TEMPLATE].get("experiment_name", "")
        num_automated = form_data[AUTOMATED_SPEC].get("automated", 0)

        experiment_template = ExperimentTemplate.objects.get(
            uuid=form_data[SELECT_TEMPLATE]["select_experiment_template"]
        )

        # Setup vessel templates
        vessel_data: Dict[VesselTemplate, Vessel] = {}
        vessel_key = (
            SELECT_VESSELS
            if SELECT_VESSELS in form_data
            else f"formset-{SELECT_VESSELS}"
        )
        for vt_data in form_data.get(vessel_key, {}):
            vt: VesselTemplate = VesselTemplate.objects.get(
                uuid=vt_data["template_uuid"]
            )
            vessel: Vessel = vt_data["value"]
            vessel_data[vt] = vessel

        # Setup action parameters for non-decomposable
        action_parameters: Dict[ActionTemplate, ActionData] = {}
        action_params_key = (
            ACTION_PARAMS if ACTION_PARAMS in form_data else f"formset-{ACTION_PARAMS}"
        )
        for action_params in form_data.get(action_params_key, {}):
            a_data: ActionData
            at = None
            parameters = {}
            for k, v in action_params.items():
                if k == "action_template_uuid":
                    at = ActionTemplate.objects.get(uuid=v)
                if at is None:
                    continue
                if k.startswith("parameter_uuid"):
                    suffix = k.split("parameter_uuid")[-1]
                    parameter_def: ParameterDef = ParameterDef.objects.get(uuid=v)
                    source_vd = (
                        VesselData(
                            vessel=vessel_data[at.source_vessel_template],
                            vessel_template=at.source_vessel_template,
                        )
                        if at.source_vessel_template
                        else None
                    )
                    dest_vd = (
                        VesselData(
                            vessel=vessel_data[at.dest_vessel_template],
                            vessel_template=at.dest_vessel_template,
                        )
                        if at.dest_vessel_template
                        else None
                    )
                    aud = ActionUnitData(
                        source_vessel=source_vd,
                        dest_vessel=dest_vd,
                        nominal_value=action_params[f"value{suffix}"],
                    )
                    parameters[parameter_def] = [aud]
            a_data = ActionData(parameters=parameters)
            action_parameters[at] = a_data

        # Setup reagent parameters
        reagent_properties_dict: Dict[ReagentTemplate, ReagentPropertyData] = {}
        reagent_params_keys = (
            REAGENT_PARAMS
            if REAGENT_PARAMS in form_data
            else f"formset-{REAGENT_PARAMS}"
        )
        for reagent_params in form_data.get(reagent_params_keys, {}):
            reagent_template_uuid = reagent_params["reagent_template_uuid"]
            reagent_template = ReagentTemplate.objects.get(uuid=reagent_template_uuid)
            reagent_properties = {}

            for i in range(reagent_template.properties.count()):
                rprop = PropertyTemplate.objects.get(
                    uuid=reagent_params[f"reagent_prop_uuid_{i}"]
                )
                reagent_properties[rprop] = reagent_params[f"reagent_prop_{i}"]

            rmt_prop_data: Dict[
                ReagentMaterialTemplate, ReagentMaterialPropertyData
            ] = {}
            for k, v in reagent_params.items():
                rmt_uuid_key = "reagent_material_template_uuid"
                if k.startswith(rmt_uuid_key):
                    rmt: ReagentMaterialTemplate = ReagentMaterialTemplate.objects.get(
                        uuid=v
                    )
                    rmt_index = k.split(rmt_uuid_key)[-1]
                    material_uuid = reagent_params[f"material{rmt_index}"]
                    im = InventoryMaterial.objects.get(uuid=material_uuid)
                    material_type_uuid = reagent_params[f"material_type{rmt_index}"]
                    material_type = MaterialType.objects.get(uuid=material_type_uuid)

                    rmt_properties: Dict[PropertyTemplate, Val] = {}
                    for i in range(rmt.properties.count()):
                        mat_prop_val = reagent_params[
                            f"reagent_material_prop{rmt_index}_{i}"
                        ]
                        mat_prop_template_uuid = reagent_params[
                            f"reagent_material_prop_uuid{rmt_index}_{i}"
                        ]
                        mat_prop_template = PropertyTemplate.objects.get(
                            uuid=mat_prop_template_uuid
                        )
                        rmt_properties[mat_prop_template] = mat_prop_val
                    rmt_data = ReagentMaterialPropertyData(
                        inventory_material=im,
                        properties=rmt_properties,
                        material_type=material_type,
                    )
                    rmt_prop_data[rmt] = rmt_data

            rp_data = ReagentPropertyData(
                properties=reagent_properties,
                reagent_materials=rmt_prop_data,
            )
            reagent_properties_dict[reagent_template] = rp_data

        return cls(
            experiment_name=experiment_name,
            experiment_template=experiment_template,
            vessel_data=vessel_data,
            action_parameters=action_parameters,
            reagent_properties=reagent_properties_dict,
            num_of_sampled_experiments=num_automated,
        )
