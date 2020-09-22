--======================================================================
/*
Name:			prod_tables
Parameters:		none
Returns:			
Author:			G. Cattabriga
Date:			2020.01.23
Description:	create the production tables, primary keys and comments for ESCALATEv3
Notes:			triggers, foreign keys and other constraints are in other sql files
 				20200123: remove the measure and measure type entities - measure will be part 
 				of the originating entity
 				20200130: add measure, measure_type back in, and also add the xref table 
				 measure_x
 */
--======================================================================

-- DROP SCHEMA dev cascade;
-- CREATE SCHEMA dev;
 --=====================================
 -- EXTENSIONS 
 --=====================================
-- CREATE EXTENSION if not exists ltree with schema dev;
-- REATE EXTENSION if not exists tablefunc with schema dev;
-- CREATE EXTENSION if not exists "uuid-ossp" with schema dev;
-- CREATE EXTENSION IF NOT EXISTS hstore with schema dev;
-- set search_path = dev, public;
 
 --=====================================
 -- DROP TYPES 
 --=====================================
DROP TYPE IF EXISTS val cascade; 
DROP TYPE IF EXISTS type_def_category cascade;


 --=====================================
 -- DROP FUNCTIONS
 --=====================================
 -- this will delete all escalate functions
 -- do this during dev, as we might miss
 -- some functions along the way
DO
$do$
DECLARE
   _sql text;
BEGIN
	SELECT INTO _sql
		string_agg(format('DROP %s %s cascade;', 
		CASE prokind
			WHEN 'f' THEN 'FUNCTION'
			WHEN 'a' THEN 'AGGREGATE'
			WHEN 'p' THEN 'PROCEDURE'
		END
		, oid::regprocedure), E'\n')
	FROM   pg_proc
	WHERE  pronamespace = 'dev'::regnamespace  -- schema name here!
	AND proname like any (array['get%', 'put%', 'upsert%', 'load_%'])  
   	-- AND prokind = ANY ('{f,a,p}')         -- optionally filter kinds
   	;
   	IF _sql IS NOT NULL THEN
   	--   RAISE NOTICE '%', _sql;  -- debug / check first
		EXECUTE _sql;         -- uncomment payload once you are sure
   	ELSE 
		RAISE NOTICE 'No functions found in schema';
   	END IF;
END
$do$;

/* 
DROP FUNCTION IF EXISTS read_file_utf8 (path CHARACTER VARYING) cascade;
DROP FUNCTION IF EXISTS read_file (path CHARACTER VARYING) cascade;
DROP FUNCTION IF EXISTS isdate (txt VARCHAR) CASCADE;
DROP FUNCTION IF EXISTS read_dirfiles (PATH CHARACTER VARYING) cascade;
DROP FUNCTION IF EXISTS get_table_uuids() cascade;
DROP FUNCTION IF EXISTS get_material_uuid_bystatus () CASCADE;
DROP FUNCTION IF EXISTS get_material_nameref_bystatus () cascade;
DROP FUNCTION IF EXISTS get_material_bydescr_bystatus () cascade;
DROP FUNCTION IF EXISTS get_material_type () cascade;
DROP FUNCTION IF EXISTS get_actor () cascade;
DROP FUNCTION IF EXISTS get_calculation_def () cascade;
DROP FUNCTION IF EXISTS get_calculation () cascade;
DROP FUNCTION IF EXISTS get_val_json () cascade;
DROP FUNCTION IF EXISTS get_val_actual () cascade;
DROP FUNCTION IF EXISTS get_val () cascade;
DROP FUNCTION IF EXISTS get_val_unit () cascade;
DROP FUNCTION IF EXISTS put_val () cascade;
DROP FUNCTION IF EXISTS get_chemaxon_directory () cascade;
DROP FUNCTION IF EXISTS get_chemaxon_version () cascade;
DROP FUNCTION IF EXISTS run_descriptor () cascade;
DROP FUNCTION IF EXISTS get_charge_count () cascade;
DROP FUNCTION IF EXISTS math_op () cascade;
DROP FUNCTION IF EXISTS delete_assigned_recs () cascade;
DROP FUNCTION IF EXISTS upsert_actor () cascade;
DROP FUNCTION IF EXISTS upsert_actor_pref () cascade;
DROP FUNCTION IF EXISTS upsert_calculation () cascade;
DROP FUNCTION IF EXISTS upsert_calculation_def () cascade;
DROP FUNCTION IF EXISTS upsert_edocument () cascade;
DROP FUNCTION IF EXISTS upsert_edocument_assign () cascade;
DROP FUNCTION IF EXISTS upsert_material () cascade;
DROP FUNCTION IF EXISTS upsert_material () cascade;
DROP FUNCTION IF EXISTS upsert_material_type () cascade;
DROP FUNCTION IF EXISTS upsert_material_refname_def () cascade;
DROP FUNCTION IF EXISTS upsert_organization () cascade;
DROP FUNCTION IF EXISTS upsert_person () cascade;
DROP FUNCTION IF EXISTS upsert_systemtool () cascade;
DROP FUNCTION IF EXISTS upsert_systemtool_type () cascade;
DROP FUNCTION IF EXISTS upsert_tag_type () cascade;
DROP FUNCTION IF EXISTS upsert_tag () cascade;
DROP FUNCTION IF EXISTS upsert_tag_x () cascade;
DROP FUNCTION IF EXISTS upsert_udf_def () cascade;
DROP FUNCTION IF EXISTS upsert_status () cascade;
DROP FUNCTION IF EXISTS upsert_property_def () cascade;
DROP FUNCTION IF EXISTS upsert_property () cascade;
DROP FUNCTION IF EXISTS upsert_material_property () cascade;
DROP FUNCTION IF EXISTS upsert_note () cascade;
DROP FUNCTION IF EXISTS upsert_type_def () cascade;
*/



 --=====================================
 -- DROP VIEWS
 --=====================================
 -- this will delete all escalate functions
 -- do this during dev, as we might miss
 -- some functions along the way
DO
$do$
DECLARE
   _sql text;
BEGIN
	SELECT INTO _sql
		string_agg(format('DROP VIEW IF EXISTS %s cascade;', 
		viewname), E'\n')
	FROM   pg_catalog.pg_views
	where schemaname = 'dev'  -- schema name here!
   	;
   	IF _sql IS NOT NULL THEN
   		-- RAISE NOTICE '%', _sql;  -- debug / check first
		EXECUTE _sql;         -- uncomment payload once you are sure
   	ELSE 
		RAISE NOTICE 'No views found in schema';
   	END IF;
END
$do$;

/* 
DROP VIEW IF EXISTS vw_actor cascade;
DROP VIEW IF EXISTS vw_actor_pref cascade;
DROP VIEW IF EXISTS vw_calculation cascade;
DROP VIEW IF EXISTS vw_calculation_def cascade;
DROP VIEW IF EXISTS vw_edocument cascade;
DROP VIEW IF EXISTS vw_experiment_measure_calculation cascade;
DROP VIEW IF EXISTS vw_experiment_measure_calculation_json cascade;
DROP VIEW IF EXISTS vw_inventory cascade;
DROP VIEW IF EXISTS vw_inventory_material cascade;
DROP VIEW IF EXISTS vw_material cascade;
DROP VIEW IF EXISTS vw_material_calculation_json cascade;
DROP VIEW IF EXISTS vw_material_calculation_raw cascade;
DROP VIEW IF EXISTS vw_material_raw cascade;
DROP VIEW IF EXISTS vw_material_refname_def cascade;
DROP VIEW IF EXISTS vw_material_type cascade;
DROP VIEW IF EXISTS vw_property_def cascade;
DROP VIEW IF EXISTS vw_property cascade;
DROP VIEW IF EXISTS vw_material_property cascade;
DROP VIEW IF EXISTS vw_note cascade;
DROP VIEW IF EXISTS vw_organization cascade;
DROP VIEW IF EXISTS vw_person cascade;
DROP VIEW IF EXISTS vw_status cascade;
DROP VIEW IF EXISTS vw_systemtool cascade;
DROP VIEW IF EXISTS vw_systemtool_raw cascade;
DROP VIEW IF EXISTS vw_systemtool_type cascade;
DROP VIEW IF EXISTS vw_tag cascade;
DROP VIEW IF EXISTS vw_tag_type cascade;
DROP VIEW IF EXISTS vw_tag_x cascade;
DROP VIEW IF EXISTS vw_type_def cascade;
*/

 --=====================================
 -- DROP TABLES 
 --=====================================
DROP TABLE IF EXISTS sys_audit cascade; 
DROP TABLE IF EXISTS bom cascade; 
DROP TABLE IF EXISTS organization cascade; 
DROP TABLE IF EXISTS person cascade; 
DROP TABLE IF EXISTS systemtool cascade;
DROP TABLE IF EXISTS systemtool_type cascade;
DROP TABLE IF EXISTS actor cascade;
DROP TABLE IF EXISTS actor_pref cascade;
DROP TABLE IF EXISTS experiment cascade;
DROP TABLE IF EXISTS experiment_workflow cascade;
DROP TABLE IF EXISTS material cascade;
DROP TABLE IF EXISTS material_x cascade;
DROP TABLE IF EXISTS material_type cascade;
DROP TABLE IF EXISTS material_type_x cascade;
DROP TABLE IF EXISTS material_refname cascade;
DROP TABLE IF EXISTS material_refname_x cascade;
DROP TABLE IF EXISTS material_refname_def cascade;
DROP TABLE IF EXISTS outcome cascade;
DROP TABLE IF EXISTS outcome_type cascade;
DROP TABLE IF EXISTS outcome_x cascade;
DROP TABLE IF EXISTS property cascade;
DROP TABLE IF EXISTS property_def cascade;
DROP TABLE IF EXISTS property_x cascade;
DROP TABLE IF EXISTS parameter cascade;
DROP TABLE IF EXISTS parameter_def cascade;
DROP TABLE IF EXISTS parameter_x cascade;
DROP TABLE IF EXISTS calculation_class cascade;
DROP TABLE IF EXISTS calculation_def cascade;
DROP TABLE IF EXISTS calculation cascade;
DROP TABLE IF EXISTS calculation_eval cascade;
DROP TABLE IF EXISTS inventory cascade;
DROP TABLE IF EXISTS measure cascade;
DROP TABLE IF EXISTS measure_x cascade;
DROP TABLE IF EXISTS measure_type cascade;
DROP TABLE IF EXISTS note cascade;
DROP TABLE IF EXISTS note_x cascade;
DROP TABLE IF EXISTS edocument cascade;
DROP TABLE IF EXISTS edocument_x cascade;
DROP TABLE IF EXISTS tag cascade;
DROP TABLE IF EXISTS tag_x cascade;
DROP TABLE IF EXISTS tag_type cascade;
DROP TABLE IF EXISTS type_def cascade;
DROP TABLE IF EXISTS udf cascade;
DROP TABLE IF EXISTS udf_x cascade;
DROP TABLE IF EXISTS udf_def cascade;
DROP TABLE IF EXISTS workflow cascade;
DROP TABLE IF EXISTS workflow_step cascade;
DROP TABLE IF EXISTS workflow_state_def cascade;
DROP TABLE IF EXISTS workflow_state cascade;
DROP TABLE IF EXISTS workflow_type cascade;
DROP TABLE IF EXISTS action_def cascade;
DROP TABLE IF EXISTS action cascade;
DROP TABLE IF EXISTS action_condition cascade;
DROP TABLE IF EXISTS status cascade;
-- DROP TABLE IF EXISTS escalate_change_log cascade;
-- DROP TABLE IF EXISTS escalate_version cascade;

 --=====================================
 -- CREATE DATA TYPES 
 --=====================================
-- define (enumerate) the value types where hierachy is seperated by '_' with simple data types (int, num, text) as single phrase; treat 'array' like a fifo stack
-- CREATE TYPE val_type AS ENUM ('int', 'array_int', 'num', 'array_num', 'text', 'array_text', 'blob_text', 'blob_pdf', 'blob_svg', 'blob_jpg', 'blob_png', 'blob_xrd', 'bool', 'array_bool');

-- define (enumerate) the type_def categories 
CREATE TYPE type_def_category AS ENUM ('data', 'file', 'role');


CREATE TYPE val AS (
	v_type_uuid uuid,
	v_unit varchar,
	v_text varchar,
	v_text_array varchar[],
	v_int int8,
	v_int_array int8[],
	v_num numeric,
	v_num_array numeric[],
	v_edocument_uuid uuid,
	v_source_uuid uuid,
	v_bool BOOLEAN,
	v_bool_array BOOLEAN[]	
);

 --=====================================
 -- CREATE TABLES 
 --=====================================
 ---------------------------------------
-- Table structure for sys_audit
---------------------------------------
CREATE TABLE sys_audit (
    event_id bigserial primary key,
    schema_name text not null,
    table_name text not null,
    relid oid not null,
    session_user_name text,
    action_tstamp_tx timestamptz NOT NULL,
    action_tstamp_stm timestamptz NOT NULL,
    action_tstamp_clk timestamptz NOT NULL,
    transaction_id bigint,
    application_name text,
    client_addr inet,
    client_port integer,
    client_query text,
    action TEXT NOT NULL CHECK (action IN ('I','D','U', 'T')),
    row_data hstore,
    changed_fields hstore,
    statement_only boolean not null
);


 ---------------------------------------
-- Table structure for type_def
---------------------------------------
CREATE TABLE type_def (
	type_def_uuid uuid DEFAULT uuid_generate_v4 (),
	category type_def_category NOT NULL,
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for organization
---------------------------------------
CREATE TABLE organization (
	organization_uuid uuid DEFAULT uuid_generate_v4 (),
	parent_uuid uuid,
	parent_path ltree,
	description varchar COLLATE "pg_catalog"."default",
	full_name varchar COLLATE "pg_catalog"."default" NOT NULL,
	short_name varchar COLLATE "pg_catalog"."default",
	address1 varchar COLLATE "pg_catalog"."default",
	address2 varchar COLLATE "pg_catalog"."default",
	city varchar COLLATE "pg_catalog"."default",
	state_province char(3) COLLATE "pg_catalog"."default",
	zip varchar COLLATE "pg_catalog"."default",
	country varchar COLLATE "pg_catalog"."default",
	website_url varchar COLLATE "pg_catalog"."default",
	phone varchar COLLATE "pg_catalog"."default",
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for person
---------------------------------------
CREATE TABLE person (
	person_uuid uuid DEFAULT uuid_generate_v4 (),
	first_name varchar COLLATE "pg_catalog"."default",
	last_name varchar COLLATE "pg_catalog"."default" NOT NULL,
	middle_name varchar COLLATE "pg_catalog"."default",
	address1 varchar COLLATE "pg_catalog"."default",
	address2 varchar COLLATE "pg_catalog"."default",
	city varchar COLLATE "pg_catalog"."default",
	state_province char(3) COLLATE "pg_catalog"."default",
	zip varchar COLLATE "pg_catalog"."default",
	country varchar COLLATE "pg_catalog"."default",
	phone varchar COLLATE "pg_catalog"."default",
	email varchar COLLATE "pg_catalog"."default",
	title VARCHAR COLLATE "pg_catalog"."default",
	suffix varchar COLLATE "pg_catalog"."default",
	organization_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for systemtool
---------------------------------------
CREATE TABLE systemtool (
  systemtool_uuid uuid DEFAULT uuid_generate_v4 (),
  systemtool_name varchar COLLATE "pg_catalog"."default" NOT NULL,
  description varchar COLLATE "pg_catalog"."default",
  systemtool_type_uuid uuid,
  vendor_organization_uuid uuid,
  model varchar COLLATE "pg_catalog"."default",
  serial varchar COLLATE "pg_catalog"."default",
  ver varchar COLLATE "pg_catalog"."default" NOT NULL,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for systemtool_type
---------------------------------------
CREATE TABLE systemtool_type (
  systemtool_type_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for actor
---------------------------------------
CREATE TABLE actor (
	actor_uuid uuid DEFAULT uuid_generate_v4 (),
	person_uuid uuid,
	organization_uuid uuid,
	systemtool_uuid uuid,
	description varchar COLLATE "pg_catalog"."default",
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for actor_pref
---------------------------------------
CREATE TABLE actor_pref (
	actor_pref_uuid uuid DEFAULT uuid_generate_v4 (),
	actor_uuid uuid,
	pkey varchar COLLATE "pg_catalog"."default" NOT NULL,
	pvalue varchar COLLATE "pg_catalog"."default",
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for experiment
---------------------------------------
CREATE TABLE experiment (
	experiment_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_uid varchar,
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	parent_uuid uuid,
	parent_path ltree,
	owner_uuid uuid,
	operator_uuid uuid,
	lab_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for experiment_workflow
---------------------------------------
CREATE TABLE experiment_workflow (
	experiment_workflow_uuid uuid DEFAULT uuid_generate_v4 (),
	experiment_uuid uuid,
	workflow_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for material (reference/catalog)
---------------------------------------
CREATE TABLE material (
	material_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	parent_uuid uuid,
	parent_path ltree,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for bom (bill of materials)
---------------------------------------
CREATE TABLE bom (
	bom_uuid uuid DEFAULT uuid_generate_v4 (),
	experiment_uuid uuid NOT NULL,
	material_uuid uuid NOT NULL,
	measure_x_uuid uuid,
	actor_uuid uuid, 
	status_uuid uuid, 
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for material_x
---------------------------------------
CREATE TABLE material_x (
	material_x_uuid uuid DEFAULT uuid_generate_v4 (),
	material_uuid uuid NOT NULL,
	ref_material_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for material_type_x
---------------------------------------
CREATE TABLE material_type_x (
	material_type_x_uuid uuid DEFAULT uuid_generate_v4 (),
	material_uuid uuid NOT NULL,
	material_type_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_type
---------------------------------------
CREATE TABLE material_type (
	material_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_refname
---------------------------------------
CREATE TABLE material_refname (
	material_refname_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	-- material_uuid int8,
	blob_value bytea,
	blob_type varchar,
	material_refname_def_uuid uuid,
	reference varchar COLLATE "pg_catalog"."default",
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_refname_x
---------------------------------------
CREATE TABLE material_refname_x (
	material_refname_x_uuid uuid DEFAULT uuid_generate_v4 (),
	material_uuid uuid NOT NULL,
	material_refname_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_refname_def
---------------------------------------
CREATE TABLE material_refname_def (
	material_refname_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for property
---------------------------------------
CREATE TABLE property (
	property_uuid uuid DEFAULT uuid_generate_v4 (),
	property_def_uuid uuid NOT NULL,
	property_val val NOT NULL,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for property_x
---------------------------------------
CREATE TABLE property_x (
	property_x_uuid uuid DEFAULT uuid_generate_v4 (),
	material_uuid uuid NOT NULL,
	property_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for property_def
---------------------------------------
CREATE TABLE property_def (
	property_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	short_description varchar COLLATE "pg_catalog"."default" NOT NULL,
	valtype_uuid uuid,
	valunit varchar,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for parameter_def
---------------------------------------
CREATE TABLE parameter_def (
	parameter_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	valtype_uuid uuid,
	valunit varchar,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for parameter
---------------------------------------
CREATE TABLE parameter (
	parameter_uuid uuid DEFAULT uuid_generate_v4 (),
	parameter_def_uuid uuid NOT NULL,
	parameter_val val NOT NULL,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for parameter_x
---------------------------------------
CREATE TABLE parameter_x (
	parameter_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_parameter_uuid uuid NOT NULL,
	parameter_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for calculation_class
---------------------------------------
CREATE TABLE calculation_class (
	calculation_class_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" not null,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for calculation_def
---------------------------------------
CREATE TABLE calculation_def (
	calculation_def_uuid uuid DEFAULT uuid_generate_v4 (),
	short_name varchar COLLATE "pg_catalog"."default" NOT NULL,
	calc_definition varchar COLLATE "pg_catalog"."default" NOT NULL,
	systemtool_uuid uuid,
	description varchar COLLATE "pg_catalog"."default",
	in_source_uuid uuid,
	in_type_uuid uuid,
	in_opt_source_uuid uuid,
	in_opt_type_uuid uuid,
	out_type_uuid uuid,
	calculation_class_uuid uuid,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


select short_name, calc_definition, description, actor_description, systemtool_name, systemtool_version from vw_calculation_def where short_name = 'atomcount_c_standardize';




---------------------------------------
-- Table structure for calculation
---------------------------------------
CREATE TABLE calculation (
	calculation_uuid uuid DEFAULT uuid_generate_v4 (),
	calculation_def_uuid uuid NOT NULL,
	calculation_alias_name varchar,
	in_val val,
	in_opt_val val,
	out_val val,
	status_uuid uuid,
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for calculation_eval
-- internal use only
---------------------------------------
CREATE TABLE calculation_eval (
	calculation_eval_id serial8,
	calculation_def_uuid uuid,
	in_val val,
	in_opt_val val,
	out_val val,
	calculation_alias_name varchar,
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for inventory
---------------------------------------
CREATE TABLE inventory (
	inventory_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar,
	material_uuid uuid NOT NULL,
	actor_uuid uuid,
	part_no varchar,
	onhand_amt numeric,
	unit varchar,
	-- measure_uuid int8,
	expiration_date timestamptz DEFAULT NULL,
	inventory_location varchar(255) COLLATE "pg_catalog"."default",
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure_x
---------------------------------------
CREATE TABLE measure_x (
	measure_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_measure_uuid uuid NOT NULL,
	measure_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure
---------------------------------------
CREATE TABLE measure (
	measure_uuid uuid DEFAULT uuid_generate_v4 (),
	measure_type_uuid uuid,
	description varchar COLLATE "pg_catalog"."default",
	amount val,
	unit varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure_type
---------------------------------------
CREATE TABLE measure_type (
	measure_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for note_x
---------------------------------------
CREATE TABLE note_x (
	note_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_note_uuid uuid NOT NULL,
	note_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for note
---------------------------------------
CREATE TABLE note (
	note_uuid uuid DEFAULT uuid_generate_v4 (),
	notetext varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for outcome_type
-- ----------------------------
CREATE TABLE outcome_type (
	outcome_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for outcome
-- ----------------------------
CREATE TABLE outcome (
	outcome_uuid uuid DEFAULT uuid_generate_v4 (),
	outcome_ref_uuid uuid,
	actor_uuid uuid,
	outcome_type_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


-- ----------------------------
-- Table structure for outcome_x
-- ----------------------------
CREATE TABLE outcome_x (
	outcome_x_uuid uuid DEFAULT uuid_generate_v4 (),
	outcome_ref_uuid uuid,
	outcome_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for edocument_x
---------------------------------------
CREATE TABLE edocument_x (
	edocument_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_edocument_uuid uuid NOT NULL,
	edocument_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for document
-- ----------------------------
CREATE TABLE edocument (
	edocument_uuid uuid DEFAULT uuid_generate_v4 (),
	title varchar COLLATE "pg_catalog"."default" NOT NULL,
	description varchar COLLATE "pg_catalog"."default",
	filename varchar COLLATE "pg_catalog"."default",
	source varchar COLLATE "pg_catalog"."default",
	edocument bytea NOT NULL,
	doc_type_uuid uuid NOT NULL,
	doc_ver varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for tag_x
---------------------------------------
CREATE TABLE tag_x (
	tag_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_tag_uuid uuid NOT NULL,
	tag_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for tag
-- ----------------------------
CREATE TABLE tag (
	tag_uuid uuid DEFAULT uuid_generate_v4 (),
	tag_type_uuid uuid,
	display_text varchar(16) COLLATE "pg_catalog"."default" NOT NULL,
	description varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for tag_type
-- ----------------------------
CREATE TABLE tag_type (
	tag_type_uuid uuid DEFAULT uuid_generate_v4 (),
	type varchar(32) COLLATE "pg_catalog"."default",
	description varchar COLLATE "pg_catalog"."default",
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for udf_x
-- ----------------------------
CREATE TABLE udf_x (
	udf_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_udf_uuid uuid NOT NULL,
	udf_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for udf
-- ----------------------------
CREATE TABLE udf (
	udf_uuid uuid DEFAULT uuid_generate_v4 (),
	udf_def_uuid uuid,
	udf_val val,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for udf_def
-- ----------------------------
CREATE TABLE udf_def (
	udf_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	valtype_uuid uuid,
	unit varchar,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


-- ----------------------------
-- Table structure for workflow
-- ----------------------------
CREATE TABLE workflow (
	workflow_uuid uuid DEFAULT uuid_generate_v4 (),
	workflow_type_uuid uuid,
	description varchar COLLATE "pg_catalog"."default",
	experiment_uuid uuid NOT NULL, 
	parent_uuid uuid,
	parent_path ltree,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


-- ----------------------------
-- Table structure for workflow_step
-- ----------------------------
CREATE TABLE workflow_step (
	workflow_step_uuid uuid DEFAULT uuid_generate_v4 (),
	workflow_uuid uuid,
	seq int8 NOT NULL,
	action_uuid uuid NOT NULL,
	action_condition_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for workflow_state_def
---------------------------------------
CREATE TABLE workflow_state_def (
	workflow_state_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	status_uuid uuid,
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for workflow_state
-- ----------------------------
CREATE TABLE workflow_state (
	workflow_state_uuid uuid DEFAULT uuid_generate_v4 (),
	workflow_step_uuid uuid,
	workflow_state_def_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for workflow_type
---------------------------------------
CREATE TABLE workflow_type (
	workflow_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for workflow_action_def
---------------------------------------
CREATE TABLE action_def (
	action_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	status_uuid uuid,
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

 ---------------------------------------
-- Table structure for workflow_action
---------------------------------------
CREATE TABLE action (
	action_uuid uuid DEFAULT uuid_generate_v4 (),
	action_def_uuid uuid,
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	start_date timestamptz,
	end_date timestamptz,
	duration numeric,
	repeating int8,
	ref_parameter_uuid uuid,
	calculation_def_uuid uuid,
	source_material_uuid uuid,
	destination_material_uuid uuid,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for workflow_action_condition
---------------------------------------
CREATE TABLE action_condition (
	action_condition_uuid uuid DEFAULT uuid_generate_v4 (),
	calculation_def_uuid uuid,
	in_val val,
	in_opt_val val,
	out_val val,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


-- ----------------------------
-- Table structure for status
-- ----------------------------
CREATE TABLE status (
	status_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


/*
-- ----------------------------
-- Table for [internal] escalate use only
-- ----------------------------
CREATE TABLE escalate_change_log (
 change_log_uuid uuid DEFAULT uuid_generate_v4 (),
 issue varchar COLLATE "pg_catalog"."default",
 object_type varchar COLLATE "pg_catalog"."default",
 object_name varchar COLLATE "pg_catalog"."default",
 resolution varchar COLLATE "pg_catalog"."default",
 author varchar COLLATE "pg_catalog"."default",
 status varchar COLLATE "pg_catalog"."default",
 create_date timestamptz NOT NULL DEFAULT NOW(),
 close_date timestamptz NOT NULL DEFAULT NOW()
);

CREATE TABLE escalate_version (
 ver_uuid uuid DEFAULT uuid_generate_v4 (),
 short_name varchar COLLATE "pg_catalog"."default",
 description varchar COLLATE "pg_catalog"."default",	
 add_date timestamptz NOT NULL DEFAULT NOW()
);
 */
--=====================================
-- KEYS
--=====================================

CREATE INDEX "ix_sys_audit_relid" ON sys_audit (relid);

CREATE INDEX "ix_sys_audit_action_tstamp_tx_stm" ON sys_audit (action_tstamp_stm);

CREATE INDEX "ix_sys_audit_action" ON sys_audit (action);

ALTER TABLE organization
	ADD CONSTRAINT "pk_organization_organization_uuid" PRIMARY KEY (organization_uuid),
		ADD CONSTRAINT "un_organization" UNIQUE (full_name);
CREATE INDEX "ix_organization_parent_path" ON organization
USING GIST (parent_path);
CREATE INDEX "ix_organization_parent_uuid" ON organization (parent_uuid);
CLUSTER organization
USING "pk_organization_organization_uuid";

ALTER TABLE person
	ADD CONSTRAINT "pk_person_person_uuid" PRIMARY KEY (person_uuid);
CREATE UNIQUE INDEX "un_person" ON person (coalesce(last_name, NULL), coalesce(first_name, NULL), coalesce(middle_name, NULL));
CLUSTER person
USING "pk_person_person_uuid";

ALTER TABLE systemtool
	ADD CONSTRAINT "pk_systemtool_systemtool_uuid" PRIMARY KEY (systemtool_uuid),
		ADD CONSTRAINT "un_systemtool" UNIQUE (systemtool_name, systemtool_type_uuid, vendor_organization_uuid, ver);
CLUSTER systemtool
USING "pk_systemtool_systemtool_uuid";

ALTER TABLE systemtool_type
	ADD CONSTRAINT "pk_systemtool_systemtool_type_uuid" PRIMARY KEY (systemtool_type_uuid);
CLUSTER systemtool_type
USING "pk_systemtool_systemtool_type_uuid";

ALTER TABLE actor
	ADD CONSTRAINT "pk_actor_uuid" PRIMARY KEY (actor_uuid);
CREATE UNIQUE INDEX "un_actor" ON actor (coalesce(person_uuid, NULL), coalesce(organization_uuid, NULL), coalesce(systemtool_uuid, NULL));
CLUSTER actor
USING "pk_actor_uuid";

ALTER TABLE actor_pref
	ADD CONSTRAINT "pk_actor_pref_uuid" PRIMARY KEY (actor_pref_uuid);
CLUSTER actor_pref
USING "pk_actor_pref_uuid";

ALTER TABLE experiment
	ADD CONSTRAINT "pk_experiment_experiment_uuid" PRIMARY KEY (experiment_uuid);
CREATE INDEX "ix_experiment_parent_path" ON experiment
USING GIST (parent_path);
CREATE INDEX "ix_experiment_parent_uuid" ON experiment (parent_uuid);
CLUSTER experiment
USING "pk_experiment_experiment_uuid";

ALTER TABLE experiment_workflow
	ADD CONSTRAINT "pk_experiment_workflow_uuid" PRIMARY KEY (experiment_workflow_uuid);
CLUSTER experiment_workflow
USING "pk_experiment_workflow_uuid";

-- material constraints
ALTER TABLE material
	ADD CONSTRAINT "pk_material_material_uuid" PRIMARY KEY (material_uuid),
		ADD CONSTRAINT "un_material" UNIQUE (description, parent_uuid, status_uuid);
-- CREATE UNIQUE INDEX "un_material" ON material (coalesce(description, NULL), coalesce(parent_uuid, NULL), coalesce(status_uuid, NULL));
CREATE INDEX "ix_material_parent_path" ON material
USING GIST (parent_path);
CREATE INDEX "ix_material_parent_uuid" ON material (parent_uuid);
CLUSTER material
USING "pk_material_material_uuid";

-- bom (bill of materials) constraints
ALTER TABLE bom
	ADD CONSTRAINT "pk_bom_bom_uuid" PRIMARY KEY (bom_uuid),
		ADD CONSTRAINT "un_bom_experiment_material" UNIQUE (experiment_uuid, material_uuid);
CREATE INDEX "ix_bom_experiment_uuid" ON bom (experiment_uuid);
CLUSTER bom
USING "pk_bom_bom_uuid";

-- material_x constraints
ALTER TABLE material_x
	ADD CONSTRAINT "pk_material_x_material_x_uuid" PRIMARY KEY (material_x_uuid),
		ADD CONSTRAINT "un_material_x" UNIQUE (material_uuid, ref_material_uuid);
CLUSTER material_x
USING "pk_material_x_material_x_uuid";

ALTER TABLE material_type
	ADD CONSTRAINT "pk_material_type_material_type_uuid" PRIMARY KEY (material_type_uuid),
		ADD CONSTRAINT "un_material_type" UNIQUE (description);
CLUSTER material_type
USING "pk_material_type_material_type_uuid";

ALTER TABLE material_type_x
	ADD CONSTRAINT "pk_material_type_x_material_type_x_uuid" PRIMARY KEY (material_type_x_uuid),
		ADD CONSTRAINT "un_material_type_x" UNIQUE (material_uuid, material_type_uuid);
CLUSTER material_type_x
USING "pk_material_type_x_material_type_x_uuid";

ALTER TABLE material_refname
	ADD CONSTRAINT "pk_material_refname_material_refname_uuid" PRIMARY KEY (material_refname_uuid),
		ADD CONSTRAINT "un_material_refname" UNIQUE (description, material_refname_def_uuid);
CLUSTER material_refname
USING "pk_material_refname_material_refname_uuid";

ALTER TABLE material_refname_x
	ADD CONSTRAINT "pk_material_refname_x_material_refname_x_uuid" PRIMARY KEY (material_refname_x_uuid),
		ADD CONSTRAINT "un_material_refname_x" UNIQUE (material_uuid, material_refname_uuid);
CLUSTER material_refname_x
USING "pk_material_refname_x_material_refname_x_uuid";

ALTER TABLE material_refname_def
	ADD CONSTRAINT "pk_material_refname_def_material_refname_def_uuid" PRIMARY KEY (material_refname_def_uuid);
CLUSTER material_refname_def
USING "pk_material_refname_def_material_refname_def_uuid";

-- property (of materials) constraints
ALTER TABLE property
	ADD CONSTRAINT "pk_property_property_uuid" PRIMARY KEY (property_uuid);
CLUSTER property
USING "pk_property_property_uuid";

-- property_def (of materials) constraints
ALTER TABLE property_def
	ADD CONSTRAINT "pk_property_def_property_def_uuid" PRIMARY KEY (property_def_uuid),
		ADD CONSTRAINT "un_property_def" UNIQUE (short_description);
CLUSTER property_def
USING "pk_property_def_property_def_uuid";

-- property_x (of materials) constraints
ALTER TABLE property_x
	ADD CONSTRAINT "pk_property_x_property_x_uuid" PRIMARY KEY (property_x_uuid),
		ADD CONSTRAINT "un_property_x_def" UNIQUE (material_uuid, property_uuid);
CLUSTER property_x
USING "pk_property_x_property_x_uuid";

-- parameter constraints
ALTER TABLE parameter
	ADD CONSTRAINT "pk_parameter_parameter_uuid" PRIMARY KEY (parameter_uuid);
CLUSTER parameter
USING "pk_parameter_parameter_uuid";

-- parameter_def constraints
ALTER TABLE parameter_def
	ADD CONSTRAINT "pk_parameter_def_parameter_def_uuid" PRIMARY KEY (parameter_def_uuid),
		ADD CONSTRAINT "un_parameter_def" UNIQUE (description);
CLUSTER parameter_def
USING "pk_parameter_def_parameter_def_uuid";

-- parameter_x constraints
ALTER TABLE parameter_x
	ADD CONSTRAINT "pk_parameter_x_parameter_x_uuid" PRIMARY KEY (parameter_x_uuid),
		ADD CONSTRAINT "un_parameter_x_def" UNIQUE (ref_parameter_uuid, parameter_uuid);
CLUSTER parameter_x
USING "pk_parameter_x_parameter_x_uuid";

ALTER TABLE calculation_class
	ADD CONSTRAINT "pk_calculation_class_calculation_class_uuid" PRIMARY KEY (calculation_class_uuid);
CLUSTER calculation_class
USING "pk_calculation_class_calculation_class_uuid";

ALTER TABLE calculation_def
	ADD CONSTRAINT "pk_calculation_calculation_def_uuid" PRIMARY KEY (calculation_def_uuid),
		ADD CONSTRAINT "un_calculation_def" UNIQUE (actor_uuid, short_name, calc_definition);
CLUSTER calculation_def
USING "pk_calculation_calculation_def_uuid";

ALTER TABLE calculation
	ADD CONSTRAINT "pk_calculation_calculation_uuid" PRIMARY KEY (calculation_uuid),
		ADD CONSTRAINT "un_calculation" UNIQUE (calculation_def_uuid, in_val, in_opt_val);
CLUSTER calculation
USING "pk_calculation_calculation_uuid";

ALTER TABLE calculation_eval
	ADD CONSTRAINT "pk_calculation_eval_calculation_eval_id" PRIMARY KEY (calculation_eval_id),
		ADD CONSTRAINT "un_calculation_eval" UNIQUE (calculation_def_uuid, in_val, in_opt_val);
CLUSTER calculation_eval
USING "pk_calculation_eval_calculation_eval_id";

ALTER TABLE inventory
	ADD CONSTRAINT "pk_inventory_inventory_uuid" PRIMARY KEY (inventory_uuid),
		ADD CONSTRAINT "un_inventory" UNIQUE (material_uuid, actor_uuid, add_date);
CLUSTER inventory
USING "pk_inventory_inventory_uuid";

ALTER TABLE measure
	ADD CONSTRAINT "pk_measure_measure_uuid" PRIMARY KEY (measure_uuid),
		ADD CONSTRAINT "un_measure" UNIQUE (measure_uuid);
CLUSTER measure
USING "pk_measure_measure_uuid";

ALTER TABLE measure_x
	ADD CONSTRAINT "pk_measure_x_measure_x_uuid" PRIMARY KEY (measure_x_uuid),
		ADD CONSTRAINT "un_measure_x" UNIQUE (ref_measure_uuid, measure_uuid);
CLUSTER measure_x
USING "pk_measure_x_measure_x_uuid";

ALTER TABLE measure_type
	ADD CONSTRAINT "pk_measure_type_measure_type_uuid" PRIMARY KEY (measure_type_uuid);
CLUSTER measure_type
USING "pk_measure_type_measure_type_uuid";

ALTER TABLE note
	ADD CONSTRAINT "pk_note_note_uuid" PRIMARY KEY (note_uuid);
CLUSTER note
USING "pk_note_note_uuid";

ALTER TABLE note_x
	ADD CONSTRAINT "pk_note_x_note_x_uuid" PRIMARY KEY (note_x_uuid),
		ADD CONSTRAINT "un_note_x" UNIQUE (ref_note_uuid, note_uuid);
CLUSTER note_x
USING "pk_note_x_note_x_uuid";

ALTER TABLE edocument
	ADD CONSTRAINT "pk_edocument_edocument_uuid" PRIMARY KEY (edocument_uuid),
		ADD CONSTRAINT "un_edocument" UNIQUE (title, doc_ver);
CLUSTER edocument
USING "pk_edocument_edocument_uuid";

ALTER TABLE edocument_x
	ADD CONSTRAINT "pk_edocument_x_edocument_x_uuid" PRIMARY KEY (edocument_x_uuid),
		ADD CONSTRAINT "un_edocument_x" UNIQUE (ref_edocument_uuid, edocument_uuid);
CLUSTER edocument_x
USING "pk_edocument_x_edocument_x_uuid";

ALTER TABLE tag
	ADD CONSTRAINT "pk_tag_tag_uuid" PRIMARY KEY (tag_uuid),
		ADD CONSTRAINT "un_tag" UNIQUE (display_text, tag_type_uuid);
CLUSTER tag
USING "pk_tag_tag_uuid";

ALTER TABLE tag_x
	ADD CONSTRAINT "pk_tag_x_tag_x_uuid" PRIMARY KEY (tag_x_uuid),
		ADD CONSTRAINT "un_tag_x" UNIQUE (ref_tag_uuid, tag_uuid);
CLUSTER tag_x
USING "pk_tag_x_tag_x_uuid";

ALTER TABLE tag_type
	ADD CONSTRAINT "pk_tag_tag_type_uuid" PRIMARY KEY (tag_type_uuid),
		ADD CONSTRAINT "un_tag_type" UNIQUE (type);
CLUSTER tag_type
USING "pk_tag_tag_type_uuid";

ALTER TABLE type_def
	ADD CONSTRAINT "pk_type_def_type_def_uuid" PRIMARY KEY (type_def_uuid),
		ADD CONSTRAINT "un_type_def" UNIQUE (category, description);
CLUSTER type_def
USING "pk_type_def_type_def_uuid";

ALTER TABLE udf
	ADD CONSTRAINT "pk_udf_udf_uuid" PRIMARY KEY (udf_uuid);
CLUSTER udf
USING "pk_udf_udf_uuid";

ALTER TABLE udf_x
	ADD CONSTRAINT "pk_udf_x_udf_x_uuid" PRIMARY KEY (udf_x_uuid),
		ADD CONSTRAINT "un_udf_x" UNIQUE (ref_udf_uuid, udf_uuid);
CLUSTER udf_x
USING "pk_udf_x_udf_x_uuid";

ALTER TABLE udf_def
	ADD CONSTRAINT "pk_udf_def_udf_def_uuid" PRIMARY KEY (udf_def_uuid),
		ADD CONSTRAINT "un_udf_def" UNIQUE (description);
CLUSTER udf_def
USING "pk_udf_def_udf_def_uuid";

-- workflow primary key and constraints
ALTER TABLE workflow
	ADD CONSTRAINT "pk_workflow_workflow_uuid" PRIMARY KEY (workflow_uuid);
CREATE INDEX "ix_workflow_experiment_uuid" ON workflow (experiment_uuid);
CREATE INDEX "ix_workflow_parent_uuid" ON workflow
USING GIST (parent_path);
CLUSTER workflow
USING "pk_workflow_workflow_uuid";

-- workflow_step primary key and constraints
ALTER TABLE workflow_step
	ADD CONSTRAINT "pk_workflow_step_workflow_step_uuid" PRIMARY KEY (workflow_step_uuid);
CLUSTER workflow_step
USING "pk_workflow_step_workflow_step_uuid";

-- workflow_state_def primary key and constraints
ALTER TABLE workflow_state_def
	ADD CONSTRAINT "pk_workflow_state_def_workflow_state_def_uuid" PRIMARY KEY (workflow_state_def_uuid),
		ADD CONSTRAINT "un_workflow_state_def" UNIQUE (description);
CLUSTER workflow_state_def
USING "pk_workflow_state_def_workflow_state_def_uuid";

-- workflow_state primary key and constraints
ALTER TABLE workflow_state
	ADD CONSTRAINT "pk_workflow_state_workflow_state_uuid" PRIMARY KEY (workflow_state_uuid);
CLUSTER workflow_state
USING "pk_workflow_state_workflow_state_uuid";

ALTER TABLE workflow_type
	ADD CONSTRAINT "pk_workflow_type_workflow_type_uuid" PRIMARY KEY (workflow_type_uuid),
		ADD CONSTRAINT "un_workflow_type" UNIQUE (description);
CLUSTER workflow_type
USING "pk_workflow_type_workflow_type_uuid";

-- action_def primary key and constraints
ALTER TABLE action_def
	ADD CONSTRAINT "pk_action_def_action_def_uuid" PRIMARY KEY (action_def_uuid),
		ADD CONSTRAINT "un_action_def" UNIQUE (description);
CLUSTER action_def
USING "pk_action_def_action_def_uuid";

-- action primary key and constraints
ALTER TABLE action
	ADD CONSTRAINT "pk_action_action_uuid" PRIMARY KEY (action_uuid);
CLUSTER action
USING "pk_action_action_uuid";

-- workflow_action_condition primary key and constraints
ALTER TABLE action_condition
	ADD CONSTRAINT "pk_action_condition_action_condition_uuid" PRIMARY KEY (action_condition_uuid);
CLUSTER action_condition
USING "pk_action_condition_action_condition_uuid";

-- status primary key and constraints
ALTER TABLE status
	ADD CONSTRAINT "pk_status_status_uuid" PRIMARY KEY (status_uuid),
			ADD CONSTRAINT "un_status" UNIQUE (description);;
CLUSTER status
USING "pk_status_status_uuid";


/*
ALTER TABLE escalate_change_log 
 ADD CONSTRAINT "pk_escalate_change_log_uuid" PRIMARY KEY (change_log_uuid);
CLUSTER escalate_change_log USING "pk_escalate_change_log_uuid";

ALTER TABLE escalate_version 
 ADD CONSTRAINT "pk_escalate_version_uuid" PRIMARY KEY (ver_uuid),
 ADD CONSTRAINT "un_escalate_version" UNIQUE (ver_uuid, short_name);
CLUSTER escalate_version USING "pk_escalate_version_uuid";
 */
--=====================================
-- FOREIGN KEYS
--=====================================
-- ALTER TABLE organization DROP CONSTRAINT fk_organization_note_1;

ALTER TABLE organization
	ADD CONSTRAINT fk_organization_organization_1 FOREIGN KEY (parent_uuid) REFERENCES organization (organization_uuid);

-- ALTER TABLE person DROP CONSTRAINT fk_person_organization_1,
--	DROP CONSTRAINT fk_person_note_1;

ALTER TABLE person
	ADD CONSTRAINT fk_person_organization_1 FOREIGN KEY (organization_uuid) REFERENCES organization (organization_uuid);

-- ALTER TABLE systemtool DROP CONSTRAINT fk_systemtool_systemtool_type_1,
--	DROP CONSTRAINT fk_systemtool_organization_1,
--	DROP CONSTRAINT fk_systemtool_note_1;

ALTER TABLE systemtool
	ADD CONSTRAINT fk_systemtool_systemtool_type_1 FOREIGN KEY (systemtool_type_uuid) REFERENCES systemtool_type (systemtool_type_uuid),
		ADD CONSTRAINT fk_systemtool_vendor_1 FOREIGN KEY (vendor_organization_uuid) REFERENCES organization (organization_uuid);

-- ALTER TABLE systemtool_type DROP CONSTRAINT fk_systemtool_type_note_1;
-- ALTER TABLE systemtool_type
-- 	ADD CONSTRAINT fk_systemtool_type_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);
-- ALTER TABLE actor DROP CONSTRAINT fk_actor_person_1,
--	DROP CONSTRAINT fk_actor_organization_1,
--	DROP CONSTRAINT fk_actor_systemtool_1,
--	DROP CONSTRAINT fk_actor_note_1;

ALTER TABLE actor
	ADD CONSTRAINT fk_actor_person_1 FOREIGN KEY (person_uuid) REFERENCES person (person_uuid),
		ADD CONSTRAINT fk_actor_organization_1 FOREIGN KEY (organization_uuid) REFERENCES organization (organization_uuid),
			ADD CONSTRAINT fk_actor_systemtool_1 FOREIGN KEY (systemtool_uuid) REFERENCES systemtool (systemtool_uuid),
				ADD CONSTRAINT fk_actor_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE actor_pref
	ADD CONSTRAINT fk_actor_pref_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);

ALTER TABLE experiment
	ADD CONSTRAINT fk_experiment_actor_owner_1 FOREIGN KEY (owner_uuid) REFERENCES actor (actor_uuid),
		ADD CONSTRAINT fk_experiment_actor_operator_1 FOREIGN KEY (operator_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_experiment_actor_lab_1 FOREIGN KEY (lab_uuid) REFERENCES actor (actor_uuid),
				ADD CONSTRAINT fk_experiment_experiment_1 FOREIGN KEY (parent_uuid) REFERENCES experiment (experiment_uuid),
					ADD CONSTRAINT fk_experiment_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

-- ALTER TABLE material DROP CONSTRAINT fk_material_actor_1,
--	DROP CONSTRAINT fk_material_material_1;
--	DROP CONSTRAINT fk_material_note_1;

ALTER TABLE material
 ADD CONSTRAINT fk_material_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_material_material_1 FOREIGN KEY (parent_uuid) REFERENCES material (material_uuid),
		ADD CONSTRAINT fk_material_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE bom
	ADD CONSTRAINT fk_bom_experiment_1 FOREIGN KEY (experiment_uuid) REFERENCES experiment (experiment_uuid),
		ADD CONSTRAINT fk_bom_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_bom_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE material_x
	ADD CONSTRAINT fk_material_x_material_1 FOREIGN KEY (ref_material_uuid) REFERENCES material (material_uuid);
-- ALTER TABLE material_type DROP CONSTRAINT fk_material_type_note_1;
-- ALTER TABLE material_type
--	ADD CONSTRAINT fk_material_type_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);
--ALTER TABLE material_type_x DROP CONSTRAINT fk_material_type_x_material_1,
--	DROP CONSTRAINT fk_material_type_x_material_type_1;

ALTER TABLE material_type_x
	ADD CONSTRAINT fk_material_type_x_material_1 FOREIGN KEY (material_uuid) REFERENCES material (material_uuid),
		ADD CONSTRAINT fk_material_type_x_material_type_1 FOREIGN KEY (material_type_uuid) REFERENCES material_type (material_type_uuid);

--ALTER TABLE material_refname DROP CONSTRAINT fk_alt_material_refname_material_1,
--	DROP CONSTRAINT fk_alt_material_refname_note_1;

ALTER TABLE material_refname
	ADD CONSTRAINT fk_material_refname_def_1 FOREIGN KEY (material_refname_def_uuid) REFERENCES material_refname_def (material_refname_def_uuid),
		ADD CONSTRAINT fk_material_refname_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

--ALTER TABLE material_refname_x DROP CONSTRAINT fk_material_refname_x_material_1,
--	DROP CONSTRAINT fk_material_refname_x_material_type_1;

ALTER TABLE material_refname_x
	ADD CONSTRAINT fk_material_refname_x_material_1 FOREIGN KEY (material_uuid) REFERENCES material (material_uuid),
		ADD CONSTRAINT fk_material_refname_x_material_refname_1 FOREIGN KEY (material_refname_uuid) REFERENCES material_refname (material_refname_uuid);

-- ALTER TABLE calculation_class DROP CONSTRAINT fk_calculation_class_note_1;
-- ALTER TABLE calculation_class
--	ADD CONSTRAINT fk_calculation_class_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);
-- ALTER TABLE calculation_def DROP CONSTRAINT fk_calculation_def_note_1,
-- DROP CONSTRAINT fk_calculation_def_actor_1,
-- DROP CONSTRAINT fk_calculation_def_calculation_class_1,
-- DROP CONSTRAINT fk_calculation_def_systemtool_1;

ALTER TABLE property 
 ADD CONSTRAINT fk_property_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_property_property_def_1 FOREIGN KEY (property_def_uuid) REFERENCES property_def (property_def_uuid),
		ADD CONSTRAINT fk_property_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE property_def 
 ADD CONSTRAINT fk_property_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_property_def_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid),
			ADD CONSTRAINT fk_property_def_valtype_1 FOREIGN KEY (valtype_uuid) REFERENCES type_def (type_def_uuid);

ALTER TABLE property_x 
 ADD CONSTRAINT fk_property_x_material_1 FOREIGN KEY (material_uuid) REFERENCES material (material_uuid),
	ADD CONSTRAINT fk_property_x_property_1 FOREIGN KEY (property_uuid) REFERENCES property (property_uuid);

ALTER TABLE parameter
 ADD CONSTRAINT fk_parameter_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_parameter_parameter_def_1 FOREIGN KEY (parameter_def_uuid) REFERENCES parameter_def (parameter_def_uuid),
		ADD CONSTRAINT fk_parameter_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE parameter_def 
 ADD CONSTRAINT fk_parameter_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_parameter_def_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid),
			ADD CONSTRAINT fk_parameter_def_valtype_1 FOREIGN KEY (valtype_uuid) REFERENCES type_def (type_def_uuid);

ALTER TABLE parameter_x 
	ADD CONSTRAINT fk_parameter_x_parameter_1 FOREIGN KEY (parameter_uuid) REFERENCES parameter (parameter_uuid);

ALTER TABLE calculation_def
	ADD CONSTRAINT fk_calculation_def_calculation_class_1 FOREIGN KEY (calculation_class_uuid) REFERENCES calculation_class (calculation_class_uuid),
		ADD CONSTRAINT fk_calculation_def_systemtool_1 FOREIGN KEY (systemtool_uuid) REFERENCES systemtool (systemtool_uuid),
			ADD CONSTRAINT fk_calculation_def_in_type_1 FOREIGN KEY (in_type_uuid) REFERENCES type_def (type_def_uuid),
				ADD CONSTRAINT fk_calculation_def_in_opt_type_1 FOREIGN KEY (in_opt_type_uuid) REFERENCES type_def (type_def_uuid),
					ADD CONSTRAINT fk_calculation_def_opt_type_1 FOREIGN KEY (out_type_uuid) REFERENCES type_def (type_def_uuid),				
						ADD CONSTRAINT fk_calculation_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);

ALTER TABLE calculation
--	ADD CONSTRAINT fk_calculation_material_refname_1 FOREIGN KEY (material_refname_description_in, material_refname_def_in) REFERENCES material_refname (description, material_refname_def),
	ADD CONSTRAINT fk_calculation_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),
		ADD CONSTRAINT fk_calculation_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_calculation_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE calculation_eval
	ADD CONSTRAINT fk_calculation_eval_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),
		ADD CONSTRAINT fk_calculation_eval_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);

-- ALTER TABLE inventory  DROP CONSTRAINT fk_inventory_material_1,
-- DROP CONSTRAINT fk_inventory_actor_1,
-- DROP CONSTRAINT fk_inventory_measure_1,
-- DROP CONSTRAINT fk_inventory_note_1;

ALTER TABLE inventory
	ADD CONSTRAINT fk_inventory_material_1 FOREIGN KEY (material_uuid) REFERENCES material (material_uuid),
		ADD CONSTRAINT fk_inventory_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_inventory_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE measure
	ADD CONSTRAINT fk_measure_measure_type_1 FOREIGN KEY (measure_type_uuid) REFERENCES measure_type (measure_type_uuid),
		ADD CONSTRAINT fk_measure_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);

-- ALTER TABLE measure_type DROP CONSTRAINT fk_measure_type_note_1;
-- ALTER TABLE measure_type
--	ADD CONSTRAINT fk_measure_type_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);
-- ALTER TABLE measure_x DROP CONSTRAINT fk_measure_x_measure_1;

ALTER TABLE measure_x
	ADD CONSTRAINT fk_measure_x_measure_1 FOREIGN KEY (measure_uuid) REFERENCES measure (measure_uuid);

-- ALTER TABLE note DROP CONSTRAINT fk_note_edocument_1;
ALTER TABLE note
	ADD CONSTRAINT fk_note_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);

ALTER TABLE note_x
	ADD CONSTRAINT fk_note_x_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE edocument_x ADD CONSTRAINT "pk_edocument_x_edocument_x_uuid" PRIMARY KEY (edocument_x_uuid), ADD CONSTRAINT "un_edocument_x" UNIQUE (ref_uuid, edocument_uuid);
ALTER TABLE edocument_x
	ADD CONSTRAINT fk_edocument_x_edocument_1 FOREIGN KEY (edocument_uuid) REFERENCES edocument (edocument_uuid);

--ALTER TABLE tag DROP CONSTRAINT fk_tag_tag_type_1,
--	DROP CONSTRAINT fk_tag_note_1;

ALTER TABLE tag
	ADD CONSTRAINT fk_tag_tag_type_1 FOREIGN KEY (tag_type_uuid) REFERENCES tag_type (tag_type_uuid),
		ADD CONSTRAINT fk_tag_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);

-- ALTER TABLE tag ADD CONSTRAINT "pk_tag_tag_uuid" PRIMARY KEY (tag_uuid);
ALTER TABLE tag_x
	ADD CONSTRAINT fk_tag_x_tag_1 FOREIGN KEY (tag_uuid) REFERENCES tag (tag_uuid);

ALTER TABLE udf
	ADD CONSTRAINT fk_udf_udf_def_1 FOREIGN KEY (udf_def_uuid) REFERENCES udf_def (udf_def_uuid);

ALTER TABLE udf_x
	ADD CONSTRAINT fk_udf_x_udf_1 FOREIGN KEY (udf_uuid) REFERENCES udf (udf_uuid);

ALTER TABLE workflow
	ADD CONSTRAINT fk_workflow_experiment_1 FOREIGN KEY (experiment_uuid) REFERENCES experiment (experiment_uuid),
		ADD CONSTRAINT fk_workflow_type_1 FOREIGN KEY (workflow_type_uuid) REFERENCES workflow_type (workflow_type_uuid),		
			ADD CONSTRAINT fk_workflow_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
				ADD CONSTRAINT fk_workflow_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE workflow_step
	ADD CONSTRAINT fk_workflow_step_workflow_1 FOREIGN KEY (workflow_uuid) REFERENCES workflow (workflow_uuid),
		ADD CONSTRAINT fk_workflow_step_workflow_action_1 FOREIGN KEY (action_uuid) REFERENCES action (action_uuid),
			ADD CONSTRAINT fk_workflow_step_action_condition_1 FOREIGN KEY (action_condition_uuid) REFERENCES action_condition (action_condition_uuid);

ALTER TABLE workflow_state_def
	ADD CONSTRAINT fk_workflow_state_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
		ADD CONSTRAINT fk_workflow_state_def_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE workflow_state
	ADD CONSTRAINT fk_workflow_state_workflow_step_1 FOREIGN KEY (workflow_step_uuid) REFERENCES workflow_step (workflow_step_uuid),
		ADD CONSTRAINT fk_workflow_state_workflow_state_def_1 FOREIGN KEY (workflow_state_def_uuid) REFERENCES workflow_state_def (workflow_state_def_uuid);;
	
ALTER TABLE action_def
	ADD CONSTRAINT fk_action_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
		ADD CONSTRAINT fk_action_def_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE action
	ADD CONSTRAINT fk_action_action_def_1 FOREIGN KEY (action_def_uuid) REFERENCES action_def (action_def_uuid),
		ADD CONSTRAINT fk_action_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),
			ADD CONSTRAINT fk_action_source_material_1 FOREIGN KEY (source_material_uuid) REFERENCES material (material_uuid),
				ADD CONSTRAINT fk_action_destination_material_1 FOREIGN KEY (destination_material_uuid) REFERENCES material (material_uuid),
					ADD CONSTRAINT fk_action_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
						ADD CONSTRAINT fk_action_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);			

ALTER TABLE action_condition
	ADD CONSTRAINT fk_action_condition_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),
		ADD CONSTRAINT fk_action_condition_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_action_condition_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


--=====================================
-- TABLE AND COLUMN COMMENTS
--=====================================

COMMENT ON TABLE organization IS 'organization information for ESCALATE person and system tool; can be component of actor';
COMMENT ON COLUMN organization.organization_uuid IS 'uuid for this organization record';
COMMENT ON COLUMN organization.parent_uuid IS 'reference to parent organization; uses [internal] organization_uuid';
COMMENT ON COLUMN organization.parent_path IS 'allows a searchable, naviagatable tree structure; currently not being used';
COMMENT ON COLUMN organization.description IS 'free test describing the organization';
COMMENT ON COLUMN organization.full_name IS 'long (full) version of the org name';
COMMENT ON COLUMN organization.short_name IS 'short version of the org name; using acronym, initialism, etc';
COMMENT ON COLUMN organization.address1 IS 'first line of organization address';
COMMENT ON COLUMN organization.address2 IS 'second line of organization address';
COMMENT ON COLUMN organization.city IS 'city of the organization';
COMMENT ON COLUMN organization.state_province IS 'state or province (abbreviation)';
COMMENT ON COLUMN organization.zip IS 'zip or province code';
COMMENT ON COLUMN organization.country IS 'country code';
COMMENT ON COLUMN organization.website_url IS 'organization url';
COMMENT ON COLUMN organization.phone IS 'primary organization phone';
COMMENT ON COLUMN organization.add_date IS 'date this record added';
COMMENT ON COLUMN organization.mod_date IS 'date this record updated';