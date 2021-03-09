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
-- =====================================================================
