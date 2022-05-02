## List of view tables exposed in Django
Actor
Inventory
InventoryMaterial
Systemtool
SystemtoolType
Calculation
CalculationDef
Material
CompositeMaterial
BillOfMaterials
BomMaterial
BomCompositeMaterial
MaterialCalculationJson
MaterialRefnameDef
MaterialType
Note
Note_x
Organization
Person
Status
Tag
TagAssign
TagType
Edocument
Experiment
ExperimentWorkflow
Outcome
UdfDef
Property
PropertyDef
MaterialProperty
CompositeMaterialProperty
ParameterDef
ActionDef
Condition
ConditionDef
ActionParameterDef
ActionParameterDefAssign
ActionParameterAssign
Action
ActionParameter
Parameter
WorkflowType
Workflow
WorkflowStep
WorkflowObject

# -- Sorted alphabetically
| Table | Postgres View | Notes |
|-------|---------------|-------|
|Action|vw_action||
|ActionDef|vw_action_def||
|ActionParameter|vw_action_parameter||
|ActionParameterDef|vw_action_parameter_def||
|ActionParameterDefAssign|vw_action_parameter_def_assign||
|Actor|vw_actor||
|BillOfMaterials|vw_bom||
|BomCompositeMaterial|vw_bom_material_composite||
|BomMaterial|vw_bom_material||
|Calculation|vw_calculation||
|CalculationDef|vw_calculation_def||
|CompositeMaterial|vw_material_composite||
|CompositeMaterialProperty|vw_material_composite_property||
|Condition|vw_condition||
|ConditionDef|vw_condition_def||
|Edocument|vw_edocument||
|Experiment|vw_experiment||
|ExperimentWorkflow|vw_experiment_workflow||
|Inventory|vw_inventory||
|InventoryMaterial|vw_inventory_material||
|Material|vw_material||
|MaterialProperty|vw_material_property||
|MaterialRefnameDef|vw_material_refname_def||
|MaterialType|vw_material_type||
|Note|vw_note||
|Note_x|note_x||
|Organization|vw_organization||
|Outcome|vw_outcome||
|Parameter|vw_parameter||
|ParameterDef|vw_parameter_def||
|Person|vw_person||
|Property|vw_property||
|PropertyDef|vw_property_def||
|Status|vw_status||
|Systemtool|vw_systemtool||
|SystemtoolType|vw_systemtool_type||
|Tag|vw_tag||
|TagAssign|vw_tag_assign||
|TagType|vw_tag_type||
|UdfDef|vw_udf_def||
|Workflow|vw_workflow||
|WorkflowObject|vw_workflow_object||
|WorkflowStep|vw_workflow_step||
|WorkflowType|vw_workflow_type||

## Unexposed views 
vw_actor_pref 
vw_calculation_parameter_def
vw_calculation_parameter_def_assign
vw_condition_calculation
vw_condition_calculation_def_assign
vw_condition_path
vw_experiment_measure_calculation
vw_inventory_material_material
vw_material_refname
vw_material_type_assign
vw_measure_def
vw_outcome_measure
vw_udf
vw_workflow_action_set

# Categories
## 1. Workflow

| Table | Postgres View | Notes |
|-------|---------------|-------|
|Action|vw_action||
|ActionDef|vw_action_def||
|ActionParameter|vw_action_parameter||
|ActionParameterDef|vw_action_parameter_def||
|ActionParameterDefAssign|vw_action_parameter_def_assign||
|BillOfMaterials|vw_bom||
|BomCompositeMaterial|vw_bom_material_composite||
|BomMaterial|vw_bom_material||
|Condition|vw_condition||
|ConditionDef|vw_condition_def||
|Experiment|vw_experiment||
|ExperimentWorkflow|vw_experiment_workflow||
|Outcome|vw_outcome||
|Workflow|vw_workflow||
|WorkflowObject|vw_workflow_object||
|WorkflowStep|vw_workflow_step||
|WorkflowType|vw_workflow_type||
vw_condition_calculation
vw_condition_calculation_def_assign
vw_condition_path
vw_experiment_measure_calculation
vw_outcome_measure
vw_workflow_action_set

## 2. Organization

| Table | Postgres View | Notes |
|-------|---------------|-------|
|Actor|vw_actor||
|Organization|vw_organization||
|Person|vw_person||
|Systemtool|vw_systemtool||
|SystemtoolType|vw_systemtool_type||
vw_actor_pref
## 3. Chemistry Data

| Table | Postgres View | Notes |
|-------|---------------|-------|
|CompositeMaterial|vw_material_composite||
|CompositeMaterialProperty|vw_material_composite_property||
|Inventory|vw_inventory||
|InventoryMaterial|vw_inventory_material||
|Material|vw_material||
|MaterialProperty|vw_material_property||
|MaterialRefnameDef|vw_material_refname_def||
|MaterialType|vw_material_type||
vw_inventory_material_material
vw_material_refname
vw_material_type_assign

## 4. Generic Data

| Table | Postgres View | Notes |
|-------|---------------|-------|
|Calculation|vw_calculation||
|CalculationDef|vw_calculation_def||
|Edocument|vw_edocument||
|Note|vw_note||
|Note_x|note_x||
|Parameter|vw_parameter||
|ParameterDef|vw_parameter_def||
|Property|vw_property||
|PropertyDef|vw_property_def||
|Status|vw_status||
|Tag|vw_tag||
|TagAssign|vw_tag_assign||
|TagType|vw_tag_type||
|UdfDef|vw_udf_def||
vw_calculation_parameter_def
vw_calculation_parameter_def_assign
vw_measure_def
vw_udf