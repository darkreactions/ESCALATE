/*
Name:			prod_update_1_material
Parameters:		none
Returns:			
Author:			G. Cattabriga
Date:			2020.12.02
Description:	load data from load_chem_inventory into material tables; material_type, material, material_refname, material_refname_x
Notes:				
*/
-- drop and create material, material_type, material_refname


-- insert rows into material type from "load_Chem_Inventory"
insert into vw_material_type (description)
	SELECT trim(regexp_split_to_table(load_chem_inventory."ChemicalCategory", E',')) as ccat
	FROM load_chem_inventory
	group by ccat;
-- ones not identified in the inventory (yet)
insert into vw_material_type (description) values ('a-cation'); 
insert into vw_material_type (description) values ('b-cation'); 
insert into vw_material_type (description) values ('halide'); 
insert into vw_material_type (description) values ('antisovent'); 
insert into vw_material_type (description) values ('reference');
insert into vw_material_type (description) values ('catalog');


INSERT INTO material_refname_def (description)
VALUES 
	('Chemical_Name'),
	('Abbreviation'),
	('InChI'),
	('InChIKey'),
	('RInChI'),		
	('SMILES'),
	('SMARTS'),	
	('SMIRKS'),	
	('Molecular_Formula')
;


-- insert load_chem_inventory materials into material table
-- default to HC as actor
insert into material (description, status_uuid)
	select "ChemicalName" as descr, (select status_uuid from status where description = 'active') as status  
	from load_chem_inventory inv;


-- insert load_chem_inventory "ChemicalCategory" crossref'ed to material_type into material_type_x
insert into material_type_x (material_uuid, material_type_uuid)
	select mat.material_uuid, mtt.t_uuid from material mat 
	join 
		(select inv."ChemicalName" as cname, mt.material_type_uuid as t_uuid from ( SELECT "ChemicalName", trim(regexp_split_to_table(load_chem_inventory."ChemicalCategory"||',catalog,reference', E',')) as "ChemicalCategory"
				FROM load_chem_inventory
				group by "ChemicalName", "ChemicalCategory" ) inv 
		join material_type mt on inv."ChemicalCategory" = mt.description) mtt 
	on mat.description = mtt.cname;

	
-- insert the alternative material names into material_refname
-- abbreviation, inchi, inchikey, canonical smiles, molecular formula	
-- chemical name
insert into material_refname (description, material_refname_def_uuid, status_uuid) 	
	select distinct inv."ChemicalName" as abbrv, (select material_refname_def_uuid from material_refname_def where description = 'Chemical_Name') as refname_def, (select status_uuid from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."ChemicalName" is not null;
-- abbreviation
insert into material_refname (description, material_refname_def_uuid, status_uuid) 	
	select distinct inv."ChemicalAbbreviation" as abbrv, (select material_refname_def_uuid from material_refname_def where description = 'Abbreviation') as refname_def, (select status_uuid from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."ChemicalAbbreviation" is not null;
-- InChi
insert into material_refname (description, material_refname_def_uuid, status_uuid) 	
	select distinct inv."InChI" as abbrv, (select material_refname_def_uuid from material_refname_def where description = 'InChI') as refname_def, (select status_uuid from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."InChI" is not null;
-- InChiKey
insert into material_refname (description, material_refname_def_uuid, status_uuid) 	
	select distinct inv."InChIKey" as abbrv, (select material_refname_def_uuid from material_refname_def where description = 'InChIKey') as refname_def, (select status_uuid from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."InChIKey" is not null;
-- SMILES
insert into material_refname (description, material_refname_def_uuid, status_uuid) 	
	select distinct inv."CanonicalSMILES" as abbrv, (select material_refname_def_uuid from material_refname_def where description = 'SMILES') as refname_def, (select status_uuid from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."CanonicalSMILES" is not null;
-- MolecularFormula
insert into material_refname (description, material_refname_def_uuid, status_uuid) 	
	select distinct inv."MolecularFormula" as abbrv, (select material_refname_def_uuid from material_refname_def where description = 'Molecular_Formula') as refname_def, (select status_uuid from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."MolecularFormula" is not null;

-- now insert the material xref'd to the material names into material_refname_x
-- chemical name, abbreviation, inchi, inchikey, canonical smiles, molecular formula	
insert into material_refname_x (material_uuid, material_refname_uuid) 	
	select distinct mat.material_uuid as m_uuid, mn.material_refname_uuid 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join 
		(select mr.material_refname_uuid, mr.description, mt.description as material_refname_def from material_refname mr join material_refname_def mt on mr.material_refname_def_uuid = mt.material_refname_def_uuid) as mn
		on inv."ChemicalName" = mn.description and mn.material_refname_def = 'Chemical_Name'
	where inv."ChemicalName" is not null;

insert into material_refname_x (material_uuid, material_refname_uuid) 	
	select distinct mat.material_uuid as m_uuid, mn.material_refname_uuid 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join 
		(select mr.material_refname_uuid, mr.description, mt.description as material_refname_def from material_refname mr join material_refname_def mt on mr.material_refname_def_uuid = mt.material_refname_def_uuid) as mn 
		on inv."ChemicalAbbreviation" = mn.description and mn.material_refname_def = 'Abbreviation'
	where inv."ChemicalAbbreviation" is not null;

insert into material_refname_x (material_uuid, material_refname_uuid) 	
	select distinct mat.material_uuid as m_uuid, mn.material_refname_uuid 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join 
		(select mr.material_refname_uuid, mr.description, mt.description as material_refname_def from material_refname mr join material_refname_def mt on mr.material_refname_def_uuid = mt.material_refname_def_uuid) as mn 
		on inv."InChI" = mn.description and mn.material_refname_def = 'InChI'
	where inv."InChI" is not null;

insert into material_refname_x (material_uuid, material_refname_uuid) 	
	select distinct mat.material_uuid as m_uuid, mn.material_refname_uuid 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join 
		(select mr.material_refname_uuid, mr.description, mt.description as material_refname_def from material_refname mr join material_refname_def mt on mr.material_refname_def_uuid = mt.material_refname_def_uuid) as mn 
		on inv."InChIKey" = mn.description and mn.material_refname_def = 'InChIKey'
	where inv."InChIKey" is not null;
	
insert into material_refname_x (material_uuid, material_refname_uuid) 	
	select distinct mat.material_uuid as m_uuid, mn.material_refname_uuid 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join 
		(select mr.material_refname_uuid, mr.description, mt.description as material_refname_def from material_refname mr join material_refname_def mt on mr.material_refname_def_uuid = mt.material_refname_def_uuid) as mn 
		on inv."CanonicalSMILES" = mn.description and mn.material_refname_def = 'SMILES'
	where inv."CanonicalSMILES" is not null;	
	
--insert into material_refname_x (material_id, material_refname_id) 	
--	select distinct mat.material_id as m_id, mn.material_refname_id 
----	from load_chem_inventory inv
--	join material mat ON inv."ChemicalName" = mat.description
--	join material_refname mn on inv."StandardizedSMILES" = mn.description and mn.material_refname_def = 'SMILES Standardized'
--	where inv."StandardizedSMILES" is not null;		
	
insert into material_refname_x (material_uuid, material_refname_uuid) 	
	select distinct mat.material_uuid as m_uuid, mn.material_refname_uuid 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join 
		(select mr.material_refname_uuid, mr.description, mt.description as material_refname_def from material_refname mr join material_refname_def mt on mr.material_refname_def_uuid = mt.material_refname_def_uuid) as mn 
		on inv."MolecularFormula" = mn.description and mn.material_refname_def = 'Molecular_Formula'
	where inv."MolecularFormula" is not null;	
	
	
-- populate a material or two with tags 
-- we'll do it based on material_type for 'CC(C)(C)[NH3+].[I-]'
insert into tag_x (ref_tag_uuid, tag_uuid)
	select (SELECT material_uuid FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE)) as tag_ref_uuid, tag_uuid 
		from tag tg where tg.display_text in (
		SELECT unnest(get_material_type ((SELECT material_uuid FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE))))
		);

