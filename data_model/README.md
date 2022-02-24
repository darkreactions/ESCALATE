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

## Purpose
### A generalized experiment _specification_ and _capture_ (measure / observable) relational database.

The database model consists of the following entities:

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

<br/>


## Built With

* [PostgreSQL 12](https://www.postgresql.org) - Database
* [pgAdmin 4](https://www.pgadmin.org) - Database management tool
* [Navicat](https://www.navicat.com/en/) - Used to generate model and SQL code

<br/>

## Authors

* [**Gary Cattabriga**](https://github.com/gcatabr1) - *Initial work* 
* [**Joseph Pannizzo**](https://github.com/jpannizzo)
* [**Venkateswaran Shekar**](https://github.com/vshekar)											   
* [**Nicole Smina**](https://github.com/nsmina914)

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
