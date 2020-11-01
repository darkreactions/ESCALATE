--======================================================================
/*
Name:			prod_views
Parameters:		none
Returns:			
Author:			G. Cattabriga
Date:			2020.01.23
Description:	create the production views for ESCALATEv3
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
LEFT JOIN systemtool_type stt ON vst.systemtool_type_uuid = stt.systemtool_type_uuid
;


DROP TRIGGER IF EXISTS trigger_systemtool_upsert ON vw_systemtool;
CREATE TRIGGER trigger_systemtool_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_systemtool
FOR EACH ROW
EXECUTE PROCEDURE upsert_systemtool ( );


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
	-- dact.description AS actor_description,
	--	md.num_valarray_out,
	--	encode( md.blob_val_out, 'escape' ) AS blob_val_out,
	--	md.blob_type_out,
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
	mat.parent_uuid,
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
-- get materials, all status as a crosstab, with refname types
-- DROP VIEW vw_material cascade;
----------------------------------------
CREATE OR REPLACE VIEW vw_material AS
SELECT
	*
FROM
	crosstab (
		'select material_uuid, description, parent_uuid, status_uuid, status_description, add_date, mod_date, material_refname_def, material_refname_description
				   from vw_material_raw where material_type_description = ''catalog'' order by 1, 3',
		'select distinct material_refname_def
				   from vw_material_raw where material_refname_def is not null order by 1' ) AS ct (
		material_uuid uuid,
		description varchar,
		parent_uuid uuid,
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
		vw_material ) vmc
JOIN vw_material mat ON vmc.material_uuid = mat.material_uuid
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
	mc.json_object_agg AS calculation_json
FROM (
	SELECT
		material_uuid,
		json_object_agg(calculation_alias_name, json_build_object('type', calculation_type_uuid, 'value', calculation_value )
		ORDER BY
			calculation_alias_name DESC )
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
LEFT JOIN vw_material vm ON mc.material_uuid = vm.material_uuid;


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
-- view property
----------------------------------------
CREATE OR REPLACE VIEW vw_material_property AS
SELECT
	px.property_x_uuid,
	mat.material_uuid,
	mat.description,
	mat.parent_uuid,
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
	act.description as actor_description,
	pr.status_uuid as property_status_uuid,
	st.description as status_description,
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
-- view inventory; with links to material, actor, status, edocument, note
----------------------------------------
CREATE OR REPLACE VIEW vw_inventory AS
SELECT
	inv.inventory_uuid,
	inv.description as inventory_description,
	inv.part_no,
	inv.onhand_amt,
	inv.unit,
	inv.add_date,
	inv.mod_date,
	inv.expiration_date,
	inv.inventory_location,
	st.status_uuid AS status_uuid,
	st.description AS status_description,
	mat.material_uuid,
	mat.description AS material_description,
	act.actor_uuid,
	act.description as actor_description
FROM
	inventory inv
LEFT JOIN material mat ON inv.material_uuid = mat.material_uuid
LEFT JOIN actor act ON inv.actor_uuid = act.actor_uuid
LEFT JOIN status st ON inv.status_uuid = st.status_uuid;


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
	inv.add_date AS inventory_add_date,
	inv.expiration_date AS inventory_expiration_date,
	inv.inventory_location,
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
LEFT JOIN vw_material mat ON inv.material_uuid = mat.material_uuid
LEFT JOIN vw_actor act ON inv.actor_uuid = act.actor_uuid
LEFT JOIN status st ON inv.status_uuid = st.status_uuid;


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
     ap.action_parameter_def_x_uuid,
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
 INNER JOIN action_parameter_def_x ap ON ad.action_def_uuid = ap.action_def_uuid
 LEFT JOIN vw_parameter_def pd ON ap.parameter_def_uuid = pd.parameter_def_uuid
 LEFT JOIN status st ON ad.status_uuid = st.status_uuid;


----------------------------------------
 -- view action
----------------------------------------
CREATE OR REPLACE VIEW vw_action AS
SELECT
    act.action_uuid,
    act.action_def_uuid,
    act.description as action_description,
    ad.description as action_def_description,
    act.start_date,
    act.end_date,
    act.duration,
    act.repeating,
    act.ref_parameter_uuid,
    act.calculation_def_uuid,
    act.source_material_uuid,
    act.destination_material_uuid,
    act.actor_uuid,
    actor.description as actor_description,
    act.status_uuid,
    st.description as status_description,
    act.add_date,
    act.mod_date
FROM action act
LEFT JOIN vw_action_def ad ON act.action_def_uuid = ad.action_def_uuid
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
-- view condition_calculation_json
-- drop view condition_calculation_json
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
			'condition_actor', c.actor_description,
			'condition_status_uuid', c.actor_uuid,
			'condition_status', c.status_description,
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
			'calculation_actor', p.calculation_actor_description,
			'calculation_status_uuid', p.calculation_status_uuid,
			'calculation_status', p.calculation_status_description,
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
-- view workflow_def
-- DROP VIEW vw_workflow_def
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_def AS
SELECT
	wd.workflow_def_uuid,
	wd.workflow_type_uuid,
	wt.description as workflow_type_description,
	wd.description,
	wd.actor_uuid,
    act.description as actor_description,	
	wd.status_uuid,
	st.description as status_description,
	wd.add_date,
	wd.mod_date
FROM
	workflow_def wd
LEFT JOIN vw_actor act ON wd.actor_uuid = act.actor_uuid
LEFT JOIN vw_workflow_type wt ON wd.workflow_type_uuid = wt.workflow_type_uuid
LEFT JOIN status st ON wd.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_def_upsert ON vw_workflow_def;
CREATE TRIGGER trigger_workflow_def_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow_def
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow_def ( );


----------------------------------------
-- view workflow
-- DROP VIEW vw_workflow
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow AS
SELECT
	wf.workflow_uuid,
	wf.description,
	wf.parent_uuid,
	wf.workflow_def_uuid,
	wd.description as workflow_def_description,
	wd.workflow_type_uuid,
	wt.description as workflow_type_description,
	wf.experiment_uuid,
	ex.description as experiment_description,
	wd.actor_uuid,
    act.description as actor_description,	
	wd.status_uuid,
	st.description as status_description, 
	wd.add_date,
	wd.mod_date
FROM
	workflow wf
LEFT JOIN vw_workflow_def wd ON wf.workflow_def_uuid = wd.workflow_def_uuid
LEFT JOIN vw_workflow_type wt ON wd.workflow_type_uuid = wt.workflow_type_uuid
LEFT JOIN vw_experiment ex ON wf.experiment_uuid = ex.experiment_uuid
LEFT JOIN vw_actor act ON wf.actor_uuid = act.actor_uuid
LEFT JOIN status st ON wf.status_uuid = st.status_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_upsert ON vw_workflow;
CREATE TRIGGER trigger_workflow_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow ( );


----------------------------------------
-- view workflow_step_object
-- DROP VIEW vw_workflow_step_object
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_step_object AS
SELECT
	wso.workflow_step_object_uuid,
	CASE
		when wso.action_uuid is not null then 'action'
		when wso.condition_uuid is not null then 'condition'
		else 'node'
	end as step_object_type,
	wso.action_uuid,
	a.action_description,	
	a.action_def_description,
	wso.condition_uuid,
	c.condition_description,
	c.calculation_description,	
	wso.add_date,
	wso.mod_date
FROM workflow_step_object wso
LEFT JOIN vw_action a ON wso.action_uuid = a.action_uuid
LEFT JOIN vw_condition c ON wso.condition_uuid = c.condition_uuid
LEFT JOIN vw_condition_calculation_def_assign cc ON c.condition_calculation_def_x_uuid = cc.condition_calculation_def_x_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_step_upsert ON vw_workflow_step_object;
CREATE TRIGGER trigger_workflow_step_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow_step_object
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow_step_object ( );


----------------------------------------
-- view workflow_step
-- DROP VIEW workflow_step
----------------------------------------
CREATE OR REPLACE VIEW vw_workflow_step AS
SELECT
	wsd.workflow_step_uuid,
	wsd.workflow_uuid,
	wsd.workflow_step_object_uuid,
	wso.step_object_type as step_object_type,
	CASE
		when wso.action_uuid is not null then wso.action_description
		when wso.condition_uuid is not null then wso.condition_description
	end as step_object_description,
	CASE
		when wso.action_uuid is not null then wso.action_uuid
		when wso.condition_uuid is not null then wso.condition_uuid
	end as step_object_uuid,
	wso.action_uuid,
	wso.action_description,
	wso.condition_uuid,
	wso.condition_description,
	wsd.initial_uuid,
	wsd.terminal_uuid,
	wsd.status_uuid,
	wsd.add_date,
	wsd.mod_date
FROM workflow_step wsd
LEFT JOIN vw_workflow_step_object wso ON wsd.workflow_step_object_uuid = wso.workflow_step_object_uuid;

DROP TRIGGER IF EXISTS trigger_workflow_step_upsert ON vw_workflow_step;
CREATE TRIGGER trigger_workflow_step_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_workflow_step
FOR EACH ROW
EXECUTE PROCEDURE upsert_workflow_step ( );


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
			
	