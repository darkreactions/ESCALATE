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
INSERT INTO m_descriptor_def (short_name, calc_definition, description, in_type, out_type, systemtool_id, actor_uuid)
	select def.short_name, def.calc_definition, def.description, in_type::val_type, out_type::val_type, st.systemtool_id, (select actor_uuid from vw_actor where per_lastname = 'Cattabriga')
	from load_perov_desc_def def 
	left join (select systemtool_id, systemtool_name from vw_latest_systemtool) st on def.systemtool_name = st.systemtool_name;

-- get the standardized (desalted) SMILES - returns varchar, so put in blob_value with type text
-- in this [perov] case, this descriptor becomes the parent of many subsequent descriptors
-- do this is 2 steps: 1) add the values into the val table then create the m_descriptor record
INSERT INTO m_descriptor (in_val.v_text, in_val.v_type, m_descriptor_def_uuid, out_val.v_text, out_val.v_type, m_descriptor_alias_name, create_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type, m_descriptor_def_uuid, val_out, val_out_type, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select pd._raw_smiles as val_in, 'text'::val_type as val_in_type, tmp.descr as descriptor_name, tmp.val as val_out, 'text'::val_type as val_out_type, alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from load_perov_desc pd
		join lateral (values ('standardize', '_raw_smiles_standard', _raw_smiles_standard)) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_m_descriptor DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		create_date = EXCLUDED.create_date;


-- create the m_descriptor table (numeric values only) using 
-- the m_descriptor_def table and load_perov_desc table
-- get all the descriptors previously run on the perov from the load_perov_desc table
-- for those descriptors based on the STANDARDIZED SMILES
INSERT INTO m_descriptor (in_val.v_text, in_val.v_type, m_descriptor_def_uuid, out_val.v_int, out_val.v_num, out_val.v_type, m_descriptor_alias_name, create_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type, def.m_descriptor_def_uuid, 
	case when val_out_type::text = 'int' then val_out else NULL end as vout_int, 
	case when val_out_type::text = 'num' then val_out else NULL end as vout_num, 
	val_out_type, alias_name, create_date, status_uuid, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select pd._raw_smiles_standard as val_in, 'text'::val_type as val_in_type, tmp.descr as descriptor_name, tmp.val as val_out, tmp.vtype::val_type as val_out_type, alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status_uuid
	from load_perov_desc pd
		join lateral (values 	
													('molweight', 'num', '_raw_standard_molweight', _raw_standard_molweight),
													('atomcount_c', 'int', '_feat_atomcount_c', _feat_atomcount_c),	
													('atomcount_n', 'int', '_feat_atomcount_n', _feat_atomcount_n),
													('avgpol','num', '_feat_avgpol', _feat_avgpol),
													('molpol','num', '_feat_molpol', _feat_molpol),
													('refractivity','num', '_feat_refractivity', _feat_refractivity),
													('aliphaticringcount', 'int', '_feat_aliphaticringcount', _feat_aliphaticringcount),
													('aromaticringcount', 'int', '_feat_aromaticringcount', _feat_aromaticringcount),
													('aliphaticatomcount', 'int', '_feat_aliphaticatomcount', _feat_aliphaticatomcount),
													('aromaticatomcount', 'int', '_feat_aromaticatomcount', _feat_aromaticatomcount),
													('bondcount', 'int', '_feat_bondcount', _feat_bondcount),
													('carboaliphaticringcount', 'int', '_feat_carboaliphaticringcount', _feat_carboaliphaticringcount),
													('carboaromaticringcount', 'int', '_feat_carboaromaticringcount', _feat_carboaromaticringcount),
													('carboringcount', 'int', '_feat_carboringcount', _feat_carboringcount),
													('chainatomcount', 'int', '_feat_chainatomcount', _feat_chainatomcount),
													('chiralcentercount', 'int', '_feat_chiralcentercount', _feat_chiralcentercount),
													('ringatomcount', 'int', '_feat_ringatomcount', _feat_ringatomcount),
													('smallestringsize', 'int', '_feat_smallestringsize', _feat_smallestringsize),
													('largestringsize', 'int', '_feat_largestringsize', _feat_largestringsize),
													('heteroaliphaticringcount', 'int', '_feat_heteroaliphaticringcount', _feat_heteroaliphaticringcount),
													('heteroaromaticringcount', 'int', '_feat_heteroaromaticringcount', _feat_heteroaromaticringcount),
													('rotatablebondcount', 'int', '_feat_rotatablebondcount', _feat_rotatablebondcount),
													('balabanindex','num', '_feat_balabanindex', _feat_balabanindex),
													('cyclomaticnumber', 'int', '_feat_cyclomaticnumber', _feat_cyclomaticnumber),
													('hyperwienerindex', 'int', '_feat_hyperwienerindex', _feat_hyperwienerindex),
													('wienerindex', 'int', '_feat_wienerindex', _feat_wienerindex),
													('wienerpolarity', 'int', '_feat_wienerpolarity', _feat_wienerpolarity),												
													('minimalprojectionarea','num', '_feat_minimalprojectionarea', _feat_minimalprojectionarea),
													('maximalprojectionarea','num', '_feat_maximalprojectionarea', _feat_maximalprojectionarea),
													('minimalprojectionradius','num', '_feat_minimalprojectionradius', _feat_minimalprojectionradius),								
													('maximalprojectionradius','num', '_feat_maximalprojectionradius', _feat_maximalprojectionradius),								
													('lengthperpendiculartotheminarea','num', '_feat_lengthperpendiculartotheminarea', _feat_lengthperpendiculartotheminarea),								
													('lengthperpendiculartothemaxarea','num', '_feat_lengthperpendiculartothemaxarea', _feat_lengthperpendiculartothemaxarea),								
													('vanderwaalsvolume','num', '_feat_vanderwaalsvolume', _feat_vanderwaalsvolume),
													('vanderwaalssurfacearea','num', '_feat_vanderwaalssurfacearea', _feat_vanderwaalssurfacearea),
													('asa','num', '_feat_asa', _feat_asa),
													('asa+','num', '_feat_asa+', "_feat_asa+"),
													('asa-','num', '_feat_asa-', "_feat_asa-"),
													('asa_h','num', '_feat_asa_h', _feat_asa_h),
													('asa_p','num', '_feat_asa_p', _feat_asa_p),												
													('polarsurfacearea','num', '_feat_polarsurfacearea', _feat_polarsurfacearea),	
													('acceptorcount', 'int', '_feat_acceptorcount', _feat_acceptorcount),
													('accsitecount', 'int', '_feat_accsitecount', _feat_accsitecount),												
													('donorcount', 'int', '_feat_donorcount', _feat_donorcount),												
													('donsitecount', 'int', '_feat_donsitecount', _feat_donsitecount),												
													('maximalprojectionsize','num', '_feat_maximalprojectionsize', _feat_maximalprojectionsize),												
													('minimalprojectionsize','num', '_feat_minimalprojectionsize', _feat_minimalprojectionsize),												
													('molsurfaceareavdwp','num', '_feat_molsurfaceareavdwp', _feat_molsurfaceareavdwp),												
													('msareavdwp','num', '_feat_msareavdwp', _feat_msareavdwp),												
													('molsurfaceareaasap','num', '_feat_molsurfaceareaasap', _feat_molsurfaceareaasap),	
													('msareaasap','num', '_feat_msareaasap', _feat_msareaasap),													
													('protpolarsurfacearea','num', '_feat_protpolarsurfacearea', _feat_protpolarsurfacearea),													
													('protpsa','num', '_feat_protpsa', _feat_protpsa),													
													('hacceptorcount', 'int', '_feat_hacceptorcount', _feat_hacceptorcount),													
													('hdonorcount', 'int', '_feat_hdonorcount', _feat_hdonorcount),													
													('fr_nh2', 'int', '_feat_fr_nh2', _feat_fr_nh2),		
													('fr_nh1', 'int', '_feat_fr_nh1', _feat_fr_nh1),	
													('fr_nh0', 'int', '_feat_fr_nh0', _feat_fr_nh0),													
													('fr_quatn', 'int', '_feat_fr_quatn', _feat_fr_quatn),													
													('fr_arn', 'int', '_feat_fr_arn', _feat_fr_arn),													
													('fr_ar_nh', 'int', '_feat_fr_ar_nh', _feat_fr_ar_nh),	
													('fr_imine', 'int', '_feat_fr_imine', _feat_fr_imine),	
													('fr_amidine', 'int', '_feat_fr_amidine', _feat_fr_amidine),	
													('fr_dihydropyridine', 'int', '_feat_fr_dihydropyridine', _feat_fr_dihydropyridine),	
													('fr_guanido', 'int', '_feat_fr_guanido', _feat_fr_guanido),	
													('fr_piperdine', 'int', '_feat_fr_piperdine', _feat_fr_piperdine),	
													('fr_piperzine', 'int', '_feat_fr_piperzine', _feat_fr_piperzine),		
													('fr_pyridine', 'int', '_feat_fr_pyridine', _feat_fr_pyridine)												
									) as tmp(descr, vtype, alias_name, val) on true) dsc
--									left JOIN
--									(select m_descriptor_uuid, (in_val).v_text as val_in,  
--										m_descriptor_def_uuid from m_descriptor ) md
--									on pd._raw_smiles = md.parent_in and (select m_descriptor_def_uuid from get_m_descriptor_def (array['standardize'])) = md.m_descriptor_def_uuid
--									left join m_descriptor_def mdd on mdd.m_descriptor_def_uuid = md.m_descriptor_def_uuid) dsc
	-- join this with the latest descriptor defs from the m_descriptor_def table 
	-- and the latest view of systemtools (to make sure we have the most recent version)
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_m_descriptor DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		create_date = EXCLUDED.create_date;


INSERT INTO m_descriptor (in_val.v_text, in_val.v_type, m_descriptor_def_uuid, out_val.v_num, out_val.v_type, m_descriptor_alias_name, create_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type, m_descriptor_def_uuid, val_out, val_out_type, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select pd._raw_smiles as val_in, 'text'::val_type as val_in_type, tmp.descr as descriptor_name, tmp.val as val_out, 'num'::val_type as val_out_type, alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from load_perov_desc pd
		join lateral (values ('molweight', '_raw_molweight', _raw_molweight)) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_m_descriptor DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		create_date = EXCLUDED.create_date;


-- now get the ecpf_256_6 and load in as a blob value
INSERT INTO m_descriptor (in_val.v_text, in_val.v_type, m_descriptor_def_uuid, out_val.v_blob, out_val.v_type, m_descriptor_alias_name, create_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type, m_descriptor_def_uuid, val_out::bytea, val_out_type, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select pd._raw_smiles_standard as val_in, 'text'::val_type as val_in_type, tmp.descr as descriptor_name, tmp.val as val_out, 'blob_text'::val_type as val_out_type, alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from load_perov_desc pd
		join lateral (values ('ecpf4_256_6', '_prototype_ecpf4_256_6', _prototype_ecpf4_256_6)) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_m_descriptor DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		create_date = EXCLUDED.create_date;


-- lastly, add the molecule image (from SMILES)	
INSERT INTO m_descriptor (in_val.v_text, in_val.v_type, m_descriptor_def_uuid, out_val.v_blob, out_val.v_type, m_descriptor_alias_name, create_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type, m_descriptor_def_uuid, val_out::bytea, val_out_type, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where actor_description like '%Haverford College%') as actor_uuid
	from
	(select pd.material_refname as val_in, 'text'::val_type as val_in_type, tmp.descr as descriptor_name, tmp.val as val_out, 'blob_svg'::val_type as val_out_type, alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from 
		(select mn.material_refname, mn.material_refname_type, img._image from load_perov_mol_image img 
		join (SELECT * FROM get_material_nameref_bystatus (array['active', 'proto'], TRUE) where material_refname_type = 'SMILES') mn 
		on img.fileno = mn.material_id) pd
		join lateral (values ('molimage', '_molimage', _image)) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from m_descriptor_def mdd 
		join vw_latest_systemtool vst 
		on mdd.systemtool_id = vst.systemtool_id) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_m_descriptor DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		create_date = EXCLUDED.create_date;

	
	


