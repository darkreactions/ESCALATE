/*
Name:					prod_data_initialize_tables
Parameters:		none
Returns:			none
Author:				G. Cattabriga
Date:					2019.12.02
Description:	initialize production tables with data
Notes:				code for parsing chem inventory data is contained in other file(s)
*/

-- ----------------------------
-- Records of organization
-- ----------------------------
/*
  organization_id serial8,
	organization_uuid uuid,
  description varchar(255),
  full_name varchar(255),
	short_name varchar(255)
  address1 varchar(255),
  address2 varchar(255),
  city varchar(255),
  state_province char(3) ,
  zip varchar(255),
  country varchar(255),
  website_url varchar(255),
  phone varchar(255),
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
*/
BEGIN;
INSERT INTO organization (description, full_name, short_name, address1, address2, city, state_province, zip, website_url, phone, note_id) 
VALUES 
	('College', 'Haverford College', 'HC', '370 Lancaster Ave.', NULL, 'Haverford', 'PA   ', '19041', 'http://www.haverford.edu', NULL, NULL),
	('Laboratory', 'Lawrence Berkeley National Laboratory', 'LBL', '1 Cyclotron Rd.', NULL, 'Berkeley', 'CA   ', '94720', 'https://www.lbl.gov', NULL, NULL),
	('Chemical vendor', 'Sigma-Aldrich', 'Sigma-Aldrich', '3050 Spruce St.', NULL, 'St Louis', 'MO   ', '63103', 'http://www.sigmaaldrich.com', NULL, NULL),
	('Chemical vendor', 'Greatcell', 'Greatcell', NULL, NULL, 'Elanora', 'QLD  ', '4221', 'http://www.greatcellsolar.com/shop/', NULL, NULL),
	('Cheminfomatics software', 'ChemAxon', 'ChemAxon', NULL, NULL, NULL, NULL, NULL, 'https://chemaxon.com', NULL, NULL),
	('Cheminfomatics software', 'RDKit open source software', 'RDKit', NULL, NULL, NULL, NULL, NULL, 'https://www.rdkit.org', NULL, NULL);
COMMIT;


-- ----------------------------
-- Records of systemtool_type
-- ----------------------------
/*
  systemtype_id serial8 NOT NULL,
	systemtype_uuid uuid,
  description varchar(255),
  note_id int8,
  add_date" timestamptz NOT NULL DEFAULT NOW(),
  mod_date" timestamptz NOT NULL DEFAULT NOW()
*/
BEGIN;
INSERT INTO systemtool_type (description) 
VALUES 
	('Command-line tool'),
	('API'),
	('Python toolkit');
COMMIT;

-- ----------------------------
-- Records of systemtool
-- ----------------------------
/*
  system_id serial8,
	system_uuid uuid,
  name varchar(255),
  description varchar(255),
  systemtype_id" int8,
  vendor varchar(255),
  model varchar(255),
  serial varchar(255),
  version varchar(255),
  organization_id int8,
  note_id int8,
  alias varchar(255),
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
*/
BEGIN;
INSERT INTO systemtool (systemtool_name, description, systemtool_type_id, vendor, model, serial, ver, organization_id, note_id)
VALUES 
	('standardize', 'Chemical standardizer', 
		(select systemtool_type_id from systemtool_type where description = 'Command-line tool'), 
		'ChemAxon', NULL, NULL, '19.24.0', 
		(select organization_id from organization where full_name = 'ChemAxon'),
		NULL),
	('cxcalc', 'Chemical descriptor calculator',
		(select systemtool_type_id from systemtool_type where description = 'Command-line tool'), 
		'ChemAxon', NULL, NULL, '19.24.0', 
		(select organization_id from organization where full_name = 'ChemAxon'),
		NULL),
	('generatemd', 'Chemical fingerprint calculator',
		(select systemtool_type_id from systemtool_type where description = 'Command-line tool'),
		'ChemAxon', NULL, NULL, '19.6.0', 
		(select organization_id from organization where full_name = 'ChemAxon'),
		NULL),
	('RDKit', 'Cheminformatics toolkit for Python', 
		(select systemtool_type_id from systemtool_type where description = 'Python toolkit'),
		'Open Source: RDKit', NULL, NULL, '19.03.4', 
		(select organization_id from organization where short_name = 'RDKit'),
		NULL);
COMMIT;

-- ----------------------------
-- Records of person
-- ----------------------------
/*
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
*/
BEGIN;
INSERT INTO person (firstname, lastname, email, organization_id)
VALUES 
	('Mansoor', 'Nellikkal', 'maninajeeb@haverford.edu', 
		(select organization_id from organization where short_name = 'HC')),
	('Zhi', 'Li', 'zhili@lbl.gov', 
		(select organization_id from organization where short_name = 'LBL')),
	('Ian', 'Pendleton', 'ipendleton@haverford.edu ', 
		(select organization_id from organization where short_name = 'HC'))
;
COMMIT;

-- ----------------------------
-- Records of actor
-- ----------------------------
/*
  actor_id serial8,
	actor_uuid uuid,
  person_id int8,
  organization_id int8,
  system_id int8,
  description varchar(255),
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
*/
BEGIN;
INSERT INTO actor (person_id, organization_id, systemtool_id, description)  
VALUES 
	-- haverford college as an actor
	((select person_id from person where lastname = 'Nellikkal'), 
		(select organization_id from person where lastname = 'Nellikkal'),
		NULL, 'Mansoor'),
	((select person_id from person where lastname = 'Li'), 
		(select organization_id from person where lastname = 'Li'),
		NULL, 'Zhi'),	
	((select person_id from person where lastname = 'Pendleton'), 
		(select organization_id from person where lastname = 'Pendleton'),
		NULL, 'Ian'),
	(NULL, 
		(select organization_id from organization where short_name = 'HC'),
		NULL, 'Haverford College'),
	-- LBL as an actor
	(NULL, 
		(select organization_id from organization where short_name = 'LBL'),
		NULL, 'LBL'),
	(NULL, 
		(select organization_id from organization where short_name = 'Sigma-Aldrich'),
		NULL, 'Sigma-Aldrich'),
	(NULL, 
		(select organization_id from organization where short_name = 'Greatcell'),
		NULL, 'Greatcell'),		
	(NULL, 
		(select organization_id from organization where short_name = 'ChemAxon'),
		NULL, 'ChemAxon'),		
	(NULL, 
		(select organization_id from organization where short_name = 'RDKit'),
		NULL, 'RDKit'),			
	(NULL, 
		(select organization_id from organization where short_name = 'ChemAxon'),
		(select systemtool_id from systemtool where systemtool_name = 'standardize'), 
		'ChemAxon: standardize'),		
	(NULL, 
		(select organization_id from organization where short_name = 'ChemAxon'),
		(select systemtool_id from systemtool where systemtool_name = 'cxcalc'), 
		'ChemAxon: cxcalc'),		
	(NULL, 
		(select organization_id from organization where short_name = 'ChemAxon'),
		(select systemtool_id from systemtool where systemtool_name = 'generatemd'), 
		'ChemAxon: generatemd'),
	(NULL, 
		(select organization_id from organization where short_name = 'RDKit'),
		(select systemtool_id from systemtool where systemtool_name = 'RDKit'), 
		'RDKit: Python toolkit');	
COMMIT;

-- ----------------------------
-- Records of status
-- ----------------------------
/*
	status_id serial8,
  description varchar(255) COLLATE "pg_catalog"."default",
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
*/
BEGIN;
INSERT INTO status (description)
VALUES 
	('active'),
	('inactive'),
	('test'),
	('do not use'),
	('prototype')
;
COMMIT;



