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

2. Models
    - `model` in Django refers to the database model
    - `model` may also refer to a machine learning model, which can be referred to as `ML model`

<!-- ******************* Core App ****************** -->
<a name="core_app"></a>
# Core App

## Models
These models are defined in `./core/models/view_tables/*`

1. **Action**: actual activity to be performed (by actor/person/systemtool/organization); associated with actionunits, parameters and/or calculations
2. **ActionDef**: specification of an action
3. **ActionSequence**: container of specified actions and associated action paths
4. **ActionSequenceType**: desctiption of ActionSequence
5. **ActionUnit**: measurement of action performed; contains a source and optionally a destination that the action is performed on
6. **Actor**: object that act on, or with any of the entities
7. **BaseBomMaterial**: instance of BillOfMaterials that associate inventories, vessels, and materials
8. **BillOfMaterials**: container of all materials (from inventory) that can or will be addressed in the experiment
9. **BomCompositeMaterials**: bill of materials specific to composite materials and mixtures
10. **BomMaterial**: bill of materials specific to materials
11. **BomVessel**: bill of materials specific to vessels
12. **Calculation**: actual function performing a transformation or calculation with one or more parameters
13. **CalculationDef**: specification of calculations
14. **Condition**: type of action sequence object that determines (by way of assoc. calculation) the path taken for subsequent action
15. **Contents**: defines materials contained within a vessel instance
16. **DefaultValues**: template for nominal and actual values
17. **DescriptorTemplate**: template for multiple model instance descriptors
18. **ExperimentActionSequence**: sequential order of an experiment; instance of ActionSequence
19. **ExperimentCompletedInstance**: proxy model of ExpermentInstance that contains finished experiments
20. **ExperimentInstance**: container **specifying** one or more action sequences (of actions) operating on or with one or more materials and **capturing** one or more measures and/or observables at any level of experiment detail
21. **ExperimentPendingInstance**: proxy model of ExpermentInstance that contains pending experiments
22. **ExperimentTemplate**: template that specifies experiments that can be created
23. **Edocument**: electronic document that can be defined and a file can be associated; files can be uploaded via various forms within the UI or directly through the API
24. **Inventory**: inventory template; defines owner/operator/lab associated with inventory
25. **InventoryMaterial**: instance of inventory model; collection of 'actual' materials assignable to an organization (lab)
26. **Material**:  'ideal' singleton, material can have unlimited reference names, properties and calculations (descriptors) assigned
27. **MaterialIdentifier**: descriptors for materials; can be composed of multiple definitions
28. **MaterialIdentifierDef**: individual descriptor for MaterialIdentifier
29. **MaterialType**: defines the type of material within multiple template models
30. **Measure**: observable and/or measure associated with a specific entity
31. **MeasureDef**: defines the specifcations of a Measure model
32. **MeasureType**: unit of measurement associated with Measure
33. **Mixture**: composite materials and components associated with the creation of the mixture; material types can be defined and accessed
34. **MolecularDescriptor**: descriptor for molecular materials
35. **Note**: text that can be associated with any entity
36. **Organization**: organization that act on, or with any of the entities
37. **OutcomeInstance**: container of measures that address purpose or aim of experiment
38. **OutcomeInstanceValue**: stores the nominal and actual values related to an outcome instance
39. **OutcomeTemplate**: template for outcomes; contains associated experiment and default values
40. **Parameter**: actual characterization of an activity or calculation; of which action or calculation can have zero to many
41. **ParameterDef**: specification of Parameter model
42. **Person**: personal details of an individual including association with organizations
43. **Property**: characterization of a material; of which a material can have zero to many
44. **PropertyTemplate**: template for Property instance; contains default values for property instances
45. **ReactionParameters**: quick access to specific parameters associated within an experiment
46. **Reagent**: instance of ReagentTemplate; associates a ReagentTemplate with an ExperimentInstance
47. **ReagentTemplate**: template for reagent instance
48. **ReagentMaterialTemplate**: template for reagent material instance; material type defined in MaterialType model
49. **ReagentMaterial**: instance of ReagentMaterialTemplate; associates Reagent and InventoryMaterial with ReagentMaterialTemplate
50. **ReagentMaterialValue**: nominal and actual values for a reagent material within an experiment
51. **ReagentMaterialValueTemplate**: template for reagent material value instance; material type defined in MaterialType model
52. **Status**: text describing the state or status of an entity
53. **Systemtool**: software that act on, or with any of the entities
54. **SystemtoolType**: defines type of software
55. **Tag**: short descriptive text that can be associated with any entity
56. **TagAssign**: associates a tag with a model instance
57. **TagType**: defines the type of tag
58. **Udf**: User Defined Field; For example, if we want to start tracking ‘challenge problem #’ within an experiment. Instead of creating a new column in experiment, we could define a udf(udf_def) and it’s associated value(val) type, in this case: text. Then we could allow the user (API) to create a specific instance of that udf_def, and associate it with a specific experiment, where the experiment_uuid is the ref_udf_uuid.
59. **UdfDef**: description of UDF
60. **ValueInstance**: instance of DefaultValues model; contains specific nominal and actual values and associates with the Outcome model
61. **Vessel**: template for vessel instance
62. **VesselInstance**: experiment container; child of Vessel model and defines a specific instance of that template
63. **VesselType**: describes the type of vessel for a Vessel template

<a name="rest_api"></a>
## Rest API
API endpoints are available for most models. Below are the API endpoint URLs for a local installation.

1. **action**: "http://localhost:8000/api/action/",
2. **actiondef**: "http://localhost:8000/api/action-def/",
3. **actionsequence**: "http://localhost:8000/api/action-sequence/",
4. **actionsequencetype**: "http://localhost:8000/api/action-sequence-type/",
5. **actionunit**: "http://localhost:8000/api/action-unit/",
6. **actor**: "http://localhost:8000/api/actor/",
7. **basebommaterial**: "http://localhost:8000/api/base-bom-material/",
8. **billofmaterials**: "http://localhost:8000/api/bill-of-materials/",
9. **bomcompositematerial**: "http://localhost:8000/api/bom-composite-material/",
10. **bommaterial**: "http://localhost:8000/api/bom-material/"",
11. **contents**: "http://localhost:8000/api/contents/",
12. **defaultvalues**: "http://localhost:8000/api/default-values/",
13. **descriptortemplate**: "http://localhost:8000/api/descriptor-template/",
14. **experimentactionsequence**: "http://localhost:8000/api/experiment-action-sequence/",
15. **experimentdescriptor**: "http://localhost:8000/api/experiment-descriptor/",
16. **experimentinstance**: "http://localhost:8000/api/experiment-instance/",
17. **experimenttemplate**: "http://localhost:8000/api/experiment-template/",
18. **experimenttype**: "http://localhost:8000/api/experiment-type/",
19. **inventory**: "http://localhost:8000/api/inventory/",
20. **inventorymaterial**: "http://localhost:8000/api/inventory-material/",
21. **material**: "http://localhost:8000/api/material/",
22. **materialidentifier**: "http://localhost:8000/api/material-identifier/",
23. **materialidentifierdef**: "http://localhost:8000/api/material-identifier-def/",
24. **materialtype**: "http://localhost:8000/api/material-type/",
25. **measure**: "http://localhost:8000/api/measure/",
26. **measuredef**: "http://localhost:8000/api/measure-def/",
27. **measuretype**: "http://localhost:8000/api/measure-type/",
28. **mixture**: "http://localhost:8000/api/mixture/",
29. **moleculardescriptor**: "http://localhost:8000/api/molecular-descriptor/",
30. **organization**: "http://localhost:8000/api/organization/",
31. **outcomeinstance**: "http://localhost:8000/api/outcome-instance/",
32. **outcometemplate**: "http://localhost:8000/api/outcome-template/",
33. **parameterdef**: "http://localhost:8000/api/parameter-def/",
34. **person**: "http://localhost:8000/api/person/",
35. **propertytemplate**: "http://localhost:8000/api/property-template/",
36. **reagent**: "http://localhost:8000/api/reagent/",
37. **reagentmaterial**: "http://localhost:8000/api/reagent-material/",
38. **reagentmaterialtemplate**: "http://localhost:8000/api/reagent-material-template/",
39. **reagentmaterialvalue**: "http://localhost:8000/api/reagent-material-value/",
40. **reagentmaterialvaluetemplate**: "http://localhost:8000/api/reagent-material-value-template/",
41. **reagenttemplate**: "http://localhost:8000/api/reagent-template/",
42. **status**: "http://localhost:8000/api/status/",
43. **systemtool**: "http://localhost:8000/api/systemtool/",
44. **systemtooltype**: "http://localhost:8000/api/systemtool-type/",
45. **tag**: "http://localhost:8000/api/tag/",
46. **tagtype**: "http://localhost:8000/api/tag-type/",
47. **typedef**: "http://localhost:8000/api/type-def/",
48. **udfdef**: "http://localhost:8000/api/udf-def/",
49. **unittype**: "http://localhost:8000/api/unit-type/",
50. **vessel**: "http://localhost:8000/api/vessel/",
51. **vesselinstance**: "http://localhost:8000/api/vessel-instance/",
52. **vesseltype**: "http://localhost:8000/api/vessel-type/"
	
<!-- ******************* Authors ****************** -->
<a name="authors"></a>
## Authors

* **Venkateswaran Shekar** [ESCALATE](https://github.com/vshekar)
* **Joseph Pannizzo** [ESCALATE](https://github.com/jpannizzo)

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
