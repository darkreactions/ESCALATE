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
* [Upserts](#upserts)
* [Authors](#authors)
* [License](#license)
* [Acknowledgements](#acknowledgements)

<br/>

<!-- ******************* Introduction ****************** -->
<a name="introduction"></a>
## Introduction

These instructions will get you a copy of the database up and running on your local machine (or container) for development and testing purposes. 

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

```
val_type AS ENUM ('int', 'array_int', 'num', 'array_num', 'text', 'array_text', 'blob_text', 'blob_svg', 'blob_jpg', 'blob_png', 'blob_xrd')

val AS (
	v_type val_type,
	v_text varchar,
	v_text_array varchar[],
	v_int int8,
	v_int_array int8[],
	v_num double precision,
	v_num_array double precision[],
	v_blob bytea)
```
<br/>


### Core Tables (non ETL)

```
actor
actor_pref
calculation
calculation_class
calculation_def
calculation_eval
edocument
edocument_x
escalate_change_log
escalate_version
experiment
files
inventory
material
material_refname
material_refname_type
material_refname_x
material_type
material_type_x
measure
measure_type
measure_x
note
organization
person
status
sys_audit
systemtool
systemtool_type
tag
tag_type
tag_x

```
<br/>

### Primary Keys and Constraints

```
CREATE INDEX "ix_sys_audit_relid" ON sys_audit(relid);
CREATE INDEX "ix_sys_audit_action_tstamp_tx_stm" ON sys_audit(action_tstamp_stm);
CREATE INDEX "ix_sys_audit_action" ON sys_audit(action);

ALTER TABLE organization 
	ADD CONSTRAINT "pk_organization_organization_uuid" PRIMARY KEY (organization_uuid),
	ADD CONSTRAINT "un_organization" UNIQUE (full_name);
	CREATE INDEX "ix_organization_parent_path" ON organization USING GIST (parent_path);
	CREATE INDEX "ix_organization_parent_uuid" ON organization (parent_uuid);
CLUSTER organization USING "pk_organization_organization_uuid";

ALTER TABLE person 
ADD CONSTRAINT "pk_person_person_uuid" PRIMARY KEY (person_uuid);
CLUSTER person USING "pk_person_person_uuid";

ALTER TABLE systemtool 
	ADD CONSTRAINT "pk_systemtool_systemtool_uuid" PRIMARY KEY (systemtool_uuid),
	ADD CONSTRAINT "un_systemtool" UNIQUE (systemtool_name, systemtool_type_uuid, vendor_organization_uuid, ver);
CLUSTER systemtool USING "pk_systemtool_systemtool_uuid";

ALTER TABLE systemtool_type 
	ADD CONSTRAINT "pk_systemtool_systemtool_type_uuid" PRIMARY KEY (systemtool_type_uuid);
CLUSTER systemtool_type USING "pk_systemtool_systemtool_type_uuid";

ALTER TABLE actor 
	ADD CONSTRAINT "pk_actor_uuid" PRIMARY KEY (actor_uuid);
	CREATE UNIQUE INDEX "un_actor" ON actor (coalesce(person_uuid,null), coalesce(organization_uuid,null), coalesce(systemtool_uuid,null) );
CLUSTER actor USING "pk_actor_uuid";

ALTER TABLE actor_pref 
	ADD CONSTRAINT "pk_actor_pref_uuid" PRIMARY KEY (actor_pref_uuid);
CLUSTER actor_pref USING "pk_actor_pref_uuid";

ALTER TABLE experiment ADD 
	CONSTRAINT "pk_experimentl_experiment_uuid" PRIMARY KEY (experiment_uuid);
	CREATE INDEX "ix_experiment_parent_path" ON experiment USING GIST (parent_path);
	CREATE INDEX "ix_experiment_parent_uuid" ON experiment (parent_uuid);
CLUSTER experiment USING "pk_experimentl_experiment_uuid";

ALTER TABLE material ADD 
	CONSTRAINT "pk_material_material_uuid" PRIMARY KEY (material_uuid);
	CREATE INDEX "ix_material_parent_path" ON material USING GIST (parent_path);
	CREATE INDEX "ix_material_parent_uuid" ON material (parent_uuid);
CLUSTER material USING "pk_material_material_uuid";

ALTER TABLE material_type ADD 
	CONSTRAINT "pk_material_type_material_type_uuid" PRIMARY KEY (material_type_uuid);
CLUSTER material_type USING "pk_material_type_material_type_uuid";

ALTER TABLE material_type_x 
	ADD CONSTRAINT "pk_material_type_x_material_type_x_uuid" PRIMARY KEY (material_type_x_uuid),
	ADD CONSTRAINT "un_material_type_x" UNIQUE (ref_material_uuid, material_type_uuid);
CLUSTER material_type_x USING "pk_material_type_x_material_type_x_uuid";

ALTER TABLE material_refname 
	ADD CONSTRAINT "pk_material_refname_material_refname_uuid" PRIMARY KEY (material_refname_uuid),
	ADD CONSTRAINT "un_material_refname" UNIQUE (description, material_refname_type_uuid);
CLUSTER material_refname USING "pk_material_refname_material_refname_uuid";

ALTER TABLE material_refname_x 
	ADD CONSTRAINT "pk_material_refname_x_material_refname_x_uuid" PRIMARY KEY (material_refname_x_uuid),
	ADD CONSTRAINT "un_material_refname_x" UNIQUE (material_uuid, material_refname_uuid);
CLUSTER material_refname_x USING "pk_material_refname_x_material_refname_x_uuid";

ALTER TABLE material_refname_type 
	ADD CONSTRAINT "pk_material_refname_type_material_refname_type_uuid" PRIMARY KEY (material_refname_type_uuid);
CLUSTER material_refname_type USING "pk_material_refname_type_material_refname_type_uuid";

ALTER TABLE calculation_class ADD 
	CONSTRAINT "pk_calculation_class_calculation_class_uuid" PRIMARY KEY (calculation_class_uuid);
CLUSTER calculation_class USING "pk_calculation_class_calculation_class_uuid";

ALTER TABLE calculation_def 
	ADD CONSTRAINT "pk_calculation_calculation_def_uuid" PRIMARY KEY (calculation_def_uuid),
	ADD CONSTRAINT "un_calculation_def" UNIQUE (actor_uuid, short_name, calc_definition);	
CLUSTER calculation_def USING "pk_calculation_calculation_def_uuid";

ALTER TABLE calculation
	ADD CONSTRAINT "pk_calculation_calculation_uuid" PRIMARY KEY (calculation_uuid),
	ADD CONSTRAINT "un_calculation" UNIQUE (calculation_def_uuid, in_val, in_opt_val);
CLUSTER calculation USING "pk_calculation_calculation_uuid";

ALTER TABLE calculation_eval
	ADD CONSTRAINT "pk_calculation_eval_calculation_eval_id" PRIMARY KEY (calculation_eval_id),
	ADD CONSTRAINT "un_calculation_eval" UNIQUE (calculation_def_uuid, in_val, in_opt_val);
CLUSTER calculation_eval USING "pk_calculation_eval_calculation_eval_id";

ALTER TABLE inventory 
	ADD CONSTRAINT "pk_inventory_inventory_uuid" PRIMARY KEY (inventory_uuid),
	ADD CONSTRAINT "un_inventory" UNIQUE (material_uuid, actor_uuid, create_date);
CLUSTER inventory USING "pk_inventory_inventory_uuid";

ALTER TABLE measure 
	ADD CONSTRAINT "pk_measure_measure_uuid" PRIMARY KEY (measure_uuid),
	ADD CONSTRAINT "un_measure" UNIQUE (measure_uuid);
 CLUSTER measure USING "pk_measure_measure_uuid";

ALTER TABLE measure_x 
	ADD CONSTRAINT "pk_measure_x_measure_x_uuid" PRIMARY KEY (measure_x_uuid),
	ADD CONSTRAINT "un_measure_x" UNIQUE (ref_measure_uuid, measure_uuid);
CLUSTER measure_x USING "pk_measure_x_measure_x_uuid";

 ALTER TABLE measure_type ADD 
	CONSTRAINT "pk_measure_type_measure_type_uuid" PRIMARY KEY (measure_type_uuid);
 CLUSTER measure_type USING "pk_measure_type_measure_type_uuid";

ALTER TABLE note ADD 
	CONSTRAINT "pk_note_note_uuid" PRIMARY KEY (note_uuid);
CLUSTER note USING "pk_note_note_uuid";

ALTER TABLE edocument 
	ADD CONSTRAINT "pk_edocument_edocument_uuid" PRIMARY KEY (edocument_uuid),
	ADD CONSTRAINT "un_edocument" UNIQUE (edocument_title, edocument_filename, edocument_source);
CLUSTER edocument USING "pk_edocument_edocument_uuid";

ALTER TABLE edocument_x 
	ADD CONSTRAINT "pk_edocument_x_edocument_x_uuid" PRIMARY KEY (edocument_x_uuid),
	ADD CONSTRAINT "un_edocument_x" UNIQUE (ref_edocument_uuid, edocument_uuid);
CLUSTER edocument_x USING "pk_edocument_x_edocument_x_uuid";

ALTER TABLE tag 
	ADD CONSTRAINT "pk_tag_tag_uuid" PRIMARY KEY (tag_uuid),
	ADD CONSTRAINT "un_tag" UNIQUE (tag_uuid);;
CLUSTER tag USING "pk_tag_tag_uuid";

ALTER TABLE tag_x 
	ADD CONSTRAINT "pk_tag_x_tag_x_uuid" PRIMARY KEY (tag_x_uuid),
	ADD CONSTRAINT "un_tag_x" UNIQUE (ref_tag_uuid, tag_uuid);
CLUSTER tag_x USING "pk_tag_x_tag_x_uuid";

ALTER TABLE tag_type ADD 
	CONSTRAINT "pk_tag_tag_type_uuid" PRIMARY KEY (tag_type_uuid);
CLUSTER tag_type USING "pk_tag_tag_type_uuid";

ALTER TABLE status ADD 
	CONSTRAINT "pk_status_status_uuid" PRIMARY KEY (status_uuid);
CLUSTER status USING "pk_status_status_uuid";
```


<br/>

<!-- ******************* Functions ****************** -->
<a name="functions"></a>
## Functions
List of callable and trigger functions (see SQL code for details):

```
trigger_set_timestamp()
if_modified_func()
audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, ignored_cols text[]) RETURNS void
audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean) RETURNS void
read_file_utf8(path CHARACTER VARYING) RETURNS TEXT
read_file(path CHARACTER VARYING) RETURNS TEXT
isdate ( txt VARCHAR ) RETURNS BOOLEAN
read_dirfiles ( PATH CHARACTER VARYING ) RETURNS BOOLEAN
get_material_uuid_bystatus (p_status_array varchar[], p_null_bool boolean)
   RETURNS TABLE (
		material_uuid uuid,
		material_description varchar)
get_material_nameref_bystatus (p_status_array varchar[], p_null_bool boolean)
   RETURNS TABLE (
       material_uuid uuid,
		material_refname varchar,
		material_refname_type varchar)
get_material_bydescr_bystatus (p_descr varchar, p_status_array VARCHAR[], p_null_bool BOOLEAN)
   RETURNS TABLE (
      material_uuid uuid,
		material_description varchar,
		material_refname_uuid uuid,
		material_refname_description VARCHAR,
		material_refname_type varchar)
get_material_type (p_material_uuid uuid) RETURNS varchar[]
get_actor ()
   RETURNS TABLE (
       actor_uuid uuid,
		organization_uuid int8,
		person_uuid int8,
		systemtool_uuid int8,
		actor_description varchar,
		actor_status varchar,
		notetext varchar,
		org_description varchar,
		person_lastfirst varchar,
		systemtool_name varchar,
		systemtool_version varchar)
get_calculation_def (p_descr VARCHAR[])
   RETURNS TABLE (
		calculation_def_uuid uuid,
		short_name varchar,
		systemtool_name varchar,
		calc_definition varchar,
		description varchar,
		in_type val_type,
		out_type val_type,
		systemtool_version varchar)
get_calculation (p_material_refname varchar, p_descr VARCHAR[] = null)
   RETURNS TABLE (calculation_uuid uuid) 
get_val (p_in val) returns text
get_chemaxon_directory ( p_systemtool_uuid uuid, p_actor_uuid uuid ) RETURNS TEXT
get_chemaxon_version ( p_systemtool_uuid uuid, p_actor_uuid uuid ) RETURNS TEXT
run_descriptor (p_descriptor_def_uuid uuid, p_alias_name varchar, p_command_opt varchar, p_actor_uuid uuid) RETURNS BOOLEAN
load_mol_images ( p_systemtool_uuid uuid, p_actor_uuid uuid ) RETURNS bool
get_charge_count ( p_mol_smiles varchar ) RETURNS int
math_op (p_in_num numeric, p_op text, p_in_opt_num numeric default null) returns numeric
delete_organization (_fulln varchar) RETURNS int8
upsert_organization() RETURNS TRIGGER

```

<br/>

<!-- ******************* Views ****************** -->
<a name="views"></a>
## Views
Below are a list of the views with high-level description, followed by column names returned by view. Views are named using the following structure: 

### Available Views

```
sys_audit_tableslist
vw_actor
vw_calculation
vw_calculation_def
vw_edocument
vw_experiment_measure_calculation
vw_experiment_measure_calculation_json
vw_inventory
vw_inventory_material
vw_latest_systemtool
vw_latest_systemtool_raw
vw_material
vw_material_calculation_json
vw_material_calculation_raw
vw_material_raw
vw_material_refname_type
vw_material_type
vw_note
vw_organization
vw_person
vw_status
vw_systemtool_type
vw_tag
vw_tag_type

```
<br/>


Views provide full **CRUD/Restful API** or **Read/Get** functionality<br/>
(C)reate/Post, (R)ead/Get, (U)pdate/Put, (D)elete/Delete
Below the columns returned or updateable for each of the views:


__vw\_organization__<br/>
_read/GET_ <br/>

```
organization_uuid, description, full_name, short_name, address1, address2, city, state_province, zip, country, website_url, phone, parent_uuid, parent_org_full_name, add_date, mod_date, note_uuid, notetext, edocument_uuid, edocument_descr, tag_uuid, tag_short_descr
```
_upsert/POST/PUT/DELETE_ <br/>

```
description, full_name, short_name, address1, address2, city, state_province, zip, country, website_url, phone, parent_uuid, notetext
```
<br/>

__vw\_person__<br/>
_read/GET_ <br/>

```
person_uuid, first_name, last_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, add_date, mod_date, organization_uuid, organization_full_name, note_uuid, notetext, edocument_uuid, edocument_descr, tag_uuid, tag_short_descr
```
_upsert/POST/PUT/DELETE_ <br/>

```
last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid, notetext
```

<br/>

__vw\_latest_systemtool__<br/>
_read/GET_ <br/>

```
systemtool_uuid, systemtool_name, description, vendor_organization_uuid, organization_fullname, systemtool_type_uuid, systemtool_type_description, model, serial, ver, note_uuid, notetext, actor_uuid, actor_description, add_date, mod_date
```
_upsert/POST/PUT/DELETE_ <br/>

```
systemtool_name, description, systemtool_type_uuid, vendor_organization_uuid, model, serial, ver, notetext
```


<br/>

__vw\_systemtool_type__<br/>
_read/GET_ <br/>

```
systemtool_type_uuid, description, note_uuid, notetext, add_date, mod_date
```
_upsert/POST/PUT/DELETE_ <br/>

```
description, notetext
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


__vw_actor__<br/>
_read/GET_<br/>

```
actor_uuid, actor_id, organization_id, person_id, systemtool_id, actor_description, actor_status, actor_notetext, actor_document, actor_doc_type, org_full_name, org_short_name, per_lastname, per_firstname, person_lastfirst, person_org, systemtool_name, systemtool_description, systemtool_type, systemtool_vendor, systemtool_model, systemtool_serial, systemtool_version, systemtool_org 
```
<br/>

__vw\_calculation__<br/>
_read/GET_

```
calculation_uuid, in_val, in_val_type, in_val_value, in_val_unit, in_val_edocument_uuid, in_opt_val, in_opt_val_type, in_opt_val_value, in_opt_val_unit, in_opt_val_edocument_uuid, out_val, out_val_type, out_val_value, out_val_unit, out_val_edocument_uuid, calculation_alias_name, create_date, status, actor_descr, notetext, calculation_def_uuid, short_name, calc_definition, description, in_type, out_type, systemtool_uuid, systemtool_name, systemtool_type_description, systemtool_vendor_organization, systemtool_version, actor_uuid, actor_description
```
<br/>

__vw\_calculation\_def__<br/>
_read/GET_

```
calculation_def_uuid, short_name, calc_definition, description, actor_id, actor_org, actor_systemtool_name, actor_systemtool_version
```
<br/>


__vw\_edocument__<br/>
_read/GET_

```
edocument_uuid, edocument_title, edocument_description, edocument_filename, edocument_source, edocument_type, edocument, actor_uuid, actor_description
```
<br/>


__vw\_inventory__<br/>
_read/GET_

```
inventory_uuid, description inventory_description, part_no, onhand_amt, unit, create_date, expiration_date, inventory_location, status, material_uuid, material_description, actor_uuid, description, edocument_uuid, edocument_description, note_uuid, notetext
```
<br/>

__vw\_inventory\_material__<br/>
_read/GET_

```
inventory_uuid, inventory_description, inventory_part_no, inventory_onhand_amt, inventory_unit, inventory_create_date, inventory_expiration_date, inventory_location, inventory_status, actor_uuid, actor_description, org_full_name, material_uuid, material_status, material_create_date, material_name, material_abbreviation, material_inchi, material_inchikey, material_molecular_formula, material_smiles
```
<br/>

__vw\_material__<br/>
_read/GET_

```
material_uuid, material_status, create_date, Abbreviation, Chemical_Name, InChI, InChIKey, Molecular_Formula, SMILES
```
<br/>

__vw\_material\_calculation\_raw__<br/>
_read/GET_

```
material_uuid, material_status, material_create_date, abbreviation, chemical_name, inchi, inchikey, molecular_formula, smiles, calculation_uuid, in_val, in_val_type, in_val_value, in_val_unit, in_val_edocument_uuid, in_opt_val, in_opt_val_type, in_opt_val_value, in_opt_val_unit, in_opt_val_edocument_uuid, out_val, out_val_type, out_val_value, out_val_unit, out_val_edocument_uuid, calculation_alias_name, calculation_create_date, status, actor_descr, notetext, calculation_def_uuid, short_name, calc_definition, description, in_type, out_type, systemtool_uuid, systemtool_name, systemtool_type_description, systemtool_vendor_organization, systemtool_version, actor_uuid, actor_description
```
<br/>

__vw\_material\_raw__<br/>
_read/GET_

```
material_uuid, material_description, material_status, material_type_description, material_refname_type, material_refname_description, material_refname_type_uuid, material_create_date, note_uuid, notetext
```
<br/>

__vw\_vw\_material\_refname\_type__<br/>
_read/GET_

```
material_refname_type_uuid, description, notetext
```
<br/>

__vw\_vw\_material\_type__<br/>
_read/GET_

```
material_type_uuid, description, notetext
```
<br/>

__vw\_vw\_note__<br/>
_read/GET_

```
note_uuid, notetext, add_date, mod_date, edocument_uuid, edocument_title, edocument_description, edocument_filename, edocument_source, edocument_type, actor_uuid, actor_description
```
<br/>

__vw\_vw\_status__<br/>
_read/GET_

```
status_uuid, description, add_date, mod_date
```
<br/>

__vw\_vw_tag__<br/>
_read/GET_

```
tag_uuid, tag_short_descr, tag_description, add_date, mod_date, tag_type_uuid, tag_type_short_descr, tag_type_description, actor_uuid, actor_description, note_uuid, notetext
```
<br/>


__vw\_vw_tag\_type__<br/>
_read/GET_

```
tag_type_uuid, short_description, description, actor_uuid, actor_description, add_date, mod_date
```
<br/>

<br/>

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
