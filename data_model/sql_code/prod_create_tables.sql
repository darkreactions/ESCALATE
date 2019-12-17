/*
Name:					prod_create_tables
Parameters:		none
Returns:			
Author:				G. Cattabriga
Date:					2019.12.02
Description:	create the production tables, primary keys and comments for ESCALATEv3
Notes:				triggers, foreign keys and other constraints are in other sql files
*/
 --=====================================
 -- CREATE TABLES 
 --=====================================
---------------------------------------
-- Table structure for organization
---------------------------------------
DROP TABLE IF EXISTS organization cascade;
CREATE TABLE organization (
  organization_id serial8,
	organization_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar(255) COLLATE "pg_catalog"."default",
  full_name varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  short_name varchar(255) COLLATE "pg_catalog"."default",	
  address1 varchar(255) COLLATE "pg_catalog"."default",
  address2 varchar(255) COLLATE "pg_catalog"."default",
  city varchar(255) COLLATE "pg_catalog"."default",
  state_province char(3) COLLATE "pg_catalog"."default",
  zip varchar(255) COLLATE "pg_catalog"."default",
  country varchar(255) COLLATE "pg_catalog"."default",	
  website_url varchar(255) COLLATE "pg_catalog"."default",
  phone varchar(255) COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

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

---------------------------------------
-- Table structure for person
---------------------------------------
DROP TABLE IF EXISTS person cascade;
CREATE TABLE person (
  person_id serial8,
  person_uuid uuid DEFAULT uuid_generate_v4 (),	
  firstname varchar(255) COLLATE "pg_catalog"."default",
  lastname varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  middlename varchar(255) COLLATE "pg_catalog"."default",
  address1 varchar(255) COLLATE "pg_catalog"."default",
  address2 varchar(255) COLLATE "pg_catalog"."default",
  city varchar(255) COLLATE "pg_catalog"."default",
  stateprovince char(3) COLLATE "pg_catalog"."default",
  phone varchar(255) COLLATE "pg_catalog"."default",
  email varchar(255) COLLATE "pg_catalog"."default",
  title varchar(255) COLLATE "pg_catalog"."default",
  suffix varchar(255) COLLATE "pg_catalog"."default",
  organization_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for systemtool
---------------------------------------
DROP TABLE IF EXISTS systemtool cascade;
CREATE TABLE systemtool (
  systemtool_id serial8,
  systemtool_uuid uuid DEFAULT uuid_generate_v4 (),
  systemtool_name varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  description varchar(255) COLLATE "pg_catalog"."default",
  systemtool_type_id int8,
  vendor varchar(255) COLLATE "pg_catalog"."default",
  model varchar(255) COLLATE "pg_catalog"."default",
  serial varchar(255) COLLATE "pg_catalog"."default",
  ver varchar(255) COLLATE "pg_catalog"."default",
  organization_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for systemtool_type
---------------------------------------
DROP TABLE IF EXISTS systemtool_type cascade;
CREATE TABLE systemtool_type (
  systemtool_type_id serial8 NOT NULL,
  systemtool_type_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar(255) COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for actor
---------------------------------------
DROP TABLE IF EXISTS actor cascade;
CREATE TABLE actor (
  actor_id serial8,
  actor_uuid uuid DEFAULT uuid_generate_v4 (),
  person_id int8,
  organization_id int8,
  systemtool_id int8,
  description varchar(255) COLLATE "pg_catalog"."default",
	status_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material
---------------------------------------
DROP TABLE IF EXISTS material cascade;
CREATE TABLE material (
  material_id serial8,
  material_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default" NOT NULL,
  parent_material_id int8,
--  "material_ref_id" int8,
--  actor_id int8,
--  "descriptor_id" int8,
--  "alt_material_name_id" int8,
	status_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_type
---------------------------------------
DROP TABLE IF EXISTS material_type cascade;
CREATE TABLE material_type (
  material_type_id serial8,
  material_type_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar(255) COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_ref
---------------------------------------
DROP TABLE IF EXISTS material_ref cascade;
CREATE TABLE material_ref (
  material_ref_id serial8,
  material_ref_uuid uuid DEFAULT uuid_generate_v4 (),
	material_id int8,
  material_type_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for material_name
---------------------------------------
DROP TABLE IF EXISTS material_name cascade;
CREATE TABLE material_name (
  material_name_id serial8,
	material_name_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  material_id int8,		
  material_name_type varchar(255) COLLATE "pg_catalog"."default",
  reference varchar(255) COLLATE "pg_catalog"."default",
	status_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for descriptor
---------------------------------------
DROP TABLE IF EXISTS m_descriptor cascade;
CREATE TABLE m_descriptor (
  m_descriptor_id serial8,
	m_descriptor_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  material_id int8,
  m_descriptor_class_id int8,
  m_descriptor_value_id int8,
  actor_id int8,
  status_id int8,
  ver varchar(255) COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for descriptor_class
---------------------------------------
DROP TABLE IF EXISTS m_descriptor_class cascade;
CREATE TABLE m_descriptor_class (
  m_descriptor_class_id serial8,
	m_descriptor_class_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar(255) COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for descriptor_value
---------------------------------------
DROP TABLE IF EXISTS m_descriptor_value cascade;
CREATE TABLE m_descriptor_value (
  m_descriptor_value_id serial8,
	m_descriptor_value_uuid uuid DEFAULT uuid_generate_v4 (),
  num_value DOUBLE PRECISION,
  blob_value bytea,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for inventory
---------------------------------------
DROP TABLE IF EXISTS inventory cascade;
CREATE TABLE inventory (
  inventory_id serial8,
	inventory_uuid uuid DEFAULT uuid_generate_v4 (),
	description varchar,
  material_id int8 NOT NULL,
  actor_id int8,
	part_no varchar,
	onhand_amt  DOUBLE PRECISION,
	unit varchar,
	measure_id int8,
  create_dt timestamptz NOT NULL DEFAULT NOW(),
  expiration_dt timestamptz DEFAULT NULL,
  inventory_location varchar(255) COLLATE "pg_catalog"."default",
	status_id int8,
	document_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure
---------------------------------------
DROP TABLE IF EXISTS measure cascade;
CREATE TABLE measure (
  measure_id serial8,
	measure_uuid uuid DEFAULT uuid_generate_v4 (),
  measure_type_id int8,
  amount DOUBLE PRECISION,
  unit varchar(255) COLLATE "pg_catalog"."default",
	blob_amount bytea,
  document_id int8,
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for measure_type
---------------------------------------
DROP TABLE IF EXISTS measure_type cascade;
CREATE TABLE measure_type (
	measure_type_id serial8,
	measure_type_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar(255) COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

---------------------------------------
-- Table structure for note
---------------------------------------
DROP TABLE IF EXISTS note cascade;
CREATE TABLE note (
  note_id serial8,
	note_uuid uuid DEFAULT uuid_generate_v4 (),
  notetext varchar COLLATE "pg_catalog"."default",
  edocument_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for document
-- ----------------------------
DROP TABLE IF EXISTS edocument cascade;
CREATE TABLE edocument (
  edocument_id serial8,
	edocument_uuid uuid DEFAULT uuid_generate_v4 (),
  description varchar COLLATE "pg_catalog"."default",
  edocument bytea,
  edoc_type varchar(255) COLLATE "pg_catalog"."default",
  ver varchar(255) COLLATE "pg_catalog"."default",
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for tag
-- ----------------------------
DROP TABLE IF EXISTS tag cascade;
CREATE TABLE tag (
  tag_id serial8,
	tag_uuid uuid DEFAULT uuid_generate_v4 (),
	tag_type_id int8,
  description varchar COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for tag_type
-- ----------------------------
DROP TABLE IF EXISTS tag_type cascade;
CREATE TABLE tag_type (
  tag_type_id serial8,
	tag_type_uuid uuid DEFAULT uuid_generate_v4 (),
	short_desscription varchar(32) COLLATE "pg_catalog"."default",
  description varchar(255) COLLATE "pg_catalog"."default",
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);

-- ----------------------------
-- Table structure for status
-- ----------------------------
DROP TABLE IF EXISTS status cascade;
CREATE TABLE status (
  status_id serial8,
  description varchar(255) COLLATE "pg_catalog"."default",
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
);


--=====================================
-- KEYS
--=====================================
ALTER TABLE organization ADD 
	CONSTRAINT "pk_organization_organization_id" PRIMARY KEY (organization_id);
CLUSTER organization USING "pk_organization_organization_id";

ALTER TABLE person ADD 
	CONSTRAINT "pk_person_person_id" PRIMARY KEY (person_id);
CLUSTER person USING "pk_person_person_id";

ALTER TABLE systemtool ADD 
	CONSTRAINT "pk_systemtool_systemtool_id" PRIMARY KEY (systemtool_id);
CLUSTER systemtool USING "pk_systemtool_systemtool_id";

ALTER TABLE systemtool_type ADD 
	CONSTRAINT "pk_systemtool_systemtool_type_id" PRIMARY KEY (systemtool_type_id);
CLUSTER systemtool_type USING "pk_systemtool_systemtool_type_id";

ALTER TABLE actor ADD 
	CONSTRAINT "pk_actor_id" PRIMARY KEY (actor_id),
	ADD CONSTRAINT "un_actor" UNIQUE (person_id, organization_id, systemtool_id);
CLUSTER actor USING "pk_actor_id";

ALTER TABLE material ADD 
	CONSTRAINT "pk_material_material_id" PRIMARY KEY (material_id);
CLUSTER material USING "pk_material_material_id";

ALTER TABLE material_type ADD 
	CONSTRAINT "pk_material_type_material_type_id" PRIMARY KEY (material_type_id);
CLUSTER material_type USING "pk_material_type_material_type_id";

ALTER TABLE material_ref ADD 
	CONSTRAINT "pk_material_ref_material_ref_id" PRIMARY KEY (material_ref_id);
CLUSTER material_ref USING "pk_material_ref_material_ref_id";

ALTER TABLE material_name ADD 
	CONSTRAINT "pk_material_name_material_name_id" PRIMARY KEY (material_name_id);
CLUSTER material_name USING "pk_material_name_material_name_id";

ALTER TABLE m_descriptor ADD 
	CONSTRAINT "pk_m_descriptor_m_descriptor_id" PRIMARY KEY (m_descriptor_id);
CLUSTER m_descriptor USING "pk_m_descriptor_m_descriptor_id";

ALTER TABLE m_descriptor_class ADD 
	CONSTRAINT "pk_m_descriptor_class_m_descriptor_class_id" PRIMARY KEY (m_descriptor_class_id);
CLUSTER m_descriptor_class USING "pk_m_descriptor_class_m_descriptor_class_id";

ALTER TABLE m_descriptor_value ADD 
	CONSTRAINT "pk_m_descriptor_value_m_descriptor_value_id" PRIMARY KEY (m_descriptor_value_id);
CLUSTER m_descriptor_value USING "pk_m_descriptor_value_m_descriptor_value_id";

ALTER TABLE inventory 
	ADD CONSTRAINT "pk_inventory_inventory_id" PRIMARY KEY (inventory_id),
	ADD CONSTRAINT "un_inventory" UNIQUE (material_id, actor_id, create_dt);
CLUSTER inventory USING "pk_inventory_inventory_id";

ALTER TABLE measure ADD 
	CONSTRAINT "pk_measure_measure_id" PRIMARY KEY (measure_id);
CLUSTER measure USING "pk_measure_measure_id";

ALTER TABLE measure_type ADD 
	CONSTRAINT "pk_measure_type_measure_type_id" PRIMARY KEY (measure_type_id);
CLUSTER measure_type USING "pk_measure_type_measure_type_id";

ALTER TABLE note ADD 
	CONSTRAINT "pk_note_note_id" PRIMARY KEY (note_id);
CLUSTER note USING "pk_note_note_id";

ALTER TABLE edocument ADD 
	CONSTRAINT "pk_edocument_edocument_id" PRIMARY KEY (edocument_id);
CLUSTER edocument USING "pk_edocument_edocument_id";

ALTER TABLE tag ADD 
	CONSTRAINT "pk_tag_tag_id" PRIMARY KEY (tag_id);
CLUSTER tag USING "pk_tag_tag_id";

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
	ADD CONSTRAINT fk_material_material_1 FOREIGN KEY (parent_material_id) REFERENCES material (material_id),
	ADD CONSTRAINT fk_material_status_1 FOREIGN KEY (status_id) REFERENCES status (status_id),	
	ADD CONSTRAINT fk_material_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);
	
-- ALTER TABLE material_type DROP CONSTRAINT fk_material_type_note_1;
ALTER TABLE material_type 
	ADD CONSTRAINT fk_material_type_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

--ALTER TABLE material_ref DROP CONSTRAINT fk_material_ref_material_1, 
--	DROP CONSTRAINT fk_material_ref_material_type_1;
ALTER TABLE material_ref 
	ADD CONSTRAINT fk_material_ref_material_1 FOREIGN KEY (material_id) REFERENCES material (material_id),
	ADD CONSTRAINT fk_material_ref_material_type_1 FOREIGN KEY (material_type_id) REFERENCES material_type (material_type_id);

--ALTER TABLE alt_material_name DROP CONSTRAINT fk_alt_material_name_material_1, 
--	DROP CONSTRAINT fk_alt_material_name_note_1;
ALTER TABLE material_name 
	ADD CONSTRAINT fk_material_name_material_1 FOREIGN KEY (material_id) REFERENCES material (material_id),
	ADD CONSTRAINT fk_material_name_status_1 FOREIGN KEY (status_id) REFERENCES status (status_id),	
	ADD CONSTRAINT fk_material_name_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

-- ALTER TABLE m_descriptor DROP CONSTRAINT fk_m_descriptor_material_1, 
-- DROP CONSTRAINT fk_m_descriptor_actor_1, 
-- DROP CONSTRAINT fk_m_descriptor_m_descriptor_class_1,
-- DROP CONSTRAINT fk_m_descriptor_m_descriptor_value_1, 
-- DROP CONSTRAINT fk_m_descriptor_status_1,
-- DROP CONSTRAINT fk_m_descriptor_note_1;
ALTER TABLE m_descriptor 
	ADD CONSTRAINT fk_m_descriptor_material_1 FOREIGN KEY (material_id) REFERENCES material (material_id),
	ADD CONSTRAINT fk_m_descriptor_actor_1 FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
	ADD CONSTRAINT fk_m_descriptor_m_descriptor_class_1 FOREIGN KEY (m_descriptor_class_id) REFERENCES m_descriptor_class (m_descriptor_class_id),	
	ADD CONSTRAINT fk_m_descriptor_m_descriptor_value_1 FOREIGN KEY (m_descriptor_value_id) REFERENCES m_descriptor_value (m_descriptor_value_id),	
	ADD CONSTRAINT fk_m_descriptor_status_1 FOREIGN KEY (status_id) REFERENCES status (status_id),
	ADD CONSTRAINT fk_m_descriptor_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);
	
-- ALTER TABLE m_descriptor_class DROP CONSTRAINT fk_m_descriptor_class_note_1;
ALTER TABLE m_descriptor_class 
	ADD CONSTRAINT fk_m_descriptor_class_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

-- ALTER TABLE inventory  DROP CONSTRAINT fk_inventory_material_1, 
-- DROP CONSTRAINT fk_inventory_actor_1, 
-- DROP CONSTRAINT fk_inventory_measure_1,
-- DROP CONSTRAINT fk_inventory_note_1;
ALTER TABLE inventory 
	ADD CONSTRAINT fk_inventory_material_1 FOREIGN KEY (material_id) REFERENCES material (material_id),
	ADD CONSTRAINT fk_inventory_actor_1 FOREIGN KEY (actor_id) REFERENCES actor (actor_id),
	ADD CONSTRAINT fk_inventory_status_1 FOREIGN KEY (status_id) REFERENCES status (status_id),	
	ADD CONSTRAINT fk_inventory_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

-- ALTER TABLE measure_type DROP CONSTRAINT fk_measure_type_note_1;
ALTER TABLE measure_type 
	ADD CONSTRAINT fk_measure_type_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);
	
-- ALTER TABLE note DROP CONSTRAINT fk_note_edocument_1;
ALTER TABLE note 
	ADD CONSTRAINT fk_note_edocument_1 FOREIGN KEY (edocument_id) REFERENCES edocument (edocument_id);	

--ALTER TABLE tag DROP CONSTRAINT fk_tag_tag_type_1, 
--	DROP CONSTRAINT fk_tag_note_1;
ALTER TABLE tag 
	ADD CONSTRAINT fk_tag_tag_type_1 FOREIGN KEY (tag_type_id) REFERENCES tag_type (tag_type_id),
	ADD CONSTRAINT fk_tag_note_1 FOREIGN KEY (note_id) REFERENCES note (note_id);

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



--=====================================
-- TABLE AND COLUMN COMMENTS
--=====================================
COMMENT ON TABLE organization IS 'organization information for ESCALATE users, vendors, and other actors';
  COMMENT ON COLUMN organization.organization_id IS 'Primary key for organization records';



--=====================================
-- VIEWS
--=====================================
CREATE OR REPLACE VIEW vw_inventory AS 
	SELECT inv.inventory_id, inv.description, inv.material_id, inv.actor_id, inv.part_no, inv.create_dt, inv.mod_date, mm.measure_id, mm.amount, mm.unit
		FROM inventory inv
		LEFT JOIN measure mm 
		ON inv.measure_id = mm.measure_id;


