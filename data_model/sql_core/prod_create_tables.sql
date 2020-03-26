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

 --=====================================
 -- EXTENSIONS 
 --=====================================
CREATE EXTENSION if not exists ltree;
CREATE EXTENSION if not exists tablefunc;
CREATE EXTENSION if not exists "uuid-ossp";
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
DROP TABLE IF EXISTS m_descriptor_class cascade;
DROP TABLE IF EXISTS m_descriptor_def cascade;
DROP TABLE IF EXISTS m_descriptor cascade;
DROP TABLE IF EXISTS m_descriptor_eval cascade;
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

 --=====================================
 -- CREATE DATA TYPES 
 --=====================================
-- define (enumerate) the value types where hierachy is seperated by '_' with simple data types (int, num, text) as single phrase; treat 'array' like a fifo stack
CREATE TYPE val_type AS ENUM ('int', 'array_int', 'num', 'array_num', 'text', 'array_text', 'blob_text', 'blob_svg', 'blob_jpg', 'blob_png');

CREATE TYPE val AS (
	v_type 	val_type,
	v_text varchar,
	v_text_array varchar[],
	v_int int8,
	v_int_array int8[],
	v_num double precision,
	v_num_array double precision[],
	v_blob bytea
);

 --=====================================
 -- CREATE TABLES 
 --=====================================
---------------------------------------
-- Table structure for organization
---------------------------------------
CREATE TABLE organization (
	organization_id	serial8, 
	organization_uuid uuid DEFAULT uuid_generate_v4 (),
	parent_id int8,
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
	person_id serial8,
  person_uuid uuid DEFAULT uuid_generate_v4 (),	
  firstname varchar COLLATE "pg_catalog"."default",
  lastname varchar COLLATE "pg_catalog"."default" NOT NULL,
  middlename varchar COLLATE "pg_catalog"."default",
  address1 varchar COLLATE "pg_catalog"."default",
  address2 varchar COLLATE "pg_catalog"."default",
  city varchar COLLATE "pg_catalog"."default",
  stateprovince char(3) COLLATE "pg_catalog"."default",
  phone varchar COLLATE "pg_catalog"."default",
  email varchar COLLATE "pg_catalog"."default",
  title VARCHAR COLLATE "pg_catalog"."default",
  suffix varchar COLLATE "pg_catalog"."default",
	organization_id int8,
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for systemtool
---------------------------------------
CREATE TABLE systemtool (
	systemtool_id serial8, 
  systemtool_uuid uuid DEFAULT uuid_generate_v4 (),
  systemtool_name varchar COLLATE "pg_catalog"."default" NOT NULL,
  description varchar COLLATE "pg_catalog"."default",
  systemtool_type_id int8,
  vendor_organization_id int8,
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
	systemtool_type_id serial8,
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
  person_id int8,
  organization_id int8,
  systemtool_id int8,
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
  material_id serial8,
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
-- Table structure for m_descriptor_class
---------------------------------------
CREATE TABLE m_descriptor_class (
	m_descriptor_class_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for m_descriptor_def
---------------------------------------
CREATE TABLE m_descriptor_def (
	m_descriptor_def_uuid uuid DEFAULT uuid_generate_v4 (),
  short_name varchar COLLATE "pg_catalog"."default",
	calc_definition varchar COLLATE "pg_catalog"."default",
	systemtool_id int8,
	description varchar COLLATE "pg_catalog"."default",
	in_type val_type,
	out_type val_type,
	m_descriptor_class_uuid uuid,
	actor_uuid uuid, 
  note_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for m_descriptor
---------------------------------------
CREATE TABLE m_descriptor (
	m_descriptor_uuid uuid DEFAULT uuid_generate_v4 (),
  m_descriptor_def_uuid uuid,
	m_descriptor_alias_name varchar,
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
-- Table structure for m_descriptor_eval
---------------------------------------
CREATE TABLE m_descriptor_eval(
	m_descriptor_eval_id serial8,
  m_descriptor_def_uuid uuid,
	in_val val, 
	in_opt_val val,
	out_val val, 
	m_descriptor_alias_name varchar,
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
  description varchar COLLATE "pg_catalog"."default",
  edocument bytea,
  edoc_type varchar COLLATE "pg_catalog"."default",
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

--=====================================
-- KEYS
--=====================================
ALTER TABLE organization ADD 
	CONSTRAINT "pk_organization_organization_id" PRIMARY KEY (organization_id);
CREATE INDEX "ix_organization_parent_path" ON organization USING GIST (parent_path);
CREATE INDEX "ix_organization_parent_id" ON organization (parent_id);
CLUSTER organization USING "pk_organization_organization_id";

ALTER TABLE person ADD 
	CONSTRAINT "pk_person_person_id" PRIMARY KEY (person_id);
CLUSTER person USING "pk_person_person_id";

ALTER TABLE systemtool 
	ADD CONSTRAINT "pk_systemtool_systemtool_id" PRIMARY KEY (systemtool_id),
	ADD CONSTRAINT "un_systemtool" UNIQUE (systemtool_name, systemtool_type_id, vendor_organization_id, ver);
CLUSTER systemtool USING "pk_systemtool_systemtool_id";

ALTER TABLE systemtool_type 
	ADD CONSTRAINT "pk_systemtool_systemtool_type_id" PRIMARY KEY (systemtool_type_id);
CLUSTER systemtool_type USING "pk_systemtool_systemtool_type_id";

ALTER TABLE actor 
	ADD CONSTRAINT "pk_actor_uuid" PRIMARY KEY (actor_uuid);
CREATE UNIQUE INDEX "un_actor" ON actor (coalesce(person_id,-1), coalesce(organization_id,-1), coalesce(systemtool_id,-1) );
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

ALTER TABLE m_descriptor_class ADD 
	CONSTRAINT "pk_m_descriptor_class_m_descriptor_class_uuid" PRIMARY KEY (m_descriptor_class_uuid);
CLUSTER m_descriptor_class USING "pk_m_descriptor_class_m_descriptor_class_uuid";

ALTER TABLE m_descriptor_def 
	ADD CONSTRAINT "pk_m_descriptor_m_descriptor_def_uuid" PRIMARY KEY (m_descriptor_def_uuid),
	ADD CONSTRAINT "un_m_descriptor_def" UNIQUE (actor_uuid, calc_definition);	
CLUSTER m_descriptor_def USING "pk_m_descriptor_m_descriptor_def_uuid";

ALTER TABLE m_descriptor
	ADD CONSTRAINT "pk_m_descriptor_m_descriptor_uuid" PRIMARY KEY (m_descriptor_uuid),
	ADD CONSTRAINT "un_m_descriptor" UNIQUE (m_descriptor_def_uuid, in_val, in_opt_val);
CLUSTER m_descriptor USING "pk_m_descriptor_m_descriptor_uuid";

ALTER TABLE m_descriptor_eval
	ADD CONSTRAINT "pk_m_descriptor_eval_m_descriptor_eval_id" PRIMARY KEY (m_descriptor_eval_id),
	ADD CONSTRAINT "un_m_descriptor_eval" UNIQUE (m_descriptor_def_uuid, in_val, in_opt_val);
CLUSTER m_descriptor_eval USING "pk_m_descriptor_eval_m_descriptor_eval_id";

-- ALTER TABLE m_descriptor_value ADD 
-- 	CONSTRAINT "pk_m_descriptor_value_m_descriptor_value_uuid" PRIMARY KEY (m_descriptor_value_uuid);
-- CLUSTER m_descriptor_value USING "pk_m_descriptor_value_m_descriptor_value_uuid";-- 

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


--=====================================
-- FOREIGN KEYS
--=====================================
-- ALTER TABLE organization DROP CONSTRAINT fk_organization_note_1;
ALTER TABLE organization 
	ADD CONSTRAINT fk_organization_organization_1 FOREIGN KEY (parent_id) REFERENCES organization (organization_id),
	ADD CONSTRAINT fk_organization_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE person DROP CONSTRAINT fk_person_organization_1, 
--	DROP CONSTRAINT fk_person_note_1;
ALTER TABLE person 
	ADD CONSTRAINT fk_person_organization_1 FOREIGN KEY (organization_id) REFERENCES organization (organization_id),
	ADD CONSTRAINT fk_person_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE systemtool DROP CONSTRAINT fk_systemtool_systemtool_type_1,
--	DROP CONSTRAINT fk_systemtool_organization_1,
--	DROP CONSTRAINT fk_systemtool_note_1;
ALTER TABLE systemtool 
	ADD CONSTRAINT fk_systemtool_systemtool_type_1 FOREIGN KEY (systemtool_type_id) REFERENCES systemtool_type (systemtool_type_id),
	ADD CONSTRAINT fk_systemtool_vendor_1 FOREIGN KEY (vendor_organization_id) REFERENCES organization (organization_id),
	ADD CONSTRAINT fk_systemtool_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE systemtool_type DROP CONSTRAINT fk_systemtool_type_note_1;
ALTER TABLE systemtool_type 
	ADD CONSTRAINT fk_systemtool_type_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

-- ALTER TABLE actor DROP CONSTRAINT fk_actor_person_1, 
--	DROP CONSTRAINT fk_actor_organization_1, 
--	DROP CONSTRAINT fk_actor_systemtool_1,
--	DROP CONSTRAINT fk_actor_note_1;
ALTER TABLE actor 
	ADD CONSTRAINT fk_actor_person_1 FOREIGN KEY (person_id) REFERENCES person (person_id),
	ADD CONSTRAINT fk_actor_organization_1 FOREIGN KEY (organization_id) REFERENCES organization (organization_id),
	ADD CONSTRAINT fk_actor_systemtool_1 FOREIGN KEY (systemtool_id) REFERENCES systemtool (systemtool_id),
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

-- ALTER TABLE m_descriptor_class DROP CONSTRAINT fk_m_descriptor_class_note_1;
ALTER TABLE m_descriptor_class 
	ADD CONSTRAINT fk_m_descriptor_class_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);
	
-- ALTER TABLE m_descriptor_def DROP CONSTRAINT fk_m_descriptor_def_note_1,
-- DROP CONSTRAINT fk_m_descriptor_def_actor_1, 
-- DROP CONSTRAINT fk_m_descriptor_def_m_descriptor_class_1,
-- DROP CONSTRAINT fk_m_descriptor_def_systemtool_1;
ALTER TABLE m_descriptor_def 
	ADD CONSTRAINT fk_m_descriptor_def_m_descriptor_class_1 FOREIGN KEY (m_descriptor_class_uuid) REFERENCES m_descriptor_class (m_descriptor_class_uuid),	
	ADD CONSTRAINT fk_m_descriptor_def_systemtool_1 FOREIGN KEY (systemtool_id) REFERENCES systemtool (systemtool_id),	
	ADD CONSTRAINT fk_m_descriptor_def_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),
	ADD CONSTRAINT fk_m_descriptor_def_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);	

-- ALTER TABLE m_descriptor DROP CONSTRAINT fk_m_descriptor_material_1, 
-- DROP CONSTRAINT fk_m_descriptor_actor_1, 
-- DROP CONSTRAINT fk_m_descriptor_status_1,
-- DROP CONSTRAINT fk_m_descriptor_note_1;
ALTER TABLE m_descriptor 
--	ADD CONSTRAINT fk_m_descriptor_material_refname_1 FOREIGN KEY (material_refname_description_in, material_refname_type_in) REFERENCES material_refname (description, material_refname_type),
	ADD CONSTRAINT fk_m_descriptor_m_descriptor_def_1 FOREIGN KEY (m_descriptor_def_uuid) REFERENCES m_descriptor_def (m_descriptor_def_uuid),	
	ADD CONSTRAINT fk_m_descriptor_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid),	
	ADD CONSTRAINT fk_m_descriptor_status_1 FOREIGN KEY (status_uuid) REFERENCES status (status_uuid),	
	ADD CONSTRAINT fk_m_descriptor_note_1 FOREIGN KEY (note_uuid) REFERENCES note (note_uuid);

ALTER TABLE m_descriptor_eval
	ADD CONSTRAINT fk_m_descriptor_eval_m_descriptor_def_1 FOREIGN KEY (m_descriptor_def_uuid) REFERENCES m_descriptor_def (m_descriptor_def_uuid),	
	ADD CONSTRAINT fk_m_descriptor_eval_actor_1 FOREIGN KEY (actor_uuid) REFERENCES actor (actor_uuid);

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
  COMMENT ON COLUMN organization.organization_id IS 'primary key for organization records';
	COMMENT ON COLUMN organization.organization_uuid is 'uuid for this organization record';
	COMMENT ON COLUMN organization.parent_id is 'reference to parent organization; uses [internal] organization_uuid';
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
-- integrated view of inventory; joins measure (amounts of material
CREATE OR REPLACE VIEW vw_actor AS 
SELECT
	act.actor_uuid AS actor_uuid,
	org.organization_id,
	per.person_id,
	st.systemtool_id,
	act.description AS actor_description,
	sts.description AS actor_status,
	nt.notetext AS actor_notetext,
	doc.edocument AS actor_document,
	doc.edoc_type AS actor_doc_type,
	org.full_name AS org_full_name,
	org.short_name AS org_short_name,
	per.lastname AS per_lastname,
	per.firstname AS per_firstname,
CASE
		WHEN per.person_id IS NOT NULL THEN
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
	LEFT JOIN organization org ON act.organization_id = org.organization_id
	LEFT JOIN person per ON act.person_id = per.person_id
	LEFT JOIN organization porg ON per.organization_id = porg.organization_id
	LEFT JOIN systemtool st ON act.systemtool_id = st.systemtool_id
	LEFT JOIN systemtool_type stt ON st.systemtool_type_id = stt.systemtool_type_id
	LEFT JOIN organization vorg on st.vendor_organization_id = vorg.organization_id
	LEFT JOIN note nt ON act.note_uuid = nt.note_uuid
	LEFT JOIN edocument_x docx ON nt.note_uuid = docx.ref_edocument_uuid
	LEFT JOIN edocument doc ON docx.edocument_uuid = doc.edocument_uuid
	LEFT JOIN status sts ON act.status_uuid = sts.status_uuid;
		
-- get most recent version of a systemtool
-- return all columns from the systemtool table
CREATE OR REPLACE VIEW vw_latest_systemtool AS 
SELECT
	stl.* 
FROM
	systemtool stl
	JOIN (
	SELECT
		st.systemtool_name,
		st.systemtool_type_id,
		st.vendor_organization_id,
		MAX ( st.ver ) AS ver 
	FROM
		systemtool st 
	WHERE
		st.systemtool_name IS NOT NULL 
		AND st.ver IS NOT NULL 
	GROUP BY
		st.systemtool_name,
		st.systemtool_type_id,
		st.vendor_organization_id 
	) mrs ON stl.systemtool_name = mrs.systemtool_name 
	AND stl.systemtool_type_id = mrs.systemtool_type_id 
	AND stl.vendor_organization_id = mrs.vendor_organization_id 
	AND stl.ver = mrs.ver;
	
-- get most recent version of a systemtool as it's parent actor
-- return all columns from actor table
CREATE OR REPLACE VIEW vw_latest_systemtool_actor AS 
	SELECT
	act.* 
FROM
	vw_latest_systemtool vst
	JOIN actor act ON vst.systemtool_id = act.systemtool_id;


-- get the m_descriptor_def and associated actor
CREATE OR REPLACE VIEW vw_m_descriptor_def AS 
SELECT
	mdd.m_descriptor_def_uuid,
	mdd.short_name,
	mdd.calc_definition,
	mdd.description,
	mdd.in_type,
	mdd.out_type,
	mdd.systemtool_id,
	st.systemtool_name,
	stt.description as systemtool_type_description,
	org.short_name as systemtool_vendor_organzation,
	st.ver as systemtool_version,
	mdd.actor_uuid as actor_uuid,
	act.actor_description as actor_description
FROM
	m_descriptor_def mdd
	LEFT JOIN vw_actor act ON mdd.actor_uuid = act.actor_uuid
	LEFT JOIN vw_latest_systemtool st ON mdd.systemtool_id = st.systemtool_id
	LEFT JOIN systemtool_type stt on st.systemtool_type_id = stt.systemtool_type_id
	LEFT JOIN organization org on st.vendor_organization_id = org.organization_id;


-- get the descriptors and associated descriptor_def, including parent
-- if there is a parent descriptor, then use the parent m_descriptor_uuid (and type) as 
-- link back to material, otherwise use the current m_descriptor_uuid
-- DROP VIEW vw_m_descriptor;
CREATE OR REPLACE VIEW vw_m_descriptor AS 
SELECT
	md.m_descriptor_uuid, 
-- in_val
	md.in_val,
	md.in_opt_val,
	md.out_val,
	md.m_descriptor_alias_name,
	md.create_date,
	sts.description AS status, 
	dact.actor_description as actor_descr,
	nt.notetext as note_text,
--	md.num_valarray_out,
--	encode( md.blob_val_out, 'escape' ) AS blob_val_out,
--	md.blob_type_out,
	mdd.*
FROM
	m_descriptor md
	LEFT JOIN vw_m_descriptor_def mdd ON md.m_descriptor_def_uuid = mdd.m_descriptor_def_uuid
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


-- get materials, all status
-- DROP VIEW vw_material_raw
CREATE OR REPLACE VIEW vw_material_raw AS 
SELECT mat.material_id, mat.material_uuid, mat.description as material_description, st.description as material_status, mr.description as material_refname_description, mr.material_refname_type_uuid, mt.description as material_refname_type, mt.add_date as create_date
FROM material mat
LEFT JOIN material_refname_x mrx on mat.material_uuid = mrx.material_uuid
LEFT JOIN material_refname mr on mrx.material_refname_uuid = mr.material_refname_uuid
LEFT JOIN material_refname_type mt on mr.material_refname_type_uuid = mt.material_refname_type_uuid
LEFT JOIN status st on mat.status_uuid = st.status_uuid
order by mat.material_uuid, mt.description;

-- get materials, all status as a crosstab, with refname types 
-- DROP VIEW vw_material
CREATE OR REPLACE VIEW vw_material AS 
SELECT *
FROM crosstab(
  'select material_uuid, material_status, create_date, material_refname_type, material_refname_description
   from vw_material_raw order by 1, 3',
	 'select distinct material_refname_type
   from vw_material_raw order by 1')
AS ct(material_uuid uuid, material_status varchar, create_date timestamptz, Abbreviation varchar, Chemical_Name varchar, InChI varchar, InChIKey varchar, Molecular_Formula varchar, SMILES varchar);


-- get materials and all related descriptors, all status
-- drop view vw_material_descriptor_raw
CREATE OR REPLACE VIEW vw_material_descriptor_raw AS 
select mt.material_uuid, df.m_descriptor_uuid, df.m_descriptor_alias_name, df.in_val, df.in_opt_val, df.out_val
	from
	(SELECT distinct material_uuid, m_descriptor_uuid
	FROM vw_material_raw mat
	join (SELECT distinct des1.m_descriptor_uuid as parent_uuid, (des1.in_val).v_text as parent_text, des2.m_descriptor_uuid
		FROM vw_m_descriptor des1 
		join vw_m_descriptor des2 on (des1.out_val).v_text = (des2.in_val).v_text) t2 on mat.material_refname_description = t2.parent_text
	UNION 
	SELECT material_uuid, m_descriptor_uuid
	FROM vw_material_raw mat
	join vw_m_descriptor des on (mat.material_refname_description = (des.in_val).v_text)) tt 
	left join (select * from vw_material_raw where vw_material_raw.material_refname_type = 'SMILES') mt on tt.material_uuid = mt.material_uuid 
	left join vw_m_descriptor df on tt.m_descriptor_uuid = df.m_descriptor_uuid
	order by mt.material_uuid, df.m_descriptor_alias_name;


-- get materials and all related descriptors, all status
-- drop view vw_material_descriptor
CREATE OR REPLACE VIEW vw_material_descriptor AS 
select mat.*, mdr.m_descriptor_uuid, mdr.m_descriptor_alias_name, mdr.in_val, mdr.in_opt_val, mdr.out_val from vw_material mat 
join vw_material_descriptor_raw mdr on mat.material_uuid = mdr.material_uuid;


-- get inventory, all status
CREATE OR REPLACE VIEW vw_inventory AS 
SELECT *
FROM inventory inv;

-- get inventory / material, all status
CREATE OR REPLACE VIEW vw_inventory_material AS 
SELECT inv.inventory_uuid, inv.description as inventory_description, inv.part_no as inventory_part_no, inv.onhand_amt as inventory_onhand_amt, inv.unit as inventory_unit, 
				inv.create_date as inventory_crate_date, inv.expiration_date as inventory_expiration_date, inv.inventory_location, st.description as inventory_status,
				inv.actor_uuid, act.actor_description, act.org_full_name, inv.material_uuid, mat.material_status, mat.create_date as material_create_date, mat.chemical_name as material_name, 
				mat.abbreviation as material_abbreviation, mat.inchi as material_inchi, mat.inchikey as material_inchikey, mat.molecular_formula as material_molecular_formula, mat.smiles as material_smiles
FROM inventory inv
left join vw_material mat on inv.material_uuid = mat.material_uuid
left join vw_actor act on inv.actor_uuid = act.actor_uuid
left join status st on inv.status_uuid = st.status_uuid;

-- STUB get inventory / material / descriptors, all status
CREATE OR REPLACE VIEW vw_inventory_material_descriptor AS 
SELECT *
FROM inventory inv; 