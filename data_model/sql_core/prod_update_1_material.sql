/*
Name:					prod_update_1_material
Parameters:		none
Returns:			
Author:				G. Cattabriga
Date:					2020.12.02
Description:	load data from load_chem_inventory into material tables; material_type, material, material_refname, material_refname_x
Notes:				
*/
-- drop and create material, material_type, material_refname

-- insert rows into material type from "load_Chem_Inventory"
insert into material_type (description)
	select "ChemicalCategory" from load_chem_inventory
		group by "ChemicalCategory";

-- insert load_chem_inventory materials into material table
-- default to HC as actor
insert into material (material_id, description, status_id)
	select row_number() over () as m_id, "ChemicalName" as descr, (select status_id from status where description = 'active') as status  
	from load_chem_inventory inv;

-- insert load_chem_inventory "ChemicalCategory" crossref'ed to material_type into material_type_x
insert into material_type_x (material_id, material_type_id)
	select mat.material_id, mtt.t_id from material mat 
	join 
		(select inv."ChemicalName" as cname, mt.material_type_id as t_id from load_chem_inventory inv 
		join material_type mt on inv."ChemicalCategory" = mt.description) mtt 
	on mat.description = mtt.cname;

	
-- insert the alternative material names into material_refname
-- abbreviation, inchi, inchikey, canonical smiles, molecular formula	
-- chemical name
insert into material_refname (description, material_refname_type, status_id) 	
	select distinct inv."ChemicalName" as abbrv, 'Chemical Name' as atype, (select status_id from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."ChemicalName" is not null;
-- abbreviation
insert into material_refname (description, material_refname_type, status_id) 	
	select distinct inv."ChemicalAbbreviation" as abbrv, 'Abbreviation' as atype, (select status_id from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."ChemicalAbbreviation" is not null;
-- InChi
insert into material_refname (description, material_refname_type, status_id) 	
	select distinct inv."InChI" as abbrv, 'InChI' as atype, (select status_id from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."InChI" is not null;
-- InChiKey
insert into material_refname (description, material_refname_type, status_id) 	
	select distinct inv."InChIKey" as abbrv, 'InChIKey' as atype, (select status_id from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."InChIKey" is not null;
-- SMILES
insert into material_refname (description, material_refname_type, status_id) 	
	select distinct inv."CanonicalSMILES" as abbrv, 'SMILES' as atype, (select status_id from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."CanonicalSMILES" is not null;
-- MolecularFormula
insert into material_refname (description, material_refname_type, status_id) 	
	select distinct inv."MolecularFormula" as abbrv, 'Molecular Formula' as atype, (select status_id from status where description = 'active') as status 
	from load_chem_inventory inv
	where inv."MolecularFormula" is not null;

-- now insert the material xref'd to the material names into material_refname_x
-- chemical name, abbreviation, inchi, inchikey, canonical smiles, molecular formula	
insert into material_refname_x (material_id, material_refname_id) 	
	select distinct mat.material_id as m_id, mn.material_refname_id 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join material_refname mn on inv."ChemicalName" = mn.description and mn.material_refname_type = 'Chemical Name'
	where inv."ChemicalName" is not null;

insert into material_refname_x (material_id, material_refname_id) 	
	select distinct mat.material_id as m_id, mn.material_refname_id 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join material_refname mn on inv."ChemicalAbbreviation" = mn.description and mn.material_refname_type = 'Abbreviation'
	where inv."ChemicalAbbreviation" is not null;

insert into material_refname_x (material_id, material_refname_id) 	
	select distinct mat.material_id as m_id, mn.material_refname_id 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join material_refname mn on inv."InChI" = mn.description and mn.material_refname_type = 'InChI'
	where inv."InChI" is not null;

insert into material_refname_x (material_id, material_refname_id) 	
	select distinct mat.material_id as m_id, mn.material_refname_id 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join material_refname mn on inv."InChIKey" = mn.description and mn.material_refname_type = 'InChIKey'
	where inv."InChIKey" is not null;
	
insert into material_refname_x (material_id, material_refname_id) 	
	select distinct mat.material_id as m_id, mn.material_refname_id 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join material_refname mn on inv."CanonicalSMILES" = mn.description and mn.material_refname_type = 'SMILES'
	where inv."CanonicalSMILES" is not null;	
	
--insert into material_refname_x (material_id, material_refname_id) 	
--	select distinct mat.material_id as m_id, mn.material_refname_id 
----	from load_chem_inventory inv
--	join material mat ON inv."ChemicalName" = mat.description
--	join material_refname mn on inv."StandardizedSMILES" = mn.description and mn.material_refname_type = 'SMILES Standardized'
--	where inv."StandardizedSMILES" is not null;		
	
insert into material_refname_x (material_id, material_refname_id) 	
	select distinct mat.material_id as m_id, mn.material_refname_id 
	from load_chem_inventory inv
	join material mat ON inv."ChemicalName" = mat.description
	join material_refname mn on inv."MolecularFormula" = mn.description and mn.material_refname_type = 'Molecular Formula'
	where inv."MolecularFormula" is not null;	
	
	
-- test materials and NAMES
/*
select mat.material_id, mat.description, mtn.description, mtn.material_refname_type from 
material mat 
join material_refname_x mtx on mat.material_id = mtx.material_id
join material_refname mtn on mtx.material_refname_id = mtn.material_refname_id
order by 1, 4
*/
