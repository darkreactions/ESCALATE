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
Discussion how this stuff all relates together...

[![Schema Detail][schema-detail]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/escalate_erd_physicalmodel.pdf)

**Primary Keys and Constraints**

```
ALTER TABLE organization 
ADD CONSTRAINT "pk_organization_organization_id" PRIMARY KEY (organization_id);
CREATE INDEX "ix_organization_parent_path" ON organization USING GIST (parent_path);
CREATE INDEX "ix_organization_parent_id" ON organization (parent_id);

ALTER TABLE person 
	ADD CONSTRAINT "pk_person_person_id" PRIMARY KEY (person_id);

ALTER TABLE systemtool 
	ADD CONSTRAINT "pk_systemtool_systemtool_id" PRIMARY KEY (systemtool_id),
	ADD CONSTRAINT "un_systemtool" UNIQUE (systemtool_name, systemtool_type_id, ver, organization_id);

ALTER TABLE systemtool_type 
	ADD CONSTRAINT "pk_systemtool_systemtool_type_id" PRIMARY KEY (systemtool_type_id);

ALTER TABLE actor 
	ADD CONSTRAINT "pk_actor_id" PRIMARY KEY (actor_id);
CREATE UNIQUE INDEX "un_actor" ON actor (coalesce(person_id,-1), coalesce(organization_id,-1), coalesce(systemtool_id,-1) );

ALTER TABLE material 
	ADD CONSTRAINT "pk_material_material_id" PRIMARY KEY (material_id);
CREATE INDEX "ix_material_parent_path" ON material USING GIST (parent_path);
CREATE INDEX "ix_material_parent_id" ON material (parent_id);

ALTER TABLE material_type 
	ADD CONSTRAINT "pk_material_type_material_type_id" PRIMARY KEY (material_type_id);

ALTER TABLE material_type_x 
	ADD CONSTRAINT "pk_material_type_x_material_type_x_id" PRIMARY KEY (material_type_x_id),
	ADD CONSTRAINT "un_material_type_x" UNIQUE (material_id, material_type_id);

ALTER TABLE material_refname 
	ADD CONSTRAINT "pk_material_refname_material_refname_id" PRIMARY KEY (material_refname_id),
	ADD CONSTRAINT "un_material_refname" UNIQUE (description, material_refname_type);

ALTER TABLE material_refname_x 
	ADD CONSTRAINT "pk_material_refname_x_material_refname_x_id" PRIMARY KEY (material_refname_x_id),
	ADD CONSTRAINT "un_material_refname_x" UNIQUE (material_id, material_refname_id);

ALTER TABLE m_descriptor_class 
	ADD CONSTRAINT "pk_m_descriptor_class_m_descriptor_class_id" PRIMARY KEY (m_descriptor_class_id);

ALTER TABLE m_descriptor_def 
	ADD CONSTRAINT "pk_m_descriptor_m_descriptor_def_id" PRIMARY KEY (m_descriptor_def_id),
	ADD CONSTRAINT "un_m_descriptor_def" UNIQUE (actor_id, calc_definition);

ALTER TABLE m_descriptor
	ADD CONSTRAINT "pk_m_descriptor_m_descriptor_id" PRIMARY KEY (m_descriptor_id),
	ADD CONSTRAINT "un_m_descriptor" UNIQUE (parent_id, m_descriptor_material_in, m_descriptor_material_type_in, m_descriptor_def_id);
CREATE INDEX "ix_m_descriptor_parent_path" ON m_descriptor USING GIST (parent_path);
CREATE INDEX "ix_m_descriptor_parent_id" ON m_descriptor (parent_id);

ALTER TABLE inventory 
	ADD CONSTRAINT "pk_inventory_inventory_id" PRIMARY KEY (inventory_id),
	ADD CONSTRAINT "un_inventory" UNIQUE (material_id, actor_id, create_date);

ALTER TABLE measure 
	ADD CONSTRAINT "pk_measure_measure_id" PRIMARY KEY (measure_id),
	ADD CONSTRAINT "un_measure" UNIQUE (measure_uuid);

ALTER TABLE measure_x 
	ADD CONSTRAINT "pk_measure_x_measure_x_id" PRIMARY KEY (measure_x_id),
	ADD CONSTRAINT "un_measure_x" UNIQUE (ref_measure_uuid, measure_uuid);

 ALTER TABLE measure_type 
	ADD CONSTRAINT "pk_measure_type_measure_type_id" PRIMARY KEY (measure_type_id);

ALTER TABLE note 
	ADD CONSTRAINT "pk_note_note_id" PRIMARY KEY (note_id);

ALTER TABLE edocument 
	ADD CONSTRAINT "pk_edocument_edocument_id" PRIMARY KEY (edocument_id);

ALTER TABLE edocument_x 
	ADD CONSTRAINT "pk_edocument_x_edocument_x_id" PRIMARY KEY (edocument_x_id),
	ADD CONSTRAINT "un_edocument_x" UNIQUE (ref_uuid, edocument_id);

ALTER TABLE tag 
	ADD CONSTRAINT "pk_tag_tag_id" PRIMARY KEY (tag_id),
	ADD CONSTRAINT "un_tag" UNIQUE (tag_uuid);;

ALTER TABLE tag_x 
	ADD CONSTRAINT "pk_tag_x_tag_x_id" PRIMARY KEY (tag_x_id),
	ADD CONSTRAINT "un_tag_x" UNIQUE (ref_tag_uuid, tag_uuid);

ALTER TABLE tag_type 
	ADD CONSTRAINT "pk_tag_tag_type_id" PRIMARY KEY (tag_type_id);

ALTER TABLE status 
	ADD CONSTRAINT "pk_status_status_id" PRIMARY KEY (status_id);
```


<br/>

<!-- ******************* Functions ****************** -->
<a name="functions"></a>
## Functions

**isdate(str varchar)**<br/>
if str can be cast to a date, then return TRUE, else FALSE

```
CREATE OR REPLACE FUNCTION isdate ( txt VARCHAR ) RETURNS BOOLEAN AS $$ BEGIN
		perform txt :: DATE;
	RETURN TRUE;
	EXCEPTION 
	WHEN OTHERS THEN
		RETURN FALSE;
END;
$$ LANGUAGE plpgsql;
```
<br/>

**trigger_set_timestamp()**<br/>
update the mod_dt (modify date) column with current date with timezone

```
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.mod_date = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```



<br/>

<!-- ******************* Views ****************** -->
<a name="views"></a>
## Views
Below are a list of the views with highlevel description, followed by column names returned by view. Views are named using the following structure: 

```
vw_[filter]_[table1]_[table2]_[tablen]
```
where *filter* indicates a 'where/having clause' applied and the [table] entities are listed in order of preponderance.

e.g. __vw\_latest\_systemtool__ returns records from the **systemtool** table with a 'filter' or where clause selecting only 'active' status records. 
<br/><br/>

__vw_actor__<br/>
_returns set of all **actor** records, direct and linked: **organization**, **person**, **systemtool**, **status**, **note**, **edocument**_ <br/>
columns returned:

```
actor_uuid, actor_id, organization_id, person_id, systemtool_id, actor_description, actor_status, actor_notetext, actor_document, actor_doc_type, org_full_name, org_short_name, per_lastname, per_firstname, person_lastfirst, person_org, systemtool_name, systemtool_description, systemtool_type, systemtool_vendor, systemtool_model, systemtool_serial, systemtool_version, systemtool_org 
```
<br/>

__vw\_latest\_systemtool__<br/>
_returns set of most recent / latest version **systemtool** records_ <br/>
columns returned:

```
systemtool_id, systemtool_uuid, systemtool_name, description, systemtool_type_id, vendor, model, serial, ver, organization_id, note_id, add_date,mod_date
```
<br/>

__vw\_latest\_systemtool\_actor__<br/>
_returns set of **actor** records that are parents of latest *systemtool* records_ <br/>
columns returned:

```
actor_id, actor_uuid, person_id, organization_id, systemtool_id, description, status_id, note_id, add_date, mod_date
```
<br/>


__vw\_m\_descriptor\_def__<br/>
_returns set of **descriptor\_def** and associated **actor** records_ <br/>
columns returned:

```
m_descriptor_def_id, m_descriptor_def_uuid, short_name, calc_definition, description, actor_id, actor_org, actor_systemtool_name, actor_systemtool_version
```
<br/>


__vw\_m\_descriptor__<br/>
_returns set of **descriptor** and associated **descriptor** parent records_ <br/>
columns returned:

```
m_descriptor_id, m_descriptor_uuid, material_ref, material_ref_type, descriptor_in, descriptor_type_in, create_date, num_valarray_out, blob_val_out, blob_type_out, m_descriptor_def_id, m_descriptor_def_uuid, short_name, calc_definition, description, actor_id, actor_org, actor_systemtool_name, actor_systemtool_version, status
```
<br/>

<!-- ******************* Upserts ****************** -->
<a name="upserts"></a>
## Upserts
```
upsert up() 
```

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
