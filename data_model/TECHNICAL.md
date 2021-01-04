<!-- ESCALATE v3 Data Model -->
<!--
Author: Gary Cattabriga
Date: 01.29.2020
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses 
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
*** used some nice shields from this site:
*** https://shields.io/category/platform-support
-->
<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/darkreactions/ESCALATE">
    <img src="images/Escalate_B-04.png" alt="Logo" width="250 height="100">
  </a>
  <h1 align="center">ESCALATE v3 Data Model</h1>
   <h2 align="center">Technical Document</h2> 
   <p align="center">
    <br />
    <a href="https://github.com/darkreactions/ESCALATE/tree/master/data_model"><strong>Explore the README</strong></a>
    <br />
    <br />
  </p>
</p>

<!-- **************** Table of Contents **************** -->
## Table of Contents

* [Introduction](#introduction)
* [Overview](#overview)
* [Schema Detail](#schemadetail)
* [Functions](#functions)
* [Views](#views)
* [View Models](#viewmodels)
* [Authors](#authors)
* [License](#license)
* [Acknowledgements](#acknowledgements)

<br/>

<!-- ******************* Introduction ****************** -->
<a name="introduction"></a>
## Introduction

These instructions will get a copy of the database up and running on your local machine (or container) for development and testing purposes. 

<br/>


<!-- ******************* Overview ****************** -->
<a name="overview"></a>
## Overview
Talk about the core entities...

[![Schema Highlevel][schema-highlevel]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/escalatev3_schema_highlevel.png)

<br/>

<!-- ******************* Schema Detail ****************** -->
<a name="schemadetail"></a>
## Schema Detail
Discussion on how this stuff all relates together...

[![Schema Detail][schema-detail]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/escalate_erd_physicalmodel.pdf)

### Defined Types
val type is generic holder of 'values', allowing most any type of data to be
stored and retrieved without special consideration of the data type

```
val AS (
	v_type_uuid uuid,
	v_unit varchar,
	v_text varchar,
	v_text_array varchar[],
	v_int int8,
	v_int_array int8[],
	v_num numeric,
	v_num_array numeric[],
	v_edocument_uuid uuid,
	v_source_uuid uuid,
	v_bool BOOLEAN,
	v_bool_array BOOLEAN[]	
)
```
<br/>
Current value types pre-defined in the type_def table are divided into categories ('data' and 'file')
where 'data' describes a data type (e.g. bool, int, num, text) and 'file' describes the type of
file stored as edocument. Pre-defined data type values are (category, description):

```
	('data', 'bool');
	('data', 'array_bool');	
	('data', 'int');
	('data', 'array_int');
	('data', 'num');
	('data', 'array_num');
	('data', 'text');
	('data', 'array_text');
	('data', 'blob');
	('file', 'text');
	('file', 'pdf');
	('file', 'svg');
	('file', 'jpg');
	('file', 'png');
	('file', 'xrd');
```
<br/>

### Core Tables (non ETL)

```
action
action_def
action_parameter_def_x
actor
actor_pref
bom
bom_material
bom_material_composite
bom_material_index
calculation
calculation_class
calculation_def
calculation_eval
calculation_parameter_def_x
calculation_stack
condition
condition_calculation_def_x
condition_def
condition_path
edocument
edocument_x
escalate_change_log
escalate_version
experiment
experiment_type
experiment_workflow
files
inventory
inventory_material
material
material_composite
material_refname
material_refname_def
material_refname_x
material_type
material_type_x
material_x
measure
measure_def
measure_type
measure_x
note
note_x
organization
outcome
parameter
parameter_def
parameter_x
person
property
property_def
property_x
status
sys_audit
systemtool
systemtool_type
tag
tag_type
tag_x
type_def
udf
udf_def
udf_x
workflow
workflow_action_set
workflow_object
workflow_state
workflow_step
workflow_type

```
<br/>

### Primary Keys, Constraints and Foreign Keys
Tables and their associated primary keys (pk\_), index and unique constraints (ix_\_, un\_) and 
foreign keys (fk\_):

```
action:  ix_action_action_def
action:  ix_action_ref_parameter
action:  ix_action_workflow_action_set
action:  pk_action_action_uuid
action:  ix_action_workflow
```
```
action_def:  pk_action_def_action_def_uuid
action_def:  un_action_def
```
```
action_parameter_def_x:  ix_action_parameter_def_x_parameter_def
action_parameter_def_x:  un_action_parameter_def_x_def
action_parameter_def_x:  pk_action_parameter_def_x_action_parameter_def_x_uuid
action_parameter_def_x:  ix_action_parameter_def_x_action_def
```
```
actor:  ix_actor_systemtool
actor:  pk_actor_uuid
actor:  un_actor
actor:  ix_actor_person
actor:  ix_actor_organization
```
```
actor_pref:  pk_actor_pref_uuid
```
```
bom:  pk_bom_bom_uuid
bom:  ix_bom_experiment_uuid
bom:  ix_outcome_experiment_uuid
```
```
bom_material:  ix_bom_material_inventory_material
bom_material:  pk_bom_material_bom_material_uuid
bom_material:  ix_bom_material_bom_uuid
```
```
bom_material_composite:  ix_bom_material_composite_material_composite
bom_material_composite:  ix_bom_material_composite_bom_material
bom_material_composite:  pk_bom_material_composite_bom_material_composite_uuid
```
```
bom_material_index:  ix_bom_material_index_bom_material
bom_material_index:  pk_bom_material_index_bom_material_index_uuid
bom_material_index:  ix_bom_material_index_bom_material_composite
```
```
calculation:  un_calculation
calculation:  pk_calculation_calculation_uuid
calculation:  ix_calculation_calculation_def
```
```
calculation_class:  pk_calculation_class_calculation_class_uuid
```
```
calculation_def:  un_calculation_def
calculation_def:  pk_calculation_calculation_def_uuid
```
```
calculation_eval:  pk_calculation_eval_calculation_eval_id
calculation_eval:  un_calculation_eval
```
```
calculation_parameter_def_x:  ix_calculation_parameter_def_x_calculation_def
calculation_parameter_def_x:  pk_calculation_parameter_def_x_calculation_parameter_def_x_uuid
calculation_parameter_def_x:  un_calculation_parameter_def_x_def
calculation_parameter_def_x:  ix_calculation_parameter_def_x_parameter_def
```
```
calculation_stack:  calculation_stack_pkey
```
```
condition:  pk_condition_condition_uuid
condition:  ix_condition_workflow
condition:  ix_condition_workflow_action_set
condition:  ix_condition_condition_calculation_def_x
```
```
condition_calculation_def_x:  ix_condition_calculation_def_x_condition_def
condition_calculation_def_x:  un_condition_calculation_def_x
condition_calculation_def_x:  pk_condition_calculation_def_x_condition_calculation_def_x_uuid
condition_calculation_def_x:  ix_condition_calculation_def_x_calculation_def
```
```
condition_def:  pk_condition_def_condition_def_uuid
condition_def:  un_condition_def
```
```
condition_path:  un_condition_path
condition_path:  pk_condition_path_condition_path_uuid
```
```
edocument:  pk_edocument_edocument_uuid
edocument:  un_edocument
```
```
edocument_x:  pk_edocument_x_edocument_x_uuid
edocument_x:  un_edocument_x
edocument_x:  ix_edocument_x_edocument
edocument_x:  ix_edocument_x_ref_edocument
```
```
escalate_change_log:  pk_escalate_change_log_uuid
```
```
escalate_version:  pk_escalate_version_uuid
escalate_version:  un_escalate_version
```
```
experiment:  ix_experiment_parent_path
experiment:  ix_experiment_parent_uuid
experiment:  pk_experiment_experiment_uuid
```
```
experiment_type:  pk_experiment_type_experiment_type_uuid
```
```
experiment_workflow:  pk_experiment_workflow_uuid
experiment_workflow:  ix_experiment_workflow_workflow
experiment_workflow:  ix_experiment_workflow_experiment
```
```
inventory:  pk_inventory_inventory_uuid
```
```
inventory_material:  un_inventory_material
inventory_material:  ix_inventory_material
inventory_material:  pk_inventory_material_inventory_material_uuid
inventory_material:  ix_inventory_inventory
```
```
material:  un_material
material:  pk_material_material_uuid
```
```
material_composite:  pk_material_composite_material_composite_uuid
```
```
material_refname:  un_material_refname
material_refname:  pk_material_refname_material_refname_uuid
```
```
material_refname_def:  pk_material_refname_def_material_refname_def_uuid
```
```
material_refname_x:  pk_material_refname_x_material_refname_x_uuid
material_refname_x:  un_material_refname_x
material_refname_x:  ix_material_refname_x_material
material_refname_x:  ix_material_refname_x_material_refname
```
```
material_type:  un_material_type
material_type:  pk_material_type_material_type_uuid
```
```
material_type_x:  pk_material_type_x_material_type_x_uuid
material_type_x:  un_material_type_x
```
```
material_x:  ix_material_x_ref_material
material_x:  un_material_x
material_x:  pk_material_x_material_x_uuid
material_x:  ix_material_x_material
```
```
measure:  pk_measure_measure_uuid
measure:  ix_measure_measure_def
```
```
measure_def:  pk_measure_def_measure_def_uuid
```
```
measure_type:  pk_measure_type_measure_type_uuid
```
```
measure_x:  ix_measure_x_ref_measure
measure_x:  un_measure_x
measure_x:  pk_measure_x_measure_x_uuid
measure_x:  ix_measure_x_measure
```
```
note:  pk_note_note_uuid
```
```
note_x:  ix_note_x_ref_note
note_x:  ix_note_x_note
note_x:  un_note_x
note_x:  pk_note_x_note_x_uuid
```
```
organization:  ix_organization_parent_uuid
organization:  pk_organization_organization_uuid
organization:  un_organization
organization:  ix_organization_parent_path
```
```
outcome:  pk_outcome_outcome_uuid
```
```
parameter:  ix_parameter_parameter_def
parameter:  pk_parameter_parameter_uuid
```
```
parameter_def:  pk_parameter_def_parameter_def_uuid
parameter_def:  un_parameter_def
```
```
parameter_x:  ix_parameter_x_ref_parameter
parameter_x:  pk_parameter_x_parameter_x_uuid
parameter_x:  un_parameter_x_def
parameter_x:  ix_parameter_x_parameter
```
```
person:  pk_person_person_uuid
person:  un_person
```
```
property:  pk_property_property_uuid
property:  ix_property_property_def
```
```
property_def:  un_property_def
property_def:  pk_property_def_property_def_uuid
```
```
property_x:  un_property_x_def
property_x:  ix_property_x_property
property_x:  ix_property_x_material
property_x:  pk_property_x_property_x_uuid
```
```
status:  un_status
status:  pk_status_status_uuid
```
```
sys_audit:  ix_sys_audit_relid
sys_audit:  ix_sys_audit_action_tstamp_tx_stm
sys_audit:  ix_sys_audit_action
sys_audit:  sys_audit_pkey
```
```
systemtool:  pk_systemtool_systemtool_uuid
systemtool:  un_systemtool
```
```
systemtool_type:  pk_systemtool_systemtool_type_uuid
```
```
tag:  un_tag
tag:  pk_tag_tag_uuid
```
```
tag_type:  pk_tag_tag_type_uuid
tag_type:  un_tag_type
```
```
tag_x:  un_tag_x
tag_x:  ix_tag_x_tag
tag_x:  pk_tag_x_tag_x_uuid
tag_x:  ix_tag_x_ref_tag
```
```
type_def:  un_type_def
type_def:  pk_type_def_type_def_uuid
```
```
udf:  pk_udf_udf_uuid
```
```
udf_def:  pk_udf_def_udf_def_uuid
udf_def:  un_udf_def
```
```
udf_x:  un_udf_x
udf_x:  ix_udf_x_udf
udf_x:  ix_udf_x_ref_udf
udf_x:  pk_udf_x_udf_x_uuid
```
```
workflow:  ix_workflow_parent_uuid
workflow:  pk_workflow_workflow_uuid
```
```
workflow_action_set:  pk_workflow_action_set_workflow_action_set_uuid
workflow_action_set:  ix_workflow_action_set_workflow
workflow_action_set:  ix_workflow_action_set_action_def
workflow_action_set:  ix_workflow_action_set_calculation
workflow_action_set:  ix_workflow_action_set_parameter_def
```
```
workflow_object:  ix_workflow_object_workflow
workflow_object:  ix_workflow_object_workflow_action_set
workflow_object:  ix_workflow_object_action
workflow_object:  ix_workflow_object_condition
workflow_object:  un_workflow_object
workflow_object:  pk_workflow_object_workflow_object_uuid
```
```
workflow_state:  pk_workflow_state_workflow_state_uuid
```
```
workflow_step:  un_workflow_step_workflow_step_uuid
workflow_step:  ix_workflow_step_workflow
workflow_step:  ix_workflow_step_workflow_action_set
workflow_step:  ix_workflow_step_workflow_object
workflow_step:  pk_workflow_step_workflow_step_uuid
workflow_step:  ix_workflow_step_parent_uuid
```
```
workflow_type:  pk_workflow_type_workflow_type_uuid
workflow_type:  un_workflow_type
```

<br/>

<!-- ******************* Functions ****************** -->
<a name="functions"></a>
## Functions
List of callable and trigger functions (see SQL code for details):


**trigger\_set\_timestamp() RETURNS TRIGGER**<br/>
*creates both the function and the trigger (for all tables with mod_dt)*<br/>
<br/>

**get\_column\_count (\_table varchar) RETURNS TABLE (t\_column\_name text, t\_count int8)**<br/>
*creates both the function and the trigger (for all tables with mod_dt)*<br/>
`select c.t_column_name as col_name, c.t_count as count from get_column_count( 'load_v2_bromides') c;`<br/>
<br/>

**if\_modified\_func () RETURNS TRIGGER**<br/>
*Track changes to a table at the statement and/or row level*<br/>
<br/>

**audit\_table (target\_table regclass, audit\_rows boolean, audit\_query\_text boolean, ignored\_cols text []) RETURNS void**<br/>
*add or drop auditing support to a table*<br/>
`SELECT audit_table('person');`<br/>
`DROP TRIGGER audit_trigger_row ON person;`<br/>
<br/>

**read\_file\_utf8 (path CHARACTER VARYING) RETURNS TEXT**<br/>
*read the contents of a text file, stripping out carriage returns, line feeds and following spaces*<br/>
<br/>

**read\_file (path CHARACTER VARYING) RETURNS TEXT**<br/>
*read the contents of a text file, retains all chars, including the control chars*<br/>
<br/>

**isdate (txt VARCHAR) RETURNS BOOLEAN**<br/>
*if str can be cast to a date, then return TRUE, else FALSE*<br/>
<br/>

**read\_dirfiles (PATH CHARACTER VARYING) RETURNS BOOLEAN**<br/>
*creates load_FILES table populated with all file[names] starting with the [path] directory and all subdirectories*<br/>
<br/>

**get\_table\_uuids () RETURNS TABLE (ref\_uuid uuid, entity text)**<br/>
*returns a table of all primary key UUIDs and their respective TABLE NAME*<br/>
`select * from get_table_uuids();`<br/>
<br/>

**get\_material\_uuid\_bystatus (p\_status_array varchar [], p\_null\_bool boolean) RETURNS TABLE (material\_uuid uuid, material\_description varchar)**<br/>
*return material id's with specific status*<br/>
`SELECT * FROM get_material_uuid_bystatus (array['active', 'proto'], TRUE);`<br/>
<br/>

**get\_material\_nameref_bystatus (p\_status\_array varchar [], p\_null\_bool boolean) RETURNS TABLE (material\_uuid uuid, material\_refname varchar, material\_refname\_def varchar)**<br/>
*return material id, material name based on specific status*<br/>
`SELECT * FROM get_material_nameref_bystatus (array['active', 'proto'], TRUE) where material_refname_def = 'InChI' order by 1;`<br/>
<br/>

**get\_material\_bydescr\_bystatus (p\_descr varchar, p\_status_array VARCHAR [], p\_null\_bool BOOLEAN) RETURNS TABLE (material\_uuid uuid, material\_description varchar, material\_refname\_uuid uuid, material\_refname\_description VARCHAR, material\_refname\_def varchar)**<br/>
*return material uuid, material description, material_ref uuid, material_ref description based on specific status*<br/>
`SELECT * FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE);`<br/>
<br/>

**get\_material\_type (p\_material\_uuid uuid) RETURNS varchar []**<br/>
*returns varchar array of material_types associated with a material (uuid)*<br/>
`SELECT * FROM get_material_type ((SELECT material_uuid FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE)));`<br/>
<br/>

**get\_calculation\_def (p_descr VARCHAR []) RETURNS TABLE (calculation\_def\_uuid uuid, short\_name varchar, systemtool\_name varchar, calc_definition varchar, description varchar, in\_type\_uuid uuid, out\_type\_uuid uuid, systemtool\_version varchar)**<br/>
*returns keys (uuid) of calculation_def matching p_descrp parameters*<br/>
`SELECT * FROM get_calculation_def (array['standardize']);`<br/>
<br/>

**get\_calculation (p\_material\_refname varchar, p\_descr VARCHAR [] = NULL) RETURNS TABLE (calculation\_uuid uuid)**<br/>
*returns uuid of calculation*<br/>
`SELECT * FROM get_calculation ('CN(C)C=O');`<br/>
<br/>

**get\_val\_json (p_in val) RETURNS json**<br/>
*returns value from a 'val' type composite in json, otherwise null*<br/>
`SELECT get_val_json (concat('(',(select type_def_uuid from vw_type_def where category = 'data' and description ='bool'),',,,,,,,,,,TRUE,)')::val)`<br/>
<br/>

**get\_val\_actual (p\_in anyelement, p\_val val) RETURNS anyelement**<br/>
*returns value from a 'val' type composite, otherwise null*<br/>
`SELECT get_val_actual (null::numeric, concat('(',(select type_def_uuid from vw_type_def where category = 'data' and description ='num'),',,,,,,266.99,,,,,)')::val);`<br/>
<br/>

**get_val (p\_in val) RETURNS table (val\_type text, val\_unit text, val\_val text)**<br/>
*returns type, unit and value (all as text) from a 'val' type composite*<br/>
`SELECT get_val (concat('(',(select type_def_uuid from vw_type_def where category = 'data' and description ='fred'), ',,,,,,,,,,TRUE,)')::val);`<br/>
<br/>

**get\_val\_unit (p\_in val) returns text**<br/>
*returns unit (as text) from a 'val' type composite*<br/>
`SELECT get_val_unit (concat('(',(select type_def_uuid from vw_type_def where category = 'data' and description ='int'),',mols,,,15,,,,,,,)')::val);`<br/>
<br/>

**get\_type\_def (\_category varchar, \_description varchar) returns uuid**<br/>
*returns uuid of type_def or null*<br/>
`select get_type_def ('data', 'text');`<br/>
<br/>

**arr\_val\_2\_val_arr (arr\_val val) RETURNS val[]**<br/>
*function to convert an array (in a val) to an array of val's*<br/>
`select arr_val_2_val_arr ((select out_val from vw_calculation where short_name = 'LANL_WF1_H2O_5mL_concentration'));`<br/>
<br/>

**get\_chemaxon\_directory (p\_systemtool\_uuid uuid, p\_actor\_uuid uuid) RETURNS TEXT**<br/>
*returns the directory chemaxon tool is located; uses actor_pref *<br/>
<br/>

**get\_chemaxon\_version (p\_systemtool\_uuid uuid, p\_actor\_uuid uuid ) RETURNS TEXT**<br/>
*returns the version for the specified chemaxon tool in string format*<br/>
`select arr_val_2_val_arr ((select out_val from vw_calculation where short_name = 'LANL_WF1_H2O_5mL_concentration'));`<br/>
<br/>

**math\_op (p\_in\_num numeric, p\_op text, p\_in\_opt\_num numeric DEFAULT NULL) RETURNS numeric**<br/>
*results of math operation as NUM*<br/>
`select math_op(12, '/', 6);`<br/>
<br/>

**math\_op\_arr(p\_in\_num numeric[], p\_op text, p\_in\_opt_num numeric DEFAULT NULL) RETURNS numeric[]**<br/>
*returns the result of a basic math operation on a numeric operation*<br/>
`select math_op_arr(array[12, 6, 4, 2, 1, .1, .01, .001], '/', 12);`<br/>
<br/>

**do\_calculation (p\_calculation\_def\_uuid uuid) RETURNS val**<br/>
*returns the results of a basic postgres math operation; will bring in any associated parameters*<br/>
`select do_calculation((select calculation_def_uuid from vw_calculation_defwhere short_name = 'LANL_WF1_H2O_5mL_concentration'));`<br/>
<br/>

**delete\_assigned\_recs (p\_ref\_uuid uuid) RETURNS TABLE (entity text, ref\_uuid uuid)**<br/>
*removes associated records to p_ref_uuid for the following entities: note, tag, udf*<br/>
`select delete_assigned_recs ((select actor_uuid from vw_actor where description = 'Lester Tester'));`<br/>
<br/>

**stack\_clear () RETURNS int**<br/>
*delete all items in the LIFO stack (calculation_stack); reset id (serial) to 1*<br/>
`select stack_clear ();`<br/>
<br/>

**stack\_push (p_val val) RETURNS int4**<br/>
*pushes value (p_val) onto stack (calculation_stack)*<br/>
`select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '100', 'C'))::val);`<br/>
<br/>

**stack\_pop () RETURNS val**<br/>
*pops value off from stack (calculation_stack) in LIFO manner*<br/>
`select stack_pop ();`<br/>
<br/>

**stack\_dup () RETURNS void**<br/>
*duplicates the top value - pops val, then pushes twice*<br/>
`select stack_dup ();`<br/>
<br/>

**stack\_swap () RETURNS void**<br/>
*swaps the two top values - pops val, pops val, then push, push*<br/>
`select stack_swap ();`<br/>
<br/>

**tag\_to\_array (p\_ref\_uuid uuid) RETURNS text[]**<br/>
*returns the tags associated with the uuid (p_ref_uuid) in an array (text[])*<br/>
`select tag_to_array ((select actor_uuid from vw_actor where description = 'Lester Tester'));`<br/>
<br/>

**note\_to\_array (p\_ref\_uuid uuid) RETURNS text[]**<br/>
*returns the notes associated with the uuid (p_ref_uuid) in an array (text[])*<br/>
`select note_to_array ((select actor_uuid from vw_actor where description = 'Lester Tester'));`<br/>
<br/>

**experiment\_copy (p\_experiment\_uuid uuid, p\_new\_name varchar default null) RETURNS uuid**<br/>
*instantiates a full experiment (sans measures) based on an existing experiment (experiment_uuid)*<br/>
`select * from experiment_copy ((select experiment_uuid from vw_experiment where description = 'LANL Test Experiment Template'));`<br/>
<br/>
<br/>

<!-- ******************* Views ****************** -->
<a name="views"></a>
## Views
Below are a list of the views with high-level description, followed by column names returned by view. Views are named using the following structure: 

### Available Views

```
sys_audit_tableslist
vw_action
vw_action_def
vw_action_parameter
vw_action_parameter_def
vw_action_parameter_def_assign
vw_actor
vw_actor_pref
vw_bom
vw_bom_material
vw_bom_material_composite
vw_bom_material_index
vw_calculation
vw_calculation_def
vw_calculation_parameter_def
vw_calculation_parameter_def_assign
vw_condition
vw_condition_calculation
vw_condition_calculation_def_assign
vw_condition_def
vw_condition_path
vw_edocument
vw_experiment
vw_experiment_parameter
vw_experiment_type
vw_experiment_workflow
vw_inventory
vw_inventory_material
vw_inventory_material_material
vw_material
vw_material_composite
vw_material_composite_property
vw_material_property
vw_material_refname
vw_material_refname_def
vw_material_type
vw_material_type_assign
vw_measure
vw_measure_def
vw_measure_type
vw_note
vw_organization
vw_outcome
vw_outcome_measure
vw_parameter
vw_parameter_def
vw_person
vw_property
vw_property_def
vw_status
vw_systemtool
vw_systemtool_type
vw_tag
vw_tag_assign
vw_tag_type
vw_type_def
vw_udf
vw_udf_def
vw_workflow
vw_workflow_action_set
vw_workflow_object
vw_workflow_step
vw_workflow_type

```
<br/>


Views provide full **CRUD/Restful API** or minimally **Read/Get** functionality<br/>
```
(C)reate/Post, (R)ead/Get, (U)pdate/Put, (D)elete/Delete
```
<br/>
Each view is described below with the following information:<br/>
__view name__, if it is fully `CRUD` or only `R`, <br/>
*associated upsert trigger function*<br/>
followed by the returned columns;<br/>
columns required are denoted with an `r` (required on insert, not updatable), <br/>
columns visible in forms are denoted with a `v`,<br/>
columns updatable are denoted with a `u`<br/>
Examples<br/><br/>


__sys\_audit\_tablelist__ `R`<br/>

> trigger\_schema (v) <br/>
> event\_object\_table (v) <br/>

```
 Note: view of sys_audit tables with trigger on
```
```
 Example: 
 select * from sys_audit_tablelist;

```
<br/>

__vw\_action__ `CRUD`<br/>
*upsert\_action()*

> action\_uuid (v) <br/>
> action\_def\_uuid (r v u) <br/>
> workflow\_uuid (r v u) <br/>
> workflow\_description (v) <br/>
> workflow\_action\_set\_uuid (v) <br/>
> workflow\_action\_set\_description (v) <br/>
> action\_description (r v u) <br/>
> action\_def\_description (v) <br/>
> start\_date (v u) <br/>
> end\_date (v u) <br/>
> duration (v u) <br/>
> repeating (v u) <br/>
> ref\_parameter\_uuid (v u) <br/>
> calculation\_def\_uuid (v u) <br/>
> source\_material\_uuid (v u) <br/>
> source\_material\_description (v) <br/>
> destination\_material\_uuid (v u) <br/>
> destination\_material\_description (v) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> tags (v) <br/>
> notes (v) <br/>

```
Note:   On INSERT, creates:
		1. An item in the vw_action that points back to an action_def.
		2. k items in the vw_action_parameter where k is the # of parameter_defs 
		assigned to action_def
	    The items in vw_action_parameter are created with the respective default values 
	    from vw_parameter_def,
	    which can be updated through vw_action_parameter.
```
```
Example:
insert into vw_action (action_def_uuid, action_description, status_uuid)
    values (
	(select action_def_uuid from vw_action_def where description = 'heat_stir'), 
	'example_heat_stir',
	(select status_uuid from vw_status where description = 'active'));
update vw_action set actor_uuid = (select actor_uuid from vw_actor where description = 'Ian Pendleton')
    where action_description = 'example_heat_stir';
	insert into vw_action (action_def_uuid, action_description, actor_uuid, status_uuid)
    values (
	(select action_def_uuid from vw_action_def where description = 'heat'), 
	'example_heat',
	(select actor_uuid from vw_actor where description = 'Ian Pendleton'),
	(select status_uuid from vw_status where description = 'active'));
delete from vw_action where action_description = 'example_heat_stir';
delete from vw_action where action_description = 'example_heat';
```
<br/>

__vw\_action\_def__ `CRUD`<br/>
*upsert\_action\_def()*

> action\_def\_uuid (v) <br/>
> description (r v u) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/> 
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/> 
> tags (v) <br/>
> notes (v) <br/>

```
 Note: Deletes elements in vw_action_parameter_def_assign
```
```
 Example: 
 insert into vw_action_def (description, actor_uuid, status_uuid) values
			   ('heat_stir', (select actor_uuid from vw_actor where description = 'Ian Pendleton'),
				(select status_uuid from vw_status where description = 'active')),
			   ('heat', (select actor_uuid from vw_actor where description = 'Ian Pendleton'),
				(select status_uuid from vw_status where description = 'active'));
delete from vw_action_def where description in ('heat_stir', 'heat');
```
<br/>

__vw\_action\_parameter\_def__ `R` <br/>

> action\_def\_uuid (v) <br/>
> description (v) <br/>
> actor\_uuid (v) <br/>
> actor\_description (v) <br/>
> status\_uuid (v) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> parameter\_def\_uuid (v) <br/>
> parameter\_description (v) <br/>
> default\_val (v) <br/>
> required (v) <br/>
> parameter\_val\_type_uuid (v) <br/>
> parameter\_val\_type\_description (v) <br/>
> parameter\_unit (v) <br/>
> parameter\_actor\_uuid (v) <br/>
> parameter\_actor\_description (v) <br/>
> parameter\_status\_uuid (v) <br/>
> parameter\_status\_description (v) <br/>
> parameter\_add\_date (v) <br/>
> parameter\_mod\_date (v) <br/>

<br/>



__vw\_action\_parameter\_def\_assign__ `CRD` <br/>
*upsert\_action\_parameter\_def\_assign()*

> action\_parameter\_def\_x\_uuid (v) <br/> 
> action\_def\_uuid (r v u) <br/>
> parameter\_def\_uuid (r v u) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>

```
Notes: 
	* not updatable
	* binds action def to parameter def -- requires both uuids
```
```
 Example:       
 insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid)
     values ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
	     (select parameter_def_uuid from vw_parameter_def where description = 'duration')),
	    ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
	     (select parameter_def_uuid from vw_parameter_def where description = 'temperature')),
	    ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
	     (select parameter_def_uuid from vw_parameter_def where description = 'speed')),
	     ((select action_def_uuid from vw_action_def where description = 'heat'),
	     (select parameter_def_uuid from vw_parameter_def where description = 'duration')),
	    ((select action_def_uuid from vw_action_def where description = 'heat'),
	     (select parameter_def_uuid from vw_parameter_def where description = 'temperature'));
delete
    from vw_action_parameter_def_assign
    where action_def_uuid = (select action_def_uuid from vw_action_def where description = 'heat_stir')
    and parameter_def_uuid in (select parameter_def_uuid
			       from vw_parameter_def
			       where description in ('speed', 'duration', 'temperature'));
```

<br/>

__vw\_action\_parameter__ `CRUD`<br/>
*upsert\_action\_parameter()*

> action\_uuid (v) <br/>
> action\_def\_uuid (r v) <br/>
> action\_description (v) <br/>
> action\_def\_description (v) <br/>
> action\_actor\_uuid (v) <br/>
> action\_actor\_description (v) <br/>
> action\_status\_uuid (v) <br/>
> action\_status\_description (v) <br/>
> action\_add_date (v) <br/>
> action\_mod_date (v) <br/>
> parameter\_uuid (v) <br/>
> parameter\_def\_uuid (r v) <br/>
> parameter\_def\_description (v) <br/>
> parameter\_val (r v u) <br/>
> parameter\_actor_uuid (v u) <br/>
> parameter\_actor\_description (v) <br/>
> parameter\_status\_uuid (v, u) <br/>
> parameter\_status\_description (v) <br/>
> parameter\_add\_date (v) <br/>
> parameter\_mod\_date (v) <br/> 

```
Note: Will fail silently if action def not associated w/ specified parameter def.
```
```
-- this creates three action parameters implicitly
insert into vw_action (action_def_uuid, action_description)
    values ((select action_def_uuid from vw_action_def where description = 'heat_stir'), 'example_heat_stir');
-- which can be modified explicitly:
update vw_action_parameter
    set parameter_val = (select put_val (
    (select val_type_uuid from vw_parameter_def where description = 'speed'),
     '8888',
    (select valunit from vw_parameter_def where description = 'speed'))
    )
    where (action_description = 'example_heat_stir' AND parameter_def_description = 'speed');
-- cleanup
delete from vw_action_parameter where action_description = 'example_heat_stir';

```

__vw_actor__`CRUD`<br/>
*upsert\_actor ()*

> actor\_uuid (v) <br/>
> organization\_uuid (v u) <br/>
> person\_uuid (v u) <br/>
> systemtool\_uuid (v u) <br/>
> description (v u) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> org\_full\_name (v) <br/>
> org\_short\_name (v) <br/>
> person\_last\_name (v) <br/>
> person\_first\_name (v) <br/>
> person\_last\_first (v) <br/>
> person\_org (v) <br/>
> person\_organization\_uuid (v) <br/>
> person\_organization\_description (v) <br/>
> systemtool\_name (v) <br/>
> systemtool\_description (v) <br/>
> systemtool\_type (v) <br/>
> systemtool\_vendor (v) <br/>
> systemtool\_model (v) <br/>
> systemtool\_serial (v) <br/>
> systemtool\_version (v) <br/>
> tags (v) <br/>
> notes (v) <br/> 

`**NOTE: actor will typically have many dependencies (e.g. experiments, workflows, inventory) so deleting may be impractical. In that case do a status change (e.g. inactive)`<br/>
`**NOTE: new actor record will be created on person, organization, systemtool insert`<br/>
`**NOTE: delete vw_actor will automatically delete all related actor_pref records`<br/>

```
-- first create a 'test' person that will become the actor
insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) values ('Tester','Lester','Fester','1313 Mockingbird Ln',null,'Munsterville','NY',null,null,null,null,null,null,null);
-- insert 'test' person into actor
insert into vw_actor (person_uuid, actor_description, actor_status_uuid) values ((select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester')), 'Lester the Actor', (select status_uuid from vw_status where description = 'active'));
-- add a note to the actor; with the author being the same actor !! <- note
insert into vw_note (notetext, actor_uuid, ref_note_uuid) values ('test note for Lester the Actor', (select actor_uuid from vw_actor where person_last_name = 'Tester'), (select actor_uuid from vw_actor where person_last_name = 'Tester'));
-- update the 'test' actor with a new description
update vw_actor set description = 'new description for Lester the Actor' where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));
-- update the 'test' actor with an assigned organization
update vw_actor set organization_uuid = (select organization_uuid from vw_organization where full_name = 'Haverford College') where person_uuid = (select person_uuid from person where (last_name = 'Tester' and first_name = 'Lester'));
-- delete the actor (WILL get an ERROR as there is a dependency to note)
delete from vw_actor where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));
-- delete the note
delete from vw_note where note_uuid in (select note_uuid from vw_note where actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Tester'));
-- delete the actor (no other dependencies, so will succeed)
delete from vw_actor where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));
-- clean up the 'test' person
delete from vw_person where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));
```

<br/>

__vw\_actor\_pref__ `CRUD`<br/>
*upsert\_actor_pref ()*
> actor\_pref\_uuid (v) <br/>
> actor\_uuid (r v) <br/>
> pkey (r v u) <br/>
> pvalue (v u) <br/> 
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
insert into vw_actor_pref (actor_uuid, pkey, pvalue) values ((select actor_uuid from vw_actor where person_last_name = 'Tester'), 'test_key', 'test_value');
update vw_actor_pref set pvalue = 'new_new_test_value' where actor_pref_uuid = (select actor_pref_uuid from vw_actor_pref where actor_uuid = (select actor_uuid from vw_actor where description = 'Lester Fester Tester') and pkey = 'test_key');
delete from vw_actor_pref where actor_pref_uuid = (select actor_pref_uuid from vw_actor_pref where actor_uuid = (select actor_uuid from vw_actor where description = 'Lester Fester Tester'));

```

<br/>

__vw\_bom__ `CRUD`<br/>
*upsert\_bom()*

> bom\_uuid (v) <br/>
> experiment\_uuid (r v u) <br/>
> experiment\_description (v) <br/>
> description (v u) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/> 
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/> 
> tags (v) <br/>
> notes (v) <br/>

```
insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) values (
	(select experiment_uuid from vw_experiment where description = 'test_experiment'),
	'test_bom',					
	(select actor_uuid from vw_actor where description = 'T Testuser'),
	(select status_uuid from vw_status where description = 'test'));
update vw_bom set status_uuid = (select status_uuid from vw_status where description = 'active') 
    where description = 'test_bom'; 
delete from vw_bom where description = 'test_bom';

```

<br/>

__vw\_bom\_material__ `CRUD`<br/>
*upsert\_bom\_material()*

> bom\_material\_uuid (v) <br/>
> description (v u) <br/>
> bom\_material\_index\_uuid (v) <br/>
> bom\_uuid (r v u) <br/>
> bom\_description (v) <br/>
> inventory\_material\_uuid (r v u) <br/>
> inventory\_description (v) <br/>
> material\_uuid (v) <br/>
> alloc\_amt\_val (v u) <br/>
> used\_amt\_val (v u) <br/>
> putback\_amt\_val (v u) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/> 
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/> 
> tags (v) <br/>
> notes (v) <br/>

```
insert into vw_bom_material (bom_uuid, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
   (select bom_uuid from vw_bom where description = 'test_bom'),
	(select inventory_material_uuid from vw_inventory_material where description = 'HCL'),
	(select put_val((select get_type_def ('data', 'num')), '500.00','mL')), null, null,	(select actor_uuid from vw_actor where description = 'T Testuser'),
	(select status_uuid from vw_status where description = 'test'));
update vw_bom_material set status_uuid = (select status_uuid from vw_status where description = 'active') 
	where inventory_material_uuid = (select inventory_material_uuid from vw_inventory_material where description = 'HCL');
update vw_bom_material set used_amt_val = (select put_val((select get_type_def ('data', 'num')), '487.21','mL')) 
	where inventory_material_uuid = (select inventory_material_uuid from vw_inventory_material where description = 'HCL');
delete from vw_bom_material where description = 'Sample Prep Plate';

```

<br/>

__vw\_bom\_material\_composite__ `CRUD`<br/>
*upsert\_bom\_material\_composite()*

> bom\_material\_composite\_uuid (v) <br/>
> description (v u) <br/>
> bom\_material\_index\_uuid (v) <br/>
> bom\_material\_uuid (r v u) <br/>
> bom\_material\_description (v) <br/>
> material\_composite\_uuid (r v u) <br/> 
> component\_uuid (v) <br/>
> material\_description (v) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/> 
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/> 
> tags (v) <br/>
> notes (v) <br/>

`**NOTE: do not call this directly - instead use vw_bom_material as the way to insert, update and delete bom_materials`<br/>

```
insert into vw_bom_material_composite (description, bom_material_uuid, material_composite_uuid, actor_uuid, status_uuid) values (
	'Test Plate: Plate well#: A1',
	(select material_composite_uuid from vw_material_composite where component_description = 'Plate well#: A1'),
	(select material_composite_uuid from vw_material_composite where component_description = 'Plate well#: A1'),
	(select actor_uuid from vw_actor where description = 'T Testuser'),
	(select status_uuid from vw_status where description = 'test'));
update vw_bom_material_composite set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'Test Plate: Plate well#: A1';
delete from vw_bom where description = 'Test Plate: Plate well#: A1';

```

<br/>

__vw\_bom\_material\_index__ `R`<br/>

> bom\_material\_index\_uuid (v) <br/>
> description (v) <br/>
> bom\_material\_uuid (v) <br/>
> inventory\_description (v) <br/>
> bom\_material\_composite\_uuid (v) <br/> 
> bom\_material\_description (v) <br/> 
> material\_uuid (v) <br/>
> material\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/> 

<br/>


__vw\_calculation__`CRUD`<br/>
*upsert\_calculation()*
> calculation\_uuid (v) <br/> 
> in\_val (v u) <br/> 
> in\_val\_type (v) <br/> 
> in\_val\_value (v) <br/> 
> in\_val\_unit (v) <br/>
> in\_val\_edocument\_uuid (v) <br/> 
> in\_opt\_val (v u) <br/> 
> in\_opt\_val\_type (v) <br/> 
> in\_opt\_val\_value (v) <br/>
> in\_opt\_val\_unit (v) <br/> 
> in\_opt\_val\_edocument_uuid (v) <br/> 
> out\_val (v u) <br/> 
> out\_val\_type (v) <br/> 
> out\_val\_value (v) <br/> 
> out\_val\_unit (v) <br/> 
> out\_val\_edocument\_uuid (v) <br/> 
> calculation\_alias\_name (v u) <br/> 
> calculation\_add\_date (v) <br/> 
> calculation\_mod\_date (v) <br/> 
> calculation\_actor\_uuid (v u) <br/>
> calculation\_actor\_description (v) <br/>
> calculation\_status\_uuid (v u) <br/>
> calculation\_status\_description (v) <br/> 
> calculation\_tags (v) <br/>
> calculation\_notes (v) <br/>
> calculation\_def\_uuid (v) <br/> 
> short\_name (v) <br/>
> calc\_definition (v) <br/> 
> description (v) <br/> 
> in\_type (v) <br/> 
> out\_type (v) <br/> 
> systemtool\_uuid (v) <br/> 
> systemtool\_name (v) <br/> 
> systemtool\_type\_description (v) <br/> 
> systemtool\_vendor\_organization (v) <br/> 
> systemtool\_version (v) <br/> 
> actor\_uuid (v) <br/> 
> actor\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>

`**NOTE: this will check to see if calculation_def exists`<br/>

```
insert into vw_calculation (short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, 	
	in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid ) 
	values ('test_calc_def', 'function param1 param2', 
	(select systemtool_uuid from vw_actor where description = 'Molecule Standardizer'),
	'testing calculation definition upsert', 
	(select calculation_def_uuid from vw_calculation_def where short_name = 'standardize'), 
	(select type_def_uuid from vw_type_def where category = 'data' and description = 'text'),
	null, null, 
	(select type_def_uuid from vw_type_def where category = 'data' and description = 'int'),
	null, (select actor_uuid from vw_actor where description = 'Gary Cattabriga'),
	(select status_uuid from vw_status where description = 'active')) returning *;
delete from vw_calculation where short_name = 'test_calc_def';
```

<br/>

__vw\_calculation\_def__`CRUD`<br/>
*upsert\_calculation\_def ()*
> calculation\_def\_uuid (v) <br/> 
> short\_name (r v u) <br/> 
> calc\_definition (r v u) <br/>
> description (v u) <br/>
> in\_source\_uuid (v u) <br/>
> in\_type\_uuid (v u) <br/>
> in\_type\_description (v) <br/>
> in\_op\t_source\_uuid (v u) <br/>
> in\_opt\_type\_uuid (v u) <br/>
> in\_opt\_type\_description (v) <br/>
> out\_type\_uuid (v u) <br/>
> out\_unit (v u) <br/>
> out\_type\_description (v) <br/>
> systemtool\_uuid (v u) <br/>
> systemtool\_name (v) <br/>
> systemtool\_type\_description (v) <br/>
> systemtool\_vendor\_organization (v) <br/>
> systemtool\_version (v) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> calculation\_class\_uuid (v u) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> tags (v) <br/>
> notes (v) <br/>

`**NOTE: for postgres calculations (math_op, math_op_arr) make sure parameter reference names in a calc definition 			have  '' around them
          e.g. 'math_op_arr(math_op_arr(''hcl_concentrations'', '/', stock_concentration), '*', total_vol)'`<br/>

```
insert into vw_calculation_def (short_name, calc_definition, systemtool_uuid, description, in_source_uuid, 
	in_type_uuid, in_opt_source_uuid, in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid,status_uuid ) 
	values ('test_calc_def', 'function param1 param2', 
	(select systemtool_uuid from vw_actor where description = 'Molecule Standardizer'),
	'testing calculation definition upsert', 
	(select calculation_def_uuid from vw_calculation_def where short_name = 'standardize'), 
	(select type_def_uuid from vw_type_def where category = 'data' and description = 'text'),
	null, null, 
	(select type_def_uuid from vw_type_def where category = 'data' and description = 'int'),
	null, (select actor_uuid from vw_actor where description = 'Gary Cattabriga'),
	(select status_uuid from vw_status where description = 'active')) returning *;
delete from vw_calculation_def where short_name = 'test_calc_def';
```

<br/>

__vw\_calculation\_parameter\_def__`CRD`<br/>
*upsert\_calculation\_parameter\_def ()*
> calculation\_def\_uuid (r v u) <br/> 
> short\_name (v) <br/> 
> calc\_definition (v) <br/>
> description (v) <br/>
> in\_source\_uuid (v) <br/>
> in\_type\_uuid (v) <br/>
> in\_type\_description (v) <br/>
> in\_opt\_source\_uuid (v) <br/>
> in\_opt\_type\_uuid (v) <br/>
> in\_opt\_type\_description (v) <br/>
> out\_type\_uuid (v u) <br/>
> out\_unit (v u) <br/>
> out\_type\_description (v) <br/>
> systemtool\_uuid (v) <br/>
> systemtool\_name (v) <br/>
> systemtool\_type\_description (v) <br/>
> systemtool\_vendor\_organization (v) <br/>
> systemtool\_version (v) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> calculation\_class\_uuid (v u) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> calculation\_parameter\_def\_x\_uuid (v) <br/>
> parameter\_def\_uuid (r v u) <br/>
> parameter\_def\_description (v) <br/>
> required (v) <br/>
> default\_val (v) <br/>
> parameter\_def\_actor\_uuid <br/>
> parameter\_def\_acto\_description <br/>
> parameter\_def\_status\_uuid <br/>
> parameter\_def\_status\_description <br/>
> parameter\_def\_add\_date <br/>
> parameter\_def\_mod\_date <br/>

`**NOTE: this MAY supercede upsert_calculation_parameter_def_assign`<br/>

```
insert into vw_calculation_parameter_def (calculation_def_uuid, parameter_def_uuid)values 
	((select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration'),
   (select parameter_def_uuid from vw_parameter_def where description = 'hcl_concentration')),
   ((select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration'),
   (select parameter_def_uuid from vw_parameter_def where description = 'total_vol')),
   ((select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration'),
   (select parameter_def_uuid from vw_parameter_def where description = 'stock_concentration'));
delete from vw_calculation_parameter_def where 
	calculation_def_uuid = 
		(select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration')
       and parameter_def_uuid in (select parameter_def_uuid from vw_parameter_def
       where description in ('hcl_concentration', 'total_vol', 'stock_concentration'));
```

<br/>

__vw\_condition__`CRUD`<br/>
*upsert\_condition()*
> condition\_uuid (v) <br/> 
> workflow\_uuid (r v u) <br/>
> workflow\_set\_action\_uuid (v u) <br/>
> condition\_calculation\_def\_x\_uuid (v u) <br/>
> condition\_def\_uuid (v) <br/>
> condition\_description (v) <br/>
> calculation\_description (v) <br/>
> in\_val (v u) <br/> 
> out\_val (v u) <br/>
> actor\_uuid (v u) <br/> 
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>


`**NOTE: requires condition_calculation_def_x_uuid`<br/>

```
insert into vw_condition 
	(condition_calculation_def_x_uuid, in_val, out_val, actor_uuid, status_uuid) values (
	(select condition_calculation_def_x_uuid from vw_condition_calculation_def_assign where 
		condition_description = 'temp > threshold ?'),
	(ARRAY[(SELECT put_val ((select get_type_def ('data', 'num')), '100', 'C'))]), 
	(ARRAY[(SELECT put_val ((select get_type_def ('data', 'bool')), 'FALSE', null))]),
	(select actor_uuid from vw_actor where description = 'T Testuser'),
	(select status_uuid from vw_status where description = 'active'));
update vw_condition set 
	in_val = (ARRAY[(SELECT put_val ((select get_type_def ('data', 'num')), '120', 'C'))]) 
		where condition_description = 'temp > threshold ?'; 
delete from vw_condition where condition_description = 'temp > threshold ?';
```
<br/>

__vw\_condition\_calculation__`R`<br/>
> condition\_uuid (v) <br/> 
> condition\_description (v) <br/>
> in\_val (v u) <br/> 
> out\_val (v u) <br/>
> actor\_uuid (v u) <br/> 
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> calculation\_def\_uuid (v) <br/>
> calculation\_short\_name (v) <br/>
> calculation\_calc\_definition (v) <br/>
> calculation\_description (v) <br/>
> calculation\_actor\_uuid (v) <br/>
> calculation\_actor\_description (v) <br/>
> calculation\_status\_uuid (v) <br/>
> calculation\_status\_description (v) <br/>
> calculation\_add\_date (v) <br/>
> calculation\_mod\_date (v) <br/>

<br/>


__vw\_condition\_calculation\_def\_assign__`CRUD`<br/>
*upsert\_condition\_calculation\_def\_assign ()*
> condition\_calculation_def_x_uuid (v) <br/> 
> condition\_def\_uuid (r v u) <br/>
> condition\_description (v) <br/>
> calculation\_def\_uuid (r v u) <br/>
> calculation\_description (v) <br/>
> calculation\_add\_date (v) <br/>
> calculation\_mod\_date (v) <br/>

`**NOTE: requires condition_def_uuid and calculation_def_uuid`<br/>

```
-- first create a calculation
insert into vw_calculation_def 
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, 	in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid ) 
	values ('greater_than', 'pop A, pop B, >', 
		(select systemtool_uuid from vw_actor where systemtool_name = 'escalate'),
		'B > A ? (pop B, pop A, >?) returning true or false', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'bool'),
		null, (select actor_uuid from vw_actor where description = 'T Testuser'),
		(select status_uuid from vw_status where description = 'active'));
insert into vw_condition_calculation_def_assign (condition_def_uuid, calculation_def_uuid) VALUES 
	((select condition_def_uuid from vw_condition_def where description = 'temp > threshold ?'),
	(select calculation_def_uuid from vw_calculation_def where short_name = 'greater_than'));
delete from vw_condition_calculation_def_assign where
	condition_def_uuid = (select condition_def_uuid from vw_condition_def where description = 'temp > threshold ?') and
	calculation_def_uuid = (select calculation_def_uuid from vw_calculation_def where short_name = 'greater_than');
delete from vw_calculation_def where short_name = 'greater_than';
```

<br/>

__vw\_condition\_def__`CRUD`<br/>
*upsert\_condition\_def()*
> condition\_def\_uuid (v) <br/> 
> description (r v u) <br/>
> actor\_uuid (v u) <br/> 
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>

`**NOTE: think of the conditions (and related calculation) as stack-based -> LIFO ala forth`<br/>

```
insert into vw_condition_def (description, actor_uuid) values
	('temp > threshold ?', (select actor_uuid from vw_actor where description = 'T Testuser'));
update vw_condition_def set status_uuid = (select status_uuid from vw_status where description = 'active') where
	description = 'temp > threshold ?';
delete from vw_condition_def where description = 'temp > threshold ?';
```
<br/>


__vw\_condition\_path__`CRUD`<br/>
*upsert\_condition\_path()*
> condition\_path\_uuid (v) <br/> 
> condition\_uuid (v u) <br/>
> condition_out_val (v u) <br/>
> workflow_step_uuid (v u) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>

```
insert into vw_condition_path (condition_uuid, condition_out_val, workflow_step_uuid) values (
	(select condition_uuid from vw_condition where condition_description = 'temp > threshold ?'),
	((SELECT put_val ((select get_type_def ('data', 'bool')), 'FALSE', null))),
	(select workflow_step_uuid from vw_workflow_step where 
		(object_description = 'example_heat_stir' and parent_object_description = 'temp > threshold ?')));
insert into vw_condition_path 
	(condition_uuid, condition_out_val, workflow_step_uuid) values (
	(select condition_uuid from vw_condition where condition_description = 'temp > threshold ?'),
	((SELECT put_val ((select get_type_def ('data', 'bool')), 'FALSE', null))),
	(select workflow_step_uuid from vw_workflow_step where 
		(object_description = 'example_heat' and parent_object_description = 'temp > threshold ?')));
update vw_condition_path set 
	condition_out_val = ((SELECT put_val ((select get_type_def ('data', 'bool')), 'TRUE', null))) where 		condition_path_uuid = (select condition_path_uuid from vw_condition_path where 
			condition_uuid = (select condition_uuid from vw_condition where 
				condition_description = 'temp > threshold ?') and 
				workflow_step_uuid = (select workflow_step_uuid from vw_workflow_step where 
					(workflow_description = 'test_workflow' and 
					object_type = 'action' and object_description = 'example_heat'))); 
delete from vw_condition_path where condition_uuid = (select condition_uuid from vw_condition where
	condition_description = 'temp > threshold ?');
```
<br/>


__vw\_edocument__`CRUD`<br/>
*upsert\_edocument ()*
> edocument\_uuid (v) <br/> 
> title (r v u) <br/> 
> description (v u) <br/> 
> filename (v u) <br/>
> source (v u) <br/> 
> edocument (r v u) <br/> 
> doc\_type\_uuid (r v u) <br/> 
> doc\_type\_description (v) <br/> 
> doc\_ver (v u) <br/> 
> actor\_uuid (v u) <br/> 
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> edocument\_x\_uuid (v) <br/>
> ref\_edocument_uuid (v u) <br/>

```
-- just insert the document, with no association to an entity
insert into vw_edocument (title, description, filename, source, edocument, doc_type, doc_ver, actor_uuid, status_uuid) 
	values ('Test document 1', 'This is a test document', null, null, 'a bunch of text cast as a blob'::bytea, 'blob_text'::val_type, null,
	(select actor_uuid from vw_actor where description = 'Gary Cattabriga'), (select status_uuid from vw_status where description = 'active'));
delete from vw_edocument where edocument_uuid = (select edocument_uuid from vw_edocument where title = 'Test document 1');
```
<br/>

__vw\_experiment__`CRUD`<br/>
*upsert\_experiment ()*
> experiment\_uuid (v) <br/> 
> experiment\_type\_uuid (v) <br/>
> ref\_uid (v u) <br/>
> description (v u) <br/> 
> parent\_uuid (v u) <br/>
> parent\_description (v) <br/>
> parent\_path (v) <br/>
> owner\_uuid (v u) <br/>
> owner\_description (v) <br/>
> operator\_uuid (v u) <br/>
> operator\_description (v) <br/>
> lab\_uuid (v u) <br/>
> lab\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> tags (v) <br/>
> notes (v u) <br/>

```
insert into vw_experiment (ref_uid, description, parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid) values (
	'test_red_uid', 'test_experiment', null,
	(select actor_uuid from vw_actor where description = 'HC')
	(select actor_uuid from vw_actor where description = 'T Testuser'),
	(select actor_uuid from vw_actor where description = 'HC'),
	null);
update vw_experiment set status_uuid = (select status_uuid from vw_status where description = 'active') where 	description = 'test_experiment'; 
delete from vw_experiment where description = 'test_experiment';
```
<br/>

<br/>

__vw\_experiment\_parameter__`RU`<br/>
*upsert\_experiment\_parameter ()*
> experiment\_uuid (v) <br/> 
> experiment (v) <br/>
> workflow (v) <br/>
> workflow\_seq (v) <br/>
> workflow\_object (v) <br/>
> object\_description (v) <br/>
> object\_uuid (v) <br/>
> parameter\_def\_description (v) <br/>
> parameter\_uuid (v) <br/>
> parameter\_value (v u) <br/>

`**NOTE: trigger proc that executes only on an update (to the list of actions)
         The update process depends on action type (action, action_set):
         it may only update a parameter value (action) or,
         delete a set of actions and rebuild the actions based on new parameter (action_set)`<br/>

```
update vw_experiment_parameter
	set parameter_value =
   		array[(select put_val ((select val_type_uuid from vw_parameter_def where description = 'total_vol'), '9.9',
       	(select valunit from vw_parameter_def where description = 'volume')))]
    where experiment = 'LANL Test Experiment Template' and 
    	object_description = 'dispense Am-Stock into SamplePrep Plate action_set'
      	and parameter_def_description = 'volume';
```
<br/>

__vw\_experiment\_type__`CRUD`<br/>
*upsert\_experiment\_type ()*
> experiment\_type\_uuid (v) <br/> 
> description (v u) <br/> 
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> tags (v) <br/>
> notes (v) <br/>

```
insert into vw_experiment_type (description, actor_uuid, status_uuid) values
	('TEST experiment type',
	(select actor_uuid from vw_actor where org_short_name = 'HC'), null);
update vw_experiment_type set
	status_uuid = (select status_uuid from vw_status where description = 'active') where (description = 'TEST measure type');
delete from vw_experiment_type where experiment_type_uuid = (select experiment_type_uuid from vw_experiment_type
    where (description = 'TEST experiment type'));;
```



<br/>

__vw\_organization__ `CRUD`<br/>
*upsert\_organization ()*
> organization\_uuid (v) <br/>
> description (v u) <br/>
> full\_name (r v) <br/>
> short_name (v u) <br/> 
> address1 (v u) <br/>
> address2 (v u) <br/>
> city (v u) <br/>
> state\_province (v u) <br/> 
> zip (v u) <br/> 
> country (v u) <br/> 
> website\_url (v u) <br/> 
> phone (v u) <br/> 
> parent\_uuid (v u) <br/> 
> parent\_org\_full\_name (v) <br/> 
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
-- insert new record
insert into vw_organization (description, full_name, short_name, address1, address2, city, state_province, zip, country, website_url, phone, parent_uuid) values ('some description here','IBM','IBM','1001 IBM Lane',null,'Some City','NY',null,null,null,null,null);
-- update the description, city and zip columns
update vw_organization set description = 'some [new] description here', city = 'Some [new] City', zip = '00000' where full_name = 'IBM';
-- update with a parent organization
update vw_organization set parent_uuid =  (select organization_uuid from organization where organization.full_name = 'Haverford College') where full_name = 'IBM';
-- delete the record (assumes no dependent, referential records); any notes attached to this record are automatically deleted
delete from vw_organization where full_name = 'IBM';
```

<br/>


__vw_parameter_def__ `CRUD`<br/>
*upsert\_parameter\_def()*

> parameter_def_uuid (v) <br/>
> description (v u) <br/>
> val_type_description (v) <br/>
> val_type_uuid (v) <br/>
> default_val_val (v) <br/>
> valunit (v) <br/>
> default_val (v u) <br/>
> required (v) <br/>
> actor_uuid (v u) <br/>
> actor_description (v) <br/>
> status_uuid (v u) <br/>
> status_description (v) <br/>
> add_date (v) <br/>
> mod_date (v) <br/> 

```
Note: Default val determines the datatype and unit of the parameter def
```
```
Example:		
insert into vw_parameter_def (description, default_val)
	    values
	    ('duration',
	      (select put_val(
		  (select get_type_def ('data', 'num')),
		     '0',
		     'mins')
	       )
	    ),
	    ('speed',
	     (select put_val (
	       (select get_type_def ('data', 'num')),
	       '0',
	       'rpm')
	      )
	    ),
	    ('temperature',
	     (select put_val(
	       (select get_type_def ('data', 'num')),
		 '0',
		 'degC'))
	    );
update vw_parameter_def
    set status_uuid = (select status_uuid from vw_status where description = 'active')
    where description = 'temperature';
delete from vw_parameter_def where description in ('duration', 'speed', 'temperature');
```

<br/>

__vw_parameter__ `CRUD`<br/>
*upsert\_parameter()*

> parameter_uuid (v) <br/>
> parameter_def_uuid (v u) <br/>
> parameter_def_description (v) <br/>
> parameter_val (v u) <br/>
> val_type_description (v) <br/>
> valunit (v) <br/>
> actor_uuid (v u) <br/>
> actor_description (v) <br/> 
> status_uuid (v u) <br/>
> status_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>
> ref_parameter_uuid (v) <br/>
> parameter_x_uuid (v) <br/>

```
Notes: Preferred use is through vw_action_parameter
```
```
Example:		
insert into vw_parameter (parameter_def_uuid, ref_parameter_uuid, parameter_val, actor_uuid, status_uuid ) 
values (
	(select parameter_def_uuid from vw_parameter_def where description = 'duration'),
	(select action_def_uuid from vw_action_def where description = 'heat'),
	(select put_val (
		(select val_type_uuid from vw_parameter_def where description = 'duration'),
		'10',
		(select valunit from vw_parameter_def where description = 'duration'))),
	(select actor_uuid from vw_actor where org_short_name = 'LANL'),
	(select status_uuid from vw_status where description = 'active')
	);
update vw_parameter set parameter_val = (select put_val (
		    (select val_type_uuid from vw_parameter_def where description = 'duration'),
		    '36',
		    (select valunit from vw_parameter_def where description = 'duration')))
		where parameter_def_description = 'duration'
		and ref_parameter_uuid = (select action_def_uuid from vw_action_def where description = 'heat');
delete from vw_parameter where parameter_def_description = 'duration' AND ref_parameter_uuid = (select action_def_uuid from vw_action_def where description = 'heat');
```

<br/>


__vw\_person__ `CRUD`<br/>
*upsert\_person ()*
> person\_uuid (v) <br/>
> first\_name (v u) <br/>
> last\_name (r v) <br/>
> middle\_name (v u) <br/> 
> address1 (v u) <br/>
> address2 (v u) <br/>
> city (v u) <br/>
> state\_province (v u) <br/> 
> zip (v u) <br/> 
> country (v u) <br/> 
> phone (v u) <br/> 
> email (v u) <br/> 
> title (v u) <br/> 
> suffix (v u) <br/> 
> organization\_uuid (v u) <br/> 
> organization\_full\_name (v) <br/> 
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
-- insert new person record; also adds actor record related to this person
insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) values ('Tester','Lester','Fester','1313 Mockingbird Ln',null,'Munsterville','NY',null,null,null,null,null,null,null);
-- update title, city, zip and email columns
update vw_person set title = 'Mr', city = 'Some [new] City', zip = '99999', email = 'TesterL@scarythings.xxx' where person_uuid = (select person_uuid from person where (last_name = 'Tester' and first_name = 'Lester'));
-- update associated organization
update vw_person set organization_uuid =  (select organization_uuid from organization where organization.full_name = 'Haverford College') where (last_name = 'Tester' and first_name = 'Lester');
-- delete record; any notes attached to this record are automatically deleted - note that actor must be deleted first
delete from vw_actor where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));
delete from vw_person where person_uuid = (select person_uuid from person where (last_name = 'Tester' and first_name = 'Lester'));
```
<br/>

__vw\_systemtool__`CRUD`<br/>
*upsert\_systemtool ()*
> systemtool\_uuid (v) <br/>
> systemtool\_name (r v u) <br/>
> description (v u) <br/>
> systemtool\_type\_uuid (v u)
> systemtool\_type\_description (v)
> vendor\_organization\_uuid (v u) <br/> 
> organization\_fullname (v) <br/>
> model (v u) <br/>
> serial (v u) <br/>
> ver (r v u) <br/> 
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
-- insert new systemtool; note, ver[sion] is required
insert into vw_systemtool (systemtool_name, description, systemtool_type_uuid, vendor_organization_uuid, model, serial, ver) values ('MRROBOT', 'MR Robot to you',(select systemtool_type_uuid from vw_systemtool_type where description = 'API'),(select organization_uuid from vw_organization where full_name = 'ChemAxon'),'super duper', null, '1.0');
-- update serial column
update vw_systemtool set serial = 'ABC-1234' where systemtool_uuid = 
 (select systemtool_uuid from vw_systemtool where (systemtool_name = 'MRROBOT'));
-- *** update record with new version, but forced to insert a copy with new ver[sion] and create a new actor ***
update vw_systemtool set ver = '1.1' where systemtool_uuid = 
 (select systemtool_uuid from vw_systemtool where (systemtool_name = 'MRROBOT'));
-- delete [latest] version = 1.1; any notes attached to this record are automatically deleted - note that actor must be deleted first
delete from actor where systemtool_uuid = (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT' and ver = '1.1');
delete from vw_systemtool where systemtool_uuid = (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT' and ver = '1.1');
-- delete version = 1.0; any notes attached to this record are automatically deleted - note that actor must be deleted first
delete from actor where systemtool_uuid = (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT' and ver = '1.1');
delete from vw_systemtool where systemtool_uuid = (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT' and ver = '1.0');
```


<br/>

__vw\_systemtool_type__`CRUD`<br/>
*upsert\_systemtool\_type ()*
> systemtool\_type\_uuid (v) <br/>
> description (v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
-- insert new systemtool_type record
insert into vw_systemtool_type (description) values ('TEST Systemtool Type');
-- update systemtool_type
update vw_systemtool_type set description = 'TEST Systemtool Type w/ extra features';
-- delete systemtool_type; any notes attached to this record are automatically deleted
delete from vw_systemtool_type where systemtool_type_uuid = (select systemtool_type_uuid from vw_systemtool_type where (description = 'TEST Systemtool Type'));
```
<br/>


__vw\_tag__`CRUD`<br/>
*upsert\_tag ()*
> tag\_uuid (v) <br/>
> display_text (r v u) <br/>
> description (v u) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>
> tag\_type\_uuid (v u) <br/>
> tag\_type\_short\_descr (v) <br/>
> tag\_type\_description (v) <br/>

```
-- insert new tag  (tag_uuid = NULL, ref_tag_uuid = NULL)
insert into vw_tag (display_text, description, actor_uuid, tag_type_uuid) 
	values ('invalid', 'invalid experiment', (select actor_uuid from vw_actor where person_last_name = 'Alves'), null);
update vw_tag set description = 'invalid experiment with stuff added', 
 	tag_type_uuid = (select tag_type_uuid from vw_tag_type where type = 'experiment') 
 	where tag_uuid = (select tag_uuid from vw_tag where (display_text = 'invalid'));
 delete from vw_tag where tag_uuid = (select tag_uuid from vw_tag where (display_text = 'invalid' and type = 'experiment'));
```

<br/>


__vw\_tag_assign__`CRUD`<br/>
*upsert\_tag\_assign ()*
> tag\_x\_uuid (v) <br/>
> ref\_tag\_uuid (r)
> tag\_uuid (r) <br/>
> display\_text (v) <br/>
> type (v) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
-- insert new tag_assign (ref_tag) 
insert into vw_tag_assign (tag_uuid, ref_tag_uuid) values ((select tag_uuid from vw_tag 
 	where (display_text = 'inactive' and vw_tag.type = 'actor')), (select actor_uuid from vw_actor where person_last_name = 'Alves') );
delete from vw_tag_assign where tag_uuid = (select tag_uuid from vw_tag 
 	where (display_text = 'inactive' and vw_tag.type = 'actor') and ref_tag_uuid = (select actor_uuid from vw_actor where person_last_name = 'Alves') );
```

<br/>


__vw\_tag_type__`CRUD`<br/>
*upsert\_tag\_type ()*
> tag\_type\_uuid (v) <br/>
> short_description (r u) <br/>
> description (v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
-- insert tag_type
insert into vw_tag_type (short_description, description) values ('TESTDEV', 'tags for development cycle phase');
-- update description column
update vw_tag_type set description = 'tags used to help identify development cycle phase; e.g. SPEC, TEST, DEV' where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (short_description = 'TESTDEV'));
-- update short_description column
update vw_tag_type set short_description = 'TESTDEV1', description = 'tags used to help identify development cycle phase; e.g. SPEC, TEST, DEV' where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (short_description = 'TESTDEV'));
-- delete tag_type (assumes no dependent, referential records); any notes attached to this record are automatically deleted
 delete from vw_tag_type where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (short_description = 'TESTDEV1'));
```

<br/>


__vw\_udf\_def__`CRUD`<br/>
*upsert\_udf\_def ()*
> udf\_def\_uuid (v) <br/>
> description (r v u) <br/>
> valtype (v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
-- insert udf_def record with only description
insert into vw_udf_def (description, valtype) values ('user defined 1', null);
-- update valtype column; need to cast to val_type 
update vw_udf_def set valtype = 'text'::val_type where udf_def_uuid = (select udf_def_uuid from vw_udf_def where (description = 'user defined 1'));
-- delete udf_def; any notes attached to this record are automatically deleted
delete from vw_udf_def where udf_def_uuid = (select udf_def_uuid from udf_def where (description = 'user defined 1'));
```


<br/>


__vw\_udf__`CRUD`<br/>
*upsert\_udf ()*
> udf\_uuid (v) <br/>
> udf\_def\_uuid (r v u) <br/>
> description (v) <br/>
> udf_val (v) <br/>
> udf_val_type_uuid (v) <br/>
> udf_val_val (r v u) <br/>
> udf_val_unit (v) <br/>
> udf_val_edocument_uuid (v u) <br/>
> valtype (v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>
> udf\_x\_uuid (v) <br/>
> ref\_udf\_uuid (r v u) <br/>

```
insert into vw_udf (ref_udf_uuid, udf_def_uuid, udf_val_val) values 
	((select actor_uuid from vw_actor where description = 'HC'),
	(select udf_def_uuid from vw_udf_def where description = 'user defined 1') 
	, 'some text: a, b, c, d');
update vw_udf set udf_val_val = 'some more text: a, b, c, d, e, f' where
	udf_def_uuid = (select udf_def_uuid from vw_udf_def where (description = 'user defined 1'));
delete from vw_udf where udf_def_uuid = (select udf_def_uuid from udf_def where (description = 'user defined 1'));
```

<br/>

__vw\_status__`CRUD`<br/>
*upsert\_status ()*
> status\_uuid (v) <br/>
> description (r v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
insert into vw_status (description) values ('testtest');
update vw_status set description = 'testtest status' where status_uuid = (select status_uuid from vw_status where (description = 'testtest'));
-- delete record; any notes attached to this record are automatically deleted
delete from vw_status where status_uuid = (select status_uuid from vw_status where (description = 'testtest status'));
```

<br/>

__vw\_material\_type__`CRUD`<br/>
*upsert\_material\_type ()*
> material\_type\_uuid (v) <br/>
> description (r v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
insert into vw_material_type (description) values ('materialtype_test');
-- delete record; any notes attached to this record are automatically deleted
delete from vw_material_type where material_type_uuid = (select material_type_uuid from vw_material_type where (description = 'materialtype_test'));
```

<br/>

__vw\_material\_refname\_def__`CRUD`<br/>
*upsert\_material\_refname\_def ()*
> material\_refname\_def\_uuid (v) <br/>
> description (r v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
insert into vw_material_refname_def (description) values ('materialrefnamedef_test');
-- delete record; any notes attached to this record are automatically deleted
delete from vw_material_refname_def where material_refname_def_uuid = (select material_refname_def_uuid from vw_material_refname_def where (description = 'materialrefnamedef_test'));
```


<br/>

__vw\_property\_def__`CRUD`<br/>
*upsert\_property\_def ()*
> property_def_uuid (v) <br/>
> description (v u) <br/>
> short_description (r v u) <br/>
> valtype (r v u) <br/>
> valunit(r v u) <br/>
> actor_uuid (v u) <br/>
> actor_description (v) <br/>
> status_uuid (v u) <br/>
> status_description (v) <br/>
> add_date (v) <br/>
> mod_date (v) <br/>

```
insert into vw_property_def (description, short_description, valtype, valunit, actor_uuid, status_uuid ) 
	values ('particle-size {min, max}', 'particle-size', 'array_num', 'mesh', 
	null,
	(select status_uuid from vw_status where description = 'active'));
update vw_property_def set short_description = 'particle-size', actor_uuid = (select actor_uuid from vw_actor where org_short_name = 'LANL') where (short_description = 'particle-size');
delete from vw_property_def where short_description = 'particle-size';
```

<br/>

__vw\_property__`CRUD`<br/>
*upsert\_property ()*
> property\_uuid (v) <br/>
> property\_def\_uuid (r v u) <br/>
> short\_description (v) <br/>
> property\_val (r v u) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>

`**NOTE: AVOID using this view as an upsert; USE vw_material_property instead.`<br/>

```
insert into vw_property (property_def_uuid, property_val, actor_uuid, status_uuid ) 
	values ((select property_def_uuid from vw_property_def where short_description = 'particle-size'),
	(select put_val ((select valtype from vw_property_def where short_description = 'particle-size'),'{100, 200}',
	(select valunit from vw_property_def where short_description = 'particle-size'))), 
	null,
	(select status_uuid from vw_status where description = 'active'));
update vw_property set actor_uuid = (select actor_uuid from vw_actor where org_short_name = 'LANL') where (property_uuid = 'e36c8f19-cd2f-4f5d-960d-54638f26f066');
delete from vw_property where (property_uuid = 'e36c8f19-cd2f-4f5d-960d-54638f26f066');
```


<br/>

__vw\_material\_property__`CRUD`<br/>
*upsert\_material\_property ()*
> property\_x\_uuid (v) <br/>
> material\_uuid (r v) <br/>
> description (v) <br/>
> parent\_uuid (v) <br/>
> property\_uuid (v) <br/>
> property\_def\_uuid (r v u) <br/>
> property\_short\_description (v u) <br/>
> v\_type\_uuid (v) <br/>
> val\_type (v) <br/>
> val_unit (v) <br/>
> val_val (r v u) <br/>
> property\_val (r v u) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/>
> status\_uuid (v u) <br/>
> status\_description (v) <br/>
> add\_date (v) <br/>
> mod\_date (v) <br/>

`**NOTE: because this is a one to many, on insert property_uuid and material_uuid is (r)equired`<br/>
`**NOTE: property_x_uuid is added to guarantee a unique key for the view table`<br/>

```
insert into vw_material_property (material_uuid, property_def_uuid, 
	val_val, property_actor_uuid, property_status_uuid ) 
	values ((select material_uuid from vw_material where description = 'Formic Acid'),
		(select property_def_uuid from vw_property_def where short_description = 'particle-size'),
		'{100, 200}', 
		null,
		(select status_uuid from vw_status where description = 'active')
	) returning *;
update vw_material_property set property_actor_uuid = (select actor_uuid from vw_actor where org_short_name = 'LANL') where material_uuid = 
	(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'particle-size';
update vw_material_property set val_val = '{100, 900}' where material_uuid = 
	(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'particle-size';
delete from vw_material_property where material_uuid = 
	(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'particle-size';
```

<br/>

__vw\_note__`CRUD`<br/>
*upsert\_material\_refname\_def ()*
> note\_uuid (v) <br/>
> notetext (v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>
> actor\_uuid (v u) <br/>
> actor\_description (v) <br/>
> note\_x\_uuid <br/>
> ref\_note\_uuid (r)

```
insert into vw_note (notetext, actor_uuid, ref_note_uuid) 
	values ('test note', (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), 
	(select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));
insert into vw_note (notetext, actor_uuid) values 
	('test note', (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));
update vw_note set notetext = 'test note with additional text...' where note_uuid = (select note_uuid from vw_note where (notetext = 'test note'));
delete from vw_note where note_uuid = (select note_uuid from vw_note where (notetext = 'test note with additional text...'));
-- delete all notes associated with a given entity
insert into vw_note (notetext, actor_uuid, ref_note_uuid) 
	values ('test note 1', (select actor_uuid from vw_actor where person_last_name = 'Alves'), (select actor_uuid from vw_actor where person_last_name = 'Alves'));
insert into vw_note (notetext, actor_uuid, ref_note_uuid) 
	values ('test note 2', (select actor_uuid from vw_actor where person_last_name = 'Alves'), (select actor_uuid from vw_actor where person_last_name = 'Alves'));
insert into vw_note (notetext, actor_uuid, ref_note_uuid) 
	values ('test note 2', (select actor_uuid from vw_actor where person_last_name = 'Alves'), (select actor_uuid from vw_actor where person_last_name = 'Alves'));
delete from vw_note where note_uuid in (select note_uuid from vw_note where actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Alves'));

```



__vw\_edocument\_assign__`CRUD`<br/>
*upsert\_edocument\_assign ()*
> edocument\_x\_uuid (v) <br/>
> ref\_edocument\_uuid (r v u)
> edocument\_uuid (r v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
-- just insert the document, with no association to an entity
insert into vw_edocument_assign (ref_edocument_uuid, edocument_uuid) values 
 	((select actor_uuid from vw_actor where person_last_name = 'Alves') ,(select edocument_uuid from vw_edocument where (title = 'Test document 1'));
delete from vw_edocument_assign where edocument_uuid = (select edocument_uuid from vw_edocument where 
 	(title = 'Test document 1') and ref_tag_uuid = (select actor_uuid from vw_actor where person_last_name = 'Alves') );
```
<br/>


__vw\_type\_def__`CRUD`<br/>
*upsert\_edocument\_assign ()*
> type\_def\_uuid (v) <br/>
> category (r v u)
> description (r v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
insert into vw_type_def (category, description) values ('data', 'bool');
insert into vw_type_def (category, description) values ('file', 'pdf');
update vw_type_def set description = 'svg' where type_def_uuid = (select type_def_uuid from 
	vw_type_def where category = 'file' and description = 'pdf');
delete from vw_type_def where type_def_uuid = (select type_def_uuid from vw_type_def where category = 'data' and description = 'bool');
delete from vw_type_def where type_def_uuid = (select type_def_uuid from vw_type_def where category = 'file' and description = 'svg');
```
<br/>

__vw\_workflow\_type__`CRUD`<br/>
*upsert\_workflow\_type ()*
> workflow\_type\_uuid (v) <br/>
> description (r v u) <br/>
> add\_date (v) <br/> 
> mod\_date (v) <br/>

```
insert into vw_workflow_type (description) values ('workflowtype_test');
delete from vw_workflow_type where workflow_type_uuid = (select workflow_type_uuid from vw_workflow_type where (description = 'workflowtype_test'));
```

<br/>



<!-- UPDATE views!! 

```
vw_[filter]_[table1]_[table2]_[tablen]
```
where *filter* indicates a 'where/having clause' applied and the [table] entities are listed in order of preponderance.

e.g. __vw\_latest\_systemtool__ returns records from the **systemtool** table with a 'filter' or where clause selecting only 'active' status records. 
<br/><br/>

-->



<br/>


__vw\_inventory__`R`<br/>
> inventory_uuid (v) <br/>
> inventory_description (v) <br/>
> part_no (v) <br/>
> onhand_amt (v) <br/>
> unit (v) <br/>
> create_date (v) <br/>
> expiration_date (v) <br/>
> inventory_location (v) <br/>
> status_uuid (v) <br/>
> status_description (v) <br/>
> material_uuid (v) <br/>
> material_description (v) <br/>
> actor_uuid (v) <br/> 
> actor_description (v) <br/>
> add_date (v) <br/>
> mod_date (v) <br/>

<br/>

__vw\_inventory\_material__`R`<br/>
> inventory_uuid (v) <br/>
> inventory_description (v) <br/>
> inventory_part_no (v) <br/>
> inventory_onhand_amt (v) <br/>
> inventory_unit (v) <br/>
> inventory_create_date (v) <br/>
> inventory_expiration_date (v) <br/>
> inventory_location (v) <br/>
> inventory_status_uuid (v) <br/>
> inventory_status_description (v) <br/>
> actor_uuid (v) <br/>
> actor_description (v) <br/>
> org_full_name (v) <br/>
> material_uuid (v) <br/>
> material_status_description (v) <br/>
> create_date AS material_create_date (v) <br/>
> chemical_name AS material_name (v) <br/>
> abbreviation AS material_abbreviation (v) <br/>
> inchi AS material_inchi (v) <br/>
> inchikey AS material_inchikey (v) <br/>
> molecular_formula AS material_molecular_formula (v) <br/>
> smiles AS material_smiles (v) <br/>


<br/>

__vw\_material__`R`<br/>
> material_uuid (v) <br/>
> description (v) <br/>
> material_status_uuid (v) <br/>
> material_status_description (v) <br/>
> add_date (v) <br/>
> mod_date (v) <br/>
> abbreviation (v) <br/>
> chemical_name (v) <br/>
> inchi (v) <br/>
> inchikey (v) <br/>
> molecular_formula (v) <br/>
> smiles (v) <br/>


<br/>






<br/>


<!-- ******************* View Models ****************** -->
<a name="viewmodels"></a>
## View Models

### Note View Model
[![Note View Model][note-viewmodel]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/note_viewmodel.pdf)

### Tag Manage View Model
[![Tag Manage View Model][tag-manage-viewmodel]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/tag_manage_viewmodel.pdf)

### Tag Assign Model
[![Tag Assign View Model][tag-assign-viewmodel]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/tag_assign_viewmodel.pdf)

### UDF Manage View Model
[![UDF Assign View Model][udf-manage-viewmodel]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/udf_view_model_1.pdf)

### UDF Assign View Model
[![UDF Assign View Model][udf-assign-viewmodel]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/udf_view_model_2.pdf)

<!-- ******************* Authors ****************** -->
<a name="authors"></a>
## Authors

* **Gary Cattabriga** [ESCALATE](https://github.com/gcatabr1)

See also the list of [contributors](https://github.com/darkreactions/ESCALATE/graphs/contributors) who participated in this project.

<br/>

<!-- ******************* License ****************** -->
<a name="license"></a>
## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details

<br/>


<!-- ******************* Acknowledgments ****************** -->
<a name="acknowledgements"></a>
## Acknowledgments
* [DARPA SD2 program](https://www.darpa.mil/program/synergistic-discovery-and-design)
* [Haverford College](https://www.haverford.edu)
* [Lawrence Berkely National Lab](https://www.lbl.gov)



<!-- MARKDOWN LINKS & IMAGES -->
[postgresqlinstall-url]: https://www.postgresql.org/download/
[postgresql-logo]: images/postgresql_logo.png
[dockerinstall-url]: https://docs.docker.com/install/
[docker-logo]: images/docker_logo.png
[pgadmininstall-url]: https://www.pgadmin.org/download/
[pgadmin-logo]: images/pgadmin_logo.png
[schema-highlevel]: erd_diagrams/escalatev3_schema_highlevel.png
[schema-detail]: erd_diagrams/escalate_erd_physicalmodel.png
[note-viewmodel]: erd_diagrams/note_viewmodel.png
[tag-manage-viewmodel]: erd_diagrams/tag_manage_viewmodel.png
[tag-assign-viewmodel]: erd_diagrams/tag_assign_viewmodel.png
[udf-manage-viewmodel]: erd_diagrams/udf_view_model_1.png
[udf-assign-viewmodel]: erd_diagrams/udf_view_model_2.png

