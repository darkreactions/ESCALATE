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
BEGIN;
INSERT INTO systemtool (systemtool_name, description, systemtool_type_uuid, vendor_organization_uuid, model, serial, ver, note_uuid)
VALUES 
	('standardize', 'Molecule Standardizer', 
		(select systemtool_type_uuid from systemtool_type where description = 'Command-line tool'), 
		(select organization_uuid from organization where short_name = 'ChemAxon'), NULL, NULL, '19.27.0', NULL),
	('cxcalc', 'Molecular Descriptor Generator',
		(select systemtool_type_uuid from systemtool_type where description = 'Command-line tool'), 
		(select organization_uuid from organization where short_name = 'ChemAxon'), NULL, NULL, '19.27.0', NULL),
	('molconvert', 'Molecule File Converter',
		(select systemtool_type_uuid from systemtool_type where description = 'Command-line tool'), 
		(select organization_uuid from organization where short_name = 'ChemAxon'), NULL, NULL, '19.27.0', NULL),
	('generatemd', 'Molecular Descriptor Generator',
		(select systemtool_type_uuid from systemtool_type where description = 'Command-line tool'),
		(select organization_uuid from organization where short_name = 'ChemAxon'), NULL, NULL, '19.6.0', NULL),
	('RDKit', 'Cheminformatics Toolkit for Python', 
		(select systemtool_type_uuid from systemtool_type where description = 'Python toolkit'),
		(select organization_uuid from organization where short_name = 'RDKit'), NULL, NULL, '19.03.4', NULL),
	('escalate', 'ESCALATE function call', 
		(select systemtool_type_uuid from systemtool_type where description = 'ESCALATE function'),
		(select organization_uuid from organization where short_name = 'HC'), NULL, NULL, '3.0.0', NULL)
;
COMMIT;

-- ----------------------------
-- Records of person
-- ----------------------------
BEGIN;
INSERT INTO person (first_name, last_name, email, organization_uuid, note_uuid)
VALUES 
	('Mansoor', 'Nellikkal', 'maninajeeb@haverford.edu', 
		(select organization_uuid from organization where short_name = 'HC'),NULL),
	('Zhi', 'Li', 'zhili@lbl.gov', 
		(select organization_uuid from organization where short_name = 'LBNL'),NULL),
	('Gary', 'Cattabriga', 'gcattabrig@haverford.edu', 
		(select organization_uuid from organization where short_name = 'HC'),NULL),
	('Ian', 'Pendleton', 'ipendleton@haverford.edu', 
		(select organization_uuid from organization where short_name = 'HC'),NULL),
	('Philip', 'Nega', 'pnega@lbl.gov', 
		(select organization_uuid from organization where short_name = 'LBNL'),NULL)	
;
COMMIT;

-- ----------------------------
-- Records of actor
-- ----------------------------
BEGIN;
INSERT INTO actor (person_uuid, organization_uuid, systemtool_uuid, description, status_uuid)  
VALUES 
	-- haverford college as an actor
	((select person_uuid from person where last_name = 'Nellikkal'), 
		(select organization_uuid from organization where short_name = 'HC'), NULL, 
		'Mansoor Nellikkal', (select status_uuid from status where description = 'active')),
	((select person_uuid from person where last_name = 'Li'), 
		(select organization_uuid from organization where short_name = 'LBNL'), NULL, 
		'Zhi Li', (select status_uuid from status where description = 'active')),	
	((select person_uuid from person where last_name = 'Pendleton'), 
		(select organization_uuid from organization where short_name = 'HC'), NULL, 
		'Ian Pendleton', (select status_uuid from status where description = 'active')),
	((select person_uuid from person where last_name = 'Cattabriga'), 
		(select organization_uuid from organization where short_name = 'HC'), NULL, 
		'Gary Cattabriga', (select status_uuid from status where description = 'active')),
	((select person_uuid from person where last_name = 'Nega'), 
		(select organization_uuid from organization where short_name = 'LBNL'), NULL, 
		'Philip Nega', (select status_uuid from status where description = 'active')),	
	(NULL, 
		(select organization_uuid from organization where short_name = 'HC'),
		NULL, 'Haverford College', (select status_uuid from status where description = 'active')),
	(NULL, 
		(select organization_uuid from organization where short_name = 'LBNL'),
		NULL, 'LBNL', (select status_uuid from status where description = 'active')),
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
	(NULL, (select organization_uuid from organization where short_name = 'HC'), 
		(select systemtool_uuid from systemtool where systemtool_name = 'RDKit'), 
		'RDKit: Python toolkit', (select status_uuid from status where description = 'active')),
	(NULL, (select organization_uuid from organization where short_name = 'HC'), 
		(select systemtool_uuid from systemtool where systemtool_name = 'escalate'), 
		'escalate: system function call', (select status_uuid from status where description = 'active'))
;	
COMMIT;


-- ----------------------------
-- Records of actor_pref
-- ----------------------------
BEGIN;
INSERT INTO actor_pref (actor_uuid, pkey, pvalue)  
VALUES 
	-- for GC actor, set up environment variables
	((select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), 'HOME_DIR', '/Users/gcattabriga/'),	
	((select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), 'MARVINSUITE_DIR', '/Applications/MarvinSuite/bin/'),
	((select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), 'CHEMAXON_DIR', '/Applications/ChemAxon/JChemSuite/bin/')
	;	
COMMIT;



-- ----------------------------
-- Populate tag_type
-- ----------------------------
BEGIN;
INSERT INTO tag_type (short_description, description, actor_uuid)
VALUES 
	('material', 'tags used to assist in identifying material types', (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'))
;
COMMIT;

-- ----------------------------
-- Populate some Tags
-- ----------------------------
BEGIN;
INSERT INTO tag (short_description, tag_type_uuid, actor_uuid)
VALUES 
	('A-Cation', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('B-Cation', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('Halide', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('acid', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('antisolvent', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('inorganic', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('organic', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('polymer', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
	('solvent', (select tag_type_uuid from vw_tag_type where short_description = 'material'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'))
;
COMMIT;



-- ----------------------------
-- Add example(s) edocument
-- ----------------------------
BEGIN;
INSERT into edocument (edocument_title, description, edocument_filename, edocument_source, edocument, edoc_type, actor_uuid) 
	(select document_title, description, file_name, document_source, edocument, 'blob_pdf'::val_type, (select actor_uuid from vw_actor where person_last_name = 'Pendleton') from load_edocument)
	;	
COMMIT;


-- ----------------------------
-- Update Person, Org, Actor 
-- with example note and edocument
-- ----------------------------
BEGIN;
with ins as 
(insert into note (notetext, edocument_uuid, actor_uuid)
		(select ed.description, ed.edocument_uuid, ed.actor_uuid 
		from edocument ed where actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Pendleton'))
returning note_uuid)
update person set note_uuid = (select note_uuid from ins) where last_name = 'Pendleton';
COMMIT;
BEGIN;
with ins as 
(insert into note (notetext, actor_uuid) VALUES
	('https://docs.chemaxon.com/display/docs/cxcalc_command_line_tool.html', (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'))
returning note_uuid)
update actor set note_uuid = (select note_uuid from ins) where description = 'ChemAxon: cxcalc';
COMMIT;
BEGIN;
with ins as 
(insert into note (notetext, actor_uuid) VALUES
	('Motto: Non doctior, sed meliore doctrina imbutus (Not more learned, but steeped in a higher learning)', (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'))
returning note_uuid)
update organization set note_uuid = (select note_uuid from ins) where full_name = 'Haverford College';
COMMIT;



