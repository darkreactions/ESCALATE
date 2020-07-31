[![Contributors][contributors-shield]][contributors-url]
[![Commits][commits-shield]][commits-url]
[![Last Commit][lastcommit-shield]][lastcommit-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

<!-- PROJECT LOGO -->
<br />
<p align="center">
  <a href="https://github.com/darkreactions/ESCALATE">
    <img src="../data_model/images/Escalate_B-04.png" alt="Logo" width="250 height="100">
  </a>
  <h1 align="center">ESCALATE v3</h1>
  <p align="center">
   Django Project README
    <br />
        <a href="https://github.com/darkreactions/ESCALATE/blob/master/escalate/README.md"><strong>ESCALATE Django Technical Docs</strong></a>
    <br />
  </p>
  
</p>

# Table of Contents

* [Introduction](#introduction)
* [Overview](#overview)
* [Core App](#core_app)
* [Rest API](#rest_api)

<!-- ******************* Introduction ****************** -->
<a name="introduction"></a>
# Introduction

This document describes the structure and components of the Django site and how it relates to the Postgres Data Model described [here](../data_model/TECHNICAL.md)

<br/>


<!-- ******************* Overview ****************** -->
<a name="overview"></a>
# Overview
The ESCALATE Django app contains:
1. `core` app - Site for managing and accessing data in Postgres
2. `rest_api` app - Rest API built on Django models defined in `core`

## Terminology
Terms used throughout this document may refer to different concepts in other systems. Unless specified, all terms used here refers to the Django ecosystem. Some examples are:

1. Views
    - `view` in Django refers to the Python code that renders a page
    - `view` also refers to a PostgreSQL database function that queries the database in different ways, more details [here](https://www.postgresqltutorial.com/postgresql-views/). These views will be referred to as `postgres view`

2. Models
    - `model` in Django refers to the database model
    - `model` may also refer to a machine learning model, which can be referred to as `ML model`

<!-- ******************* Core App ****************** -->
<a name="core_app"></a>
# Core App

## Models
This section describes all the models implemented

### Django models
These models are defined in `./core/app_tables.py`
1. CustomUser - Inherited from `django.contrib.auth.models.AbstractUser`

### PostgreSQL models
These models are defined in `./core/view_tables.py`. They track the postgres views defined in the database. These views do not directly access database tables hence they are all set to `managed = False`. Postgres views are defined [here](../data_model/TECHNICAL.md).

|  | Model Name | Postgres view |
| --- | --- | --- |
1.| Actor | `vw_actor`
2.| Inventory | `vw_inventory`
3.| InventoryMaterial | `vw_inventory_material`
4.| LatestSystemtool | `vw_systemtool`
5.| SystemtoolType | `vw_systemtool_type`
6.| Calculation | `vw_calculation`
7.| CalculationDef | `vw_calculation_def`
8.| Material | `vw_material`
9.| MaterialCalculationJson | `vw_material_calculation_json`
10.| MaterialRefnameDef | `vw_material_refname_def`
11.| MaterialType | `vw_material_type`
12.| Note | `vw_note`
13.| Note_x | `note_x`
14.| Organization | `vw_organization`
15.| Person | `vw_person`
16.| Status | `vw_status`
17.| Tag | `vw_tag`
18.| Tag_X | `vw_tag_x`
19.| TagType | `vw_tag_type`
20.| Edocument | `vw_edocument` 
21.| ExperimentMeasureCalculation | `vw_experiment_measure_calculation_json`
22.| UdfDef | `vw_udf_def`

<a name="rest_api"></a>
# Rest API