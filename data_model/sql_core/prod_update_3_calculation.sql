/*
Name:			prod_update_3_caclulation
Parameters:		none
Returns:			
Author:			G. Cattabriga
Date:			2020.01.23
Description:	load data from load_perov_desc
Notes:			presumes calculation_def has been populated (see initialize tables)
				not sure how best to use the calculation_class :(
*/


-- first populate calculation_def for calculations not dependent on a 'source'
-- using the load_perov_desc_def table joined to actor table (function) to bring in approp actor_uuid 
INSERT INTO calculation_def (short_name, calc_definition, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, in_opt_type_uuid, out_type_uuid, systemtool_uuid, actor_uuid)
	select def.short_name, def.calc_definition, def.description, null::uuid as in_source_uuid, 
	(select get_type_def ('data', def.in_type)) as in_type_uuid, null::uuid as in_opt_calc_source_uuid, 
	(select get_type_def ('data', def.in_opt_type)) as in_opt_type_uuid,
	(select get_type_def ('data', def.out_type)) as out_type_uuid,	
	st.systemtool_uuid, (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')
	from load_perov_desc_def def 
	left join (select systemtool_uuid, systemtool_name from vw_systemtool) st on def.systemtool_name = st.systemtool_name
	where in_calc_source is null and in_opt_calc_source is null;


-- now do the calculations that have an 'in_source' but not an 'in_opt_source'
-- using the load_perov_desc_def table joined to actor table (function) to bring in approp actor_uuid 
INSERT INTO calculation_def (short_name, calc_definition, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, in_opt_type_uuid, out_type_uuid, systemtool_uuid, actor_uuid)
	select def.short_name, def.calc_definition, def.description, cd1.calculation_def_uuid as in_source_uuid, 
	cd1.out_type_uuid as in_type_uuid, null::uuid as in_opt_source_uuid, 
	null as in_opt_type_uuid,
	(select get_type_def ('data', def.out_type)) as out_type_uuid,	
	st.systemtool_uuid, (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')
	from load_perov_desc_def def 
	left join (select systemtool_uuid, systemtool_name from vw_systemtool) st on def.systemtool_name = st.systemtool_name
	left join calculation_def cd1 on def.in_calc_source = cd1.short_name
	left join calculation_def cd2 on def.in_opt_calc_source = cd2.short_name
	where in_calc_source is not null and in_opt_calc_source is null;

-- now do the calculations that have an 'in_source' and an 'in_opt_source'
-- using the load_perov_desc_def table joined to actor table (function) to bring in approp actor_uuid 
INSERT INTO calculation_def (short_name, calc_definition, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, in_opt_type_uuid, out_type_uuid, systemtool_uuid, actor_uuid)
	select def.short_name, def.calc_definition, def.description, cd1.calculation_def_uuid as in_source_uuid, cd1.out_type_uuid as in_type_uuid, 
	cd2.calculation_def_uuid as in_opt_source_uuid, cd2.out_type_uuid, 
	(select get_type_def ('data', def.out_type)) as out_type_uuid,	
	st.systemtool_uuid, (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')
	from load_perov_desc_def def 
	left join (select systemtool_uuid, systemtool_name from vw_systemtool) st on def.systemtool_name = st.systemtool_name
	left join calculation_def cd1 on def.in_calc_source = cd1.short_name
	left join calculation_def cd2 on def.in_opt_calc_source = cd2.short_name
	where in_calc_source is not null and in_opt_calc_source is not null;


-- get the standardized (desalted) SMILES - returns varchar, so put in blob_value with type text
-- in this [perov] case, this descriptor becomes the parent of many subsequent descriptors
-- do this is 2 steps: 1) add the values into the val table then create the calculation record
INSERT INTO calculation (in_val.v_text, in_val.v_type_uuid, calculation_def_uuid, out_val.v_text, out_val.v_type_uuid, calculation_alias_name, add_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type_uuid, calculation_def_uuid, val_out, val_out_type_uuid, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where description like '%Haverford College%') as actor_uuid
	from
	(select pd._raw_smiles as val_in, 
	(select get_type_def ('data', 'text')) as val_in_type_uuid, 
	tmp.descr as descriptor_name, tmp.val as val_out, 
	(select get_type_def ('data', 'text')) as val_out_type_uuid, 
	alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from load_perov_desc pd
		join lateral (values ('standardize', '_raw_smiles_standard', _raw_smiles_standard)) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from calculation_def mdd 
		join vw_systemtool vst 
		on mdd.systemtool_uuid = vst.systemtool_uuid) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_calculation DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date;


INSERT INTO calculation (in_val.v_text, in_val.v_type_uuid, calculation_def_uuid, out_val.v_num, out_val.v_type_uuid, calculation_alias_name, add_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type_uuid, calculation_def_uuid, val_out, val_out_type_uuid, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where description like '%Haverford College%') as actor_uuid
	from
	(select pd._raw_smiles as val_in, 
	(select get_type_def ('data', 'num')) as val_in_type_uuid, 
	tmp.descr as descriptor_name, tmp.val as val_out, 
	(select get_type_def ('data', 'num')) as val_out_type_uuid, 
	alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from load_perov_desc pd
		join lateral (values ('molweight', '_raw_molweight', _raw_molweight)) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from calculation_def mdd 
		join vw_systemtool vst 
		on mdd.systemtool_uuid = vst.systemtool_uuid) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_calculation DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date;


-- add the molecule image (from SMILES)	
-- first insert image into edocument
insert into edocument (title, description, filename, source, edocument, doc_type_uuid, actor_uuid)
	select mol_name as title, mol_name as description, filename, (select calculation_def_uuid from get_calculation_def (array['molimage'])) as edocument_source, _image as edocument, 
	(select get_type_def ('file', 'svg')) as edoc_type_uuid, 
	(select actor_uuid from vw_actor where person_last_name = 'Cattabriga') as actor_uuid from load_perov_mol_image img
ON CONFLICT ON CONSTRAINT un_edocument DO UPDATE
	SET 
		edocument = EXCLUDED.edocument,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date;


INSERT INTO calculation (in_val.v_text, in_val.v_type_uuid, calculation_def_uuid, out_val.v_edocument_uuid, out_val.v_type_uuid, calculation_alias_name, add_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type_uuid, calculation_def_uuid, val_out, val_out_type_uuid, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where description like '%Haverford College%') as actor_uuid
	from
	(select pd.material_refname as val_in, 
	(select get_type_def ('data', 'text')) as val_in_type_uuid, 
	tmp.descr as descriptor_name, tmp.val as val_out, 
	(select get_type_def ('data', 'blob')) as val_out_type_uuid, 
	alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from 
		(select mn.material_refname, mn.material_refname_def, img.edocument_uuid from edocument img 
		join (SELECT * FROM get_material_nameref_bystatus (array['active', 'proto'], TRUE) where material_refname_def = 'SMILES') mn 
		on img.title = mn.material_refname) pd
		join lateral (values ('molimage', '_molimage', edocument_uuid)) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from calculation_def mdd 
		join vw_systemtool vst 
		on mdd.systemtool_uuid = vst.systemtool_uuid) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_calculation DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date;


-- create the calculation table (numeric values only) using 
-- the calculation_def table and load_perov_desc table
-- get all the descriptors previously run on the perov from the load_perov_desc table
-- for those descriptors based on the STANDARDIZED SMILES
INSERT INTO calculation (in_val.v_source_uuid, in_val.v_text, in_val.v_type_uuid, calculation_def_uuid, out_val.v_int, out_val.v_num, out_val.v_type_uuid, calculation_alias_name, add_date, status_uuid, actor_uuid)
	select distinct val_in_source, val_in, val_in_type_uuid, def.calculation_def_uuid, 
	case when val_out_type_uuid = (select get_type_def ('data', 'int')) then val_out else NULL end as vout_int, 
	case when val_out_type_uuid = (select get_type_def ('data', 'num')) then val_out else NULL end as vout_num, 
	val_out_type_uuid, alias_name, create_date, dsc.status_uuid, (SELECT actor_uuid FROM vw_actor where description like '%Haverford College%') as actor_uuid
	from
	(select (get_calculation (pd._raw_smiles, array['standardize'])) as val_in_source, pd._raw_smiles_standard as val_in, 
		(select get_type_def ('data', 'text')) as val_in_type_uuid, tmp.descr as descriptor_name, tmp.val as val_out, 
		(select get_type_def ('data', tmp.vtype)) as val_out_type_uuid, alias_name, 
		'2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status_uuid
	from load_perov_desc pd
		join lateral (values 	
													('molweight_standardize', 'num', '_raw_standard_molweight', _raw_standard_molweight),
													('atomcount_c_standardize', 'int', '_feat_atomcount_c', _feat_atomcount_c),	
													('atomcount_n_standardize', 'int', '_feat_atomcount_n', _feat_atomcount_n),
													('avgpol_standardize','num', '_feat_avgpol', _feat_avgpol),
													('molpol_standardize','num', '_feat_molpol', _feat_molpol),
													('refractivity_standardize','num', '_feat_refractivity', _feat_refractivity),
													('aliphaticringcount_standardize', 'int', '_feat_aliphaticringcount', _feat_aliphaticringcount),
													('aromaticringcount_standardize', 'int', '_feat_aromaticringcount', _feat_aromaticringcount),
													('aliphaticatomcount_standardize', 'int', '_feat_aliphaticatomcount', _feat_aliphaticatomcount),
													('aromaticatomcount_standardize', 'int', '_feat_aromaticatomcount', _feat_aromaticatomcount),
													('bondcount_standardize', 'int', '_feat_bondcount', _feat_bondcount),
													('carboaliphaticringcount_standardize', 'int', '_feat_carboaliphaticringcount', _feat_carboaliphaticringcount),
													('carboaromaticringcount_standardize', 'int', '_feat_carboaromaticringcount', _feat_carboaromaticringcount),
													('carboringcount_standardize', 'int', '_feat_carboringcount', _feat_carboringcount),
													('chainatomcount_standardize', 'int', '_feat_chainatomcount', _feat_chainatomcount),
													('chiralcentercount_standardize', 'int', '_feat_chiralcentercount', _feat_chiralcentercount),
													('ringatomcount_standardize', 'int', '_feat_ringatomcount', _feat_ringatomcount),
													('smallestringsize_standardize', 'int', '_feat_smallestringsize', _feat_smallestringsize),
													('largestringsize_standardize', 'int', '_feat_largestringsize', _feat_largestringsize),
													('heteroaliphaticringcount_standardize', 'int', '_feat_heteroaliphaticringcount', _feat_heteroaliphaticringcount),
													('heteroaromaticringcount_standardize', 'int', '_feat_heteroaromaticringcount', _feat_heteroaromaticringcount),
													('rotatablebondcount_standardize', 'int', '_feat_rotatablebondcount', _feat_rotatablebondcount),
													('balabanindex_standardize','num', '_feat_balabanindex', _feat_balabanindex),
													('cyclomaticnumber_standardize', 'int', '_feat_cyclomaticnumber', _feat_cyclomaticnumber),
													('hyperwienerindex_standardize', 'int', '_feat_hyperwienerindex', _feat_hyperwienerindex),
													('wienerindex_standardize', 'int', '_feat_wienerindex', _feat_wienerindex),
													('wienerpolarity_standardize', 'int', '_feat_wienerpolarity', _feat_wienerpolarity),												
													('minimalprojectionarea_standardize','num', '_feat_minimalprojectionarea', _feat_minimalprojectionarea),
													('maximalprojectionarea_standardize','num', '_feat_maximalprojectionarea', _feat_maximalprojectionarea),
													('minimalprojectionradius_standardize','num', '_feat_minimalprojectionradius', _feat_minimalprojectionradius),								
													('maximalprojectionradius_standardize','num', '_feat_maximalprojectionradius', _feat_maximalprojectionradius),								
													('lengthperpendiculartotheminarea_standardize','num', '_feat_lengthperpendiculartotheminarea', _feat_lengthperpendiculartotheminarea),								
													('lengthperpendiculartothemaxarea_standardize','num', '_feat_lengthperpendiculartothemaxarea', _feat_lengthperpendiculartothemaxarea),								
													('vanderwaalsvolume_standardize','num', '_feat_vanderwaalsvolume', _feat_vanderwaalsvolume),
													('vanderwaalssurfacearea_standardize','num', '_feat_vanderwaalssurfacearea', _feat_vanderwaalssurfacearea),
													('asa_standardize','num', '_feat_asa', _feat_asa),
													('asa+_standardize','num', '_feat_asa+', "_feat_asa+"),
													('asa-_standardize','num', '_feat_asa-', "_feat_asa-"),
													('asa_h_standardize','num', '_feat_asa_h', _feat_asa_h),
													('asa_p_standardize','num', '_feat_asa_p', _feat_asa_p),												
													('polarsurfacearea_standardize','num', '_feat_polarsurfacearea', _feat_polarsurfacearea),	
													('acceptorcount_standardize', 'int', '_feat_acceptorcount', _feat_acceptorcount),
													('accsitecount_standardize', 'int', '_feat_accsitecount', _feat_accsitecount),												
													('donorcount_standardize', 'int', '_feat_donorcount', _feat_donorcount),												
													('donsitecount_standardize', 'int', '_feat_donsitecount', _feat_donsitecount),												
													('maximalprojectionsize_standardize','num', '_feat_maximalprojectionsize', _feat_maximalprojectionsize),												
													('minimalprojectionsize_standardize','num', '_feat_minimalprojectionsize', _feat_minimalprojectionsize),												
													('molsurfaceareavdwp_standardize','num', '_feat_molsurfaceareavdwp', _feat_molsurfaceareavdwp),												
													('msareavdwp_standardize','num', '_feat_msareavdwp', _feat_msareavdwp),												
													('molsurfaceareaasap_standardize','num', '_feat_molsurfaceareaasap', _feat_molsurfaceareaasap),	
													('msareaasap_standardize','num', '_feat_msareaasap', _feat_msareaasap),													
													('protpolarsurfacearea_standardize','num', '_feat_protpolarsurfacearea', _feat_protpolarsurfacearea),													
													('protpsa_standardize','num', '_feat_protpsa', _feat_protpsa),													
													('hacceptorcount_standardize', 'int', '_feat_hacceptorcount', _feat_hacceptorcount),													
													('hdonorcount_standardize', 'int', '_feat_hdonorcount', _feat_hdonorcount),													
													('fr_nh2_standardize', 'int', '_feat_fr_nh2', _feat_fr_nh2),		
													('fr_nh1_standardize', 'int', '_feat_fr_nh1', _feat_fr_nh1),	
													('fr_nh0_standardize', 'int', '_feat_fr_nh0', _feat_fr_nh0),													
													('fr_quatn_standardize', 'int', '_feat_fr_quatn', _feat_fr_quatn),													
													('fr_arn_standardize', 'int', '_feat_fr_arn', _feat_fr_arn),													
													('fr_ar_nh_standardize', 'int', '_feat_fr_ar_nh', _feat_fr_ar_nh),	
													('fr_imine_standardize', 'int', '_feat_fr_imine', _feat_fr_imine),	
													('fr_amidine_standardize', 'int', '_feat_fr_amidine', _feat_fr_amidine),	
													('fr_dihydropyridine_standardize', 'int', '_feat_fr_dihydropyridine', _feat_fr_dihydropyridine),	
													('fr_guanido_standardize', 'int', '_feat_fr_guanido', _feat_fr_guanido),	
													('fr_piperdine_standardize', 'int', '_feat_fr_piperdine', _feat_fr_piperdine),	
													('fr_piperzine_standardize', 'int', '_feat_fr_piperzine', _feat_fr_piperzine),		
													('fr_pyridine_standardize', 'int', '_feat_fr_pyridine', _feat_fr_pyridine),
													('charge_cnt_standardize', 'int', '_feat_charge_cnt', _feat_charge_cnt)													
									) as tmp(descr, vtype, alias_name, val) on true) dsc
--									left JOIN
--									(select calculation_uuid, (in_val).v_text as val_in,  
--										calculation_def_uuid from calculation ) md
--									on pd._raw_smiles = md.parent_in and (select calculation_def_uuid from get_calculation_def (array['standardize'])) = md.calculation_def_uuid
--									left join calculation_def mdd on mdd.calculation_def_uuid = md.calculation_def_uuid) dsc
	-- join this with the latest descriptor defs from the calculation_def table 
	-- and the latest view of systemtools (to make sure we have the most recent version)
	left join 
		(select *
		from calculation_def mdd 
		join vw_systemtool vst 
		on mdd.systemtool_uuid = vst.systemtool_uuid) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_calculation DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date;


-- get the escalate calculated descriptors
INSERT INTO calculation (in_val.v_int, in_val.v_type_uuid, in_val.v_source_uuid, in_opt_val.v_num, in_opt_val.v_type_uuid, in_opt_val.v_source_uuid, calculation_def_uuid, out_val.v_num, out_val.v_type_uuid, calculation_alias_name, add_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type_uuid, val_in_source, val_in_opt, val_in_opt_type_uuid, val_in_opt_source, calculation_def_uuid, val_out::numeric, val_out_type_uuid, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where description like '%Haverford College%') as actor_uuid
	from
	(select (get_calculation (pd._raw_smiles, array['charge_cnt_standardize'])) as val_in_source, pd._feat_charge_cnt as val_in, 
		(select get_type_def ('data', 'int')) as val_in_type_uuid, (get_calculation (pd._raw_smiles, array['vanderwaalsvolume_standardize'])) as val_in_opt_source,
		pd._feat_vanderwaalsvolume as val_in_opt, 
		(select get_type_def ('data', 'num')) as val_in_opt_type_uuid, tmp.descr as descriptor_name, tmp.val as val_out, 
		(select get_type_def ('data', 'num')) as val_out_type_uuid, 
		alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from load_perov_desc pd
		join lateral (values 
			('chrg_per_vol_standardize', '_calc_chrg_per_vol', _calc_chrg_per_vol)) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from calculation_def mdd 
		join vw_systemtool vst 
		on mdd.systemtool_uuid = vst.systemtool_uuid) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_calculation DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date;
		
		
INSERT INTO calculation (in_val.v_int, in_val.v_type_uuid, in_val.v_source_uuid, in_opt_val.v_num, in_opt_val.v_type_uuid, in_opt_val.v_source_uuid, calculation_def_uuid, out_val.v_num, out_val.v_type_uuid, calculation_alias_name, add_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type_uuid, val_in_source, val_in_opt, val_in_opt_type_uuid, val_in_opt_source, calculation_def_uuid, val_out::numeric, val_out_type_uuid, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where description like '%Haverford College%') as actor_uuid
	from
	(select (get_calculation (pd._raw_smiles, array['charge_cnt_standardize'])) as val_in_source, pd._feat_charge_cnt as val_in, 
		(select get_type_def ('data', 'int')) as val_in_type_uuid, 
		(get_calculation (pd._raw_smiles, array['asa-_standardize'])) as val_in_opt_source,
		pd."_feat_asa-" as val_in_opt, 
		(select get_type_def ('data', 'num')) as val_in_opt_type_uuid, tmp.descr as descriptor_name, tmp.val as val_out, 
		(select get_type_def ('data', 'num')) as val_out_type_uuid,
		alias_name, '2020-02-20'::timestamptz as create_date, (select status_uuid from status where description = 'active') as status
	from load_perov_desc pd
		join lateral (values 
			('chrg_per_asa_standardize', '_calc_chrg_per_asa-', "_calc_chrg_per_asa-")) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from calculation_def mdd 
		join vw_systemtool vst 
		on mdd.systemtool_uuid = vst.systemtool_uuid) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_calculation DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date;		


-- get the ecpf_256_6 and load in as a blob value
INSERT INTO calculation (in_val.v_text, in_val.v_type_uuid, in_val.v_source_uuid, calculation_def_uuid, out_val.v_text, out_val.v_type_uuid, calculation_alias_name, add_date, status_uuid, actor_uuid)
	select distinct val_in, val_in_type_uuid, val_in_source, calculation_def_uuid, val_out::text, val_out_type_uuid, alias_name, create_date, status, (SELECT actor_uuid FROM vw_actor where description like '%Haverford College%') as actor_uuid
	from
	(select (get_calculation(pd._raw_smiles, array['standardize'])) as val_in_source, pd._raw_smiles_standard as val_in, 
		(select get_type_def ('data', 'text')) as val_in_type_uuid, tmp.descr as descriptor_name, tmp.val as val_out, 
		(select get_type_def ('data', 'text')) as val_out_type_uuid, alias_name, '2020-02-20'::timestamptz as
		create_date, (select status_uuid from status where description = 'active') as status
	from load_perov_desc pd
		join lateral (values ('ecpf4_256_6_standardize', '_prototype_ecpf4_256_6', _prototype_ecpf4_256_6)) as tmp(descr, alias_name, val) on true) dsc
	left join 
		(select *
		from calculation_def mdd 
		join vw_systemtool vst 
		on mdd.systemtool_uuid = vst.systemtool_uuid) def 
	on dsc.descriptor_name = def.short_name
ON CONFLICT ON CONSTRAINT un_calculation DO UPDATE
	SET 
		out_val = EXCLUDED.out_val,
		actor_uuid = EXCLUDED.actor_uuid,
		mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date;


