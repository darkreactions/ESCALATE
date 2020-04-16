/*
Name:					prod_create_tables
Parameters:		none
Returns:			
Author:				G. Cattabriga
Date:					2020.01.23
Description:	create the production tables, primary keys and comments for ESCALATEv3
Notes:				triggers, foreign keys and other constraints are in other sql files
							20200123: remove the measure and measure type entities - measure will be part 
												of the originating entity
							20200130: add measure, measure_type back in, and also add the xref table 
												measure_x
*/

-- DROP SCHEMA dev cascade;
-- CREATE SCHEMA dev;
 --=====================================
 -- EXTENSIONS 
 --=====================================
-- CREATE EXTENSION if not exists ltree with schema dev;
-- REATE EXTENSION if not exists tablefunc with schema dev;
-- CREATE EXTENSION if not exists "uuid-ossp" with schema dev;
-- set search_path = dev, public;
 
 --=====================================
 -- DROP TYPES 
 --=====================================
DROP TYPE IF EXISTS val_type cascade; 
DROP TYPE IF EXISTS val cascade; 

 --=====================================
 -- DROP TABLES 
 --=====================================
DROP TABLE IF EXISTS organization cascade; 
DROP TABLE IF EXISTS person cascade; 
DROP TABLE IF EXISTS systemtool cascade;
DROP TABLE IF EXISTS systemtool_type cascade;
DROP TABLE IF EXISTS actor cascade;
DROP TABLE IF EXISTS actor_pref cascade;
DROP TABLE IF EXISTS material cascade;
DROP TABLE IF EXISTS material_type cascade;
DROP TABLE IF EXISTS material_type_x cascade;
DROP TABLE IF EXISTS material_refname cascade;
DROP TABLE IF EXISTS material_refname_x cascade;
DROP TABLE IF EXISTS material_refname_type cascade;
DROP TABLE IF EXISTS calculation_class cascade;
DROP TABLE IF EXISTS calculation_def cascade;
DROP TABLE IF EXISTS calculation cascade;
DROP TABLE IF EXISTS calculation_eval cascade;
DROP TABLE IF EXISTS inventory cascade;
DROP TABLE IF EXISTS measure cascade;
DROP TABLE IF EXISTS measure_x cascade;
DROP TABLE IF EXISTS measure_type cascade;
DROP TABLE IF EXISTS note cascade;
DROP TABLE IF EXISTS edocument cascade;
DROP TABLE IF EXISTS edocument_x cascade;
DROP TABLE IF EXISTS tag cascade;
DROP TABLE IF EXISTS tag_x cascade;
DROP TABLE IF EXISTS tag_type cascade;
DROP TABLE IF EXISTS status cascade;
DROP TABLE IF EXISTS escalate_change_log cascade;
DROP TABLE IF EXISTS escalate_version cascade;

 --=====================================
 -- CREATE DATA TYPES 
 --=====================================
-- define (enumerate) the value types where hierachy is seperated by '_' with simple data types (int, num, text) as single phrase; treat 'array' like a fifo stack
CREATE TYPE val_type AS ENUM ('int', 'array_int', 'num', 'array_num', 'text', 'array_text', 'blob_text', 'blob_pdf', 'blob_svg', 'blob_jpg', 'blob_png', 'blob_xrd');

CREATE TYPE val AS (
	v_type 	val_type,
	v_unit varchar,
	v_text varchar,
	v_text_array varchar[],
	v_int int8,
	v_int_array int8[],
	v_num double precision,
	v_num_array double precision[],
	v_blob bytea,
	v_source_uuid uuid
);

 --=====================================
 -- CREATE TABLES 
 --=====================================
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
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for person
---------------------------------------
CREATE TABLE person (
  person_uuid uuid DEFAULT uuid_generate_v4 (),	
  firstname varchar COLLATE "pg_catalog"."default",
  lastname varchar COLLATE "pg_catalog"."default" NOT NULL,
  middlename varchar COLLATE "pg_catalog"."default",
  address1 varchar COLLATE "pg_catalog"."default",
  address2 varchar COLLATE "pg_catalog"."default",
  city varchar COLLATE "pg_catalog"."default",
  stateprovince char(3) COLLATE "pg_catalog"."default",
  zip varchar COLLATE "pg_catalog"."default",
  country varchar COLLATE "pg_catalog"."default",	
  phone varchar COLLATE "pg_catalog"."default",
  email varchar COLLATE "pg_catalog"."default",
  title VARCHAR COLLATE "pg_catalog"."default",
  suffix varchar COLLATE "pg_catalog"."default",
	organization_uuid uuid,
  note_uuid uuid,
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
  ver varchar COLLATE "pg_catalog"."default",
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for systemtool_type
---------------------------------------
CREATE TABLE systemtool_type (
  systemtool_type_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  note_uuid uuid,
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
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for actor_pref
---------------------------------------
CREATE TABLE actor_pref (
  actor_pref_uuid uuid DEFAULT uuid_generate_v4 (),
  actor_uuid uuid,
	pkey varchar COLLATE "pg_catalog"."default",
  pvalue varchar COLLATE "pg_catalog"."default",
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material
---------------------------------------
CREATE TABLE material (
  material_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default" NOT NULL,
  parent_uuid uuid,
	parent_path ltree,	
--  "material_type_x_uuid" int8,
--  actor_uuid int8,
--  "descriptor_uuid" int8,
--  "alt_material_refname_uuid" int8,
	status_uuid uuid,
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_type
---------------------------------------
CREATE TABLE material_type (
  material_type_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_type_x
---------------------------------------
CREATE TABLE material_type_x (
  material_type_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_material_uuid uuid,
  material_type_uuid uuid,
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
  material_refname_type_uuid uuid,
  reference varchar COLLATE "pg_catalog"."default",
	status_uuid uuid,
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_refname_x
---------------------------------------
CREATE TABLE material_refname_x (
  material_refname_x_uuid uuid DEFAULT uuid_generate_v4 (),
	material_uuid uuid,
  material_refname_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_refname_type
---------------------------------------
CREATE TABLE material_refname_type (
	material_refname_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	note_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for calculation_class
---------------------------------------
CREATE TABLE calculation_class (
	calculation_class_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for calculation_def
---------------------------------------
CREATE TABLE calculation_def (
	calculation_def_uuid uuid DEFAULT uuid_generate_v4 (),
  short_name varchar COLLATE "pg_catalog"."default",
	calc_definition varchar COLLATE "pg_catalog"."default",
	systemtool_uuid uuid,
	description varchar COLLATE "pg_catalog"."default",
	in_source varchar,
	in_type val_type,
	in_opt_source varchar,
	in_opt_type val_type,
	out_type val_type,
	calculation_class_uuid uuid,
	actor_uuid uuid, 
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for calculation
---------------------------------------
CREATE TABLE calculation (
	calculation_uuid uuid DEFAULT uuid_generate_v4 (),
  calculation_def_uuid uuid,
	calculation_alias_name varchar,
	in_val val,
	in_opt_val val,
	out_val val,
	create_date timestamptz,
  status_uuid uuid,
	actor_uuid uuid,
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);


---------------------------------------
-- Table structure for calculation_eval
-- internal use only
---------------------------------------
CREATE TABLE calculation_eval(
	calculation_eval_id serial8,
  calculation_def_uuid uuid,
	in_val val, 
	in_opt_val val,
	out_val val, 
	calculation_alias_name varchar,
	actor_uuid uuid, 
	create_date timestamptz NOT NULL DEFAULT NOW()
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
	onhand_amt  DOUBLE PRECISION,
	unit varchar,
	-- measure_uuid int8,
  create_date timestamptz,
  expiration_date timestamptz DEFAULT NULL,
  inventory_location varchar(255) COLLATE "pg_catalog"."default",
	status_uuid uuid,
	edocument_uuid uuid,
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure
---------------------------------------
CREATE TABLE measure (
	measure_uuid uuid DEFAULT uuid_generate_v4 (),
	measure_type_uuid uuid,
	amount val,
	unit varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
	edocument_uuid uuid,
	note_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure_x
---------------------------------------
CREATE TABLE measure_x (
  measure_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_measure_uuid uuid,
  measure_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure_type
---------------------------------------
CREATE TABLE measure_type (
	measure_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	note_uuid uuid,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for note
---------------------------------------
CREATE TABLE note (
	note_uuid uuid DEFAULT uuid_generate_v4 (),
  notetext varchar COLLATE "pg_catalog"."default",
  edocument_uuid uuid,
	actor_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for document
-- ----------------------------
CREATE TABLE edocument (
	edocument_uuid uuid DEFAULT uuid_generate_v4 (),
  edocument_title varchar COLLATE "pg_catalog"."default",
  description varchar COLLATE "pg_catalog"."default",
	edocument_filename varchar COLLATE "pg_catalog"."default",
	edocument_source varchar COLLATE "pg_catalog"."default",
  edocument bytea,
  edoc_type val_type,
  ver varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for edocument_x
---------------------------------------
CREATE TABLE edocument_x (
  edocument_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_edocument_uuid uuid,
  edocument_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for tag
-- ----------------------------
CREATE TABLE tag (
	tag_uuid uuid DEFAULT uuid_generate_v4 (),
	tag_type_uuid uuid,
	short_description varchar(16) COLLATE "pg_catalog"."default",
  description varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for tag_x
---------------------------------------
CREATE TABLE tag_x (
  tag_x_uuid uuid DEFAULT uuid_generate_v4 (),
	ref_tag_uuid uuid,
  tag_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for tag_type
-- ----------------------------
CREATE TABLE tag_type (
	tag_type_uuid uuid DEFAULT uuid_generate_v4 (),
	short_description varchar(32) COLLATE "pg_catalog"."default",
  description varchar COLLATE "pg_catalog"."default",
	actor_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for status
-- ----------------------------
CREATE TABLE status (
  status_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);


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


--=====================================
-- KEYS
--=====================================
ALTER TABLE organization 
	ADD CONSTRAINT "pk_organization_organization_uuid" PRIMARY KEY (organization_uuid);
	CREATE INDEX "ix_organization_parent_path" ON organization USING GIST (parent_path);
	CREATE INDEX "ix_organization_parent_uuid" ON organization (parent_uuid);
CLUSTER organization USING "pk_organization_organization_uuid";

ALTER TABLE person 
ADD CONSTRAINT "pk_person_person_uuid" PRIMARY KEY (person_uuid);
CLUSTER person USING "pk_person_person_uuid";

ALTER TABLE systemtool 
	ADD CONSTRAINT "pk_systemtool_systemtool_uuid" PRIMARY KEY (systemtool_uuid),
	ADD CONSTRAINT "un_systemtool" UNIQUE (systemtool_name, systemtool_type_uuid, vendor_organization_uuid, ver);
CLUSTER systemtool USING "pk_systemtool_systemtool_uuid";

ALTER TABLE systemtool_type 
	ADD CONSTRAINT "pk_systemtool_systemtool_type_uuid" PRIMARY KEY (systemtool_type_uuid);
CLUSTER systemtool_type USING "pk_systemtool_systemtool_type_uuid";

ALTER TABLE actor 
	ADD CONSTRAINT "pk_actor_uuid" PRIMARY KEY (actor_uuid);
	CREATE UNIQUE INDEX "un_actor" ON actor (coalesce(person_uuid,null), coalesce(organization_uuid,null), coalesce(systemtool_uuid,null) );
CLUSTER actor USING "pk_actor_uuid";

ALTER TABLE actor_pref 
	ADD CONSTRAINT "pk_actor_pref_uuid" PRIMARY KEY (actor_pref_uuid);
CLUSTER actor_pref USING "pk_actor_pref_uuid";

ALTER TABLE material ADD 
	CONSTRAINT "pk_material_material_uuid" PRIMARY KEY (material_uuid);
	CREATE INDEX "ix_material_parent_path" ON material USING GIST (parent_path);
	CREATE INDEX "ix_material_parent_uuid" ON material (parent_uuid);
CLUSTER material USING "pk_material_material_uuid";

ALTER TABLE material_type ADD 
	CONSTRAINT "pk_material_type_material_type_uuid" PRIMARY KEY (material_type_uuid);
CLUSTER material_type USING "pk_material_type_material_type_uuid";

ALTER TABLE material_type_x 
	ADD CONSTRAINT "pk_material_type_x_material_type_x_uuid" PRIMARY KEY (material_type_x_uuid),
	ADD CONSTRAINT "un_material_type_x" UNIQUE (ref_material_uuid, material_type_uuid);
CLUSTER material_type_x USING "pk_material_type_x_material_type_x_uuid";

ALTER TABLE material_refname 
	ADD CONSTRAINT "pk_material_refname_material_refname_uuid" PRIMARY KEY (material_refname_uuid),
	ADD CONSTRAINT "un_material_refname" UNIQUE (description, material_refname_type_uuid);
CLUSTER material_refname USING "pk_material_refname_material_refname_uuid";

ALTER TABLE material_refname_x 
	ADD CONSTRAINT "pk_material_refname_x_material_refname_x_uuid" PRIMARY KEY (material_refname_x_uuid),
	ADD CONSTRAINT "un_material_refname_x" UNIQUE (material_uuid, material_refname_uuid);
CLUSTER material_refname_x USING "pk_material_refname_x_material_refname_x_uuid";

ALTER TABLE material_refname_type 
	ADD CONSTRAINT "pk_material_refname_type_material_refname_type_uuid" PRIMARY KEY (material_refname_type_uuid);
CLUSTER material_refname_type USING "pk_material_refname_type_material_refname_type_uuid";

ALTER TABLE calculation_class ADD 
	CONSTRAINT "pk_calculation_class_calculation_class_uuid" PRIMARY KEY (calculation_class_uuid);
CLUSTER calculation_class USING "pk_calculation_class_calculation_class_uuid";

ALTER TABLE calculation_def 
	ADD CONSTRAINT "pk_calculation_calculation_def_uuid" PRIMARY KEY (calculation_def_uuid),
	ADD CONSTRAINT "un_calculation_def" UNIQUE (actor_uuid, short_name, calc_definition);	
CLUSTER calculation_def USING "pk_calculation_calculation_def_uuid";

ALTER TABLE calculation
	ADD CONSTRAINT "pk_calculation_calculation_uuid" PRIMARY KEY (calculation_uuid),
	ADD CONSTRAINT "un_calculation" UNIQUE (calculation_def_uuid, in_val, in_opt_val);
CLUSTER calculation USING "pk_calculation_calculation_uuid";

ALTER TABLE calculation_eval
	ADD CONSTRAINT "pk_calculation_eval_calculation_eval_id" PRIMARY KEY (calculation_eval_id),
	ADD CONSTRAINT "un_calculation_eval" UNIQUE (calculation_def_uuid, in_val, in_opt_val);
CLUSTER calculation_eval USING "pk_calculation_eval_calculation_eval_id";

ALTER TABLE inventory 
	ADD CONSTRAINT "pk_inventory_inventory_uuid" PRIMARY KEY (inventory_uuid),
	ADD CONSTRAINT "un_inventory" UNIQUE (material_uuid, actor_uuid, create_date);
CLUSTER inventory USING "pk_inventory_inventory_uuid";

ALTER TABLE measure 
	ADD CONSTRAINT "pk_measure_measure_uuid" PRIMARY KEY (measure_uuid),
	ADD CONSTRAINT "un_measure" UNIQUE (measure_uuid);
 CLUSTER measure USING "pk_measure_measure_uuid";

ALTER TABLE measure_x 
	ADD CONSTRAINT "pk_measure_x_measure_x_uuid" PRIMARY KEY (measure_x_uuid),
	ADD CONSTRAINT "un_measure_x" UNIQUE (ref_measure_uuid, measure_uuid);
CLUSTER measure_x USING "pk_measure_x_measure_x_uuid";

 ALTER TABLE measure_type ADD 
	CONSTRAINT "pk_measure_type_measure_type_uuid" PRIMARY KEY (measure_type_uuid);
 CLUSTER measure_type USING "pk_measure_type_measure_type_uuid";

ALTER TABLE note ADD 
	CONSTRAINT "pk_note_note_uuid" PRIMARY KEY (note_uuid);
CLUSTER note USING "pk_note_note_uuid";

ALTER TABLE edocument ADD 
	CONSTRAINT "pk_edocument_edocument_uuid" PRIMARY KEY (edocument_uuid);
CLUSTER edocument USING "pk_edocument_edocument_uuid";

ALTER TABLE edocument_x 
	ADD CONSTRAINT "pk_edocument_x_edocument_x_uuid" PRIMARY KEY (edocument_x_uuid),
	ADD CONSTRAINT "un_edocument_x" UNIQUE (ref_edocument_uuid, edocument_uuid);
CLUSTER edocument_x USING "pk_edocument_x_edocument_x_uuid";

ALTER TABLE tag 
	ADD CONSTRAINT "pk_tag_tag_uuid" PRIMARY KEY (tag_uuid),
	ADD CONSTRAINT "un_tag" UNIQUE (tag_uuid);;
CLUSTER tag USING "pk_tag_tag_uuid";

ALTER TABLE tag_x 
	ADD CONSTRAINT "pk_tag_x_tag_x_uuid" PRIMARY KEY (tag_x_uuid),
	ADD CONSTRAINT "un_tag_x" UNIQUE (ref_tag_uuid, tag_uuid);
CLUSTER tag_x USING "pk_tag_x_tag_x_uuid";

ALTER TABLE tag_type ADD 
	CONSTRAINT "pk_tag_tag_type_uuid" PRIMARY KEY (tag_type_uuid);
CLUSTER tag_type USING "pk_tag_tag_type_uuid";

ALTER TABLE status ADD 
	CONSTRAINT "pk_status_status_uuid" PRIMARY KEY (status_uuid);
CLUSTER status USING "pk_status_status_uuid";

ALTER TABLE escalate_change_log 
	ADD CONSTRAINT "pk_escalate_change_log_uuid" PRIMARY KEY (change_log_uuid);
CLUSTER escalate_change_log USING "pk_escalate_change_log_uuid";

ALTER TABLE escalate_version 
	ADD CONSTRAINT "pk_escalate_version_uuid" PRIMARY KEY (ver_uuid),
	ADD CONSTRAINT "un_escalate_version" UNIQUE (ver_uuid, short_name);
CLUSTER escalate_version USING "pk_escalate_version_uuid";

--=====================================
-- FOREIGN KEYS
--=====================================
-- ALTER TABLE organization DROP CONSTRAINT fk_organization_note_1;
ALTER TABLE organization 
	ADD CONSTRAINT fk_organization_organization_1 FOREIGN KEY (parent_uuid) REFERENCES organization (organization_uuid),
	ADD CONSTRAINT fk_organization_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE person DROP CONSTRAINT fk_person_organization_1, 
--	DROP CONSTRAINT fk_person_note_1;
ALTER TABLE person 
	ADD CONSTRAINT fk_person_organization_1 FOREIGN KEY (organization_uuid) REFERENCES organization (organization_uuid),
	ADD CONSTRAINT fk_person_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE systemtool DROP CONSTRAINT fk_systemtool_systemtool_type_1,
--	DROP CONSTRAINT fk_systemtool_organization_1,
--	DROP CONSTRAINT fk_systemtool_note_1;
ALTER TABLE systemtool 
	ADD CONSTRAINT fk_systemtool_systemtool_type_1 FOREIGN KEY (systemtool_type_uuid) REFERENCES systemtool_type (systemtool_type_uuid),
	ADD CONSTRAINT fk_systemtool_vendor_1 FOREIGN KEY (vendor_organization_uuid) REFERENCES organization (organization_uuid),
	ADD CONSTRAINT fk_systemtool_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE systemtool_type DROP CONSTRAINT fk_systemtool_type_note_1;
ALTER TABLE systemtool_type 
	ADD CONSTRAINT fk_systemtool_type_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE actor DROP CONSTRAINT fk_actor_person_1, 
--	DROP CONSTRAINT fk_actor_organization_1, 
--	DROP CONSTRAINT fk_actor_systemtool_1,
--	DROP CONSTRAINT fk_actor_note_1;
ALTER TABLE actor 
	ADD CONSTRAINT fk_actor_person_1 FOREIGN KEY (person_uuid) REFERENCES person (person_uuid),
	ADD CONSTRAINT fk_actor_organization_1 FOREIGN KEY (organization_uuid) REFERENCES organization (organization_uuid),
	ADD CONSTRAINT fk_actor_systemtool_1 FOREIGN KEY (systemtool_uuid) REFERENCES systemtool (systemtool_uuid),
	ADD CONSTRAINT fk_actor_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid),	
	ADD CONSTRAINT fk_actor_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);
	
ALTER TABLE actor_pref 
	ADD CONSTRAINT fk_actor_pref_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_actor_pref_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);
	
-- ALTER TABLE material DROP CONSTRAINT fk_material_actor_1,
--	DROP CONSTRAINT fk_material_material_1;
--	DROP CONSTRAINT fk_material_note_1;
ALTER TABLE material 
--	ADD CONSTRAINT fk_material_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_material_material_1 FOREIGN KEY (parent_uuid) REFERENCES material (material_uuid),
	ADD CONSTRAINT fk_material_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid),	
	ADD CONSTRAINT fk_material_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);
	
-- ALTER TABLE material_type DROP CONSTRAINT fk_material_type_note_1;
ALTER TABLE material_type 
	ADD CONSTRAINT fk_material_type_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

--ALTER TABLE material_type_x DROP CONSTRAINT fk_material_type_x_material_1, 
--	DROP CONSTRAINT fk_material_type_x_material_type_1;
ALTER TABLE material_type_x 
	ADD CONSTRAINT fk_material_type_x_material_1 FOREIGN KEY (ref_material_uuid) REFERENCES material (material_uuid),
	ADD CONSTRAINT fk_material_type_x_material_type_1 FOREIGN KEY (material_type_uuid) REFERENCES material_type (material_type_uuid);

--ALTER TABLE material_refname DROP CONSTRAINT fk_alt_material_refname_material_1, 
--	DROP CONSTRAINT fk_alt_material_refname_note_1;
ALTER TABLE material_refname 
	ADD CONSTRAINT fk_material_refname_type_1 FOREIGN KEY (material_refname_type_uuid) REFERENCES material_refname_type (material_refname_type_uuid),	
	ADD CONSTRAINT fk_material_refname_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid),	
	ADD CONSTRAINT fk_material_refname_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

--ALTER TABLE material_refname_x DROP CONSTRAINT fk_material_refname_x_material_1, 
--	DROP CONSTRAINT fk_material_refname_x_material_type_1;
ALTER TABLE material_refname_x 
	ADD CONSTRAINT fk_material_refname_x_material_1 FOREIGN KEY (material_uuid) REFERENCES material (material_uuid),
	ADD CONSTRAINT fk_material_refname_x_material_refname_1 FOREIGN KEY (material_refname_uuid) REFERENCES material_refname (material_refname_uuid);

-- ALTER TABLE calculation_class DROP CONSTRAINT fk_calculation_class_note_1;
ALTER TABLE calculation_class 
	ADD CONSTRAINT fk_calculation_class_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);
	
-- ALTER TABLE calculation_def DROP CONSTRAINT fk_calculation_def_note_1,
-- DROP CONSTRAINT fk_calculation_def_actor_1, 
-- DROP CONSTRAINT fk_calculation_def_calculation_class_1,
-- DROP CONSTRAINT fk_calculation_def_systemtool_1;
ALTER TABLE calculation_def 
	ADD CONSTRAINT fk_calculation_def_calculation_class_1 FOREIGN KEY (calculation_class_uuid) REFERENCES calculation_class (calculation_class_uuid),	
	ADD CONSTRAINT fk_calculation_def_systemtool_1 FOREIGN KEY (systemtool_uuid) REFERENCES systemtool (systemtool_uuid),	
	ADD CONSTRAINT fk_calculation_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_calculation_def_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);	

-- ALTER TABLE calculation DROP CONSTRAINT fk_calculation_material_1, 
-- DROP CONSTRAINT fk_calculation_actor_1, 
-- DROP CONSTRAINT fk_calculation_status_1,
-- DROP CONSTRAINT fk_calculation_note_1;
ALTER TABLE calculation 
--	ADD CONSTRAINT fk_calculation_material_refname_1 FOREIGN KEY (material_refname_description_in, material_refname_type_in) REFERENCES material_refname (description, material_refname_type),
	ADD CONSTRAINT fk_calculation_calculation_def_1 FOREIGN KEY (calculation_def_uuid) REFERENCES calculation_def (calculation_def_uuid),	
	ADD CONSTRAINT fk_calculation_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),	
	ADD CONSTRAINT fk_calculation_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid),	
	ADD CONSTRAINT fk_calculation_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

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
	ADD CONSTRAINT fk_inventory_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid),	
	ADD CONSTRAINT fk_inventory_edocument_1 FOREIGN KEY (edocument_uuid) REFERENCES edocument (edocument_uuid),		
	ADD CONSTRAINT fk_inventory_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

ALTER TABLE measure 
	ADD CONSTRAINT fk_measure_measure_type_1 FOREIGN KEY (measure_type_uuid) REFERENCES measure_type (measure_type_uuid),
	ADD CONSTRAINT fk_measure_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_measure_edocument_1 FOREIGN KEY (edocument_uuid) REFERENCES edocument (edocument_uuid),
	ADD CONSTRAINT fk_measure_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

 -- ALTER TABLE measure_type DROP CONSTRAINT fk_measure_type_note_1;
 ALTER TABLE measure_type 
	ADD CONSTRAINT fk_measure_type_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE measure_x DROP CONSTRAINT fk_measure_x_measure_1;
ALTER TABLE measure_x 
	ADD CONSTRAINT fk_measure_x_measure_1 FOREIGN KEY (ref_measure_uuid) REFERENCES measure (measure_uuid);

-- ALTER TABLE note DROP CONSTRAINT fk_note_edocument_1;
ALTER TABLE note 
	ADD CONSTRAINT fk_note_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_note_edocument_1 FOREIGN KEY (edocument_uuid) REFERENCES edocument (edocument_uuid);	

-- ALTER TABLE edocument_x ADD CONSTRAINT "pk_edocument_x_edocument_x_uuid" PRIMARY KEY (edocument_x_uuid), ADD CONSTRAINT "un_edocument_x" UNIQUE (ref_uuid, edocument_uuid);
ALTER TABLE edocument_x
	ADD CONSTRAINT fk_edocument_x_edocument_1 FOREIGN KEY (edocument_uuid) REFERENCES edocument (edocument_uuid);

--ALTER TABLE tag DROP CONSTRAINT fk_tag_tag_type_1, 
--	DROP CONSTRAINT fk_tag_note_1;
ALTER TABLE tag 
	ADD CONSTRAINT fk_tag_tag_type_1 FOREIGN KEY (tag_type_uuid) REFERENCES tag_type (tag_type_uuid),
	ADD CONSTRAINT fk_tag_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_tag_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE tag ADD CONSTRAINT "pk_tag_tag_uuid" PRIMARY KEY (tag_uuid);
ALTER TABLE tag_x 
	ADD CONSTRAINT fk_tag_x_tag_1 FOREIGN KEY (tag_uuid) REFERENCES tag (tag_uuid);


--=====================================
-- TRIGGERS
--=====================================
---------------------------------------
-- set_timestamp trigger
---------------------------------------
-- drop trigger_set_timestamp triggers
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name FROM information_schema.columns
        WHERE column_name = 'mod_date' and table_schema='dev'
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS set_timestamp ON %I',t);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- create trigger_set_timestamp triggers
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name FROM information_schema.columns
        WHERE column_name = 'mod_date' and table_schema='dev'
    LOOP
        EXECUTE format('CREATE TRIGGER set_timestamp
                        BEFORE UPDATE ON %I
                        FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp()',
                        t);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

/*
-- test the update TRIGGER
CREATE TRIGGER set_timestamp
	BEFORE UPDATE ON organization
	FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp();	
	
UPDATE organization 
	SET city = 'Cambridge',
	state = 'MA',
	zip = '02142'
 WHERE name = 'ChemAxon' RETURNING *;
 
 UPDATE actor 
	SET organization_uuid = 4
 WHERE organization_uuid = 4 RETURNING *;
 */



--=====================================
-- TABLE AND COLUMN COMMENTS
--=====================================
COMMENT ON TABLE organization IS 'organization information for ESCALATE person and system tool; can be component of actor';
	COMMENT ON COLUMN organization.organization_uuid is 'uuid for this organization record';
	COMMENT ON COLUMN organization.parent_uuid is 'reference to parent organization; uses [internal] organization_uuid';
	COMMENT ON COLUMN organization.parent_path is 'allows a searchable, naviagatable tree structure; currently not being used';
  COMMENT ON COLUMN organization.description is 'free test describing the organization';
  COMMENT ON COLUMN organization.full_name is 'long (full) version of the org name';
  COMMENT ON COLUMN organization.short_name is 'short version of the org name; using acronym, initialism, etc';
  COMMENT ON COLUMN organization.address1 is 'first line of organization address';
  COMMENT ON COLUMN organization.address2 is 'second line of organization address';
  COMMENT ON COLUMN organization.city is 'city of the organization';
  COMMENT ON COLUMN organization.state_province is 'state or province (abbreviation)';
  COMMENT ON COLUMN organization.zip is 'zip or province code';
  COMMENT ON COLUMN organization.country is 'country code';	
  COMMENT ON COLUMN organization.website_url is 'organization url';
  COMMENT ON COLUMN organization.phone is 'primary organization phone';
  COMMENT ON COLUMN organization.note_uuid is 'organization note; reference to note object which can be free text or blob';
  COMMENT ON COLUMN organization.add_date is 'date this record added';
  COMMENT ON COLUMN organization.mod_date is 'date this record updated';

--=====================================
-- VIEWS
--=====================================
-- view of status table (simple)
CREATE OR REPLACE VIEW vw_status AS 
SELECT status_uuid, description, add_date, mod_date from status;

-- view of note; links to edocument and actor
CREATE OR REPLACE VIEW vw_edocument AS 
select doc.edocument_uuid, doc.edocument_title, doc.description as edocument_description, 
		doc.edocument_filename, doc.edocument_source, doc.edoc_type as edocument_type, act.actor_uuid, act.description as actor_description  from edocument doc
left join actor act on doc.actor_uuid = act.actor_uuid;


-- view of note; links to edocument and actor
CREATE OR REPLACE VIEW vw_note AS 
select nt.note_uuid, nt.notetext, nt.add_date, nt.mod_date, ed.edocument_uuid, ed.edocument_title, ed.description as edocument_description, 
		ed.edocument_filename, ed.edocument_source, ed.edoc_type as edocument_type, act.actor_uuid, act.description as actor_description  from note nt 
left join edocument ed on nt.edocument_uuid = ed.edocument_uuid 
left join actor act on nt.actor_uuid = act.actor_uuid;


-- view of tag_type; links to actor
CREATE OR REPLACE VIEW vw_tag_type AS 
select tt.tag_type_uuid, tt.short_description, tt.description, tt.actor_uuid, act.description as actor_description, tt.add_date, tt.mod_date from tag_type tt
left join actor act on tt.actor_uuid = act.actor_uuid;


-- view of tag; links to tag_type, actor and note
CREATE OR REPLACE VIEW vw_tag AS 
select tg.tag_uuid, tg.short_description as tag_short_descr, tg.description as tag_description, tg.add_date, tg.mod_date,
			tg.tag_type_uuid, tt.short_description as tag_type_short_descr, tt.description as tag_type_description,
			act.actor_uuid, act.description as actor_description, nt.note_uuid, nt.notetext
				from tag tg 
left join tag_type tt on tg.tag_type_uuid = tt.tag_type_uuid 
left join actor act on tg.actor_uuid = act.actor_uuid 
left join note nt on tg.note_uuid = nt.note_uuid;


-- view of person; links to organization and note
CREATE OR REPLACE VIEW vw_person AS 
select per.person_uuid, per.firstname, per.lastname, per.middlename, per.address1, per.address2, per.city, per.stateprovince, per.zip, per.country, per.phone, per.email, per.title, per.suffix, 
				per.add_date, per.mod_date, org.organization_uuid, org.full_name, nt.note_uuid, nt.notetext,
				ed.edocument_uuid, ed.description as edocument_descr, tag.tag_uuid, tag.short_description as tag_short_descr
				from person per 
left join organization org on per.organization_uuid = org.organization_uuid
left join note nt on per.note_uuid = nt.note_uuid
left join tag_x tx on per.person_uuid = tx.ref_tag_uuid
left join tag on tx.tag_uuid = tag.tag_uuid
left join edocument_x edx on per.person_uuid = edx.ref_edocument_uuid
left join edocument ed on edx.edocument_uuid = ed.edocument_uuid;


-- view of organization; links to parent organization and note
CREATE OR REPLACE VIEW vw_organization AS 
select org.organization_uuid, org.description, org.full_name, org.short_name, org.address1, org.address2, org.city, org.state_province, org.zip, org.country, org.website_url, org.phone, org.parent_uuid, orgp.full_name as parent_org_full_name, 
				org.add_date, org.mod_date, nt.note_uuid, nt.notetext,
				ed.edocument_uuid, ed.description as edocument_descr, tag.tag_uuid, tag.short_description as tag_short_descr 
				from organization org			
left join organization orgp on org.parent_uuid = orgp.organization_uuid 
left join note nt on org.note_uuid = nt.note_uuid
left join tag_x tx on org.organization_uuid = tx.ref_tag_uuid
left join tag on tx.tag_uuid = tag.tag_uuid
left join edocument_x edx on org.organization_uuid = edx.ref_edocument_uuid
left join edocument ed on edx.edocument_uuid = ed.edocument_uuid;


-- integrated view of inventory; joins measure (amounts of material
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
CASE
		WHEN per.person_uuid IS NOT NULL THEN
		CAST ( concat ( per.lastname, ', ', per.firstname ) AS VARCHAR ) 
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
	LEFT JOIN organization vorg on st.vendor_organization_uuid = vorg.organization_uuid
	LEFT JOIN note nt ON act.note_uuid = nt.note_uuid
	left join edocument_x edx on act.actor_uuid = edx.ref_edocument_uuid
	left join edocument ed on edx.edocument_uuid = ed.edocument_uuid
	LEFT JOIN status sts ON act.status_uuid = sts.status_uuid;
		
-- get most recent version of a systemtool in raw format
-- return all columns from the systemtool table
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
		MAX ( st.ver ) AS ver
	FROM
		systemtool st 
	WHERE
		st.systemtool_name IS NOT NULL 
		AND st.ver IS NOT NULL 
	GROUP BY
		st.systemtool_name,
		st.systemtool_type_uuid,
		st.vendor_organization_uuid,
		st.note_uuid
	) mrs ON stl.systemtool_name = mrs.systemtool_name 
	AND stl.systemtool_type_uuid = mrs.systemtool_type_uuid 
	AND stl.vendor_organization_uuid = mrs.vendor_organization_uuid
	AND stl.ver = mrs.ver;
	
-- get most recent version of a systemtool
-- return all columns from actor table
CREATE OR REPLACE VIEW vw_latest_systemtool AS 
SELECT
	vst.systemtool_uuid, vst.systemtool_name, vst.description, vst.vendor_organization_uuid, org.full_name organization_fullname, vst.systemtool_type_uuid, stt.description as systemtool_type_description, 
	vst.model, vst.serial, vst.ver, act.actor_uuid, act.description as actor_description, vst.add_date, vst.mod_date 
FROM
	vw_latest_systemtool_raw vst
	LEFT JOIN actor act ON vst.systemtool_uuid = act.systemtool_uuid
	LEFT JOIN organization org on vst.vendor_organization_uuid = org.organization_uuid
	LEFT JOIN note nt on vst.note_uuid = nt.note_uuid
	LEFT JOIN systemtool_type stt on vst.systemtool_type_uuid = stt.systemtool_type_uuid;


-- get the calculation_def and associated actor
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
	stt.description as systemtool_type_description,
	org.short_name as systemtool_vendor_organization,
	st.ver as systemtool_version,
	mdd.actor_uuid as actor_uuid,
	act.actor_description as actor_description
FROM
	calculation_def mdd
	LEFT JOIN vw_actor act ON mdd.actor_uuid = act.actor_uuid
	LEFT JOIN vw_latest_systemtool st ON mdd.systemtool_uuid = st.systemtool_uuid
	LEFT JOIN systemtool_type stt on st.systemtool_type_uuid = stt.systemtool_type_uuid
	LEFT JOIN organization org on st.vendor_organization_uuid = org.organization_uuid;


-- get the descriptors and associated descriptor_def, including parent
-- if there is a parent descriptor, then use the parent calculation_uuid (and type) as 
-- link back to material, otherwise use the current calculation_uuid
-- DROP VIEW vw_calculation;
CREATE OR REPLACE VIEW vw_calculation AS 
SELECT
	md.calculation_uuid, 
-- in_val
	md.in_val,
	md.in_opt_val,
	md.out_val,
	md.calculation_alias_name,
	md.create_date,
	sts.description AS status, 
	dact.actor_description as actor_descr,
	nt.notetext as notetext,
--	md.num_valarray_out,
--	encode( md.blob_val_out, 'escape' ) AS blob_val_out,
--	md.blob_type_out,
	mdd.*
FROM
	calculation md
	LEFT JOIN vw_calculation_def mdd ON md.calculation_def_uuid = mdd.calculation_def_uuid
	LEFT JOIN vw_actor dact ON md.actor_uuid = dact.actor_uuid
	LEFT JOIN status sts ON md.status_uuid = sts.status_uuid
	LEFT JOIN note nt ON md.note_uuid = nt.note_uuid
;

-- get material_refname_type
-- DROP VIEW vw_material_refname_type
CREATE OR REPLACE VIEW vw_material_refname_type AS 
SELECT mrt.material_refname_type_uuid, mrt.description, nt.notetext
FROM material_refname_type mrt
left join note nt on mrt.note_uuid = nt.note_uuid
order by 2;


-- get material_type
-- DROP VIEW vw_material_type
CREATE OR REPLACE VIEW vw_material_type AS 
SELECT mt.material_type_uuid, mt.description, nt.notetext
FROM material_type mt
left join note nt on mt.note_uuid = nt.note_uuid
order by 2;


-- get materials, all status
-- DROP VIEW vw_material_raw
CREATE OR REPLACE VIEW vw_material_raw AS 
SELECT mat.material_uuid, mat.description as material_description, st.description as material_status, get_material_type(mat.material_uuid) as material_type_description,
 mrt.description as material_refname_type, mr.description as material_refname_description, mr.material_refname_type_uuid, mat.add_date as material_create_date,
nt.note_uuid, nt.notetext
FROM material mat
LEFT JOIN material_refname_x mrx on mat.material_uuid = mrx.material_uuid
LEFT JOIN material_refname mr on mrx.material_refname_uuid = mr.material_refname_uuid
LEFT JOIN material_refname_type mrt on mr.material_refname_type_uuid = mrt.material_refname_type_uuid
LEFT JOIN status st on mat.status_uuid = st.status_uuid
LEFT JOIN note nt on mat.note_uuid = nt.note_uuid
order by mat.material_uuid, mr.description;

-- get materials, all status as a crosstab, with refname types 
-- DROP VIEW vw_material
CREATE OR REPLACE VIEW vw_material AS 
SELECT *
FROM crosstab(
  'select material_uuid, material_status, material_create_date, material_refname_type, material_refname_description
   from vw_material_raw order by 1, 3',
	 'select distinct material_refname_type
   from vw_material_raw order by 1')
AS ct(material_uuid uuid, material_status varchar, create_date timestamptz, Abbreviation varchar, Chemical_Name varchar, InChI varchar, InChIKey varchar, Molecular_Formula varchar, SMILES varchar);


-- get materials and all related descriptors, all status
-- drop view vw_material_descriptor_raw
CREATE OR REPLACE VIEW vw_material_descriptor_raw AS 
select mt.material_uuid, df.calculation_uuid, df.calculation_alias_name, df.in_val, df.in_opt_val, df.out_val
	from
	(SELECT distinct material_uuid, calculation_uuid
	FROM vw_material_raw mat
	join (SELECT distinct des1.calculation_uuid as parent_uuid, (des1.in_val).v_text as parent_text, des2.calculation_uuid
		FROM vw_calculation des1 
		join vw_calculation des2 on (des1.out_val).v_text = (des2.in_val).v_text) t2 on mat.material_refname_description = t2.parent_text
	UNION 
	SELECT material_uuid, calculation_uuid
	FROM vw_material_raw mat
	join vw_calculation des on (mat.material_refname_description = (des.in_val).v_text)) tt 
	left join (select * from vw_material_raw where vw_material_raw.material_refname_type = 'SMILES') mt on tt.material_uuid = mt.material_uuid 
	left join vw_calculation df on tt.calculation_uuid = df.calculation_uuid
	order by mt.material_uuid, df.calculation_alias_name;


-- get materials and all related descriptors, all status
-- drop view vw_material_descriptor
CREATE OR REPLACE VIEW vw_material_descriptor AS 
select mat.*, mdr.calculation_uuid, mdr.calculation_alias_name, mdr.in_val, mdr.in_opt_val, mdr.out_val from vw_material mat 
join vw_material_descriptor_raw mdr on mat.material_uuid = mdr.material_uuid;


-- view inventory; with links to material, actor, status, edocument, note
CREATE OR REPLACE VIEW vw_inventory AS 
SELECT inv.inventory_uuid, inv.description inventory_description, inv.part_no, inv.onhand_amt, inv.unit, inv.create_date, inv.expiration_date, inv.inventory_location, 
			st.description as status, mat.material_uuid, mat.description as material_description, act.actor_uuid, act.description, 
			ed.edocument_uuid, ed.description as edocument_description, nt.note_uuid, nt.notetext
FROM inventory inv 
left join material mat on inv.material_uuid = mat.material_uuid
left join actor act on inv.actor_uuid = act.actor_uuid
left join status st on inv.status_uuid = st.status_uuid
left join edocument ed on inv.edocument_uuid = ed.edocument_uuid
left join note nt on inv.note_uuid = nt.note_uuid;


-- get inventory / material, all status
CREATE OR REPLACE VIEW vw_inventory_material AS 
SELECT inv.inventory_uuid, inv.description as inventory_description, inv.part_no as inventory_part_no, inv.onhand_amt as inventory_onhand_amt, inv.unit as inventory_unit, 
				inv.create_date as inventory_create_date, inv.expiration_date as inventory_expiration_date, inv.inventory_location, st.description as inventory_status,
				inv.actor_uuid, act.actor_description, act.org_full_name, inv.material_uuid, mat.material_status, mat.create_date as material_create_date, mat.chemical_name as material_name, 
				mat.abbreviation as material_abbreviation, mat.inchi as material_inchi, mat.inchikey as material_inchikey, mat.molecular_formula as material_molecular_formula, mat.smiles as material_smiles
FROM inventory inv
left join vw_material mat on inv.material_uuid = mat.material_uuid
left join vw_actor act on inv.actor_uuid = act.actor_uuid
left join status st on inv.status_uuid = st.status_uuid;




