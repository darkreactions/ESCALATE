/*
Name:			prod_initialize_coretables
Parameters:		none
Returns:		none
Author:			G. Cattabriga
Date:			2020.01.23
Description:	initialize core production tables organization, person, systemtool and actor with data
Notes:			code for parsing chem inventory data is contained in other file(s)
				20200123: - reorganize the actors so that persons or systemtools are not redundantly defined by 
				there parent organization
*/

-- ----------------------------
-- Records of status
-- ----------------------------
BEGIN;
	insert into vw_status (description) values ('active');
	insert into vw_status (description) values ('inactive');
	insert into vw_status (description) values ('test');
	insert into vw_status (description) values ('do_not_use');
	insert into vw_status (description) values ('prototype');
COMMIT;


-- ----------------------------
-- Records of organization
-- ----------------------------
BEGIN;
INSERT INTO vw_organization (description, full_name, short_name, address1, address2, city, state_province, zip, country, website_url, phone) 
VALUES 
	('College', 'Haverford College', 'HC', '370 Lancaster Ave.', NULL, 'Haverford', 'PA', '19041', 'US','http://www.haverford.edu', NULL),
	('Laboratory', 'Lawrence Berkeley National Laboratory', 'LBL', '1 Cyclotron Rd.', NULL, 'Berkeley', 'CA', '94720', 'US', 'https://www.lbl.gov', NULL),
	('Chemical vendor', 'Sigma-Aldrich', 'Sigma-Aldrich', '3050 Spruce St.', NULL, 'St Louis', 'MO', '63103', 'US', 'http://www.sigmaaldrich.com', NULL),
	('Chemical vendor', 'Greatcell Solar', 'Greatcell', '3 Dominion Place', NULL, 'Queanbeyan', 'NSW', '2620', 'AUS', 'http://www.greatcellsolar.com/shop/', NULL),
	('Cheminfomatics software', 'ChemAxon', 'ChemAxon', NULL, NULL, NULL, NULL, NULL, 'US', 'https://chemaxon.com', NULL),
	('Cheminfomatics software', 'RDKit open source software', 'RDKit', NULL, NULL, NULL, NULL, NULL, NULL,'https://www.rdkit.org', NULL),
	('Laboratory', 'Emerald Cloud Lab', 'ECL', '844 Dubuque Ave', NULL, 'South San Francisco', 'CA', '94080', 'US', 'https://www.emeraldcloudlab.com', NULL),
	('DBMS', 'PostgreSQL', 'postgres', NULL, NULL, NULL, NULL, NULL, NULL, 'https://www.postgresql.org', NULL);
COMMIT;


-- ----------------------------
-- Records of systemtool_type
-- ----------------------------
BEGIN;
INSERT INTO vw_systemtool_type (description) VALUES ('Command-line tool');
INSERT INTO vw_systemtool_type (description) VALUES ('API');
INSERT INTO vw_systemtool_type (description) VALUES ('Python toolkit');
INSERT INTO vw_systemtool_type (description) VALUES ('ESCALATE function');
INSERT INTO vw_systemtool_type (description) VALUES ('Database Management System');
COMMIT;

-- ----------------------------
-- Records of systemtool
-- ----------------------------
BEGIN;
INSERT INTO vw_systemtool (systemtool_name, description, systemtool_type_uuid, vendor_organization_uuid, model, serial, ver)
VALUES 
	('standardize', 'Molecule Standardizer', 
		(select systemtool_type_uuid from systemtool_type where description = 'Command-line tool'), 
		(select organization_uuid from organization where short_name = 'ChemAxon'), NULL, NULL, '19.27.0'),
	('cxcalc', 'Molecular Descriptor Generator',
		(select systemtool_type_uuid from systemtool_type where description = 'Command-line tool'), 
		(select organization_uuid from organization where short_name = 'ChemAxon'), NULL, NULL, '19.27.0'),
	('molconvert', 'Molecule File Converter',
		(select systemtool_type_uuid from systemtool_type where description = 'Command-line tool'), 
		(select organization_uuid from organization where short_name = 'ChemAxon'), NULL, NULL, '19.27.0'),
	('generatemd', 'Molecular Descriptor Generator',
		(select systemtool_type_uuid from systemtool_type where description = 'Command-line tool'),
		(select organization_uuid from organization where short_name = 'ChemAxon'), NULL, NULL, '19.6.0'),
	('RDKit', 'Cheminformatics Toolkit for Python', 
		(select systemtool_type_uuid from systemtool_type where description = 'Python toolkit'),
		(select organization_uuid from organization where short_name = 'RDKit'), NULL, NULL, '19.03.4'),
	('escalate', 'ESCALATE function call', 
		(select systemtool_type_uuid from systemtool_type where description = 'ESCALATE function'),
		(select organization_uuid from organization where short_name = 'HC'), NULL, NULL, '3.0.0'),
	('postgres', 'PostgreSQL DBMS',
		(select systemtool_type_uuid from systemtool_type where description = 'Database Management System'),
		(select organization_uuid from organization where short_name = 'HC'), NULL, NULL, '12.0')	
;
COMMIT;

-- ----------------------------
-- Records of person
-- ----------------------------
BEGIN;
INSERT INTO vw_person (first_name, last_name, email, organization_uuid)
VALUES 
	('Mansoor', 'Nellikkal', 'maninajeeb@haverford.edu', 
		(select organization_uuid from organization where short_name = 'HC')),
	('Zhi', 'Li', 'zhili@lbl.gov', 
		(select organization_uuid from organization where short_name = 'LBL')),
	('Gary', 'Cattabriga', 'gcattabrig@haverford.edu', 
		(select organization_uuid from organization where short_name = 'HC')),
	('Ian', 'Pendleton', 'ipendleton@haverford.edu', 
		(select organization_uuid from organization where short_name = 'HC')),
	('Minji', 'Lee', 'minjil.ee@lbl.gov', 
		(select organization_uuid from organization where short_name = 'LBL')),
	('Wesley', 'Wang', null, 
		(select organization_uuid from organization where short_name = 'LBL')),	
	('Philip', 'Nega', 'pnega@lbl.gov', 
		(select organization_uuid from organization where short_name = 'LBL')),	
	('Matt', 'Castillo', null, 
		(select organization_uuid from organization where short_name = 'LBL')),	
	('Liana', 'Alves', null, 
		(select organization_uuid from organization where short_name = 'HC'))
;
COMMIT;

-- ----------------------------
-- Records of actor
-- ----------------------------
/*
BEGIN;
INSERT INTO actor (person_uuid, organization_uuid, systemtool_uuid, description, status_uuid)  
VALUES 
	-- haverford college as an actor
	((select person_uuid from person where last_name = 'Nellikkal'), 
		NULL, NULL, 
		'Mansoor Nellikkal', (select status_uuid from status where description = 'active')),
	((select person_uuid from person where last_name = 'Li'), 
		NULL, NULL, 
		'Zhi Li', (select status_uuid from status where description = 'active')),	
	((select person_uuid from person where last_name = 'Pendleton'), 
		NULL, NULL, 
		'Ian Pendleton', (select status_uuid from status where description = 'active')),
	((select person_uuid from person where last_name = 'Cattabriga'), 
		NULL, NULL, 
		'Gary Cattabriga', (select status_uuid from status where description = 'active')),
	((select person_uuid from person where last_name = 'Nega'), 
		NULL, NULL, 
		'Philip Nega', (select status_uuid from status where description = 'active')),
	((select person_uuid from person where last_name = 'Lee'), 
		NULL, NULL, 
		'Minji Lee', (select status_uuid from status where description = 'active')),	
	((select person_uuid from person where last_name = 'Wang'), 
		NULL, NULL, 
		'Wesley Wang', (select status_uuid from status where description = 'active')),	
	((select person_uuid from person where last_name = 'Castillo'), 
		NULL, NULL, 
		'Matt Castillo', (select status_uuid from status where description = 'active')),	
	((select person_uuid from person where last_name = 'Alves'), 
		NULL, NULL, 
		'Liana Alves', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_uuid from organization where short_name = 'HC'),
		NULL, 'Haverford College', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_uuid from organization where short_name = 'LBL'),
		NULL, 'LBL', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_uuid from organization where short_name = 'Sigma-Aldrich'),
		NULL, 'Sigma-Aldrich', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_uuid from organization where short_name = 'Greatcell'),
		NULL, 'Greatcell', (select status_uuid from status where description = 'active')),		
	(NULL, 
		(select organization_uuid from organization where short_name = 'ChemAxon'),
		NULL, 'ChemAxon', (select status_uuid from status where description = 'active')),		
	(NULL, 
		(select organization_uuid from organization where short_name = 'RDKit'),
		NULL, 'RDKit', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_uuid from organization where short_name = 'ECL'),
		NULL, 'ECL', (select status_uuid from status where description = 'active')),		
	(NULL, (select organization_uuid from organization where short_name = 'HC'), 
		(select systemtool_uuid from systemtool where systemtool_name = 'standardize'),	
		'ChemAxon: standardize', (select status_uuid from status where description = 'active')),		
	(NULL, (select organization_uuid from organization where short_name = 'HC'), 
		(select systemtool_uuid from systemtool where systemtool_name = 'cxcalc'), 
		'ChemAxon: cxcalc', (select status_uuid from status where description = 'active')),		
	(NULL, (select organization_uuid from organization where short_name = 'HC'), 
		(select systemtool_uuid from systemtool where systemtool_name = 'molconvert'), 
		'ChemAxon: molconvert', (select status_uuid from status where description = 'active')),		
	(NULL, (select organization_uuid from organization where short_name = 'HC'), 
		(select systemtool_uuid from systemtool where systemtool_name = 'generatemd'), 
		'ChemAxon: generatemd', (select status_uuid from status where description = 'active')),
	(NULL, NULL, 
		(select systemtool_uuid from systemtool where systemtool_name = 'RDKit'), 
		'RDKit: Python toolkit', (select status_uuid from status where description = 'active')),
	(NULL, NULL, 
		(select systemtool_uuid from systemtool where systemtool_name = 'escalate'), 
		'escalate: system function call', (select status_uuid from status where description = 'active'))
;	
COMMIT;
*/

-- ----------------------------
-- Records of actor_pref
-- ----------------------------
BEGIN;
INSERT INTO actor_pref (actor_uuid, pkey, pvalue)  
VALUES 
	-- for GC actor, set up environment variables
	((select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), 'HOME_DIR', '/Users/gcattabriga/'),	
	((select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), 'MARVINSUITE_DIR', '/Applications/MarvinSuite/bin/'),
	((select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), 'CHEMAXON_DIR', '/Applications/ChemAxon/JChemSuite/bin/');	
COMMIT;

delete from vw_actor where systemtool_name = 'postgres';

-- ----------------------------
-- Populate tag_type
-- ----------------------------
BEGIN;
INSERT INTO vw_tag_type (short_description, description)
VALUES 
	('material', 'tags used to assist in identifying material types'),
	('experiment', 'tags used to assist in charactizing experiments, visibility'),
	('actor', 'tags used to assist in charactizing actors');
;
COMMIT;

-- ----------------------------
-- Populate measure_type
-- ----------------------------
BEGIN;
INSERT INTO measure_type (description)
VALUES 
	('nominal'),
	('actual'),
	('derived')
;
COMMIT;


-- ----------------------------
-- Populate some Tags
-- ----------------------------
BEGIN;
INSERT INTO vw_tag (display_text, tag_type_uuid, actor_uuid)
VALUES 
	('a-cation', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('b-cation', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('halide', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('acid', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('antisolvent', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('inorganic', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('organic', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('polymer', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('solvent', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('WF1 Bromides', (select tag_type_uuid from vw_tag_type where short_description = 'experiment'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('WF1 Iodides', (select tag_type_uuid from vw_tag_type where short_description = 'experiment'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('WF3 Iodide', (select tag_type_uuid from vw_tag_type where short_description = 'experiment'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('WF3 HalideAlloy', (select tag_type_uuid from vw_tag_type where short_description = 'experiment'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('WF3 Unique', (select tag_type_uuid from vw_tag_type where short_description = 'experiment'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('reference', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),	
	('catalog', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('reference', (select tag_type_uuid from vw_tag_type where short_description = 'experiment'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),	
	('catalog', (select tag_type_uuid from vw_tag_type where short_description = 'experiment'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('reference', (select tag_type_uuid from vw_tag_type where short_description = 'actor'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),	
	('temporary', (select tag_type_uuid from vw_tag_type where short_description = 'actor'), (select actor_uuid from vw_actor where systemtool_name = 'postgres')),
	('on_loan', (select tag_type_uuid from vw_tag_type where short_description = 'actor'), (select actor_uuid from vw_actor where systemtool_name = 'postgres')),	
	('do_not_use', (select tag_type_uuid from vw_tag_type where short_description = 'actor'), (select actor_uuid from vw_actor where systemtool_name = 'postgres'))	
;
COMMIT;


-- ----------------------------
-- Populate some UDFs
-- ----------------------------
BEGIN;
INSERT INTO vw_udf_def (description, valtype)
VALUES 
	('experiment version', 'text'::val_type),
	('generation version', 'text'::val_type),
	('challenge problem', 'text'::val_type),
	('model predicted', 'text'::val_type),
	('batch count', 'text'::val_type)
;
COMMIT;



-- ----------------------------
-- Add example(s) edocument
-- ----------------------------
BEGIN;
	with ins as 
		(INSERT into edocument (edocument_title, description, edocument_filename, edocument_source, edocument, edoc_type, actor_uuid) 
		(select document_title, description, file_name, document_source, edocument, 'blob_pdf'::val_type, (select actor_uuid from vw_actor where person_last_name = 'Pendleton') from load_edocument)
		returning edocument_uuid)
		insert into edocument_x (ref_edocument_uuid, edocument_uuid) VALUES
		((select actor_uuid from vw_actor where person_last_name = 'Pendleton'), (select edocument_uuid from ins))
	returning edocument_uuid; 
COMMIT;


-- ----------------------------
-- Update Person, Org, Actor 
-- with example note and edocument
-- ----------------------------
BEGIN;
insert into vw_note (notetext, actor_uuid, ref_note_uuid) values ('Motto: Non doctior, sed meliore doctrina imbutus (Not more learned, but steeped in a higher learning)', 
	(select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));
insert into vw_note (notetext, actor_uuid, ref_note_uuid) values ('https://docs.chemaxon.com/display/docs/cxcalc_command_line_tool.html', 
	(select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), (select systemtool_uuid from vw_systemtool where systemtool_name = 'cxcalc'));
COMMIT;



