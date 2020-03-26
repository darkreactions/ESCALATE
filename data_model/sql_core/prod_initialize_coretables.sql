/*
Name:					prod_initialize_coretables
Parameters:		none
Returns:			none
Author:				G. Cattabriga
Date:					2020.01.23
Description:	initialize core production tables organization, person, systemtool and actor with data
Notes:				code for parsing chem inventory data is contained in other file(s)
							20200123: - reorganize the actors so that persons or systemtools are not redundantly defined by 
							there parent organization
*/

-- ----------------------------
-- Records of status
-- ----------------------------
/*
	status_uuid serial8,
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
	('do_not_use'),
	('prototype')
;
COMMIT;

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
INSERT INTO organization (description, full_name, short_name, address1, address2, city, state_province, zip, website_url, phone, note_uuid) 
VALUES 
	('College', 'Haverford College', 'HC', '370 Lancaster Ave.', NULL, 'Haverford', 'PA   ', '19041', 'http://www.haverford.edu', NULL, NULL),
	('Laboratory', 'Lawrence Berkeley National Laboratory', 'LBNL', '1 Cyclotron Rd.', NULL, 'Berkeley', 'CA   ', '94720', 'https://www.lbl.gov', NULL, NULL),
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
	('Python toolkit'),
	('ESCALATE function');
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
INSERT INTO systemtool (systemtool_name, description, systemtool_type_id, vendor_organization_id, model, serial, ver, note_uuid)
VALUES 
	('standardize', 'Molecule Standardizer', 
		(select systemtool_type_id from systemtool_type where description = 'Command-line tool'), 
		(select organization_id from organization where short_name = 'ChemAxon'), NULL, NULL, '19.27.0', NULL),
	('cxcalc', 'Molecular Descriptor Generator',
		(select systemtool_type_id from systemtool_type where description = 'Command-line tool'), 
		(select organization_id from organization where short_name = 'ChemAxon'), NULL, NULL, '19.27.0', NULL),
	('molconvert', 'Molecule File Converter',
		(select systemtool_type_id from systemtool_type where description = 'Command-line tool'), 
		(select organization_id from organization where short_name = 'ChemAxon'), NULL, NULL, '19.27.0', NULL),
	('generatemd', 'Molecular Descriptor Generator',
		(select systemtool_type_id from systemtool_type where description = 'Command-line tool'),
		(select organization_id from organization where short_name = 'ChemAxon'), NULL, NULL, '19.6.0', NULL),
	('RDKit', 'Cheminformatics Toolkit for Python', 
		(select systemtool_type_id from systemtool_type where description = 'Python toolkit'),
		(select organization_id from organization where short_name = 'RDKit'), NULL, NULL, '19.03.4', NULL),
	('escalate', 'ESCALATE function call', 
		(select systemtool_type_id from systemtool_type where description = 'ESCALATE function'),
		(select organization_id from organization where short_name = 'Haverford'), NULL, NULL, 'V3', NULL)
;
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
		(select organization_id from organization where short_name = 'LBNL')),
	('Ian', 'Pendleton', 'ipendleton@haverford.edu ', 
		(select organization_id from organization where short_name = 'HC')),
	('Gary', 'Cattabriga', 'gcattabrig@haverford.edu ', 
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
INSERT INTO actor (person_id, organization_id, systemtool_id, description, status_uuid)  
VALUES 
	-- haverford college as an actor
	((select person_id from person where lastname = 'Nellikkal'), 
		(select organization_id from organization where short_name = 'HC'), NULL, 
		'Mansoor Nellikkal', (select status_uuid from status where description = 'active')),
	((select person_id from person where lastname = 'Li'), 
		(select organization_id from organization where short_name = 'LBNL'), NULL, 
		'Zhi Li', (select status_uuid from status where description = 'active')),	
	((select person_id from person where lastname = 'Pendleton'), 
		(select organization_id from organization where short_name = 'HC'), NULL, 
		'Ian Pendleton', (select status_uuid from status where description = 'active')),
	((select person_id from person where lastname = 'Cattabriga'), 
		(select organization_id from organization where short_name = 'HC'), NULL, 
		'Gary Cattabriga', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_id from organization where short_name = 'HC'),
		NULL, 'Haverford College', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_id from organization where short_name = 'LBNL'),
		NULL, 'LBNL', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_id from organization where short_name = 'Sigma-Aldrich'),
		NULL, 'Sigma-Aldrich', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_id from organization where short_name = 'Greatcell'),
		NULL, 'Greatcell', (select status_uuid from status where description = 'active')),		
	(NULL, 
		(select organization_id from organization where short_name = 'ChemAxon'),
		NULL, 'ChemAxon', (select status_uuid from status where description = 'active')),		
	(NULL, 
		(select organization_id from organization where short_name = 'RDKit'),
		NULL, 'RDKit', (select status_uuid from status where description = 'active')),			
	(NULL, (select organization_id from organization where short_name = 'HC'), 
		(select systemtool_id from systemtool where systemtool_name = 'standardize'), 
		'ChemAxon: standardize', (select status_uuid from status where description = 'active')),		
	(NULL, (select organization_id from organization where short_name = 'HC'), 
		(select systemtool_id from systemtool where systemtool_name = 'cxcalc'), 
		'ChemAxon: cxcalc', (select status_uuid from status where description = 'active')),		
	(NULL, (select organization_id from organization where short_name = 'HC'), 
		(select systemtool_id from systemtool where systemtool_name = 'molconvert'), 
		'ChemAxon: molconvert', (select status_uuid from status where description = 'active')),		
	(NULL, (select organization_id from organization where short_name = 'HC'), 
		(select systemtool_id from systemtool where systemtool_name = 'generatemd'), 
		'ChemAxon: generatemd', (select status_uuid from status where description = 'active')),
	(NULL, (select organization_id from organization where short_name = 'HC'), 
		(select systemtool_id from systemtool where systemtool_name = 'RDKit'), 
		'RDKit: Python toolkit', (select status_uuid from status where description = 'active')),
	(NULL, (select organization_id from organization where short_name = 'HC'), 
		(select systemtool_id from systemtool where systemtool_name = 'escalate'), 
		'escalate: system function call', (select status_uuid from status where description = 'active'))
;	
COMMIT;


-- ----------------------------
-- Records of actor_pref
-- ----------------------------
/*
  actor_pref_id serial8,
  actor_pref_uuid uuid DEFAULT uuid_generate_v4 (),
  actor_id int8,
	pkey varchar(255) COLLATE "pg_catalog"."default",
  pvalue varchar COLLATE "pg_catalog"."default",
  note_id int8,
  add_date timestamptz NOT NULL DEFAULT NOW(),
  mod_date timestamptz NOT NULL DEFAULT NOW()
*/
BEGIN;
INSERT INTO actor_pref (actor_uuid, pkey, pvalue)  
VALUES 
	-- for GC actor, set up environment variables
	((select actor_uuid from vw_actor where per_lastname = 'Cattabriga'), 'HOME_DIR', '/Users/gcattabriga/'),	
	((select actor_uuid from vw_actor where per_lastname = 'Cattabriga'), 'MARVINSUITE_DIR', '/Applications/MarvinSuite/bin/'),
	((select actor_uuid from vw_actor where per_lastname = 'Cattabriga'), 'CHEMAXON_DIR', '/Applications/ChemAxon/JChemSuite/bin/')
	;	
COMMIT;




