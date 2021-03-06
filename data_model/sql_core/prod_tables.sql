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
DROP TABLE IF EXISTS bom_material_composite cascade;
DROP TABLE IF EXISTS bom_material_index cascade;
DROP TABLE IF EXISTS calculation cascade;
DROP TABLE IF EXISTS calculation_class cascade;
DROP TABLE IF EXISTS calculation_def cascade;
DROP TABLE IF EXISTS calculation_eval cascade;
DROP TABLE IF EXISTS calculation_parameter_def_x cascade;
DROP TABLE IF EXISTS calculation_stack cascade;
DROP TABLE IF EXISTS condition cascade;
DROP TABLE IF EXISTS condition_calculation_def_x cascade;
DROP TABLE IF EXISTS condition_def cascade;
DROP TABLE IF EXISTS condition_path cascade;
DROP TABLE IF EXISTS edocument cascade;
DROP TABLE IF EXISTS edocument_x cascade;
DROP TABLE IF EXISTS experiment cascade;
DROP TABLE IF EXISTS experiment_type cascade;
DROP TABLE IF EXISTS experiment_workflow cascade;
DROP TABLE IF EXISTS inventory cascade;
DROP TABLE IF EXISTS inventory_material cascade;
DROP TABLE IF EXISTS material cascade;
DROP TABLE IF EXISTS material_class cascade;
DROP TABLE IF EXISTS material_composite cascade;
DROP TABLE IF EXISTS material_refname cascade;
DROP TABLE IF EXISTS material_refname_def cascade;
DROP TABLE IF EXISTS material_refname_x cascade;
DROP TABLE IF EXISTS material_type cascade;
DROP TABLE IF EXISTS material_type_x cascade;
DROP TABLE IF EXISTS material_x cascade;
DROP TABLE IF EXISTS measure cascade;
DROP TABLE IF EXISTS measure_def cascade;
DROP TABLE IF EXISTS measure_type cascade;
DROP TABLE IF EXISTS measure_x cascade;
DROP TABLE IF EXISTS note cascade;
DROP TABLE IF EXISTS note_x cascade;
DROP TABLE IF EXISTS organization cascade;
DROP TABLE IF EXISTS outcome cascade;
DROP TABLE IF EXISTS parameter cascade;
DROP TABLE IF EXISTS parameter_def cascade;
DROP TABLE IF EXISTS parameter_x cascade;
DROP TABLE IF EXISTS person cascade; 
DROP TABLE IF EXISTS property cascade;
DROP TABLE IF EXISTS property_def cascade;
DROP TABLE IF EXISTS property_class cascade;
DROP TABLE IF EXISTS property_type cascade;
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
	action_def_uuid uuid NOT NULL,
	workflow_uuid uuid NOT NULL,
	workflow_action_set_uuid uuid,
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
	inventory_material_uuid uuid NOT NULL,
	alloc_amt_val val,
	used_amt_val val,
	putback_amt_val val,
	actor_uuid uuid, 
	status_uuid uuid, 
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE bom_material_composite (
	bom_material_composite_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	bom_material_uuid uuid NOT NULL,
	material_composite_uuid uuid NOT NULL,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE bom_material_index (
	bom_material_index_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	bom_material_uuid uuid,
	bom_material_composite_uuid uuid,
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
	in_unit varchar,
	in_opt_source_uuid uuid,
	in_opt_type_uuid uuid,
	in_opt_unit varchar,
	out_type_uuid uuid,
	out_unit varchar,
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


CREATE TABLE calculation_parameter_def_x (
    calculation_parameter_def_x_uuid uuid DEFAULT uuid_generate_v4 (),
 	parameter_def_uuid uuid NOT NULL,
 	calculation_def_uuid uuid NOT NULL,
 	add_date timestamptz NOT NULL DEFAULT NOW(),
 	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE calculation_stack (
	calculation_stack_id  serial primary key,
	stack_val val,
	add_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE condition (
	condition_uuid uuid DEFAULT uuid_generate_v4 (),
	workflow_uuid uuid NOT NULL,
	workflow_action_set_uuid uuid,
	condition_calculation_def_x_uuid uuid,
	in_val val,
	out_val val,
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
	experiment_type_uuid uuid,
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


CREATE TABLE experiment_type (
	experiment_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
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
	owner_uuid uuid,
	operator_uuid uuid,
	lab_uuid uuid,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE inventory_material (
	inventory_material_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar,
	inventory_uuid uuid NOT NULL,
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
	class_uuid uuid,
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


CREATE TABLE material_class (
    class_uuid uuid DEFAULT uuid_generate_v4 (),
    description varchar COLLATE "pg_catalog"."default" NOT NULL,
    actor_uuid uuid,
	status_uuid uuid,
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
	measure_def_uuid uuid,
	measure_type_uuid uuid,
	description varchar COLLATE "pg_catalog"."default",
	measure_value val,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);


CREATE TABLE measure_def (
	measure_def_uuid uuid DEFAULT uuid_generate_v4 (),
	default_measure_type_uuid uuid,
	description varchar COLLATE "pg_catalog"."default",
	default_measure_value val,
	property_def_uuid uuid,
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
	description varchar COLLATE "pg_catalog"."default" NOT NULL,
	experiment_uuid uuid NOT NULL,
	actor_uuid uuid,
	status_uuid uuid,
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
	type_uuid uuid,
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
	class_uuid uuid,
	valunit varchar,
	actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

CREATE TABLE property_class (
    class_uuid uuid DEFAULT uuid_generate_v4(),
    description varchar COLLATE "pg_catalog"."default",
    actor_uuid uuid,
	status_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

CREATE TABLE property_type (
    type_uuid uuid DEFAULT uuid_generate_v4(),
    description varchar COLLATE "pg_catalog"."default",
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
	workflow_action_set_uuid uuid,
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
	workflow_action_set_uuid uuid,
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
CREATE INDEX "ix_action_action_def" ON action (action_def_uuid);
CREATE INDEX "ix_action_workflow" ON action (workflow_uuid);
CREATE INDEX "ix_action_workflow_action_set" ON action (workflow_action_set_uuid);
CREATE INDEX "ix_action_ref_parameter" ON action (ref_parameter_uuid);
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
CREATE INDEX "ix_action_parameter_def_x_parameter_def" ON action_parameter_def_x (parameter_def_uuid);
CREATE INDEX "ix_action_parameter_def_x_action_def" ON action_parameter_def_x (action_def_uuid);
 CLUSTER action_parameter_def_x
 USING "pk_action_parameter_def_x_action_parameter_def_x_uuid";


ALTER TABLE actor
    ADD CONSTRAINT "pk_actor_uuid" PRIMARY KEY (actor_uuid);
CREATE UNIQUE INDEX "un_actor" ON actor (COALESCE(person_uuid, NULL), COALESCE(organization_uuid, NULL),
                                         COALESCE(systemtool_uuid, NULL));
CREATE INDEX "ix_actor_person" ON actor (person_uuid);
CREATE INDEX "ix_actor_organization" ON actor (organization_uuid);
CREATE INDEX "ix_actor_systemtool" ON actor (systemtool_uuid);
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
CREATE INDEX "ix_bom_material_inventory_material" ON bom_material (inventory_material_uuid);
CLUSTER bom_material
USING "pk_bom_material_bom_material_uuid";


ALTER TABLE bom_material_composite
	ADD CONSTRAINT "pk_bom_material_composite_bom_material_composite_uuid" PRIMARY KEY (bom_material_composite_uuid);
CREATE INDEX "ix_bom_material_composite_bom_material" ON bom_material_composite (bom_material_uuid);
CREATE INDEX "ix_bom_material_composite_material_composite" ON bom_material_composite (material_composite_uuid);
CLUSTER bom_material_composite
USING "pk_bom_material_composite_bom_material_composite_uuid";


ALTER TABLE bom_material_index
	ADD CONSTRAINT "pk_bom_material_index_bom_material_index_uuid" PRIMARY KEY (bom_material_index_uuid);
CREATE INDEX "ix_bom_material_index_bom_material" ON bom_material_index (bom_material_uuid);
CREATE INDEX "ix_bom_material_index_bom_material_composite" ON bom_material_index (bom_material_composite_uuid);
CLUSTER bom_material_index
USING "pk_bom_material_index_bom_material_index_uuid";


ALTER TABLE calculation
	ADD CONSTRAINT "pk_calculation_calculation_uuid" PRIMARY KEY (calculation_uuid),
		ADD CONSTRAINT "un_calculation" UNIQUE (calculation_def_uuid, in_val, in_opt_val);
CREATE INDEX "ix_calculation_calculation_def" ON calculation (calculation_def_uuid);
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


 ALTER TABLE calculation_parameter_def_x
 	ADD CONSTRAINT "pk_calculation_parameter_def_x_calculation_parameter_def_x_uuid" PRIMARY KEY (calculation_parameter_def_x_uuid),
 		ADD CONSTRAINT "un_calculation_parameter_def_x_def" UNIQUE (parameter_def_uuid, calculation_def_uuid);
CREATE INDEX "ix_calculation_parameter_def_x_parameter_def" ON calculation_parameter_def_x (parameter_def_uuid);
CREATE INDEX "ix_calculation_parameter_def_x_calculation_def" ON calculation_parameter_def_x (calculation_def_uuid);
 CLUSTER calculation_parameter_def_x
 USING "pk_calculation_parameter_def_x_calculation_parameter_def_x_uuid";


ALTER TABLE condition
	ADD CONSTRAINT "pk_condition_condition_uuid" PRIMARY KEY (condition_uuid);
CREATE INDEX "ix_condition_workflow" ON condition (workflow_uuid);
CREATE INDEX "ix_condition_workflow_action_set" ON condition (workflow_action_set_uuid);
CREATE INDEX "ix_condition_condition_calculation_def_x" ON condition (condition_calculation_def_x_uuid);
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
CREATE INDEX "ix_condition_calculation_def_x_condition_def" ON condition_calculation_def_x (condition_def_uuid);
CREATE INDEX "ix_condition_calculation_def_x_calculation_def" ON condition_calculation_def_x (calculation_def_uuid);
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
CREATE INDEX "ix_edocument_x_ref_edocument" ON edocument_x (ref_edocument_uuid);
CREATE INDEX "ix_edocument_x_edocument" ON edocument_x (edocument_uuid);
CLUSTER edocument_x
USING "pk_edocument_x_edocument_x_uuid";


ALTER TABLE experiment
	ADD CONSTRAINT "pk_experiment_experiment_uuid" PRIMARY KEY (experiment_uuid);
CREATE INDEX "ix_experiment_parent_path" ON experiment
USING GIST (parent_path);
CREATE INDEX "ix_experiment_parent_uuid" ON experiment (parent_uuid);
CLUSTER experiment
USING "pk_experiment_experiment_uuid";


ALTER TABLE experiment_type
	ADD CONSTRAINT "pk_experiment_type_experiment_type_uuid" PRIMARY KEY (experiment_type_uuid);
CLUSTER experiment_type
USING "pk_experiment_type_experiment_type_uuid";


ALTER TABLE experiment_workflow
	ADD CONSTRAINT "pk_experiment_workflow_uuid" PRIMARY KEY (experiment_workflow_uuid);
CREATE INDEX "ix_experiment_workflow_experiment" ON experiment_workflow (experiment_uuid);
CREATE INDEX "ix_experiment_workflow_workflow" ON experiment_workflow (workflow_uuid);
CLUSTER experiment_workflow
USING "pk_experiment_workflow_uuid";


ALTER TABLE inventory
	ADD CONSTRAINT "pk_inventory_inventory_uuid" PRIMARY KEY (inventory_uuid);
CLUSTER inventory
USING "pk_inventory_inventory_uuid";


ALTER TABLE inventory_material
	ADD CONSTRAINT "pk_inventory_material_inventory_material_uuid" PRIMARY KEY (inventory_material_uuid),
		ADD CONSTRAINT "un_inventory_material" UNIQUE (material_uuid, actor_uuid, add_date);
CREATE INDEX "ix_inventory_inventory" ON inventory_material (inventory_uuid);
CREATE INDEX "ix_inventory_material" ON inventory_material (material_uuid);
CLUSTER inventory_material
USING "pk_inventory_material_inventory_material_uuid";


ALTER TABLE material
	ADD CONSTRAINT "pk_material_material_uuid" PRIMARY KEY (material_uuid),
		ADD CONSTRAINT "un_material" UNIQUE (description);
CLUSTER material
USING "pk_material_material_uuid";


ALTER TABLE material_class
	ADD CONSTRAINT "pk_material_class_class_uuid" PRIMARY KEY (class_uuid),
		ADD CONSTRAINT "un_material_class" UNIQUE (description);
CLUSTER material_class
USING "pk_material_class_class_uuid";


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
CREATE INDEX "ix_material_refname_x_material" ON material_refname_x (material_uuid);
CREATE INDEX "ix_material_refname_x_material_refname" ON material_refname_x (material_refname_uuid);
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
CREATE INDEX "ix_material_x_material" ON material_x (material_uuid);
CREATE INDEX "ix_material_x_ref_material" ON material_x (ref_material_uuid);
CLUSTER material_x
USING "pk_material_x_material_x_uuid";


ALTER TABLE measure
	ADD CONSTRAINT "pk_measure_measure_uuid" PRIMARY KEY (measure_uuid),
		ADD CONSTRAINT "un_measure" UNIQUE (measure_uuid);
CREATE INDEX "ix_measure_measure_def" ON measure (measure_def_uuid);
CLUSTER measure
USING "pk_measure_measure_uuid";


ALTER TABLE measure_def
	ADD CONSTRAINT "pk_measure_def_measure_def_uuid" PRIMARY KEY (measure_def_uuid),
		ADD CONSTRAINT "un_measure_def" UNIQUE (measure_def_uuid);
CLUSTER measure_def
USING "pk_measure_def_measure_def_uuid";


ALTER TABLE measure_type
	ADD CONSTRAINT "pk_measure_type_measure_type_uuid" PRIMARY KEY (measure_type_uuid);
CLUSTER measure_type
USING "pk_measure_type_measure_type_uuid";


ALTER TABLE measure_x
	ADD CONSTRAINT "pk_measure_x_measure_x_uuid" PRIMARY KEY (measure_x_uuid),
		ADD CONSTRAINT "un_measure_x" UNIQUE (ref_measure_uuid, measure_uuid);
CREATE INDEX "ix_measure_x_ref_measure" ON measure_x (ref_measure_uuid);
CREATE INDEX "ix_measure_x_measure" ON measure_x (measure_uuid);
CLUSTER measure_x
USING "pk_measure_x_measure_x_uuid";


ALTER TABLE note
	ADD CONSTRAINT "pk_note_note_uuid" PRIMARY KEY (note_uuid);
CLUSTER note
USING "pk_note_note_uuid";


ALTER TABLE note_x
	ADD CONSTRAINT "pk_note_x_note_x_uuid" PRIMARY KEY (note_x_uuid),
		ADD CONSTRAINT "un_note_x" UNIQUE (ref_note_uuid, note_uuid);
CREATE INDEX "ix_note_x_ref_note" ON note_x (ref_note_uuid);
CREATE INDEX "ix_note_x_note" ON note_x (note_uuid);
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


ALTER TABLE outcome
	ADD CONSTRAINT "pk_outcome_outcome_uuid" PRIMARY KEY (outcome_uuid);
CREATE INDEX "ix_outcome_experiment_uuid" ON bom (experiment_uuid);
CLUSTER outcome
USING "pk_outcome_outcome_uuid";


ALTER TABLE parameter
	ADD CONSTRAINT "pk_parameter_parameter_uuid" PRIMARY KEY (parameter_uuid);
CREATE INDEX "ix_parameter_parameter_def" ON parameter (parameter_def_uuid);
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
CREATE INDEX "ix_parameter_x_ref_parameter" ON parameter_x (ref_parameter_uuid);
CREATE INDEX "ix_parameter_x_parameter" ON parameter_x (parameter_uuid);
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
CREATE INDEX "ix_property_property_def" ON property (property_def_uuid);
CLUSTER property
USING "pk_property_property_uuid";


ALTER TABLE property_def
	ADD CONSTRAINT "pk_property_def_property_def_uuid" PRIMARY KEY (property_def_uuid),
		ADD CONSTRAINT "un_property_def" UNIQUE (short_description);
CLUSTER property_def
USING "pk_property_def_property_def_uuid";


ALTER TABLE property_class
	ADD CONSTRAINT "pk_property_class_uuid" PRIMARY KEY (class_uuid);
CREATE INDEX "ix_property_class_uuid" ON property_class (class_uuid);
CLUSTER property_class
USING "pk_property_class_uuid";

ALTER TABLE property_type
	ADD CONSTRAINT "pk_property_type_uuid" PRIMARY KEY (type_uuid);
CREATE INDEX "ix_property_type_uuid" ON property_type (type_uuid);
CLUSTER property_type
USING "pk_property_type_uuid";

ALTER TABLE property_x
	ADD CONSTRAINT "pk_property_x_property_x_uuid" PRIMARY KEY (property_x_uuid),
		ADD CONSTRAINT "un_property_x_def" UNIQUE (material_uuid, property_uuid);
CREATE INDEX "ix_property_x_material" ON property_x (material_uuid);
CREATE INDEX "ix_property_x_property" ON property_x (property_uuid);
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
CREATE INDEX "ix_tag_x_ref_tag" ON tag_x (ref_tag_uuid);
CREATE INDEX "ix_tag_x_tag" ON tag_x (tag_uuid);
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
CREATE INDEX "ix_udf_x_ref_udf" ON udf_x (ref_udf_uuid);
CREATE INDEX "ix_udf_x_udf" ON udf_x (udf_uuid);
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
CREATE INDEX "ix_workflow_action_set_workflow" ON workflow_action_set (workflow_uuid);
CREATE INDEX "ix_workflow_action_set_action_def" ON workflow_action_set (action_def_uuid);
CREATE INDEX "ix_workflow_action_set_parameter_def" ON workflow_action_set (parameter_def_uuid);
CREATE INDEX "ix_workflow_action_set_calculation" ON workflow_action_set (calculation_uuid);
CLUSTER workflow_action_set
USING "pk_workflow_action_set_workflow_action_set_uuid";


ALTER TABLE workflow_object
	ADD CONSTRAINT "pk_workflow_object_workflow_object_uuid" PRIMARY KEY (workflow_object_uuid),
		ADD CONSTRAINT "un_workflow_object" UNIQUE (action_uuid, condition_uuid);
CREATE INDEX "ix_workflow_object_workflow" ON workflow_object (workflow_uuid);
CREATE INDEX "ix_workflow_object_workflow_action_set" ON workflow_object (workflow_action_set_uuid);
CREATE INDEX "ix_workflow_object_action" ON workflow_object (action_uuid);
CREATE INDEX "ix_workflow_object_condition" ON workflow_object (condition_uuid);
CLUSTER workflow_object
USING "pk_workflow_object_workflow_object_uuid";


ALTER TABLE workflow_state
	ADD CONSTRAINT "pk_workflow_state_workflow_state_uuid" PRIMARY KEY (workflow_state_uuid);
CLUSTER workflow_state
USING "pk_workflow_state_workflow_state_uuid";


ALTER TABLE workflow_step
	ADD CONSTRAINT "pk_workflow_step_workflow_step_uuid" PRIMARY KEY (workflow_step_uuid),
		ADD CONSTRAINT "un_workflow_step_workflow_step_uuid" UNIQUE (workflow_object_uuid, parent_uuid);
CREATE INDEX "ix_workflow_step_workflow" ON workflow_step (workflow_uuid);
CREATE INDEX "ix_workflow_step_workflow_action_set" ON workflow_step (workflow_action_set_uuid);
CREATE INDEX "ix_workflow_step_workflow_object" ON workflow_step (workflow_object_uuid);
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
 	        ADD CONSTRAINT fk_action_workflow_action_set_1 FOREIGN KEY (workflow_action_set_uuid) REFERENCES  workflow_action_set (workflow_action_set_uuid),
			    ADD CONSTRAINT fk_action_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),
				    ADD CONSTRAINT fk_action_source_material_1 FOREIGN KEY (source_material_uuid) REFERENCES bom_material_index (bom_material_index_uuid),
					    ADD CONSTRAINT fk_action_destination_material_1 FOREIGN KEY (destination_material_uuid) REFERENCES bom_material_index (bom_material_index_uuid),
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
		ADD CONSTRAINT fk_bom_material_inventory_material_1 FOREIGN KEY (inventory_material_uuid) REFERENCES inventory_material (inventory_material_uuid),
			ADD CONSTRAINT fk_bom_material_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
				ADD CONSTRAINT fk_bom_material_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE bom_material_composite
	ADD CONSTRAINT fk_bom_material_composite_bom_material_1 FOREIGN KEY (bom_material_uuid) REFERENCES bom_material (bom_material_uuid),
		ADD CONSTRAINT fk_bom_material_composite_material_composite_1 FOREIGN KEY (material_composite_uuid) REFERENCES material_composite (material_composite_uuid),
			ADD CONSTRAINT fk_bom_material_composite_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
				ADD CONSTRAINT fk_bom_material_composite_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE bom_material_index
	ADD CONSTRAINT fk_bom_material_index_bom_material_1 FOREIGN KEY (bom_material_uuid) REFERENCES bom_material (bom_material_uuid),
		ADD CONSTRAINT fk_bom_material_index_bom_material_composite_1 FOREIGN KEY (bom_material_composite_uuid) REFERENCES bom_material_composite (bom_material_composite_uuid);


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


ALTER TABLE calculation_parameter_def_x
 	ADD CONSTRAINT fk_calculation_parameter_def_x_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),
         ADD CONSTRAINT fk_calculation_parameter_def_x_parameter_def_1 FOREIGN KEY (parameter_def_uuid) REFERENCES parameter_def (parameter_def_uuid);


ALTER TABLE condition
	ADD CONSTRAINT fk_condition_condition_calculation_def_x_1 FOREIGN KEY (condition_calculation_def_x_uuid) REFERENCES condition_calculation_def_x (condition_calculation_def_x_uuid),
		ADD CONSTRAINT fk_condition_workflow_1 FOREIGN KEY (workflow_uuid) REFERENCES workflow (workflow_uuid),
	 	    ADD CONSTRAINT fk_condition_workflow_action_set_1 FOREIGN KEY (workflow_action_set_uuid) REFERENCES  workflow_action_set (workflow_action_set_uuid),
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


ALTER TABLE edocument
	ADD CONSTRAINT fk_edocument_doc_type_1 FOREIGN KEY (doc_type_uuid) REFERENCES type_def (type_def_uuid);


ALTER TABLE edocument_x
	ADD CONSTRAINT fk_edocument_x_edocument_1 FOREIGN KEY (edocument_uuid) REFERENCES edocument (edocument_uuid);


ALTER TABLE experiment
    ADD CONSTRAINT fk_experiment_experiment_type_1 FOREIGN KEY (experiment_type_uuid) REFERENCES experiment_type (experiment_type_uuid),
        ADD CONSTRAINT fk_experiment_actor_owner_1 FOREIGN KEY (owner_uuid) REFERENCES actor (actor_uuid),
		    ADD CONSTRAINT fk_experiment_actor_operator_1 FOREIGN KEY (operator_uuid) REFERENCES actor (actor_uuid),
			    ADD CONSTRAINT fk_experiment_actor_lab_1 FOREIGN KEY (lab_uuid) REFERENCES actor (actor_uuid),
				    ADD CONSTRAINT fk_experiment_experiment_1 FOREIGN KEY (parent_uuid) REFERENCES experiment (experiment_uuid),
					    ADD CONSTRAINT fk_experiment_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE experiment_type
	ADD CONSTRAINT fk_experiment_type_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
		ADD CONSTRAINT fk_experiment_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE experiment_workflow
	ADD CONSTRAINT fk_experiment_workflow_experiment_1 FOREIGN KEY (experiment_uuid) REFERENCES experiment (experiment_uuid),
		ADD CONSTRAINT fk_experiment_workflow_workflow_1 FOREIGN KEY (workflow_uuid) REFERENCES workflow (workflow_uuid);


ALTER TABLE inventory
	ADD CONSTRAINT fk_inventory_actor_owner_1 FOREIGN KEY (owner_uuid) REFERENCES actor (actor_uuid),
		ADD CONSTRAINT fk_inventory_actor_operator_1 FOREIGN KEY (operator_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_inventory_actor_lab_1 FOREIGN KEY (lab_uuid) REFERENCES actor (actor_uuid),
				ADD CONSTRAINT fk_inventory_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE inventory_material
    ADD CONSTRAINT fk_inventory_material_inventory_1 FOREIGN KEY (inventory_uuid) REFERENCES inventory (inventory_uuid),
	    ADD CONSTRAINT fk_inventory_material_material_1 FOREIGN KEY (material_uuid) REFERENCES material (material_uuid),
		    ADD CONSTRAINT fk_inventory_material_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			    ADD CONSTRAINT fk_inventory_material_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE material
    ADD CONSTRAINT fk_material_type_1 FOREIGN KEY (class_uuid) REFERENCES material_class (class_uuid),
        ADD CONSTRAINT fk_material_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	        ADD CONSTRAINT fk_material_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE material_composite
 ADD CONSTRAINT fk_material_composite_composite_1 FOREIGN KEY (composite_uuid) REFERENCES material (material_uuid),
	ADD CONSTRAINT fk_material_composite_component_1 FOREIGN KEY (component_uuid) REFERENCES material (material_uuid),
	    --ADD CONSTRAINT fk_material_component_class_1 FOREIGN KEY (class_uuid) REFERENCES material_class (class_uuid),
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
		ADD CONSTRAINT fk_measure_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
    		ADD CONSTRAINT fk_measure_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE measure_def
	ADD CONSTRAINT fk_measure_def_default_measure_type_1 FOREIGN KEY (default_measure_type_uuid) REFERENCES measure_type (measure_type_uuid),
		ADD CONSTRAINT fk_measure_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
        	ADD CONSTRAINT fk_measure_def_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);;


ALTER TABLE measure_x
	ADD CONSTRAINT fk_measure_x_measure_1 FOREIGN KEY (measure_uuid) REFERENCES measure (measure_uuid);


ALTER TABLE note
	ADD CONSTRAINT fk_note_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);


ALTER TABLE note_x
	ADD CONSTRAINT fk_note_x_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);


ALTER TABLE organization
	ADD CONSTRAINT fk_organization_organization_1 FOREIGN KEY (parent_uuid) REFERENCES organization (organization_uuid);


ALTER TABLE outcome
	ADD CONSTRAINT fk_outcome_experiment_1 FOREIGN KEY (experiment_uuid) REFERENCES experiment (experiment_uuid),
		ADD CONSTRAINT fk_outcome_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
			ADD CONSTRAINT fk_outcome_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


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
    ADD CONSTRAINT fk_property_type_1 FOREIGN KEY (type_uuid) REFERENCES property_type (type_uuid),
        ADD CONSTRAINT fk_property_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	        ADD CONSTRAINT fk_property_property_def_1 FOREIGN KEY (property_def_uuid) REFERENCES property_def (property_def_uuid),
		        ADD CONSTRAINT fk_property_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);

ALTER TABLE property_def
    ADD CONSTRAINT fk_property_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
        ADD CONSTRAINT fk_property_def_class_1 FOREIGN KEY (class_uuid) REFERENCES property_class (class_uuid),
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
						 	ADD CONSTRAINT fk_workflow_action_set_workflow_action_set_1 FOREIGN KEY (workflow_action_set_uuid) REFERENCES  workflow_action_set (workflow_action_set_uuid),ADD CONSTRAINT fk_workflow_action_set_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE workflow_object
	ADD CONSTRAINT fk_workflow_object_workflow_1 FOREIGN KEY (workflow_uuid) REFERENCES workflow (workflow_uuid),
        ADD CONSTRAINT fk_workflow_object_workflow_action_set_1 FOREIGN KEY (workflow_action_set_uuid) REFERENCES workflow_action_set (workflow_action_set_uuid),
		    ADD CONSTRAINT fk_workflow_object_action_1 FOREIGN KEY (action_uuid) REFERENCES action (action_uuid),
			    ADD CONSTRAINT fk_workflow_object_condition_1 FOREIGN KEY (condition_uuid) REFERENCES condition (condition_uuid),
				    ADD CONSTRAINT fk_workflow_object_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


ALTER TABLE workflow_state
	ADD CONSTRAINT fk_workflow_state_workflow_step_1 FOREIGN KEY (workflow_step_uuid) REFERENCES workflow_step (workflow_step_uuid),
		ADD CONSTRAINT fk_workflow_state_workflow_state_1 FOREIGN KEY (workflow_state_uuid) REFERENCES workflow_state (workflow_state_uuid);


ALTER TABLE workflow_step
	ADD CONSTRAINT fk_workflow_step_workflow_step_1 FOREIGN KEY (workflow_uuid) REFERENCES workflow (workflow_uuid),
        ADD CONSTRAINT fk_workflow_step_workflow_action_set_1 FOREIGN KEY (workflow_action_set_uuid) REFERENCES workflow_action_set (workflow_action_set_uuid),
		    ADD CONSTRAINT fk_workflow_step_object_1 FOREIGN KEY (workflow_object_uuid) REFERENCES workflow_object (workflow_object_uuid),
				ADD CONSTRAINT fk_workflow_step_parent_1 FOREIGN KEY (parent_uuid) REFERENCES workflow_step (workflow_step_uuid),
				    ADD CONSTRAINT fk_workflow_step_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid);


--======================================================================
--======================================================================
-- TABLE AND COLUMN COMMENTS
--======================================================================
--======================================================================
COMMENT ON TABLE action IS 'experiment, workflow actions (based on action_def)';
COMMENT ON COLUMN action.action_uuid IS 'PK of action table';
COMMENT ON COLUMN action.action_def_uuid IS 'FK to the action definition (action_def_uuid) in action_def table';
COMMENT ON COLUMN action.workflow_uuid IS 'FK to the workflow (workflow_uuid) defined in workflow table';
COMMENT ON COLUMN action.workflow_action_set_uuid IS 'FK to the workflow_action_set (workflow_action_set_uuid) defined in workflow_action_set table';
COMMENT ON COLUMN action.description IS 'description of the instantiated action';
COMMENT ON COLUMN action.start_date IS 'start date/time of the action';
COMMENT ON COLUMN action.end_date IS 'end date/time of the action';
COMMENT ON COLUMN action.duration IS 'duration (in some units) of the action';
COMMENT ON COLUMN action.repeating IS 'number of times the action repeats';
COMMENT ON COLUMN action.ref_parameter_uuid IS 'FK to [optional] parameter (parameter)';
COMMENT ON COLUMN action.calculation_def_uuid IS 'FK to [optional] calculation definition in calculation_def table';
COMMENT ON COLUMN action.source_material_uuid IS 'FK to [optional] source material in bom_material table';
COMMENT ON COLUMN action.destination_material_uuid IS 'FK to [optional] destination material in bom_material table';
COMMENT ON COLUMN action.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN action.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN action.add_date IS 'date/time record was created';
COMMENT ON COLUMN action.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE action_def IS 'name definition of for an action';
COMMENT ON COLUMN action_def.action_def_uuid IS 'PK of action_def table';
COMMENT ON COLUMN action_def.description IS 'description of the action; default name of instantiated action';
COMMENT ON COLUMN action_def.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN action_def.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN action_def.add_date IS 'date/time record was created';
COMMENT ON COLUMN action_def.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE action_parameter_def_x IS 'relates a parameter definition (parameter_def) with an action definition (action_def)';
COMMENT ON COLUMN action_parameter_def_x.action_parameter_def_x_uuid IS 'PK of action_parameter_def_x table';
COMMENT ON COLUMN action_parameter_def_x.parameter_def_uuid IS 'FK to parameter definition (parameter_def_uuid) in parameter_def table';
COMMENT ON COLUMN action_parameter_def_x.action_def_uuid IS 'FK to action definition (action_def_uuid) in action_def table';
COMMENT ON COLUMN action_parameter_def_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN action_parameter_def_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE actor IS 'references a person, organization and/or systemtool; can be a combination of the three';
COMMENT ON COLUMN actor.actor_uuid IS 'PK of actor table';
COMMENT ON COLUMN actor.person_uuid IS 'FK to person (person_uuid) in person table';
COMMENT ON COLUMN actor.organization_uuid IS 'FK to organization (organization_uuid) in organization table';
COMMENT ON COLUMN actor.systemtool_uuid IS 'FK to systemtool (systemtool_uuid) in systemtool table';
COMMENT ON COLUMN actor.description IS 'description of the actor. Can be different than the person, org or systemtool description';
COMMENT ON COLUMN actor.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN actor.add_date IS 'date/time record was created';
COMMENT ON COLUMN actor.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE actor_pref IS 'general container for actor-related preferences in key/value form';
COMMENT ON COLUMN actor_pref.actor_pref_uuid IS 'PK of actor_pref table';
COMMENT ON COLUMN actor_pref.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN actor_pref.pkey IS 'key [element] of a key/value pair';
COMMENT ON COLUMN actor_pref.pvalue IS 'value [element] of a key/value pair';
COMMENT ON COLUMN actor_pref.add_date IS 'date/time record was created';
COMMENT ON COLUMN actor_pref.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE bom IS 'bill of material (bom) container associated with an experiment';
COMMENT ON COLUMN bom.bom_uuid IS 'PK of bom table';
COMMENT ON COLUMN bom.experiment_uuid IS 'FK to experiment (experiment_uuid) in experiment table';
COMMENT ON COLUMN bom.description IS 'description of bom';
COMMENT ON COLUMN bom.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN bom.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN bom.add_date IS 'date/time record was created';
COMMENT ON COLUMN bom.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE bom_material IS '[singleton and parent] materials from inventory table, defined in material/material_composite tables';
COMMENT ON COLUMN bom_material.bom_material_uuid IS 'PK of bom_material table ';
COMMENT ON COLUMN bom_material.bom_uuid IS 'FK to bom (bom_uuid) in the bom table';
COMMENT ON COLUMN bom_material.description IS 'description of the bom material';
COMMENT ON COLUMN bom_material.inventory_material_uuid IS 'FK to inventory material (inventory_material_uuid) in the inventory_material table';
COMMENT ON COLUMN bom_material.alloc_amt_val IS 'the amount (val) of material allocated';
COMMENT ON COLUMN bom_material.used_amt_val IS 'the amount (val) of material used';
COMMENT ON COLUMN bom_material.putback_amt_val IS 'the amount (val) of material to be putback to inventory';
COMMENT ON COLUMN bom_material.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN bom_material.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN bom_material.add_date IS 'date/time record was created';
COMMENT ON COLUMN bom_material.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE bom_material_composite IS 'composite materials associated with bom_material as defined in material_composite table';
COMMENT ON COLUMN bom_material_composite.bom_material_composite_uuid IS 'PK of bom_material_composite table';
COMMENT ON COLUMN bom_material_composite.description IS 'description of bom material composite';
COMMENT ON COLUMN bom_material_composite.bom_material_uuid IS 'FK to parent material in bom_material';
COMMENT ON COLUMN bom_material_composite.material_composite_uuid IS 'FK to composite material definition in material_composite';
COMMENT ON COLUMN bom_material_composite.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN bom_material_composite.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN bom_material_composite.add_date IS 'date/time record was created';
COMMENT ON COLUMN bom_material_composite.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE bom_material_index IS 'combines (flattens) bom_material and bom_material_composite tables';
COMMENT ON COLUMN bom_material_index.bom_material_index_uuid IS 'PK of bom_material_index table';
COMMENT ON COLUMN bom_material_index.description IS 'copy of the bom_material, bom_material_composite descriptions respectively';
COMMENT ON COLUMN bom_material_index.bom_material_uuid IS 'FK to bom_material';
COMMENT ON COLUMN bom_material_index.bom_material_composite_uuid IS 'FK to bom_material_composite';
COMMENT ON COLUMN bom_material_index.add_date IS 'date/time record was created';
COMMENT ON COLUMN bom_material_index.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE calculation IS 'instantiated (executed, resultant) calculations';
COMMENT ON COLUMN calculation.calculation_uuid IS 'PK of calculation';
COMMENT ON COLUMN calculation.calculation_def_uuid IS 'FK to calculation_def';
COMMENT ON COLUMN calculation.calculation_alias_name IS 'alternative description of the calculation (than calculation_def)';
COMMENT ON COLUMN calculation.in_val IS 'value (val) of input paramater to the calculation; note: alternatively could be specified in a parameter record';
COMMENT ON COLUMN calculation.in_opt_val IS 'value (val) of secondary input paramater to the calculation; note: alternatively could be specified in a parameter record';
COMMENT ON COLUMN calculation.out_val IS 'value (val) of output (result) of calculation';
COMMENT ON COLUMN calculation.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN calculation.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN calculation.add_date IS 'date/time record was created';
COMMENT ON COLUMN calculation.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE calculation_class IS 'calculation categorization; not used yet';
COMMENT ON COLUMN calculation_class.calculation_class_uuid IS 'PK of calculation_class';
COMMENT ON COLUMN calculation_class.description IS 'description of the calculation class';
COMMENT ON COLUMN calculation_class.add_date IS 'date/time record was created';
COMMENT ON COLUMN calculation_class.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE calculation_def IS 'calculation specification: can refer to systemtool, executable or postgres operation';
COMMENT ON COLUMN calculation_def.calculation_def_uuid IS 'PK of calculation_def';
COMMENT ON COLUMN calculation_def.short_name IS 'short name of the calculation_def';
COMMENT ON COLUMN calculation_def.calc_definition IS 'the executable, service, math op, etc that gets executed to perform calculation';
COMMENT ON COLUMN calculation_def.systemtool_uuid IS 'FK to systemtool_uuid; if used';
COMMENT ON COLUMN calculation_def.description IS 'general (verbose) description of the calculation';
COMMENT ON COLUMN calculation_def.in_source_uuid IS 'reference (not FK) to a previous calculation (as input); currently used as source of prior calculation (like chemaxon standardize)';
COMMENT ON COLUMN calculation_def.in_type_uuid IS 'data type definition; FK to type_def';
COMMENT ON COLUMN calculation_def.in_unit IS 'unit (text) of input value';
COMMENT ON COLUMN calculation_def.in_opt_source_uuid IS 'secondary input source reference; see in_source_uuid';
COMMENT ON COLUMN calculation_def.in_opt_type_uuid IS 'data type definition of secondary input value; FK to type_def';
COMMENT ON COLUMN calculation_def.in_opt_unit IS 'unit (text) of secondary input value';
COMMENT ON COLUMN calculation_def.out_type_uuid IS 'data type definition of output value; FK to type_def';
COMMENT ON COLUMN calculation_def.out_unit IS 'unit (text) of output input value';
COMMENT ON COLUMN calculation_def.calculation_class_uuid IS 'FK to calculation_class; not used yet';
COMMENT ON COLUMN calculation_def.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN calculation_def.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN calculation_def.add_date IS 'date/time record was created';
COMMENT ON COLUMN calculation_def.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE calculation_eval IS 'reserved for future use: when calculation might be more like a state-machine';
COMMENT ON COLUMN calculation_eval.calculation_eval_id IS 'PK of calculation_eval';
COMMENT ON COLUMN calculation_eval.calculation_def_uuid IS 'FK to calculation_def';
COMMENT ON COLUMN calculation_eval.in_val IS 'value (val) of calculation input';
COMMENT ON COLUMN calculation_eval.in_opt_val IS 'value (val) of calculation secondary input';
COMMENT ON COLUMN calculation_eval.out_val IS 'value (val) of calculation output (result)';
COMMENT ON COLUMN calculation_eval.calculation_alias_name IS 'alias name to reference this calculation';
COMMENT ON COLUMN calculation_eval.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN calculation_eval.add_date IS 'date/time record was created';


COMMENT ON TABLE calculation_parameter_def_x IS 'cross table for joining calculation_def and parameter_def';
COMMENT ON COLUMN calculation_parameter_def_x.calculation_parameter_def_x_uuid IS 'PK of calculation_parameter_def_x';
COMMENT ON COLUMN calculation_parameter_def_x.parameter_def_uuid IS 'FK to parameter_def_uuid in parameter_def table';
COMMENT ON COLUMN calculation_parameter_def_x.calculation_def_uuid IS 'FK to calculation_def_uuid in calculation_def table';
COMMENT ON COLUMN calculation_parameter_def_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN calculation_parameter_def_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE calculation_stack IS 'temporary stack to push and pop values for a calculation; not currently used';
COMMENT ON COLUMN calculation_stack.calculation_stack_id IS 'index (pointer) into stack';
COMMENT ON COLUMN calculation_stack.stack_val IS 'value (val) on stack';
COMMENT ON COLUMN calculation_stack.add_date IS 'date/time record was created';


COMMENT ON TABLE condition IS 'workflow object of evaluated expression (calculation) and used as branch to one or more objects';
COMMENT ON COLUMN condition.condition_uuid IS 'PK of condition';
COMMENT ON COLUMN condition.workflow_uuid IS 'FK to the workflow (workflow_uuid) defined in workflow table';
COMMENT ON COLUMN condition.workflow_action_set_uuid IS 'FK to the workflow_action_set (workflow_action_set_uuid) defined in workflow_action_set table';
COMMENT ON COLUMN condition.condition_calculation_def_x_uuid IS 'FK to condition_calculation_def_x in order to bind condition calculation';
COMMENT ON COLUMN condition.in_val IS 'input value (val)';
COMMENT ON COLUMN condition.out_val IS 'output value (val)';
COMMENT ON COLUMN condition.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN condition.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN condition.add_date IS 'date/time record was created';
COMMENT ON COLUMN condition.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE condition_def IS 'definition (name) of condition';
COMMENT ON COLUMN condition_def.condition_def_uuid IS 'PK of condition_def';
COMMENT ON COLUMN condition_def.description IS 'description of condition_def';
COMMENT ON COLUMN condition_def.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN condition_def.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN condition_def.add_date IS 'date/time record was created';
COMMENT ON COLUMN condition_def.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE condition_calculation_def_x IS 'cross table for joining condition_def and calculation_def';
COMMENT ON COLUMN condition_calculation_def_x.condition_calculation_def_x_uuid IS 'PK of condition_calculation_def_x';
COMMENT ON COLUMN condition_calculation_def_x.condition_def_uuid IS 'FK to condition_def_uuid in condition_def table';
COMMENT ON COLUMN condition_calculation_def_x.calculation_def_uuid IS 'FK to calculation_def_uuid in calculation_def table';
COMMENT ON COLUMN condition_calculation_def_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN condition_calculation_def_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE condition_path IS 'routing connector (for a condition instance) to other workflow objects';
COMMENT ON COLUMN condition_path.condition_path_uuid IS 'PK of condition_path';
COMMENT ON COLUMN condition_path.condition_uuid IS 'FK to condition_uuid in condition';
COMMENT ON COLUMN condition_path.condition_out_val IS 'one (of possible many) value associated with condition connector';
COMMENT ON COLUMN condition_path.workflow_step_uuid IS 'FK to workflow_step_uuid in workflow_step';
COMMENT ON COLUMN condition_path.add_date IS 'date/time record was created';
COMMENT ON COLUMN condition_path.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE edocument IS 'container of all general files (edocuments); stored as blob';
COMMENT ON COLUMN edocument.edocument_uuid IS 'PK of edocument';
COMMENT ON COLUMN edocument.title IS 'title of document';
COMMENT ON COLUMN edocument.description IS 'general description of document';
COMMENT ON COLUMN edocument.filename IS 'filename associated if available';
COMMENT ON COLUMN edocument.source IS 'named source of document';
COMMENT ON COLUMN edocument.edocument IS 'file in blob (bytea) form';
COMMENT ON COLUMN edocument.doc_type_uuid IS 'FK to type_def';
COMMENT ON COLUMN edocument.doc_ver IS 'version of document, if any';
COMMENT ON COLUMN edocument.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN edocument.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN edocument.add_date IS 'date/time record was created';
COMMENT ON COLUMN edocument.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE edocument_x IS 'cross table to join an edocument to any other entity row';
COMMENT ON COLUMN edocument_x.edocument_x_uuid IS 'PK of edocument_x';
COMMENT ON COLUMN edocument_x.ref_edocument_uuid IS 'FK to uuid of reference entity';
COMMENT ON COLUMN edocument_x.edocument_uuid IS 'FK to edocument';
COMMENT ON COLUMN edocument_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN edocument_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE experiment IS 'named (instantiated) experiment';
COMMENT ON COLUMN experiment.experiment_uuid IS 'PK of experiment';
COMMENT ON COLUMN experiment.ref_uid IS 'reference back to an existing experiment';
COMMENT ON COLUMN experiment.description IS 'general description of experiment';
COMMENT ON COLUMN experiment.parent_uuid IS 'reference to a parent experiment (in experiment)';
COMMENT ON COLUMN experiment.parent_path IS 'path instantiation of parent';
COMMENT ON COLUMN experiment.owner_uuid IS 'accountable actor associated with experiment';
COMMENT ON COLUMN experiment.operator_uuid IS 'responsible actor associated with experiment';
COMMENT ON COLUMN experiment.lab_uuid IS 'organization experiment performed [in]';
COMMENT ON COLUMN experiment.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN experiment.add_date IS 'date/time record was created';
COMMENT ON COLUMN experiment.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE experiment_workflow IS 'instantiated (named) workflows associationed with experiment';
COMMENT ON COLUMN experiment_workflow.experiment_workflow_uuid IS 'PK of experiment_workflow';
COMMENT ON COLUMN experiment_workflow.experiment_workflow_seq IS 'order (int) of workflow(s); can be duplicates';
COMMENT ON COLUMN experiment_workflow.experiment_uuid IS 'FK to experiment_uuid in experiment';
COMMENT ON COLUMN experiment_workflow.workflow_uuid IS 'FK to workflow_uuid in workflow';
COMMENT ON COLUMN experiment_workflow.add_date IS 'date/time record was created';
COMMENT ON COLUMN experiment_workflow.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE inventory IS 'inventory that will contain [actual] materials';
COMMENT ON COLUMN inventory.inventory_uuid IS 'PF of inventory';
COMMENT ON COLUMN inventory.description IS 'general description of inventory';
COMMENT ON COLUMN inventory.owner_uuid IS 'who (actor) is accountable for the inventory';
COMMENT ON COLUMN inventory.operator_uuid IS 'who (actor) is responsible for the inventory';
COMMENT ON COLUMN inventory.lab_uuid IS 'who (actor) inventory belongs to';
COMMENT ON COLUMN inventory.actor_uuid IS 'who enter this inventory record';
COMMENT ON COLUMN inventory.status_uuid IS 'status of this inventory';
COMMENT ON COLUMN inventory.add_date IS 'add date of the inventory record';
COMMENT ON COLUMN inventory.mod_date IS 'mod date of the inventory record';


COMMENT ON TABLE inventory_material IS 'material (actual) in inventory';
COMMENT ON COLUMN inventory_material.inventory_material_uuid IS 'PK of inventory_material';
COMMENT ON COLUMN inventory_material.description IS 'general description of material in inventory';
COMMENT ON COLUMN inventory_material.inventory_uuid IS 'FK to inventory_uuid in inventory';
COMMENT ON COLUMN inventory_material.material_uuid IS 'FK to material_uuid in material';
COMMENT ON COLUMN inventory_material.part_no IS 'description of material part_no (order_no, sku, etc)';
COMMENT ON COLUMN inventory_material.onhand_amt IS 'value (val) of onhand amount';
COMMENT ON COLUMN inventory_material.expiration_date IS 'datetime of material expiration';
COMMENT ON COLUMN inventory_material.location IS 'description of material location';
COMMENT ON COLUMN inventory_material.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN inventory_material.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN inventory_material.add_date IS 'date/time record was created';
COMMENT ON COLUMN inventory_material.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE material IS 'all idealized materials (singleton, parent, component)';
COMMENT ON COLUMN material.material_uuid IS 'PK of material';
COMMENT ON COLUMN material.description IS 'general description of material; additional reference names are in material_refname';
COMMENT ON COLUMN material.consumable IS 'consumable designation (boolean); e.g. chemical (true) v labware (false) ';
COMMENT ON COLUMN material.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN material.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN material.add_date IS 'date/time record was created';
COMMENT ON COLUMN material.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE material_composite IS 'materials that are components of composites (chemical or labware)';
COMMENT ON COLUMN material_composite.material_composite_uuid IS 'PK of material_composite';
COMMENT ON COLUMN material_composite.composite_uuid IS 'FK to material_uuid in material representing parent';
COMMENT ON COLUMN material_composite.component_uuid IS 'FK to material_uuid in material represention component';
COMMENT ON COLUMN material_composite.addressable IS 'is component addressable (boolean), in a workflow. e.g. plate well would be true';
COMMENT ON COLUMN material_composite.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN material_composite.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN material_composite.add_date IS 'date/time record was created';
COMMENT ON COLUMN material_composite.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE material_x IS 'cross table join a material to another entity row';
COMMENT ON COLUMN material_x.material_x_uuid IS 'PK of material_x';
COMMENT ON COLUMN material_x.material_uuid IS 'FK to material_uuid in material';
COMMENT ON COLUMN material_x.ref_material_uuid IS 'FK to reference entity';
COMMENT ON COLUMN material_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN material_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE material_refname IS 'alternative standard reference name for a material';
COMMENT ON COLUMN material_refname.material_refname_uuid IS 'PK of material_refname';
COMMENT ON COLUMN material_refname.description IS 'reference name';
COMMENT ON COLUMN material_refname.blob_value IS 'file representation of reference (e.g. image); this is optional, better done through edocuument';
COMMENT ON COLUMN material_refname.blob_type IS 'description of file type; optional';
COMMENT ON COLUMN material_refname.material_refname_def_uuid IS 'FK to material_refname_def_uuid in material_refname_def';
COMMENT ON COLUMN material_refname.reference IS 'description of standard';
COMMENT ON COLUMN material_refname.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN material_refname.add_date IS 'date/time record was created';
COMMENT ON COLUMN material_refname.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE material_refname_def IS 'material reference name standards (e.g. SMILES, InChI, ';
COMMENT ON COLUMN material_refname_def.material_refname_def_uuid IS 'PK of material_refname_def';
COMMENT ON COLUMN material_refname_def.description IS 'description of reference';
COMMENT ON COLUMN material_refname_def.add_date IS 'date/time record was created';
COMMENT ON COLUMN material_refname_def.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE material_refname_x IS 'cross table of material and refname';
COMMENT ON COLUMN material_refname_x.material_refname_x_uuid IS 'PK of material_refname_x';
COMMENT ON COLUMN material_refname_x.material_uuid IS 'FK to material_uuid in material';
COMMENT ON COLUMN material_refname_x.material_refname_uuid IS 'FK to material_refname_uuid in material_refname_uuid';
COMMENT ON COLUMN material_refname_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN material_refname_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE material_type IS 'categorization of material';
COMMENT ON COLUMN material_type.material_type_uuid IS 'PK of material_type_uuid';
COMMENT ON COLUMN material_type.description IS 'material type description';
COMMENT ON COLUMN material_type.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN material_type.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN material_type.add_date IS 'date/time record was created';
COMMENT ON COLUMN material_type.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE material_type_x IS 'cross table for material and material_type';
COMMENT ON COLUMN material_type_x.material_type_x_uuid IS 'PK of material_type_x';
COMMENT ON COLUMN material_type_x.material_uuid IS 'FK to material_uuid in material';
COMMENT ON COLUMN material_type_x.material_type_uuid IS 'FK to material_type_uuid in material_type';
COMMENT ON COLUMN material_type_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN material_type_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE measure IS 'instantiation of a measure (observable); can be associated with any entity';
COMMENT ON COLUMN measure.measure_uuid IS 'PK of measure';
COMMENT ON COLUMN measure.measure_type_uuid IS 'FK to measure_type_uuid in measure_type';
COMMENT ON COLUMN measure.description IS 'description of measure';
COMMENT ON COLUMN measure.measure_value IS 'value (val) of measure';
COMMENT ON COLUMN measure.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN measure.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN measure.add_date IS 'date/time record was created';
COMMENT ON COLUMN measure.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE measure_def IS 'definition of a measure (name, property def, default value';
COMMENT ON COLUMN measure_def.measure_def_uuid IS 'PK of measure_def';
COMMENT ON COLUMN measure_def.default_measure_type_uuid IS 'FK to measure_type_uuid in measure_type';
COMMENT ON COLUMN measure_def.description IS 'description of measure definition';
COMMENT ON COLUMN measure_def.default_measure_value IS 'default value (val)';
COMMENT ON COLUMN measure_def.property_def_uuid IS 'FK to property_def_uuid in property_def';
COMMENT ON COLUMN measure_def.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN measure_def.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN measure_def.add_date IS 'date/time record was created';
COMMENT ON COLUMN measure_def.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE measure_type IS 'categorization of measure type';
COMMENT ON COLUMN measure_type.measure_type_uuid IS 'PK of measure_type';
COMMENT ON COLUMN measure_type.description IS 'description of measure type';
COMMENT ON COLUMN measure_type.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN measure_type.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN measure_type.add_date IS 'date/time record was created';
COMMENT ON COLUMN measure_type.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE measure_x IS 'cross table for measure and associated entity row';
COMMENT ON COLUMN measure_x.measure_x_uuid IS 'PK of measure_x';
COMMENT ON COLUMN measure_x.ref_measure_uuid IS 'FK to associated entity row (uuid)';
COMMENT ON COLUMN measure_x.measure_uuid IS 'FK to measure_uuid in measure';
COMMENT ON COLUMN measure_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN measure_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE note IS 'note text; can be associate to any entity';
COMMENT ON COLUMN note.note_uuid IS 'PK of note';
COMMENT ON COLUMN note.notetext IS 'note text';
COMMENT ON COLUMN note.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN note.add_date IS 'date/time record was created';
COMMENT ON COLUMN note.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE note_x IS 'cross table for note and associated entity row';
COMMENT ON COLUMN note_x.note_x_uuid IS 'PK of note_x';
COMMENT ON COLUMN note_x.ref_note_uuid IS 'FK to associated entity uuid';
COMMENT ON COLUMN note_x.note_uuid IS 'FK to note_uuid in note';
COMMENT ON COLUMN note_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN note_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE organization IS 'organization information for person and system tool; can be component of actor';
COMMENT ON COLUMN organization.organization_uuid IS 'uuid for this organization record';
COMMENT ON COLUMN organization.parent_uuid IS 'reference to parent organization; uses [internal] organization_uuid';
COMMENT ON COLUMN organization.parent_path IS 'allows a searchable, navigable tree structure; currently not being used';
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


COMMENT ON TABLE outcome IS 'container of experiment measures (observables)';
COMMENT ON COLUMN outcome.outcome_uuid IS 'PK of outcome';
COMMENT ON COLUMN outcome.description IS 'description of outcome [container]';
COMMENT ON COLUMN outcome.experiment_uuid IS 'FK to experiment_uuid in experiment';
COMMENT ON COLUMN outcome.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN outcome.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN outcome.add_date IS 'date/time record was created';
COMMENT ON COLUMN outcome.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE parameter IS 'instantiation of a parameter (input to a calculation)';
COMMENT ON COLUMN parameter.parameter_uuid IS 'PK of parameter';
COMMENT ON COLUMN parameter.parameter_def_uuid IS 'FK to parameter_def_uuid in parameter_def';
COMMENT ON COLUMN parameter.parameter_val IS 'value (val) of parameter';
COMMENT ON COLUMN parameter.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN parameter.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN parameter.add_date IS 'date/time record was created';
COMMENT ON COLUMN parameter.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE parameter_def IS 'template for a parameter';
COMMENT ON COLUMN parameter_def.parameter_def_uuid IS 'PK of parameter_def';
COMMENT ON COLUMN parameter_def.description IS 'description of the parameter definition';
COMMENT ON COLUMN parameter_def.default_val IS 'default value (val)';
COMMENT ON COLUMN parameter_def.required IS 'required designation (boolean)';
COMMENT ON COLUMN parameter_def.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN parameter_def.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN parameter_def.add_date IS 'date/time record was created';
COMMENT ON COLUMN parameter_def.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE parameter_x IS 'cross table for parameter and associated entity';
COMMENT ON COLUMN parameter_x.parameter_x_uuid IS 'PK of parameter_x';
COMMENT ON COLUMN parameter_x.ref_parameter_uuid IS 'FK to associated entity uuid';
COMMENT ON COLUMN parameter_x.parameter_uuid IS 'FK to parameter_uuid in parameter';
COMMENT ON COLUMN parameter_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN parameter_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE person IS 'individual (human) actor';
COMMENT ON COLUMN person.person_uuid IS 'PK of person';
COMMENT ON COLUMN person.first_name IS 'first name';
COMMENT ON COLUMN person.last_name IS 'last name';
COMMENT ON COLUMN person.middle_name IS 'middle name';
COMMENT ON COLUMN person.address1 IS 'address 1';
COMMENT ON COLUMN person.address2 IS 'addres 2';
COMMENT ON COLUMN person.city IS 'city or town';
COMMENT ON COLUMN person.state_province IS 'state or province abbreviation';
COMMENT ON COLUMN person.zip IS 'zipcode';
COMMENT ON COLUMN person.country IS 'country designation';
COMMENT ON COLUMN person.phone IS 'phone number';
COMMENT ON COLUMN person.email IS 'email address';
COMMENT ON COLUMN person.title IS 'title';
COMMENT ON COLUMN person.suffix IS 'suffix';
COMMENT ON COLUMN person.organization_uuid IS 'FK to organization_uuid in organization';
COMMENT ON COLUMN person.add_date IS 'date/time record was created';
COMMENT ON COLUMN person.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE property IS 'instantiation of property; characterization and measure of a material';
COMMENT ON COLUMN property.property_uuid IS 'PK of property';
COMMENT ON COLUMN property.property_def_uuid IS 'FK to property_def_uuid in property_def';
COMMENT ON COLUMN property.property_val IS 'value (val)';
COMMENT ON COLUMN property.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN property.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN property.add_date IS 'date/time record was created';
COMMENT ON COLUMN property.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE property_def IS 'property definition; characterization and measure of a material';
COMMENT ON COLUMN property_def.property_def_uuid IS 'PK of property_def';
COMMENT ON COLUMN property_def.description IS 'description of property';
COMMENT ON COLUMN property_def.short_description IS 'short description';
COMMENT ON COLUMN property_def.val_type_uuid IS 'definition of value type; FK to type_def_uuid in type_def';
COMMENT ON COLUMN property_def.valunit IS 'value unit';
COMMENT ON COLUMN property_def.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN property_def.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN property_def.add_date IS 'date/time record was created';
COMMENT ON COLUMN property_def.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE property_x IS 'cross table for property and associated entity';
COMMENT ON COLUMN property_x.property_x_uuid IS 'PK of property_x';
COMMENT ON COLUMN property_x.material_uuid IS 'FK to material_uuid in material';
COMMENT ON COLUMN property_x.property_uuid IS 'FK to property_uuid in property';
COMMENT ON COLUMN property_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN property_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE status IS 'description of status for association to any entity (row); each entity has FK to status';
COMMENT ON COLUMN status.status_uuid IS 'PK of status';
COMMENT ON COLUMN status.description IS 'description of status';
COMMENT ON COLUMN status.add_date IS 'date/time record was created';
COMMENT ON COLUMN status.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE systemtool IS 'system, software or tool (as actor)';
COMMENT ON COLUMN systemtool.systemtool_uuid IS 'PK of systemtool';
COMMENT ON COLUMN systemtool.systemtool_name IS 'short description of systemtool';
COMMENT ON COLUMN systemtool.description IS 'general description of systemtool';
COMMENT ON COLUMN systemtool.systemtool_type_uuid IS 'FK to systemtool_type_uuid in systemtool_type';
COMMENT ON COLUMN systemtool.vendor_organization_uuid IS 'FK to organization_uuid in organization designating associate vendor, manuf';
COMMENT ON COLUMN systemtool.model IS 'tool model number';
COMMENT ON COLUMN systemtool.serial IS 'tool serial number';
COMMENT ON COLUMN systemtool.ver IS 'tool version number (esp useful for software)';
COMMENT ON COLUMN systemtool.add_date IS 'date/time record was created';
COMMENT ON COLUMN systemtool.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE systemtool_type IS 'categorization of systemtool';
COMMENT ON COLUMN systemtool_type.systemtool_type_uuid IS 'PK of systemtool_type';
COMMENT ON COLUMN systemtool_type.description IS 'description of systemtool type';
COMMENT ON COLUMN systemtool_type.add_date IS 'date/time record was created';
COMMENT ON COLUMN systemtool_type.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE sys_audit IS 'system table for auditing all targeted table activities';
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


COMMENT ON TABLE tag IS 'tag (short text) that can be associated with any entity (row)';
COMMENT ON COLUMN tag.tag_uuid IS 'PK of tag';
COMMENT ON COLUMN tag.tag_type_uuid IS 'FK to tag_type_uuid in tag_type';
COMMENT ON COLUMN tag.display_text IS 'tag name; short';
COMMENT ON COLUMN tag.description IS 'tag description: any length, not displayed';
COMMENT ON COLUMN tag.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN tag.add_date IS 'date/time record was created';
COMMENT ON COLUMN tag.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE tag_type IS 'categorization of tag';
COMMENT ON COLUMN tag_type.tag_type_uuid IS 'PK of tag_type';
COMMENT ON COLUMN tag_type.type IS 'description of tag type, a way to reuse tag names and target specific entities or actions';
COMMENT ON COLUMN tag_type.description IS 'description of tag type';
COMMENT ON COLUMN tag_type.add_date IS 'date/time record was created';
COMMENT ON COLUMN tag_type.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE tag_x IS 'cross table for tag and associated entity (row)';
COMMENT ON COLUMN tag_x.tag_x_uuid IS 'PK of tag_x';
COMMENT ON COLUMN tag_x.ref_tag_uuid IS 'FK to associated entity row (uuid)';
COMMENT ON COLUMN tag_x.tag_uuid IS 'FK to tag_uuid in tag';
COMMENT ON COLUMN tag_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN tag_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE type_def IS 'categorization of value (val) types; this is required as part of val';
COMMENT ON COLUMN type_def.type_def_uuid IS 'PK of type_def';
COMMENT ON COLUMN type_def.category IS 'category of type (current, data and file)';
COMMENT ON COLUMN type_def.description IS 'description of type';
COMMENT ON COLUMN type_def.add_date IS 'date/time record was created';
COMMENT ON COLUMN type_def.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE udf IS 'instantiation of a user defined field (udf)';
COMMENT ON COLUMN udf.udf_uuid IS 'PK of udf';
COMMENT ON COLUMN udf.udf_def_uuid IS 'FK to udf_def_uuid in udf_def';
COMMENT ON COLUMN udf.udf_val IS 'value (val)';
COMMENT ON COLUMN udf.add_date IS 'date/time record was created';
COMMENT ON COLUMN udf.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE udf_def IS 'user define field (udf) definition';
COMMENT ON COLUMN udf_def.udf_def_uuid IS 'PK of udf_def';
COMMENT ON COLUMN udf_def.description IS 'description of udf';
COMMENT ON COLUMN udf_def.val_type_uuid IS 'FK to type_def_uuid in type_def';
COMMENT ON COLUMN udf_def.unit IS 'unit of value';
COMMENT ON COLUMN udf_def.add_date IS 'date/time record was created';
COMMENT ON COLUMN udf_def.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE udf_x IS 'cross table for udf and associated entity (row)';
COMMENT ON COLUMN udf_x.udf_x_uuid IS 'PK of udf_x';
COMMENT ON COLUMN udf_x.ref_udf_uuid IS 'FK to uuid in associated entity';
COMMENT ON COLUMN udf_x.udf_uuid IS 'FK to udf_uuid in udf';
COMMENT ON COLUMN udf_x.add_date IS 'date/time record was created';
COMMENT ON COLUMN udf_x.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE workflow IS 'container for [experiment] actions';
COMMENT ON COLUMN workflow.workflow_uuid IS 'PK of workflow';
COMMENT ON COLUMN workflow.workflow_type_uuid IS 'FK to workflow_type_uuid in workflow_type';
COMMENT ON COLUMN workflow.description IS 'description of workflow';
COMMENT ON COLUMN workflow.parent_uuid IS 'reference to parent workflow';
COMMENT ON COLUMN workflow.parent_path IS 'navigable path';
COMMENT ON COLUMN workflow.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN workflow.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN workflow.add_date IS 'date/time record was created';
COMMENT ON COLUMN workflow.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE workflow_action_set IS 'definition of an action set (same) actions operating over a variety of parameters and/or materials';
COMMENT ON COLUMN workflow_action_set.workflow_action_set_uuid IS 'PK of workflow_action_set';
COMMENT ON COLUMN workflow_action_set.description IS 'description of action set';
COMMENT ON COLUMN workflow_action_set.workflow_uuid IS 'FK to workflow_uuid in workflow';
COMMENT ON COLUMN workflow_action_set.action_def_uuid IS 'FK to action_def_uuid in action_def';
COMMENT ON COLUMN workflow_action_set.start_date IS 'start date of action(s)';
COMMENT ON COLUMN workflow_action_set.end_date IS 'end date of action(s)';
COMMENT ON COLUMN workflow_action_set.duration IS 'duration of action(s)';
COMMENT ON COLUMN workflow_action_set.repeating IS 'repeat # of action(s)';
COMMENT ON COLUMN workflow_action_set.parameter_def_uuid IS 'FK to parameter_def_uuid in parameter';
COMMENT ON COLUMN workflow_action_set.parameter_val IS 'parameter value (val)';
COMMENT ON COLUMN workflow_action_set.calculation_uuid IS 'optional reference FK to calculation_uuid in calculation';
COMMENT ON COLUMN workflow_action_set.source_material_uuid IS 'FK to bom_material_index_uuid in bom_material_index';
COMMENT ON COLUMN workflow_action_set.destination_material_uuid IS 'FK to bom_material_index_uuid in bom_material_index';
COMMENT ON COLUMN workflow_action_set.actor_uuid IS 'FK to actor associated with record';
COMMENT ON COLUMN workflow_action_set.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN workflow_action_set.add_date IS 'date/time record was created';
COMMENT ON COLUMN workflow_action_set.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE workflow_object IS 'abstracted workflow objects (currently action and condition); e.g. the rectangles and diamonds in a workflow diagram';
COMMENT ON COLUMN workflow_object.workflow_object_uuid IS 'PK of workflow_object';
COMMENT ON COLUMN workflow_object.workflow_uuid IS 'FK to workflow_uuid in workflow';
COMMENT ON COLUMN workflow_object.workflow_action_set_uuid IS 'FK to workflow_action_set_uuid in workflow_action_set';
COMMENT ON COLUMN workflow_object.action_uuid IS 'FK to action_uuid in action';
COMMENT ON COLUMN workflow_object.condition_uuid IS 'FK to condition_uuid in condition';
COMMENT ON COLUMN workflow_object.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN workflow_object.add_date IS 'date/time record was created';
COMMENT ON COLUMN workflow_object.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE workflow_state IS 'collection of workflow states; not currently used';
COMMENT ON COLUMN workflow_state.workflow_state_uuid IS 'PK of workflow_state';
COMMENT ON COLUMN workflow_state.workflow_step_uuid IS 'FK to workflow_step_uuid in workflow_step';
COMMENT ON COLUMN workflow_state.add_date IS 'date/time record was created';
COMMENT ON COLUMN workflow_state.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE workflow_step IS 'designation of workflow_object paths or connections; i.e. the paths between objects in a workflow diagram';
COMMENT ON COLUMN workflow_step.workflow_step_uuid IS 'PK of workflow_step';
COMMENT ON COLUMN workflow_step.workflow_uuid IS 'FK to workflow_uuid in workflow';
COMMENT ON COLUMN workflow_step.workflow_action_set_uuid IS 'FK to workflow_action_set_uuid in workflow_action_set';
COMMENT ON COLUMN workflow_step.parent_uuid IS 'uuid of parent workflow_object; i.e. proceeding workflow_object; or tail in a head-tail path';
COMMENT ON COLUMN workflow_step.parent_path IS 'navigable path';
COMMENT ON COLUMN workflow_step.workflow_object_uuid IS 'uuid of workflow_object (head in head-tail path)';
COMMENT ON COLUMN workflow_step.status_uuid IS 'FK to status associated with record';
COMMENT ON COLUMN workflow_step.add_date IS 'date/time record was created';
COMMENT ON COLUMN workflow_step.mod_date IS 'date/time record was last modified';


COMMENT ON TABLE workflow_type IS 'categorization of workflow';
COMMENT ON COLUMN workflow_type.workflow_type_uuid IS 'PK of workflow_type';
COMMENT ON COLUMN workflow_type.description IS 'description of workflow type';
COMMENT ON COLUMN workflow_type.add_date IS 'date/time record was created';
COMMENT ON COLUMN workflow_type.mod_date IS 'date/time record was last modified';