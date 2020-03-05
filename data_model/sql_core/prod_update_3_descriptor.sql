/*
Name:					prod_update_3_descriptor
Parameters:		none
Returns:			
Author:				G. Cattabriga
Date:					2020.01.23
Description:	load data from load_perov_desc
Notes:				presumes m_descriptor_def has been populated (see initialize tables)
							not sure how best to use the m_descriptor_class :(
*/


-- first populate m_descriptor_def
-- using the load_perov_desc_def table joined to actor table (function) to bring in approp actor_uuid 
INSERT INTO m_descriptor_def (short_name, calc_definition, description, systemtool_id, actor_uuid, m_descriptor_out_value_type_uuid)
	select def.short_name, def.calc_definition, def.description, st.systemtool_id, (select actor_uuid from vw_actor where per_lastname = 'Cattabriga'), vt.value_type_uuid
	from load_perov_desc_def def 
	left join (select systemtool_id, systemtool_name from vw_latest_systemtool) st on def.systemtool_name = st.systemtool_name
	left join value_type vt on def.calc_type = vt.description;

-- get the standadized (desalted) SMILES - returns varchar, so put in blob_value with type text
-- in this [perov] case, this descriptor becomes the parent of many subsequent descriptors
INSERT INTO m_descriptor (m_descriptor_material_in, m_descriptor_material_type_in, m_descriptor_def_uuid, blob_val_out, blob_type_out, create_date, status_uuid, actor_uuid)
	select distinct material_refname_in, material_type_in, m_descriptor_def_uuid, bytea(descriptor_value), 'text' as blob_type, create_date, status, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select pd._raw_smiles as material_refname_in, 'SMILES' as material_type_in, tmp.descr as descriptor_name, tmp.val as descriptor_value, '2019-11-04'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from load_perov_desc pd
		join lateral (values ('standardize', _raw_smiles_standard)) as tmp(descr, val) on true) dsc
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name;


-- create the m_descriptor table (numeric values only) using 
-- the m_descriptor_def table and load_perov_desc table
-- get all the descriptors previously run on the perov from the load_perov_desc table
-- for those descriptors based on the STANDARDIZED SMILES
INSERT INTO m_descriptor (parent_uuid, m_descriptor_material_in, m_descriptor_material_type_in, m_descriptor_def_uuid, num_valarray_out, create_date, status_uuid, actor_uuid)
	select distinct parent_uuid, mat_in, mat_type_in, def.m_descriptor_def_uuid, array[descriptor_value], create_date, status_uuid, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select md.m_descriptor_uuid as parent_uuid, mat_in, mdd.description as mat_type_in, tmp.descr as descriptor_name, tmp.val as descriptor_value, '2019-11-04'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status_uuid
	from load_perov_desc pd
		join lateral (values 	
													('molweight', _raw_standard_molweight),
													('atomcount_c', _feat_atomcount_c),	
													('atomcount_n', _feat_atomcount_n),
													('avgpol', _feat_avgpol),
													('molpol', _feat_molpol),
													('refractivity', _feat_refractivity),
													('aliphaticringcount', _feat_aliphaticringcount),
													('aromaticringcount', _feat_aromaticringcount),
													('aliphaticatomcount', _feat_aliphaticatomcount),
													('aromaticatomcount', _feat_aromaticatomcount),
													('bondcount', _feat_bondcount),
													('carboaliphaticringcount', _feat_carboaliphaticringcount),
													('carboaromaticringcount', _feat_carboaromaticringcount),
													('carboringcount', _feat_carboringcount),
													('chainatomcount', _feat_chainatomcount),
													('chiralcentercount', _feat_chiralcentercount),
													('ringatomcount', _feat_ringatomcount),
													('smallestringsize', _feat_smallestringsize),
													('largestringsize', _feat_largestringsize),
													('heteroaliphaticringcount', _feat_heteroaliphaticringcount),
													('heteroaromaticringcount', _feat_heteroaromaticringcount),
													('rotatablebondcount', _feat_rotatablebondcount),
													('balabanindex', _feat_balabanindex),
													('cyclomaticnumber', _feat_cyclomaticnumber),
													('hyperwienerindex', _feat_hyperwienerindex),
													('wienerindex', _feat_wienerindex),
													('wienerpolarity', _feat_wienerpolarity),												
													('minimalprojectionarea', _feat_minimalprojectionarea),
													('maximalprojectionarea', _feat_maximalprojectionarea),
													('minimalprojectionradius', _feat_minimalprojectionradius),								
													('maximalprojectionradius', _feat_maximalprojectionradius),								
													('lengthperpendiculartotheminarea', _feat_lengthperpendiculartotheminarea),								
													('lengthperpendiculartothemaxarea', _feat_lengthperpendiculartothemaxarea),								
													('vanderwaalsvolume', _feat_vanderwaalsvolume),
													('vanderwaalssurfacearea', _feat_vanderwaalssurfacearea),
													('asa', _feat_asa),
													('asa+', "_feat_asa+"),
													('asa-', "_feat_asa-"),
													('asa_h', "_feat_asa_h"),
													('asa_p', "_feat_asa_p"),												
													('polarsurfacearea', _feat_polarsurfacearea),	
													('acceptorcount', _feat_acceptorcount),
													('accsitecount', _feat_accsitecount),												
													('donorcount', _feat_donorcount),												
													('donsitecount', _feat_donsitecount),												
													('maximalprojectionsize', _feat_maximalprojectionsize),												
													('minimalprojectionsize', _feat_minimalprojectionsize),												
													('molsurfaceareavdwp', _feat_molsurfaceareavdwp),												
													('msareavdwp', _feat_msareavdwp),												
													('molsurfaceareaasap', _feat_molsurfaceareaasap),	
													('msareaasap', _feat_msareaasap),													
													('protpolarsurfacearea', _feat_protpolarsurfacearea),													
													('protpsa', _feat_protpsa),													
													('hacceptorcount', _feat_hacceptorcount),													
													('hdonorcount', _feat_hdonorcount),													
													('fr_nh2', _feat_fr_nh2),		
													('fr_nh1', _feat_fr_nh1),	
													('fr_nh0', _feat_fr_nh0),													
													('fr_quatn', _feat_fr_quatn),													
													('fr_arn', _feat_fr_arn),													
													('fr_ar_nh', _feat_fr_ar_nh),	
													('fr_imine', _feat_fr_imine),	
													('fr_amidine', _feat_fr_amidine),	
													('fr_dihydropyridine', _feat_fr_dihydropyridine),	
													('fr_guanido', _feat_fr_guanido),	
													('fr_piperdine', _feat_fr_piperdine),	
													('fr_piperzine', _feat_fr_piperzine),		
													('fr_pyridine', _feat_fr_pyridine)												
									) as tmp(descr, val) on true
									left JOIN
									(select m_descriptor_uuid, encode(blob_val_out, 'escape') as mat_in,  
										m_descriptor_material_in as parent_in, m_descriptor_def_uuid from m_descriptor ) md
									on pd._raw_smiles = md.parent_in and (select m_descriptor_def_uuid from get_m_descriptor_def (array['standardize'])) = md.m_descriptor_def_uuid
									left join m_descriptor_def mdd on mdd.m_descriptor_def_uuid = md.m_descriptor_def_uuid) dsc
	-- join this with the latest descriptor defs from the m_descriptor_def table 
	-- and the latest view of systemtools (to make sure we have the most recent version)
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name
	;


-- cant forget to get the molweight of the SMILES (non-standardized)
INSERT INTO m_descriptor (m_descriptor_material_in, m_descriptor_material_type_in, m_descriptor_def_uuid, num_valarray_out, create_date, status_uuid, actor_uuid)
	select distinct material_refname, material_type, m_descriptor_def_uuid, array[descriptor_value], create_date, status_uuid, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select pd._raw_smiles as material_refname, 'SMILES' as material_type, tmp.descr as descriptor_name, tmp.val as descriptor_value, '2019-11-04'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status_uuid
	from load_perov_desc pd
		join lateral (values ('molweight', _raw_molweight)) as tmp(descr, val) on true) dsc
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name;


-- now get the ecpf_256_6 and load in as a blob value
INSERT INTO m_descriptor (parent_uuid, m_descriptor_material_in, m_descriptor_material_type_in, m_descriptor_def_uuid, blob_val_out, blob_type_out, create_date, status_uuid, actor_uuid)
	select distinct parent_uuid, mat_in, mat_type_in, def.m_descriptor_def_uuid, cast(descriptor_value as bytea), 'text' as blob_type, create_date, status_uuid, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select md.m_descriptor_uuid as parent_uuid, mat_in, mdd.description as mat_type_in, tmp.descr as descriptor_name, tmp.val as descriptor_value, '2019-11-04'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status_uuid
	from load_perov_desc pd
		join lateral (values ('ecpf4_256_6', _prototype_ecpf4_256_6)) as tmp(descr, val) on true
	left JOIN
		(select m_descriptor_uuid, encode(blob_val_out, 'escape') as mat_in, m_descriptor_material_in, m_descriptor_def_uuid from m_descriptor) md
		on pd._raw_smiles = md.m_descriptor_material_in and (select m_descriptor_def_uuid from get_m_descriptor_def (array['standardize'])) = md.m_descriptor_def_uuid
		left join m_descriptor_def mdd on mdd.m_descriptor_def_uuid = md.m_descriptor_def_uuid) dsc
	-- join this with the latest descriptor defs from the m_descriptor_def table 
	-- and the latest view of systemtools (to make sure we have the most recent version)
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name
	;
	

-- lastly, add the molecule image (from SMILES)
	INSERT INTO m_descriptor (m_descriptor_material_in, m_descriptor_material_type_in, m_descriptor_def_uuid, blob_val_out, blob_type_out, create_date, status_uuid, actor_uuid)
	select distinct material_refname,material_type, m_descriptor_def_uuid, cast(descriptor_value as bytea), 'svg' as blob_type, create_date, status_uuid, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select pd.material_refname as material_refname, pd.material_refname_type as material_type, tmp.descr as descriptor_name, tmp.val as descriptor_value, '2019-11-04'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status_uuid
	from 
		(select mn.material_refname, mn.material_refname_type, img._image from load_perov_mol_image img 
		join (SELECT * FROM get_material_nameref_bystatus (array['active', 'proto'], TRUE) where material_refname_type = 'SMILES') mn 
		on img.fileno = mn.material_id) pd
	join lateral (values ('molimage', _image)) as tmp(descr, val) on true) dsc
	-- join this with the latest descriptor defs from the m_descriptor_def table 
	-- and the latest view of systemtools (to make sure we have the most recent version)
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name
	;
	
	
	

	
	


