/*
Name:					prod_load_material
Parameters:		none
Returns:			
Author:				G. Cattabriga
Date:					2019.12.02
Description:	load data from load_chem_inventory into material tables; material_type, material, material_ref, alt_material_name
Notes:				
*/
-- drop and create material, material_type, alt_material_name

-- insert rows into material type from "load_Chem_Inventory"
insert into material_type (description)
	select "ChemicalCategory" from load_chem_inventory
		group by "ChemicalCategory";

-- insert load_chem_inventory materials into material table
-- default to HC as actor
insert into material (material_id, description, actor_id)
	select row_number() over () as m_id, "ChemicalName" as descr,  
		(select aa.actor_id from actor aa 
			join organization org on aa.organization_id = org.organization_id
			where org.short_name = 'HC') as actor_id 
	from load_chem_inventory inv;
	
-- insert load_chem_inventory "ChemicalCategory" crossref'ed to material_type
insert into material_ref (material_id, material_type_id)
	select mat.material_id, mtt.t_id from material mat 
	join 
		(select inv."ChemicalName" as cname, mt.material_type_id as t_id from load_chem_inventory inv 
		join material_type mt on inv."ChemicalCategory" = mt.description) mtt 
	on mat.description = mtt.cname;

-- insert the alternative material names into alt_material_name
-- abbreviation, inchi, inchikey, canonical smiles, molecular formula	
insert into alt_material_name (description, material_id, alt_material_name_type) 	
	select inv."ChemicalAbbreviation" as abbrv, mat.material_id as m_id, 'Abbreviation' as atype 
	from load_chem_inventory inv
	join material mat ON
	inv."ChemicalName" = mat.description;
	
insert into alt_material_name (description, material_id, alt_material_name_type) 	
	select inv."InChI" as inchi, mat.material_id as m_id, 'InChi' as atype 
	from load_chem_inventory inv
	join material mat ON
	inv."ChemicalName" = mat.description;

insert into alt_material_name (description, material_id, alt_material_name_type) 	
	select inv."InChIKey" as abbrv, mat.material_id as m_id, 'InChiKey' as atype 
	from load_chem_inventory inv
	join material mat ON
	inv."ChemicalName" = mat.description;
	
insert into alt_material_name (description, material_id, alt_material_name_type) 	
	select inv."CanonicalSMILES" as abbrv, mat.material_id as m_id, 'SMILES' as atype 
	from load_chem_inventory inv
	join material mat ON
	inv."ChemicalName" = mat.description;
	
insert into alt_material_name (description, material_id, alt_material_name_type) 	
	select inv."MolecularFormula" as abbrv, mat.material_id as m_id, 'Molecular Formula' as atype 
	from load_chem_inventory inv
	join material mat ON
	inv."ChemicalName" = mat.description;

