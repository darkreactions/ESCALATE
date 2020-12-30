--======================================================================
/*
Name:			test_functions v1
Parameters:		none
Returns:		NA
Author:			G. Cattabriga
Date:			2020.09.27
Description:	test [most] functions, [all] upserts. For upserts, perform all methods
				(e.g. insert, update, delete)
Notes:			Make sure to use status = 'dev_test' and actor = 'Test123' for 
				all upserts. These are inserted at the beginning of the upsert
				tests, and deleted at the end

				2020.09.27:	This version tests ONLY if the function executes 
							without error. Next version add testing outputs
*/
--======================================================================
--======================================================================
-- FUNCTIONS
--======================================================================
--======================================================================

/*
Name:			get_column_count(_table varchar)
Notes:
*/
select * from get_column_count('load_v2_bromides') LIMIT 1;


/*
Name:			get_table_uuids()
Notes:			
*/
select * from get_table_uuids() LIMIT 10;


/*
Name:			get_material_uuid_bystatus (p_status_arr, p_null_bool)
Notes:	
*/			
SELECT * FROM get_material_uuid_bystatus (array['active', 'proto'], TRUE)  LIMIT 1;


/*
Name:			get_material_nameref_bystatus (p_status_arr, p_null_bool)
Notes:			
*/
SELECT * FROM get_material_nameref_bystatus (array['active', 'proto'], TRUE) where material_refname_def = 'InChI' order by 1  LIMIT 1;


/*
Name:			get_material_bydescr_bystatus (p_descr VARCHAR, p_status_array VARCHAR[], p_null_bool BOOLEAN );
Notes:			
*/
SELECT * FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE)  LIMIT 1;


/*
Name:			get_material_type (p_material_uuid uuid)
Notes:				
*/							
SELECT * FROM get_material_type ((SELECT material_uuid FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE)))  LIMIT 1;


/*
Name:			get_calculation_def ()
Notes:				
*/							
SELECT * FROM get_calculation_def (array['standardize'])  LIMIT 1;


/*
Name:			get_calculation (p_material_refname varchar, p_descr VARCHAR)
Notes:
*/				
SELECT * FROM get_calculation ('C1=CC=C(C=C1)CC[NH3+].[I-]', array['standardize'])  LIMIT 1;
SELECT * FROM get_calculation ('C1CC[NH2+]C1.[I-]', array['standardize'])  LIMIT 1;	
SELECT * FROM get_calculation ('C1CC[NH2+]C1.[I-]', array['charge_cnt_standardize'])  LIMIT 1;
SELECT * FROM get_calculation ('CN(C)C=O', array['charge_cnt_standardize'])  LIMIT 1;	
SELECT * FROM get_calculation ('CN(C)C=O')  LIMIT 1;	


/*
Name:			get_val_json (p_in val)
Notes:				
*/							
SELECT get_val_json (concat('(', 
	(select type_def_uuid from vw_type_def where category = 'data' and description ='text'),
	',,"[I-].[NH3+](CCC1=CC=C(C=C1)OC)",,,,,,,,,)')::val);
SELECT get_val_json (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='num'),
	',fuff,,,,,266.99,,,,,)')::val);
SELECT get_val_json (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='int'),
	',tuts,,,15,,,,,,,)')::val);			
SELECT get_val_json (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='array_int'),
	',,,,,"{1,2,3,4,5}",,,,,,)')::val);	
SELECT get_val_json (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='blob'),				
	',,,,,,,,',
	(select edocument_uuid from vw_edocument where 
	title = 'Experiment Specification, Capture and Laboratory Automation Technology (ESCALATE): a software pipeline for automated chemical experimentation and data management'),
	',,,)')::val);
SELECT get_val_json (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='bool'),
	',,,,,,,,,,TRUE,)')::val);		


/*
Name:			get_val_actual (p_in anyelement, p_val val)
Notes:				
*/							
SELECT get_val_actual (null::int8, concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='int'),
	',,,,15,,,,,,,)')::val);	
SELECT get_val_actual (null::int8[], concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='array_int'),
	',,,,,"{1,2,3,4,5}",,,,,,)')::val);	
SELECT get_val_actual (null::text, concat('(', 
	(select type_def_uuid from vw_type_def where category = 'data' and description ='text'),
	',,"[I-].[NH3+](CCC1=CC=C(C=C1)OC)",,,,,,,,,)')::val);
SELECT get_val_actual (null::numeric, concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='num'),
	',,,,,,266.99,,,,,)')::val);

/*
Name:			get_val (p_in val) 
Notes:				
*/						
SELECT get_val (concat('(', 
	(select type_def_uuid from vw_type_def where category = 'data' and description ='text'),
	',,"[I-].[NH3+](CCC1=CC=C(C=C1)OC)",,,,,,,,,)')::val);
SELECT get_val (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='num'),
	',,,,,,266.99,,,,,)')::val);
SELECT val_type from get_val (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='num'),
	',,,,,,266.99,,,,,)')::val);
SELECT val_val from get_val (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='num'),
	',,,,,,266.99,,,,,)')::val);
SELECT get_val (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='int'),
	',,,,15,,,,,,,)')::val);			
SELECT get_val (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='array_int'),
	',,,,,"{1,2,3,4,5}",,,,,,)')::val);	
SELECT get_val (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='bool'),
	',,,,,,,,,,TRUE,)')::val);	
SELECT get_val (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='fred'),
	',,,,,,,,,,TRUE,)')::val);					


/*
Name:			get_val_units (p_in val)
Notes:				
*/						
SELECT get_val_unit (concat('(', 
	(select type_def_uuid from vw_type_def where category = 'data' and description ='text'),
	',inchikey,"[I-].[NH3+](CCC1=CC=C(C=C1)OC)",,,,,,,,,)')::val);
SELECT get_val_unit (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='num'),
	',ergs,,,,,266.99,,,,,)')::val);
SELECT get_val_unit (concat('(',
	(select type_def_uuid from vw_type_def where category = 'data' and description ='int'),
	',mols,,,15,,,,,,,)')::val);							


/*
Name:			get_type_def (_category type_def_category, _description varchar)
Notes:				
*/							
select get_type_def ('data', 'text');
select get_type_def ('data', 'bool');
select get_type_def ('data', 'blob');	
select get_type_def ('file', 'svg');	
select get_type_def ('data', 'fred');	


/*
Name:			put_val (p_type_uuid uuid, p_val anyelement, p_unit text )
Notes:				
*/							
SELECT put_val ((select get_type_def ('data', 'text')),'[I-].[NH3+](CCC1=CC=C(C=C1)OC)'::text, 'inchikey');
SELECT put_val ((select get_type_def ('data', 'text')),'fred'::text, null);
SELECT put_val ((select get_type_def ('data', 'int')), '5', 'ergs');
SELECT put_val ((select get_type_def ('data', 'num')), '1.2345', 'ergs');
SELECT put_val ((select get_type_def ('data', 'array_num')), '{1.01,2,3,404.237}', 'ergs');
SELECT put_val ((select get_type_def ('data', 'bool')), 'FALSE', null);
SELECT put_val ((select get_type_def ('data', 'array_bool')), '{FALSE,TRUE,TRUE,FALSE}', null);
select get_val((SELECT put_val ((select get_type_def ('data', 'int')), '5', 'ergs')));
select get_val((SELECT put_val ((select get_type_def ('data', 'array_int')), '{1,2,3,4}', 'ergs')));	


/*
Name:			get_chemaxon_directory ()
Notes:				
*/							
select get_chemaxon_directory((select systemtool_uuid from systemtool where systemtool_name = 'standardize'), (SELECT actor_uuid FROM vw_actor where person_last_first like 'Cattabriga, Gary'));


/*
Name:			get_chemaxon_version ()
Notes:				
*/							
select get_chemaxon_version((select systemtool_uuid from systemtool where systemtool_name = 'generatemd'), (select actor_uuid from vw_actor where person_last_first like 'Cattabriga, Gary'));


/*
Name:			get_charge_count (p_mol_smiles varchar) 
Notes:			
*/							
select get_charge_count('C1C[NH+]2CC[NH+]1CC2');
select get_charge_count(null);


/*
Name:			math_op (p_in_num numeric, p_op text, p_in_opt_num numeric default null) 
Notes:	
*/		
select math_op(9, '/', 3);
select math_op(101, '*', 11);
select math_op(5, '!');


/*
Name:			delete_assigned_recs (p_ref_uuid uuid) 
Notes:			
*/
insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) 
	values ('Test123','Dev','Temp','123 Testing Ln',null,'Test City','NY',null,null,null,null,null,null,null);
insert into vw_note (notetext, actor_uuid, ref_note_uuid) 
	values ('test note for Dev Test123', (select actor_uuid from vw_actor where person_last_name = 'Test123'), 
	(select actor_uuid from vw_actor where person_last_name = 'Test123'));
insert into vw_tag_assign (tag_uuid, ref_tag_uuid) 
	values ((select tag_uuid from vw_tag where (display_text = 'do_not_use' and type = 'actor')), 
	(select actor_uuid from vw_actor where person_last_name = 'Test123'));
insert into vw_udf (ref_udf_uuid, udf_def_uuid, udf_val_val) values
	((select actor_uuid from vw_actor where person_last_name = 'Test123'), 
	(select udf_def_uuid from vw_udf_def where description = 'batch count'),
	'123 -> batch no. test');
select delete_assigned_recs ((select actor_uuid from vw_actor where description = 'Dev Test123'));
delete from vw_actor where actor_uuid in (select actor_uuid from vw_actor where description = 'Dev Test123');			



--======================================================================
--======================================================================
-- UPSERTS
--======================================================================
--======================================================================

------------------------------------------------------------------------
-- set up a test actor (person) and test status to be used throughout
insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) 
	values ('Test123','Dev','Temp','123 Testing Ln',null,'Test City','NY',null,null,null,null,null,null,null);
insert into vw_status (description) values ('dev_test');
------------------------------------------------------------------------

/*
Name:			upsert_tag_type()
Notes:
*/	
insert into vw_tag_type (type) values ('DEVTEST_TAGTYPE');
update vw_tag_type set description = 'devtest tagtype description' where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (type = 'DEVTEST_TAGTYPE'));
delete from vw_tag_type where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (type = 'DEVTEST_TAGTYPE'));


/*
Name:			upsert_tag()
Notes:			
*/ 
-- set up the tag_type
insert into vw_tag_type (type) values ('DEVTEST_TAGTYPE');
insert into vw_tag (display_text, description, actor_uuid, tag_type_uuid) 
 	values ('devtest_tag', 'devtest_tag description', (select actor_uuid from vw_actor where person_last_name = 'Test123'), null);
update vw_tag set description = 'devtest_tag description with stuff added', 
 	tag_type_uuid = (select tag_type_uuid from vw_tag_type where type = 'DEVTEST_TAGTYPE') 
 	where tag_uuid = (select tag_uuid from vw_tag where (display_text = 'devtest_tag'));	
delete from vw_tag where tag_uuid = (select tag_uuid from vw_tag where (display_text = 'devtest_tag' and type = 'DEVTEST_TAGTYPE'));
-- delete tag_type
delete from vw_tag_type where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (type = 'DEVTEST_TAGTYPE'));						


/*
Name:			upsert_tag_assign()
Notes:			
*/
insert into vw_tag_type (type) values ('DEVTEST_TAGTYPE');
insert into vw_tag (display_text, description, actor_uuid, tag_type_uuid) 
 	values ('devtest_tag', 'devtest_tag description', (select actor_uuid from vw_actor where person_last_name = 'Test123'), 
 	(select tag_type_uuid from vw_tag_type where type = 'DEVTEST_TAGTYPE'));
insert into vw_tag_assign (tag_uuid, ref_tag_uuid) values ((select tag_uuid from vw_tag 
 	where (display_text = 'devtest_tag' and vw_tag.type = 'DEVTEST_TAGTYPE')), (select actor_uuid from vw_actor where person_last_name = 'Test123') );
delete from vw_tag_assign where tag_uuid = (select tag_uuid from vw_tag 
 	where (display_text = 'devtest_tag' and vw_tag.type = 'DEVTEST_TAGTYPE') and ref_tag_uuid = (select actor_uuid from vw_actor where person_last_name = 'Test123') );
delete from vw_tag where tag_uuid = (select tag_uuid from vw_tag where (display_text = 'devtest_tag' and type = 'DEVTEST_TAGTYPE'));
delete from vw_tag_type where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (type = 'DEVTEST_TAGTYPE'));	


/*
Name:			upsert_udf_def()
Notes:				
*/ 
insert into vw_udf_def (description, val_type_uuid) 
	values ('devtest_udf_def', (select type_def_uuid from vw_type_def where category = 'data' and description = 'text'));
update vw_udf_def set unit = 'devtest-unit' where
 	udf_def_uuid = (select udf_def_uuid from vw_udf_def where (description = 'devtest_udf_def'));
delete from vw_udf_def where udf_def_uuid = (select udf_def_uuid from udf_def where (description = 'devtest_udf_def'));


/*
Name:			upsert_udf()
Notes:				
*/ 
insert into vw_udf_def (description, val_type_uuid) 
	values ('devtest_udf_def', (select type_def_uuid from vw_type_def where category = 'data' and description = 'text'));
insert into vw_udf (ref_udf_uuid, udf_def_uuid, udf_val_val) values 
	((select actor_uuid from vw_actor where person_last_name = 'Test123'),
	(select udf_def_uuid from vw_udf_def where description = 'devtest_udf_def') 
	, 'devtest: a, b, c, d');
update vw_udf set udf_val_val = 'devtest: some more text a, b, c, d, e, f' where
 	udf_def_uuid = (select udf_def_uuid from vw_udf_def where (description = 'devtest_udf_def'));
delete from vw_udf where udf_def_uuid = (select udf_def_uuid from udf_def where (description = 'devtest_udf_def'));
delete from vw_udf_def where udf_def_uuid = (select udf_def_uuid from udf_def where (description = 'devtest_udf_def'));


/*
Name:			upsert_status()
Notes:				
*/ 
insert into vw_status (description) values ('dev_test status');
update vw_status set description = 'dev_test status new description' where status_uuid = (select status_uuid from vw_status where (description = 'dev_test status'));
delete from vw_status where status_uuid = (select status_uuid from vw_status where (description = 'dev_test status new description'));


/*
Name:			upsert_type_def()
Notes:			
*/ 
insert into vw_type_def (category, description) values ('file', 'devtest');
update vw_type_def set description = 'devtest_update' where type_def_uuid = (select type_def_uuid from 
	vw_type_def where category = 'file' and description = 'devtest');
delete from vw_type_def where type_def_uuid = (select type_def_uuid from vw_type_def where category = 'file' and description = 'devtest_update');	


/*
Name:			upsert_note()
Notes:
*/ 
insert into vw_note (notetext, actor_uuid, ref_note_uuid) 
	values ('devtest note', (select actor_uuid from vw_actor where person_last_name = 'Test123'), 
	(select actor_uuid from vw_actor where person_last_name = 'Test123'));
update vw_note set notetext = 'devtest note note with additional text...' where note_uuid = (select note_uuid from vw_note where (notetext = 'devtest note'));
delete from vw_note where note_uuid = (select note_uuid from vw_note where (notetext = 'devtest note note with additional text...'));


/*
Name:			upsert_edocument()
Notes:				
*/ 
insert into vw_edocument (title, description, filename, source, edocument, doc_type_uuid, doc_ver, actor_uuid, status_uuid, ref_edocument_uuid) 
	values ('devtest test document title', 'This is a test document', null, null, 'a bunch of text cast as a blob'::bytea, 
	(select type_def_uuid from vw_type_def where category = 'file' and description = 'text'), null,
	(select actor_uuid from vw_actor where person_last_name = 'Test123'), (select status_uuid from vw_status where description = 'dev_test'),
	null);
update vw_edocument set ref_edocument_uuid = (select actor_uuid from vw_actor where person_last_name = 'Test123') where 
	edocument_uuid = (select edocument_uuid from vw_edocument where title = 'devtest test document title');
delete from vw_edocument where edocument_uuid = (select edocument_uuid from vw_edocument where title = 'devtest test document title');


/*
Name:				upsert_actor ()
Notes:				
*/ 
insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) 
	values ('Tester','Lester','Fester','1313 Mockingbird Ln',null,'Munsterville','NY',null,null,null,null,null,null,null);
update vw_actor set description = 'new description for Lester the Actor' 
	where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));
delete from vw_actor where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));


/*
Name:			upsert_actor_pref()
Notes:				
*/ 
insert into vw_actor_pref (actor_uuid, pkey, pvalue) values ((select actor_uuid from vw_actor where person_last_name = 'Test123'), 'test_key', 'test_value');
update vw_actor_pref set pvalue = 'new_new_test_value' where actor_pref_uuid = (select actor_pref_uuid from vw_actor_pref where actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Test123') and pkey = 'test_key');
delete from vw_actor_pref where actor_pref_uuid = (select actor_pref_uuid from vw_actor_pref where actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Test123'));

/*
Name:				upsert_organization ()
Notes:				
*/
							
insert into vw_organization (description, full_name, short_name, address1, address2, city, state_province, zip, country, website_url, phone, parent_uuid) 
	values ('devtest org description','DEVTEST','devtest','1001 devtest way',null,'Center City','NY',null,null,null,null,null);
update vw_organization set description = 'devtest org new description', city = 'Centre City', zip = '00000' where full_name = 'DEVTEST';
update vw_organization set parent_uuid =  (select organization_uuid from organization where organization.full_name = 'Haverford College') where full_name = 'DEVTEST';
delete from vw_actor where organization_uuid = (select organization_uuid from vw_organization where full_name = 'DEVTEST');
			

/*
Name:				upsert_person ()
Notes:				
*/ 
insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) 
	values ('Tester','Lester','Fester','1313 Mockingbird Ln',null,'Munsterville','NY',null,null,null,null,null,null,null);
update vw_person set title = 'Mr', city = 'Some [new] City', zip = '99999', email = 'TesterL@scarythings.xxx' where person_uuid = 
 	(select person_uuid from person where (last_name = 'Tester' and first_name = 'Lester')) ;
update vw_person set organization_uuid =  (select organization_uuid from organization where organization.full_name = 'Haverford College') where (last_name = 'Tester' and first_name = 'Lester');
delete from vw_actor where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));


/*
Name:			upsert_systemtool()
Notes:			
*/ 
insert into vw_systemtool (systemtool_name, description, systemtool_type_uuid, vendor_organization_uuid, model, serial, ver)
	values ('MRROBOT', 'MR Robot to you',(select systemtool_type_uuid from vw_systemtool_type where description = 'API'),
	(select organization_uuid from vw_organization where full_name = 'ChemAxon'),'super duper', null, '1.0');
update vw_systemtool set serial = 'ABC-1234' where systemtool_uuid = (select systemtool_uuid from vw_systemtool where (systemtool_name = 'MRROBOT'));
update vw_systemtool set ver = '1.1' where systemtool_uuid = (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT');
update vw_systemtool set ver = '1.2' where systemtool_uuid = (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT' and ver = '1.1');
delete from actor where systemtool_uuid in (select systemtool_uuid from systemtool where systemtool_name = 'MRROBOT');


/*
Name:			upsert_systemtool_type()
Notes:				
*/ 
insert into vw_systemtool_type (description) values ('devtest systemtool type');
delete from vw_systemtool_type where systemtool_type_uuid = (select systemtool_type_uuid from vw_systemtool_type where (description = 'devtest systemtool type'));


/*
Name:			upsert_measure_type()
Notes:				
*/ 
insert into vw_measure_type (description, actor_uuid, status_uuid) values 
	('TEST measure type',
	(select actor_uuid from vw_actor where person_last_name = 'Test123'),
	null);
update vw_measure_type set 
	status_uuid = (select status_uuid from vw_status where description = 'dev_test') where (description = 'TEST measure type');
delete from vw_measure_type where measure_type_uuid = (select measure_type_uuid from vw_measure_type where (description = 'TEST measure type'));


/*
Name:			upsert_measure()
Notes:				
*/ 
insert into vw_measure (measure_type_uuid, ref_measure_uuid, description, measure_value, actor_uuid, status_uuid) values
	((select measure_type_uuid from vw_measure_type where description = 'manual'),
	(select material_uuid from vw_material where description = 'Formic Acid'),
	'TEST measure',
	(select put_val((select get_type_def ('data', 'num')),'3.1415926535','slice')),
	(select actor_uuid from vw_actor where person_last_name = 'Test123'),
	null);
update vw_measure set 
	status_uuid = (select status_uuid from vw_status where description = 'dev_test') where (description = 'TEST measure');
delete from vw_measure where measure_uuid = (select measure_uuid from vw_measure where description = 'TEST measure');


/*
Name:			upsert_material_type()
Notes:				
*/ 
insert into vw_material_type (description) values ('devtest_materialtype');
delete from vw_material_type where material_type_uuid = (select material_type_uuid from vw_material_type where (description = 'devtest_materialtype'));


/*
Name:			upsert_material_refname_def()
Notes:				
*/ 
insert into vw_material_refname_def (description) values ('devtest_material_refname_def');
delete from vw_material_refname_def where material_refname_def_uuid = 
	(select material_refname_def_uuid from vw_material_refname_def where (description = 'devtest_material_refname_def'));


/*
Name:			upsert_material()
Notes:				
*/ 
insert into vw_material (description) values ('devtest_material');
delete from vw_material where material_uuid = 
	(select material_uuid from vw_material where (description = 'devtest_material'));


/*
Name:			upsert_material_type_assign()
Notes:				
*/ 
insert into vw_material_type_assign (material_uuid, material_type_uuid) values 
	((select material_uuid from vw_material where description = 'Hydrochloric acid'),
	(select material_type_uuid from vw_material_type where description = 'solvent'));
delete from vw_material_type_assign where material_uuid = (select material_uuid from vw_material where description = 'Hydrochloric acid') and
 	material_type_uuid = (select material_type_uuid from vw_material_type where description = 'solvent');


/*
Name:			upsert_property_def()
Notes:				
*/ 
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('devtest property {min, max}', 'devtest property', 
	(select get_type_def ('data', 'array_num')), 
	'devtest', null, (select status_uuid from vw_status where description = 'dev_test'));
update vw_property_def set short_description = 'devtest property',
	actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Test123') where (short_description = 'devtest property');
delete from vw_property_def where short_description = 'devtest property';


/*
Name:			upsert_material_property()
Notes:				
*/ 
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('devtest property {min, max}', 'devtest property', 
	(select get_type_def ('data', 'array_num')), 
	'devtest', null, (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_material_property (material_uuid, property_def_uuid, 
	property_value, property_actor_uuid, property_status_uuid )
	values ((select material_uuid from vw_material where description = 'Formic Acid'),
		(select property_def_uuid from vw_property_def where short_description = 'devtest property'),
		'{100, 200}', 
		null,
		(select status_uuid from vw_status where description = 'dev_test')
);
update vw_material_property set property_actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Test123') where material_uuid = 
	(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'devtest property';
update vw_material_property set property_value = '{100, 900}' where material_uuid =
	(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'devtest property';
delete from vw_material_property where material_uuid = 
	(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'devtest property';
delete from vw_property_def where short_description = 'devtest property';


/*
Name:			upsert_calculation_def()
Notes:				
*/ 
insert into vw_calculation_def (short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, 	
	in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid ) 
	values ('test_calc_def', 'function param1 param2', 
		(select systemtool_uuid from vw_actor where description = 'Molecule Standardizer'),
		'testing calculation definition upsert', 
		(select calculation_def_uuid from vw_calculation_def where short_name = 'standardize'), 
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'text'),
		null, null, 
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'int'),
		null, (select actor_uuid from vw_actor where description = 'Dev Test123'),
		(select status_uuid from vw_status where description = 'dev_test')		
		);
delete from vw_calculation_def where short_name = 'test_calc_def';


/*
Name:			upsert_calculation()
Notes:				
*/ 
 
/*
Name:			upsert_workflow_def()
Notes:				
*/


/*
Name:			upsert_action_def()
Notes:
*/
insert into vw_action_def (description, actor_uuid, status_uuid) values
	('heat_stir', (select actor_uuid from vw_actor where description = 'Dev Test123'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('heat', (select actor_uuid from vw_actor where description = 'Dev Test123'),
    (select status_uuid from vw_status where description = 'dev_test'));



/*
Name:			upsert_parameter_def()
Notes:				
*/ 
insert into vw_parameter_def (description, default_val)
	values
    	('duration',
        (select put_val(
        (select get_type_def ('data', 'num')), '0', 'mins'))
        ),
        ('speed',
        (select put_val ((select get_type_def ('data', 'num')),'0','rpm'))
        ),
        ('temperature',
        (select put_val((select get_type_def ('data', 'num')), '0', 'degC'))
		);
update vw_parameter_def
	set status_uuid = (select status_uuid from vw_status where description = 'dev_test')
    where description = 'temperature';



/*
Name:			upsert_action_parameter_def_assign()
Notes:			
*/
insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid)
	values ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
    	(select parameter_def_uuid from vw_parameter_def where description = 'duration')),
        ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
        (select parameter_def_uuid from vw_parameter_def where description = 'temperature')),
        ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
        (select parameter_def_uuid from vw_parameter_def where description = 'speed')),
        ((select action_def_uuid from vw_action_def where description = 'heat'),
        (select parameter_def_uuid from vw_parameter_def where description = 'duration')),
        ((select action_def_uuid from vw_action_def where description = 'heat'),
        (select parameter_def_uuid from vw_parameter_def where description = 'temperature'));



/*
Name:			upsert_parameter()
Notes:			Preferred use is through upsert_action_parameter
*/
/* 
insert into vw_parameter (parameter_def_uuid, ref_parameter_uuid, parameter_val, actor_uuid, status_uuid ) values (
	(select parameter_def_uuid from vw_parameter_def where description = 'duration'),
    (select actor_uuid from vw_actor where description = 'Dev Test123'),
	(select put_val (
		(select val_type_uuid from vw_parameter_def where description = 'duration'),
		'10',
		(select valunit from vw_parameter_def where description = 'duration'))),
	(select actor_uuid from vw_actor where org_short_name = 'LANL'),
	(select status_uuid from vw_status where description = 'dev_test')
);
update vw_parameter set parameter_val = (select put_val (
	(select val_type_uuid from vw_parameter_def where description = 'duration'),
	'36',
	(select valunit from vw_parameter_def where description = 'duration')))
    where parameter_def_description = 'duration';
*/


/*
Name:			upsert_workflow_type()
Notes:
*/
insert into vw_workflow_type (description) values ('workflowtype_test');
-- delete from vw_workflow_type where workflow_type_uuid = (select workflow_type_uuid from vw_workflow_type where (description = 'workflowtype_test'));


/*
Name:			upsert_workflow()
Notes:
*/
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'workflowtype_test'),
		'workflow_test',
		(select actor_uuid from vw_actor where description = 'Dev Test123'),
		null);
update vw_workflow set status_uuid = (select status_uuid from vw_status where description = 'dev_test') where description = 'workflow_test';




/*
Name:			upsert_action()                     
Notes:          
*/
insert into vw_action (action_def_uuid, workflow_uuid, action_description, status_uuid)
	values (
    	(select action_def_uuid from vw_action_def where description = 'heat_stir'),
	    (select workflow_uuid from vw_workflow where description = 'workflow_test'),
        'example_heat_stir',
        (select status_uuid from vw_status where description = 'dev_test'));
update vw_action set actor_uuid = (select actor_uuid from vw_actor where description = 'Dev Test123')
	where action_description = 'example_heat_stir';
insert into vw_action (action_def_uuid, workflow_uuid, action_description, actor_uuid, status_uuid)
	values (
    	(select action_def_uuid from vw_action_def where description = 'heat'),
	    (select workflow_uuid from vw_workflow where description = 'workflow_test'),
        'example_heat',
        (select actor_uuid from vw_actor where description = 'Dev Test123'),
        (select status_uuid from vw_status where description = 'dev_test'));



/*
Name:			upsert_action_parameter()
Notes:
*/
update vw_action_parameter
	set parameter_val = (select put_val (
    	(select val_type_uuid from vw_parameter_def where description = 'speed'),
        '8888',
		(select valunit from vw_parameter_def where description = 'speed'))
		)
where (action_description = 'example_heat_stir' AND parameter_def_description = 'speed');

-- clean up the action, parameter functions above
delete from vw_action_parameter where action_description = 'example_heat_stir';
delete from vw_action where action_description = 'example_heat_stir';
delete from vw_action where action_description = 'example_heat';
delete from vw_parameter where parameter_def_description = 'duration' AND ref_parameter_uuid = (select actor_uuid from vw_actor where description = 'Dev Test123');
delete from vw_action_parameter_def_assign
	where action_def_uuid = (select action_def_uuid from vw_action_def where description = 'heat_stir')
    	and parameter_def_uuid in 
    		(select parameter_def_uuid from vw_parameter_def 
    			where description in ('speed', 'duration', 'temperature'));
delete from vw_action_def where description in ('heat_stir', 'heat');
delete from vw_parameter_def where description in ('duration', 'speed', 'temperature');



/*
Name:			upsert_condition_def()
Notes:				
*/		
insert into vw_condition_def (description, actor_uuid) values
	('temp > threshold ?', (select actor_uuid from vw_actor where description = 'Dev Test123'));
update vw_condition_def set status_uuid = (select status_uuid from vw_status where description = 'dev_test') where description = 'temp > threshold ?';
delete from vw_condition_def where description = 'temp > threshold ?';


/*
Name:			upsert_condition_calculation_def_assign()
Notes:
*/
insert into vw_condition_def (description, actor_uuid, status_uuid) values
	('temp > threshold ?', (select actor_uuid from vw_actor where description = 'Dev Test123'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_calculation_def 
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, 		
	in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid ) 
	values ('greater_than', 'pop A, pop B, >', 
		(select systemtool_uuid from vw_actor where systemtool_name = 'escalate'),
		'B > A ? (pop B, pop A, >?) returning true or false', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'bool'),
		null, (select actor_uuid from vw_actor where description = 'Dev Test123'),
		(select status_uuid from vw_status where description = 'dev_test')		
		);
insert into vw_condition_calculation_def_assign (condition_def_uuid, calculation_def_uuid)
	VALUES ((select condition_def_uuid from vw_condition_def where description = 'temp > threshold ?'),
		(select calculation_def_uuid from vw_calculation_def where short_name = 'greater_than'));	
delete from vw_condition_calculation_def_assign where
	condition_def_uuid = (select condition_def_uuid from vw_condition_def where description = 'temp > threshold ?') and
	calculation_def_uuid = (select calculation_def_uuid from vw_calculation_def where short_name = 'greater_than');
delete from vw_calculation_def where short_name = 'greater_than';
delete from vw_condition_def where description = 'temp > threshold ?';



/*
Name:			upsert_experiment()
Notes:
*/
insert into vw_experiment (ref_uid, description, parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid) 
	values (
		'test_red_uid', 'test_experiment',
		null,
		(select actor_uuid from vw_actor where description = 'Dev Test123'),						
		(select actor_uuid from vw_actor where description = 'Dev Test123'),
		(select actor_uuid from vw_actor where description = 'Dev Test123'),
		null);
update vw_experiment set status_uuid = (select status_uuid from vw_status where description = 'dev_test') where description = 'test_experiment'; 


/*
Name:			upsert_experiment_workflow()
Notes:
*/

insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid) 
	values (
		1, 
		(select experiment_uuid from vw_experiment where description = 'test_experiment'),
		(select workflow_uuid from vw_workflow where description = 'workflow_test'));
delete from vw_experiment_workflow 
 		where experiment_uuid = (select experiment_uuid from vw_experiment where description = 'test_experiment');


/*
Name:			upsert_inventory()
Notes:
*/
insert into vw_inventory (description, owner_uuid, operator_uuid, lab_uuid, actor_uuid, status_uuid)
    values (
        'test_inventory',
        (select actor_uuid from vw_actor where description = 'Dev Test123'),
        (select actor_uuid from vw_actor where description = 'Dev Test123'),
        (select actor_uuid from vw_actor where description = 'Dev Test123'),
        (select actor_uuid from vw_actor where description = 'Dev Test123'),
        (select status_uuid from vw_status where description = 'active'));


/*
Name:			upsert_inventory_material()
Notes:
*/
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, part_no, onhand_amt, expiration_date, location, status_uuid) values
	(
	 (select inventory_uuid from vw_inventory where description = 'test_inventory'),
	 'Water',
	(select material_uuid from vw_material where description = 'Water'),
	(select actor_uuid from vw_actor where description = 'Dev Test123'),
	'xxx_123_24',
	(select put_val((select get_type_def ('data', 'num')),'100.00','L')),
	'2021-12-31',
	'Shelf 3, Bin 2',
	(select status_uuid from vw_status where description = 'dev_test'));

/*
Name:			upsert_bom()
Notes:
*/
insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) 
	values (
	(select experiment_uuid from vw_experiment where description = 'test_experiment'),
	'test_bom',					
	(select actor_uuid from vw_actor where description = 'Dev Test123'),
	(select status_uuid from vw_status where description = 'dev_test'));
update vw_bom set status_uuid = (select status_uuid from vw_status where description = 'dev_test') where description = 'test_bom'; 


/*
Name:			upsert_bom_material()
Notes:
*/
insert into vw_bom_material (bom_uuid, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid)
	values (
	(select bom_uuid from vw_bom where description = 'test_bom'),
	(select inventory_material_uuid from vw_inventory_material where description = 'Water'),
	(select put_val((select get_type_def ('data', 'num')), '9999.99','mL')),
	null, null,				
	(select actor_uuid from vw_actor where description = 'Dev Test123'),
	(select status_uuid from vw_status where description = 'dev_test'));
update vw_bom_material set used_amt_val = (select put_val((select get_type_def ('data', 'num')), '487.21','mL')) 
	where inventory_material_uuid = (select inventory_material_uuid from vw_inventory_material where description = 'Water');
-- clean up bom_material, bom, workflow, experiment						
delete from vw_bom_material where inventory_material_uuid = (select inventory_material_uuid from vw_inventory_material where description = 'Water');
delete from vw_bom where description = 'test_bom';
delete from vw_inventory_material where description = 'Water';
delete from vw_workflow where description = 'workflow_test' ;
delete from vw_workflow_type where description = 'workflowtype_test';
delete from vw_experiment where description = 'test_experiment';
delete from vw_inventory where description = 'test_inventory';


------------------------------------------------------------------------
-- clean up a test actor (person) and test status
delete from vw_actor where actor_uuid in (select actor_uuid from vw_actor where person_last_name = 'Test123');
delete from vw_status where status_uuid = (select status_uuid from vw_status where (description = 'dev_test'));
------------------------------------------------------------------------




--======================================================================
--======================================================================
-- scratch area to set up specific scenarios for further dev and testing
--
--        !!!! REMEMBER TO COMMENT OUT OR REMOVE WHEN DONE !!!!
--======================================================================
--======================================================================
--======================================================================
-- set up test org
-- ===========================================================================
insert into vw_organization (description, full_name, short_name, address1, address2, city, state_province,
                             zip, country, website_url, phone, parent_uuid)
                             values ('Test Laboratory Organization','NewLabCo','NLC','1001 New Lab Lane',
                                     null,'Science City','NY','99999',null,null,null,null);
-- set up a test actor (person) and test status to be used throughout
insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) 
	values ('Bond','Ion','X','123 Testing Ln',null,'Test City','NY','99999',null,null,null,null,null,null);
insert into vw_status (description) values ('dev_test');

-- add some chemicals to material so we can use them in an experiment (BOM -> bill of materials)
-- added HCl, water and AM-243 into chem inventory_material.
-- ===========================================================================
-- add some material types
-- ===========================================================================
insert into vw_material_type (description) 
values 
	('separation target'),
	('gas'),
	('stock solution'),
	('human prepared'),
	('solute');

-- ===========================================================================
-- add in property_defs and measure_defs
-- so they can be used to record action and outcome measures
-- ===========================================================================
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('temperature', 'temperature',
	(select get_type_def ('data', 'num')),
	'C',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('stir rate', 'stir_rate',
	(select get_type_def ('data', 'num')),
	'rpm',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('color', 'color',
	(select get_type_def ('data', 'text')),
	'',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_measure_def (default_measure_type_uuid, description, default_measure_value, property_def_uuid, actor_uuid, status_uuid) values
	((select measure_type_uuid from vw_measure_type where description = 'manual'),
	'plate temp',
	(select put_val(
        (select get_type_def ('data', 'num')),
        '0.0',
        'C')),
    (select property_def_uuid from vw_property_def where description = 'temperature'),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_measure_def (default_measure_type_uuid, description, default_measure_value, property_def_uuid, actor_uuid, status_uuid) values
	((select measure_type_uuid from vw_measure_type where description = 'manual'),
	'plate stir',
	(select put_val(
        (select get_type_def ('data', 'num')),
        '0',
        'rpm')),
    (select property_def_uuid from vw_property_def where description = 'stir rate'),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_measure_def (default_measure_type_uuid, description, default_measure_value, property_def_uuid, actor_uuid, status_uuid) values
	((select measure_type_uuid from vw_measure_type where description = 'manual'),
	'sample color',
	(select put_val(
        (select get_type_def ('data', 'text')),
        '',
        '')),
    (select property_def_uuid from vw_property_def where description = 'color'),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
-- ===========================================================================
-- add in test materials
-- property_def's for the resin
-- ===========================================================================
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('particle-size {min, max}', 'particle-size', 
	(select get_type_def ('data', 'array_num')), 
	'mesh', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('capacity', 'capacity', 
	(select get_type_def ('data', 'num')), 
	'meq/mL', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('cross-linkage %', 'cross-linkage', 
	(select get_type_def ('data', 'num')), 
	'', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('moisture % {min, max}', 'moisture', 
	(select get_type_def ('data', 'array_num')), 
	'', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
-- add properties to resin
insert into vw_material_property (material_uuid, property_def_uuid, property_value, property_actor_uuid, property_status_uuid ) values
	((select material_uuid from vw_material where description = 'Fine Mesh Resin'),
	(select property_def_uuid from vw_property_def where short_description = 'particle-size'),
	'{100, 200}', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_material_property (material_uuid, property_def_uuid, property_value, property_actor_uuid, property_status_uuid ) values
	((select material_uuid from vw_material where description = 'Fine Mesh Resin'),
	(select property_def_uuid from vw_property_def where short_description = 'capacity'),
	'1.7', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_material_property (material_uuid, property_def_uuid, property_value, property_actor_uuid, property_status_uuid ) values
	((select material_uuid from vw_material where description = 'Fine Mesh Resin'),
	(select property_def_uuid from vw_property_def where short_description = 'cross-linkage'),
	'8', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_material_property (material_uuid, property_def_uuid, property_value, property_actor_uuid, property_status_uuid ) values
	((select material_uuid from vw_material where description = 'Fine Mesh Resin'),
	(select property_def_uuid from vw_property_def where short_description = 'moisture'),
	'{50, 58}', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));

-- 24 well plate
-- plate and well properties (location, volume, ord (order))
-- creates linked list of plate wells in order of the arrays below
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('plate well count', 'plate_well_cnt', 
	(select get_type_def ('data', 'int')), 
	null, 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('plate well location', 'well_loc', 
	(select get_type_def ('data', 'text')), 
	null, 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('plate well robot order', 'well_ord', 
	(select get_type_def ('data', 'int')), 
	null, 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('plate well volume {min, max}', 'well_vol', 
	(select get_type_def ('data', 'array_num')), 
	'ml', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
	('concentration', 'concentration', 
	(select get_type_def ('data', 'num')), 
	'', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add a 24 well plate
insert into vw_material (description, consumable, actor_uuid, status_uuid) values 
	('Plate: 24 well', FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add a 48 well plate
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Plate: 48 well', FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add plate well
insert into vw_material (description, consumable, actor_uuid, status_uuid) values 
	('Plate well', FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- assign the 24 plate a well qty property
insert into vw_material_property (material_uuid, property_def_uuid, 
	property_value, property_actor_uuid, property_status_uuid ) values (
	(select material_uuid from vw_material where description = 'Plate: 24 well'),
	(select property_def_uuid from vw_property_def where short_description = 'plate_well_cnt'), 
	'24', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'), 
	(select status_uuid from vw_status where description = 'dev_test'));
-- assign the 48 plate a well qty property
insert into vw_material_property (material_uuid, property_def_uuid,
	property_value, property_actor_uuid, property_status_uuid ) values (
	(select material_uuid from vw_material where description = 'Plate: 48 well'),
	(select property_def_uuid from vw_property_def where short_description = 'plate_well_cnt'),
	'48',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add some hardware to material so we can use in an experiment (24 well plate)
-- insert the well location properties A1-D6 (24)
-- we'll figure out a way to do this more compactly through a higher level insert
DO
$do$
DECLARE
	loc_let varchar;
	loc_num	varchar;
	ord int := 1;
	loc_arr_let varchar[] := array['A','B','C','D','E','F'];
	loc_arr_num varchar[] := array['1','2','3','4','5','6','7','8'];
	prop_loc_def uuid := (select property_def_uuid from vw_property_def where short_description = 'well_loc');
	prop_vol_def uuid := (select property_def_uuid from vw_property_def where short_description = 'well_vol');
	prop_ord_def uuid := (select property_def_uuid from vw_property_def where short_description = 'well_ord');
	act uuid := (select actor_uuid from vw_actor where description = 'Ion Bond');
	st uuid := (select status_uuid from vw_status where description = 'dev_test');
	plate_24_uuid uuid := (select material_uuid from vw_material where description = 'Plate: 24 well');
    plate_48_uuid uuid := (select material_uuid from vw_material where description = 'Plate: 48 well');
	well_uuid uuid;
	component_uuid uuid;
BEGIN
	FOREACH loc_let IN ARRAY loc_arr_let[1:4]
	LOOP
		FOREACH loc_num IN ARRAY loc_arr_num[1:6]
   		LOOP
   			insert into vw_material (description, consumable, actor_uuid, status_uuid) values 
				(concat('Plate well#: ',loc_let,loc_num), FALSE,
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_uuid into well_uuid;
			insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) values 
				(plate_24_uuid, well_uuid, TRUE,
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_composite_uuid into component_uuid;
			insert into vw_material_property (material_uuid, property_def_uuid, 
					property_value, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_ord_def, 
						ord::text, 
						act, st);
			insert into vw_material_property (material_uuid, property_def_uuid, 
					property_value, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_loc_def, 
						concat(loc_let,loc_num), 
						act, st);
			insert into vw_material_property (material_uuid, property_def_uuid, 
					property_value, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_vol_def, 
						'{.5,10}',
						act, st);
			ord := ord + 1;
   		END LOOP;
	END LOOP;
END
$do$; 

-- add remaining [composite] materials
-- Am-243 Stock (composite)
insert into vw_material (description, consumable, actor_uuid, status_uuid) values 
	('Am-243 Stock', TRUE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add the components
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Am-243 Stock'),
	(select material_uuid from vw_material where description = 'Am-243'),
	FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
	);	
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Am-243 Stock'),
	(select material_uuid from vw_material where description = 'Hydrochloric acid'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Am-243 Stock'),
	(select material_uuid from vw_material where description = 'Water'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
	);			
-- add material_type to materials
insert into vw_material_type_assign (material_uuid, material_type_uuid) values 
	((select material_uuid from vw_material where description = 'Am-243'),(select material_type_uuid from vw_material_type where description = 'separation target')),
	((select material_uuid from vw_material where description = 'Hydrochloric acid'),(select material_type_uuid from vw_material_type where description = 'gas')),
	((select material_uuid from vw_material where description = 'Am-243 Stock'),(select material_type_uuid from vw_material_type where description = 'stock solution')),
	((select material_uuid from vw_material where description = 'Am-243 Stock'),(select material_type_uuid from vw_material_type where description = 'human prepared')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Am-243'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Hydrochloric acid'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Water'),
		(select material_type_uuid from vw_material_type where description = 'solvent'));
-- add component properties
-- assign the parent a well qty property 
insert into vw_material_property (material_uuid, property_def_uuid, 
	property_value, property_value_unit, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Am-243'),
	(select property_def_uuid from vw_property_def where short_description = 'concentration'), 
	'1000', 'dpm/uL',
	(select actor_uuid from vw_actor where description = 'Ion Bond'), 
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_material_property (material_uuid, property_def_uuid, 
	property_value, property_value_unit, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Hydrochloric acid'),
	(select property_def_uuid from vw_property_def where short_description = 'concentration'), 
	'.1', 'M',
	(select actor_uuid from vw_actor where description = 'Ion Bond'), 
	(select status_uuid from vw_status where description = 'dev_test'));
-- Next (and last) composite material
-- HCl-12M (composite)
insert into vw_material (description, consumable, actor_uuid, status_uuid) values 
	('HCl-12M', TRUE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add the components
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'HCl-12M'),
	(select material_uuid from vw_material where description = 'Hydrochloric acid'),
	FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
	);	
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'HCl-12M'),
	(select material_uuid from vw_material where description = 'Water'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
	);


-- ===========================================================================
-- create an inventory
-- add materials to inventory_material (in order for bom to have something to pull from)
-- start with 24 well plate
-- ===========================================================================
insert into vw_inventory (description, owner_uuid, operator_uuid, lab_uuid, actor_uuid, status_uuid)
	values (
	'Test Inventory',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select actor_uuid from vw_actor where description = 'NLC'),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid) 
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'24 well plate',
				(select material_uuid from vw_material where description = 'Plate: 24 well'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# 24wp_123',
				(select put_val((select get_type_def ('data', 'int')),'2','')),
                '2022-12-31',
                'Shelf 1, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add water to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid) 
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'Water',
				(select material_uuid from vw_material where description = 'Water'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# h2o',
				(select put_val((select get_type_def ('data', 'num')),'5000','mL')),
                '2021-12-31',
                'Shelf 2, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add hcl to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid) 
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'HCL',
				(select material_uuid from vw_material where description = 'Hydrochloric acid'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# hcl_222',
				(select put_val((select get_type_def ('data', 'num')),'1000','mL')),
                '2021-12-31',
                'Shelf 10, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add resin to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid) 
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'Resin',
				(select material_uuid from vw_material where description = 'Fine Mesh Resin'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# amberchrom_50wx8',
				(select put_val((select get_type_def ('data', 'num')),'100','g')),
                '2021-12-31',
                'Shelf 5, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add Am-243 Stock to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid) 
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'Am-243 Stock',
				(select material_uuid from vw_material where description = 'Am-243 Stock'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# am-243-stock_002',
				(select put_val((select get_type_def ('data', 'int')),'100','mL')),
                '2021-12-31',
                'Shelf xx, Bin x2',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add HCl-12M to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid) 
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'HCl-12M',
				(select material_uuid from vw_material where description = 'HCl-12M'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# hcl12M_202011',
				(select put_val((select get_type_def ('data', 'int')),'1000','mL')),
                '2022-12-31',
                'Shelf 03, Bin 22',
				(select status_uuid from vw_status where description = 'dev_test')
				);

-- ===========================================================================
-- set up actions, parameter defs
-- ===========================================================================
-- upsert condition, condition-calculation
insert into vw_condition_def (description, actor_uuid, status_uuid) values
	('temp > threshold ?', (select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_calculation_def 
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, 		
	in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid ) 
	values ('greater_than', 'pop A, pop B, >', 
		(select systemtool_uuid from vw_actor where systemtool_name = 'escalate'),
		'B > A ? (pop B, pop A, >?) returning true or false', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'bool'),
		null, (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_condition_calculation_def_assign (condition_def_uuid, calculation_def_uuid)
	VALUES ((select condition_def_uuid from vw_condition_def where description = 'temp > threshold ?'),
		(select calculation_def_uuid from vw_calculation_def where short_name = 'greater_than'));
insert into vw_calculation_def 
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, 		
	in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid ) 
	values ('num_array_index', '[x, y, z], 2 -> y', 
		(select systemtool_uuid from vw_actor where systemtool_name = 'escalate'),
		'return numeric from indexed array', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'num'),
		null, (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_parameter_def (description, default_val, actor_uuid, status_uuid)
	values
	    ('volume',
        (select put_val((select get_type_def ('data', 'num')), '0', 'mL')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')),
    	('duration',
        (select put_val((select get_type_def ('data', 'num')), '0', 'mins')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ('speed',
        (select put_val ((select get_type_def ('data', 'num')),'0','rpm')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ('temperature',
        (select put_val((select get_type_def ('data', 'num')), '0', 'degC')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_action_def (description, actor_uuid, status_uuid) values
	('dispense', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test')),
	('heat_stir', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('heat', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('start_node', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('end_node', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test'));
-- add a note to dispense action indicating that source is the dispensed material
-- and destination is the container
insert into vw_note (notetext, actor_uuid, ref_note_uuid) values 
	('source material = material to be dispensed, destination material = plate well', 
	(select actor_uuid from vw_actor where description = 'Ion Bond'), 
	(select action_def_uuid from vw_action_def where description = 'dispense')); 

insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid)
	values 
		((select action_def_uuid from vw_action_def where description = 'dispense'),
    	(select parameter_def_uuid from vw_parameter_def where description = 'volume')),
		((select action_def_uuid from vw_action_def where description = 'heat_stir'),
    	(select parameter_def_uuid from vw_parameter_def where description = 'duration')),
        ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
        (select parameter_def_uuid from vw_parameter_def where description = 'temperature')),
        ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
        (select parameter_def_uuid from vw_parameter_def where description = 'speed')),
        ((select action_def_uuid from vw_action_def where description = 'heat'),
        (select parameter_def_uuid from vw_parameter_def where description = 'duration')),
        ((select action_def_uuid from vw_action_def where description = 'heat'),
        (select parameter_def_uuid from vw_parameter_def where description = 'temperature'));

-- ===========================================================================
-- set up some calculations
-- ===========================================================================
-- define the calculation parameters, calculations and then join together
insert into vw_parameter_def (description, default_val, actor_uuid, status_uuid)
	values
	    ('hcl_concentrations',
        (select put_val((select get_type_def ('data', 'array_num')), '{12.0,6.0,4.0,2.0,1.0,.1,.01,.001}', '')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')),
    	('total_vol',
        (select put_val((select get_type_def ('data', 'num')), '5', 'mL')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ('stock_concentration',
        (select put_val ((select get_type_def ('data', 'num')),'12','M')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- first one is for determining 12M HCL, Water for various concentrations in 5mL
-- calc_def's first
insert into vw_calculation_def
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid,
	in_opt_type_uuid, out_type_uuid, out_unit, calculation_class_uuid, actor_uuid, status_uuid )
	values ('LANL_WF1_HCL12M_5mL_concentration', 'math_op_arr(math_op_arr(''hcl_concentrations'', ''/'', stock_concentration), ''*'', total_vol)',
		(select systemtool_uuid from vw_actor where systemtool_name = 'postgres'),
		'LANL WF1: return array of mL vols for 12M HCL for 5mL target across concentration array', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'array_num'), 'mL',
		null, (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')
		);
insert into vw_calculation_def
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid,
	in_opt_type_uuid, out_type_uuid, out_unit, calculation_class_uuid, actor_uuid, status_uuid )
	values ('LANL_WF1_H2O_5mL_concentration', 'math_op_arr(math_op_arr(math_op_arr(''hcl_concentrations'', ''/'', stock_concentration), ''*'', (math_op(0, ''-'', total_vol))), ''+'', total_vol)',
		(select systemtool_uuid from vw_actor where systemtool_name = 'postgres'),
		'LANL WF1: return array of mL vols for H2O for 5mL target across concentration array', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'array_num'), 'mL',
		null, (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')
		);
insert into vw_calculation_parameter_def (calculation_def_uuid, parameter_def_uuid)
    values (
        (select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'hcl_concentrations')),
        ((select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'total_vol')),
        ((select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'stock_concentration'));
insert into vw_calculation_parameter_def (calculation_def_uuid, parameter_def_uuid)
    values (
        (select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_H2O_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'hcl_concentrations')),
        ((select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_H2O_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'total_vol')),
        ((select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_H2O_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'stock_concentration'));
-- now create the calculation for HCL
insert into vw_calculation (calculation_def_uuid, calculation_alias_name, in_val, in_opt_val, out_val, actor_uuid, status_uuid) values
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration'),
    'LANL_WF1_HCL12M_5mL_concentration',
    null,
    null,
    (select do_calculation((select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration'))),
 	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
);
-- calculation for H2O
insert into vw_calculation (calculation_def_uuid, calculation_alias_name, in_val, in_opt_val, out_val, actor_uuid, status_uuid) values
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_H2O_5mL_concentration'),
    'LANL_WF1_H2O_5mL_concentration',
    null,
    null,
    (select do_calculation((select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_H2O_5mL_concentration'))),
 	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
);


-- ===========================================================================
-- set up experiment
-- ===========================================================================
insert into vw_experiment (ref_uid, description, parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid)
	values (
		'test_uid', 'LANL Test Experiment Template',
		null,
		(select actor_uuid from vw_actor where description = 'NLC'),
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select actor_uuid from vw_actor where description = 'NLC'),
		(select status_uuid from vw_status where description = 'dev_test'));

-- ===========================================================================
-- set up outcome (container)
-- ===========================================================================
insert into vw_outcome (experiment_uuid, description, actor_uuid, status_uuid)
	values (
		(select experiment_uuid from vw_experiment where description = 'LANL Test Experiment Template'),
		'LANL Test Experiment Outcome',
 	    (select actor_uuid from vw_actor where description = 'Ion Bond'),
	    (select status_uuid from vw_status where description = 'dev_test'));

-- =========================================================================== 
-- BOM
-- =========================================================================== 
insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) values 
	((select experiment_uuid from vw_experiment where description = 'LANL Test Experiment Template'),
	'LANL Test BOM',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- then add materials (and amounts) to BOM
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Test BOM'),
    'HCl-12M',
	(select inventory_material_uuid from vw_inventory_material where description = 'HCl-12M'),
	(select put_val((select get_type_def ('data', 'num')), '60.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),				
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Test BOM'),
    'H2O',
	(select inventory_material_uuid from vw_inventory_material where description = 'Water'),
	(select put_val((select get_type_def ('data', 'num')), '60.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),				
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Test BOM'),
    'Am-243 Stock',
	(select inventory_material_uuid from vw_inventory_material where description = 'Am-243 Stock'),
	(select put_val((select get_type_def ('data', 'num')), '1.20','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),				
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Test BOM'),
    'Resin',
	(select inventory_material_uuid from vw_inventory_material where description = 'Resin'),
	(select put_val((select get_type_def ('data', 'num')), '0.60','g')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','g')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','g')),				
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Test BOM'),
    'Sample Prep Plate',
	(select inventory_material_uuid from vw_inventory_material where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),				
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Test BOM'),
    'Sample Assay Plate',
	(select inventory_material_uuid from vw_inventory_material where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- ===========================================================================
-- create workflows
-- ===========================================================================
-- create workflow_action_set for H2O
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL_WF1a_H2O_SamplePrep',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- create workflow_action_set for HCL
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL_WF1b_HCL_SamplePrep',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- create workflow for Setting Plate Temp
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL_WF1c_SetTemp_SamplePrep',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- create workflow for Setting Plate Temp
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL_WF2_Am-243Stock_Dispense',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- associate wf's with experiment
insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid)
    values (1,
        (select experiment_uuid from vw_experiment where description = 'LANL Test Experiment Template'),
        (select workflow_uuid from vw_workflow where description = 'LANL_WF1a_H2O_SamplePrep')),
        (2,
        (select experiment_uuid from vw_experiment where description = 'LANL Test Experiment Template'),
        (select workflow_uuid from vw_workflow where description = 'LANL_WF1b_HCL_SamplePrep')),
        (3,
        (select experiment_uuid from vw_experiment where description = 'LANL Test Experiment Template'),
        (select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep')),
        (4,
        (select experiment_uuid from vw_experiment where description = 'LANL Test Experiment Template'),
        (select workflow_uuid from vw_workflow where description = 'LANL_WF2_Am-243Stock_Dispense'));

-- create the action_sets
insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('dispense H2O into SamplePrep Plate action_set',
        (select workflow_uuid from vw_workflow where description = 'LANL_WF1a_H2O_SamplePrep'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        null,
        (select calculation_uuid from vw_calculation where short_name = 'LANL_WF1_H2O_5mL_concentration'),
 --       (select arr_val_2_val_arr ((select out_val from vw_calculation where short_name = 'LANL_WF1_H2O_5mL_concentration'))),
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'H2O')],
        array [
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A1%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A2%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A3%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A4%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A5%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A6%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%B1%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%B2%')],
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('dispense HCL into SamplePrep Plate action_set',
        (select workflow_uuid from vw_workflow where description = 'LANL_WF1b_HCL_SamplePrep'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        null,
        (select calculation_uuid from vw_calculation where short_name = 'LANL_WF1_HCL12M_5mL_concentration'),
 --       (select arr_val_2_val_arr ((select out_val from vw_calculation where short_name = 'LANL_WF1_H2O_5mL_concentration'))),
        (select array [(select bom_material_index_uuid from vw_bom_material_index where description = 'HCl-12M')]),
        (select array(select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%'
            and description similar to '%(A1|A2|A3|A4|A5|A6|B1|B2)%')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values  ('dispense Am-Stock into SamplePrep Plate action_set',
        (select workflow_uuid from vw_workflow where description = 'LANL_WF2_Am-243Stock_Dispense'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array[(select put_val((select get_type_def('data', 'num')), '.1', 'mL'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Am-243 Stock')],
        array [
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A1%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A2%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A3%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A4%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A5%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%A6%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%B1%'),
            (select bom_material_index_uuid from vw_bom_material_index where description like '%Sample Prep Plate%B2%')],
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));
/*
insert into vw_action (action_def_uuid, workflow_uuid, action_description, source_material_uuid, actor_uuid, status_uuid)
	values (
    	(select action_def_uuid from vw_action_def where description = 'heat'),
    	(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
        'Heat Sample Prep Plate',
        (select bom_material_index_uuid from vw_bom_material_index where description = 'Sample Prep Plate'),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select action_uuid from vw_action where action_description = 'Heat Sample Prep Plate'));

insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Heat Sample Prep Plate')),
        null,
        (select status_uuid from vw_status where description = 'dev_test'));
*/
insert into vw_condition (workflow_uuid, condition_calculation_def_x_uuid, in_val, out_val, actor_uuid, status_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select condition_calculation_def_x_uuid from vw_condition_calculation_def_assign where condition_description = 'temp > threshold ?'),
		(SELECT put_val ((select get_type_def ('data', 'num')), '100', 'C')),
		(SELECT put_val ((select get_type_def ('data', 'bool')), 'false', null)),
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_action (action_def_uuid, workflow_uuid, action_description, actor_uuid, status_uuid)
	values (
    	(select action_def_uuid from vw_action_def where description = 'dispense'),
    	(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
        'example_dispense',
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_action (action_def_uuid, workflow_uuid, action_description, actor_uuid, status_uuid)
	values (
    	(select action_def_uuid from vw_action_def where description = 'heat_stir'),
    	(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
        'example_heat_stir',
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_action (action_def_uuid, workflow_uuid, action_description, actor_uuid, status_uuid)
	values (
    	(select action_def_uuid from vw_action_def where description = 'heat'),
    	(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
        'example_heat',
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_action (action_def_uuid, workflow_uuid, action_description, actor_uuid, status_uuid)
	values (
    	(select action_def_uuid from vw_action_def where description = 'start_node'),
    	(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
        'start',
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_action (action_def_uuid, workflow_uuid, action_description, actor_uuid, status_uuid)
	values (
    	(select action_def_uuid from vw_action_def where description = 'end_node'),
    	(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
        'end',
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));

-- set up the workflow step object (from actions and conditions)
insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select action_uuid from vw_action where action_description = 'example_heat'));
insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select action_uuid from vw_action where action_description = 'example_heat_stir'));
insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select action_uuid from vw_action where action_description = 'example_dispense'));
insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select action_uuid from vw_action where action_description = 'start'));
insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select action_uuid from vw_action where action_description = 'end'));
-- now define the path(s) between object -> workflow_step
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'start')),
		null,
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'example_dispense')),
		(select workflow_step_uuid from vw_workflow_step where (object_type = 'action' and object_description = 'start')),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'example_heat')),
		(select workflow_step_uuid from vw_workflow_step where (object_type = 'action' and object_description = 'example_dispense')),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'LANL_WF1c_SetTemp_SamplePrep'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'end')),
		(select workflow_step_uuid from vw_workflow_step where (object_type = 'action' and object_description = 'example_heat')),
		(select status_uuid from vw_status where description = 'dev_test'));

-- let's set the temperature and duration of the action heat sample plate
update vw_action_parameter
    set parameter_val = (select put_val (
            (select val_type_uuid from vw_parameter_def where description = 'volume'),
             '1.5',
            (select valunit from vw_parameter_def where description = 'volume'))
            )
where (action_description = 'example_dispense' AND parameter_def_description = 'volume');
update vw_action_parameter
    set parameter_val = (select put_val (
            (select val_type_uuid from vw_parameter_def where description = 'temperature'),
             '110.23',
            (select valunit from vw_parameter_def where description = 'temperature'))
            )
where (action_description = 'example_heat' AND parameter_def_description = 'temperature');
update vw_action_parameter
    set parameter_val = (select put_val (
            (select val_type_uuid from vw_parameter_def where description = 'duration'),
             '10',
            (select valunit from vw_parameter_def where description = 'duration'))
            )
where (action_description = 'example_heat' AND parameter_def_description = 'duration');


-- add in some measures
-- to action(s)
insert into vw_measure (measure_def_uuid, measure_type_uuid, ref_measure_uuid, description, measure_value, actor_uuid, status_uuid) values
	((select measure_def_uuid from vw_measure_def where description = 'plate temp'),
	 (select measure_type_uuid from vw_measure_type where description = 'manual'),
	 (select action_uuid from vw_action where action_description = 'Heat Sample Prep Plate'),
	'sample plate temperature',
	(select put_val(
        (select get_type_def ('data', 'num')),
        '52.9',
        'C')),
    (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test'));

-- add measure(s) to outcome
insert into vw_measure (measure_def_uuid, measure_type_uuid, ref_measure_uuid, description, measure_value, actor_uuid, status_uuid) values
	((select measure_def_uuid from vw_measure_def where description = 'sample color'),
	 (select measure_type_uuid from vw_measure_type where description = 'manual'),
	 (select outcome_uuid from vw_outcome where description = 'LANL Test Experiment Outcome'),
	'sample color observation',
	(select put_val(
        (select get_type_def ('data', 'text')),
        'green to green-yellow',
        '')),
    (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test'));

-- add tags to measure
insert into vw_tag_assign (tag_uuid, ref_tag_uuid) values
    ((select tag_uuid from vw_tag where (display_text = 'subjective' and vw_tag.type = 'measure')),
     (select measure_uuid from vw_measure where
        measure_def_description = 'sample color' and measure_value_value = 'green to green-yellow'
        and actor_description = 'Ion Bond')),
    ((select tag_uuid from vw_tag where (display_text = 'preliminary' and vw_tag.type = 'measure')),
     (select measure_uuid from vw_measure where
        measure_def_description = 'sample color' and measure_value_value = 'green to green-yellow'
        and actor_description = 'Ion Bond'));

-- add a note to measure
insert into vw_note (notetext, actor_uuid, ref_note_uuid) values ('quick assessment of color, no color chart',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select measure_uuid from vw_measure where
        measure_def_description = 'sample color' and measure_value_value = 'green to green-yellow'
        and actor_description = 'Ion Bond'));
