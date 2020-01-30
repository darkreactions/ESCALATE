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

<!-- TABLE OF CONTENTS -->
## Table of Contents

* [Introduction](#introduction)
* [Overview](#overview)
* [Schema Detail](#schemadetail)
* [Views](#views)
* [Authors](#authors)
* [License](#license)
* [Acknowledgements](#acknowledgements)


<a name="introduction"></a>

## Introduction

These instructions will get you a copy of the database up and running on your local machine (or container) for development and testing purposes. 



<br/>
<a name="overview"></a>

## Overview
Talk about the core entities...

[![Schema Highlevel][schema-highlevel]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/escalatev3_schema_highlevel.png)

<br/>
<a name="schemadetail"></a>

## Schema: Detail
Discussion how this stuff all relates together...

[![Schema Detail][schema-detail]](https://github.com/darkreactions/ESCALATE/blob/master/data_model/erd_diagrams/escalate_erd_physicalmodel.pdf)

```
Keys, fk 
```

<br/>
<a name="views"></a>

## Views
Below is a list of views with highlevel description, followed by column names returned by view. 

| view name| description|
| -------- |----------|
| vw\_actor| returns table of all actor information: org, person, systemtool, status, note, edocument|
| vw\_latest\_systemtool| returns systemtool records with 'active' status  |
| vw\_latest\_systemtool\_actor| returns actor records that are comprised of 'active' systemtools |
| vw\_m\_descriptor\_def| returns descriptor_def and associated actor info |
| vw\_m\_descriptor| returns descriptor info and associated parent |

<br/>

**vw_actor** columns

```
	actor_uuid
	actor_id
	organization_id
	person_id
	systemtool_id
	actor_description
	actor_status
	actor_notetext
	actor_document
	actor_doc_type
	org_full_name
	org_short_name
	per_lastname
	per_firstname
	person_lastfirst
	person_org
	systemtool_name
	systemtool_description
	systemtool_type
	systemtool_vendor
	systemtool_model
	systemtool_serial
	systemtool_version
	systemtool_org 
```
<br/>
**vw\_latest_systemtool** columns

```
  systemtool_id
  systemtool_uuid
  systemtool_name
  description
  systemtool_type_id
  vendor
  model
  serial
  ver
  organization_id
  note_id
  add_date
  mod_date
```

<br/>
<a name="authors"></a>

## Authors

* **Gary Cattabriga** - *Initial work* - [ESCALATE](https://github.com/gcatabr1)

See also the list of [contributors](https://github.com/darkreactions/ESCALATE/graphs/contributors) who participated in this project.

<br/>
<a name="license"></a>

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details

<br/>
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
