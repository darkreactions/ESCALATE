/*
Name:			prod_create_views
Parameters:		none
Returns:			
Author:			G. Cattabriga
Date:			2020.01.23
Description:	create the production views for ESCALATEv3
Notes:				
 */
 
--=====================================
-- VIEWS
--=====================================

----------------------------------------
-- view of sys_audit tables trigger on
----------------------------------------
CREATE OR REPLACE VIEW sys_audit_tableslist AS 
 SELECT DISTINCT trigger_schema AS schema,
    event_object_table AS auditedtable
   FROM information_schema.triggers
    WHERE trigger_name::text IN ('audit_trigger_row'::text, 'audit_trigger_stm'::text)  
ORDER BY auditedtable;

----------------------------------------
-- view of status table (simple)
----------------------------------------
CREATE OR REPLACE VIEW vw_status AS
SELECT
	status_uuid,
	description,
	add_date,
	mod_date
FROM
	status;

----------------------------------------
-- view of note; links to edocument and actor
----------------------------------------
CREATE OR REPLACE VIEW vw_edocument AS
SELECT
  doc.edocument_uuid,
  doc.edocument_title,
  doc.description AS edocument_description,
  doc.edocument_filename,
  doc.edocument_source,
  doc.edoc_type AS edocument_type,
  doc.edocument,
  act.actor_uuid,
  act.description AS actor_description
FROM
  edocument doc
  LEFT JOIN actor act ON doc.actor_uuid = act.actor_uuid;

----------------------------------------
-- view of note; links to edocument and actor
----------------------------------------
CREATE OR REPLACE VIEW vw_note AS
SELECT
	nt.note_uuid,
	nt.notetext,
	nt.add_date,
	nt.mod_date,
	ed.edocument_uuid,
	ed.edocument_title,
	ed.description AS edocument_description,
	ed.edocument_filename,
	ed.edocument_source,
	ed.edoc_type AS edocument_type,
	act.actor_uuid,
	act.description AS actor_description
FROM
	note nt
	LEFT JOIN edocument ed ON nt.edocument_uuid = ed.edocument_uuid
	LEFT JOIN actor act ON nt.actor_uuid = act.actor_uuid;

----------------------------------------
-- view of tag_type; links to actor
----------------------------------------
CREATE OR REPLACE VIEW vw_tag_type AS
SELECT
	tt.tag_type_uuid,
	tt.short_description,
	tt.description,
	tt.actor_uuid,
	act.description AS actor_description,
	tt.add_date,
	tt.mod_date
FROM
	tag_type tt
	LEFT JOIN actor act ON tt.actor_uuid = act.actor_uuid;

----------------------------------------
-- view of tag; links to tag_type, actor and note
----------------------------------------
CREATE OR REPLACE VIEW vw_tag AS
SELECT
	tg.tag_uuid,
	tg.short_description AS tag_short_descr,
	tg.description AS tag_description,
	tg.add_date,
	tg.mod_date,
	tg.tag_type_uuid,
	tt.short_description AS tag_type_short_descr,
	tt.description AS tag_type_description,
	act.actor_uuid,
	act.description AS actor_description,
	nt.note_uuid,
	nt.notetext
FROM
	tag tg
	LEFT JOIN tag_type tt ON tg.tag_type_uuid = tt.tag_type_uuid
	LEFT JOIN actor act ON tg.actor_uuid = act.actor_uuid
	LEFT JOIN note nt ON tg.note_uuid = nt.note_uuid;

----------------------------------------
-- view of person; links to organization and note
----------------------------------------
CREATE OR REPLACE VIEW vw_person AS
SELECT
	per.person_uuid,
	per.firstname,
	per.lastname,
	per.middlename,
	per.address1,
	per.address2,
	per.city,
	per.stateprovince,
	per.zip,
	per.country,
	per.phone,
	per.email,
	per.title,
	per.suffix,
	per.add_date,
	per.mod_date,
	org.organization_uuid,
	org.full_name,
	nt.note_uuid,
	nt.notetext,
	ed.edocument_uuid,
	ed.description AS edocument_descr,
	tag.tag_uuid,
	tag.short_description AS tag_short_descr
FROM
	person per
	LEFT JOIN organization org ON per.organization_uuid = org.organization_uuid
	LEFT JOIN note nt ON per.note_uuid = nt.note_uuid
	LEFT JOIN tag_x tx ON per.person_uuid = tx.ref_tag_uuid
	LEFT JOIN tag ON tx.tag_uuid = tag.tag_uuid
	LEFT JOIN edocument_x edx ON per.person_uuid = edx.ref_edocument_uuid
	LEFT JOIN edocument ed ON edx.edocument_uuid = ed.edocument_uuid;

----------------------------------------
-- view of organization; links to parent organization and note
----------------------------------------
CREATE OR REPLACE VIEW vw_organization AS
SELECT
	org.organization_uuid,
	org.description,
	org.full_name,
	org.short_name,
	org.address1,
	org.address2,
	org.city,
	org.state_province,
	org.zip,
	org.country,
	org.website_url,
	org.phone,
	org.parent_uuid,
	orgp.full_name AS parent_org_full_name,
	org.add_date,
	org.mod_date,
	nt.note_uuid,
	nt.notetext,
	ed.edocument_uuid,
	ed.description AS edocument_descr,
	tag.tag_uuid,
	tag.short_description AS tag_short_descr
FROM
	organization org
	LEFT JOIN organization orgp ON org.parent_uuid = orgp.organization_uuid
	LEFT JOIN note nt ON org.note_uuid = nt.note_uuid
	LEFT JOIN tag_x tx ON org.organization_uuid = tx.ref_tag_uuid
	LEFT JOIN tag ON tx.tag_uuid = tag.tag_uuid
	LEFT JOIN edocument_x edx ON org.organization_uuid = edx.ref_edocument_uuid
	LEFT JOIN edocument ed ON edx.edocument_uuid = ed.edocument_uuid;

DROP TRIGGER IF EXISTS trigger_organization_upsert on vw_organization;
CREATE TRIGGER trigger_organization_upsert
INSTEAD OF INSERT OR UPDATE OR DELETE ON vw_organization
    FOR EACH ROW EXECUTE PROCEDURE upsert_organization();

----------------------------------------
-- integrated view of inventory; joins measure (amounts of material
----------------------------------------
CREATE OR REPLACE VIEW vw_actor AS
SELECT
	act.actor_uuid AS actor_uuid,
	org.organization_uuid,
	per.person_uuid,
	st.systemtool_uuid,
	act.description AS actor_description,
	sts.description AS actor_status,
	nt.notetext AS actor_notetext,
	org.full_name AS org_full_name,
	org.short_name AS org_short_name,
	per.lastname AS per_lastname,
	per.firstname AS per_firstname,
	CASE WHEN per.person_uuid IS NOT NULL THEN
		CAST(
			concat(per.lastname, ', ', per.firstname) AS VARCHAR)
	END AS person_lastfirst,
	porg.full_name AS person_org,
	st.systemtool_name,
	st.description AS systemtool_description,
	stt.description AS systemtool_type,
	vorg.full_name AS systemtool_vendor,
	st.model AS systemtool_model,
	st.serial AS systemtool_serial,
	st.ver AS systemtool_version
FROM
	actor act
	LEFT JOIN organization org ON act.organization_uuid = org.organization_uuid
	LEFT JOIN person per ON act.person_uuid = per.person_uuid
	LEFT JOIN organization porg ON per.organization_uuid = porg.organization_uuid
	LEFT JOIN systemtool st ON act.systemtool_uuid = st.systemtool_uuid
	LEFT JOIN systemtool_type stt ON st.systemtool_type_uuid = stt.systemtool_type_uuid
	LEFT JOIN organization vorg ON st.vendor_organization_uuid = vorg.organization_uuid
	LEFT JOIN note nt ON act.note_uuid = nt.note_uuid
	LEFT JOIN edocument_x edx ON act.actor_uuid = edx.ref_edocument_uuid
	LEFT JOIN edocument ed ON edx.edocument_uuid = ed.edocument_uuid
	LEFT JOIN status sts ON act.status_uuid = sts.status_uuid;

----------------------------------------
-- get most recent version of a systemtool in raw format
-- return all columns from the systemtool table
----------------------------------------
CREATE OR REPLACE VIEW vw_latest_systemtool_raw AS
SELECT
	stl.*
FROM
	systemtool stl
	JOIN (
		SELECT
			st.systemtool_name,
			st.systemtool_type_uuid,
			st.vendor_organization_uuid,
			MAX(st.ver) AS ver
		FROM
			systemtool st
		WHERE
			st.systemtool_name IS NOT NULL
			AND st.ver IS NOT NULL
		GROUP BY
			st.systemtool_name,
			st.systemtool_type_uuid,
			st.vendor_organization_uuid,
			st.note_uuid) mrs ON stl.systemtool_name = mrs.systemtool_name
	AND stl.systemtool_type_uuid = mrs.systemtool_type_uuid
	AND stl.vendor_organization_uuid = mrs.vendor_organization_uuid
	AND stl.ver = mrs.ver;

----------------------------------------
-- get most recent version of a systemtool
-- return all columns from actor table
----------------------------------------
CREATE OR REPLACE VIEW vw_latest_systemtool AS
SELECT
	vst.systemtool_uuid,
	vst.systemtool_name,
	vst.description,
	vst.vendor_organization_uuid,
	org.full_name organization_fullname,
	vst.systemtool_type_uuid,
	stt.description AS systemtool_type_description,
	vst.model,
	vst.serial,
	vst.ver,
	act.actor_uuid,
	act.description AS actor_description,
	vst.add_date,
	vst.mod_date
FROM
	vw_latest_systemtool_raw vst
	LEFT JOIN actor act ON vst.systemtool_uuid = act.systemtool_uuid
	LEFT JOIN organization org ON vst.vendor_organization_uuid = org.organization_uuid
	LEFT JOIN note nt ON vst.note_uuid = nt.note_uuid
	LEFT JOIN systemtool_type stt ON vst.systemtool_type_uuid = stt.systemtool_type_uuid;

----------------------------------------
-- get the calculation_def and associated actor
----------------------------------------
CREATE OR REPLACE VIEW vw_calculation_def AS
SELECT
	mdd.calculation_def_uuid,
	mdd.short_name,
	mdd.calc_definition,
	mdd.description,
	mdd.in_type,
	mdd.out_type,
	mdd.systemtool_uuid,
	st.systemtool_name,
	stt.description AS systemtool_type_description,
	org.short_name AS systemtool_vendor_organization,
	st.ver AS systemtool_version,
	mdd.actor_uuid AS actor_uuid,
	act.actor_description AS actor_description
FROM
	calculation_def mdd
	LEFT JOIN vw_actor act ON mdd.actor_uuid = act.actor_uuid
	LEFT JOIN vw_latest_systemtool st ON mdd.systemtool_uuid = st.systemtool_uuid
	LEFT JOIN systemtool_type stt ON st.systemtool_type_uuid = stt.systemtool_type_uuid
	LEFT JOIN organization org ON st.vendor_organization_uuid = org.organization_uuid;

----------------------------------------
-- get the calculations and associated entities
-- DROP VIEW vw_calculation;
----------------------------------------
CREATE OR REPLACE VIEW vw_calculation AS
SELECT
	md.calculation_uuid,
	-- in_val
	--	md.in_val,
	--	md.in_opt_val,
	--	md.out_val,
	md.in_val,
	(
		md.in_val).v_type AS in_val_type,
	get_val (
		md.in_val) AS in_val_value,
	(
		md.in_val).v_unit AS in_val_unit,
	(
		md.in_val).v_edocument_uuid AS in_val_edocument_uuid,
	md.in_opt_val,
	(
		md.in_opt_val).v_type AS in_opt_val_type,
	get_val (
		md.in_opt_val) AS in_opt_val_value,
	(
		md.in_opt_val).v_unit AS in_opt_val_unit,
	(
		md.in_opt_val).v_edocument_uuid AS in_opt_val_edocument_uuid,
	md.out_val,
	(
		md.out_val).v_type AS out_val_type,
	get_val (
		md.out_val) AS out_val_value,
	(
		md.out_val).v_unit AS out_val_unit,
	(
		md.out_val).v_edocument_uuid AS out_val_edocument_uuid,
	md.calculation_alias_name,
	md.create_date,
	sts.description AS status,
	dact.actor_description AS actor_descr,
	nt.notetext AS notetext,
	--	md.num_valarray_out,
	--	encode( md.blob_val_out, 'escape' ) AS blob_val_out,
	--	md.blob_type_out,
	mdd.*
FROM
	calculation md
	LEFT JOIN vw_calculation_def mdd ON md.calculation_def_uuid = mdd.calculation_def_uuid
	LEFT JOIN vw_edocument ed ON (
		md.out_val).v_edocument_uuid = ed.edocument_uuid
	LEFT JOIN vw_actor dact ON md.actor_uuid = dact.actor_uuid
	LEFT JOIN status sts ON md.status_uuid = sts.status_uuid
	LEFT JOIN note nt ON md.note_uuid = nt.note_uuid;

----------------------------------------
-- get material_refname_type
-- DROP VIEW vw_material_refname_type
----------------------------------------
CREATE OR REPLACE VIEW vw_material_refname_type AS
SELECT
	mrt.material_refname_type_uuid,
	mrt.description,
	nt.notetext
FROM
	material_refname_type mrt
	LEFT JOIN note nt ON mrt.note_uuid = nt.note_uuid
ORDER BY
	2;

----------------------------------------
-- get material_type
-- DROP VIEW vw_material_type
----------------------------------------
CREATE OR REPLACE VIEW vw_material_type AS
SELECT
	mt.material_type_uuid,
	mt.description,
	nt.notetext
FROM
	material_type mt
	LEFT JOIN note nt ON mt.note_uuid = nt.note_uuid
ORDER BY
	2;

----------------------------------------
-- get materials, all status
-- DROP VIEW vw_material_raw
----------------------------------------
CREATE OR REPLACE VIEW vw_material_raw AS
SELECT
	mat.material_uuid,
	mat.description AS material_description,
	st.description AS material_status,
	get_material_type (
		mat.material_uuid) AS material_type_description,
	mrt.description AS material_refname_type,
	mr.description AS material_refname_description,
	mr.material_refname_type_uuid,
	mat.add_date AS material_create_date,
	nt.note_uuid,
	nt.notetext
FROM
	material mat
	LEFT JOIN material_refname_x mrx ON mat.material_uuid = mrx.material_uuid
	LEFT JOIN material_refname mr ON mrx.material_refname_uuid = mr.material_refname_uuid
	LEFT JOIN material_refname_type mrt ON mr.material_refname_type_uuid = mrt.material_refname_type_uuid
	LEFT JOIN status st ON mat.status_uuid = st.status_uuid
	LEFT JOIN note nt ON mat.note_uuid = nt.note_uuid
ORDER BY
	mat.material_uuid,
	mr.description;

----------------------------------------
-- get materials, all status as a crosstab, with refname types
-- DROP VIEW vw_material
----------------------------------------
CREATE OR REPLACE VIEW vw_material AS
SELECT
	*
FROM
	crosstab (
		'select material_uuid, material_status, material_create_date, material_refname_type, material_refname_description
		   from vw_material_raw order by 1, 3',
		'select distinct material_refname_type
		   from vw_material_raw order by 1') AS ct (
		material_uuid uuid,
		material_status varchar,
		create_date timestamptz,
		Abbreviation varchar,
		Chemical_Name varchar,
		InChI varchar,
		InChIKey varchar,
		Molecular_Formula varchar,
		SMILES varchar
);

----------------------------------------
-- get materials and all related calculations, all status
-- drop view vw_material_calculation_raw
----------------------------------------
CREATE OR REPLACE VIEW vw_material_calculation_raw AS
SELECT
	mat.material_uuid,
	mat.material_status,
	mat.create_date AS material_create_date,
	mat.abbreviation,
	mat.chemical_name,
	mat.inchi,
	mat.inchikey,
	mat.molecular_formula,
	mat.smiles,
	cal.calculation_uuid,
	cal.in_val,
	cal.in_val_type,
	cal.in_val_value,
	cal.in_val_unit,
	cal.in_val_edocument_uuid,
	cal.in_opt_val,
	cal.in_opt_val_type,
	cal.in_opt_val_value,
	cal.in_opt_val_unit,
	cal.in_opt_val_edocument_uuid,
	cal.out_val,
	cal.out_val_type,
	cal.out_val_value,
	cal.out_val_unit,
	cal.out_val_edocument_uuid,
	cal.calculation_alias_name,
	cal.create_date AS calculation_create_date,
	cal.status,
	cal.actor_descr,
	cal.notetext,
	cal.calculation_def_uuid,
	cal.short_name,
	cal.calc_definition,
	cal.description,
	cal.in_type,
	cal.out_type,
	cal.systemtool_uuid,
	cal.systemtool_name,
	cal.systemtool_type_description,
	cal.systemtool_vendor_organization,
	cal.systemtool_version,
	cal.actor_uuid,
	cal.actor_description
FROM (
	SELECT DISTINCT
		material_uuid,
		get_calculation (smiles) AS calculation_uuid
	FROM
		vw_material) vmc
	JOIN vw_material mat ON vmc.material_uuid = mat.material_uuid
	JOIN vw_calculation cal ON vmc.calculation_uuid = cal.calculation_uuid;

----------------------------------------
-- get materials and all related calculations as a pivot
-- drop view vw_material_calculation_json
----------------------------------------
CREATE OR REPLACE VIEW vw_material_calculation_json AS
SELECT
	vm.material_uuid,
	vm.material_status,
	vm.create_date,
	vm.abbreviation,
	vm.chemical_name,
	vm.inchi,
	vm.inchikey,
	vm.molecular_formula,
	vm.smiles,
	mc.json_object_agg AS calculation_json
FROM (
	SELECT
		material_uuid,
		json_object_agg(calculation_alias_name, json_build_object('type', calculation_type, 'value', calculation_value)
		ORDER BY
			calculation_alias_name DESC)
	FROM (
		SELECT
			vmc.material_uuid,
			vmc.calculation_alias_name,
			max(vmc.out_val_type::text) AS calculation_type,
			max(vmc.out_val_value) AS calculation_value
		FROM
			vw_material_calculation_raw vmc
		GROUP BY
			vmc.material_uuid,
			vmc.calculation_alias_name
		ORDER BY
			1,
			2 DESC) s
	GROUP BY
		material_uuid
	ORDER BY
		material_uuid) mc
	LEFT JOIN vw_material vm ON mc.material_uuid = vm.material_uuid;


----------------------------------------
-- view inventory; with links to material, actor, status, edocument, note
----------------------------------------
CREATE OR REPLACE VIEW vw_inventory AS
SELECT
	inv.inventory_uuid,
	inv.description inventory_description,
	inv.part_no,
	inv.onhand_amt,
	inv.unit,
	inv.create_date,
	inv.expiration_date,
	inv.inventory_location,
	st.description AS status,
	mat.material_uuid,
	mat.description AS material_description,
	act.actor_uuid,
	act.description,
	ed.edocument_uuid,
	ed.description AS edocument_description,
	nt.note_uuid,
	nt.notetext
FROM
	inventory inv
	LEFT JOIN material mat ON inv.material_uuid = mat.material_uuid
	LEFT JOIN actor act ON inv.actor_uuid = act.actor_uuid
	LEFT JOIN status st ON inv.status_uuid = st.status_uuid
	LEFT JOIN edocument ed ON inv.edocument_uuid = ed.edocument_uuid
	LEFT JOIN note nt ON inv.note_uuid = nt.note_uuid;

----------------------------------------
-- get inventory / material, all status
----------------------------------------
CREATE OR REPLACE VIEW vw_inventory_material AS
SELECT
	inv.inventory_uuid,
	inv.description AS inventory_description,
	inv.part_no AS inventory_part_no,
	inv.onhand_amt AS inventory_onhand_amt,
	inv.unit AS inventory_unit,
	inv.create_date AS inventory_create_date,
	inv.expiration_date AS inventory_expiration_date,
	inv.inventory_location,
	st.description AS inventory_status,
	inv.actor_uuid,
	act.actor_description,
	act.org_full_name,
	inv.material_uuid,
	mat.material_status,
	mat.create_date AS material_create_date,
	mat.chemical_name AS material_name,
	mat.abbreviation AS material_abbreviation,
	mat.inchi AS material_inchi,
	mat.inchikey AS material_inchikey,
	mat.molecular_formula AS material_molecular_formula,
	mat.smiles AS material_smiles
FROM
	inventory inv
	LEFT JOIN vw_material mat ON inv.material_uuid = mat.material_uuid
	LEFT JOIN vw_actor act ON inv.actor_uuid = act.actor_uuid
	LEFT JOIN status st ON inv.status_uuid = st.status_uuid;
	
	
	
-- =======================================
-- TESTING ONLY
-- =======================================
----------------------------------------
-- get experiments, measures, calculations 
-- drop view vw_experiment_measure_calculation
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_measure_calculation AS
select * from  
(
	(SELECT 'wf1_iodides' as dataset_type, * from load_v2_iodides order by _exp_no)
	union
	(SELECT 'wf1_bromides' as dataset_type, * from load_v2_bromides order by _exp_no)
	union
	(SELECT 'wf3_iodides' as dataset_type, * from load_v2_wf3_iodides order by _exp_no)	
	union
	(SELECT 'wf3_alloying' as dataset_type, * from load_v2_wf3_alloying order by _exp_no)	
) s;

----------------------------------------
-- get experiments, measures, calculations in json 
-- drop view vw_experiment_measure_calculation_json
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_measure_calculation_json AS
select _exp_no as UID, row_to_json(s) from  
(
	(SELECT 'wf1_iodides' as dataset_type, * from load_v2_iodides order by _exp_no)
	union
	(SELECT 'wf1_bromides' as dataset_type, * from load_v2_bromides order by _exp_no)
	union
	(SELECT 'wf3_iodides' as dataset_type, * from load_v2_wf3_iodides order by _exp_no)	
	union
	(SELECT 'wf3_alloying' as dataset_type, * from load_v2_wf3_alloying order by _exp_no)	
) s;


	