--======================================================================
/*
Name:			prod_tables
Parameters:		none
Returns:
Author:			G. Cattabriga
Date:			2020.01.23
Description:	create the production tables, primary keys and comments for ESCALATE v3
Notes:			triggers, foreign keys and other constraints are in other sql files
 				20200123: remove the measure and measure type entities - measure will be part
 				of the originating entity
 				20200130: add measure, measure_type back in, and also add the xref table
				 measure_x
 */
--======================================================================

-- DROP SCHEMA dev cascade;
-- CREATE SCHEMA dev;
--======================================================================
--======================================================================
 -- EXTENSIONS
--======================================================================
--======================================================================
-- CREATE EXTENSION if not exists ltree with schema dev;
-- CREATE EXTENSION if not exists tablefunc with schema dev;
-- CREATE EXTENSION if not exists "uuid-ossp" with schema dev;
-- CREATE EXTENSION IF NOT EXISTS hstore with schema dev;
-- set search_path = dev, public;

DROP EXTENSION IF EXISTS pgtap CASCADE;

--======================================================================
--======================================================================
 -- DROP TYPES
--======================================================================
--======================================================================
DROP TYPE IF EXISTS val cascade;
DROP TYPE IF EXISTS type_def_category cascade;


--======================================================================
--======================================================================
 -- DROP FUNCTIONS
--======================================================================
--======================================================================
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



--======================================================================
--======================================================================
 -- DROP VIEWS
--======================================================================
--======================================================================
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



--======================================================================
--======================================================================
 -- DROP TABLES
--======================================================================
--======================================================================
DROP TABLE IF EXISTS action cascade;
DROP TABLE IF EXISTS action_def cascade;
DROP TABLE IF EXISTS action_parameter_def_x cascade;
DROP TABLE IF EXISTS actor cascade;
DROP TABLE IF EXISTS actor_pref cascade;
DROP TABLE IF EXISTS bom cascade; 
DROP TABLE IF EXISTS bom_material cascade;
DROP TABLE IF EXISTS calculation cascade;
DROP TABLE IF EXISTS calculation_class cascade;
DROP TABLE IF EXISTS calculation_def cascade;
DROP TABLE IF EXISTS calculation_eval cascade;
DROP TABLE IF EXISTS calculation_stack cascade;
DROP TABLE IF EXISTS condition cascade;
DROP TABLE IF EXISTS condition_calculation_def_x cascade;
DROP TABLE IF EXISTS condition_def cascade;
DROP TABLE IF EXISTS condition_path cascade;
DROP TABLE IF EXISTS edocument cascade;
DROP TABLE IF EXISTS edocument_x cascade;
DROP TABLE IF EXISTS experiment cascade;
DROP TABLE IF EXISTS experiment_workflow cascade;
DROP TABLE IF EXISTS inventory cascade;
DROP TABLE IF EXISTS material cascade;
DROP TABLE IF EXISTS material_composite cascade;
DROP TABLE IF EXISTS material_refname cascade;
DROP TABLE IF EXISTS material_refname_def cascade;
DROP TABLE IF EXISTS material_refname_x cascade;
DROP TABLE IF EXISTS material_type cascade;
DROP TABLE IF EXISTS material_type_x cascade;
DROP TABLE IF EXISTS material_x cascade;
DROP TABLE IF EXISTS measure cascade;
DROP TABLE IF EXISTS measure_type cascade;
DROP TABLE IF EXISTS measure_x cascade;
DROP TABLE IF EXISTS note cascade;
DROP TABLE IF EXISTS note_x cascade;
DROP TABLE IF EXISTS organization cascade;
DROP TABLE IF EXISTS outcome cascade;
DROP TABLE IF EXISTS outcome_type cascade;
DROP TABLE IF EXISTS outcome_x cascade;
DROP TABLE IF EXISTS parameter cascade;
DROP TABLE IF EXISTS parameter_def cascade;
DROP TABLE IF EXISTS parameter_x cascade;
DROP TABLE IF EXISTS person cascade;
DROP TABLE IF EXISTS property cascade;
DROP TABLE IF EXISTS property_def cascade;
DROP TABLE IF EXISTS property_x cascade;
DROP TABLE IF EXISTS status cascade;
DROP TABLE IF EXISTS systemtool cascade;
DROP TABLE IF EXISTS systemtool_type cascade;
DROP TABLE IF EXISTS sys_audit cascade;
DROP TABLE IF EXISTS tag cascade;
DROP TABLE IF EXISTS tag_type cascade;
DROP TABLE IF EXISTS tag_x cascade;
DROP TABLE IF EXISTS type_def cascade;
DROP TABLE IF EXISTS udf cascade;
DROP TABLE IF EXISTS udf_x cascade;
DROP TABLE IF EXISTS udf_def cascade;
DROP TABLE IF EXISTS workflow cascade;
DROP TABLE IF EXISTS workflow_action_set cascade;
DROP TABLE IF EXISTS workflow_object cascade;
DROP TABLE IF EXISTS workflow_step cascade;
DROP TABLE IF EXISTS workflow_state cascade;
DROP TABLE IF EXISTS workflow_type cascade;
-- DROP TABLE IF EXISTS escalate_change_log cascade;
-- DROP TABLE IF EXISTS escalate_version cascade;

--======================================================================
--======================================================================
-- CREATE DATA TYPES
--======================================================================
--======================================================================
-- define (enumerate) the value types where hierarchy is separated by '_' with simple data types (int, num, text) as single phrase; treat 'array' like a fifo stack
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

--======================================================================
--======================================================================
-- CREATE TABLES
--======================================================================
--======================================================================
CREATE TABLE action (
	action_uuid uuid DEFAULT uuid_generate_v4 (),
	action_def_uuid uuid,
	workflow_uuid uuid,
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


CREATE TABLE action_def (
	action_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	status_uuid uuid,
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE action_parameter_def_x (
    action_parameter_def_x_uuid uuid DEFAULT uuid_generate_v4 (),
 	parameter_def_uuid uuid NOT NULL,
 	action_def_uuid uuid NOT NULL,
 	add_date timestamptz NOT NULL DEFAULT NOW(),
 	mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


CREATE TABLE actor_pref (
	actor_pref_uuid uuid DEFAULT uuid_generate_v4 (),
	actor_uuid uuid,
	pkey varchar COLLATE "pg_catalog"."default" NOT NULL,
	pvalue varchar COLLATE "pg_catalog"."default",
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE bom (
	bom_uuid uuid DEFAULT uuid_generate_v4 (),
	experiment_uuid uuid NOT NULL,
	description varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid, 
	status_uuid uuid, 
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE bom_material (
	bom_material_uuid uuid DEFAULT uuid_generate_v4 (),
	bom_uuid uuid NOT NULL,
	description varchar COLLATE "pg_catalog"."default",
	inventory_uuid uuid NOT NULL,
	material_composite_uuid uuid,
	alloc_amt_val val,
	used_amt_val val,
	putback_amt_val val,
	actor_uuid uuid, 
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


CREATE TABLE calculation_class (
	calculation_class_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" not null,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


CREATE TABLE calculation_stack (
	calculation_stack_id  serial primary key,
	stack_val val,
	add_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE condition (
	condition_uuid uuid DEFAULT uuid_generate_v4 (),
	condition_calculation_def_x_uuid uuid,
	in_val val[],
	out_val val[],
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE condition_def (
	condition_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE condition_calculation_def_x (
    condition_calculation_def_x_uuid uuid DEFAULT uuid_generate_v4 (),
  	condition_def_uuid uuid NOT NULL,
 	calculation_def_uuid uuid NOT NULL,
 	add_date timestamptz NOT NULL DEFAULT NOW(),
 	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE condition_path (
	condition_path_uuid uuid DEFAULT uuid_generate_v4 (),
	condition_uuid uuid,
	condition_out_val val,
	workflow_step_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


CREATE TABLE edocument_x (
	edocument_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_edocument_uuid uuid NOT NULL,
	edocument_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


CREATE TABLE experiment_workflow (
	experiment_workflow_uuid uuid DEFAULT uuid_generate_v4 (),
	experiment_workflow_seq int2,
	experiment_uuid uuid,
	workflow_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE inventory (
	inventory_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar,
	material_uuid uuid NOT NULL,
	part_no varchar,
	onhand_amt val,
	expiration_date timestamptz DEFAULT NULL,
	location varchar(255) COLLATE "pg_catalog"."default",
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE material (
	material_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	consumable BOOLEAN NOT NULL DEFAULT TRUE,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE material_composite (
	material_composite_uuid uuid DEFAULT uuid_generate_v4 (),
	composite_uuid uuid NOT NULL,
	component_uuid uuid NOT NULL,
	addressable BOOLEAN NOT NULL DEFAULT FALSE,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE material_x (
	material_x_uuid uuid DEFAULT uuid_generate_v4 (),
	material_uuid uuid NOT NULL,
	ref_material_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE material_refname (
	material_refname_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	blob_value bytea,
	blob_type varchar,
	material_refname_def_uuid uuid,
	reference varchar COLLATE "pg_catalog"."default",
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE material_refname_def (
	material_refname_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE material_refname_x (
	material_refname_x_uuid uuid DEFAULT uuid_generate_v4 (),
	material_uuid uuid NOT NULL,
	material_refname_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE material_type (
	material_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE material_type_x (
	material_type_x_uuid uuid DEFAULT uuid_generate_v4 (),
	material_uuid uuid NOT NULL,
	material_type_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE measure (
	measure_uuid uuid DEFAULT uuid_generate_v4 (),
	measure_type_uuid uuid,
	description varchar COLLATE "pg_catalog"."default",
	amount val,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE measure_type (
	measure_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
	status_uuid uuid,	
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE measure_x (
	measure_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_measure_uuid uuid NOT NULL,
	measure_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE note (
	note_uuid uuid DEFAULT uuid_generate_v4 (),
	notetext varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE note_x (
	note_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_note_uuid uuid NOT NULL,
	note_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


CREATE TABLE outcome (
	outcome_uuid uuid DEFAULT uuid_generate_v4 (),
	outcome_ref_uuid uuid,
	actor_uuid uuid,
	outcome_type_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE outcome_type (
	outcome_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE outcome_x (
	outcome_x_uuid uuid DEFAULT uuid_generate_v4 (),
	outcome_ref_uuid uuid,
	outcome_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE parameter (
	parameter_uuid uuid DEFAULT uuid_generate_v4 (),
	parameter_def_uuid uuid NOT NULL,
	parameter_val val NOT NULL,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE parameter_def (
	parameter_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	default_val val,           -- parameter type and units are stored here
	required boolean NOT NULL, -- default set in upsert
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE parameter_x (
	parameter_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_parameter_uuid uuid NOT NULL,
	parameter_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


CREATE TABLE property (
	property_uuid uuid DEFAULT uuid_generate_v4 (),
	property_def_uuid uuid NOT NULL,
	property_val val NOT NULL,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE property_def (
	property_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	short_description varchar COLLATE "pg_catalog"."default" NOT NULL,
	val_type_uuid uuid,
	valunit varchar,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE property_x (
	property_x_uuid uuid DEFAULT uuid_generate_v4 (),
	material_uuid uuid NOT NULL,
	property_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE status (
	status_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


CREATE TABLE systemtool_type (
  systemtool_type_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


CREATE TABLE tag (
	tag_uuid uuid DEFAULT uuid_generate_v4 (),
	tag_type_uuid uuid,
	display_text varchar(16) COLLATE "pg_catalog"."default" NOT NULL,
	description varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE tag_type (
	tag_type_uuid uuid DEFAULT uuid_generate_v4 (),
	type varchar(32) COLLATE "pg_catalog"."default",
	description varchar COLLATE "pg_catalog"."default",
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE tag_x (
	tag_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_tag_uuid uuid NOT NULL,
	tag_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE type_def (
	type_def_uuid uuid DEFAULT uuid_generate_v4 (),
	category type_def_category NOT NULL,
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE udf (
	udf_uuid uuid DEFAULT uuid_generate_v4 (),
	udf_def_uuid uuid NOT NULL,
	udf_val val NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE udf_def (
	udf_def_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	val_type_uuid uuid NOT NULL,
	unit varchar,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE udf_x (
	udf_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_udf_uuid uuid NOT NULL,
	udf_uuid uuid NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE workflow (
	workflow_uuid uuid DEFAULT uuid_generate_v4 (),
	workflow_type_uuid uuid,
	description varchar COLLATE "pg_catalog"."default",
	parent_uuid uuid,
	parent_path ltree,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE workflow_action_set (
	workflow_action_set_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	workflow_uuid uuid,
	action_def_uuid uuid,
	start_date timestamptz,
	end_date timestamptz,
	duration numeric,
	repeating int8,
	parameter_def_uuid uuid,
	parameter_val val[],	
	calculation_uuid uuid,
	source_material_uuid uuid[],
	destination_material_uuid uuid[], 
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE workflow_object (
	workflow_object_uuid uuid DEFAULT uuid_generate_v4 (),
	workflow_uuid uuid,
	action_uuid uuid,
	condition_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE workflow_state (
	workflow_state_uuid uuid DEFAULT uuid_generate_v4 (),
	workflow_step_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE workflow_step (
	workflow_step_uuid uuid DEFAULT uuid_generate_v4 (),
	workflow_uuid uuid,
	parent_uuid uuid,
	parent_path ltree,
	workflow_object_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE workflow_type (
	workflow_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


/*
-- ----------------------------
-- Table for [internal] escalate use only
-- ----------------------------
-- CREATE TABLE escalate_change_log (
 change_log_uuid uuid DEFAULT uuid_generate_v4 (),
 issue varchar COLLATE "pg_catalog"."default",
 object_type varchar COLLATE "pg_catalog"."default",
 object_name varchar COLLATE "pg_catalog"."default",
 resolution varchar COLLATE "pg_catalog"."default",
 author varchar COLLATE "pg_catalog"."default",
 status varchar COLLATE "pg_catalog"."default",
 create_date timestamptz NOT NULL DEFAULT NOW(),
 close_date timestamptz NOT NULL DEFAULT NOW()
-- );

-- CREATE TABLE escalate_version (
 ver_uuid uuid DEFAULT uuid_generate_v4 (),
 short_name varchar COLLATE "pg_catalog"."default",
 description varchar COLLATE "pg_catalog"."default",
 add_date timestamptz NOT NULL DEFAULT NOW()
-- );
 */

--======================================================================
--======================================================================
-- PRIMARY KEYS and CONSTRAINTS
--======================================================================
--======================================================================
CREATE INDEX "ix_sys_audit_relid" ON sys_audit (relid);
CREATE INDEX "ix_sys_audit_action_tstamp_tx_stm" ON sys_audit (action_tstamp_stm);
CREATE INDEX "ix_sys_audit_action" ON sys_audit (action);

ALTER TABLE action
	ADD CONSTRAINT "pk_action_action_uuid" PRIMARY KEY (action_uuid);
CLUSTER action
USING "pk_action_action_uuid";


ALTER TABLE action_def
	ADD CONSTRAINT "pk_action_def_action_def_uuid" PRIMARY KEY (action_def_uuid),
		ADD CONSTRAINT "un_action_def" UNIQUE (description);
CLUSTER action_def
USING "pk_action_def_action_def_uuid";


 ALTER TABLE action_parameter_def_x
 	ADD CONSTRAINT "pk_action_parameter_def_x_action_parameter_def_x_uuid" PRIMARY KEY (action_parameter_def_x_uuid),
 		ADD CONSTRAINT "un_action_parameter_def_x_def" UNIQUE (parameter_def_uuid, action_def_uuid);
 CLUSTER action_parameter_def_x
 USING "pk_action_parameter_def_x_action_parameter_def_x_uuid";


ALTER TABLE actor
    ADD CONSTRAINT "pk_actor_uuid" PRIMARY KEY (actor_uuid);
CREATE UNIQUE INDEX "un_actor" ON actor (COALESCE(person_uuid, NULL), COALESCE(organization_uuid, NULL),
                                         COALESCE(systemtool_uuid, NULL));
CLUSTER actor
    USING "pk_actor_uuid";


ALTER TABLE actor_pref
	ADD CONSTRAINT "pk_actor_pref_uuid" PRIMARY KEY (actor_pref_uuid);
CLUSTER actor_pref
USING "pk_actor_pref_uuid";


ALTER TABLE bom
	ADD CONSTRAINT "pk_bom_bom_uuid" PRIMARY KEY (bom_uuid);
CREATE INDEX "ix_bom_experiment_uuid" ON bom (experiment_uuid);
CLUSTER bom
USING "pk_bom_bom_uuid";


ALTER TABLE bom_material
	ADD CONSTRAINT "pk_bom_material_bom_material_uuid" PRIMARY KEY (bom_material_uuid);
CREATE INDEX "ix_bom_material_bom_uuid" ON bom_material (bom_uuid);
CLUSTER bom_material
USING "pk_bom_material_bom_material_uuid";


ALTER TABLE calculation
	ADD CONSTRAINT "pk_calculation_calculation_uuid" PRIMARY KEY (calculation_uuid),
		ADD CONSTRAINT "un_calculation" UNIQUE (calculation_def_uuid, in_val, in_opt_val);
CLUSTER calculation
USING "pk_calculation_calculation_uuid";


ALTER TABLE calculation_class
	ADD CONSTRAINT "pk_calculation_class_calculation_class_uuid" PRIMARY KEY (calculation_class_uuid);
CLUSTER calculation_class
USING "pk_calculation_class_calculation_class_uuid";


ALTER TABLE calculation_def
	ADD CONSTRAINT "pk_calculation_calculation_def_uuid" PRIMARY KEY (calculation_def_uuid),
		ADD CONSTRAINT "un_calculation_def" UNIQUE (actor_uuid, short_name, calc_definition);
CLUSTER calculation_def
USING "pk_calculation_calculation_def_uuid";


ALTER TABLE calculation_eval
	ADD CONSTRAINT "pk_calculation_eval_calculation_eval_id" PRIMARY KEY (calculation_eval_id),
		ADD CONSTRAINT "un_calculation_eval" UNIQUE (calculation_def_uuid, in_val, in_opt_val);
CLUSTER calculation_eval
USING "pk_calculation_eval_calculation_eval_id";


ALTER TABLE condition
	ADD CONSTRAINT "pk_condition_condition_uuid" PRIMARY KEY (condition_uuid);
CLUSTER condition
USING "pk_condition_condition_uuid";


ALTER TABLE condition_def
	ADD CONSTRAINT "pk_condition_def_condition_def_uuid" PRIMARY KEY (condition_def_uuid),
		ADD CONSTRAINT "un_condition_def" UNIQUE (description);
CLUSTER condition_def
USING "pk_condition_def_condition_def_uuid";


ALTER TABLE condition_calculation_def_x
 	ADD CONSTRAINT "pk_condition_calculation_def_x_condition_calculation_def_x_uuid" PRIMARY KEY (condition_calculation_def_x_uuid),
 		ADD CONSTRAINT "un_condition_calculation_def_x" UNIQUE (condition_def_uuid, calculation_def_uuid);
CLUSTER condition_calculation_def_x
USING "pk_condition_calculation_def_x_condition_calculation_def_x_uuid";


ALTER TABLE condition_path
	ADD CONSTRAINT "pk_condition_path_condition_path_uuid" PRIMARY KEY (condition_path_uuid),
	 	ADD CONSTRAINT "un_condition_path" UNIQUE (condition_out_val, workflow_step_uuid);
CLUSTER condition_path
USING "pk_condition_path_condition_path_uuid";


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


ALTER TABLE inventory
	ADD CONSTRAINT "pk_inventory_inventory_uuid" PRIMARY KEY (inventory_uuid),
		ADD CONSTRAINT "un_inventory" UNIQUE (material_uuid, actor_uuid, add_date);
CLUSTER inventory
USING "pk_inventory_inventory_uuid";


ALTER TABLE material
	ADD CONSTRAINT "pk_material_material_uuid" PRIMARY KEY (material_uuid),
		ADD CONSTRAINT "un_material" UNIQUE (description);
CLUSTER material
USING "pk_material_material_uuid";


ALTER TABLE material_composite
	ADD CONSTRAINT "pk_material_composite_material_composite_uuid" PRIMARY KEY (material_composite_uuid),
		ADD CONSTRAINT "un_material_composite" CHECK (composite_uuid <> component_uuid);
CLUSTER material_composite
USING "pk_material_composite_material_composite_uuid";


ALTER TABLE material_refname
	ADD CONSTRAINT "pk_material_refname_material_refname_uuid" PRIMARY KEY (material_refname_uuid),
		ADD CONSTRAINT "un_material_refname" UNIQUE (description, material_refname_def_uuid);
CLUSTER material_refname
USING "pk_material_refname_material_refname_uuid";


ALTER TABLE material_refname_def
	ADD CONSTRAINT "pk_material_refname_def_material_refname_def_uuid" PRIMARY KEY (material_refname_def_uuid);
CLUSTER material_refname_def
USING "pk_material_refname_def_material_refname_def_uuid";


ALTER TABLE material_refname_x
	ADD CONSTRAINT "pk_material_refname_x_material_refname_x_uuid" PRIMARY KEY (material_refname_x_uuid),
		ADD CONSTRAINT "un_material_refname_x" UNIQUE (material_uuid, material_refname_uuid);
CLUSTER material_refname_x
USING "pk_material_refname_x_material_refname_x_uuid";


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


ALTER TABLE material_x
	ADD CONSTRAINT "pk_material_x_material_x_uuid" PRIMARY KEY (material_x_uuid),
		ADD CONSTRAINT "un_material_x" UNIQUE (material_uuid, ref_material_uuid);
CLUSTER material_x
USING "pk_material_x_material_x_uuid";


ALTER TABLE measure
	ADD CONSTRAINT "pk_measure_measure_uuid" PRIMARY KEY (measure_uuid),
		ADD CONSTRAINT "un_measure" UNIQUE (measure_uuid);
CLUSTER measure
USING "pk_measure_measure_uuid";


ALTER TABLE measure_type
	ADD CONSTRAINT "pk_measure_type_measure_type_uuid" PRIMARY KEY (measure_type_uuid);
CLUSTER measure_type
USING "pk_measure_type_measure_type_uuid";


ALTER TABLE measure_x
	ADD CONSTRAINT "pk_measure_x_measure_x_uuid" PRIMARY KEY (measure_x_uuid),
		ADD CONSTRAINT "un_measure_x" UNIQUE (ref_measure_uuid, measure_uuid);
CLUSTER measure_x
USING "pk_measure_x_measure_x_uuid";


ALTER TABLE note
	ADD CONSTRAINT "pk_note_note_uuid" PRIMARY KEY (note_uuid);
CLUSTER note
USING "pk_note_note_uuid";


ALTER TABLE note_x
	ADD CONSTRAINT "pk_note_x_note_x_uuid" PRIMARY KEY (note_x_uuid),
		ADD CONSTRAINT "un_note_x" UNIQUE (ref_note_uuid, note_uuid);
CLUSTER note_x
USING "pk_note_x_note_x_uuid";


ALTER TABLE organization
	ADD CONSTRAINT "pk_organization_organization_uuid" PRIMARY KEY (organization_uuid),
		ADD CONSTRAINT "un_organization" UNIQUE (full_name);
CREATE INDEX "ix_organization_parent_path" ON organization
USING GIST (parent_path);
CREATE INDEX "ix_organization_parent_uuid" ON organization (parent_uuid);
CLUSTER organization
USING "pk_organization_organization_uuid";


ALTER TABLE parameter
	ADD CONSTRAINT "pk_parameter_parameter_uuid" PRIMARY KEY (parameter_uuid);
CLUSTER parameter
USING "pk_parameter_parameter_uuid";


ALTER TABLE parameter_def
	ADD CONSTRAINT "pk_parameter_def_parameter_def_uuid" PRIMARY KEY (parameter_def_uuid),
		ADD CONSTRAINT "un_parameter_def" UNIQUE (description);
CLUSTER parameter_def
USING "pk_parameter_def_parameter_def_uuid";


ALTER TABLE parameter_x
	ADD CONSTRAINT "pk_parameter_x_parameter_x_uuid" PRIMARY KEY (parameter_x_uuid),
		ADD CONSTRAINT "un_parameter_x_def" UNIQUE (ref_parameter_uuid, parameter_uuid);
CLUSTER parameter_x
USING "pk_parameter_x_parameter_x_uuid";


ALTER TABLE person
    ADD CONSTRAINT "pk_person_person_uuid" PRIMARY KEY (person_uuid);
CREATE UNIQUE INDEX "un_person" ON person (COALESCE(last_name, NULL), COALESCE(first_name, NULL),
                                           COALESCE(middle_name, NULL));
CLUSTER person
    USING "pk_person_person_uuid";


ALTER TABLE property
	ADD CONSTRAINT "pk_property_property_uuid" PRIMARY KEY (property_uuid);
CLUSTER property
USING "pk_property_property_uuid";


ALTER TABLE property_def
	ADD CONSTRAINT "pk_property_def_property_def_uuid" PRIMARY KEY (property_def_uuid),
		ADD CONSTRAINT "un_property_def" UNIQUE (short_description);
CLUSTER property_def
USING "pk_property_def_property_def_uuid";


ALTER TABLE property_x
	ADD CONSTRAINT "pk_property_x_property_x_uuid" PRIMARY KEY (property_x_uuid),
		ADD CONSTRAINT "un_property_x_def" UNIQUE (material_uuid, property_uuid);
CLUSTER property_x
USING "pk_property_x_property_x_uuid";


ALTER TABLE status
	ADD CONSTRAINT "pk_status_status_uuid" PRIMARY KEY (status_uuid),
			ADD CONSTRAINT "un_status" UNIQUE (description);
CLUSTER status
USING "pk_status_status_uuid";


ALTER TABLE systemtool
	ADD CONSTRAINT "pk_systemtool_systemtool_uuid" PRIMARY KEY (systemtool_uuid),
		ADD CONSTRAINT "un_systemtool" UNIQUE (systemtool_name, systemtool_type_uuid, vendor_organization_uuid, ver);
CLUSTER systemtool
USING "pk_systemtool_systemtool_uuid";


ALTER TABLE systemtool_type
	ADD CONSTRAINT "pk_systemtool_systemtool_type_uuid" PRIMARY KEY (systemtool_type_uuid);
CLUSTER systemtool_type
USING "pk_systemtool_systemtool_type_uuid";


ALTER TABLE tag
	ADD CONSTRAINT "pk_tag_tag_uuid" PRIMARY KEY (tag_uuid),
		ADD CONSTRAINT "un_tag" UNIQUE (display_text, tag_type_uuid);
CLUSTER tag
USING "pk_tag_tag_uuid";


ALTER TABLE tag_type
	ADD CONSTRAINT "pk_tag_tag_type_uuid" PRIMARY KEY (tag_type_uuid),
		ADD CONSTRAINT "un_tag_type" UNIQUE (type);
CLUSTER tag_type
USING "pk_tag_tag_type_uuid";


ALTER TABLE tag_x
	ADD CONSTRAINT "pk_tag_x_tag_x_uuid" PRIMARY KEY (tag_x_uuid),
		ADD CONSTRAINT "un_tag_x" UNIQUE (ref_tag_uuid, tag_uuid);
CLUSTER tag_x
USING "pk_tag_x_tag_x_uuid";


ALTER TABLE type_def
	ADD CONSTRAINT "pk_type_def_type_def_uuid" PRIMARY KEY (type_def_uuid),
		ADD CONSTRAINT "un_type_def" UNIQUE (category, description);
CLUSTER type_def
USING "pk_type_def_type_def_uuid";


ALTER TABLE udf
	ADD CONSTRAINT "pk_udf_udf_uuid" PRIMARY KEY (udf_uuid);
CLUSTER udf
USING "pk_udf_udf_uuid";


ALTER TABLE udf_def
	ADD CONSTRAINT "pk_udf_def_udf_def_uuid" PRIMARY KEY (udf_def_uuid),
		ADD CONSTRAINT "un_udf_def" UNIQUE (description);
CLUSTER udf_def
USING "pk_udf_def_udf_def_uuid";


ALTER TABLE udf_x
	ADD CONSTRAINT "pk_udf_x_udf_x_uuid" PRIMARY KEY (udf_x_uuid),
		ADD CONSTRAINT "un_udf_x" UNIQUE (ref_udf_uuid, udf_uuid);
CLUSTER udf_x
USING "pk_udf_x_udf_x_uuid";


ALTER TABLE workflow
	ADD CONSTRAINT "pk_workflow_workflow_uuid" PRIMARY KEY (workflow_uuid);
CREATE INDEX "ix_workflow_parent_uuid" ON workflow
USING GIST (parent_path);
CLUSTER workflow
USING "pk_workflow_workflow_uuid";


ALTER TABLE workflow_action_set
	ADD CONSTRAINT "pk_workflow_action_set_workflow_action_set_uuid" PRIMARY KEY (workflow_action_set_uuid);
CLUSTER workflow_action_set
USING "pk_workflow_action_set_workflow_action_set_uuid";


ALTER TABLE workflow_object
	ADD CONSTRAINT "pk_workflow_object_workflow_object_uuid" PRIMARY KEY (workflow_object_uuid),
		ADD CONSTRAINT "un_workflow_object" UNIQUE (action_uuid, condition_uuid);
CREATE INDEX "ix_workflow_object_uuid" ON workflow (workflow_uuid);
CLUSTER workflow_object
USING "pk_workflow_object_workflow_object_uuid";


ALTER TABLE workflow_state
	ADD CONSTRAINT "pk_workflow_state_workflow_state_uuid" PRIMARY KEY (workflow_state_uuid);
CLUSTER workflow_state
USING "pk_workflow_state_workflow_state_uuid";


ALTER TABLE workflow_step
	ADD CONSTRAINT "pk_workflow_step_workflow_step_uuid" PRIMARY KEY (workflow_step_uuid),
		ADD CONSTRAINT "un_workflow_step_workflow_step_uuid" UNIQUE (workflow_object_uuid, parent_uuid);
CREATE INDEX "ix_workflow_step_parent_uuid" ON workflow_step
USING GIST (parent_path);
CLUSTER workflow_step
USING "pk_workflow_step_workflow_step_uuid";


ALTER TABLE workflow_type
	ADD CONSTRAINT "pk_workflow_type_workflow_type_uuid" PRIMARY KEY (workflow_type_uuid),
		ADD CONSTRAINT "un_workflow_type" UNIQUE (description);
CLUSTER workflow_type
USING "pk_workflow_type_workflow_type_uuid";


/*
ALTER TABLE escalate_change_log
 ADD CONSTRAINT "pk_escalate_change_log_uuid" PRIMARY KEY (change_log_uuid);
CLUSTER escalate_change_log USING "pk_escalate_change_log_uuid";

ALTER TABLE escalate_version
 ADD CONSTRAINT "pk_escalate_version_uuid" PRIMARY KEY (ver_uuid),
 ADD CONSTRAINT "un_escalate_version" UNIQUE (ver_uuid, short_name);
CLUSTER escalate_version USING "pk_escalate_version_uuid";
 */


--======================================================================
--======================================================================
-- FOREIGN KEYS
--======================================================================
--======================================================================
ALTER TABLE action_def
	ADD CONSTRAINT fk_action_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
		ADD CONSTRAINT fk_action_def_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE action_parameter_def_x
 	ADD CONSTRAINT fk_action_parameter_def_x_action_def_1 FOREIGN KEY (action_def_uuid) REFERENCES action_def (action_def_uuid),
         ADD CONSTRAINT fk_action_parameter_def_x_parameter_def_1 FOREIGN KEY (parameter_def_uuid) REFERENCES parameter_def (parameter_def_uuid);


ALTER TABLE action
	ADD CONSTRAINT fk_action_action_def_1 FOREIGN KEY (action_def_uuid) REFERENCES action_def (action_def_uuid),
		ADD CONSTRAINT fk_action_workflow_1 FOREIGN KEY (workflow_uuid) REFERENCES workflow (workflow_uuid),
			ADD CONSTRAINT fk_action_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),
				ADD CONSTRAINT fk_action_source_material_1 FOREIGN KEY (source_material_uuid) REFERENCES bom_material (bom_material_uuid),
					ADD CONSTRAINT fk_action_destination_material_1 FOREIGN KEY (destination_material_uuid) REFERENCES bom_material (bom_material_uuid),
						ADD CONSTRAINT fk_action_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
							ADD CONSTRAINT fk_action_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE actor
	ADD CONSTRAINT fk_actor_person_1 FOREIGN KEY (person_uuid) REFERENCES person (person_uuid),
		ADD CONSTRAINT fk_actor_organization_1 FOREIGN KEY (organization_uuid) REFERENCES organization (organization_uuid),
			ADD CONSTRAINT fk_actor_systemtool_1 FOREIGN KEY (systemtool_uuid) REFERENCES systemtool (systemtool_uuid),
				ADD CONSTRAINT fk_actor_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE actor_pref
	ADD CONSTRAINT fk_actor_pref_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);


ALTER TABLE bom
	ADD CONSTRAINT fk_bom_experiment_1 FOREIGN KEY (experiment_uuid) REFERENCES experiment (experiment_uuid),
		ADD CONSTRAINT fk_bom_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_bom_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE bom_material
	ADD CONSTRAINT fk_bom_material_bom_1 FOREIGN KEY (bom_uuid) REFERENCES bom (bom_uuid),
		ADD CONSTRAINT fk_bom_material_inventory_1 FOREIGN KEY (inventory_uuid) REFERENCES inventory (inventory_uuid),
			ADD CONSTRAINT fk_bom_material_material_composite_1 FOREIGN KEY (material_composite_uuid) REFERENCES material_composite (material_composite_uuid),					
				ADD CONSTRAINT fk_bom_material_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
					ADD CONSTRAINT fk_bom_material_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE calculation
--	ADD CONSTRAINT fk_calculation_material_refname_1 FOREIGN KEY (material_refname_description_in, material_refname_def_in) REFERENCES material_refname (description, material_refname_def),
	ADD CONSTRAINT fk_calculation_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),
		ADD CONSTRAINT fk_calculation_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_calculation_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE calculation_def
	ADD CONSTRAINT fk_calculation_def_calculation_class_1 FOREIGN KEY (calculation_class_uuid) REFERENCES calculation_class (calculation_class_uuid),
		ADD CONSTRAINT fk_calculation_def_systemtool_1 FOREIGN KEY (systemtool_uuid) REFERENCES systemtool (systemtool_uuid),
			ADD CONSTRAINT fk_calculation_def_in_type_1 FOREIGN KEY (in_type_uuid) REFERENCES type_def (type_def_uuid),
				ADD CONSTRAINT fk_calculation_def_in_opt_type_1 FOREIGN KEY (in_opt_type_uuid) REFERENCES type_def (type_def_uuid),
					ADD CONSTRAINT fk_calculation_def_opt_type_1 FOREIGN KEY (out_type_uuid) REFERENCES type_def (type_def_uuid),
						ADD CONSTRAINT fk_calculation_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);


ALTER TABLE calculation_eval
	ADD CONSTRAINT fk_calculation_eval_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),
		ADD CONSTRAINT fk_calculation_eval_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);


ALTER TABLE condition
	ADD CONSTRAINT fk_condition_condition_calculation_def_x_1 FOREIGN KEY (condition_calculation_def_x_uuid) REFERENCES condition_calculation_def_x (condition_calculation_def_x_uuid),
		ADD CONSTRAINT fk_condition_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_condition_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE condition_def
	ADD CONSTRAINT fk_condition_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
		ADD CONSTRAINT fk_condition_def_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE condition_calculation_def_x
	ADD CONSTRAINT fk_condition_calculation_def_x_condition_def_1 FOREIGN KEY (condition_def_uuid) REFERENCES condition_def (condition_def_uuid),
		ADD CONSTRAINT fk_condition_calculation_def_x_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid);


ALTER TABLE condition_path
	ADD CONSTRAINT fk_condition_path_condition_uuid_1 FOREIGN KEY (condition_uuid) REFERENCES condition (condition_uuid),
		ADD CONSTRAINT fk_condition_workflow_step_uuid_1 FOREIGN KEY (workflow_step_uuid) REFERENCES workflow_step (workflow_step_uuid);


ALTER TABLE edocument_x
	ADD CONSTRAINT fk_edocument_x_edocument_1 FOREIGN KEY (edocument_uuid) REFERENCES edocument (edocument_uuid);


ALTER TABLE experiment
	ADD CONSTRAINT fk_experiment_actor_owner_1 FOREIGN KEY (owner_uuid) REFERENCES actor (actor_uuid),
		ADD CONSTRAINT fk_experiment_actor_operator_1 FOREIGN KEY (operator_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_experiment_actor_lab_1 FOREIGN KEY (lab_uuid) REFERENCES actor (actor_uuid),
				ADD CONSTRAINT fk_experiment_experiment_1 FOREIGN KEY (parent_uuid) REFERENCES experiment (experiment_uuid),
					ADD CONSTRAINT fk_experiment_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE experiment_workflow
	ADD CONSTRAINT fk_experiment_workflow_experiment_1 FOREIGN KEY (experiment_uuid) REFERENCES experiment (experiment_uuid),
		ADD CONSTRAINT fk_experiment_workflow_workflow_1 FOREIGN KEY (workflow_uuid) REFERENCES workflow (workflow_uuid);


ALTER TABLE inventory
	ADD CONSTRAINT fk_inventory_material_1 FOREIGN KEY (material_uuid) REFERENCES material (material_uuid),
		ADD CONSTRAINT fk_inventory_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_inventory_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE material
 ADD CONSTRAINT fk_material_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_material_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE material_composite
 ADD CONSTRAINT fk_material_composite_composite_1 FOREIGN KEY (composite_uuid) REFERENCES material (material_uuid),
	ADD CONSTRAINT fk_material_composite_component_1 FOREIGN KEY (component_uuid) REFERENCES material (material_uuid),
 		ADD CONSTRAINT fk_material_composite_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_material_composite_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE material_refname
	ADD CONSTRAINT fk_material_refname_def_1 FOREIGN KEY (material_refname_def_uuid) REFERENCES material_refname_def (material_refname_def_uuid),
		ADD CONSTRAINT fk_material_refname_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE material_refname_x
	ADD CONSTRAINT fk_material_refname_x_material_1 FOREIGN KEY (material_uuid) REFERENCES material (material_uuid),
		ADD CONSTRAINT fk_material_refname_x_material_refname_1 FOREIGN KEY (material_refname_uuid) REFERENCES material_refname (material_refname_uuid);


ALTER TABLE material_type_x
	ADD CONSTRAINT fk_material_type_x_material_type_1 FOREIGN KEY (material_type_uuid) REFERENCES material_type (material_type_uuid);


ALTER TABLE material_x
	ADD CONSTRAINT fk_material_x_material_1 FOREIGN KEY (ref_material_uuid) REFERENCES material (material_uuid);


ALTER TABLE measure
	ADD CONSTRAINT fk_measure_measure_type_1 FOREIGN KEY (measure_type_uuid) REFERENCES measure_type (measure_type_uuid),
		ADD CONSTRAINT fk_measure_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);


ALTER TABLE measure_x
	ADD CONSTRAINT fk_measure_x_measure_1 FOREIGN KEY (measure_uuid) REFERENCES measure (measure_uuid);


ALTER TABLE note
	ADD CONSTRAINT fk_note_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);


ALTER TABLE note_x
	ADD CONSTRAINT fk_note_x_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);


ALTER TABLE organization
	ADD CONSTRAINT fk_organization_organization_1 FOREIGN KEY (parent_uuid) REFERENCES organization (organization_uuid);


ALTER TABLE parameter
 ADD CONSTRAINT fk_parameter_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_parameter_parameter_def_1 FOREIGN KEY (parameter_def_uuid) REFERENCES parameter_def (parameter_def_uuid),
		ADD CONSTRAINT fk_parameter_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE parameter_def
 ADD CONSTRAINT fk_parameter_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_parameter_def_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE parameter_x
	ADD CONSTRAINT fk_parameter_x_parameter_1 FOREIGN KEY (parameter_uuid) REFERENCES parameter (parameter_uuid);


ALTER TABLE person
	ADD CONSTRAINT fk_person_organization_1 FOREIGN KEY (organization_uuid) REFERENCES organization (organization_uuid);


ALTER TABLE property
 ADD CONSTRAINT fk_property_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_property_property_def_1 FOREIGN KEY (property_def_uuid) REFERENCES property_def (property_def_uuid),
		ADD CONSTRAINT fk_property_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE property_def
 ADD CONSTRAINT fk_property_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_property_def_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid),
			ADD CONSTRAINT fk_property_def_val_type_1 FOREIGN KEY (val_type_uuid) REFERENCES type_def (type_def_uuid);


ALTER TABLE property_x
	ADD CONSTRAINT fk_property_x_property_1 FOREIGN KEY (property_uuid) REFERENCES property (property_uuid);


ALTER TABLE systemtool
	ADD CONSTRAINT fk_systemtool_systemtool_type_1 FOREIGN KEY (systemtool_type_uuid) REFERENCES systemtool_type (systemtool_type_uuid),
		ADD CONSTRAINT fk_systemtool_vendor_1 FOREIGN KEY (vendor_organization_uuid) REFERENCES organization (organization_uuid);


ALTER TABLE tag
	ADD CONSTRAINT fk_tag_tag_type_1 FOREIGN KEY (tag_type_uuid) REFERENCES tag_type (tag_type_uuid),
		ADD CONSTRAINT fk_tag_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);


ALTER TABLE tag_x
	ADD CONSTRAINT fk_tag_x_tag_1 FOREIGN KEY (tag_uuid) REFERENCES tag (tag_uuid);


ALTER TABLE udf
	ADD CONSTRAINT fk_udf_udf_def_1 FOREIGN KEY (udf_def_uuid) REFERENCES udf_def (udf_def_uuid);


ALTER TABLE udf_def
	ADD CONSTRAINT fk_udf_def_udf_def_1 FOREIGN KEY (val_type_uuid) REFERENCES type_def (type_def_uuid);


ALTER TABLE udf_x
	ADD CONSTRAINT fk_udf_x_udf_1 FOREIGN KEY (udf_uuid) REFERENCES udf (udf_uuid);


ALTER TABLE workflow
	ADD CONSTRAINT fk_workflow_type_1 FOREIGN KEY (workflow_type_uuid) REFERENCES  workflow_type (workflow_type_uuid),
		ADD CONSTRAINT fk_workflow_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_workflow_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE workflow_action_set
	ADD CONSTRAINT fk_workflow_action_set_workflow_1 FOREIGN KEY (workflow_uuid) REFERENCES  workflow (workflow_uuid),	
		ADD CONSTRAINT fk_workflow_action_set_action_def_1 FOREIGN KEY (action_def_uuid) REFERENCES  action_def (action_def_uuid),	
			ADD CONSTRAINT fk_workflow_action_set_parameter_def_1 FOREIGN KEY (parameter_def_uuid) REFERENCES  parameter_def (parameter_def_uuid),	
				ADD CONSTRAINT fk_workflow_action_set_calculation_1 FOREIGN KEY (calculation_uuid) REFERENCES  calculation (calculation_uuid),
					ADD CONSTRAINT fk_workflow_action_set_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
						ADD CONSTRAINT fk_workflow_action_set_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE workflow_object
	ADD CONSTRAINT fk_workflow_object_workflow_1 FOREIGN KEY (workflow_uuid) REFERENCES workflow (workflow_uuid),
		ADD CONSTRAINT fk_workflow_object_action_1 FOREIGN KEY (action_uuid) REFERENCES action (action_uuid),
			ADD CONSTRAINT fk_workflow_object_condition_1 FOREIGN KEY (condition_uuid) REFERENCES condition (condition_uuid),
				ADD CONSTRAINT fk_workflow_object_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE workflow_state
	ADD CONSTRAINT fk_workflow_state_workflow_step_1 FOREIGN KEY (workflow_step_uuid) REFERENCES workflow_step (workflow_step_uuid),
		ADD CONSTRAINT fk_workflow_state_workflow_state_1 FOREIGN KEY (workflow_state_uuid) REFERENCES workflow_state (workflow_state_uuid);


ALTER TABLE workflow_step
	ADD CONSTRAINT fk_workflow_step_workflow_step_1 FOREIGN KEY (workflow_uuid) REFERENCES workflow (workflow_uuid),
		ADD CONSTRAINT fk_workflow_step_object_1 FOREIGN KEY (workflow_object_uuid) REFERENCES workflow_object (workflow_object_uuid),
					ADD CONSTRAINT fk_workflow_step_parent_1 FOREIGN KEY (parent_uuid) REFERENCES workflow_step (workflow_step_uuid);


--======================================================================
--======================================================================
-- TABLE AND COLUMN COMMENTS
--======================================================================
--======================================================================
COMMENT ON TABLE action IS '';
COMMENT ON COLUMN action.action_uuid IS '';
COMMENT ON COLUMN action.action_def_uuid IS '';
COMMENT ON COLUMN action.workflow_uuid IS '';
COMMENT ON COLUMN action.description IS '';
COMMENT ON COLUMN action.start_date IS '';
COMMENT ON COLUMN action.end_date IS '';
COMMENT ON COLUMN action.duration IS '';
COMMENT ON COLUMN action.repeating IS '';
COMMENT ON COLUMN action.ref_parameter_uuid IS '';
COMMENT ON COLUMN action.calculation_def_uuid IS '';
COMMENT ON COLUMN action.source_material_uuid IS '';
COMMENT ON COLUMN action.destination_material_uuid IS '';
COMMENT ON COLUMN action.actor_uuid IS '';
COMMENT ON COLUMN action.status_uuid IS '';
COMMENT ON COLUMN action.add_date IS '';
COMMENT ON COLUMN action.mod_date IS '';


COMMENT ON TABLE action_def IS '';
COMMENT ON COLUMN action_def.action_def_uuid IS '';
COMMENT ON COLUMN action_def.description IS '';
COMMENT ON COLUMN action_def.status_uuid IS '';
COMMENT ON COLUMN action_def.actor_uuid IS '';
COMMENT ON COLUMN action_def.add_date IS '';
COMMENT ON COLUMN action_def.mod_date IS '';


COMMENT ON TABLE action_parameter_def_x IS '';
COMMENT ON COLUMN action_parameter_def_x.action_parameter_def_x_uuid IS '';
COMMENT ON COLUMN action_parameter_def_x.parameter_def_uuid IS '';
COMMENT ON COLUMN action_parameter_def_x.action_def_uuid IS '';
COMMENT ON COLUMN action_parameter_def_x.add_date IS '';
COMMENT ON COLUMN action_parameter_def_x.mod_date IS '';


COMMENT ON TABLE actor IS '';
COMMENT ON COLUMN actor.actor_uuid IS '';
COMMENT ON COLUMN actor.person_uuid IS '';
COMMENT ON COLUMN actor.organization_uuid IS '';
COMMENT ON COLUMN actor.systemtool_uuid IS '';
COMMENT ON COLUMN actor.description IS '';
COMMENT ON COLUMN actor.status_uuid IS '';
COMMENT ON COLUMN actor.add_date IS '';
COMMENT ON COLUMN actor.mod_date IS '';


COMMENT ON TABLE actor_pref IS '';
COMMENT ON COLUMN actor_pref.actor_pref_uuid IS '';
COMMENT ON COLUMN actor_pref.actor_uuid IS '';
COMMENT ON COLUMN actor_pref.pkey IS '';
COMMENT ON COLUMN actor_pref.pvalue IS '';
COMMENT ON COLUMN actor_pref.add_date IS '';
COMMENT ON COLUMN actor_pref.mod_date IS '';


COMMENT ON TABLE bom IS '';
COMMENT ON COLUMN bom.bom_uuid IS '';
COMMENT ON COLUMN bom.experiment_uuid IS '';
COMMENT ON COLUMN bom.description IS '';
COMMENT ON COLUMN bom.actor_uuid IS '';
COMMENT ON COLUMN bom.status_uuid IS '';
COMMENT ON COLUMN bom.add_date IS '';
COMMENT ON COLUMN bom.mod_date IS '';


COMMENT ON TABLE bom_material IS '';
COMMENT ON COLUMN bom_material.bom_material_uuid IS '';
COMMENT ON COLUMN bom_material.bom_uuid IS '';
COMMENT ON COLUMN bom_material.inventory_uuid IS '';
COMMENT ON COLUMN bom_material.material_composite_uuid IS '';
COMMENT ON COLUMN bom_material.alloc_amt_val IS '';
COMMENT ON COLUMN bom_material.used_amt_val IS '';
COMMENT ON COLUMN bom_material.putback_amt_val IS '';
COMMENT ON COLUMN bom_material.actor_uuid IS '';
COMMENT ON COLUMN bom_material.status_uuid IS '';
COMMENT ON COLUMN bom_material.add_date IS '';
COMMENT ON COLUMN bom_material.mod_date IS '';


COMMENT ON TABLE calculation IS '';
COMMENT ON COLUMN calculation.calculation_uuid IS '';
COMMENT ON COLUMN calculation.calculation_def_uuid IS '';
COMMENT ON COLUMN calculation.calculation_alias_name IS '';
COMMENT ON COLUMN calculation.in_val IS '';
COMMENT ON COLUMN calculation.in_opt_val IS '';
COMMENT ON COLUMN calculation.out_val IS '';
COMMENT ON COLUMN calculation.status_uuid IS '';
COMMENT ON COLUMN calculation.actor_uuid IS '';
COMMENT ON COLUMN calculation.add_date IS '';
COMMENT ON COLUMN calculation.mod_date IS '';


COMMENT ON TABLE calculation_class IS '';
COMMENT ON COLUMN calculation_class.calculation_class_uuid IS '';
COMMENT ON COLUMN calculation_class.description IS '';
COMMENT ON COLUMN calculation_class.add_date IS '';
COMMENT ON COLUMN calculation_class.mod_date IS '';


COMMENT ON TABLE calculation_def IS '';
COMMENT ON COLUMN calculation_def.calculation_def_uuid IS '';
COMMENT ON COLUMN calculation_def.short_name IS '';
COMMENT ON COLUMN calculation_def.calc_definition IS '';
COMMENT ON COLUMN calculation_def.systemtool_uuid IS '';
COMMENT ON COLUMN calculation_def.description IS '';
COMMENT ON COLUMN calculation_def.in_source_uuid IS '';
COMMENT ON COLUMN calculation_def.in_type_uuid IS '';
COMMENT ON COLUMN calculation_def.in_opt_source_uuid IS '';
COMMENT ON COLUMN calculation_def.in_opt_type_uuid IS '';
COMMENT ON COLUMN calculation_def.out_type_uuid IS '';
COMMENT ON COLUMN calculation_def.calculation_class_uuid IS '';
COMMENT ON COLUMN calculation_def.actor_uuid IS '';
COMMENT ON COLUMN calculation_def.status_uuid IS '';
COMMENT ON COLUMN calculation_def.add_date IS '';
COMMENT ON COLUMN calculation_def.mod_date IS '';


COMMENT ON TABLE calculation_eval IS '';
COMMENT ON COLUMN calculation_eval.calculation_eval_id IS '';
COMMENT ON COLUMN calculation_eval.calculation_def_uuid IS '';
COMMENT ON COLUMN calculation_eval.in_val IS '';
COMMENT ON COLUMN calculation_eval.in_opt_val IS '';
COMMENT ON COLUMN calculation_eval.out_val IS '';
COMMENT ON COLUMN calculation_eval.calculation_alias_name IS '';
COMMENT ON COLUMN calculation_eval.actor_uuid IS '';
COMMENT ON COLUMN calculation_eval.add_date IS '';


COMMENT ON TABLE calculation_stack IS '';
COMMENT ON COLUMN calculation_stack.calculation_stack_id IS '';
COMMENT ON COLUMN calculation_stack.stack_val IS '';
COMMENT ON COLUMN calculation_stack.add_date IS '';


COMMENT ON TABLE condition IS '';
COMMENT ON COLUMN condition.condition_uuid IS '';
COMMENT ON COLUMN condition.condition_calculation_def_x_uuid IS '';
COMMENT ON COLUMN condition.in_val IS '';
COMMENT ON COLUMN condition.out_val IS '';
COMMENT ON COLUMN condition.actor_uuid IS '';
COMMENT ON COLUMN condition.status_uuid IS '';
COMMENT ON COLUMN condition.add_date IS '';
COMMENT ON COLUMN condition.mod_date IS '';


COMMENT ON TABLE condition_def IS '';
COMMENT ON COLUMN condition_def.condition_def_uuid IS '';
COMMENT ON COLUMN condition_def.description IS '';
COMMENT ON COLUMN condition_def.actor_uuid IS '';
COMMENT ON COLUMN condition_def.status_uuid IS '';
COMMENT ON COLUMN condition_def.add_date IS '';
COMMENT ON COLUMN condition_def.mod_date IS '';


COMMENT ON TABLE condition_calculation_def_x IS '';
COMMENT ON COLUMN condition_calculation_def_x.condition_calculation_def_x_uuid IS '';
COMMENT ON COLUMN condition_calculation_def_x.condition_def_uuid IS '';
COMMENT ON COLUMN condition_calculation_def_x.calculation_def_uuid IS '';
COMMENT ON COLUMN condition_calculation_def_x.add_date IS '';
COMMENT ON COLUMN condition_calculation_def_x.mod_date IS '';


COMMENT ON TABLE condition_path IS '';
COMMENT ON COLUMN condition_path.condition_path_uuid IS '';
COMMENT ON COLUMN condition_path.condition_uuid IS '';
COMMENT ON COLUMN condition_path.condition_out_val IS '';
COMMENT ON COLUMN condition_path.workflow_step_uuid IS '';
COMMENT ON COLUMN condition_path.add_date IS '';
COMMENT ON COLUMN condition_path.mod_date IS '';


COMMENT ON TABLE edocument IS '';
COMMENT ON COLUMN edocument.edocument_uuid IS '';
COMMENT ON COLUMN edocument.title IS '';
COMMENT ON COLUMN edocument.description IS '';
COMMENT ON COLUMN edocument.filename IS '';
COMMENT ON COLUMN edocument.source IS '';
COMMENT ON COLUMN edocument.edocument IS '';
COMMENT ON COLUMN edocument.doc_type_uuid IS '';
COMMENT ON COLUMN edocument.doc_ver IS '';
COMMENT ON COLUMN edocument.actor_uuid IS '';
COMMENT ON COLUMN edocument.status_uuid IS '';
COMMENT ON COLUMN edocument.add_date IS '';
COMMENT ON COLUMN edocument.mod_date IS '';


COMMENT ON TABLE edocument_x IS '';
COMMENT ON COLUMN edocument_x.edocument_x_uuid IS '';
COMMENT ON COLUMN edocument_x.ref_edocument_uuid IS '';
COMMENT ON COLUMN edocument_x.edocument_uuid IS '';
COMMENT ON COLUMN edocument_x.add_date IS '';
COMMENT ON COLUMN edocument_x.mod_date IS '';


COMMENT ON TABLE experiment IS '';
COMMENT ON COLUMN experiment.experiment_uuid IS '';
COMMENT ON COLUMN experiment.ref_uid IS '';
COMMENT ON COLUMN experiment.description IS '';
COMMENT ON COLUMN experiment.parent_uuid IS '';
COMMENT ON COLUMN experiment.parent_path IS '';
COMMENT ON COLUMN experiment.owner_uuid IS '';
COMMENT ON COLUMN experiment.operator_uuid IS '';
COMMENT ON COLUMN experiment.lab_uuid IS '';
COMMENT ON COLUMN experiment.status_uuid IS '';
COMMENT ON COLUMN experiment.add_date IS '';
COMMENT ON COLUMN experiment.mod_date IS '';


COMMENT ON TABLE experiment_workflow IS '';
COMMENT ON COLUMN experiment_workflow.experiment_workflow_uuid IS '';
COMMENT ON COLUMN experiment_workflow.experiment_workflow_seq IS '';
COMMENT ON COLUMN experiment_workflow.experiment_uuid IS '';
COMMENT ON COLUMN experiment_workflow.workflow_uuid IS '';
COMMENT ON COLUMN experiment_workflow.add_date IS '';
COMMENT ON COLUMN experiment_workflow.mod_date IS '';


COMMENT ON TABLE inventory IS '';
COMMENT ON COLUMN inventory.inventory_uuid IS '';
COMMENT ON COLUMN inventory.description IS '';
COMMENT ON COLUMN inventory.material_uuid IS '';
COMMENT ON COLUMN inventory.part_no IS '';
COMMENT ON COLUMN inventory.onhand_amt IS '';
COMMENT ON COLUMN inventory.expiration_date IS '';
COMMENT ON COLUMN inventory.location IS '';
COMMENT ON COLUMN inventory.actor_uuid IS '';
COMMENT ON COLUMN inventory.status_uuid IS '';
COMMENT ON COLUMN inventory.add_date IS '';
COMMENT ON COLUMN inventory.mod_date IS '';


COMMENT ON TABLE material IS '';
COMMENT ON COLUMN material.material_uuid IS '';
COMMENT ON COLUMN material.description IS '';
COMMENT ON COLUMN material.consumable IS '';
COMMENT ON COLUMN material.actor_uuid IS '';
COMMENT ON COLUMN material.status_uuid IS '';
COMMENT ON COLUMN material.add_date IS '';
COMMENT ON COLUMN material.mod_date IS '';


COMMENT ON TABLE material_composite IS '';
COMMENT ON COLUMN material_composite.material_composite_uuid IS '';
COMMENT ON COLUMN material_composite.composite_uuid IS '';
COMMENT ON COLUMN material_composite.component_uuid IS '';
COMMENT ON COLUMN material_composite.addressable IS '';
COMMENT ON COLUMN material_composite.actor_uuid IS '';
COMMENT ON COLUMN material_composite.status_uuid IS '';
COMMENT ON COLUMN material_composite.add_date IS '';
COMMENT ON COLUMN material_composite.mod_date IS '';


COMMENT ON TABLE material_x IS '';
COMMENT ON COLUMN material_x.material_x_uuid IS '';
COMMENT ON COLUMN material_x.material_uuid IS '';
COMMENT ON COLUMN material_x.ref_material_uuid IS '';
COMMENT ON COLUMN material_x.add_date IS '';
COMMENT ON COLUMN material_x.mod_date IS '';


COMMENT ON TABLE material_refname IS '';
COMMENT ON COLUMN material_refname.material_refname_uuid IS '';
COMMENT ON COLUMN material_refname.description IS '';
COMMENT ON COLUMN material_refname.blob_value IS '';
COMMENT ON COLUMN material_refname.blob_type IS '';
COMMENT ON COLUMN material_refname.material_refname_def_uuid IS '';
COMMENT ON COLUMN material_refname.reference IS '';
COMMENT ON COLUMN material_refname.status_uuid IS '';
COMMENT ON COLUMN material_refname.add_date IS '';
COMMENT ON COLUMN material_refname.mod_date IS '';


COMMENT ON TABLE material_refname_def IS '';
COMMENT ON COLUMN material_refname_def.material_refname_def_uuid IS '';
COMMENT ON COLUMN material_refname_def.description IS '';
COMMENT ON COLUMN material_refname_def.add_date IS '';
COMMENT ON COLUMN material_refname_def.mod_date IS '';


COMMENT ON TABLE material_refname_x IS '';
COMMENT ON COLUMN material_refname_x.material_refname_x_uuid IS '';
COMMENT ON COLUMN material_refname_x.material_uuid IS '';
COMMENT ON COLUMN material_refname_x.material_refname_uuid IS '';
COMMENT ON COLUMN material_refname_x.add_date IS '';
COMMENT ON COLUMN material_refname_x.mod_date IS '';


COMMENT ON TABLE material_type IS '';
COMMENT ON COLUMN material_type.material_type_uuid IS '';
COMMENT ON COLUMN material_type.description IS '';
COMMENT ON COLUMN material_type.actor_uuid IS '';
COMMENT ON COLUMN material_type.status_uuid IS '';
COMMENT ON COLUMN material_type.add_date IS '';
COMMENT ON COLUMN material_type.mod_date IS '';


COMMENT ON TABLE material_type_x IS '';
COMMENT ON COLUMN material_type_x.material_type_x_uuid IS '';
COMMENT ON COLUMN material_type_x.material_uuid IS '';
COMMENT ON COLUMN material_type_x.material_type_uuid IS '';
COMMENT ON COLUMN material_type_x.add_date IS '';
COMMENT ON COLUMN material_type_x.mod_date IS '';


COMMENT ON TABLE measure IS '';
COMMENT ON COLUMN measure.measure_uuid IS '';
COMMENT ON COLUMN measure.measure_type_uuid IS '';
COMMENT ON COLUMN measure.description IS '';
COMMENT ON COLUMN measure.amount IS '';
COMMENT ON COLUMN measure.actor_uuid IS '';
COMMENT ON COLUMN measure.status_uuid IS '';
COMMENT ON COLUMN measure.add_date IS '';
COMMENT ON COLUMN measure.mod_date IS '';


COMMENT ON TABLE measure_type IS '';
COMMENT ON COLUMN measure_type.measure_type_uuid IS '';
COMMENT ON COLUMN measure_type.description IS '';
COMMENT ON COLUMN measure_type.actor_uuid IS '';
COMMENT ON COLUMN measure_type.status_uuid IS '';
COMMENT ON COLUMN measure_type.add_date IS '';
COMMENT ON COLUMN measure_type.mod_date IS '';


COMMENT ON TABLE measure_x IS '';
COMMENT ON COLUMN measure_x.measure_x_uuid IS '';
COMMENT ON COLUMN measure_x.ref_measure_uuid IS '';
COMMENT ON COLUMN measure_x.measure_uuid IS '';
COMMENT ON COLUMN measure_x.add_date IS '';
COMMENT ON COLUMN measure_x.mod_date IS '';


COMMENT ON TABLE note IS '';
COMMENT ON COLUMN note.note_uuid IS '';
COMMENT ON COLUMN note.notetext IS '';
COMMENT ON COLUMN note.actor_uuid IS '';
COMMENT ON COLUMN note.add_date IS '';
COMMENT ON COLUMN note.mod_date IS '';


COMMENT ON TABLE note_x IS '';
COMMENT ON COLUMN note_x.note_x_uuid IS '';
COMMENT ON COLUMN note_x.ref_note_uuid IS '';
COMMENT ON COLUMN note_x.note_uuid IS '';
COMMENT ON COLUMN note_x.add_date IS '';
COMMENT ON COLUMN note_x.mod_date IS '';


COMMENT ON TABLE organization IS 'organization information for ESCALATE person and system tool; can be component of actor';
COMMENT ON COLUMN organization.organization_uuid IS 'uuid for this organization record';
COMMENT ON COLUMN organization.parent_uuid IS 'reference to parent organization; uses [internal] organization_uuid';
COMMENT ON COLUMN organization.parent_path IS 'allows a searchable, navigatable tree structure; currently not being used';
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


COMMENT ON TABLE outcome IS '';
COMMENT ON COLUMN outcome.outcome_uuid IS '';
COMMENT ON COLUMN outcome.outcome_ref_uuid IS '';
COMMENT ON COLUMN outcome.actor_uuid IS '';
COMMENT ON COLUMN outcome.outcome_type_uuid IS '';
COMMENT ON COLUMN outcome.add_date IS '';
COMMENT ON COLUMN outcome.mod_date IS '';


COMMENT ON TABLE outcome_type IS '';
COMMENT ON COLUMN outcome_type.outcome_type_uuid IS '';
COMMENT ON COLUMN outcome_type.description IS '';
COMMENT ON COLUMN outcome_type.actor_uuid IS '';
COMMENT ON COLUMN outcome_type.add_date IS '';
COMMENT ON COLUMN outcome_type.mod_date IS '';


COMMENT ON TABLE outcome_x IS '';
COMMENT ON COLUMN outcome_x.outcome_x_uuid IS '';
COMMENT ON COLUMN outcome_x.outcome_ref_uuid IS '';
COMMENT ON COLUMN outcome_x.outcome_uuid IS '';
COMMENT ON COLUMN outcome_x.add_date IS '';
COMMENT ON COLUMN outcome_x.mod_date IS '';


COMMENT ON TABLE parameter IS '';
COMMENT ON COLUMN parameter.parameter_uuid IS '';
COMMENT ON COLUMN parameter.parameter_def_uuid IS '';
COMMENT ON COLUMN parameter.parameter_val IS '';
COMMENT ON COLUMN parameter.actor_uuid IS '';
COMMENT ON COLUMN parameter.status_uuid IS '';
COMMENT ON COLUMN parameter.add_date IS '';
COMMENT ON COLUMN parameter.mod_date IS '';


COMMENT ON TABLE parameter_def IS 'template for a parameter';
COMMENT ON COLUMN parameter_def.parameter_def_uuid IS '';
COMMENT ON COLUMN parameter_def.description IS '';
COMMENT ON COLUMN parameter_def.default_val IS 'this includes the type and units for the parameter';
COMMENT ON COLUMN parameter_def.required IS '';
COMMENT ON COLUMN parameter_def.actor_uuid IS '';
COMMENT ON COLUMN parameter_def.status_uuid IS '';
COMMENT ON COLUMN parameter_def.add_date IS '';
COMMENT ON COLUMN parameter_def.mod_date IS '';


COMMENT ON TABLE parameter_x IS '';
COMMENT ON COLUMN parameter_x.parameter_x_uuid IS '';
COMMENT ON COLUMN parameter_x.ref_parameter_uuid IS '';
COMMENT ON COLUMN parameter_x.parameter_uuid IS '';
COMMENT ON COLUMN parameter_x.add_date IS '';
COMMENT ON COLUMN parameter_x.mod_date IS '';


COMMENT ON TABLE person IS '';
COMMENT ON COLUMN person.person_uuid IS '';
COMMENT ON COLUMN person.first_name IS '';
COMMENT ON COLUMN person.last_name IS '';
COMMENT ON COLUMN person.middle_name IS '';
COMMENT ON COLUMN person.address1 IS '';
COMMENT ON COLUMN person.address2 IS '';
COMMENT ON COLUMN person.city IS '';
COMMENT ON COLUMN person.state_province IS '';
COMMENT ON COLUMN person.zip IS '';
COMMENT ON COLUMN person.country IS '';
COMMENT ON COLUMN person.phone IS '';
COMMENT ON COLUMN person.email IS '';
COMMENT ON COLUMN person.title IS '';
COMMENT ON COLUMN person.suffix IS '';
COMMENT ON COLUMN person.organization_uuid IS '';
COMMENT ON COLUMN person.add_date IS '';
COMMENT ON COLUMN person.mod_date IS '';


COMMENT ON TABLE property IS '';
COMMENT ON COLUMN property.property_uuid IS '';
COMMENT ON COLUMN property.property_def_uuid IS '';
COMMENT ON COLUMN property.property_val IS '';
COMMENT ON COLUMN property.actor_uuid IS '';
COMMENT ON COLUMN property.status_uuid IS '';
COMMENT ON COLUMN property.add_date IS '';
COMMENT ON COLUMN property.mod_date IS '';


COMMENT ON TABLE property_def IS '';
COMMENT ON COLUMN property_def.property_def_uuid IS '';
COMMENT ON COLUMN property_def.description IS '';
COMMENT ON COLUMN property_def.short_description IS '';
COMMENT ON COLUMN property_def.val_type_uuid IS '';
COMMENT ON COLUMN property_def.valunit IS '';
COMMENT ON COLUMN property_def.actor_uuid IS '';
COMMENT ON COLUMN property_def.status_uuid IS '';
COMMENT ON COLUMN property_def.add_date IS '';
COMMENT ON COLUMN property_def.mod_date IS '';


COMMENT ON TABLE parameter_x IS '';
COMMENT ON COLUMN parameter_x.parameter_x_uuid IS '';
COMMENT ON COLUMN parameter_x.ref_parameter_uuid IS '';
COMMENT ON COLUMN parameter_x.parameter_uuid IS '';
COMMENT ON COLUMN parameter_x.add_date IS '';
COMMENT ON COLUMN parameter_x.mod_date IS '';


COMMENT ON TABLE person IS '';
COMMENT ON COLUMN person.person_uuid IS '';
COMMENT ON COLUMN person.first_name IS '';
COMMENT ON COLUMN person.last_name IS '';
COMMENT ON COLUMN person.middle_name IS '';
COMMENT ON COLUMN person.address1 IS '';
COMMENT ON COLUMN person.address2 IS '';
COMMENT ON COLUMN person.city IS '';
COMMENT ON COLUMN person.state_province IS '';
COMMENT ON COLUMN person.zip IS '';
COMMENT ON COLUMN person.country IS '';
COMMENT ON COLUMN person.phone IS '';
COMMENT ON COLUMN person.email IS '';
COMMENT ON COLUMN person.title IS '';
COMMENT ON COLUMN person.suffix IS '';
COMMENT ON COLUMN person.organization_uuid IS '';
COMMENT ON COLUMN person.add_date IS '';
COMMENT ON COLUMN person.mod_date IS '';


COMMENT ON TABLE property IS '';
COMMENT ON COLUMN property.property_uuid IS '';
COMMENT ON COLUMN property.property_def_uuid IS '';
COMMENT ON COLUMN property.property_val IS '';
COMMENT ON COLUMN property.actor_uuid IS '';
COMMENT ON COLUMN property.status_uuid IS '';
COMMENT ON COLUMN property.add_date IS '';
COMMENT ON COLUMN property.mod_date IS '';


COMMENT ON TABLE property_def IS '';
COMMENT ON COLUMN property_def.property_def_uuid IS '';
COMMENT ON COLUMN property_def.description IS '';
COMMENT ON COLUMN property_def.short_description IS '';
COMMENT ON COLUMN property_def.val_type_uuid IS '';
COMMENT ON COLUMN property_def.valunit IS '';
COMMENT ON COLUMN property_def.actor_uuid IS '';
COMMENT ON COLUMN property_def.status_uuid IS '';
COMMENT ON COLUMN property_def.add_date IS '';
COMMENT ON COLUMN property_def.mod_date IS '';


COMMENT ON TABLE property_x IS '';
COMMENT ON COLUMN property_x.property_x_uuid IS '';
COMMENT ON COLUMN property_x.material_uuid IS '';
COMMENT ON COLUMN property_x.property_uuid IS '';
COMMENT ON COLUMN property_x.add_date IS '';
COMMENT ON COLUMN property_x.mod_date IS '';


COMMENT ON TABLE status IS '';
COMMENT ON COLUMN status.status_uuid IS '';
COMMENT ON COLUMN status.description IS '';
COMMENT ON COLUMN status.add_date IS '';
COMMENT ON COLUMN status.mod_date IS '';


COMMENT ON TABLE systemtool IS '';
COMMENT ON COLUMN systemtool.systemtool_uuid IS '';
COMMENT ON COLUMN systemtool.systemtool_name IS '';
COMMENT ON COLUMN systemtool.description IS '';
COMMENT ON COLUMN systemtool.systemtool_type_uuid IS '';
COMMENT ON COLUMN systemtool.vendor_organization_uuid IS '';
COMMENT ON COLUMN systemtool.model IS '';
COMMENT ON COLUMN systemtool.serial IS '';
COMMENT ON COLUMN systemtool.ver IS '';
COMMENT ON COLUMN systemtool.add_date IS '';
COMMENT ON COLUMN systemtool.mod_date IS '';


COMMENT ON TABLE systemtool_type IS '';
COMMENT ON COLUMN systemtool_type.systemtool_type_uuid IS '';
COMMENT ON COLUMN systemtool_type.description IS '';
COMMENT ON COLUMN systemtool_type.add_date IS '';
COMMENT ON COLUMN systemtool_type.mod_date IS '';


COMMENT ON TABLE sys_audit IS '';
COMMENT ON COLUMN sys_audit.event_id IS '';
COMMENT ON COLUMN sys_audit.schema_name IS '';
COMMENT ON COLUMN sys_audit.table_name IS '';
COMMENT ON COLUMN sys_audit.relid IS '';
COMMENT ON COLUMN sys_audit.session_user_name IS '';
COMMENT ON COLUMN sys_audit.action_tstamp_tx IS '';
COMMENT ON COLUMN sys_audit.action_tstamp_stm IS '';
COMMENT ON COLUMN sys_audit.action_tstamp_clk IS '';
COMMENT ON COLUMN sys_audit.transaction_id IS '';
COMMENT ON COLUMN sys_audit.application_name IS '';
COMMENT ON COLUMN sys_audit.client_addr IS '';
COMMENT ON COLUMN sys_audit.client_port IS '';
COMMENT ON COLUMN sys_audit.client_query IS '';
COMMENT ON COLUMN sys_audit.action IS '';
COMMENT ON COLUMN sys_audit.row_data IS '';
COMMENT ON COLUMN sys_audit.changed_fields IS '';
COMMENT ON COLUMN sys_audit.statement_only IS '';


COMMENT ON TABLE tag IS '';
COMMENT ON COLUMN tag.tag_uuid IS '';
COMMENT ON COLUMN tag.tag_type_uuid IS '';
COMMENT ON COLUMN tag.display_text IS '';
COMMENT ON COLUMN tag.description IS '';
COMMENT ON COLUMN tag.actor_uuid IS '';
COMMENT ON COLUMN tag.add_date IS '';
COMMENT ON COLUMN tag.mod_date IS '';


COMMENT ON TABLE tag_type IS '';
COMMENT ON COLUMN tag_type.tag_type_uuid IS '';
COMMENT ON COLUMN tag_type.type IS '';
COMMENT ON COLUMN tag_type.description IS '';
COMMENT ON COLUMN tag_type.add_date IS '';
COMMENT ON COLUMN tag_type.mod_date IS '';


COMMENT ON TABLE tag_x IS '';
COMMENT ON COLUMN tag_x.tag_x_uuid IS '';
COMMENT ON COLUMN tag_x.ref_tag_uuid IS '';
COMMENT ON COLUMN tag_x.tag_uuid IS '';
COMMENT ON COLUMN tag_x.add_date IS '';
COMMENT ON COLUMN tag_x.mod_date IS '';


COMMENT ON TABLE type_def IS '';
COMMENT ON COLUMN type_def.type_def_uuid IS '';
COMMENT ON COLUMN type_def.category IS '';
COMMENT ON COLUMN type_def.description IS '';
COMMENT ON COLUMN type_def.add_date IS '';
COMMENT ON COLUMN type_def.mod_date IS '';


COMMENT ON TABLE udf IS '';
COMMENT ON COLUMN udf.udf_uuid IS '';
COMMENT ON COLUMN udf.udf_def_uuid IS '';
COMMENT ON COLUMN udf.udf_val IS '';
COMMENT ON COLUMN udf.add_date IS '';
COMMENT ON COLUMN udf.mod_date IS '';


COMMENT ON TABLE udf_def IS '';
COMMENT ON COLUMN udf_def.udf_def_uuid IS '';
COMMENT ON COLUMN udf_def.description IS '';
COMMENT ON COLUMN udf_def.val_type_uuid IS '';
COMMENT ON COLUMN udf_def.unit IS '';
COMMENT ON COLUMN udf_def.add_date IS '';
COMMENT ON COLUMN udf_def.mod_date IS '';


COMMENT ON TABLE udf_x IS '';
COMMENT ON COLUMN udf_x.udf_x_uuid IS '';
COMMENT ON COLUMN udf_x.ref_udf_uuid IS '';
COMMENT ON COLUMN udf_x.udf_uuid IS '';
COMMENT ON COLUMN udf_x.add_date IS '';
COMMENT ON COLUMN udf_x.mod_date IS '';


COMMENT ON TABLE workflow IS '';
COMMENT ON COLUMN workflow.workflow_uuid IS '';
COMMENT ON COLUMN workflow.workflow_type_uuid IS '';
COMMENT ON COLUMN workflow.description IS '';
COMMENT ON COLUMN workflow.parent_uuid IS '';
COMMENT ON COLUMN workflow.parent_path IS '';
COMMENT ON COLUMN workflow.actor_uuid IS '';
COMMENT ON COLUMN workflow.status_uuid IS '';
COMMENT ON COLUMN workflow.add_date IS '';
COMMENT ON COLUMN workflow.mod_date IS '';


COMMENT ON TABLE workflow_action_set IS '';
COMMENT ON COLUMN workflow_action_set.workflow_action_set_uuid IS '';
COMMENT ON COLUMN workflow_action_set.description IS '';
COMMENT ON COLUMN workflow_action_set.workflow_uuid IS '';
COMMENT ON COLUMN workflow_action_set.action_def_uuid IS '';
COMMENT ON COLUMN workflow_action_set.start_date IS '';
COMMENT ON COLUMN workflow_action_set.end_date IS '';
COMMENT ON COLUMN workflow_action_set.duration IS '';
COMMENT ON COLUMN workflow_action_set.repeating IS '';
COMMENT ON COLUMN workflow_action_set.parameter_def_uuid IS '';
COMMENT ON COLUMN workflow_action_set.parameter_val IS '';
COMMENT ON COLUMN workflow_action_set.calculation_uuid IS '';
COMMENT ON COLUMN workflow_action_set.source_material_uuid IS '';
COMMENT ON COLUMN workflow_action_set.destination_material_uuid IS '';
COMMENT ON COLUMN workflow_action_set.actor_uuid IS '';
COMMENT ON COLUMN workflow_action_set.status_uuid IS '';
COMMENT ON COLUMN workflow_action_set.add_date IS '';
COMMENT ON COLUMN workflow_action_set.mod_date IS '';


COMMENT ON TABLE workflow_object IS '';
COMMENT ON COLUMN workflow_object.workflow_object_uuid IS '';
COMMENT ON COLUMN workflow_object.workflow_uuid IS '';
COMMENT ON COLUMN workflow_object.action_uuid IS '';
COMMENT ON COLUMN workflow_object.condition_uuid IS '';
COMMENT ON COLUMN workflow_object.status_uuid IS '';
COMMENT ON COLUMN workflow_object.add_date IS '';
COMMENT ON COLUMN workflow_object.mod_date IS '';


COMMENT ON TABLE workflow_state IS '';
COMMENT ON COLUMN workflow_state.workflow_state_uuid IS '';
COMMENT ON COLUMN workflow_state.workflow_step_uuid IS '';
COMMENT ON COLUMN workflow_state.add_date IS '';
COMMENT ON COLUMN workflow_state.mod_date IS '';


COMMENT ON TABLE workflow_step IS '';
COMMENT ON COLUMN workflow_step.workflow_step_uuid IS '';
COMMENT ON COLUMN workflow_step.workflow_uuid IS '';
COMMENT ON COLUMN workflow_step.parent_uuid IS '';
COMMENT ON COLUMN workflow_step.parent_path IS '';
COMMENT ON COLUMN workflow_step.workflow_object_uuid IS '';
COMMENT ON COLUMN workflow_step.status_uuid IS '';
COMMENT ON COLUMN workflow_step.add_date IS '';
COMMENT ON COLUMN workflow_step.mod_date IS '';


COMMENT ON TABLE workflow_type IS '';
COMMENT ON COLUMN workflow_type.workflow_type_uuid IS '';
COMMENT ON COLUMN workflow_type.description IS '';
COMMENT ON COLUMN workflow_type.add_date IS '';
COMMENT ON COLUMN workflow_type.mod_date IS '';