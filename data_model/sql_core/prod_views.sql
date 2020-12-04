--======================================================================
/*
Name:			prod_views
Parameters:		none
Returns:			
Author:			G. Cattabriga
Date:			2020.01.23
Description:	create the production views for ESCALATE v3
Notes:				
 */
--======================================================================

 
--=====================================
-- VIEWS
--=====================================

----------------------------------------
-- view of sys_audit tables trigger on
----------------------------------------

CREATE OR REPLACE VIEW sys_audit_tableslist AS SELECT DISTINCT
	trigger_schema AS SCHEMA,
	event_object_table AS auditedtable
FROM
	information_schema.triggers
WHERE
	trigger_name::text IN(
		'audit_trigger_row' ::text, 'audit_trigger_stm' ::text)
ORDER BY
	auditedtable;

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

DROP TRIGGER IF EXISTS trigger_status_upsert ON vw_status;

CREATE TRIGGER trigger_status_upsert INSTEAD OF INSERT
	OR UPDATE
	OR DELETE ON vw_status
	FOR EACH ROW
	EXECUTE PROCEDURE upsert_status ();


----------------------------------------
-- view of type_def table
----------------------------------------
CREATE OR REPLACE VIEW vw_type_def AS
SELECT
	type_def_uuid,
	category, 
	description,
	add_date,
	mod_date
FROM
	type_def;

DROP TRIGGER IF EXISTS trigger_type_def_upsert ON vw_type_def;

CREATE TRIGGER trigger_type_def_upsert INSTEAD OF INSERT
	OR UPDATE
	OR DELETE ON vw_type_def
	FOR EACH ROW
	EXECUTE PROCEDURE upsert_type_def ();


----------------------------------------
-- view of note; links to edocument and actor
----------------------------------------
CREATE OR REPLACE VIEW vw_edocument AS
SELECT
	doc.edocument_uuid,
	doc.title,
	doc.description,
	doc.filename,
	doc.source,
	doc.edocument,
	doc.doc_type_uuid,
	td.description as doc_type_description,
	doc.doc_ver,
	act.actor_uuid,
	act.description AS actor_description,
	doc.status_uuid,
	sts.description as status_description,
	doc.add_date,
	doc.mod_date,
	docx.edocument_x_uuid,
	docx.ref_edocument_uuid
FROM
	edocument doc
	LEFT JOIN edocument_x docx on docx.edocument_uuid = doc.edocument_uuid
	LEFT JOIN actor act ON doc.actor_uuid = act.actor_uuid
	LEFT JOIN status sts ON doc.status_uuid = sts.status_uuid
	LEFT JOIN type_def td ON doc.doc_type_uuid = td.type_def_uuid;

DROP TRIGGER IF EXISTS trigger_edocument_upsert ON vw_edocument;
CREATE TRIGGER trigger_edocument_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_edocument
FOR EACH ROW
EXECUTE PROCEDURE upsert_edocument ( );


----------------------------------------
-- view of note; links to edocument and actor
----------------------------------------
CREATE OR REPLACE VIEW vw_note AS
SELECT
	nt.note_uuid,
	nt.notetext,
	nt.add_date,
	nt.mod_date,
	act.actor_uuid,
	act.description AS actor_description,
	nx.note_x_uuid,
	nx.ref_note_uuid
FROM
	note nt
	LEFT JOIN actor act ON nt.actor_uuid = act.actor_uuid
	JOIN note_x nx ON nx.note_uuid = nt.note_uuid;

DROP TRIGGER IF EXISTS trigger_note_upsert ON vw_note;
CREATE TRIGGER trigger_note_upsert INSTEAD OF INSERT
	OR UPDATE
	OR DELETE ON vw_note
	FOR EACH ROW
	EXECUTE PROCEDURE upsert_note ();		

	
----------------------------------------
-- view of tag_type
----------------------------------------
CREATE OR REPLACE VIEW vw_tag_type AS
SELECT
	tt.tag_type_uuid,
	tt.type,
	tt.description,
	tt.add_date,
	tt.mod_date
FROM
	tag_type tt;

DROP TRIGGER IF EXISTS trigger_tag_type_upsert ON vw_tag_type;
CREATE TRIGGER trigger_tag_type_upsert INSTEAD OF INSERT
	OR UPDATE
	OR DELETE ON vw_tag_type
	FOR EACH ROW
	EXECUTE PROCEDURE upsert_tag_type ();


----------------------------------------
-- view of tag; links to tag_type, actor and note
----------------------------------------
CREATE OR REPLACE VIEW vw_tag AS
SELECT
	tg.tag_uuid,
	tg.display_text,
	tg.description,
	tg.actor_uuid,
	act.description AS actor_description,
	tg.add_date,
	tg.mod_date,
	tg.tag_type_uuid,
	tt.type,
	tt.description AS type_description
FROM
	tag tg
	LEFT JOIN tag_type tt ON tg.tag_type_uuid = tt.tag_type_uuid
	LEFT JOIN actor act ON tg.actor_uuid = act.actor_uuid;

DROP TRIGGER IF EXISTS trigger_tag_upsert ON vw_tag;
CREATE TRIGGER trigger_tag_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_tag
FOR EACH ROW
EXECUTE PROCEDURE upsert_tag ( );


----------------------------------------
-- view of tag_x; links to tag_type, actor and note
----------------------------------------
CREATE OR REPLACE VIEW vw_tag_assign AS
SELECT
	tx.tag_x_uuid,
	tx.ref_tag_uuid,
	tx.tag_uuid,
	tg.display_text,
	tt.type,
	tx.add_date,
	tx.mod_date
FROM
	tag_x tx
	LEFT JOIN tag tg ON tx.tag_uuid = tg.tag_uuid
	LEFT JOIN tag_type tt ON tg.tag_type_uuid = tt.tag_type_uuid;

DROP TRIGGER IF EXISTS trigger_tag_assign_upsert ON vw_tag_assign;
CREATE TRIGGER trigger_tag_assign_upsert INSTEAD OF INSERT
	OR UPDATE
	OR DELETE ON vw_tag_assign
	FOR EACH ROW
	EXECUTE PROCEDURE upsert_tag_assign ();


----------------------------------------
-- integrated view of udf_def
----------------------------------------
CREATE OR REPLACE VIEW vw_udf_def AS
SELECT
	ud.udf_def_uuid,
	ud.description,
	ud.val_type_uuid,
	td.category as val_type_category,
	td.description as val_type_description,
	ud.unit,
	ud.add_date,
	ud.mod_date
FROM
	udf_def ud
	LEFT JOIN type_def td on ud.val_type_uuid = td.type_def_uuid;

DROP TRIGGER IF EXISTS trigger_udf_def_upsert ON vw_udf_def;
CREATE TRIGGER trigger_udf_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_udf_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_udf_def ( );


----------------------------------------
-- view of udf
----------------------------------------
CREATE OR REPLACE VIEW vw_udf AS
SELECT
	ud.udf_uuid,
	ud.udf_def_uuid,
	udef.description,
	ud.udf_val,
	( ud.udf_val ).v_type_uuid AS udf_val_type_uuid,
	(select val_val from get_val ( ud.udf_val )) AS udf_val_val,
	( ud.udf_val ).v_unit AS udf_val_unit,
	( ud.udf_val ).v_edocument_uuid AS udf_val_edocument_uuid,
	ud.add_date,
	ud.mod_date,
	udx.udf_x_uuid,
	udx.ref_udf_uuid
FROM
	udf ud
	LEFT JOIN udf_x udx on ud.udf_uuid = udx.udf_uuid
	LEFT JOIN udf_def udef on ud.udf_def_uuid = udef.udf_def_uuid
	LEFT JOIN type_def td on udef.val_type_uuid = td.type_def_uuid;

DROP TRIGGER IF EXISTS trigger_udf_upsert ON vw_udf;
CREATE TRIGGER trigger_udf_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_udf
FOR EACH ROW
EXECUTE PROCEDURE upsert_udf ( );

----------------------------------------
-- view of person; links to organization and note
----------------------------------------
CREATE OR REPLACE VIEW vw_person AS
SELECT
	per.person_uuid,
	per.first_name,
	per.last_name,
	per.middle_name,
	per.address1,
	per.address2,
	per.city,
	per.state_province,
	per.zip,
	per.country,
	per.phone,
	per.email,
	per.title,
	per.suffix,
	per.add_date,
	per.mod_date,
	org.organization_uuid,
	org.full_name AS organization_full_name
FROM
	person per
LEFT JOIN organization org ON per.organization_uuid = org.organization_uuid;

DROP TRIGGER IF EXISTS trigger_person_upsert ON vw_person;
CREATE TRIGGER trigger_person_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_person
FOR EACH ROW
EXECUTE PROCEDURE upsert_person ( );


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
	org.mod_date
FROM
	organization org
LEFT JOIN organization orgp ON org.parent_uuid = orgp.organization_uuid;

DROP TRIGGER IF EXISTS trigger_organization_upsert ON vw_organization;
CREATE TRIGGER trigger_organization_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_organization
FOR EACH ROW
EXECUTE PROCEDURE upsert_organization ( );


----------------------------------------
-- integrated view of inventory; joins measure (amounts of material
----------------------------------------
CREATE OR REPLACE VIEW vw_actor AS
SELECT
	act.actor_uuid AS actor_uuid,
	org.organization_uuid,
	per.person_uuid,
	st.systemtool_uuid,
	act.description,
	sts.status_uuid,
	sts.description as status_description,
	act.add_date,
	act.mod_date,
	org.full_name AS org_full_name,
	org.short_name AS org_short_name,
	per.last_name AS person_last_name,
	per.first_name AS person_first_name,
	CASE WHEN per.person_uuid IS NOT NULL THEN
		CAST(
			concat(per.last_name, ', ', per.first_name ) AS VARCHAR )
	END AS person_last_first,
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
LEFT JOIN status sts ON act.status_uuid = sts.status_uuid;

DROP TRIGGER IF EXISTS trigger_actor_upsert ON vw_actor;
CREATE TRIGGER trigger_actor_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_actor
FOR EACH ROW
EXECUTE PROCEDURE upsert_actor ( );


----------------------------------------
-- integrated view of actor_pref
----------------------------------------
CREATE OR REPLACE VIEW vw_actor_pref AS
SELECT
	ap.actor_pref_uuid,
	ap.actor_uuid,
	ap.pkey,
	ap.pvalue,
	ap.add_date,
	ap.mod_date
FROM
	actor_pref ap;

DROP TRIGGER IF EXISTS trigger_actor_pref_upsert ON vw_actor_pref;
CREATE TRIGGER trigger_actor_pref_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_actor_pref
FOR EACH ROW
EXECUTE PROCEDURE upsert_actor_pref ( );




----------------------------------------
-- integrated view of systemtool_type
----------------------------------------
CREATE OR REPLACE VIEW vw_systemtool_type AS
SELECT
	stt.systemtool_type_uuid,
	stt.description,
	stt.add_date,
	stt.mod_date
FROM
	systemtool_type stt;

DROP TRIGGER IF EXISTS trigger_systemtool_type_upsert ON vw_systemtool_type;
CREATE TRIGGER trigger_systemtool_type_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_systemtool_type
FOR EACH ROW
EXECUTE PROCEDURE upsert_systemtool_type ( );


----------------------------------------
-- get most recent version of a systemtool in raw format
-- return all columns from the systemtool table
----------------------------------------
CREATE OR REPLACE VIEW vw_systemtool_raw AS
SELECT
	stl.*
FROM
	systemtool stl
	JOIN (
		SELECT
			st.systemtool_name,
			-- st.systemtool_type_uuid,
			-- st.vendor_organization_uuid,
			MAX(st.ver) AS ver
		FROM
			systemtool st
			-- WHERE
			-- st.systemtool_name IS NOT NULL
			-- AND st.ver IS NOT NULL
		GROUP BY
			st.systemtool_name
			-- st.systemtool_type_uuid,
			-- st.vendor_organization_uuid,
			-- st.note_uuid
		) mrs ON stl.systemtool_name = mrs.systemtool_name and stl.ver = mrs.ver;
--	AND stl.systemtool_type_uuid = mrs.systemtool_type_uuid
--	AND stl.vendor_organization_uuid = mrs.vendor_organization_uuid
--	AND stl.ver = mrs.ver;


----------------------------------------
-- get most recent version of a systemtool
-- return all columns from actor table
----------------------------------------
CREATE OR REPLACE VIEW vw_systemtool AS
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
	vst.add_date,
	vst.mod_date
FROM
	systemtool vst
LEFT JOIN organization org ON vst.vendor_organization_uuid = org.organization_uuid
LEFT JOIN systemtool_type stt ON vst.systemtool_type_uuid = stt.systemtool_type_uuid;

DROP TRIGGER IF EXISTS trigger_systemtool_upsert ON vw_systemtool;
CREATE TRIGGER trigger_systemtool_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_systemtool
FOR EACH ROW
EXECUTE PROCEDURE upsert_systemtool ( );


----------------------------------------
-- view measure_type
-- DROP VIEW vw_measure_type cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_measure_type AS
SELECT
	mt.measure_type_uuid,
	mt.description,
	mt.actor_uuid,
	act.description as actor_description,
	mt.status_uuid,
	st.description as status_description,
	mt.add_date,
	mt.mod_date
FROM
	measure_type mt
LEFT JOIN vw_actor act ON mt.actor_uuid = act.actor_uuid
LEFT JOIN status st ON mt.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_measure_type_upsert ON vw_measure_type;
CREATE TRIGGER trigger_measure_type_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_measure_type
FOR EACH ROW
EXECUTE PROCEDURE upsert_measure_type ( );


----------------------------------------
-- view measure
-- DROP VIEW vw_measure cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_measure AS
SELECT
	m.measure_uuid,
	m.measure_type_uuid,
	mx.ref_measure_uuid,
	m.description,
	m.amount,
	( m.amount ).v_type_uuid AS amount_type_uuid,
	(select val_val from get_val ( m.amount )) AS amount_value,
	( m.amount ).v_unit AS amount_unit,
	m.actor_uuid,
	act.description as actor_description,
	m.status_uuid,
	st.description as status_description,
	m.add_date,
	m.mod_date
FROM
	measure m
LEFT JOIN measure_x mx ON m.measure_uuid = mx.measure_uuid
LEFT JOIN vw_actor act ON m.actor_uuid = act.actor_uuid
LEFT JOIN status st ON m.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_measure_upsert ON vw_measure;
CREATE TRIGGER trigger_measure_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_measure
FOR EACH ROW
EXECUTE PROCEDURE upsert_measure ( );


----------------------------------------
-- view experiment
-- DROP VIEW vw_experiment cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment AS
SELECT
	ex.experiment_uuid,
	ex.ref_uid,
	ex.description,
	ex.parent_uuid,
	ex.parent_path,
	ex.owner_uuid,
	aown.description as owner_description,
	ex.operator_uuid,
	aop.description as operator_description,
	ex.lab_uuid,
	alab.description as lab_description,
	ex.status_uuid,
	st.description as status_description,
	ex.add_date,
	ex.mod_date
FROM experiment ex
LEFT JOIN vw_actor aown ON ex.owner_uuid = aown.actor_uuid
LEFT JOIN vw_actor aop ON ex.owner_uuid = aop.actor_uuid
LEFT JOIN vw_actor alab ON ex.owner_uuid = alab.actor_uuid
LEFT JOIN status st ON ex.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_experiment_upsert ON vw_experiment;
CREATE TRIGGER trigger_experiment_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_experiment
FOR EACH ROW
EXECUTE PROCEDURE upsert_experiment ( );


----------------------------------------
-- view workflow_type
-- DROP VIEW vw_workflow_type
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_type AS
SELECT
	wt.workflow_type_uuid,
	wt.description,
	wt.add_date,
	wt.mod_date
FROM
	workflow_type wt
ORDER BY
	2;

DROP TRIGGER IF EXISTS trigger_workflow_type_upsert ON vw_workflow_type;
CREATE TRIGGER trigger_workflow_type_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow_type
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow_type ( );


----------------------------------------
-- view workflow
-- DROP VIEW vw_workflow
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow AS
SELECT
	wf.workflow_uuid,
	wf.description,
	wf.parent_uuid,
	wf.workflow_type_uuid,
	wt.description as workflow_type_description,
	wf.actor_uuid,
    act.description as actor_description,	
	wf.status_uuid,
	st.description as status_description, 
	wf.add_date,
	wf.mod_date
FROM
	workflow wf
LEFT JOIN vw_workflow_type wt ON wf.workflow_type_uuid = wt.workflow_type_uuid
LEFT JOIN vw_actor act ON wf.actor_uuid = act.actor_uuid
LEFT JOIN status st ON wf.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_upsert ON vw_workflow;
CREATE TRIGGER trigger_workflow_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow ( );


----------------------------------------
-- view experiment_workflow
-- DROP VIEW vw_experiment_workflow cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_workflow AS
SELECT
	ew.experiment_workflow_uuid,
	e.experiment_uuid,
	e.ref_uid as experiment_ref_uid,
	e.description as experiment_description,
	e.parent_uuid as experiment_parent_uuid,
	e.owner_uuid as experiment_owner_uuid,
	e.owner_description as experiment_owner_description,
	e.operator_uuid as experiment_operator_uuid,
	e.operator_description as experiment_operator_description,
	e.lab_uuid as experiment_lab_uuid,
	e.lab_description as experiment_lab_description,
	e.status_uuid as experiment_status_uuid,
	e.status_description as experiment_status_description,
	e.add_date as experiment_add_date,
	e.mod_date as experiment_mod_date,
	ew.experiment_workflow_seq,
	w.workflow_uuid as workflow_uuid,
	w.description as workflow_description,
	w.workflow_type_uuid,
	w.workflow_type_description,
	w.actor_uuid as workflow_actor_uuid,
	w.actor_description as workflow_actor_description,
	w.status_uuid as workflow_status_uuid,
	w.status_description as workflow_status_description,
	w.add_date as workflow_add_date,
	w.mod_date as workflow_mod_date
FROM experiment_workflow ew 
LEFT JOIN vw_experiment e ON ew.experiment_uuid = e.experiment_uuid 
LEFT JOIN vw_workflow w ON ew.workflow_uuid = w.workflow_uuid;


DROP TRIGGER IF EXISTS trigger_experiment_workflow_upsert ON vw_experiment_workflow;
CREATE TRIGGER trigger_experiment_workflow_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_experiment_workflow
FOR EACH ROW
EXECUTE PROCEDURE upsert_experiment_workflow ( );


----------------------------------------
-- get the calculation_def and associated actor
----------------------------------------
CREATE OR REPLACE VIEW vw_calculation_def AS
SELECT
	mdd.calculation_def_uuid,
	mdd.short_name,
	mdd.calc_definition,
	mdd.description,
	mdd.in_source_uuid, 
	mdd.in_type_uuid,
	tdi.description as in_type_description,
	mdd.in_opt_source_uuid,
	mdd.in_opt_type_uuid,
	tdio.description as in_opt_type_description,
	mdd.out_type_uuid,
	tdo.description as out_type_description,
	mdd.systemtool_uuid,
	st.systemtool_name,
	stt.description AS systemtool_type_description,
	org.short_name AS systemtool_vendor_organization,
	st.ver AS systemtool_version,
	sts.status_uuid as status_uuid,
	sts.description as status_description,
	mdd.actor_uuid AS actor_uuid,
	act.description AS actor_description,
	mdd.calculation_class_uuid,
	mdd.add_date,
	mdd.mod_date	
FROM
	calculation_def mdd
LEFT JOIN vw_actor act ON mdd.actor_uuid = act.actor_uuid
LEFT JOIN vw_systemtool st ON mdd.systemtool_uuid = st.systemtool_uuid
LEFT JOIN vw_type_def tdi ON mdd.in_type_uuid = tdi.type_def_uuid
LEFT JOIN vw_type_def tdio ON mdd.in_type_uuid = tdio.type_def_uuid
LEFT JOIN vw_type_def tdo ON mdd.in_type_uuid = tdo.type_def_uuid 
LEFT JOIN systemtool_type stt ON st.systemtool_type_uuid = stt.systemtool_type_uuid
LEFT JOIN organization org ON st.vendor_organization_uuid = org.organization_uuid
LEFT JOIN status sts ON mdd.status_uuid = sts.status_uuid;

DROP TRIGGER IF EXISTS trigger_calculation_def_upsert ON vw_calculation_def;
CREATE TRIGGER trigger_calculation_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_calculation_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_calculation_def ( );



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
	( md.in_val ).v_type_uuid AS in_val_type_uuid,
	(select val_val from get_val ( md.in_val )) AS in_val_value,
	( md.in_val ).v_unit AS in_val_unit,
	( md.in_val ).v_edocument_uuid AS in_val_edocument_uuid,
	md.in_opt_val,
	( md.in_opt_val ).v_type_uuid AS in_opt_val_type_uuid,
	(select val_val from get_val ( md.in_opt_val )) AS in_opt_val_value,
	( md.in_opt_val ).v_unit AS in_opt_val_unit,
	( md.in_opt_val ).v_edocument_uuid AS in_opt_val_edocument_uuid,
	md.out_val,
	( md.out_val ).v_type_uuid AS out_val_type_uuid,
	(select val_val from get_val ( md.out_val )) AS out_val_value,
	( md.out_val ).v_unit AS out_val_unit,
	( md.out_val ).v_edocument_uuid AS out_val_edocument_uuid,
	md.calculation_alias_name,
	md.add_date as calculation_add_date,
	md.mod_date as calculation_mod_date,
	sts.status_uuid AS calculation_status_uuid,
	sts.description AS calculation_status_description,
	mdd.*
FROM
	calculation md
LEFT JOIN vw_calculation_def mdd ON md.calculation_def_uuid = mdd.calculation_def_uuid
LEFT JOIN vw_edocument ed ON (
	md.out_val ).v_edocument_uuid = ed.edocument_uuid
LEFT JOIN vw_actor dact ON md.actor_uuid = dact.actor_uuid
LEFT JOIN vw_status sts ON md.status_uuid = sts.status_uuid;


----------------------------------------
-- get material_refname_def
-- DROP VIEW vw_material_refname_def
----------------------------------------
CREATE OR REPLACE VIEW vw_material_refname_def AS
SELECT
	mrt.material_refname_def_uuid,
	mrt.description,
	mrt.add_date,
	mrt.mod_date
FROM
	material_refname_def mrt
ORDER BY
	2;

DROP TRIGGER IF EXISTS trigger_material_refname_def_upsert ON vw_material_refname_def;
CREATE TRIGGER trigger_material_refname_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_material_refname_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_material_refname_def ( );


----------------------------------------
-- get material_type
-- DROP VIEW vw_material_type
----------------------------------------
CREATE OR REPLACE VIEW vw_material_type AS
SELECT
	mt.material_type_uuid,
	mt.description,
	mt.add_date,
	mt.mod_date
FROM
	material_type mt
ORDER BY
	2;

DROP TRIGGER IF EXISTS trigger_material_type_upsert ON vw_material_type;
CREATE TRIGGER trigger_material_type_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_material_type
FOR EACH ROW
EXECUTE PROCEDURE upsert_material_type ( );


----------------------------------------
-- get materials, all status
-- DROP VIEW vw_material
----------------------------------------
CREATE OR REPLACE VIEW vw_material AS
SELECT
	mat.material_uuid,
	mat.description AS description,
	mat.consumable,
	CASE
		when (select 1 from material_composite where composite_uuid = mat.material_uuid limit 1) is not null then true
		else false
	END as composite_flg,
	mat.actor_uuid AS actor_uuid,
	act.description AS actor_description,
	mat.status_uuid AS status_uuid,
	st.description AS status_description,
	mat.add_date,
	mat.mod_date
FROM
	material mat
LEFT JOIN actor act ON mat.actor_uuid = act.actor_uuid
LEFT JOIN status st ON mat.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_material_upsert ON vw_material;
CREATE TRIGGER trigger_material_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_material
FOR EACH ROW
EXECUTE PROCEDURE upsert_material ( );


----------------------------------------
-- view of material_composite
-- DROP VIEW vw_material_composite
----------------------------------------
CREATE OR REPLACE VIEW vw_material_composite AS
SELECT
	mc.material_composite_uuid,
	mc.composite_uuid,
	m0.description as composite_description,
	CASE
		when (select 1 from material_composite where composite_uuid = mc.component_uuid limit 1) is not null then true
		else false
	END as composite_flg,
	mc.component_uuid,
	m1.description as component_description,
	mc.addressable,	
	mc.actor_uuid,
	mc.status_uuid,
	mc.add_date,
	mc.mod_date
FROM
	material_composite mc
LEFT JOIN material m0 ON mc.composite_uuid = m0.material_uuid
LEFT JOIN material m1 ON mc.component_uuid = m1.material_uuid;

DROP TRIGGER IF EXISTS trigger_material_composite_upsert ON vw_material_composite;
CREATE TRIGGER trigger_material_composite_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_material_composite
FOR EACH ROW
EXECUTE PROCEDURE upsert_material_composite ( );


----------------------------------------
-- view material_x -> material_type_assign
-- DROP VIEW vw_material_type_assign
----------------------------------------
CREATE OR REPLACE VIEW vw_material_type_assign AS
SELECT
	mtx.material_type_x_uuid,
	mtx.material_uuid,
	m.description as material_description,
	mtx.material_type_uuid,	
	mt.description as material_type_description,
	mtx.add_date,
	mtx.mod_date
FROM
	material_type_x mtx
LEFT JOIN material_type mt ON mtx.material_type_uuid = mt.material_type_uuid
LEFT JOIN material m ON mtx.material_uuid = m.material_uuid;

DROP TRIGGER IF EXISTS trigger_material_type_assign_upsert ON vw_material_type_assign;
CREATE TRIGGER trigger_material_type_assign_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_material_type_assign
FOR EACH ROW
EXECUTE PROCEDURE upsert_material_type_assign ( );


----------------------------------------
-- get materials, all status
-- DROP VIEW vw_material_raw
----------------------------------------
CREATE OR REPLACE VIEW vw_material_raw AS
SELECT
	mat.material_uuid,
	mat.description AS description,
	st.status_uuid AS status_uuid,
	st.description AS status_description,
	mt.material_type_uuid,
	mt.description as material_type_description,
	mr.material_refname_def_uuid,
	mrt.description AS material_refname_def,
	mr.description AS material_refname_description,
	mat.add_date,
	mat.mod_date
FROM
	material mat
LEFT JOIN material_refname_x mrx ON mat.material_uuid = mrx.material_uuid
LEFT JOIN material_refname mr ON mrx.material_refname_uuid = mr.material_refname_uuid
LEFT JOIN material_refname_def mrt ON mr.material_refname_def_uuid = mrt.material_refname_def_uuid
LEFT JOIN material_type_x mtx ON mat.material_uuid = mtx.material_uuid
LEFT JOIN material_type mt ON mtx.material_type_uuid = mt.material_type_uuid
LEFT JOIN status st ON mat.status_uuid = st.status_uuid
ORDER BY
mat.material_uuid,
mr.description;


----------------------------------------
-- get materials and assoc refname, all status
-- as a crosstab, with refname types
-- DROP VIEW vw_material_refname cascade;
----------------------------------------
CREATE OR REPLACE VIEW vw_material_refname AS
SELECT
	*
FROM
	crosstab (
		'select material_uuid, description, status_uuid, status_description, add_date, mod_date, material_refname_def, material_refname_description
				   from vw_material_raw where material_type_description = ''catalog'' order by 1, 3',
		'select distinct material_refname_def
				   from vw_material_raw where material_refname_def is not null order by 1' ) AS ct (
		material_uuid uuid,
		description varchar,
		material_status_uuid uuid,
		material_status_description varchar,
		add_date timestamptz,
		mod_date timestamptz,
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
	mat.material_status_uuid,	
	mat.material_status_description,
	mat.add_date AS material_add_date,
	mat.mod_date AS material_mod_date,	
	mat.abbreviation,
	mat.chemical_name,
	mat.inchi,
	mat.inchikey,
	mat.molecular_formula,
	mat.smiles,
	cal.calculation_uuid,
	cal.in_val,
	cal.in_val_type_uuid,
	cal.in_val_value,
	cal.in_val_unit,
	cal.in_val_edocument_uuid,
	cal.in_opt_val,
	cal.in_opt_val_type_uuid,
	cal.in_opt_val_value,
	cal.in_opt_val_unit,
	cal.in_opt_val_edocument_uuid,
	cal.out_val,
	cal.out_val_type_uuid,
	cal.out_val_value,
	cal.out_val_unit,
	cal.out_val_edocument_uuid,
	cal.calculation_alias_name,
	cal.add_date AS calculation_add_date,
	cal.calculation_status_uuid,
	cal.calculation_status_description,
	cal.calculation_def_uuid,
	cal.short_name,
	cal.calc_definition,
	cal.description,
	cal.in_type_uuid,
	cal.out_type_uuid,
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
		get_calculation (smiles ) AS calculation_uuid
	FROM
		vw_material_refname ) vmc
JOIN vw_material_refname mat ON vmc.material_uuid = mat.material_uuid
JOIN vw_calculation cal ON vmc.calculation_uuid = cal.calculation_uuid;


----------------------------------------
-- get materials and all related calculations as a pivot
-- drop view vw_material_calculation_json
----------------------------------------
CREATE OR REPLACE VIEW vw_material_calculation_json AS
SELECT
	vm.material_uuid,
	vm.material_status_uuid,
	vm.material_status_description,
	vm.add_date,
	vm.mod_date,
	vm.abbreviation,
	vm.chemical_name,
	vm.inchi,
	vm.inchikey,
	vm.molecular_formula,
	vm.smiles,
	mc.object_agg AS calculation_json
FROM (
	SELECT
		material_uuid,
		json_object_agg(calculation_alias_name, json_build_object('type', calculation_type_uuid, 'value', calculation_value )
		ORDER BY
			calculation_alias_name DESC ) as object_agg
	FROM (
		SELECT
			vmc.material_uuid,
			vmc.calculation_alias_name,
			max(vmc.out_val_type_uuid::text ) AS calculation_type_uuid,
			max(vmc.out_val_value ) AS calculation_value
		FROM
			vw_material_calculation_raw vmc
		GROUP BY
			vmc.material_uuid,
			vmc.calculation_alias_name
		ORDER BY
			1,
			2 DESC ) s
	GROUP BY
		material_uuid
	ORDER BY
		material_uuid ) mc
LEFT JOIN vw_material_refname vm ON mc.material_uuid = vm.material_uuid;


----------------------------------------
-- view property_def
----------------------------------------
CREATE OR REPLACE VIEW vw_property_def AS
SELECT 
	pd.property_def_uuid,
	pd.description,
	pd.short_description,
	pd.val_type_uuid,
	pd.valunit,
	pd.actor_uuid,
	act.description as actor_description,
	st.status_uuid,
	st.description as status_description,
	pd.add_date,
	pd.mod_date
FROM property_def pd
LEFT JOIN actor act on pd.actor_uuid = act.actor_uuid
LEFT JOIN status st on pd.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_property_def_upsert ON vw_property_def;
CREATE TRIGGER trigger_property_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_property_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_property_def ( );


----------------------------------------
-- view property
----------------------------------------
CREATE OR REPLACE VIEW vw_property AS
SELECT 
	pr.property_uuid,
	pr.property_def_uuid,
	pd.short_description,
	pr.property_val,
	pr.actor_uuid,
	act.description as actor_description,
	st.status_uuid,
	st.description as status_description,
	pr.add_date,
	pr.mod_date
FROM property pr
LEFT JOIN property_def pd on pr.property_def_uuid = pd.property_def_uuid 
LEFT JOIN actor act on pd.actor_uuid = act.actor_uuid
LEFT JOIN status st on pd.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_property_upsert ON vw_property;
CREATE TRIGGER trigger_property_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_property
FOR EACH ROW
EXECUTE PROCEDURE upsert_property ( );


----------------------------------------
-- view material_property
----------------------------------------
CREATE OR REPLACE VIEW vw_material_property AS
SELECT
	px.property_x_uuid,
	mat.material_uuid,
	mat.description,
	pr.property_uuid,
	pr.property_def_uuid,
	pd.description as property_description,
	pd.short_description as property_short_description,	
	-- pr.property_val,
	-- break out the val fields
	(pr.property_val).v_type_uuid,
	vl.val_type,
	(pr.property_val).v_unit as val_unit,
	vl.val_val,	
	pr.actor_uuid as property_actor_uuid,
	act.description as property_actor_description,
	pr.status_uuid as property_status_uuid,
	st.description as property_status_description,
	pr.add_date,
	pr.mod_date
FROM vw_material mat
LEFT JOIN property_x px on mat.material_uuid = px.material_uuid
LEFT JOIN property pr on px.property_uuid = pr.property_uuid
LEFT JOIN property_def pd on pr.property_def_uuid = pd.property_def_uuid
LEFT JOIN actor act on pr.actor_uuid = act.actor_uuid
LEFT JOIN status st on pr.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from get_val (pr.property_val)) vl ON true;

DROP TRIGGER IF EXISTS trigger_material_property_upsert ON vw_material_property;
CREATE TRIGGER trigger_material_property_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_material_property
FOR EACH ROW
EXECUTE PROCEDURE upsert_material_property ( );


----------------------------------------
-- view material_composite_property
----------------------------------------
CREATE OR REPLACE VIEW vw_material_composite_property AS
SELECT
	mc.material_composite_uuid,
	mc.composite_uuid,
	mc.composite_description,
	mc.component_uuid,
	mc.component_description,
	pr.property_uuid,
	pr.property_def_uuid,
	pd.description as property_description,
	pd.short_description as property_short_description,	
	-- pr.property_val,
	-- break out the val fields
	(pr.property_val).v_type_uuid,
	vl.val_type,
	(pr.property_val).v_unit as val_unit,
	vl.val_val,	
	pr.actor_uuid as property_actor_uuid,
	act.description as property_actor_description,
	pr.status_uuid as property_status_uuid,
	st.description as property_status_description,
	pr.add_date,
	pr.mod_date
FROM vw_material_composite mc
LEFT JOIN property_x px on mc.material_composite_uuid = px.material_uuid
LEFT JOIN property pr on px.property_uuid = pr.property_uuid
LEFT JOIN property_def pd on pr.property_def_uuid = pd.property_def_uuid
LEFT JOIN actor act on pr.actor_uuid = act.actor_uuid
LEFT JOIN status st on pr.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from get_val (pr.property_val)) vl ON true;


----------------------------------------
-- view inventory; with links to material, actor, status, edocument, note
----------------------------------------
CREATE OR REPLACE VIEW vw_inventory AS
SELECT
	inv.inventory_uuid,
	inv.description,
	inv.material_uuid,
	mat.description AS material_description,
	mat.consumable as material_consumable,
	mat.composite_flg as material_composite_flg,
	inv.part_no,
	inv.onhand_amt,
	inv.expiration_date,
	inv.location,
	inv.actor_uuid,
	act.description as actor_description,
	inv.status_uuid AS status_uuid,
	st.description AS status_description,
	inv.add_date,
	inv.mod_date
FROM
	inventory inv
LEFT JOIN vw_material mat ON inv.material_uuid = mat.material_uuid
LEFT JOIN actor act ON inv.actor_uuid = act.actor_uuid
LEFT JOIN status st ON inv.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_inventory_upsert ON vw_inventory;
CREATE TRIGGER trigger_inventory_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_inventory
FOR EACH ROW
EXECUTE PROCEDURE upsert_inventory ( );


----------------------------------------
-- get inventory / material, all status
----------------------------------------
CREATE OR REPLACE VIEW vw_inventory_material AS
SELECT
	inv.inventory_uuid,
	inv.description AS inventory_description,
	inv.part_no AS inventory_part_no,
	inv.onhand_amt AS inventory_onhand_amt,
	inv.add_date AS inventory_add_date,
	inv.expiration_date AS inventory_expiration_date,
	inv.location AS inventory_location,
	st.status_uuid AS inventory_status_uuid,	
	st.description AS inventory_status_description,
	inv.actor_uuid,
	act.description as actor_description,
	act.org_full_name,
	inv.material_uuid,
	mat.material_status_uuid,
	mat.material_status_description,
	mat.add_date AS material_add_date,
	mat.chemical_name AS material_name,
	mat.abbreviation AS material_abbreviation,
	mat.inchi AS material_inchi,
	mat.inchikey AS material_inchikey,
	mat.molecular_formula AS material_molecular_formula,
	mat.smiles AS material_smiles
FROM
	inventory inv
LEFT JOIN vw_material_refname mat ON inv.material_uuid = mat.material_uuid
LEFT JOIN vw_actor act ON inv.actor_uuid = act.actor_uuid
LEFT JOIN status st ON inv.status_uuid = st.status_uuid;


----------------------------------------
-- view bom (bill of materials)
----------------------------------------
CREATE OR REPLACE VIEW vw_bom AS
SELECT
	b.bom_uuid,
	b.experiment_uuid,
	exp.description as experiment_description,
	b.description,
	b.actor_uuid,
	act.description as actor_description,
	b.status_uuid,	
	st.description AS status_description,
	b.add_date,
	b.mod_date
FROM
	bom b
LEFT JOIN vw_experiment exp ON b.experiment_uuid = exp.experiment_uuid
LEFT JOIN vw_actor act ON b.actor_uuid = act.actor_uuid
LEFT JOIN status st ON b.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_bom_upsert ON vw_bom;
CREATE TRIGGER trigger_bom_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_bom
FOR EACH ROW
EXECUTE PROCEDURE upsert_bom ( );


----------------------------------------
-- view bom_material
----------------------------------------
CREATE OR REPLACE VIEW vw_bom_material AS
SELECT
	bm.bom_material_uuid,
	bm.bom_uuid,
    bm.description,
	b.description as bom_description,
	bm.inventory_uuid,
	bm.material_composite_uuid,
	CASE
		when bm.material_composite_uuid is not null then mc.component_description
		else i.inventory_description
	end as bom_material_description,	
	bm.alloc_amt_val,
	bm.used_amt_val,
	bm.putback_amt_val,
	b.experiment_uuid,
	exp.description as experiment_description,
	bm.actor_uuid,
	act.description as actor_description,
	bm.status_uuid,	
	st.description AS status_description,
	b.add_date,
	b.mod_date
FROM
	bom_material bm
LEFT JOIN vw_bom b ON bm.bom_uuid = b.bom_uuid
LEFT JOIN vw_inventory_material i ON bm.inventory_uuid = i.inventory_uuid
LEFT JOIN vw_material_composite mc ON bm.material_composite_uuid = mc.material_composite_uuid
LEFT JOIN vw_experiment exp ON b.experiment_uuid = exp.experiment_uuid
LEFT JOIN vw_actor act ON bm.actor_uuid = act.actor_uuid
LEFT JOIN status st ON bm.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_bom_material_upsert ON vw_bom_material;
CREATE TRIGGER trigger_bom_material_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_bom_material
FOR EACH ROW
EXECUTE PROCEDURE upsert_bom_material ( );


----------------------------------------
-- view parameter_def
----------------------------------------
CREATE OR REPLACE VIEW vw_parameter_def AS
SELECT
    pd.parameter_def_uuid,
    pd.description,
	td.description as val_type_description,
	( pd.default_val ).v_type_uuid AS val_type_uuid,
	(select val_val from get_val ( pd.default_val )) AS default_val_val,
	( pd.default_val ).v_unit AS valunit,
    pd.default_val,
    pd.required,
	pd.actor_uuid,
	act.description as actor_description,
	pd.status_uuid,
	st.description as status_description,
	pd.add_date,
	pd.mod_date
FROM parameter_def pd
LEFT JOIN vw_actor act ON pd.actor_uuid = act.actor_uuid
LEFT JOIN status st ON pd.status_uuid = st.status_uuid
LEFT JOIN type_def td ON ( pd.default_val ).v_type_uuid = td.type_def_uuid;

DROP TRIGGER IF EXISTS trigger_parameter_def_upsert ON vw_parameter_def;
CREATE TRIGGER trigger_parameter_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_parameter_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_parameter_def ( );


----------------------------------------
-- view parameter
----------------------------------------
CREATE OR REPLACE VIEW vw_parameter AS
SELECT
	pr.parameter_uuid,
	pr.parameter_def_uuid,
	pd.description as parameter_def_description,
	pr.parameter_val,
    pd.val_type_description,
    pd.valunit,
	pr.actor_uuid,
	act.description as actor_description,
	pr.status_uuid,
	st.description as status_description,
	pr.add_date,
	pr.mod_date,
	px.ref_parameter_uuid,
	px.parameter_x_uuid
FROM parameter pr
LEFT JOIN vw_parameter_def pd on pr.parameter_def_uuid = pd.parameter_def_uuid
LEFT JOIN parameter_x px on pr.parameter_uuid = px.parameter_uuid
LEFT JOIN actor act on pr.actor_uuid = act.actor_uuid
LEFT JOIN status st on pd.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_parameter_upsert ON vw_parameter;
CREATE TRIGGER trigger_parameter_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_parameter
FOR EACH ROW
EXECUTE PROCEDURE upsert_parameter ( );


----------------------------------------
 -- view action_def
----------------------------------------
CREATE OR REPLACE VIEW vw_action_def AS
SELECT
     ad.action_def_uuid,
     ad.description,
     ad.actor_uuid,
     act.description as actor_description,
     ad.status_uuid,
     st.description as status_description,
     ad.add_date,
     ad.mod_date
FROM action_def ad
LEFT JOIN vw_actor act ON ad.actor_uuid = act.actor_uuid
LEFT JOIN status st ON ad.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_action_def_upsert ON vw_action_def;
CREATE TRIGGER trigger_action_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_action_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_action_def ( );


----------------------------------------
 -- view action_parameter_def
----------------------------------------
 CREATE OR REPLACE VIEW vw_action_parameter_def AS
 SELECT
     ad.action_def_uuid,
     ad.description,
     ad.actor_uuid,
     act.description as actor_description,
     ad.status_uuid,
     st.description as status_description,
     ad.add_date,
     ad.mod_date,
     ap.parameter_def_uuid,
     pd.description as parameter_description,
     pd.default_val,
     pd.required,
     pd.val_type_uuid as parameter_val_type_uuid,
     pd.val_type_description as parameter_val_type_description,
     pd.valunit as parameter_unit,
     pd.actor_uuid as parameter_actor_uuid,
     pd.actor_description as parameter_actor_description,
     pd.status_uuid as parameter_status_uuid,
     pd.status_description as parameter_status_description,
     pd.add_date as parameter_add_date,
     pd.mod_date as parameter_mod_date
 FROM action_def ad
 LEFT JOIN vw_actor act ON ad.actor_uuid = act.actor_uuid
 LEFT JOIN action_parameter_def_x ap ON ad.action_def_uuid = ap.action_def_uuid
 LEFT JOIN vw_parameter_def pd ON ap.parameter_def_uuid = pd.parameter_def_uuid
 LEFT JOIN status st ON ad.status_uuid = st.status_uuid;


----------------------------------------
 -- view action
----------------------------------------
CREATE OR REPLACE VIEW vw_action AS
SELECT
    act.action_uuid,
    act.action_def_uuid,
    act.workflow_uuid,
    wf.description as workflow_description,
    act.description as action_description,
    ad.description as action_def_description,
    act.start_date,
    act.end_date,
    act.duration,
    act.repeating,
    act.ref_parameter_uuid,
    act.calculation_def_uuid,
    act.source_material_uuid,
    bms.bom_material_description as source_material_description,
    act.destination_material_uuid,
    bmd.bom_material_description as destination_material_description,
    act.actor_uuid,
    actor.description as actor_description,
    act.status_uuid,
    st.description as status_description,
    act.add_date,
    act.mod_date
FROM action act
LEFT JOIN vw_workflow wf ON act.workflow_uuid = wf.workflow_uuid
LEFT JOIN vw_action_def ad ON act.action_def_uuid = ad.action_def_uuid
LEFT JOIN vw_bom_material bms ON act.source_material_uuid = bms.bom_material_uuid
LEFT JOIN vw_bom_material bmd ON act.destination_material_uuid = bmd.bom_material_uuid
LEFT JOIN vw_actor actor ON act.actor_uuid = actor.actor_uuid
LEFT JOIN vw_status st ON act.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_action_upsert ON vw_action;
CREATE TRIGGER trigger_action_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_action
FOR EACH ROW
EXECUTE PROCEDURE upsert_action ( );


----------------------------------------
 -- view action_parameter_def_json
----------------------------------------
CREATE OR REPLACE VIEW vw_action_parameter_def_json AS
SELECT 
	json_build_object('action_def', 
		json_agg(
			json_build_object(
				'description', a.description, 
				'uuid', a.action_def_uuid,
				'actor', a.actor_description,
				'status', a.status_description,
				'add_date', a.add_date,
				'mod_date', a.mod_date,
				'parameter_def', param
			)
		)
	) action_parameter_def_json
FROM
	vw_action_def a
	LEFT JOIN (
		SELECT
			action_def_uuid,
			json_agg(
				json_build_object(
					'description', p.parameter_description, 
					'uuid', p.parameter_def_uuid,
				    'required', p.required,
				    'default_value', (select get_val_json(p.default_val)),
					'actor', p.parameter_actor_description,
					'status', p.parameter_status_description,
					'add_date', p.parameter_add_date,
					'mod_date', p.parameter_mod_date
				)
			) param
		FROM
			vw_action_parameter_def p
		GROUP BY
			action_def_uuid
	) p 
ON a.action_def_uuid = p.action_def_uuid;

        
----------------------------------------
 -- view action_parameter_def_assign
----------------------------------------
CREATE OR REPLACE VIEW vw_action_parameter_def_assign AS
SELECT
    action_parameter_def_x_uuid,
 	parameter_def_uuid,
 	action_def_uuid,
 	add_date,
 	mod_date
FROM action_parameter_def_x;

DROP TRIGGER IF EXISTS trigger_action_parameter_def_assign ON vw_action_parameter_def_assign;
CREATE TRIGGER trigger_action_parameter_def_assign INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_action_parameter_def_assign
FOR EACH ROW
EXECUTE PROCEDURE upsert_action_parameter_def_assign ( );


----------------------------------------
-- view action_parameter
----------------------------------------
CREATE OR REPLACE VIEW vw_action_parameter AS
SELECT
	a.action_uuid,
	a.action_def_uuid,
	a.action_description,
	a.action_def_description,
	a.actor_uuid as action_actor_uuid,
	acta.description as action_actor_description,
	a.status_uuid as action_status_uuid,
	sta.description as action_status_description,
	a.add_date as action_add_date,
	a.mod_date as action_mod_date,
	p.parameter_uuid,	
	p.parameter_def_uuid,
	p.parameter_def_description,
	p.parameter_val,
	p.actor_uuid as parameter_actor_uuid,
	actp.description as parameter_actor_description,
	p.status_uuid as parameter_status_uuid,
	stp.description as parameter_status_description,	
	p.add_date as parameter_add_date,
	p.mod_date as parameter_mod_date
FROM vw_action a
LEFT JOIN vw_actor acta ON a.actor_uuid = acta.actor_uuid
LEFT JOIN vw_status sta  ON a.status_uuid = sta.status_uuid
LEFT JOIN vw_parameter p ON a.action_uuid = p.ref_parameter_uuid
LEFT JOIN vw_actor actp ON p.actor_uuid = actp.actor_uuid
LEFT JOIN vw_status stp  ON p.status_uuid = stp.status_uuid;

DROP TRIGGER IF EXISTS trigger_action_parameter_upsert ON vw_action_parameter;
CREATE TRIGGER trigger_action_parameter_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_action_parameter
FOR EACH ROW
EXECUTE PROCEDURE upsert_action_parameter ( );


----------------------------------------
-- view action_parameter_json
----------------------------------------
CREATE OR REPLACE VIEW vw_action_parameter_json AS
SELECT
	json_build_object('action',
		json_agg(
			json_build_object(
				'action_uuid', a.action_uuid,
				'action_description', a.action_description,
				'action_def_uuid', a.action_def_uuid,
				'action_def_description', a.action_def_description,
				'action_actor_uuid', a.actor_uuid,				
				'action_actor', a.actor_description,
				'action_status_uuid', a.status_uuid,
				'action_status', a.status_description,
				'action_add_date', a.add_date,
				'action_mod_date', a.mod_date,
				'parameter', param
			)
		)
	) action_parameter_json
FROM
    vw_action a
LEFT JOIN (
SELECT
			action_uuid,
			json_agg(
				json_build_object(
--'action_uuid', p.action_uuid,
				'parameter_def_description', p.parameter_def_description,
				'parameter_def_uuid', p.parameter_def_uuid,
				'parameter_value', (select get_val_json(p.parameter_val)),
				'parameter_actor_uuid', p.parameter_actor_uuid,				
				'parameter_actor', p.parameter_actor_description,
				'parameter_status_uuid', p.parameter_status_uuid,				
				'parameter_status', p.parameter_status_description,
				'parameter_add_date', p.parameter_add_date,
				'parameter_mod_date', p.parameter_mod_date)
			) param
FROM
			vw_action_parameter p
GROUP BY
			action_uuid
	) p
ON a.action_uuid = p.action_uuid;


----------------------------------------
-- view condition_def
-- DROP VIEW vw_condition_def
----------------------------------------
CREATE OR REPLACE VIEW vw_condition_def AS
SELECT
    cd.condition_def_uuid,
    cd.description,
    cd.actor_uuid,
    act.description as actor_description,
    cd.status_uuid,
    st.description as status_description,
    cd.add_date,
	cd.mod_date
FROM condition_def cd
LEFT JOIN vw_actor act ON cd.actor_uuid = act.actor_uuid
LEFT JOIN status st ON cd.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_action_condition_def ON vw_condition_def;
CREATE TRIGGER trigger_condition_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_condition_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_condition_def ( );

	
----------------------------------------
-- view condition_calculation_def_x
-- DROP VIEW vw_condition_calculation_def_x
----------------------------------------
CREATE OR REPLACE VIEW vw_condition_calculation_def_assign AS
SELECT
    ccd.condition_calculation_def_x_uuid,
	ccd.condition_def_uuid,
	cn.description as condition_description,
	ccd.calculation_def_uuid,
	cl.description as calculation_description,
    ccd.add_date,
	ccd.mod_date
FROM condition_calculation_def_x ccd
LEFT JOIN vw_condition_def cn ON ccd.condition_def_uuid = cn.condition_def_uuid
LEFT JOIN vw_calculation_def cl ON ccd.calculation_def_uuid = cl.calculation_def_uuid;

DROP TRIGGER IF EXISTS trigger_condition_calculation_def_assign ON vw_condition_calculation_def_assign;
CREATE TRIGGER trigger_condition_calculation_def_assign INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_condition_calculation_def_assign
FOR EACH ROW
EXECUTE PROCEDURE upsert_condition_calculation_def_assign();


----------------------------------------
-- view condition
-- DROP VIEW vw_condition
----------------------------------------
CREATE OR REPLACE VIEW vw_condition AS
SELECT
    cd.condition_uuid,
    cd.condition_calculation_def_x_uuid,
    cc.condition_def_uuid,
    cc.condition_description,
    cc.calculation_description,
	cd.in_val,
	cd.out_val,
	cd.actor_uuid,
	act.description as actor_description,
	cd.status_uuid,
	st.description as status_description,
    cd.add_date,
	cd.mod_date
FROM condition cd
LEFT JOIN vw_condition_calculation_def_assign cc ON cd.condition_calculation_def_x_uuid = cc.condition_calculation_def_x_uuid 
LEFT JOIN vw_actor act ON cd.actor_uuid = act.actor_uuid
LEFT JOIN status st ON cd.status_uuid = st.status_uuid;	

DROP TRIGGER IF EXISTS trigger_condition ON vw_condition;
CREATE TRIGGER trigger_condition INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_condition
FOR EACH ROW
EXECUTE PROCEDURE upsert_condition();


----------------------------------------
-- view condition
-- DROP VIEW vw_condition_calculation
----------------------------------------
CREATE OR REPLACE VIEW vw_condition_calculation AS
SELECT
    cd.condition_uuid,
    cd.condition_description,
	cd.in_val,
	cd.out_val,
	cd.actor_uuid as condition_actor_uuid,
	act.description as condition_actor_description,
	cd.status_uuid as condition_status_uuid,
	st.description as condition_status_description,
    cd.add_date as condition_add_date,
	cd.mod_date as condition_mod_date,
	cald.calculation_def_uuid,
	cald.short_name as calculation_short_name,
	cald.calc_definition as calculation_calc_definition,
	cald.description as calculation_description,
	cald.actor_uuid as calculation_actor_uuid,
	actc.description as calculation_actor_description,
	cald.status_uuid as calculation_status_uuid,
	stc.description as calculation_status_description,
	cald.add_date as calculation_add_date,
	cald.mod_date as calculation_mod_date
FROM condition c
LEFT JOIN vw_condition_calculation_def_assign cc ON c.condition_calculation_def_x_uuid = cc.condition_calculation_def_x_uuid
LEFT JOIN vw_condition cd ON c.condition_uuid = cd.condition_uuid
LEFT JOIN vw_calculation_def cald ON cc.calculation_def_uuid = cald.calculation_def_uuid
LEFT JOIN vw_actor act ON cd.actor_uuid = act.actor_uuid
LEFT JOIN status st ON cd.status_uuid = st.status_uuid
LEFT JOIN vw_actor actc ON cd.actor_uuid = actc.actor_uuid
LEFT JOIN status stc ON cd.status_uuid = stc.status_uuid
;	


----------------------------------------
-- view condition_path
-- DROP VIEW vw_condition_path
----------------------------------------
CREATE OR REPLACE VIEW vw_condition_path AS
SELECT
    cp.condition_path_uuid,
    cp.condition_uuid,
	cp.condition_out_val,
	cp.workflow_step_uuid,
    cp.add_date,
	cp.mod_date
FROM condition_path cp
LEFT JOIN vw_condition c ON cp.condition_uuid = c.condition_uuid
LEFT JOIN workflow_step ws ON cp.workflow_step_uuid = ws.workflow_step_uuid;	

DROP TRIGGER IF EXISTS trigger_condition_path ON vw_condition_path;
CREATE TRIGGER trigger_condition_path INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_condition_path
FOR EACH ROW
EXECUTE PROCEDURE upsert_condition_path();


----------------------------------------
-- view condition_calculation_json
-- drop view vw_condition_calculation_json
----------------------------------------
CREATE OR REPLACE VIEW vw_condition_calculation_json AS
SELECT
	json_build_object('condition',
	json_agg(
		json_build_object(
			'condition_uuid', c.condition_uuid,
			'condition_description', c.condition_description,
			'condition_def_uuid', c.condition_def_uuid,
			'condition_actor_uuid', c.actor_uuid,
			'condition_actor_description', c.actor_description,
			'condition_status_uuid', c.actor_uuid,
			'condition_status_description', c.status_description,
			'condition_add_date', c.add_date,
			'condition_mod_date', c.mod_date,
			'calculation', calc
			)
		)
	) condition_calculation_json
FROM
    vw_condition c
LEFT JOIN (
SELECT
	condition_uuid,
	json_agg(
		json_build_object(
			'calculation_def_uuid', p.calculation_def_uuid,
			'calculation_short_name', p.calculation_short_name,
			'calculation_calc_definition', p.calculation_calc_definition,
			'calculation_description', p.calculation_description,
			'calculation_in_val', (select get_val_json(p.in_val[1])),
			'calculation_out_val', (select get_val_json(p.out_val[1])),
			'calculation_actor_uuid', p.calculation_actor_uuid,
			'calculation_actor_description', p.calculation_actor_description,
			'calculation_status_uuid', p.calculation_status_uuid,
			'calculation_status_description', p.calculation_status_description,
			'calculation_add_date', p.calculation_add_date,
			'calculation_mod_date', p.calculation_mod_date)
			) calc
FROM
			vw_condition_calculation p
GROUP BY
			condition_uuid
	) p
ON c.condition_uuid = p.condition_uuid;


----------------------------------------
-- view experiment
-- DROP VIEW vw_experiment cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment AS
SELECT
	ex.experiment_uuid,
	ex.ref_uid,
	ex.description,
	ex.parent_uuid,
	ex.parent_path,
	ex.owner_uuid,
	aown.description as owner_description,
	ex.operator_uuid,
	aop.description as operator_description,
	ex.lab_uuid,
	alab.description as lab_description,
	ex.status_uuid,
	st.description as status_description,
	ex.add_date,
	ex.mod_date
FROM experiment ex
LEFT JOIN vw_actor aown ON ex.owner_uuid = aown.actor_uuid
LEFT JOIN vw_actor aop ON ex.owner_uuid = aop.actor_uuid
LEFT JOIN vw_actor alab ON ex.owner_uuid = alab.actor_uuid
LEFT JOIN status st ON ex.status_uuid = st.status_uuid
;

DROP TRIGGER IF EXISTS trigger_experiment_upsert ON vw_experiment;
CREATE TRIGGER trigger_experiment_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_experiment
FOR EACH ROW
EXECUTE PROCEDURE upsert_experiment ( );


CREATE OR REPLACE VIEW vw_exp_spec_def AS
SELECT
    es.exp_spec_def_uuid,
    es.exp_ref_uuid,
    es.description,
    es.add_date,
    es.mod_date
FROM exp_spec_def es;


CREATE OR REPLACE VIEW vw_exp_spec_parameter_def_assign AS
SELECT
       espdx.exp_spec_def_uuid,
       espdx.parameter_def_uuid
FROM exp_spec_parameter_def_x espdx;

----------------------------------------
-- view workflow_type
-- DROP VIEW vw_workflow_type
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_type AS
SELECT
	wt.workflow_type_uuid,
	wt.description,
	wt.add_date,
	wt.mod_date
FROM
	workflow_type wt
ORDER BY
	2;

DROP TRIGGER IF EXISTS trigger_workflow_type_upsert ON vw_workflow_type;
CREATE TRIGGER trigger_workflow_type_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow_type
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow_type ( );


----------------------------------------
-- view workflow
-- DROP VIEW vw_workflow
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow AS
SELECT
	wf.workflow_uuid,
	wf.description,
	wf.parent_uuid,
	wf.workflow_type_uuid,
	wt.description as workflow_type_description,
	wf.actor_uuid,
    act.description as actor_description,	
	wf.status_uuid,
	st.description as status_description, 
	wf.add_date,
	wf.mod_date
FROM
	workflow wf
LEFT JOIN vw_workflow_type wt ON wf.workflow_type_uuid = wt.workflow_type_uuid
LEFT JOIN vw_actor act ON wf.actor_uuid = act.actor_uuid
LEFT JOIN status st ON wf.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_upsert ON vw_workflow;
CREATE TRIGGER trigger_workflow_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow ( );


----------------------------------------
-- view experiment_experiment
-- DROP VIEW vw_experiment_workflow cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_workflow AS
SELECT
	ew.experiment_workflow_uuid,
	e.experiment_uuid,
	e.ref_uid as experiment_ref_uid,
	e.description as experiment_description,
	e.parent_uuid as experiment_parent_uuid,
	e.owner_uuid as experiment_owner_uuid,
	e.owner_description as experiment_owner_description,
	e.operator_uuid as experiment_operator_uuid,
	e.operator_description as experiment_operator_description,
	e.lab_uuid as experiment_lab_uuid,
	e.lab_description as experiment_lab_description,
	e.status_uuid as experiment_status_uuid,
	e.status_description as experiment_status_description,
	e.add_date as experiment_add_date,
	e.mod_date as experiment_mod_date,
	ew.experiment_workflow_seq,
	w.workflow_uuid as workflow_uuid,
	w.description as workflow_description,
	w.workflow_type_uuid,
	w.workflow_type_description,
	w.actor_uuid as workflow_actor_uuid,
	w.actor_description as workflow_actor_description,
	w.status_uuid as workflow_status_uuid,
	w.status_description as workflow_status_description,
	w.add_date as workflow_add_date,
	w.mod_date as workflow_mod_date
FROM experiment_workflow ew 
LEFT JOIN vw_experiment e ON ew.experiment_uuid = e.experiment_uuid 
LEFT JOIN vw_workflow w ON ew.workflow_uuid = w.workflow_uuid;


DROP TRIGGER IF EXISTS trigger_experiment_workflow_upsert ON vw_experiment_workflow;
CREATE TRIGGER trigger_experiment_workflow_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_experiment_workflow
FOR EACH ROW
EXECUTE PROCEDURE upsert_experiment_workflow ( );

----------------------------------------
-- view workflow_object
-- DROP VIEW vw_workflow_object
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_object AS
SELECT
	wo.workflow_object_uuid,
	wo.workflow_uuid,
	wo.action_uuid,
	wo.condition_uuid,
    COALESCE (wo.action_uuid, wo.condition_uuid) as object_uuid,
	CASE
		when wo.action_uuid is not null then 'action'
		when wo.condition_uuid is not null then 'condition'
		else 'node'
	end as object_type,
	CASE
		when wo.action_uuid is not null then a.action_description
		when wo.condition_uuid is not null then c.condition_description
	end as object_description,	
	CASE
		when wo.action_uuid is not null then a.action_def_description
		when wo.condition_uuid is not null then c.calculation_description
	end as object_def_description,
	wo.add_date,
	wo.mod_date
FROM workflow_object wo
LEFT JOIN vw_action a ON wo.action_uuid = a.action_uuid
LEFT JOIN vw_condition c ON wo.condition_uuid = c.condition_uuid
LEFT JOIN vw_condition_calculation_def_assign cc ON c.condition_calculation_def_x_uuid = cc.condition_calculation_def_x_uuid
LEFT JOIN vw_status st ON wo.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_object_upsert ON vw_workflow_object;
CREATE TRIGGER trigger_workflow_object_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow_object
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow_object ( );


----------------------------------------
-- view workflow_step
-- DROP VIEW vw_workflow_step
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_step AS
SELECT
	ws.workflow_step_uuid,
	ws.workflow_uuid,
	wf.description as workflow_description,
	ws.parent_uuid,
	wfo.object_type as parent_object_type,
	wfo.object_description as parent_object_description,
	ws.parent_path,	
	cp.condition_out_val as conditional_val,
	(select val_val from get_val ( cp.condition_out_val )) AS conditional_value,
	ws.status_uuid,
	st.description as status_description,
	ws.add_date,
	ws.mod_date,
	ws.workflow_object_uuid,
	wo.object_uuid,
	wo.object_type,
	wo.object_description,
    wo.object_def_description,
	wo.add_date as object_add_date,
	wo.mod_date as object_mod_date
FROM workflow_step ws
LEFT JOIN workflow_step ws2 ON ws.parent_uuid = ws2.workflow_step_uuid
LEFT JOIN vw_workflow_object wfo ON ws2.workflow_object_uuid = wfo.workflow_object_uuid
LEFT JOIN vw_condition_path cp ON ws.workflow_step_uuid = cp.workflow_step_uuid
LEFT JOIN vw_workflow wf ON ws.workflow_uuid = wf.workflow_uuid
LEFT JOIN vw_workflow_object wo ON ws.workflow_object_uuid = wo.workflow_object_uuid
LEFT JOIN vw_status st ON ws.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_step_upsert ON vw_workflow_step;
CREATE TRIGGER trigger_workflow_step_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow_step
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow_step ( );


----------------------------------------
-- view workflow_action_set
-- DROP VIEW vw_workflow_action_set
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_action_set AS
SELECT
	was.workflow_action_set_uuid,
	was.description,
	was.workflow_uuid,
	wf.description as workflow_description,
	was.action_def_uuid,
	ad.description as action_def_description,
	was.start_date,
	was.end_date,
	was.duration,
	was.repeating,
	was.parameter_def_uuid,
	pd.description as parameter_def_description,
	was.parameter_val,	
	was.calculation_uuid,
	cd.description as calculation_description,
	was.source_material_uuid,
	was.destination_material_uuid, 
	was.actor_uuid,
	act.description as actor_description,
	was.status_uuid,
	st.description as status_description,
	was.add_date,
	was.mod_date
FROM
	workflow_action_set was
LEFT JOIN vw_workflow wf ON was.workflow_uuid = wf.workflow_uuid
LEFT JOIN vw_action_def ad ON was.action_def_uuid = ad.action_def_uuid
LEFT JOIN vw_parameter_def pd ON was.parameter_def_uuid = pd.parameter_def_uuid
LEFT JOIN vw_calculation cd ON was.calculation_uuid = cd.calculation_uuid
LEFT JOIN vw_actor act ON was.actor_uuid = act.actor_uuid
LEFT JOIN status st ON was.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_action_set_upsert ON vw_workflow_action_set;
CREATE TRIGGER trigger_workflow_action_set_upsert INSTEAD OF INSERT
OR DELETE ON vw_workflow_action_set
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow_action_set ( );

----------------------------------------
-- view workflow_step_json
-- DROP VIEW vw_workflow_step_json
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_step_json AS
SELECT * FROM
	(WITH RECURSIVE wf(workflow_step_uuid,  workflow_uuid, workflow_description, workflow_object_uuid, 
		parent_uuid, parent_object_type, parent_object_description, conditional_val, conditional_value, 
		object_uuid, object_type, object_description, status_uuid, status_description) AS (
	    SELECT  w1.workflow_step_uuid,  w1.workflow_uuid, w1.workflow_description, w1.workflow_object_uuid,
	    w1.parent_uuid, w1.parent_object_type, w1.parent_object_description, w1.conditional_val, w1.conditional_value, 
	    w1.object_uuid, w1.object_type, w1.object_description, w1.status_uuid, w1.status_description
	    FROM vw_workflow_step w1 WHERE workflow_step_uuid = (select workflow_step_uuid from vw_workflow_step 
	    	where (parent_uuid is null))
	    UNION ALL
	    SELECT w2.workflow_step_uuid,  w2. workflow_uuid, w2.workflow_description, w2.workflow_object_uuid, 
	    w2.parent_uuid, w2.parent_object_type, w2.parent_object_description, w2.conditional_val, w2.conditional_value, 
	    w2.object_uuid, w2.object_type, w2.object_description, w2.status_uuid, w2.status_description
	    FROM vw_workflow_step w2
	    JOIN wf ON w2.parent_uuid = wf.workflow_step_uuid
	)
	SELECT  
		json_build_object('workflow_step',
		json_agg(
			json_build_object(
				'workflow_step_order', n.ord,
				'workflow_uuid', n.workflow_uuid,
				'workflow_description', n.workflow_description,				
				'workflow_step_uuid', n.workflow_step_uuid,
				'workflow_step_parent_uuid', n.parent_uuid,
				'workflow_step_parent_object_type', n.parent_object_type,
				'workflow_step_parent_object_description', n.parent_object_description,
				'workflow_conditional_val', n.conditional_val,
				'workflow_conditional_value', n.conditional_value,
				'workflow_step_object_uuid', n.object_uuid,
				'workflow_step_object_type', n.object_type,
				'workflow_step_object_description', n.object_description,
				'workflow_step_status_uuid', n.status_uuid,
				'workflow_step_status_description', n.status_description
				)
			)
		)
	FROM 
		(select row_number() over () as ord, * from wf) n) w;


----------------------------------------
-- view workflow_step_object_json
-- DROP VIEW vw_workflow_step_object_json
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_step_object_json AS
WITH RECURSIVE wf(workflow_step_uuid,  workflow_uuid, workflow_description, workflow_object_uuid, 
		parent_uuid, parent_object_type, parent_object_description, conditional_val, conditional_value, 
		object_uuid, object_type, object_description, status_uuid, status_description) AS (
	    SELECT  w1.workflow_step_uuid,  w1.workflow_uuid, w1.workflow_description, w1.workflow_object_uuid,
	    w1.parent_uuid, w1.parent_object_type, w1.parent_object_description, w1.conditional_val, w1.conditional_value, 
	    w1.object_uuid, w1.object_type, w1.object_description, w1.status_uuid, w1.status_description
	    FROM vw_workflow_step w1 WHERE workflow_step_uuid = (select workflow_step_uuid from vw_workflow_step 
	    	where (parent_uuid is null))
	    UNION ALL
	    SELECT w2.workflow_step_uuid,  w2. workflow_uuid, w2.workflow_description, w2.workflow_object_uuid, 
	    w2.parent_uuid, w2.parent_object_type, w2.parent_object_description, w2.conditional_val, w2.conditional_value, 
	    w2.object_uuid, w2.object_type, w2.object_description, w2.status_uuid, w2.status_description
	    FROM vw_workflow_step w2
	    JOIN wf ON w2.parent_uuid = wf.workflow_step_uuid
	)
	SELECT 
		json_build_object('workflow_step',
		json_agg(
			json_build_object(
				'workflow_step_uuid', n.workflow_step_uuid,
				'workflow_step_order', n.ord,
				'workflow_uuid', n.workflow_uuid,
				'workflow_description', n.workflow_description,
				'workflow_step_status_uuid', n.status_uuid,
				'workflow_step_status_description', n.status_description,				
				'workflow_step_parent_uuid', n.parent_uuid,
				'workflow_step_parent_object_type', n.parent_object_type,
				'workflow_step_parent_object_description', n.parent_object_description,
				'workflow_conditional_val', n.conditional_val,
				'workflow_conditional_value', n.conditional_value,
				'object', wfs)
			)
		)
	FROM 
		(select row_number() over () as ord, * from wf) n
JOIN (
	SELECT
		workflow_step_uuid,
		json_agg(
		json_build_object(
			'workflow_object_uuid', ws.workflow_object_uuid,
			'object_uuid', ws.object_uuid,
			'object_type', ws.object_type,
			'object_description', ws.object_description,
			'object_def_description', ws.object_def_description,
			'object_add_date', ws.object_add_date,
			'object_mod_date', ws.object_mod_date)
		) wfs
	FROM vw_workflow_step ws
	GROUP BY workflow_step_uuid
) wo
ON n.workflow_step_uuid = wo.workflow_step_uuid;


----------------------------------------
-- view workflow_json
-- DROP VIEW vw_workflow_json
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_json AS
SELECT
	json_build_object('workflow',
		json_agg(
			json_build_object(
				'workflow_uuid', w.workflow_uuid,
				'workflow_description', w.description,
				'workflow_parent_uuid', w.parent_uuid,
				'workflow_actor_uuid', w.actor_uuid,				
				'workflow_actor_description', w.actor_description,
				'workflow_status_uuid', w.status_uuid,
				'workflow_status_description', w.status_description,
				'workflow_add_date', w.add_date,
				'workflow_mod_date', w.mod_date				
			)
		)
	) workflow_json
FROM
    vw_workflow w;


----------------------------------------
-- view experiment_workflow_json
-- drop view vw_experiment_workflow_json
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_workflow_json AS
SELECT
	json_build_object('experiment',
	json_agg(
		json_build_object(
			'experiment_uuid', e.experiment_uuid,
			'experiment_ref_uid', e.ref_uid,
			'experiment_description', e.description,
			'experiment_parent_uuid', e.parent_uuid,
			'experiment_owner_uuid', e.owner_uuid,
			'experiment_owner_description', e.owner_description,
			'experiment_operator_uuid', e.operator_uuid,
			'experiment_operator_description', e.operator_description,
			'experiment_lab_uuid', e.lab_uuid,
			'experiment_lab_description', e.lab_description,
			'experiment_status_uuid', e.status_uuid,
			'experiment_status_description', e.status_description,
			'experiment_add_date', e.add_date,
			'experiment_mod_date', e.mod_date,
			'workflow', wf)
		)
	) experiment_workflow_json
FROM
    vw_experiment e
JOIN (
SELECT
	experiment_uuid,
	json_agg(
		json_build_object(
			'workflow_seq', p.experiment_workflow_seq,		
			'workflow_uuid', p.workflow_uuid,
			'workflow_description', p.workflow_description,
			'workflow_type_uuid', p.workflow_type_uuid,
			'workflow_type_description', p.workflow_type_description,
			'workflow_actor_uuid', p.workflow_actor_uuid,
			'workflow_actor_description', p.workflow_actor_description,
			'workflow_status_uuid', p.workflow_status_uuid,
			'workflow_status_description', p.workflow_status_description,
			'workflow_add_date', p.workflow_add_date,
			'workflow_mod_date', p.workflow_mod_date)
			) wf
FROM
			vw_experiment_workflow p
GROUP BY
			experiment_uuid
	) p
ON e.experiment_uuid = p.experiment_uuid;


----------------------------------------
-- view experiment_workflow_step_json
-- drop view vw_experiment_workflow_step_json
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_workflow_step_json AS
SELECT
	json_build_object('experiment',
	json_agg(
		json_build_object(
			'experiment_uuid', e.experiment_uuid,
			'experiment_ref_uid', e.ref_uid,
			'experiment_description', e.description,
			'experiment_parent_uuid', e.parent_uuid,
			'experiment_owner_uuid', e.owner_uuid,
			'experiment_owner_description', e.owner_description,
			'experiment_operator_uuid', e.operator_uuid,
			'experiment_operator_description', e.operator_description,
			'experiment_lab_uuid', e.lab_uuid,
			'experiment_lab_description', e.lab_description,
			'experiment_status_uuid', e.status_uuid,
			'experiment_status_description', e.status_description,
			'experiment_add_date', e.add_date,
			'experiment_mod_date', e.mod_date,
			'workflow', wf
			)
		)
	) experiment_workflow_json
FROM
    vw_experiment e
JOIN (
	SELECT
		p.experiment_uuid,
		json_agg(
			json_build_object(
				'workflow_seq', p.experiment_workflow_seq,		
				'workflow_uuid', p.workflow_uuid,
				'workflow_description', p.workflow_description,
				'workflow_type_uuid', p.workflow_type_uuid,
				'workflow_type_description', p.workflow_type_description,
				'workflow_actor_uuid', p.workflow_actor_uuid,
				'workflow_actor_description', p.workflow_actor_description,
				'workflow_status_uuid', p.workflow_status_uuid,
				'workflow_status_description', p.workflow_status_description,
				'workflow_add_date', p.workflow_add_date,
				'workflow_mod_date', p.workflow_mod_date,
				'workflow_step', wfs)
				) wf
	FROM
		vw_experiment_workflow p
	LEFT JOIN 
		(SELECT * FROM
			(WITH RECURSIVE wf(workflow_step_uuid,  workflow_uuid, workflow_description, workflow_object_uuid, 
				parent_uuid, parent_object_type, parent_object_description, conditional_val, conditional_value, 
				object_uuid, object_type, object_description, status_uuid, status_description) AS (
			    SELECT  w1.workflow_step_uuid,  w1.workflow_uuid, w1.workflow_description, w1.workflow_object_uuid,
			    w1.parent_uuid, w1.parent_object_type, w1.parent_object_description, w1.conditional_val, w1.conditional_value, 
			    w1.object_uuid, w1.object_type, w1.object_description, w1.status_uuid, w1.status_description
			    FROM vw_workflow_step w1 WHERE workflow_step_uuid = (select workflow_step_uuid from vw_workflow_step 
			    	where (parent_uuid is null))
			    UNION ALL
			    SELECT w2.workflow_step_uuid,  w2. workflow_uuid, w2.workflow_description, w2.workflow_object_uuid, 
			    w2.parent_uuid, w2.parent_object_type, w2.parent_object_description, w2.conditional_val, w2.conditional_value, 
			    w2.object_uuid, w2.object_type, w2.object_description, w2.status_uuid, w2.status_description
			    FROM vw_workflow_step w2
			    JOIN wf ON w2.parent_uuid = wf.workflow_step_uuid
			)
			SELECT
				workflow_uuid, 
				json_build_object('workflow_step',
				json_agg(
					json_build_object(
						'workflow_step_order', n.ord,
						'workflow_uuid', n.workflow_uuid,
						'workflow_description', n.workflow_description,				
						'workflow_step_uuid', n.workflow_step_uuid,
						'workflow_step_parent_uuid', n.parent_uuid,
						'workflow_step_parent_object_type', n.parent_object_type,
						'workflow_step_parent_object_description', n.parent_object_description,
						'workflow_conditional_val', n.conditional_val,
						'workflow_conditional_value', n.conditional_value,
						'workflow_step_object_uuid', n.object_uuid,
						'workflow_step_object_type', n.object_type,
						'workflow_step_object_description', n.object_description,
						'workflow_step_status_uuid', n.status_uuid,
						'workflow_step_status_description', n.status_description)
					)
				) wfs
			FROM 
				(select row_number() over () as ord, * from wf) n
			GROUP BY workflow_uuid) p ) w
	ON p.workflow_uuid = w.workflow_uuid				
	GROUP BY p.experiment_uuid) p
ON e.experiment_uuid = p.experiment_uuid;


----------------------------------------
-- view experiment_workflow_step_object_json
-- drop view vw_experiment_workflow_step_object_json
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_workflow_step_object_json AS
SELECT
	e.experiment_uuid,
	json_build_object('experiment',
	json_agg(
		json_build_object(
			'experiment_uuid', e.experiment_uuid,
			'experiment_ref_uid', e.experiment_ref_uid,
			'experiment_description', e.experiment_description,
			'experiment_parent_uuid', e.experiment_parent_uuid,
			'experiment_owner_uuid', e.experiment_owner_uuid,
			'experiment_owner_description', e.experiment_owner_description,
			'experiment_operator_uuid', e.experiment_operator_uuid,
			'experiment_operator_description', e.experiment_operator_description,
			'experiment_lab_uuid', e.experiment_lab_uuid,
			'experiment_lab_description', e.experiment_lab_description,
			'experiment_status_uuid', e.experiment_status_uuid,
			'experiment_status_description', e.experiment_status_description,
			'experiment_add_date', e.experiment_add_date,
			'experiment_mod_date', e.experiment_mod_date,
			'workflow', wf
			)
		)
	) experiment_workflow_json
FROM
    vw_experiment_workflow e
JOIN (
	SELECT
		p.experiment_uuid,
		json_agg(
			json_build_object(
				'workflow_seq', p.experiment_workflow_seq,		
				'workflow_uuid', p.workflow_uuid,
				'workflow_description', p.workflow_description,
				'workflow_type_uuid', p.workflow_type_uuid,
				'workflow_type_description', p.workflow_type_description,
				'workflow_actor_uuid', p.workflow_actor_uuid,
				'workflow_actor_description', p.workflow_actor_description,
				'workflow_status_uuid', p.workflow_status_uuid,
				'workflow_status_description', p.workflow_status_description,
				'workflow_add_date', p.workflow_add_date,
				'workflow_mod_date', p.workflow_mod_date,
				'workflow_step', wfso)
				) wf
	FROM
		vw_experiment_workflow p
	LEFT JOIN 
	(
		WITH RECURSIVE wf(workflow_step_uuid,  workflow_uuid, workflow_description, workflow_object_uuid, 
				parent_uuid, parent_object_type, parent_object_description, conditional_val, conditional_value, 
				object_uuid, object_type, object_description, status_uuid, status_description) AS (
			    SELECT  w1.workflow_step_uuid,  w1.workflow_uuid, w1.workflow_description, w1.workflow_object_uuid,
			    w1.parent_uuid, w1.parent_object_type, w1.parent_object_description, w1.conditional_val, w1.conditional_value, 
			    w1.object_uuid, w1.object_type, w1.object_description, w1.status_uuid, w1.status_description
			    FROM vw_workflow_step w1 WHERE workflow_step_uuid = (select workflow_step_uuid from vw_workflow_step 
			    	where (parent_uuid is null))
			    UNION ALL
			    SELECT w2.workflow_step_uuid,  w2. workflow_uuid, w2.workflow_description, w2.workflow_object_uuid, 
			    w2.parent_uuid, w2.parent_object_type, w2.parent_object_description, w2.conditional_val, w2.conditional_value, 
			    w2.object_uuid, w2.object_type, w2.object_description, w2.status_uuid, w2.status_description
			    FROM vw_workflow_step w2
			    JOIN wf ON w2.parent_uuid = wf.workflow_step_uuid
			)
			SELECT
			 	workflow_uuid,
				json_agg(
					json_build_object(
						'workflow_step_uuid', n.workflow_step_uuid,
						'workflow_step_order', n.ord,
						'workflow_uuid', n.workflow_uuid,
						'workflow_description', n.workflow_description,
						'workflow_step_status_uuid', n.status_uuid,
						'workflow_step_status_description', n.status_description,				
						'workflow_step_parent_uuid', n.parent_uuid,
						'workflow_step_parent_object_type', n.parent_object_type,
						'workflow_step_parent_object_description', n.parent_object_description,
						'workflow_conditional_val', n.conditional_val,
						'workflow_conditional_value', n.conditional_value,
						'object', wfs)
				) wfso
			FROM 
				(select row_number() over () as ord, * from wf) n
		JOIN (
			SELECT
				workflow_step_uuid,
				json_agg(
				json_build_object(
					'workflow_object_uuid', ws.workflow_object_uuid,
					'object_uuid', ws.object_uuid,
					'object_type', ws.object_type,
					'object_description', ws.object_description,
					'object_def_description', ws.object_def_description,
					'object_add_date', ws.object_add_date,
					'object_mod_date', ws.object_mod_date)
				) wfs
			FROM vw_workflow_step ws
			GROUP BY workflow_step_uuid
		) wo
		ON n.workflow_step_uuid = wo.workflow_step_uuid
		GROUP BY workflow_uuid	
	) w
	ON p.workflow_uuid = w.workflow_uuid				
	GROUP BY p.experiment_uuid) p
ON e.experiment_uuid = p.experiment_uuid
GROUP BY e.experiment_uuid;


-- =======================================
-- TESTING ONLY
-- =======================================
----------------------------------------
-- get experiments, measures, calculations
-- drop view vw_experiment_measure_calculation;
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_measure_calculation AS
SELECT
	*
FROM ((
		SELECT
			'wf1_iodides' AS dataset_type,
			*
		FROM
			load_v2_iodides
		ORDER BY
			_exp_no )
	UNION (
		SELECT
			'wf1_bromides' AS dataset_type,
			*
		FROM
			load_v2_bromides
		ORDER BY
			_exp_no )
	UNION (
		SELECT
			'wf3_iodides' AS dataset_type,
			*
		FROM
			load_v2_wf3_iodides
		ORDER BY
			_exp_no )
	UNION (
		SELECT
			'wf3_alloying' AS dataset_type,
			*
		FROM
			load_v2_wf3_alloying
		ORDER BY
			_exp_no ) ) s;


----------------------------------------
-- get experiments, measures, calculations in json
-- drop view vw_experiment_measure_calculation_json;
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_measure_calculation_json AS
SELECT
	_exp_no AS UID,
	row_to_json(
		s )
FROM ((
		SELECT
			'wf1_iodides' AS dataset_type,
			*
		FROM
			load_v2_iodides
		ORDER BY
			_exp_no )
	UNION (
		SELECT
			'wf1_bromides' AS dataset_type,
			*
		FROM
			load_v2_bromides
		ORDER BY
			_exp_no )
	UNION (
		SELECT
			'wf3_iodides' AS dataset_type,
			*
		FROM
			load_v2_wf3_iodides
		ORDER BY
			_exp_no )
	UNION (
		SELECT
			'wf3_alloying' AS dataset_type,
			*
		FROM
			load_v2_wf3_alloying
		ORDER BY
			_exp_no ) ) s;
			
	