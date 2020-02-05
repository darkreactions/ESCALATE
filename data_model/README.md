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
[![Contributors][contributors-shield]][contributors-url]
[![Commits][commits-shield]][commits-url]
[![Last Commit][lastcommit-shield]][lastcommit-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/darkreactions/ESCALATE">
    <img src="images/Escalate_B-04.png" alt="Logo" width="250 height="100">
  </a>
  <h1 align="center">ESCALATE v3 Data Model</h1>
  <p align="center">
   PostgreSQL (v11/12) physical data model as part of the ESCALATE v3 application 
    <br />
    <a href="https://github.com/darkreactions/ESCALATE/blob/master/data_model/TECHNICAL.md"><strong>Check out the ESCALATE v3 Data Model Technical Doc</strong></a>
    <br />
    <br />
  </p>
</p>


## Getting Started

These instructions will get you a copy of the database up and running on your local machine (or container) for development and testing purposes. 

### Prerequisites

Minimal software you need in place to instatiate the model

```
postgreSQL v11 / v12
```

### Optional

Optional software for implementing this model:

[![dockerlogo][docker-logo]][dockerinstall-url]
&ensp;[![pgadminlogo][pgadmin-logo]][pgadmininstall-url]

<br/>
## Instantiating the Model (w/ experimental data)

This model can be instantiated into a local postgreSQL server or into a docker container. As there is extensive documentation and instructions to install postgreSQL and docker, it will not be covered in this README.

In addition to the environments in which this model can reside (e.g. local or docker), it can be created (restored) from a pg_dump backup or a manual process (running descrete sql to create and load tables). What follows are the steps to instantiate the ESCALATE v3 data model populated with experimental perovskite data from a backup and manual SQL.

But before the ESCALATE data model can be instantiated, the first step is to configure your postgreSQL environment.

### PostgreSQL configuration
**Step 1** -  Create a database named 'escalate' with owner named 'escalate'. Use pgAdmin to create the database or execute the following SQL:

```
CREATE DATABASE escalate OWNER escalate;
```
**Step 2** -  Create schema 'dev' using pgAdmin or executing the following SQL:

```
CREATE SCHEMA dev;
```
**Step 3** -  Add required extensions (collection of functions) to the schema:

```
CREATE EXTENSION if not exists ltree;
CREATE EXTENSION if not exists tablefunc;
CREATE EXTENSION if not exists "uuid-ossp";
```
<br/>
### Instantiation (restore) from *pg_dump* utility
**Option 1** -  restore into a local postgreSQL environment
using the latest 'bak' file in the repo's backup folder. This assumes a local directory named backup

```
pg_restore -d escalate -c -C -U escalate /backup/escalate-postgres_docker_backup.bak
```
**Option 2** -  restore into a docker container
using the latest 'bak' file in the repo's backup folder. This assumes the following: 1) the docker container is named: escalate-postgres and 2) the bak file has been moved to a folder in the container

```
docker exec escalate-postgres pg_restore -d escalate -c -C -U escalate /var/lib/postgres/escalate-postgres_docker_backup.bak
```
<br/>
### Instantiation from SQL
Running the SQL below, in order, will create the tables, keys and contraints, load load tables, and populate core tables.


**Step 1** - Populate the load tables with existing perovskite experimental data using SQL code found in the repo 'sql_dataload' subdirectory:

```
prod_dataload_perov_desc.sql
prod_dataload_perov_desc_def.sql
prod_dataload_perov_mol_image.sql
prod_dataload_chem_inventory.sql
prod_dataload_hc_inventory.sql
prod_dataload_lbl_inventory.sql
```

**Step 2** - Create the core model tables, primary keys, foreign keys and constraints and views using SQL code found in the repo 'sql_core' subdirectory:

```
prod_create_tables.sql
```

**Step 3** - Populate the core tables:

```
prod_initialize_org_per_sys_actor.sql
prod_load_functions.sql
prod_update_1_material.sql
prod_update_2_inventory.sql
prod_update_3_descriptor.sql
```

End with an example of getting some data out of the system or using it for a little demo

<br/>

## Validating the Tables & Data

To ensure the database tables have been created and populated properly, run the following SQL scripts and check results.


Record count of selected core tables:

```
select count(*) from actor;
> 14

select count(*) from material;
> 77
> 
select count(*) from inventory;
> 102
> 
select count(*) from m_descriptor;
> 5544
```

Check view vw_actor:

```
select systemtool_name, systemtool_description, systemtool_version from vw_actor where systemtool_vendor = 'ChemAxon';
 
> standardize	Chemical standardizer	19.27.0
> cxcalc	Chemical descriptor calculator	19.27.0
> molconvert	Chemical converter	19.27.0
> generatemd	Chemical fingerprint calculator	19.6.0
```

Check view vw_m_descriptor_def:

```
select short_name, calc_definition, description, actor_org, actor_systemtool_name, actor_systemtool_version from vw_m_descriptor_def where short_name = 'atomcount_c';;
 
> atomcount_c	atomcount -z 6	number of carbon atoms in the molecule 	ChemAxon	cxcalc	19.27.0
```

<br/>

## Built With

* [postgreSQL 12](https://www.postgresql.org) - Database
* [pgAdmin 4](https://www.pgadmin.org) - Database management tool
* [Navicat](https://www.navicat.com/en/) - Used to generate model and SQL code

<br/>

## Authors

* **Gary Cattabriga** - *Initial work* - [ESCALATE](https://github.com/gcatabr1)

See also the list of [contributors](https://github.com/darkreactions/ESCALATE/graphs/contributors) who participated in this project.

<br/>

## License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details

<br/>

## Acknowledgments
* [DARPA SD2 program](https://www.darpa.mil/program/synergistic-discovery-and-design)
* [Haverford College](https://www.haverford.edu)
* [Lawrence Berkely National Lab](https://www.lbl.gov)

<br/>

<!-- MARKDOWN LINKS & IMAGES -->
[contributors-shield]: https://img.shields.io/github/contributors/darkreactions/ESCALATE
[contributors-url]: https://github.com/darkreactions/ESCALATE/graphs/contributors
[lastcommit-shield]: https://img.shields.io/github/last-commit/darkreactions/ESCALATE
[lastcommit-url]: https://github.com/darkreactions/ESCALATE/graphs/commit-activity
[issues-shield]: https://img.shields.io/github/issues/darkreactions/ESCALATE
[issues-url]: https://github.com/darkreactions/ESCALATE/issues
[license-shield]: https://img.shields.io/github/license/darkreactions/ESCALATE
[license-url]: https://github.com/darkreactions/ESCALATE/blob/master/LICENSE
[commits-shield]: https://img.shields.io/github/commit-activity/m/darkreactions/ESCALATE
[commits-url]: https://github.com/darkreactions/ESCALATE/graphs/commit-activity
[postgresqlinstall-url]: https://www.postgresql.org/download/
[postgresql-logo]: images/postgresql_logo.png
[dockerinstall-url]: https://docs.docker.com/install/
[docker-logo]: images/docker_logo.png
[pgadmininstall-url]: https://www.pgadmin.org/download/
[pgadmin-logo]: images/pgadmin_logo.png

