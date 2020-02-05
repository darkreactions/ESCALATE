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
 -- DROP TABLES 
 --=====================================
DROP TABLE IF EXISTS organization cascade; 
DROP TABLE IF EXISTS person cascade; 
DROP TABLE IF EXISTS systemtool cascade;
DROP TABLE IF EXISTS systemtool_type cascade;
DROP TABLE IF EXISTS actor cascade;
DROP TABLE IF EXISTS material cascade;
DROP TABLE IF EXISTS material_type cascade;
DROP TABLE IF EXISTS material_type_x cascade;
DROP TABLE IF EXISTS material_refname cascade;
DROP TABLE IF EXISTS material_refname_x cascade;
DROP TABLE IF EXISTS m_descriptor_class cascade;
DROP TABLE IF EXISTS m_descriptor_def cascade;
DROP TABLE IF EXISTS m_descriptor cascade;
DROP TABLE IF EXISTS m_descriptor_value cascade;
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
 -- CREATE TABLES 
 --=====================================
---------------------------------------
-- Table structure for organization
---------------------------------------
CREATE TABLE organization (
  organization_id serial8,
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
  note_id int8,
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
  note_id int8,
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
  vendor varchar COLLATE "pg_catalog"."default",
  model varchar COLLATE "pg_catalog"."default",
  serial varchar COLLATE "pg_catalog"."default",
  ver varchar COLLATE "pg_catalog"."default",
  organization_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for systemtool_type
---------------------------------------
CREATE TABLE systemtool_type (
  systemtool_type_id serial8 NOT NULL,
  systemtool_type_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for actor
---------------------------------------
CREATE TABLE actor (
  actor_id serial8,
  actor_uuid uuid DEFAULT uuid_generate_v4 (),
  person_id int8,
  organization_id int8,
  systemtool_id int8,
  description varchar COLLATE "pg_catalog"."default",
	status_id int8,
  note_id int8,
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
  parent_id int8,
	parent_path ltree,	
--  "material_type_x_id" int8,
--  actor_id int8,
--  "descriptor_id" int8,
--  "alt_material_refname_id" int8,
	status_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_type
---------------------------------------
CREATE TABLE material_type (
  material_type_id serial8,
  material_type_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_type_x
---------------------------------------
CREATE TABLE material_type_x (
  material_type_x_id serial8,
	material_id int8,
  material_type_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_refname
---------------------------------------
CREATE TABLE material_refname (
  material_refname_id serial8,
	material_refname_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
 -- material_id int8,	
  blob_value bytea,
	blob_type varchar,
  material_refname_type varchar COLLATE "pg_catalog"."default",
  reference varchar COLLATE "pg_catalog"."default",
	status_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_refname_x
---------------------------------------
CREATE TABLE material_refname_x (
  material_refname_x_id serial8,
	material_id int8,
  material_refname_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for m_descriptor_class
---------------------------------------
CREATE TABLE m_descriptor_class (
  m_descriptor_class_id serial8,
	m_descriptor_class_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for m_descriptor_def
---------------------------------------
CREATE TABLE m_descriptor_def (
  m_descriptor_def_id serial8,
	m_descriptor_def_uuid uuid DEFAULT uuid_generate_v4 (),
  short_name varchar COLLATE "pg_catalog"."default",
	calc_definition varchar COLLATE "pg_catalog"."default",
	description varchar COLLATE "pg_catalog"."default",
	m_descriptor_class_id int8,
	actor_id int8, 
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for m_descriptor
---------------------------------------
CREATE TABLE m_descriptor (
  m_descriptor_id serial8,
	m_descriptor_uuid uuid DEFAULT uuid_generate_v4 (),
	parent_id int8,
	parent_path ltree,
	m_descriptor_material_in varchar COLLATE "pg_catalog"."default",
  m_descriptor_material_type_in varchar(255) COLLATE "pg_catalog"."default",
  m_descriptor_def_id int8,
	create_date timestamptz,
  num_valarray_out DOUBLE PRECISION[],	
  blob_val_out bytea,	
	blob_type_out varchar,
  status_id int8,
	actor_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for descriptor_value
---------------------------------------
--DROP TABLE IF EXISTS m_descriptor_value cascade;
--CREATE TABLE m_descriptor_value (
 -- m_descriptor_value_id serial8,
--	m_descriptor_value_uuid uuid DEFAULT uuid_generate_v4 (),
--  num_value DOUBLE PRECISION,
--  blob_value bytea,
--  add_date timestamptz NOT NULL DEFAULT NOW(),
--  mod_date timestamptz NOT NULL DEFAULT NOW());

---------------------------------------
-- Table structure for inventory
---------------------------------------
CREATE TABLE inventory (
  inventory_id serial8,
	inventory_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar,
  material_id int8 NOT NULL,
  actor_id int8,
	part_no varchar,
	onhand_amt  DOUBLE PRECISION,
	unit varchar,
	-- measure_id int8,
  create_date timestamptz,
  expiration_date timestamptz DEFAULT NULL,
  inventory_location varchar(255) COLLATE "pg_catalog"."default",
	status_id int8,
	edocument_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure
---------------------------------------
CREATE TABLE measure (
	measure_id serial8,
	measure_uuid uuid DEFAULT uuid_generate_v4 (),
	measure_type_id int8,
	amount DOUBLE PRECISION,
	unit varchar COLLATE "pg_catalog"."default",
	blob_amount bytea,
	edocument_id int8,
	note_id int8,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure_x
---------------------------------------
CREATE TABLE measure_x (
  measure_x_id serial8,
	ref_measure_uuid uuid DEFAULT uuid_generate_v4 (),
  measure_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure_type
---------------------------------------
CREATE TABLE measure_type (
	measure_type_id serial8,
	measure_type_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar COLLATE "pg_catalog"."default",
	note_id int8,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for note
---------------------------------------
CREATE TABLE note (
  note_id serial8,
	note_uuid uuid DEFAULT uuid_generate_v4 (),
  notetext varchar COLLATE "pg_catalog"."default",
  edocument_id int8,
	actor_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for document
-- ----------------------------
CREATE TABLE edocument (
  edocument_id serial8,
	edocument_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  edocument bytea,
  edoc_type varchar COLLATE "pg_catalog"."default",
  ver varchar COLLATE "pg_catalog"."default",
	actor_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for edocument_x
---------------------------------------
CREATE TABLE edocument_x (
  edocument_x_id serial8,
	ref_uuid uuid DEFAULT uuid_generate_v4 (),
  edocument_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for tag
-- ----------------------------
CREATE TABLE tag (
  tag_id serial8,
	tag_uuid uuid DEFAULT uuid_generate_v4 (),
	tag_type_id int8,
  description varchar COLLATE "pg_catalog"."default",
	actor_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for tag_x
---------------------------------------
CREATE TABLE tag_x (
  tag_x_id serial8,
	ref_tag_uuid uuid DEFAULT uuid_generate_v4 (),
  tag_uuid uuid,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for tag_type
-- ----------------------------
CREATE TABLE tag_type (
  tag_type_id serial8,
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
  status_id serial8,
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
	ADD CONSTRAINT "un_systemtool" UNIQUE (systemtool_name, systemtool_type_id, ver, organization_id);
CLUSTER systemtool USING "pk_systemtool_systemtool_id";

ALTER TABLE systemtool_type 
	ADD CONSTRAINT "pk_systemtool_systemtool_type_id" PRIMARY KEY (systemtool_type_id);
CLUSTER systemtool_type USING "pk_systemtool_systemtool_type_id";

ALTER TABLE actor 
	ADD CONSTRAINT "pk_actor_id" PRIMARY KEY (actor_id);
CREATE UNIQUE INDEX "un_actor" ON actor (coalesce(person_id,-1), coalesce(organization_id,-1), coalesce(systemtool_id,-1) );
CLUSTER actor USING "pk_actor_id";

ALTER TABLE material ADD 
	CONSTRAINT "pk_material_material_id" PRIMARY KEY (material_id);
CREATE INDEX "ix_material_parent_path" ON material USING GIST (parent_path);
CREATE INDEX "ix_material_parent_id" ON material (parent_id);
CLUSTER material USING "pk_material_material_id";

ALTER TABLE material_type ADD 
	CONSTRAINT "pk_material_type_material_type_id" PRIMARY KEY (material_type_id);
CLUSTER material_type USING "pk_material_type_material_type_id";

ALTER TABLE material_type_x 
	ADD CONSTRAINT "pk_material_type_x_material_type_x_id" PRIMARY KEY (material_type_x_id),
	ADD CONSTRAINT "un_material_type_x" UNIQUE (material_id, material_type_id);
CLUSTER material_type_x USING "pk_material_type_x_material_type_x_id";

ALTER TABLE material_refname 
	ADD CONSTRAINT "pk_material_refname_material_refname_id" PRIMARY KEY (material_refname_id),
	ADD CONSTRAINT "un_material_refname" UNIQUE (description, material_refname_type);
CLUSTER material_refname USING "pk_material_refname_material_refname_id";

ALTER TABLE material_refname_x 
	ADD CONSTRAINT "pk_material_refname_x_material_refname_x_id" PRIMARY KEY (material_refname_x_id),
	ADD CONSTRAINT "un_material_refname_x" UNIQUE (material_id, material_refname_id);
CLUSTER material_refname_x USING "pk_material_refname_x_material_refname_x_id";

ALTER TABLE m_descriptor_class ADD 
	CONSTRAINT "pk_m_descriptor_class_m_descriptor_class_id" PRIMARY KEY (m_descriptor_class_id);
CLUSTER m_descriptor_class USING "pk_m_descriptor_class_m_descriptor_class_id";

ALTER TABLE m_descriptor_def 
	ADD CONSTRAINT "pk_m_descriptor_m_descriptor_def_id" PRIMARY KEY (m_descriptor_def_id),
	ADD CONSTRAINT "un_m_descriptor_def" UNIQUE (actor_id, calc_definition);	
CLUSTER m_descriptor_def USING "pk_m_descriptor_m_descriptor_def_id";

ALTER TABLE m_descriptor
	ADD CONSTRAINT "pk_m_descriptor_m_descriptor_id" PRIMARY KEY (m_descriptor_id),
	ADD CONSTRAINT "un_m_descriptor" UNIQUE (parent_id, m_descriptor_material_in, m_descriptor_material_type_in, m_descriptor_def_id);
CREATE INDEX "ix_m_descriptor_parent_path" ON m_descriptor USING GIST (parent_path);
CREATE INDEX "ix_m_descriptor_parent_id" ON m_descriptor (parent_id);
CLUSTER m_descriptor USING "pk_m_descriptor_m_descriptor_id";

-- ALTER TABLE m_descriptor_value ADD 
-- 	CONSTRAINT "pk_m_descriptor_value_m_descriptor_value_id" PRIMARY KEY (m_descriptor_value_id);
-- CLUSTER m_descriptor_value USING "pk_m_descriptor_value_m_descriptor_value_id";-- 

ALTER TABLE inventory 
	ADD CONSTRAINT "pk_inventory_inventory_id" PRIMARY KEY (inventory_id),
	ADD CONSTRAINT "un_inventory" UNIQUE (material_id, actor_id, create_date);
CLUSTER inventory USING "pk_inventory_inventory_id";

ALTER TABLE measure 
	ADD CONSTRAINT "pk_measure_measure_id" PRIMARY KEY (measure_id),
	ADD CONSTRAINT "un_measure" UNIQUE (measure_uuid);
 CLUSTER measure USING "pk_measure_measure_id";

ALTER TABLE measure_x 
	ADD CONSTRAINT "pk_measure_x_measure_x_id" PRIMARY KEY (measure_x_id),
	ADD CONSTRAINT "un_measure_x" UNIQUE (ref_measure_uuid, measure_uuid);
CLUSTER measure_x USING "pk_measure_x_measure_x_id";

 ALTER TABLE measure_type ADD 
	CONSTRAINT "pk_measure_type_measure_type_id" PRIMARY KEY (measure_type_id);
 CLUSTER measure_type USING "pk_measure_type_measure_type_id";

ALTER TABLE note ADD 
	CONSTRAINT "pk_note_note_id" PRIMARY KEY (note_id);
CLUSTER note USING "pk_note_note_id";

ALTER TABLE edocument ADD 
	CONSTRAINT "pk_edocument_edocument_id" PRIMARY KEY (edocument_id);
CLUSTER edocument USING "pk_edocument_edocument_id";

ALTER TABLE edocument_x 
	ADD CONSTRAINT "pk_edocument_x_edocument_x_id" PRIMARY KEY (edocument_x_id),
	ADD CONSTRAINT "un_edocument_x" UNIQUE (ref_uuid, edocument_id);
CLUSTER edocument_x USING "pk_edocument_x_edocument_x_id";

ALTER TABLE tag 
	ADD CONSTRAINT "pk_tag_tag_id" PRIMARY KEY (tag_id),
	ADD CONSTRAINT "un_tag" UNIQUE (tag_uuid);;
CLUSTER tag USING "pk_tag_tag_id";

ALTER TABLE tag_x 
	ADD CONSTRAINT "pk_tag_x_tag_x_id" PRIMARY KEY (tag_x_id),
	ADD CONSTRAINT "un_tag_x" UNIQUE (ref_tag_uuid, tag_uuid);
CLUSTER tag_x USING "pk_tag_x_tag_x_id";

ALTER TABLE tag_type ADD 
	CONSTRAINT "pk_tag_tag_type_id" PRIMARY KEY (tag_type_id);
CLUSTER tag_type USING "pk_tag_tag_type_id";

ALTER TABLE status ADD 
	CONSTRAINT "pk_status_status_id" PRIMARY KEY (status_id);
CLUSTER status USING "pk_status_status_id";

--=====================================
-- FOREIGN KEYS
--=====================================
-- ALTER TABLE organization DROP CONSTRAINT fk_organization_note_1;
ALTER TABLE organization 
	ADD CONSTRAINT fk_organization_organization_1 FOREIGN KEY (parent_id) REFERENCES organization (organization_id),
	ADD CONSTRAINT fk_organization_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

-- ALTER TABLE person DROP CONSTRAINT fk_person_organization_1, 
--	DROP CONSTRAINT fk_person_note_1;
ALTER TABLE person 
	ADD CONSTRAINT fk_person_organization_1 FOREIGN KEY (organization_id) REFERENCES organization (organization_id),
	ADD CONSTRAINT fk_person_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

-- ALTER TABLE systemtool DROP CONSTRAINT fk_systemtool_systemtool_type_1,
--	DROP CONSTRAINT fk_systemtool_organization_1,
--	DROP CONSTRAINT fk_systemtool_note_1;
ALTER TABLE systemtool 
	ADD CONSTRAINT fk_systemtool_systemtool_type_1 FOREIGN KEY (systemtool_type_id) REFERENCES systemtool_type (systemtool_type_id),
	ADD CONSTRAINT fk_systemtool_organization_1 FOREIGN KEY (organization_id) REFERENCES organization (organization_id),
	ADD CONSTRAINT fk_systemtool_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

-- ALTER TABLE systemtool_type DROP CONSTRAINT fk_systemtool_type_note_1;
ALTER TABLE systemtool_type 
	ADD CONSTRAINT fk_systemtool_type_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

-- ALTER TABLE actor DROP CONSTRAINT fk_actor_person_1, 
--	DROP CONSTRAINT fk_actor_organization_1, 
--	DROP CONSTRAINT fk_actor_systemtool_1,
--	DROP CONSTRAINT fk_actor_note_1;
ALTER TABLE actor 
	ADD CONSTRAINT fk_actor_person_1 FOREIGN KEY (person_id) REFERENCES person (person_id),
	ADD CONSTRAINT fk_actor_organization_1 FOREIGN KEY (organization_id) REFERENCES organization (organization_id),
	ADD CONSTRAINT fk_actor_systemtool_1 FOREIGN KEY (systemtool_id) REFERENCES systemtool (systemtool_id),
	ADD CONSTRAINT fk_actor_status_1 FOREIGN KEY (status_id) REFERENCES status (status_id),	
	ADD CONSTRAINT fk_actor_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);
	
-- ALTER TABLE material DROP CONSTRAINT fk_material_actor_1,
--	DROP CONSTRAINT fk_material_material_1;
--	DROP CONSTRAINT fk_material_note_1;
ALTER TABLE material 
--	ADD CONSTRAINT fk_material_actor_1 FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
	ADD CONSTRAINT fk_material_material_1 FOREIGN KEY (parent_id) REFERENCES material (material_id),
	ADD CONSTRAINT fk_material_status_1 FOREIGN KEY (status_id) REFERENCES status (status_id),	
	ADD CONSTRAINT fk_material_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);
	
-- ALTER TABLE material_type DROP CONSTRAINT fk_material_type_note_1;
ALTER TABLE material_type 
	ADD CONSTRAINT fk_material_type_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

--ALTER TABLE material_type_x DROP CONSTRAINT fk_material_type_x_material_1, 
--	DROP CONSTRAINT fk_material_type_x_material_type_1;
ALTER TABLE material_type_x 
	ADD CONSTRAINT fk_material_type_x_material_1 FOREIGN KEY (material_id) REFERENCES material (material_id),
	ADD CONSTRAINT fk_material_type_x_material_type_1 FOREIGN KEY (material_type_id) REFERENCES material_type (material_type_id);

--ALTER TABLE material_refname DROP CONSTRAINT fk_alt_material_refname_material_1, 
--	DROP CONSTRAINT fk_alt_material_refname_note_1;
ALTER TABLE material_refname 
	ADD CONSTRAINT fk_material_refname_status_1 FOREIGN KEY (status_id) REFERENCES status (status_id),	
	ADD CONSTRAINT fk_material_refname_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

--ALTER TABLE material_refname_x DROP CONSTRAINT fk_material_refname_x_material_1, 
--	DROP CONSTRAINT fk_material_refname_x_material_type_1;
ALTER TABLE material_refname_x 
	ADD CONSTRAINT fk_material_refname_x_material_1 FOREIGN KEY (material_id) REFERENCES material (material_id),
	ADD CONSTRAINT fk_material_refname_x_material_refname_1 FOREIGN KEY (material_refname_id) REFERENCES material_refname (material_refname_id);

-- ALTER TABLE m_descriptor_class DROP CONSTRAINT fk_m_descriptor_class_note_1;
ALTER TABLE m_descriptor_class 
	ADD CONSTRAINT fk_m_descriptor_class_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);
	
-- ALTER TABLE m_descriptor_type_x DROP CONSTRAINT fk_m_descriptor_def_note_1,
-- DROP CONSTRAINT fk_m_descriptor_def_actor_1, 
-- DROP CONSTRAINT fk_m_descriptor_def_m_descriptor_class_1;
ALTER TABLE m_descriptor_def 
	ADD CONSTRAINT fk_m_descriptor_def_m_descriptor_class_1 FOREIGN KEY (m_descriptor_class_id) REFERENCES m_descriptor_class (m_descriptor_class_id),	
	ADD CONSTRAINT fk_m_descriptor_def_actor_1 FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
	ADD CONSTRAINT fk_m_descriptor_def_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);	

-- ALTER TABLE m_descriptor DROP CONSTRAINT fk_m_descriptor_material_1, 
-- DROP CONSTRAINT fk_m_descriptor_actor_1, 
-- DROP CONSTRAINT fk_m_descriptor_status_1,
-- DROP CONSTRAINT fk_m_descriptor_note_1;
ALTER TABLE m_descriptor 
--	ADD CONSTRAINT fk_m_descriptor_material_refname_1 FOREIGN KEY (material_refname_description_in, material_refname_type_in) REFERENCES material_refname (description, material_refname_type),
	ADD CONSTRAINT fk_m_descriptor_parent_1 FOREIGN KEY (parent_id) REFERENCES m_descriptor (m_descriptor_id),
	ADD CONSTRAINT fk_m_descriptor_actor_1 FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
	ADD CONSTRAINT fk_m_descriptor_status_1 FOREIGN KEY (status_id) REFERENCES status (status_id),	
	ADD CONSTRAINT fk_m_descriptor_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);
	
-- ALTER TABLE inventory  DROP CONSTRAINT fk_inventory_material_1, 
-- DROP CONSTRAINT fk_inventory_actor_1, 
-- DROP CONSTRAINT fk_inventory_measure_1,
-- DROP CONSTRAINT fk_inventory_note_1;
ALTER TABLE inventory 
	ADD CONSTRAINT fk_inventory_material_1 FOREIGN KEY (material_id) REFERENCES material (material_id),
	ADD CONSTRAINT fk_inventory_actor_1 FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
	ADD CONSTRAINT fk_inventory_status_1 FOREIGN KEY (status_id) REFERENCES status (status_id),	
	ADD CONSTRAINT fk_inventory_edocument_1 FOREIGN KEY (edocument_id) REFERENCES edocument (edocument_id),		
	ADD CONSTRAINT fk_inventory_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

ALTER TABLE measure 
	ADD CONSTRAINT fk_measure_measure_type_1 FOREIGN KEY (measure_type_id) REFERENCES measure_type (measure_type_id),
	ADD CONSTRAINT fk_measure_edocument_1 FOREIGN KEY (edocument_id) REFERENCES edocument (edocument_id),
	ADD CONSTRAINT fk_measure_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

 -- ALTER TABLE measure_type DROP CONSTRAINT fk_measure_type_note_1;
 ALTER TABLE measure_type 
	ADD CONSTRAINT fk_measure_type_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

-- ALTER TABLE measure_x DROP CONSTRAINT fk_measure_x_measure_1;
ALTER TABLE measure_x 
	ADD CONSTRAINT fk_measure_x_measure_1 FOREIGN KEY (ref_measure_uuid) REFERENCES measure (measure_uuid);

-- ALTER TABLE note DROP CONSTRAINT fk_note_edocument_1;
ALTER TABLE note 
	ADD CONSTRAINT fk_note_actor_1 FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
	ADD CONSTRAINT fk_note_edocument_1 FOREIGN KEY (edocument_id) REFERENCES edocument (edocument_id);	

-- ALTER TABLE edocument_x ADD CONSTRAINT "pk_edocument_x_edocument_x_id" PRIMARY KEY (edocument_x_id), ADD CONSTRAINT "un_edocument_x" UNIQUE (ref_uuid, edocument_id);
ALTER TABLE edocument_x
	ADD CONSTRAINT fk_edocument_x_edocument_1 FOREIGN KEY (edocument_id) REFERENCES edocument (edocument_id);

--ALTER TABLE tag DROP CONSTRAINT fk_tag_tag_type_1, 
--	DROP CONSTRAINT fk_tag_note_1;
ALTER TABLE tag 
	ADD CONSTRAINT fk_tag_tag_type_1 FOREIGN KEY (tag_type_id) REFERENCES tag_type (tag_type_id),
	ADD CONSTRAINT fk_tag_actor_1 FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
	ADD CONSTRAINT fk_tag_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

-- ALTER TABLE tag ADD CONSTRAINT "pk_tag_tag_id" PRIMARY KEY (tag_id);
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
	SET organization_id = 4
 WHERE organization_id = 4 RETURNING *;
 */



--=====================================
-- TABLE AND COLUMN COMMENTS
--=====================================
COMMENT ON TABLE organization IS 'organization information for ESCALATE person and system tool; can be component of actor';
  COMMENT ON COLUMN organization.organization_id IS 'primary key for organization records';
	COMMENT ON COLUMN organization.organization_uuid is 'uuid for this organization record';
	COMMENT ON COLUMN organization.parent_id is 'reference to parent organization; uses [internal] organization_id';
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
  COMMENT ON COLUMN organization.note_id is 'organization note; reference to note object which can be free text or blob';
  COMMENT ON COLUMN organization.add_date is 'date this record added';
  COMMENT ON COLUMN organization.mod_date is 'date this record updated';

--=====================================
-- VIEWS
--=====================================
-- integrated view of inventory; joins measure (amounts of material
CREATE OR REPLACE VIEW vw_actor AS 
SELECT
	act.actor_uuid AS actor_uuid,
	act.actor_id,
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
	st.vendor AS systemtool_vendor,
	st.model AS systemtool_model,
	st.serial AS systemtool_serial,
	st.ver AS systemtool_version,
	storg.full_name AS systemtool_org 
FROM
	actor act
	LEFT JOIN organization org ON act.organization_id = org.organization_id
	LEFT JOIN person per ON act.person_id = per.person_id
	LEFT JOIN organization porg ON per.organization_id = porg.organization_id
	LEFT JOIN systemtool st ON act.systemtool_id = st.systemtool_id
	LEFT JOIN systemtool_type stt ON st.systemtool_type_id = stt.systemtool_type_id
	LEFT JOIN organization storg ON st.organization_id = storg.organization_id
	LEFT JOIN note nt ON act.note_id = nt.note_id
	LEFT JOIN edocument_x docx ON nt.note_uuid = docx.ref_uuid
	LEFT JOIN edocument doc ON docx.edocument_x_id = doc.edocument_id
	LEFT JOIN status sts ON act.status_id = sts.status_id;
					
-- integrated view of inventory; joins actor...
-- CREATE OR REPLACE VIEW vw_inventory AS 
--	SELECT inv.inventory_id, inv.description, inv.material_id, inv.actor_id, act.actor_description, inv.part_no, inv.create_date, inv.mod_date, mm.measure_id, mm.amount, mm.unit
--		FROM inventory inv
--		LEFT JOIN measure mm 
--		ON inv.measure_id = mm.measure_id
--		left join get_actor() act
--		ON inv.actor_id = act.actor_id;

		
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
		st.organization_id,
		MAX ( st.ver ) AS ver 
	FROM
		systemtool st 
	WHERE
		st.systemtool_name IS NOT NULL 
		AND st.ver IS NOT NULL 
	GROUP BY
		st.systemtool_name,
		st.systemtool_type_id,
		st.organization_id 
	) mrs ON stl.systemtool_name = mrs.systemtool_name 
	AND stl.systemtool_type_id = mrs.systemtool_type_id 
	AND stl.organization_id = mrs.organization_id 
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
	mdd.m_descriptor_def_id,
	mdd.m_descriptor_def_uuid,
	mdd.short_name,
	mdd.calc_definition,
	mdd.description,
	mdd.actor_id,
	act.systemtool_org AS actor_org,
	act.systemtool_name AS actor_systemtool_name,
	act.systemtool_version AS actor_systemtool_version 
FROM
	m_descriptor_def mdd
	LEFT JOIN vw_actor act ON mdd.actor_id = act.actor_id;


-- get the descriptors and associated descriptor_def, including parent
-- if there is a parent descriptor, then use the parent m_descriptor_id (and type) as 
-- link back to material, otherwise use the current m_descriptor_id
CREATE OR REPLACE VIEW vw_m_descriptor AS 
SELECT
	md.m_descriptor_id, md.m_descriptor_uuid,
CASE
		WHEN md.parent_id ISNULL THEN
		md.m_descriptor_material_in ELSE mdp.m_descriptor_material_in 
	END AS material_ref,
CASE
		WHEN md.parent_id ISNULL THEN
		md.m_descriptor_material_type_in ELSE mdp.m_descriptor_material_type_in 
	END AS material_ref_type,
	md.m_descriptor_material_in AS descriptor_in,
	md.m_descriptor_material_type_in AS descriptor_type_in,
	md.create_date,
	md.num_valarray_out,
	encode( md.blob_val_out, 'escape' ) AS blob_val_out,
	md.blob_type_out,
	mdd.*,
	sts.description AS status 
FROM
	m_descriptor md
	LEFT JOIN m_descriptor mdp ON md.parent_id = mdp.m_descriptor_id
	LEFT JOIN vw_m_descriptor_def mdd ON md.m_descriptor_def_id = mdd.m_descriptor_def_id
	LEFT JOIN vw_actor dact ON md.actor_id = dact.actor_id
	LEFT JOIN status sts ON md.status_id = sts.status_id;


-- STUB get materials, all status
CREATE OR REPLACE VIEW vw_material AS 
SELECT *
FROM material mat;

-- get STUB materials and all descriptors, all status
CREATE OR REPLACE VIEW vw_material_descriptor AS 
SELECT *
FROM material mat;

-- get STUB inventory, all status
CREATE OR REPLACE VIEW vw_inventory AS 
SELECT *
FROM inventory inv;

-- STUB get inventory / material, all status
CREATE OR REPLACE VIEW vw_inventory_material AS 
SELECT *
FROM inventory inv;

-- STUB get inventory / material / descriptors, all status
CREATE OR REPLACE VIEW vw_inventory_material_descriptor AS 
SELECT *
FROM inventory inv; 