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
	act.actor_uuid,
	act.description AS actor_description,
	nt.add_date,
	nt.mod_date,
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
	ud.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	udf_def ud
LEFT JOIN type_def td on ud.val_type_uuid = td.type_def_uuid
LEFT JOIN LATERAL (select * from tag_to_array (udf_def_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (udf_def_uuid)) anote ON true;

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
	udx.ref_udf_uuid,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	udf ud
LEFT JOIN udf_x udx on ud.udf_uuid = udx.udf_uuid
LEFT JOIN udf_def udef on ud.udf_def_uuid = udef.udf_def_uuid
LEFT JOIN type_def td on udef.val_type_uuid = td.type_def_uuid
LEFT JOIN LATERAL (select * from tag_to_array (ud.udf_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (ud.udf_uuid)) anote ON true;

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
	org.full_name AS organization_full_name,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	person per
LEFT JOIN organization org ON per.organization_uuid = org.organization_uuid
LEFT JOIN LATERAL (select * from tag_to_array (person_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (person_uuid)) anote ON true;

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
	org.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	organization org
LEFT JOIN organization orgp ON org.parent_uuid = orgp.organization_uuid
LEFT JOIN LATERAL (select * from tag_to_array (org.organization_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (org.organization_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_organization_upsert ON vw_organization;
CREATE TRIGGER trigger_organization_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_organization
FOR EACH ROW
EXECUTE PROCEDURE upsert_organization ( );


----------------------------------------
-- view of actor
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
    porg.organization_uuid as person_organization_uuid,
    porg.description as person_organization_description,
	st.systemtool_name,
	st.description AS systemtool_description,
	stt.description AS systemtool_type,
	vorg.full_name AS systemtool_vendor,
	st.model AS systemtool_model,
	st.serial AS systemtool_serial,
	st.ver AS systemtool_version,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	actor act
LEFT JOIN organization org ON act.organization_uuid = org.organization_uuid
LEFT JOIN person per ON act.person_uuid = per.person_uuid
LEFT JOIN organization porg ON per.organization_uuid = porg.organization_uuid
LEFT JOIN systemtool st ON act.systemtool_uuid = st.systemtool_uuid
LEFT JOIN systemtool_type stt ON st.systemtool_type_uuid = stt.systemtool_type_uuid
LEFT JOIN organization vorg ON st.vendor_organization_uuid = vorg.organization_uuid
LEFT JOIN status sts ON act.status_uuid = sts.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (actor_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (actor_uuid)) anote ON true;

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
	vst.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	systemtool vst
LEFT JOIN organization org ON vst.vendor_organization_uuid = org.organization_uuid
LEFT JOIN systemtool_type stt ON vst.systemtool_type_uuid = stt.systemtool_type_uuid
LEFT JOIN LATERAL (select * from tag_to_array (systemtool_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (systemtool_uuid)) anote ON true;

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
LEFT JOIN actor act ON mt.actor_uuid = act.actor_uuid
LEFT JOIN status st ON mt.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_measure_type_upsert ON vw_measure_type;
CREATE TRIGGER trigger_measure_type_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_measure_type
FOR EACH ROW
EXECUTE PROCEDURE upsert_measure_type ( );


----------------------------------------
-- view measure_def
-- DROP VIEW vw_measure_def cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_measure_def AS
SELECT
	md.measure_def_uuid,
	md.default_measure_type_uuid,
	md.description,
	md.default_measure_value,
	( md.default_measure_value ).v_type_uuid AS default_measure_value_type_uuid,
	(select val_val from get_val ( md.default_measure_value )) AS default_measure_value_value,
	( md.default_measure_value ).v_unit AS default_measure_value_unit,
    md.property_def_uuid,
    pd.description as property_def_description,
    pd.short_description as property_def_short_description,
	md.actor_uuid,
	act.description as actor_description,
	md.status_uuid,
	st.description as status_description,
	md.add_date,
	md.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	measure_def md
LEFT JOIN property_def pd ON md.property_def_uuid = pd.property_def_uuid
LEFT JOIN actor act ON md.actor_uuid = act.actor_uuid
LEFT JOIN status st ON md.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (measure_def_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (measure_def_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_measure_def_upsert ON vw_measure_def;
CREATE TRIGGER trigger_measure_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_measure_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_measure_def ( );


----------------------------------------
-- view measure
-- DROP VIEW vw_measure cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_measure AS
SELECT
	m.measure_uuid,
    m.measure_def_uuid,
    md.description as measure_def_description,
	m.measure_type_uuid,
    mt.description as measure_type_description,
	mx.ref_measure_uuid,
	m.description,
	m.measure_value,
	( m.measure_value ).v_type_uuid AS measure_value_type_uuid,
    td.description as measure_value_type_description,
	(select val_val from get_val ( m.measure_value )) AS measure_value_value,
	( m.measure_value ).v_unit AS measure_value_unit,
	m.actor_uuid,
	act.description as actor_description,
	m.status_uuid,
	st.description as status_description,
	m.add_date,
	m.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	measure m
LEFT JOIN measure_def md ON m.measure_def_uuid = md.measure_def_uuid
LEFT JOIN measure_x mx ON m.measure_uuid = mx.measure_uuid
LEFT JOIN measure_type mt ON m.measure_type_uuid = mt.measure_type_uuid
LEFT JOIN type_def td ON ( m.measure_value ).v_type_uuid = td.type_def_uuid
LEFT JOIN actor act ON m.actor_uuid = act.actor_uuid
LEFT JOIN status st ON m.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (m.measure_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (m.measure_uuid)) anote ON true;

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
    ex.experiment_type_uuid,
    et.description as experiment_type,
	ex.ref_uid,
	ex.description,
	ex.parent_uuid,
    exp.description as parent_description,
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
	ex.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM experiment ex
LEFT JOIN experiment_type et ON ex.experiment_type_uuid = et.experiment_type_uuid
LEFT JOIN experiment exp ON ex.parent_uuid = exp.experiment_uuid
LEFT JOIN actor aown ON ex.owner_uuid = aown.actor_uuid
LEFT JOIN actor aop ON ex.owner_uuid = aop.actor_uuid
LEFT JOIN actor alab ON ex.owner_uuid = alab.actor_uuid
LEFT JOIN status st ON ex.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (ex.experiment_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (ex.experiment_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_experiment_upsert ON vw_experiment;
CREATE TRIGGER trigger_experiment_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_experiment
FOR EACH ROW
EXECUTE PROCEDURE upsert_experiment ( );


----------------------------------------
-- view experiment_type
-- DROP VIEW vw_experiment_type cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_type AS
SELECT
	et.experiment_type_uuid,
    et.description,
    et.actor_uuid,
    act.description as actor_description,
    et.status_uuid,
    st.description as status_description,
	et.add_date,
	et.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM experiment_type et
LEFT JOIN actor act ON et.actor_uuid = act.actor_uuid
LEFT JOIN status st ON et.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (experiment_type_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (experiment_type_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_experiment_type_upsert ON vw_experiment_type;
CREATE TRIGGER trigger_experiment_type_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_experiment_type
FOR EACH ROW
EXECUTE PROCEDURE upsert_experiment_type ( );


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
	wf.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	workflow wf
LEFT JOIN workflow_type wt ON wf.workflow_type_uuid = wt.workflow_type_uuid
LEFT JOIN actor act ON wf.actor_uuid = act.actor_uuid
LEFT JOIN status st ON wf.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (workflow_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (workflow_uuid)) anote ON true;

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
    e.tags as experiment_tags,
    e.notes as experiment_notes,
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
	w.mod_date as workflow_mod_date,
    w.tags as workflow_tags,
    w.notes as workflow_notes
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
-- view outcome
-- DROP VIEW vw_outcome cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_outcome AS
SELECT
	o.outcome_uuid,
	o.description,
    o.experiment_uuid,
	o.actor_uuid,
	act.description as actor_description,
	o.status_uuid,
	st.description AS status_description,
	o.add_date,
	o.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	outcome o
LEFT JOIN vw_experiment exp ON o.experiment_uuid = exp.experiment_uuid
LEFT JOIN vw_actor act ON o.actor_uuid = act.actor_uuid
LEFT JOIN status st ON o.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (outcome_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (outcome_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_outcome_upsert ON vw_outcome;
CREATE TRIGGER trigger_outcome_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_outcome
FOR EACH ROW
EXECUTE PROCEDURE upsert_outcome ( );


----------------------------------------
-- view outcome_measure
-- DROP VIEW vw_outcome cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_outcome_measure AS
SELECT
	o.outcome_uuid,
	o.description,
    o.experiment_uuid,
    exp.description as experiment_description,
    o.actor_uuid,
	act.description as outcome_actor_description,
	o.status_uuid,
	st.description AS outcome_status_description,
	o.add_date as outcome_add_date,
	o.mod_date as outcome_mod_date,
    o.tags as outcome_tags,
    o.notes as outcome_notes,
    m.measure_uuid,
    m.description as measure_description,
    m.measure_type_uuid,
    m.measure_type_description,
    m.measure_value,
    m.measure_value_type_uuid,
    m.measure_value_type_description,
    m.measure_value_value,
    m.measure_value_unit,
    m.actor_uuid as measure_actor_uuid,
	actm.description as measure_actor_description,
	m.status_uuid as measure_status_uuid,
	stm.description AS measure_status_description,
	m.add_date as measure_add_date,
	m.mod_date as measure_mod_date,
    m.tags as measure_tags,
    m.notes as measure_notes
FROM
	vw_outcome o
LEFT JOIN vw_measure m ON o.outcome_uuid = m.ref_measure_uuid
LEFT JOIN vw_experiment exp ON o.experiment_uuid = exp.experiment_uuid
LEFT JOIN vw_actor act ON o.actor_uuid = act.actor_uuid
LEFT JOIN vw_actor actm ON m.actor_uuid = actm.actor_uuid
LEFT JOIN vw_status st ON o.status_uuid = st.status_uuid
LEFT JOIN vw_status stm ON m.status_uuid = stm.status_uuid;


----------------------------------------
-- get the calculation_def and associated actor
----------------------------------------
CREATE OR REPLACE VIEW vw_calculation_def AS
SELECT
	cd.calculation_def_uuid,
	cd.short_name,
	cd.calc_definition,
	cd.description,
	cd.in_source_uuid,
	cd.in_type_uuid,
	tdi.description as in_type_description,
	cd.in_opt_source_uuid,
	cd.in_opt_type_uuid,
	tdio.description as in_opt_type_description,
	cd.out_type_uuid,
    cd.out_unit,
	tdo.description as out_type_description,
	cd.systemtool_uuid,
	st.systemtool_name,
	stt.description AS systemtool_type_description,
	org.short_name AS systemtool_vendor_organization,
	st.ver AS systemtool_version,
	cd.actor_uuid AS actor_uuid,
	act.description AS actor_description,
	sts.status_uuid as status_uuid,
	sts.description as status_description,
	cd.calculation_class_uuid,
	cd.add_date,
	cd.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	calculation_def cd
LEFT JOIN vw_actor act ON cd.actor_uuid = act.actor_uuid
LEFT JOIN vw_systemtool st ON cd.systemtool_uuid = st.systemtool_uuid
LEFT JOIN vw_type_def tdi ON cd.in_type_uuid = tdi.type_def_uuid
LEFT JOIN vw_type_def tdio ON cd.in_opt_type_uuid = tdio.type_def_uuid
LEFT JOIN vw_type_def tdo ON cd.out_type_uuid = tdo.type_def_uuid
LEFT JOIN systemtool_type stt ON st.systemtool_type_uuid = stt.systemtool_type_uuid
LEFT JOIN organization org ON st.vendor_organization_uuid = org.organization_uuid
LEFT JOIN status sts ON cd.status_uuid = sts.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (calculation_def_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (calculation_def_uuid)) anote ON true;

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
    md.actor_uuid as calculation_actor_uuid,
    dact.description as calculation_actor_description,
	sts.status_uuid AS calculation_status_uuid,
	sts.description AS calculation_status_description,
    atag.tag_to_array AS calculation_tags,
    anote.note_to_array AS calculation_notes,
	cd.*
FROM
	calculation md
LEFT JOIN vw_calculation_def cd ON md.calculation_def_uuid = cd.calculation_def_uuid
LEFT JOIN vw_edocument ed ON (
	md.out_val ).v_edocument_uuid = ed.edocument_uuid
LEFT JOIN actor dact ON md.actor_uuid = dact.actor_uuid
LEFT JOIN status sts ON md.status_uuid = sts.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (calculation_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (calculation_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_calculation_upsert ON vw_calculation;
CREATE TRIGGER trigger_calculation_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_calculation
FOR EACH ROW
EXECUTE PROCEDURE upsert_calculation ( );


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
-- DROP VIEW vw_material CASCADE
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
	mat.material_class,
	mat.actor_uuid AS actor_uuid,
	act.description AS actor_description,
	mat.status_uuid AS status_uuid,
	st.description AS status_description,
	mat.add_date,
	mat.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	material mat
LEFT JOIN actor act ON mat.actor_uuid = act.actor_uuid
LEFT JOIN status st ON mat.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (material_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (material_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_material_upsert ON vw_material;
CREATE TRIGGER trigger_material_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_material
FOR EACH ROW
EXECUTE PROCEDURE upsert_material ( );


----------------------------------------
-- view of material_composite
-- DROP VIEW vw_material_composite cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_material_composite AS
SELECT 
	mc.material_composite_uuid,
    mc.composite_uuid,
    m0.description  AS composite_description,
    m0.material_class AS composite_class,
    CASE
    	WHEN ((SELECT 1 FROM material_composite WHERE material_composite.composite_uuid = mc.component_uuid LIMIT 1)) IS NOT NULL THEN 
    		true
        ELSE false
    END AS composite_flg,
    mc.component_uuid,
	m1.description  AS component_description,
	m1.material_class AS component_class,
	mc.addressable,
	mc.actor_uuid,
	act.description AS actor_description,
	mc.status_uuid,
	sts.description AS status_description,
	mc.add_date,
	mc.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM material_composite mc
JOIN material m0 ON mc.composite_uuid = m0.material_uuid
JOIN material m1 ON mc.component_uuid = m1.material_uuid
LEFT JOIN vw_actor act ON mc.actor_uuid = act.actor_uuid
LEFT JOIN vw_status sts ON mc.status_uuid = sts.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (material_composite_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (material_composite_uuid)) anote ON true;

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
    pd.property_def_unit_type,
	pd.actor_uuid,
    pd.property_def_class,
	act.description as actor_description,
	st.status_uuid,
	st.description as status_description,
	pd.add_date,
	pd.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM property_def pd
LEFT JOIN vw_actor act on pd.actor_uuid = act.actor_uuid
LEFT JOIN vw_status st on pd.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (property_def_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (property_def_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_property_def_upsert ON vw_property_def;
CREATE TRIGGER trigger_property_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_property_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_property_def ( );


----------------------------------------
-- view property
-- DROP VIEW vw_property;
----------------------------------------
CREATE OR REPLACE VIEW vw_property AS
SELECT 
	pr.property_uuid,
	pr.property_def_uuid,
	pd.short_description,
    pd.property_def_unit_type,
	pr.property_val,
	pr.actor_uuid,
    pr.property_class,
	act.description as actor_description,
	st.status_uuid,
	st.description as status_description,
	pr.add_date,
	pr.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM property pr
JOIN vw_property_def pd on pr.property_def_uuid = pd.property_def_uuid
LEFT JOIN vw_actor act on pd.actor_uuid = act.actor_uuid
LEFT JOIN vw_status st on pd.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (property_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (property_uuid)) anote ON true;

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
    mat.material_class,
    pd.property_def_class,
    pr.property_class,
	pd.description as property_description,
	pd.short_description as property_short_description,	
	pr.property_val as property_value_val,
	-- break out the val fields
	(pr.property_val).v_type_uuid as property_value_type_uuid,
	vl.val_type as property_value_type_description,
	(pr.property_val).v_unit as property_value_unit,
	vl.val_val as property_value,
	pr.actor_uuid as property_actor_uuid,
	act.description as property_actor_description,
	pr.status_uuid as property_status_uuid,
	st.description as property_status_description,
	pr.add_date as property_add_date,
	pr.mod_date as property_mod_date,
    pr.tags as property_tags,
    pr.notes as property_notes
FROM vw_material mat
JOIN property_x px on mat.material_uuid = px.material_uuid
JOIN vw_property pr on px.property_uuid = pr.property_uuid
JOIN property_def pd on pr.property_def_uuid = pd.property_def_uuid
LEFT JOIN vw_actor act on pr.actor_uuid = act.actor_uuid
LEFT JOIN vw_status st on pr.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from get_val (pr.property_val)) vl ON true;

DROP TRIGGER IF EXISTS trigger_material_property_upsert ON vw_material_property;
CREATE TRIGGER trigger_material_property_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_material_property
FOR EACH ROW
EXECUTE PROCEDURE upsert_material_property ( );


----------------------------------------
-- view material_composite_property
-- DROP VIEW vw_material_composite_property CASCADE
----------------------------------------
CREATE OR REPLACE VIEW vw_material_composite_property AS
SELECT 
	mc.material_composite_uuid,
	mc.composite_uuid,
    mc.composite_class,
	mc.composite_description,
	mc.component_uuid,
	mc.component_description,
    mc.component_class,
	pr.property_uuid,
    pr.property_class,
	pr.property_def_uuid,
	pd.description  AS property_description,
	pd.short_description AS property_short_description,
    pd.property_def_class,
    pr.property_val as property_value_val,
	(pr.property_val).v_type_uuid AS property_value_type_uuid,
	vl.val_type as property_value_type_description,
	(pr.property_val).v_unit AS property_value_unit,
	vl.val_val as property_value,
	pr.actor_uuid AS property_actor_uuid,
	act.description AS property_actor_description,
	pr.status_uuid AS property_status_uuid,
	st.description AS property_status_description,
	pr.add_date,
	pr.mod_date,
    pr.tags as property_tags,
    pr.notes as property_notes
FROM vw_material_composite mc
JOIN property_x px ON mc.material_composite_uuid = px.material_uuid
JOIN vw_property pr ON px.property_uuid = pr.property_uuid
JOIN vw_property_def pd ON pr.property_def_uuid = pd.property_def_uuid
LEFT JOIN vw_actor act ON pr.actor_uuid = act.actor_uuid
LEFT JOIN vw_status st ON pr.status_uuid = st.status_uuid
LEFT JOIN LATERAL ( SELECT get_val.val_type, get_val.val_unit, get_val.val_val FROM get_val(pr.property_val) get_val(val_type, val_unit, val_val)) vl ON true;


----------------------------------------
-- view inventory; with links to organization
----------------------------------------
CREATE OR REPLACE VIEW vw_inventory AS
SELECT
	inv.inventory_uuid,
	inv.description,
    inv.owner_uuid,
    acto.description as owner_description,
    inv.operator_uuid,
    actp.description as operator_description,
    inv.lab_uuid,
    actl.description as lab_description,
    inv.actor_uuid,
    act.description as actor_description,
	inv.status_uuid AS status_uuid,
	st.description AS status_description,
	inv.add_date,
	inv.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	inventory inv
LEFT JOIN vw_actor acto ON inv.owner_uuid = acto.actor_uuid
LEFT JOIN vw_actor actp ON inv.operator_uuid = actp.actor_uuid
LEFT JOIN vw_actor actl ON inv.lab_uuid = actl.actor_uuid
LEFT JOIN actor act ON inv.actor_uuid = act.actor_uuid
LEFT JOIN status st ON inv.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (inventory_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (inventory_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_inventory_upsert ON vw_inventory;
CREATE TRIGGER trigger_inventory_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_inventory
FOR EACH ROW
EXECUTE PROCEDURE upsert_inventory ( );


----------------------------------------
-- view inventory_material; with links to material, actor, status, edocument, note
----------------------------------------
CREATE OR REPLACE VIEW vw_inventory_material AS
SELECT
	inv.inventory_material_uuid,
	inv.description,
    inv.inventory_uuid,
    i.description as inventory_description,
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
	inv.mod_date,
    i.tags as inventory_tags,
    i.notes as inventory_notes
FROM
	inventory_material inv
JOIN vw_inventory i ON inv.inventory_uuid = i.inventory_uuid
JOIN vw_material mat ON inv.material_uuid = mat.material_uuid
LEFT JOIN actor act ON inv.actor_uuid = act.actor_uuid
LEFT JOIN status st ON inv.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_inventory_material_upsert ON vw_inventory_material;
CREATE TRIGGER trigger_inventory_material_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_inventory_material
FOR EACH ROW
EXECUTE PROCEDURE upsert_inventory_material ( );


----------------------------------------
-- get inventory_material / material, all status
----------------------------------------
CREATE OR REPLACE VIEW vw_inventory_material_material AS
SELECT
    inv.inventory_material_uuid,
	inv.description AS inventory_material_description,
  	inv.inventory_uuid,
    i.description as inventory_description,
	inv.part_no AS inventory_material_part_no,
	inv.onhand_amt AS inventory_material_onhand_amt,
	inv.add_date AS inventory_material_add_date,
	inv.expiration_date AS inventory_material_expiration_date,
	inv.location AS inventory_material_location,
	st.status_uuid AS inventory_material_status_uuid,
	st.description AS inventory_material_status_description,
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
	inventory_material inv
JOIN vw_inventory i ON inv.inventory_uuid = i.inventory_uuid
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
	b.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM
	bom b
JOIN vw_experiment exp ON b.experiment_uuid = exp.experiment_uuid
LEFT JOIN vw_actor act ON b.actor_uuid = act.actor_uuid
LEFT JOIN status st ON b.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (bom_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (bom_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_bom_upsert ON vw_bom;
CREATE TRIGGER trigger_bom_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_bom
FOR EACH ROW
EXECUTE PROCEDURE upsert_bom ( );


----------------------------------------
-- view bom_material
-- drop view vw_bom_material cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_bom_material AS
SELECT
	bm.bom_material_uuid,
	bm.description,
    bmi.bom_material_index_uuid,
    bm.bom_uuid,
	b.description AS bom_description,
	bm.inventory_material_uuid,
    inv.description as inventory_description,
    inv.material_uuid,
	bm.alloc_amt_val,
	bm.used_amt_val,
	bm.putback_amt_val,
	bm.actor_uuid,
	act.description AS actor_description,
	bm.status_uuid,
	st.description AS status_description,
    bm.add_date,
    bm.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM bom_material bm
JOIN bom_material_index bmi ON bm.bom_material_uuid = bmi.bom_material_uuid
JOIN bom b ON bm.bom_uuid = b.bom_uuid
JOIN inventory_material inv ON bm.inventory_material_uuid = inv.inventory_material_uuid
LEFT JOIN actor act ON bm.actor_uuid = act.actor_uuid
LEFT JOIN status st ON bm.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (bm.bom_material_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (bm.bom_material_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_bom_material_upsert ON vw_bom_material;
CREATE TRIGGER trigger_bom_material_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_bom_material
FOR EACH ROW
EXECUTE PROCEDURE upsert_bom_material ( );


----------------------------------------
-- view bom_material_composite
-- drop view vw_bom_material_composite cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_bom_material_composite AS
SELECT
	bmc.bom_material_composite_uuid,
	bmc.description,
    bmi.bom_material_index_uuid,
    bmc.bom_material_uuid,
    bm.description as bom_material_description,
    bm.bom_uuid,
    bmc.material_composite_uuid,
    mc.component_uuid,
    mc.component_description as material_description,
	bmc.actor_uuid,
	act.description AS actor_description,
	bmc.status_uuid,
	st.description AS status_description,
    bmc.add_date,
    bmc.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM bom_material_composite bmc
JOIN bom_material_index bmi ON bmc.bom_material_composite_uuid = bmi.bom_material_composite_uuid
JOIN bom_material bm ON bmc.bom_material_uuid = bm.bom_material_uuid
JOIN vw_material_composite mc ON bmc.material_composite_uuid = mc.material_composite_uuid
LEFT JOIN actor act ON bm.actor_uuid = act.actor_uuid
LEFT JOIN status st ON bm.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (bmc.bom_material_composite_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (bmc.bom_material_composite_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_bom_material_composite_upsert ON vw_bom_material_composite;
CREATE TRIGGER trigger_bom_material_composite_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_bom_material_composite
FOR EACH ROW
EXECUTE PROCEDURE upsert_bom_material_composite ( );


----------------------------------------
-- view bom_material_index
-- drop view vw_bom_material_index cascade
----------------------------------------
CREATE OR REPLACE VIEW vw_bom_material_index AS
SELECT
	bmi.bom_material_index_uuid,
	bmi.description,
    bmi.bom_material_uuid,
    bm.inventory_description as inventory_description,
    CASE
        when bm.bom_uuid is not null then bm.bom_uuid
        else bmc.bom_uuid
    END as bom_uuid,
    bmi.bom_material_composite_uuid,
    bmc.bom_material_description as bom_material_description,
    CASE
        when bmi.bom_material_uuid is not null then m1.material_uuid
        else bmc.component_uuid
    END as material_uuid,
    CASE
        when bmi.bom_material_uuid is not null then m1.description
        else bmc.material_description
    END as material_description,
    bmi.add_date,
    bmi.mod_date
FROM bom_material_index bmi
LEFT JOIN vw_bom_material bm ON bmi.bom_material_uuid = bm.bom_material_uuid
LEFT JOIN material m1 ON bm.material_uuid = m1.material_uuid
LEFT JOIN vw_bom_material_composite bmc ON bmi.bom_material_composite_uuid = bmc.bom_material_composite_uuid
LEFT JOIN material m2 ON bmc.material_composite_uuid = m2.material_uuid;


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
    pd.parameter_def_unit_type,
    pd.required,
	pd.actor_uuid,
	act.description as actor_description,
	pd.status_uuid,
	st.description as status_description,
	pd.add_date,
	pd.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM parameter_def pd
LEFT JOIN actor act ON pd.actor_uuid = act.actor_uuid
LEFT JOIN status st ON pd.status_uuid = st.status_uuid
LEFT JOIN type_def td ON ( pd.default_val ).v_type_uuid = td.type_def_uuid
LEFT JOIN LATERAL (select * from tag_to_array (parameter_def_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (parameter_def_uuid)) anote ON true;

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
	pr.parameter_val_nominal,
    pr.parameter_val_actual,
    (select val_val from get_val ( pr.parameter_val_nominal) ) AS parameter_value_nominal,
    (select val_val from get_val ( pr.parameter_val_actual) ) AS parameter_value_actual,
    pd.val_type_uuid,
    pd.val_type_description,
    pd.valunit,
	pr.actor_uuid,
	act.description as actor_description,
	pr.status_uuid,
	st.description as status_description,
	pr.add_date,
	pr.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes,
	px.ref_parameter_uuid,
	px.parameter_x_uuid
FROM parameter pr
JOIN vw_parameter_def pd on pr.parameter_def_uuid = pd.parameter_def_uuid
JOIN parameter_x px on pr.parameter_uuid = px.parameter_uuid
LEFT JOIN actor act on pr.actor_uuid = act.actor_uuid
LEFT JOIN status st on pd.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (pr.parameter_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (pr.parameter_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_parameter_upsert ON vw_parameter;
CREATE TRIGGER trigger_parameter_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_parameter
FOR EACH ROW
EXECUTE PROCEDURE upsert_parameter ( );


----------------------------------------
 -- view calculation_parameter_def_assign
----------------------------------------
CREATE OR REPLACE VIEW vw_calculation_parameter_def_assign AS
SELECT
    calculation_parameter_def_x_uuid,
 	parameter_def_uuid,
 	calculation_def_uuid,
 	add_date,
 	mod_date
FROM calculation_parameter_def_x;

DROP TRIGGER IF EXISTS trigger_calculation_parameter_def_assign ON vw_calculation_parameter_def_assign;
CREATE TRIGGER trigger_calculation_parameter_def_assign INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_calculation_parameter_def_assign
FOR EACH ROW
EXECUTE PROCEDURE upsert_calculation_parameter_def_assign ( );


----------------------------------------
-- view calculation_parameter
----------------------------------------
CREATE OR REPLACE VIEW vw_calculation_parameter_def AS
SELECT
	cd.calculation_def_uuid,
	cd.short_name,
	cd.calc_definition,
	cd.description,
	cd.in_source_uuid,
	cd.in_type_uuid,
	tdi.description as in_type_description,
	cd.in_opt_source_uuid,
	cd.in_opt_type_uuid,
	tdio.description as in_opt_type_description,
	cd.out_type_uuid,
	tdo.description as out_type_description,
	cd.systemtool_uuid,
	st.systemtool_name,
	stt.description AS systemtool_type_description,
	org.short_name AS systemtool_vendor_organization,
	st.ver AS systemtool_version,
	cd.actor_uuid AS actor_uuid,
	act.description AS actor_description,
	sts.status_uuid as status_uuid,
	sts.description as status_description,
	cd.calculation_class_uuid,
	cd.add_date,
	cd.mod_date,
    px.calculation_parameter_def_x_uuid,
    pd.parameter_def_uuid,
    pd.description as parameter_def_description,
    pd.required,
    pd.default_val,
    pd.actor_uuid as parameter_def_actor_uuid,
    actp.description as parameter_def_actor_description,
    pd.status_uuid as parameter_def_status_uuid,
    stsp.description as parameter_def_status_description,
    pd.add_date as parameter_def_add_date,
    pd.mod_date as parameter_def_mod_date
FROM
	calculation_def cd
LEFT JOIN vw_actor act ON cd.actor_uuid = act.actor_uuid
LEFT JOIN vw_systemtool st ON cd.systemtool_uuid = st.systemtool_uuid
LEFT JOIN vw_type_def tdi ON cd.in_type_uuid = tdi.type_def_uuid
LEFT JOIN vw_type_def tdio ON cd.in_opt_type_uuid = tdio.type_def_uuid
LEFT JOIN vw_type_def tdo ON cd.out_type_uuid = tdo.type_def_uuid
LEFT JOIN systemtool_type stt ON st.systemtool_type_uuid = stt.systemtool_type_uuid
LEFT JOIN organization org ON st.vendor_organization_uuid = org.organization_uuid
LEFT JOIN status sts ON cd.status_uuid = sts.status_uuid
LEFT JOIN calculation_parameter_def_x px ON cd.calculation_def_uuid = px.calculation_def_uuid
LEFT JOIN parameter_def pd ON px.parameter_def_uuid = pd.parameter_def_uuid
LEFT JOIN vw_actor actp ON pd.actor_uuid = actp.actor_uuid
LEFT JOIN status stsp ON pd.status_uuid = stsp.status_uuid;

DROP TRIGGER IF EXISTS trigger_calculation_parameter_def ON vw_calculation_parameter_def;
CREATE TRIGGER trigger_calculation_parameter_def INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_calculation_parameter_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_calculation_parameter_def ( );


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
    ad.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM action_def ad
LEFT JOIN actor act ON ad.actor_uuid = act.actor_uuid
LEFT JOIN status st ON ad.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (action_def_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (action_def_uuid)) anote ON true;

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
LEFT JOIN actor act ON ad.actor_uuid = act.actor_uuid
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
    act.workflow_action_set_uuid,
    was.description as workflow_action_set_description,
    act.description as action_description,
    ad.description as action_def_description,
    act.start_date,
    act.end_date,
    act.duration,
    act.repeating,
    act.ref_parameter_uuid,
    act.calculation_def_uuid,
    act.source_material_uuid,
    bmis.description as source_material_description,
    act.destination_material_uuid,
    bmid.description as destination_material_description,
    act.actor_uuid,
    actor.description as actor_description,
    act.status_uuid,
    st.description as status_description,
    act.add_date,
    act.mod_date,
    atag.tag_to_array AS tags,
    anote.note_to_array AS notes
FROM action act
JOIN vw_workflow wf ON act.workflow_uuid = wf.workflow_uuid
LEFT JOIN workflow_action_set was ON act.workflow_action_set_uuid = was.workflow_action_set_uuid
JOIN vw_action_def ad ON act.action_def_uuid = ad.action_def_uuid
LEFT JOIN vw_bom_material_index bmis ON act.source_material_uuid = bmis.bom_material_index_uuid
LEFT JOIN vw_bom_material_index bmid ON act.destination_material_uuid = bmid.bom_material_index_uuid
LEFT JOIN vw_actor actor ON act.actor_uuid = actor.actor_uuid
LEFT JOIN vw_status st ON act.status_uuid = st.status_uuid
LEFT JOIN LATERAL (select * from tag_to_array (action_uuid)) atag ON true
LEFT JOIN LATERAL (select * from note_to_array (action_uuid)) anote ON true;

DROP TRIGGER IF EXISTS trigger_action_upsert ON vw_action;
CREATE TRIGGER trigger_action_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_action
FOR EACH ROW
EXECUTE PROCEDURE upsert_action ( );


----------------------------------------
 -- view action_parameter_def_json
----------------------------------------
CREATE OR REPLACE VIEW action_parameter_def_json AS
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
    a.workflow_uuid,
    a.workflow_action_set_uuid,
	a.action_def_uuid,
	a.description as action_description,
	ad.description as action_def_description,
	a.actor_uuid as action_actor_uuid,
	acta.description as action_actor_description,
	a.status_uuid as action_status_uuid,
	sta.description as action_status_description,
	a.add_date as action_add_date,
	a.mod_date as action_mod_date,
	p.parameter_uuid,
    p.parameter_x_uuid,
	p.parameter_def_uuid,
	p.parameter_def_description,
	p.parameter_val_nominal,
    p.parameter_val_actual,
    p.val_type_uuid,
    p.val_type_description,
    p.parameter_value_nominal,
    p.parameter_value_actual,
    p.valunit,
	p.actor_uuid as parameter_actor_uuid,
	actp.description as parameter_actor_description,
	p.status_uuid as parameter_status_uuid,
	stp.description as parameter_status_description,
	p.add_date as parameter_add_date,
	p.mod_date as parameter_mod_date,
    p.tags as parameter_tags,
    p.notes as parameter_notes
FROM action a
JOIN action_def ad ON a.action_def_uuid = ad.action_def_uuid
LEFT JOIN actor acta ON a.actor_uuid = acta.actor_uuid
LEFT JOIN status sta  ON a.status_uuid = sta.status_uuid
JOIN vw_parameter p ON a.action_uuid = p.ref_parameter_uuid
LEFT JOIN actor actp ON p.actor_uuid = actp.actor_uuid
LEFT JOIN status stp  ON p.status_uuid = stp.status_uuid;

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
				'parameter_value', (select get_val_json(p.parameter_val_nominal)),
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
LEFT JOIN actor act ON cd.actor_uuid = act.actor_uuid
LEFT JOIN status st ON cd.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_condition_def_upsert ON vw_condition_def;
CREATE TRIGGER trigger_condition_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_condition_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_condition_def ( );

	
----------------------------------------
-- view condition_calculation_def_assign
-- DROP VIEW vw_condition_calculation_def_assign
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
LEFT JOIN condition_def cn ON ccd.condition_def_uuid = cn.condition_def_uuid
LEFT JOIN calculation_def cl ON ccd.calculation_def_uuid = cl.calculation_def_uuid;

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
    cd.workflow_uuid,
    cd.workflow_action_set_uuid,
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
LEFT JOIN actor act ON cd.actor_uuid = act.actor_uuid
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
    c.condition_uuid,
    cd.description as condition_description,
	c.in_val,
	c.out_val,
	c.actor_uuid as condition_actor_uuid,
	act.description as condition_actor_description,
	c.status_uuid as condition_status_uuid,
	st.description as condition_status_description,
    c.add_date as condition_add_date,
	c.mod_date as condition_mod_date,
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
LEFT JOIN condition_calculation_def_x cc ON c.condition_calculation_def_x_uuid = cc.condition_calculation_def_x_uuid
LEFT JOIN condition_def cd ON cc.condition_def_uuid = cd.condition_def_uuid
LEFT JOIN vw_calculation_def cald ON cc.calculation_def_uuid = cald.calculation_def_uuid
LEFT JOIN actor act ON cd.actor_uuid = act.actor_uuid
LEFT JOIN status st ON cd.status_uuid = st.status_uuid
LEFT JOIN actor actc ON cd.actor_uuid = actc.actor_uuid
LEFT JOIN status stc ON cd.status_uuid = stc.status_uuid
;	


----------------------------------------
-- view condition_path
-- DROP VIEW vw_condition_path
----------------------------------------
CREATE OR REPLACE VIEW vw_condition_path AS
SELECT cp.condition_path_uuid,
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
			'calculation_in_val', (select get_val_json(p.in_val)),
			'calculation_out_val', (select get_val_json(p.out_val)),
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
-- view workflow_object
-- DROP VIEW vw_workflow_object
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_object AS
SELECT
	wo.workflow_object_uuid,
	wo.workflow_uuid,
    wo.workflow_action_set_uuid,
	wo.action_uuid,
	wo.condition_uuid,
    COALESCE (wo.action_uuid, wo.condition_uuid) as object_uuid,
	CASE
		when wo.action_uuid is not null then 'action'
		when wo.condition_uuid is not null then 'condition'
		else 'node'
	end as object_type,
	CASE
		when wo.action_uuid is not null then a.description
		when wo.condition_uuid is not null then c.condition_description
	end as object_description,	
	CASE
		when wo.action_uuid is not null then ad.description
		when wo.condition_uuid is not null then c.calculation_description
	end as object_def_description,
    wo.status_uuid,
	wo.add_date,
	wo.mod_date
FROM workflow_object wo
LEFT JOIN action a ON wo.action_uuid = a.action_uuid
JOIN action_def ad ON a.action_def_uuid = ad.action_def_uuid
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
    ws.workflow_action_set_uuid,
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
JOIN workflow wf ON ws.workflow_uuid = wf.workflow_uuid
LEFT JOIN vw_workflow_object wo ON ws.workflow_object_uuid = wo.workflow_object_uuid
LEFT JOIN status st ON ws.status_uuid = st.status_uuid;

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
	was.parameter_val_nominal,
    was.parameter_val_actual,
	was.calculation_uuid,
	cdd.description as calculation_description,
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
LEFT JOIN workflow wf ON was.workflow_uuid = wf.workflow_uuid
LEFT JOIN action_def ad ON was.action_def_uuid = ad.action_def_uuid
LEFT JOIN parameter_def pd ON was.parameter_def_uuid = pd.parameter_def_uuid
LEFT JOIN calculation cd ON was.calculation_uuid = cd.calculation_uuid
LEFT JOIN calculation_def cdd ON cd.calculation_def_uuid = cdd.calculation_def_uuid
LEFT JOIN actor act ON was.actor_uuid = act.actor_uuid
LEFT JOIN status st ON was.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_action_set_upsert ON vw_workflow_action_set;
CREATE TRIGGER trigger_workflow_action_set_upsert INSTEAD OF INSERT
OR DELETE ON vw_workflow_action_set
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow_action_set ( );


----------------------------------------
-- view vw_experiment_parameter
-- DROP VIEW vw_experiment_parameter
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_parameter AS
-- action
select * from
    (select e.experiment_uuid,
            e.description as experiment,
            w.description as workflow,
            ew.experiment_workflow_seq as workflow_seq,
           'action' as workflow_object,
            ap.action_description as object_description,
            ap.action_uuid as object_uuid,
            ap.parameter_def_description,
            ap.parameter_uuid as parameter_uuid,
            array[ap.parameter_val_nominal] as parameter_value_nominal,
            array[ap.parameter_val_actual] as parameter_value_actual
    from vw_action_parameter ap
    JOIN vw_workflow w ON ap.workflow_uuid = w.workflow_uuid
    JOIN experiment_workflow ew ON w.workflow_uuid = ew.workflow_uuid
    JOIN experiment e ON ew.experiment_uuid = e.experiment_uuid
    where ap.workflow_action_set_uuid is null
    UNION
    -- workflow action set parameter
    select e.experiment_uuid,
           e.description as experiment,
           was.workflow_description as workflow,
           ew.experiment_workflow_seq as workflow_seq,
           'action_set' as workflow_object,
           was.description as object_description,
           was.workflow_action_set_uuid as object_uuid,
           was.parameter_def_description,
           null as parameter_uuid,
           was.parameter_val_nominal as parameter_value_nominal,
           was.parameter_val_actual as parameter_value_actual
    FROM vw_workflow_action_set was
    JOIN experiment_workflow ew ON was.workflow_uuid = ew.workflow_uuid
    JOIN experiment e ON ew.experiment_uuid = e.experiment_uuid
    where was.parameter_val_nominal is not null
    UNION
    -- workflow action set calculation parameter
    select e.experiment_uuid,
           e.description as experiment,
           was.workflow_description as workflow,
           ew.experiment_workflow_seq as workflow_seq,
           'action_set' as workflow_object,
           was.description as object_description,
           was.workflow_action_set_uuid as object_uuid,
           cpd.parameter_def_description as parameter,
           cpd.parameter_def_uuid as parameter_uuid,
           array[cpd.default_val] as parameter_value_nominal,
           null as parameter_value_actual
    FROM vw_workflow_action_set was
    JOIN vw_calculation c ON was.calculation_uuid = c.calculation_uuid
    LEFT JOIN vw_calculation_def cd ON c.calculation_def_uuid = cd.calculation_def_uuid
    LEFT JOIN vw_calculation_parameter_def cpd ON cd.calculation_def_uuid = cpd.calculation_def_uuid
    JOIN experiment_workflow ew ON was.workflow_uuid = ew.workflow_uuid
    JOIN experiment e ON ew.experiment_uuid = e.experiment_uuid
    where was.calculation_uuid is not null) ew
order by experiment_uuid, workflow_seq, workflow_object, parameter_def_description;

DROP TRIGGER IF EXISTS trigger_experiment_parameter_upsert ON vw_experiment_parameter;
CREATE TRIGGER trigger_experiment_parameter_upsert INSTEAD OF UPDATE
ON vw_experiment_parameter
FOR EACH ROW
EXECUTE PROCEDURE upsert_experiment_parameter ( );


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
	    ORDER BY p.experiment_workflow_seq
			) wf
FROM
			vw_experiment_workflow p
GROUP BY
			experiment_uuid
	) p
ON e.experiment_uuid = p.experiment_uuid;


----------------------------------------
-- view experiment_workflow_step_object_parameter_json
-- drop view experiment_workflow_step_object_parameter_json
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_workflow_step_object_parameter_json AS
SELECT
	e.experiment_uuid,
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
			'workflow', p.wf)
	)) AS experiment_workflow_json
FROM vw_experiment e
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
				'workflow_step', w.wfso)
		) AS wf
	FROM (
		SELECT
			vw_experiment_workflow.experiment_workflow_uuid,
			vw_experiment_workflow.experiment_uuid,
			vw_experiment_workflow.experiment_ref_uid,
			vw_experiment_workflow.experiment_description,
			vw_experiment_workflow.experiment_parent_uuid,
			vw_experiment_workflow.experiment_owner_uuid,
			vw_experiment_workflow.experiment_owner_description,
			vw_experiment_workflow.experiment_operator_uuid,
			vw_experiment_workflow.experiment_operator_description,
			vw_experiment_workflow.experiment_lab_uuid,
			vw_experiment_workflow.experiment_lab_description,
			vw_experiment_workflow.experiment_status_uuid,
			vw_experiment_workflow.experiment_status_description,
			vw_experiment_workflow.experiment_add_date,
			vw_experiment_workflow.experiment_mod_date,
			vw_experiment_workflow.experiment_workflow_seq,
			vw_experiment_workflow.workflow_uuid,
			vw_experiment_workflow.workflow_description,
			vw_experiment_workflow.workflow_type_uuid,
			vw_experiment_workflow.workflow_type_description
		FROM
			vw_experiment_workflow
		ORDER BY
			vw_experiment_workflow.experiment_uuid,
			vw_experiment_workflow.experiment_workflow_seq) p
		LEFT JOIN (
			WITH RECURSIVE wf (
			workflow_step_uuid,
			level,
			workflow_uuid,
			workflow_description,
			workflow_object_uuid,
			parent_uuid,
			parent_object_type,
			parent_object_description,
			conditional_val,
			conditional_value,
			object_uuid,
			object_type,
			object_description,
			status_uuid,
			status_description) AS 
			(
			SELECT
				w1.workflow_step_uuid,
				1,
				w1.workflow_uuid,
				w1.workflow_description,
				w1.workflow_object_uuid,
				w1.parent_uuid,
				w1.parent_object_type,
				w1.parent_object_description,
				w1.conditional_val,
				w1.conditional_value,
				w1.object_uuid,
				w1.object_type,
				w1.object_description,
				w1.status_uuid,
				w1.status_description
			FROM
				vw_workflow_step w1
			WHERE
				w1.parent_uuid IS NULL
			UNION ALL
			SELECT
				w2.workflow_step_uuid,
				w0.level + 1,
				w2.workflow_uuid,
				w2.workflow_description,
				w2.workflow_object_uuid,
				w2.parent_uuid,
				w2.parent_object_type,
				w2.parent_object_description,
				w2.conditional_val,
				w2.conditional_value,
				w2.object_uuid,
				w2.object_type,
				w2.object_description,
				w2.status_uuid,
				w2.status_description
			FROM
				vw_workflow_step w2
				JOIN wf w0 ON w0.workflow_step_uuid = w2.parent_uuid
			)
		SELECT
			n.workflow_uuid,
			json_agg(
				json_build_object('workflow_uuid',
					n.workflow_uuid, 'workflow_description',
					n.workflow_description, 'workflow_step_uuid',
					n.workflow_step_uuid, 'workflow_step_order',
					n.level, 'workflow_step_parent_uuid',
					n.parent_uuid, 'workflow_step_parent_object_type',
					n.parent_object_type, 'workflow_step_parent_object_description',
					n.parent_object_description,'workflow_conditional_val',
					n.conditional_val, 'workflow_conditional_value',
					n.conditional_value, 'workflow_step_status_uuid',
					n.status_uuid, 'workflow_step_status_description',
					n.status_description, 'object',
					wo.wfs)
			) AS wfso
		FROM (
			SELECT
				wf.workflow_step_uuid,
				wf.level,
				wf.workflow_uuid,
				wf.workflow_description,
				wf.workflow_object_uuid,
				wf.parent_uuid,
				wf.parent_object_type,
				wf.parent_object_description,
				wf.conditional_val,
				wf.conditional_value,
				wf.object_uuid,
				wf.object_type,
				wf.object_description,
				wf.status_uuid,
				wf.status_description
			FROM wf
			ORDER BY wf.workflow_uuid, wf.level
		) n
		JOIN (
			SELECT
				ws.workflow_step_uuid,
				json_agg(
					json_build_object(
						'workflow_object_uuid', ws.workflow_object_uuid,
						'object_uuid', ws.object_uuid,
						'object_type', ws.object_type,
						'object_description', ws.object_description,
						'object_def_description', ws.object_def_description,
						'object_parameters',op.param)
				) AS wfs
			FROM vw_workflow_step ws
				JOIN (
					SELECT
						p.action_uuid AS object_uuid,
						json_agg(json_build_object(
							'parameter_def_description', p.parameter_def_description,
							'parameter_def_uuid', p.parameter_def_uuid,
							'parameter_value_nominal', (SELECT get_val_json (p.parameter_val_nominal) AS get_val_json))) AS param
					        --'parameter_value_actual', ((SELECT get_val_json (p.parameter_val_nominal) AS get_val_json)) AS param_actual

						FROM vw_action_parameter p
						GROUP BY p.action_uuid) op
				ON ws.object_uuid = op.object_uuid
				GROUP BY ws.workflow_step_uuid
				) wo 
			ON n.workflow_step_uuid = wo.workflow_step_uuid
			GROUP BY n.workflow_uuid) w 
		ON p.workflow_uuid = w.workflow_uuid
		GROUP BY p.experiment_uuid) p
ON e.experiment_uuid = p.experiment_uuid
GROUP BY e.experiment_uuid;


----------------------------------------
-- view experiment_workflow_bom_json
-- drop view vw_experiment_workflow_bom_json
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_bom_json AS
SELECT
	json_build_object(
		'experiment', 
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
				'bom', b.bom)
		)
	) AS experiment_workflow_json
FROM vw_experiment e
JOIN (
	SELECT
		b.experiment_uuid,
		json_agg(
			json_build_object(
				'bom_uuid', b.bom_uuid,
				'bom_description', b.description,
				'bom_material', bm.bomm)
		) AS bom
		FROM vw_bom b
		JOIN (
			SELECT
				bm.bom_uuid,
				json_agg(
					json_build_object(
						'bom_material_description', bm.description,
						'bom_inventory_material_uuid', bm.inventory_material_uuid,
						'bom_material_uuid', bm.material_uuid,
						'bom_material_property', mp.mprp, 
						'bom_material_component', mc.mcom)
					ORDER BY bm.description
				) AS bomm
			FROM (SELECT
					bm.bom_material_uuid, bm.bom_uuid, bm.description, bm.bom_description, bm.inventory_material_uuid, bm.material_uuid,
					bm.alloc_amt_val, bm.used_amt_val, bm.putback_amt_val,
					bm.actor_uuid, bm.actor_description, bm.status_uuid, bm.status_description, bm.add_date, bm.mod_date
				FROM vw_bom_material bm
				) bm
			LEFT JOIN (
				SELECT
					mp.material_uuid,
					json_agg(
						json_build_object(
                            'material_property_uuid', mp.property_uuid,
                            'material_property_def_uuid', mp.property_def_uuid,
                            'material_property_description', mp.property_description,
                            'material_property_short_description', mp.property_short_description,
                            'material_property_value_type', mp.property_value_type_description,
                            'material_property_value', mp.property_value,
                            'material_property_value_unit', mp.property_value_unit)) AS mprp
                FROM (
                    SELECT
						mp.property_x_uuid, mp.material_uuid, mp.description, mp.property_uuid, mp.property_def_uuid,
						mp.property_description, mp.property_short_description, mp.property_value_type_uuid, mp.property_value_type_description,
						mp.property_value_unit, mp.property_value, mp.property_value_val, mp.property_actor_uuid, mp.property_actor_description, mp.property_status_uuid,
						mp.property_status_description, mp.property_add_date, mp.property_mod_date
					FROM
						vw_material_property mp
					WHERE
						mp.property_x_uuid IS NOT NULL) mp
					GROUP BY
						mp.material_uuid) mp ON bm.material_uuid = mp.material_uuid
				LEFT JOIN (
					SELECT
						mc.composite_uuid,
						json_agg(
							json_build_object(
								'component_uuid', mc.material_composite_uuid,
								'component_description', mc.component_description,
								'component_addressable', mc.addressable,
								'component_property', cp.cpp)
							ORDER BY mc.component_description
						) AS mcom
					FROM (
						SELECT
							mc.material_composite_uuid, mc.composite_uuid, mc.composite_description, mc.composite_flg,
							mc.component_uuid, mc.component_description, mc.addressable, mc.actor_uuid, mc.actor_description,
							mc.status_uuid, mc.status_description, mc.add_date, mc.mod_date
						FROM
							vw_material_composite mc
						WHERE
							mc.material_composite_uuid IS NOT NULL) mc
					LEFT JOIN (
						SELECT
							cp.material_composite_uuid,
							json_agg(
								json_build_object(
									'component_property_uuid', cp.property_uuid,
									'component_property_def_uuid', cp.property_def_uuid,
									'component_property_description', cp.property_description,
									'component_property_short_description', cp.property_short_description,
									'component_property_val_type', cp.property_value_type_description,
									'component_property_val', cp.property_value,
									'component_property_val_unit', cp.property_value_unit)
							) AS cpp
						FROM (
							SELECT
								mcp.material_composite_uuid, mcp.composite_uuid, mcp.composite_description, mcp.component_uuid,
								mcp.component_description, mcp.property_uuid, mcp.property_def_uuid, mcp.property_description,
								mcp.property_short_description, mcp.property_value_type_uuid, mcp.property_value_type_description, mcp.property_value_unit,
								mcp.property_value, mcp.property_actor_uuid, mcp.property_actor_description, mcp.property_status_uuid,
								mcp.property_status_description, mcp.add_date, mcp.mod_date
							FROM
								vw_material_composite_property mcp
							WHERE
								mcp.property_uuid IS NOT NULL
						) cp
					GROUP BY cp.material_composite_uuid) cp
					ON mc.material_composite_uuid = cp.material_composite_uuid
				GROUP BY mc.composite_uuid) mc
				ON bm.material_uuid = mc.composite_uuid
		GROUP BY bm.bom_uuid) bm
		ON b.bom_uuid = bm.bom_uuid
	GROUP BY b.experiment_uuid) b
ON e.experiment_uuid = b.experiment_uuid;


----------------------------------------
-- view experiment_bom_workflow_step_object_parameter_json
-- drop view experiment_bom_workflow_step_object_parameter_json
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_workflow_bom_step_object_parameter_json AS
SELECT
	e.experiment_uuid,
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
			'bill of materials', b.bom,
			'workflow', p.wf)
	)) AS experiment_workflow_json
FROM vw_experiment e
JOIN (
    SELECT
        b.experiment_uuid,
        json_agg(
            json_build_object(
                'bom_uuid', b.bom_uuid,
                'bom_description', b.description,
                'bom_material', bm.bomm)
        ) AS bom
        FROM vw_bom b
        JOIN (
            SELECT
                bm.bom_uuid,
                json_agg(
                    json_build_object(
                        'bom_material_description', bm.description,
                        'bom_inventory_material_uuid', bm.inventory_material_uuid,
                        'bom_material_uuid', bm.material_uuid,
                        'bom_material_property', mp.mprp,
                        'bom_material_component', mc.mcom)
                    ORDER BY bm.description
                ) AS bomm
            FROM (SELECT
					bm.bom_material_uuid, bm.bom_uuid, bm.description, bm.bom_description, bm.inventory_material_uuid, bm.material_uuid,
					bm.alloc_amt_val, bm.used_amt_val, bm.putback_amt_val,
					bm.actor_uuid, bm.actor_description, bm.status_uuid, bm.status_description, bm.add_date, bm.mod_date
				FROM vw_bom_material bm) bm
            LEFT JOIN (
                SELECT
                    mp.material_uuid,
                    json_agg(
                        json_build_object(
                            'material_property_uuid', mp.property_uuid,
                            'material_property_def_uuid', mp.property_def_uuid,
                            'material_property_description', mp.property_description,
                            'material_property_short_description', mp.property_short_description,
                            'material_property_value_type', mp.property_value_type_description,
                            'material_property_value', mp.property_value,
                            'material_property_value_unit', mp.property_value_unit)) AS mprp
                FROM (
                    SELECT
						mp.property_x_uuid, mp.material_uuid, mp.description, mp.property_uuid, mp.property_def_uuid,
						mp.property_description, mp.property_short_description, mp.property_value_type_uuid, mp.property_value_type_description,
						mp.property_value_unit, mp.property_value, mp.property_value_val, mp.property_actor_uuid, mp.property_actor_description, mp.property_status_uuid,
						mp.property_status_description, mp.property_add_date, mp.property_mod_date
                    FROM
                        vw_material_property mp
                    WHERE
                        mp.property_x_uuid IS NOT NULL) mp
                    GROUP BY
                        mp.material_uuid) mp ON bm.material_uuid = mp.material_uuid
                LEFT JOIN (
                    SELECT
                        mc.composite_uuid,
                        json_agg(
                            json_build_object(
                                'component_uuid', mc.material_composite_uuid,
                                'component_description', mc.component_description,
                                'component_addressable', mc.addressable,
                                'component_property', cp.cpp)
                            ORDER BY mc.component_description
                        ) AS mcom
                    FROM (
                        SELECT
							mc.material_composite_uuid, mc.composite_uuid, mc.composite_description, mc.composite_flg,
							mc.component_uuid, mc.component_description, mc.addressable, mc.actor_uuid, mc.actor_description,
							mc.status_uuid, mc.status_description, mc.add_date, mc.mod_date
                        FROM
                            vw_material_composite mc
                        WHERE
                            mc.material_composite_uuid IS NOT NULL) mc
                    LEFT JOIN (
                        SELECT
                            cp.material_composite_uuid,
                            json_agg(
                                json_build_object(
									'component_property_uuid', cp.property_uuid,
									'component_property_def_uuid', cp.property_def_uuid,
									'component_property_description', cp.property_description,
									'component_property_short_description', cp.property_short_description,
									'component_property_val_type', cp.property_value_type_description,
									'component_property_val', cp.property_value,
									'component_property_val_unit', cp.property_value_unit)
							) AS cpp
						FROM (
							SELECT
								mcp.material_composite_uuid, mcp.composite_uuid, mcp.composite_description, mcp.component_uuid,
								mcp.component_description, mcp.property_uuid, mcp.property_def_uuid, mcp.property_description,
								mcp.property_short_description, mcp.property_value_type_uuid, mcp.property_value_type_description, mcp.property_value_unit,
								mcp.property_value, mcp.property_actor_uuid, mcp.property_actor_description, mcp.property_status_uuid,
								mcp.property_status_description, mcp.add_date, mcp.mod_date
                            FROM
                                vw_material_composite_property mcp
                            WHERE
                                mcp.property_uuid IS NOT NULL
                        ) cp
                    GROUP BY cp.material_composite_uuid) cp
                    ON mc.material_composite_uuid = cp.material_composite_uuid
                GROUP BY mc.composite_uuid) mc
                ON bm.material_uuid = mc.composite_uuid
        GROUP BY bm.bom_uuid) bm
        ON b.bom_uuid = bm.bom_uuid
    GROUP BY b.experiment_uuid) b
ON e.experiment_uuid = b.experiment_uuid
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
				'workflow_step', w.wfso)
		) AS wf
	FROM (
		SELECT
			ew.experiment_workflow_uuid, ew.experiment_uuid, ew.experiment_ref_uid, ew.experiment_description, ew.experiment_parent_uuid, ew.experiment_owner_uuid,
			ew.experiment_owner_description, ew.experiment_operator_uuid, ew.experiment_operator_description, ew.experiment_lab_uuid,
			ew.experiment_lab_description, ew.experiment_status_uuid, ew.experiment_status_description, ew.experiment_add_date, ew.experiment_mod_date,
			ew.experiment_workflow_seq, ew.workflow_uuid, ew.workflow_description, ew.workflow_type_uuid, ew.workflow_type_description
		FROM
			vw_experiment_workflow ew
		ORDER BY
			ew.experiment_uuid,
			ew.experiment_workflow_seq) p
		LEFT JOIN (
			WITH RECURSIVE wf (
			workflow_step_uuid,
			level,
			workflow_uuid,
			workflow_description,
			workflow_object_uuid,
			parent_uuid,
			parent_object_type,
			parent_object_description,
			conditional_val,
			conditional_value,
			object_uuid,
			object_type,
			object_description,
			status_uuid,
			status_description) AS
			(
			SELECT
				w1.workflow_step_uuid, 1, w1.workflow_uuid, w1.workflow_description, w1.workflow_object_uuid,
				w1.parent_uuid, w1.parent_object_type, w1.parent_object_description, w1.conditional_val, w1.conditional_value,
				w1.object_uuid, w1.object_type, w1.object_description, w1.status_uuid, w1.status_description
			FROM
				vw_workflow_step w1
			WHERE
				w1.parent_uuid IS NULL
			UNION ALL
			SELECT
				w2.workflow_step_uuid, w0.level + 1, w2.workflow_uuid, w2.workflow_description, w2.workflow_object_uuid,
				w2.parent_uuid, w2.parent_object_type, w2.parent_object_description, w2.conditional_val,
				w2.conditional_value, w2.object_uuid, w2.object_type, w2.object_description, w2.status_uuid, w2.status_description
			FROM
				vw_workflow_step w2
				JOIN wf w0 ON w0.workflow_step_uuid = w2.parent_uuid
			)
		SELECT
			n.workflow_uuid,
			json_agg(
				json_build_object('workflow_uuid',
					n.workflow_uuid, 'workflow_description',
					n.workflow_description, 'workflow_step_uuid',
					n.workflow_step_uuid, 'workflow_step_order',
					n.level, 'workflow_step_parent_uuid',
					n.parent_uuid, 'workflow_step_parent_object_type',
					n.parent_object_type, 'workflow_step_parent_object_description',
					n.parent_object_description,'workflow_conditional_val',
					n.conditional_val, 'workflow_conditional_value',
					n.conditional_value, 'workflow_step_status_uuid',
					n.status_uuid, 'workflow_step_status_description',
					n.status_description, 'object',
					wo.wfs)
			) AS wfso
		FROM (
			SELECT
				wf.workflow_step_uuid, wf.level, wf.workflow_uuid, wf.workflow_description, wf.workflow_object_uuid,
				wf.parent_uuid, wf.parent_object_type, wf.parent_object_description, wf.conditional_val, wf.conditional_value,
				wf.object_uuid, wf.object_type, wf.object_description, wf.status_uuid, wf.status_description
			FROM wf
			ORDER BY wf.workflow_uuid, wf.level
		) n
		JOIN (
			SELECT
				ws.workflow_step_uuid,
				json_agg(
					json_build_object(
						'workflow_object_uuid', ws.workflow_object_uuid,
						'object_uuid', ws.object_uuid,
						'object_type', ws.object_type,
						'object_description', ws.object_description,
						'object_def_description', ws.object_def_description,
						'object_parameters',op.param)
				) AS wfs
			FROM vw_workflow_step ws
				JOIN (
					SELECT
						p.action_uuid AS object_uuid,
						json_agg(json_build_object(
							'parameter_def_description', p.parameter_def_description,
							'parameter_def_uuid', p.parameter_def_uuid,
							'parameter_value_nominal', (SELECT get_val_json (p.parameter_val_nominal) AS get_val_json))) AS param
					FROM vw_action_parameter p
					GROUP BY p.action_uuid) op
				ON ws.object_uuid = op.object_uuid
			    GROUP BY ws.workflow_step_uuid) wo
		ON n.workflow_step_uuid = wo.workflow_step_uuid
	    GROUP BY n.workflow_uuid) w
	ON p.workflow_uuid = w.workflow_uuid
	GROUP BY p.experiment_uuid) p
ON e.experiment_uuid = p.experiment_uuid
GROUP BY e.experiment_uuid;


----------------------------------------
-- view vw_experiment_bom_workflow_measure_json
-- drop view vw_experiment_bom_workflow_measure_json
----------------------------------------
CREATE OR REPLACE VIEW vw_experiment_bom_workflow_measure_json AS
SELECT
	e.experiment_uuid,
	json_build_object('experiment',
	json_agg(
		json_build_object(
			'experiment_uuid', e.experiment_uuid,
			'experiment_ref_uid', e.ref_uid,
			'experiment_description', e.description,
			'experiment_parent_uuid', e.parent_uuid,
		    'experiment_parent_description', e.parent_description,
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
			'bill of materials', b.bom,
			'workflow', p.wf,
		    'outcomes', o.outcome_measure)
	)) AS experiment_workflow_json
FROM vw_experiment e
JOIN (
    SELECT
        b.experiment_uuid,
        json_agg(
            json_build_object(
                'bom_uuid', b.bom_uuid,
                'bom_description', b.description,
                'bom_material', bm.bomm)
        ) AS bom
        FROM vw_bom b
        JOIN (
            SELECT
                bm.bom_uuid,
                json_agg(
                    json_build_object(
                        'bom_material_description', bm.description,
                        'bom_inventory_material_uuid', bm.inventory_material_uuid,
                        'material_uuid', bm.material_uuid,
                        'material_property', mp.material_property,
                        'material_composite', mc.mcom)
                    ORDER BY bm.description
                ) AS bomm
            FROM (SELECT
					bm.bom_material_uuid, bm.bom_uuid, bm.description, bm.bom_description, bm.inventory_material_uuid, bm.material_uuid,
					bm.alloc_amt_val, bm.used_amt_val, bm.putback_amt_val,
					bm.actor_uuid, bm.actor_description, bm.status_uuid, bm.status_description, bm.add_date, bm.mod_date
				FROM vw_bom_material bm) bm
            LEFT JOIN (
                    select * from material_property_json ()
                ) mp ON bm.material_uuid = mp.material_uuid
                LEFT JOIN (
                    SELECT
                        mc.composite_uuid,
                        json_agg(
                            json_build_object(
                                'composite_uuid', mc.material_composite_uuid,
                                'composite_description', mc.component_description,
                                'composite_addressable', mc.addressable,
                                'composite_property', cp.composite_property)
                            ORDER BY mc.component_description
                        ) AS mcom
                    FROM (
                        SELECT
							mc.material_composite_uuid, mc.composite_uuid, mc.composite_description, mc.composite_flg,
							mc.component_uuid, mc.component_description, mc.addressable, mc.actor_uuid, mc.actor_description,
							mc.status_uuid, mc.status_description, mc.add_date, mc.mod_date
                        FROM
                            vw_material_composite mc
                        WHERE
                            mc.material_composite_uuid IS NOT NULL) mc
                    LEFT JOIN (
                        select * from material_composite_property_json ()
                    ) cp
                    ON mc.material_composite_uuid = cp.material_composite_uuid
                GROUP BY mc.composite_uuid) mc
                ON bm.material_uuid = mc.composite_uuid
        GROUP BY bm.bom_uuid) bm
        ON b.bom_uuid = bm.bom_uuid
    GROUP BY b.experiment_uuid) b
ON e.experiment_uuid = b.experiment_uuid
LEFT JOIN (
	SELECT
		p.experiment_uuid,
		json_agg(
			json_build_object(
				'workflow_seq', p.experiment_workflow_seq,
				'workflow_uuid', p.workflow_uuid,
				'workflow_description', p.workflow_description,
				'workflow_type_uuid', p.workflow_type_uuid,
				'workflow_type_description', p.workflow_type_description,
				'workflow_step', w.wfso)
		) AS wf
	FROM (
		SELECT
			ew.experiment_workflow_uuid, ew.experiment_uuid, ew.experiment_ref_uid, ew.experiment_description, ew.experiment_parent_uuid, ew.experiment_owner_uuid,
			ew.experiment_owner_description, ew.experiment_operator_uuid, ew.experiment_operator_description, ew.experiment_lab_uuid,
			ew.experiment_lab_description, ew.experiment_status_uuid, ew.experiment_status_description, ew.experiment_add_date, ew.experiment_mod_date,
			ew.experiment_workflow_seq, ew.workflow_uuid, ew.workflow_description, ew.workflow_type_uuid, ew.workflow_type_description
		FROM
			vw_experiment_workflow ew
		ORDER BY
			ew.experiment_uuid,
			ew.experiment_workflow_seq) p
		LEFT JOIN (
			WITH RECURSIVE wf (
			workflow_step_uuid,
			level,
			workflow_uuid,
			workflow_description,
			workflow_object_uuid,
			parent_uuid,
			parent_object_type,
			parent_object_description,
			conditional_val,
			conditional_value,
			object_uuid,
			object_type,
			object_description,
			status_uuid,
			status_description) AS
			(
			SELECT
				w1.workflow_step_uuid, 1, w1.workflow_uuid, w1.workflow_description, w1.workflow_object_uuid,
				w1.parent_uuid, w1.parent_object_type, w1.parent_object_description, w1.conditional_val, w1.conditional_value,
				w1.object_uuid, w1.object_type, w1.object_description, w1.status_uuid, w1.status_description
			FROM
				vw_workflow_step w1
			WHERE
				w1.parent_uuid IS NULL
			UNION ALL
			SELECT
				w2.workflow_step_uuid, w0.level + 1, w2.workflow_uuid, w2.workflow_description, w2.workflow_object_uuid,
				w2.parent_uuid, w2.parent_object_type, w2.parent_object_description, w2.conditional_val,
				w2.conditional_value, w2.object_uuid, w2.object_type, w2.object_description, w2.status_uuid, w2.status_description
			FROM
				vw_workflow_step w2
				JOIN wf w0 ON w0.workflow_step_uuid = w2.parent_uuid
			)
		SELECT
			n.workflow_uuid,
			json_agg(
				json_build_object('workflow_uuid',
					n.workflow_uuid, 'workflow_description',
					n.workflow_description, 'workflow_step_uuid',
					n.workflow_step_uuid, 'workflow_step_order',
					n.level, 'workflow_step_parent_uuid',
					n.parent_uuid, 'workflow_step_parent_object_type',
					n.parent_object_type, 'workflow_step_parent_object_description',
					n.parent_object_description,'workflow_conditional_val',
					n.conditional_val, 'workflow_conditional_value',
					n.conditional_value, 'workflow_step_status_uuid',
					n.status_uuid, 'workflow_step_status_description',
					n.status_description, 'object', wo.wfs)
			) AS wfso
		FROM (
			SELECT
				wf.workflow_step_uuid, wf.level, wf.workflow_uuid, wf.workflow_description, wf.workflow_object_uuid,
				wf.parent_uuid, wf.parent_object_type, wf.parent_object_description, wf.conditional_val, wf.conditional_value,
				wf.object_uuid, wf.object_type, wf.object_description, wf.status_uuid, wf.status_description
			FROM wf
			ORDER BY wf.workflow_uuid, wf.level
		) n
		JOIN (
			SELECT
				ws.workflow_step_uuid,
				json_agg(
					json_build_object(
						'workflow_object_uuid', ws.workflow_object_uuid,
						'object_uuid', ws.object_uuid,
						'object_type', ws.object_type,
						'object_description', ws.object_description,
						'object_def_description', ws.object_def_description,
						'object_parameters',op.action_parameter)
				) AS wfs
			FROM vw_workflow_step ws
				LEFT JOIN (
				    select * from action_parameter_json ()
			) op
				ON ws.object_uuid = op.object_uuid
			    GROUP BY ws.workflow_step_uuid) wo
		ON n.workflow_step_uuid = wo.workflow_step_uuid
	    GROUP BY n.workflow_uuid) w
	ON p.workflow_uuid = w.workflow_uuid
	GROUP BY p.experiment_uuid) p
ON e.experiment_uuid = p.experiment_uuid
-- now the outcomes
LEFT JOIN (
    select * from experiment_outcome_measure_json ()
) o
ON e.experiment_uuid = o.experiment_uuid
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
			
	