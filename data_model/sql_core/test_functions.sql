--======================================================================
/*
Name:			test_functions v1
Parameters:		none
Returns:		NA
Author:			G. Cattabriga
Date:			2020.09.27
Description:	test [most] functions, [all] upserts. For upserts, perforn all methods
				(e.g. insert, update, delete)
Notes:			Make sure to use status = 'dev_test' and actor = 'Test123' for 
				all upserts. These are 'insert'ed at the beginning of the upsert
				tests, and 'delete'd at the end	

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
Name:			get_materialid_bystatus (p_status_arr, p_null_bool)
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
--insert into vw_material (material_description) values ('devtest_material');
-- delete from vw_material where material_uuid = 
	(select material_uuid from vw_material where (description = 'devtest_material'));


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
	val_val, property_actor_uuid, property_status_uuid ) 
	values ((select material_uuid from vw_material where description = 'Formic Acid'),
		(select property_def_uuid from vw_property_def where short_description = 'devtest property'),
		'{100, 200}', 
		null,
		(select status_uuid from vw_status where description = 'dev_test')
);
update vw_material_property set property_actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Test123') where material_uuid = 
	(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'devtest property';
update vw_material_property set val_val = '{100, 900}' where material_uuid = 
	(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'devtest property';
delete from vw_material_property where material_uuid = 
	(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'devtest property';
delete from vw_property_def where short_description = 'devtest property';


/*
Name:			upsert_calculation_def()
Notes:				
*/ 


/*
Name:			upsert_calculation()
Notes:				
*/ 
 
/*
Name:			upsert_workflow()
Notes:				
*/

/*
Name:			upsert_parameter_def()
Notes:				
*/ 
insert into vw_parameter_def (description, val_type_uuid, valunit, actor_uuid) values
	('devtest_param', (select get_type_def ('data', 'num')), 'hours', (select actor_uuid from vw_actor where person_last_name = 'Test123'));
update vw_parameter_def set status_uuid = (select status_uuid from vw_status where description = 'dev_test') where description = 'devtest_param';
delete from vw_parameter_def where description = 'devtest_param';


/*
 Name:			upsert_action_def()
 Notes:
*/
insert into vw_action_def (description, actor_uuid) values
	('devtest_actiondef', (select actor_uuid from vw_actor where person_last_name = 'Test123'));
update vw_action_def set status_uuid = (select status_uuid from vw_status where description = 'dev_test') where description = 'devtest_actiondef';
delete from vw_action_def where description = 'devtest_actiondef';


/*
 Name:			upsert_action_parameter_def_assign()
 Notes:			
*/
insert into vw_parameter_def (description, val_type_uuid, valunit, actor_uuid) values
	('devtest_param', (select get_type_def ('data', 'num')), 'hours', (select actor_uuid from vw_actor where person_last_name = 'Test123'));
insert into vw_action_def (description, actor_uuid) values
	('devtest_actiondef', (select actor_uuid from vw_actor where person_last_name = 'Test123'));
insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid)
	VALUES (
		(select action_def_uuid from vw_action_def where description = 'devtest_actiondef'), 
		(select parameter_def_uuid from vw_parameter_def where description = 'devtest_param')
	);
delete from vw_action_parameter_def_assign where 
	action_def_uuid = (select action_def_uuid from vw_action_def where description = 'devtest_actiondef') AND
	parameter_def_uuid = (select parameter_def_uuid from vw_parameter_def where description = 'devtest_param');
delete from vw_action_def where description = 'devtest_actiondef';
delete from vw_parameter_def where description = 'devtest_param';


/*
Name:			upsert_parameter()
Notes:
*/ 
insert into vw_parameter_def (description, val_type_uuid, valunit, actor_uuid) values
	('devtest_param', (select get_type_def ('data', 'num')), 'hours', (select actor_uuid from vw_actor where person_last_name = 'Test123'));
insert into vw_parameter (parameter_def_uuid, ref_parameter_uuid, parameter_val, actor_uuid, status_uuid ) values (
	(select parameter_def_uuid from vw_parameter_def where description = 'devtest_param'),
	(select actor_uuid from vw_actor where person_last_name = 'Test123'),
	(select put_val (
		(select val_type_uuid from vw_parameter_def where description = 'devtest_param'),
		'10',
		(select valunit from vw_parameter_def where description = 'devtest_param'))
	),
	(select actor_uuid from vw_actor where person_last_name = 'Test123'),
	(select status_uuid from vw_status where description = 'devtest_param')
);
update vw_parameter set parameter_val = (select put_val (
    (select val_type_uuid from vw_parameter_def where description = 'devtest_param'),
	'36',
	(select valunit from vw_parameter_def where description = 'devtest_param')))
	where parameter_def_description = 'devtest_param';
delete from vw_parameter where parameter_def_description = 'devtest_param' AND 
	ref_parameter_uuid = (select actor_uuid from vw_actor where person_last_name = 'Test123');
delete from vw_parameter_def where description = 'devtest_param';


/*
Name:			upsert_workflow_type()
Notes:				
*/ 
-- insert into vw_workflow_type (description) values ('workflowtype_test');
-- delete from vw_workflow_type where workflow_type_uuid = (select workflow_type_uuid from vw_workflow_type where (description = 'workflowtype_test'));


------------------------------------------------------------------------
-- clean up a test actor (person) and test status
delete from vw_actor where actor_uuid in (select actor_uuid from vw_actor where person_last_name = 'Test123');
delete from vw_status where status_uuid = (select status_uuid from vw_status where (description = 'dev_test'));
------------------------------------------------------------------------