/*
Name:					prod_functions
Parameters:		none
Returns:			NA
Author:				G. Cattabriga
Date:					2019.12.02
Description:	contain the core functions used in ESCALATE sql
Notes:				
*/
--=====================================

---------------------------------------
-- Make sure postgres extensions are 
-- installed
---------------------------------------
-- SET CLIENT_ENCODING=latin1;
-- CREATE EXTENSION IF NOT EXISTS tablefunc SCHEMA prod;
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA prod;


/*
Name:					read_file_utf8
Parameters:		path (varchar)
Returns:			string (text) of the file
Author:				G. Cattabriga
Date:					2019.07.24
Description:	read the contents of a text file, stripping out carriage returns, line feeds 
							and following spaces
Notes:				used primarily with json files that have CR, LF and needless spaces
*/
CREATE OR REPLACE FUNCTION read_file_utf8(path CHARACTER VARYING)
  RETURNS TEXT AS $$
DECLARE
  var_file_oid OID;
  var_record   RECORD;
  var_result   BYTEA := '';
	var_resultt	 TEXT;
BEGIN
  SELECT lo_import(path)
  INTO var_file_oid;
  FOR var_record IN (SELECT data
                     FROM pg_largeobject
                     WHERE loid = var_file_oid
                     ORDER BY pageno) LOOP
  var_result = var_result || var_record.data;
  END LOOP;
  PERFORM lo_unlink(var_file_oid);
	var_resultt = regexp_replace(convert_from(var_result, 'utf8'), E'[\\n\\r] +', '', 'g' );
  RETURN var_resultt;
END;
$$ LANGUAGE plpgsql;


/*
Name:					read_file
Parameters:		path (varchar)
Returns:			string (text) of the file
Author:				G. Cattabriga
Date:					2019.07.24
Description:	read the contents of a text file, retains all chars, including the control chars
Notes:				used for any non-json text file
*/
CREATE OR REPLACE FUNCTION read_file(path CHARACTER VARYING)
  RETURNS TEXT AS $$
DECLARE
  var_file_oid OID;
  var_record   RECORD;
  var_result   BYTEA := '';
	var_resultt	 TEXT;
BEGIN
  SELECT lo_import(path)
  INTO var_file_oid;
  FOR var_record IN (SELECT data
                     FROM pg_largeobject
                     WHERE loid = var_file_oid
                     ORDER BY pageno) LOOP
  var_result = var_result || var_record.data;
  END LOOP;
  PERFORM lo_unlink(var_file_oid);
  RETURN var_result;
END;
$$ LANGUAGE plpgsql;



/*
Name:					isdate
Parameters:		str (varchar) that contains string to test
Returns:			TRUE or FALSE
Author:				G. Cattabriga
Date:					2019.07.24
Description:	if str can be cast to a date, then return TRUE, else FALSE
Notes:
*/
DROP FUNCTION IF EXISTS isdate(txt VARCHAR) cascade;
CREATE OR REPLACE FUNCTION isdate ( txt VARCHAR ) RETURNS BOOLEAN AS $$ BEGIN
		perform txt :: DATE;
	RETURN TRUE;
	EXCEPTION 
	WHEN OTHERS THEN
		RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

/*
Name:					read_dirfiles
Parameters:		path (varchar) that contains directory path string
Returns:			TRUE or FALSE
Author:				G. Cattabriga
Date:					2019.07.31
Description:	creates load_FILES table populated with all file[names] starting with the 
							[path] directory and all subdirectory
							The filenames have full path including file extension
Notes:				Not much in the way of validation; only checks to see if there is a non-null
							'path' string in the function parameter, which will return FALSE
							Any other error (exception) will return FALSE
*/
CREATE OR REPLACE FUNCTION read_dirfiles ( PATH CHARACTER VARYING ) RETURNS BOOLEAN AS $$ DECLARE
	copycmd TEXT;
BEGIN
	IF ( PATH = '' ) THEN
			RETURN FALSE;
	ELSE 
		DROP TABLE IF EXISTS load_dirFILES;
		CREATE TABLE load_dirFILES ( filename TEXT );
		EXECUTE format ( 'COPY load_dirFILES FROM PROGRAM ''find %s -maxdepth 10 -type f'' ', PATH );
			RETURN TRUE;	
	END IF;
	EXCEPTION 
	WHEN OTHERS THEN
		RETURN FALSE;
END $$ LANGUAGE plpgsql;

/*
Name:				  parse_filename
Parameters:		none
Returns:			TRUE or FALSE
Author:				G. Cattabriga
Date:					2019.07.31
Description:	creates load_FILES table populated with all file[names] starting with the 
							[path] directory and all subdirectory
							The filenames have full path including file extension
Notes:				Not much in the way of validation; only checks to see if there is a non-null
							'path' string in the function parameter, which will return FALSE
							Any other error (exception) will return FALSE
*/


/*
Name:					trigger_set_timestamp
Parameters:		none
Returns:			'new' (now) timestamp
Author:				G. Cattabriga
Date:					2019.12.02
Description:	update the mod_dt (modify date) column with current date with timezone
Notes:				this creates both the function and the trigger (for all tables with mod_dt)
*/
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.mod_date = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
/*
-----------------------------------------------
-- drop trigger_set_timestamp triggers
DO $$
DECLARE
    t text;
BEGIN
    FOR t IN 
        SELECT table_name FROM information_schema.columns
        WHERE column_name = 'mod_date'
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
        WHERE column_name = 'mod_date'
    LOOP
        EXECUTE format('CREATE TRIGGER set_timestamp
                        BEFORE UPDATE ON %I
                        FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp()',
                        t);
    END LOOP;
END;
$$ LANGUAGE plpgsql;
*/


/*
Name:					get_materialid_bystatus (p_status_arr, p_null_bool)
Parameters:		p_status_array = array of status description (e.g. array['active', 'proto']) 
--						where ANY of the status descriptions match
--					  p_null_bool = true or false to include null status in returned set
Returns:			dataset of material_uuid's 
Author:				G. Cattabriga
Date:					2019.12.12
Description:	return material id's with specific status
Notes:				
Example:			SELECT * FROM get_material_uuid_bystatus (array['active', 'proto'], TRUE);
*/
DROP FUNCTION IF EXISTS get_material_uuid_bystatus (p_status_array VARCHAR[], p_null_bool BOOLEAN) cascade;
CREATE OR REPLACE FUNCTION get_material_uuid_bystatus (p_status_array varchar[], p_null_bool boolean)
RETURNS TABLE (
			material_uuid uuid,
			material_description varchar
) AS $$
BEGIN
	RETURN QUERY SELECT
			mat.material_uuid,
			mat.description
		FROM
			material mat
			LEFT JOIN status st ON mat.status_uuid = st.status_uuid
		WHERE
		CASE		
			WHEN p_null_bool THEN 
				st.description = ANY(p_status_array) OR st.description IS NULL 
			ELSE st.description = ANY(p_status_array) 
		END;
END;
$$ LANGUAGE plpgsql;


/*
Name:					get_material_nameref_bystatus (p_status_arr, p_null_bool)
Parameters:		p_status_array = array of status description (e.g. array['active', 'proto']) 
							where ANY of the status descriptions match
							p_null_bool = true or false to include null status in returned set
Returns:			dataset of material names, including alternative names
Author:				G. Cattabriga
Date:					2019.12.12
Description:	return material id, material name based on specific status
Notes:				need to UNION ALL the material descriptions with the returned set from function get_materialid_bystatus ()
							because there may be duplicate names
Example:			SELECT * FROM get_material_nameref_bystatus (array['active', 'proto'], TRUE) where material_refname_type = 'InChI' order by 1;
*/
DROP FUNCTION IF EXISTS get_material_nameref_bystatus (p_status_array VARCHAR[], p_null_bool BOOLEAN ) cascade;
CREATE OR REPLACE FUNCTION get_material_nameref_bystatus (p_status_array varchar[], p_null_bool boolean)
RETURNS TABLE (
      material_uuid uuid,
			material_refname varchar,
			material_refname_type varchar
) AS $$
BEGIN
	RETURN QUERY SELECT	
		mat.material_uuid,
		mnm.description AS mname,
		mt.description as material_refname_type
	FROM get_material_uuid_bystatus ( p_status_array, p_null_bool ) mat
	JOIN material_refname_x mx ON mat.material_uuid = mx.material_uuid 
	JOIN material_refname mnm ON mx.material_refname_uuid = mnm.material_refname_uuid
	JOIN material_refname_type mt on mnm.material_refname_type_uuid = mt.material_refname_type_uuid;
END;
$$ LANGUAGE plpgsql;


/*
Name:					get_material_bydescr_bystatus (p_descr VARCHAR, p_status_array VARCHAR[], p_null_bool BOOLEAN );
Parameters:		p_descr = varchar of string (to be searched in material and material_ref description)
							p_status_array = array of status description (e.g. array['active', 'proto']) 
							where ANY of the status descriptions match
							p_null_bool = true or false to include null status in returned set
Returns:			material_uuid, 
Author:				G. Cattabriga
Date:					2020.4.1
Description:	return material uuid, material description, material_ref uuid, material_ref description based on specific status
Notes:				need to UNION ALL the material descriptions with the returned set from function get_materialid_bystatus ()
							because there may be duplicate names
Example:			SELECT * FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE);
*/
DROP FUNCTION IF EXISTS get_material_bydescr_bystatus (p_descr varchar, p_status_array VARCHAR[], p_null_bool BOOLEAN ) cascade;
CREATE OR REPLACE FUNCTION get_material_bydescr_bystatus (p_descr varchar, p_status_array VARCHAR[], p_null_bool BOOLEAN)
RETURNS TABLE (
      material_uuid uuid,
			material_description varchar,
			material_refname_uuid uuid,
			material_refname_description VARCHAR,
			material_refname_type varchar
) AS $$
BEGIN
	RETURN QUERY SELECT	
		mat.material_uuid,
		mat.material_description as material_description, 
		mnm.material_refname_uuid,
		mnm.description as material_refname_description,
		mt.description as material_refname_type
	FROM get_material_uuid_bystatus ( p_status_array, p_null_bool ) mat
	JOIN material_refname_x mx ON mat.material_uuid = mx.material_uuid 
	JOIN material_refname mnm ON mx.material_refname_uuid = mnm.material_refname_uuid
	JOIN material_refname_type mt on mnm.material_refname_type_uuid = mt.material_refname_type_uuid
	where mat.material_description = p_descr or mnm.description = p_descr;
END;
$$ LANGUAGE plpgsql;


/*
Name:					get_material_type (p_material_uuid uuid)
Parameters:		p_material_uuid uuid of material to retreive material_type(s)
Returns:			array of material_type descriptions
Author:				G. Cattabriga
Date:					2020.04.08
Description:	returns varchar array of material_types associated with a material (uuid)
Notes:				
							
Example:			SELECT * FROM get_material_type ((SELECT material_uuid FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE)));
*/
DROP FUNCTION IF EXISTS get_material_type (p_material_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION get_material_type (p_material_uuid uuid)
RETURNS varchar[] AS $$
BEGIN
	return (
		SELECT array_agg(mt.description) from material mat
		LEFT JOIN material_type_x mtx on mat.material_uuid = mtx.ref_material_uuid
		LEFT JOIN material_type mt on mtx.material_type_uuid = mt.material_type_uuid
		WHERE mat.material_uuid = p_material_uuid); 
END;
$$ LANGUAGE plpgsql;



/*
Name:					get_actor ()
Parameters:		none
Returns:			actor_uuid, org_uuid, person_uuid, systemtool_uuid, actor_description, org_description, person_lastfirst, systemtool_description
Author:				G. Cattabriga
Date:					2019.12.12
Description:	returns key info on the actor
Notes:				the person_lastfirst is a concat of person.last_name + ',' + person.first_name
							
Example:			SELECT * FROM get_actor () where actor_description like '%ChemAxon: standardize%';
*/
DROP FUNCTION IF EXISTS get_actor ();
CREATE OR REPLACE FUNCTION get_actor ()
RETURNS TABLE (
      actor_uuid uuid,
			organization_uuid int8,
			person_uuid int8,
			systemtool_uuid int8,
			actor_description varchar,
			actor_status varchar,
			notetext varchar,
			org_description varchar,
			person_lastfirst varchar,
			systemtool_name varchar,
			systemtool_version varchar
) AS $$
BEGIN
	RETURN QUERY SELECT
		act.actor_uuid, org.organization_uuid, per.person_uuid, st.systemtool_uuid, act.description, stt.description, nt.notetext as actor_notetext,
		org.full_name, 
		case when per.person_uuid is not null then cast(concat(per.lastname,', ',per.firstname) as varchar) end as lastfirst, 
		st.systemtool_name, st.ver
	from actor act 
	left join organization org on act.organization_uuid = org.organization_uuid
	left join person per on act.person_uuid = per.person_uuid
	left join systemtool st on act.systemtool_uuid = st.systemtool_uuid
	left join status stt on act.status_uuid = stt.status_uuid
	left join note nt on act.note_uuid = nt.note_uuid;
END;
$$ LANGUAGE plpgsql;



/*
Name:					get_calculation_def ()
Parameters:		p_descrp = string used in search over description columns: short_name, calc_definition, description
Returns:			calculation_def_uuid, calculation_def_uuid, short_name, calc_definition, description, systemtool_name, systemtool_ver
Author:				G. Cattabriga
Date:					2020.01.16
Description:	returns keys (uuid) of calculation_def matching p_descrp parameters 
Notes:				
							
Example:			SELECT * FROM get_calculation_def (array['standardize']);
*/                                                    
DROP FUNCTION IF EXISTS get_calculation_def (p_descr VARCHAR[]) cascade;
CREATE OR REPLACE FUNCTION get_calculation_def (p_descr VARCHAR[])
RETURNS TABLE (
			calculation_def_uuid uuid,
			short_name varchar,
			systemtool_name varchar,
			calc_definition varchar,
			description varchar,
			in_type val_type,
			out_type val_type,
			systemtool_version varchar
) AS $$
BEGIN
	RETURN QUERY SELECT
		mdd.calculation_def_uuid, mdd.short_name, st.systemtool_name, mdd.calc_definition, mdd.description, mdd.in_type, mdd.out_type, st.ver
	from calculation_def mdd
	join systemtool st on mdd.systemtool_uuid = st.systemtool_uuid
	WHERE mdd.short_name = ANY(p_descr) OR mdd.calc_definition = ANY(p_descr) OR mdd.description = ANY(p_descr); 
END;
$$ LANGUAGE plpgsql;




/*
Name:					get_calculation (p_material_refname varchar, p_descr VARCHAR)
Parameters:		p_material_refname = string of material (e.g. SMILES)
							p_descrp = string used in search over description columns: short_name, calc_definition, description
Returns:			calculation_uuid
Author:				G. Cattabriga
Date:					2020.04.01
Description:	returns uuid of calculation
Notes:				
							
Example:			SELECT * FROM get_calculation ('C1=CC=C(C=C1)CC[NH3+].[I-]', array['standardize']);
							SELECT * FROM get_calculation ('C1CC[NH2+]C1.[I-]', array['standardize']);	
							SELECT * FROM get_calculation ('C1CC[NH2+]C1.[I-]', array['charge_cnt_standardize']);
							SELECT * FROM get_calculation ('CN(C)C=O', array['charge_cnt_standardize']);	
							SELECT * FROM get_calculation ('CN(C)C=O');							
							
*/
DROP FUNCTION IF EXISTS get_calculation (p_material_refname varchar, p_descr VARCHAR[]) cascade;
CREATE OR REPLACE FUNCTION get_calculation (p_material_refname varchar, p_descr VARCHAR[] = null)
RETURNS TABLE (
			calculation_uuid uuid
) AS $$
BEGIN
	RETURN query  
	(
	with RECURSIVE calculation_chain as (
		select cal.calculation_uuid, (cal.in_val).v_source_uuid from calculation cal where (cal.in_val).v_text = p_material_refname
		UNION
		select md2.calculation_uuid, (md2.in_val).v_source_uuid from calculation md2
			inner join calculation_chain dc on dc.calculation_uuid = (md2.in_val).v_source_uuid
		) select md.calculation_uuid from calculation_chain dc 
			join calculation md on dc.calculation_uuid = md.calculation_uuid 
			join calculation_def mdd on md.calculation_def_uuid = mdd.calculation_def_uuid
			where (p_descr is null) or (mdd.short_name = ANY(p_descr) OR mdd.calc_definition = ANY(p_descr) OR mdd.description = ANY(p_descr))
		); 
END;
$$ LANGUAGE plpgsql;


/*
Name:					get_val (p_in val)
Parameters:		p_in = value of composite type 'val'
Returns:			returns the val value
Author:				G. Cattabriga
Date:					2020.04.16
Description:	returns value (as text) from a 'val' type composite 
Notes:				
							
Example:			SELECT get_val ('(text,,"[I-].[NH3+](CCC1=CC=C(C=C1)OC)",,,,,,,)'::val);
							SELECT get_val ('(num,,,,,,266.99,,,)'::val);
							SELECT get_val ('(int,,,,15,,,,,)'::val);			
							SELECT get_val ('(array_int,,,,,"{1,2,3,4,5}",,,,)'::val);	
							SELECT get_val ('(blob_svg,,,,,,,,"0ed27587-a79e-45d4-bb56-2e2e5d85937c",)'::val);				
*/
DROP FUNCTION IF EXISTS get_val (p_in val) cascade;
CREATE OR REPLACE FUNCTION get_val (p_in val)
returns text AS $$
BEGIN
	CASE
		WHEN p_in.v_type = 'int' THEN return (p_in.v_int::text);
		WHEN p_in.v_type = 'array_int' THEN return (p_in.v_int_array::text);
		WHEN p_in.v_type = 'array_int' THEN return (p_in.v_int_array::text);
		WHEN p_in.v_type = 'num' THEN return (p_in.v_num::text);
		WHEN p_in.v_type = 'array_num' THEN return (p_in.v_num_array::text);
		WHEN p_in.v_type = 'text' THEN return (p_in.v_text::text);
		WHEN p_in.v_type = 'array_text' THEN return (p_in.v_text_array::text);	
		WHEN p_in.v_type::text like 'blob%' THEN return (encode((select edocument from edocument where edocument_uuid = p_in.v_edocument_uuid),'escape'));	
		ELSE return (NULL);
	END CASE;	
END;
$$ LANGUAGE plpgsql;



/*
Name:					get_chemaxon_directory ()
Parameters:		p_systemtool_uuid = identifier (id) of the chemaxon [software] tool
							p_actor_uuid = identifier (uuid) of the actor performing the calculation: this references the relevant software directories in order to run the CLI tool
Returns:			directory as TEXT
Author:				G. Cattabriga
Date:					2020.02.18
Description:	returns the directory chemaxon tool is located; uses actor_pref 
Notes:				
							
Example:			select get_chemaxon_directory((select systemtool_uuid from systemtool where systemtool_name = 'standardize'), (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary')); (returns the version for cxcalc for actor GC) 
*/
DROP FUNCTION IF EXISTS get_chemaxon_directory ( p_systemtool_uuid int8, p_actor int8 ) cascade;
CREATE OR REPLACE FUNCTION get_chemaxon_directory ( p_systemtool_uuid uuid, p_actor_uuid uuid ) RETURNS TEXT AS $$ 
DECLARE
	v_descr_name varchar;
	v_descr_dir varchar;
BEGIN
	SELECT st.systemtool_name INTO v_descr_name FROM systemtool st WHERE st.systemtool_uuid = p_systemtool_uuid;
	CASE v_descr_name 
			WHEN 'cxcalc','standardize','molconvert' THEN
				return (SELECT ap.pvalue FROM actor_pref ap WHERE ap.actor_uuid = p_actor_uuid AND ap.pkey = 'MARVINSUITE_DIR');	
			WHEN 'generatemd' THEN
				return (SELECT ap.pvalue FROM actor_pref ap WHERE ap.actor_uuid = p_actor_uuid AND ap.pkey = 'CHEMAXON_DIR');		
	END CASE;
	COMMIT;	
END;
$$ LANGUAGE plpgsql;



/*
Name:					get_chemaxon_version ()
Parameters:		p_systemtool_uuid = identifier (uuid) of the chemaxon [software] tool
							p_actor_uuid = identifier (uuid) of the actor performing the calculation: this references the relevant software directories in order to run the CLI tool
Returns:			version as TEXT
Author:				G. Cattabriga
Date:					2020.02.12
Description:	returns the version for the specified chemaxon tool in string format 
Notes:				
							
Example:			select get_chemaxon_version((select systemtool_uuid from systemtool where systemtool_name = 'generatemd'), (select actor_uuid from actor where description = 'Gary Cattabriga')); (returns the version for cxcalc for actor GC) 
*/
DROP FUNCTION IF EXISTS get_chemaxon_version ( p_systemtool_uuid int8, p_actor_uuid uuid ) cascade;
CREATE OR REPLACE FUNCTION get_chemaxon_version ( p_systemtool_uuid uuid, p_actor_uuid uuid ) RETURNS TEXT AS $$ 
DECLARE
	v_descr_name varchar;
	v_descr_dir varchar;
BEGIN
	DROP TABLE IF EXISTS load_temp;
	CREATE TEMP TABLE load_temp ( help_string VARCHAR ) ON COMMIT DROP ;
	SELECT st.systemtool_name INTO v_descr_name FROM systemtool st WHERE st.systemtool_uuid = p_systemtool_uuid;
	CASE v_descr_name 
			WHEN 'cxcalc','standardize','molconvert' THEN
				SELECT ap.pvalue INTO v_descr_dir FROM actor_pref ap WHERE ap.actor_uuid = p_actor_uuid AND ap.pkey = 'MARVINSUITE_DIR';	
			WHEN 'generatemd' THEN
				SELECT ap.pvalue INTO v_descr_dir FROM actor_pref ap WHERE ap.actor_uuid = p_actor_uuid AND ap.pkey = 'CHEMAXON_DIR';		
	END CASE;
		EXECUTE format ( 'COPY load_temp FROM PROGRAM ''%s%s -h'' ', v_descr_dir, v_descr_name );
		RETURN ( SELECT SUBSTRING ( help_string FROM '[0-9]{1,2}[.][0-9]{1,2}[.][0-9]{1,2}' ) FROM load_temp WHERE SUBSTRING ( help_string FROM '[0-9]{1,2}[.][0-9]{1,2}[.][0-9]{1,2}' ) IS NOT NULL );
	COMMIT;	
END;
$$ LANGUAGE plpgsql;


/*
Name:					run_descriptor_calc ()
Parameters:		p_descriptor_def_uuid = the uuid of the descriptor definition you want executed
							p_alias_name = an alternate name to reference this specific descriptor created. For example, the molweight cxcalc can be run on raw SMILES or standardized SMILES; this is a way to distinguish between the two when outputting
							p_command_opt = any optional commands to be included in the execution. For example '--ignore-error'
							p_actor_uuid = uuid of the actor requesting the run
Returns:			boolean (true if executed normally, false if not
Author:				G. Cattabriga
Date:					2020.03.20
Description:	runs a descriptor calculation on a specified input 
Notes:				This function depends on the calculation_eval table for inputs (of val_type) and storage of output
							It also creates a temp file 'temp_in.txt' in the HOME_DIR
							DROP function run_descriptor (p_descriptor_def_uuid uuid, p_alias_name varchar, p_command_opt varchar, p_actor_uuid uuid);
Example:			-- first truncate then populate the calculation_eval table with the inputs 
							truncate table calculation_eval RESTART IDENTITY;
							insert into calculation_eval(in_val.v_type, in_val.v_text) (select 'text', vw.material_refname_description from vw_material vw  where vw.material_refname_type = 'SMILES');
							SELECT * FROM run_descriptor ((SELECT calculation_def_uuid FROM get_calculation_def (array['standardize'])), '--ignore-error', (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary'));
							
							-- example of using a previous calculated descriptor (standardize) as input; where we take the standardized SMILES from all materials
							truncate table calculation_eval RESTART IDENTITY;
							insert into calculation_eval(in_val.v_type, in_val.v_text) 
								select (md.out_val).v_type, (md.out_val).v_text from calculation md where md.calculation_def_uuid = (select calculation_def_uuid from get_calculation_def(array['standardize']));
							SELECT * FROM run_descriptor ((SELECT calculation_def_uuid FROM get_calculation_def (array['molweight'])), '_raw_standard_molweight', '--ignore-error --do-not-display ih', (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary'));
							
							truncate table calculation_eval RESTART IDENTITY;
							insert into calculation_eval(in_val.v_type, in_val.v_text) 
								(select 'text'::val_type, mat.material_refname_description from vw_material mat where mat.material_refname_type = 'SMILES');
							SELECT * FROM run_descriptor ((SELECT calculation_def_uuid FROM get_calculation_def (array['molweight'])), '_raw_molweight', '--ignore-error --do-not-display ih', (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary'));							
*/
DROP FUNCTION IF EXISTS run_descriptor (p_descriptor_def_uuid uuid, p_alias_name varchar, p_command_opt varchar, p_actor_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION run_descriptor (p_descriptor_def_uuid uuid, p_alias_name varchar, p_command_opt varchar, p_actor_uuid uuid)
RETURNS BOOLEAN AS $$
DECLARE
	v_descr_dir varchar;
	v_descr_command varchar;
	v_descr_param varchar;
	v_descr_ver varchar;
	v_temp_dir varchar;
	v_temp_in varchar := 'temp_in.txt';
	v_calc_out_blobval bytea;
	v_calc_out_blobtype varchar;
	v_calc_out_numarray DOUBLE PRECISION[];
	v_type_out varchar;
BEGIN
	-- assign the calculation out_type so we can properly store the calc results into calculation_eval
	select out_type into v_type_out FROM get_calculation_def (array['standardize']);
	DROP TABLE IF EXISTS load_temp_out;
--	DROP TABLE IF EXISTS calculation_eval;
	CREATE TEMP TABLE load_temp_out(load_id serial8, strout VARCHAR ) on COMMIT DROP;

--	CREATE TABLE calculation_eval(eval_id serial8, in_val val, out_val val, actor_uuid uuid, create_date timestamptz NOT NULL DEFAULT NOW());
	
	-- load the variables with actor preference data; for temp directory and chemaxon directory
	select into v_temp_dir pvalue from actor_pref act where act.actor_uuid = p_actor_uuid and act.pkey = 'HOME_DIR';
	select into v_descr_dir get_chemaxon_directory((select systemtool_uuid from calculation_def mdd where mdd.calculation_def_uuid = p_descriptor_def_uuid), p_actor_uuid);
	select into v_descr_command (select st.systemtool_name from calculation_def mdd join systemtool st on mdd.systemtool_uuid = st.systemtool_uuid where mdd.calculation_def_uuid = p_descriptor_def_uuid);
  select into v_descr_param mdd.calc_definition from calculation_def mdd where mdd.calculation_def_uuid = p_descriptor_def_uuid;

	CASE v_descr_command
	when 'cxcalc', 'standardize', 'generatemd' then 
		-- load the version of the descriptor function that will be run, this will be a future validation
		select into v_descr_ver get_chemaxon_version((select systemtool_uuid from systemtool where systemtool_name = v_descr_command), p_actor_uuid);
		
		-- copy the inputs from m_desriptor_eval into a text file to be read by the command
		-- this is set to work for ONLY single text varchar input
		EXECUTE format ('copy ( select (ev.in_val).v_text from calculation_eval ev) to ''%s%s'' ', v_temp_dir, v_temp_in);  -- '/Users/gcattabriga/tmp/temp_chem.txt';   
		EXECUTE format ('COPY load_temp_out(strout) FROM PROGRAM ''%s%s %s %s %s%s'' ', v_descr_dir, v_descr_command, p_command_opt, v_descr_param, v_temp_dir, v_temp_in);
	else 
		return false;
	end case;
	
	-- update the calculation_eval table with results from commanc execution; found in load_temp_out temp table
	
	update calculation_eval ev set calculation_def_uuid = p_descriptor_def_uuid, 
	out_val.v_type = v_type_out::val_type, 
	out_val.v_text = 
	case v_type_out 
		when 'text' then strout
		else null
	end, 
	out_val.v_num = 
	case v_type_out 
		when 'num' then strout::double precision
		else null
	end, 
	calculation_alias_name = p_alias_name,
	actor_uuid = p_actor_uuid
	from load_temp_out lto where lto.load_id = ev.eval_id;
	
	RETURN TRUE;
COMMIT;
END;
$$ LANGUAGE plpgsql;


/*
Name:					load_mol_images ()
Parameters:		p_systemtool_uuid = identifier (id) of the chemaxon [software] tool
							p_actor_uuid = identifier (uuid) of the actor performing the calculation: this references the relevant software directories in order to run the CLI tool
Returns:			version as TEXT
Author:				G. Cattabriga
Date:					2020.02.12
Description:	returns the version for the specified chemaxon tool in string format 
Notes:				
							
Example:			select load_mol_images((select systemtool_uuid from systemtool where systemtool_name = 'generatemd'), (select actor_uuid from actor where description = 'Gary Cattabriga'));
*/
-- TRUNCATE table load_perov_mol_image cascade;
DROP FUNCTION IF EXISTS load_mol_images ( p_systemtool_uuid int8, p_actor_uuid uuid ) cascade;
CREATE OR REPLACE FUNCTION load_mol_images ( p_systemtool_uuid uuid, p_actor_uuid uuid ) RETURNS bool AS $$ 
DECLARE
	pathname varchar := '/Users/gcattabriga/DRP/demob/cp_inventory_run_20200311/chem_images/';
	fullfilename VARCHAR := null;
	filename VARCHAR := null;
	fcontents varchar := null;
	fullpathname varchar := null;
	underscorepos int;
BEGIN
	FOR fullfilename IN select pg_ls_dir(pathname) order by 1 LOOP
		 IF (fullfilename ~ '^.*\.(svg)$') THEN
				fcontents = read_file(pathname||fullfilename);
				fullpathname = pathname || fullfilename;
				underscorepos = POSITION('_' in fullfilename);
				filename = substring(fullfilename, underscorepos+1, length(fullfilename) - POSITION('.' in reverse(fullfilename))- underscorepos);
				insert into "load_perov_mol_image" values (fullpathname, fullfilename, filename, bytea(fcontents));
		 END IF;
	 END LOOP;
	 RETURN TRUE;
 END; 
$$ LANGUAGE plpgsql;


/*
Name:					load_edocuments (p_actor_uuid uuid)
Parameters:		p_actor_uuid = identifier (uuid) of the actor owning this edocument
Returns:			boolean T or F
Author:				G. Cattabriga
Date:					2020.04.07
Description:	loads edocuments into the load table 
Notes:				
							
Example:			select load_edocuments((select actor_uuid from actor where description = 'Ian Pendleton'));
*/

DROP FUNCTION IF EXISTS load_edocuments (p_actor_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION load_edocuments (p_actor_uuid uuid) RETURNS bool AS $$ 
DECLARE
	pathname varchar := '/Users/gcattabriga/Downloads/GitHub/escalate_wip/';
	filename VARCHAR := null;
	fullfilename VARCHAR := null;
	fullpathname varchar := null;
	fcontents varchar := null;
BEGIN
	FOR fullfilename IN select pg_ls_dir(pathname) order by 1 LOOP
		 IF (fullfilename ~ '^.*\.(pdf)$') THEN
				fcontents = pg_read_binary_file(pathname||fullfilename);
				fullpathname = pathname || fullfilename;
				filename = substring(fullfilename, 1, length(fullfilename) - POSITION('.' in reverse(fullfilename)));
				insert into load_edocument (description, document_type, edocument, actor_uuid) values (filename, 'blob_pdf'::val_type, bytea(fcontents), p_actor_uuid);
		 END IF;
	 END LOOP;
	 RETURN TRUE;
 END; 
$$ LANGUAGE plpgsql;


/*
Name:					get_charge_count (p_mol_smiles varchar) 
Parameters:		p_mol_smiles = SMILES string representing molecule
Returns:			count of '+'s as INT
Author:				G. Cattabriga
Date:					2020.03.13
Description:	returns the count of [+] charges in a SMILES string 
Notes:				if p_mol_smiles is null, will return null (non-count); so you can check for null input
							
Example:			select get_charge_count('C1C[NH+]2CC[NH+]1CC2');
							select get_charge_count(null);
*/
DROP FUNCTION IF EXISTS get_charge_count (p_mol_smiles varchar) cascade;
CREATE OR REPLACE FUNCTION get_charge_count ( p_mol_smiles varchar ) RETURNS int AS $$ 
BEGIN
	IF (p_mol_smiles is not null) THEN
			return (CHAR_LENGTH(p_mol_smiles) - CHAR_LENGTH(REPLACE(p_mol_smiles, '+', '')));
	ELSE 
		RETURN null;
	END IF;
END; 
$$ LANGUAGE plpgsql;



/*
Name:					math_op (p_in_num numeric, p_op text, p_in_opt_num numeric default null) 
Parameters:		p_op = basic math operation ('+', '/', '-', '*'. etc)
							p_in_num, p_in_opt_num = numeric input values
Returns:			results of math operation as NUM
Author:				G. Cattabriga
Date:					2020.03.13
Description:	returns the count of [+] charges in a SMILES string 
Notes:				up to caller to cast into desired num type (e.g. int)
Example:			select math_op(9, '/', 3);
							select math_op(101, '*', 11);
							select math_op(5, '!');
*/
DROP FUNCTION IF EXISTS math_op (p_op text, p_in_num numeric, p_in_opt_num numeric) cascade;
create or replace function math_op (p_in_num numeric, p_op text, p_in_opt_num numeric default null)
returns numeric as $$
declare 
	i numeric;
begin
	CASE
		WHEN p_op in ('/', '*', '+', '-', '%', '^', '!', '|/', '@') THEN 
			execute format('select %s %s %s', p_in_num, p_op, p_in_opt_num) into i;
			return i;
		ELSE return null;
	END CASE;
END;
$$ language plpgsql;

