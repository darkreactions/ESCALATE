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
Name:					isdate
Parameters:		str (varchar) that contains string to test
Returns:			TRUE or FALSE
Author:				G. Cattabriga
Date:					2019.07.24
Description:	if str can be cast to a date, then return TRUE, else FALSE
Notes:
*/
-- DROP FUNCTION isdate(txt VARCHAR);
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
Returns:			dataset of material_id's 
Author:				G. Cattabriga
Date:					2019.12.12
Description:	return material id's with specific status
Notes:				
Example:			SELECT * FROM get_material_uuid_bystatus (array['active', 'proto'], TRUE);
*/
DROP FUNCTION get_material_uuid_bystatus (p_status_array VARCHAR[], p_null_bool BOOLEAN);
CREATE OR REPLACE FUNCTION get_material_uuid_bystatus (p_status_array varchar[], p_null_bool boolean)
RETURNS TABLE (
      material_id int8,
			material_uuid uuid
) AS $$
BEGIN
	RETURN QUERY SELECT
			mat.material_id,
			mat.material_uuid
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
Name:					get_materialnameref_bystatus (p_status_arr, p_null_bool)
Parameters:		p_status_array = array of status description (e.g. array['active', 'proto']) 
							where ANY of the status descriptions match
							p_null_bool = true or false to include null status in returned set
Returns:			dataset of material names, including alternative names
Author:				G. Cattabriga
Date:					2019.12.12
Description:	return material id, material name based on specific status
Notes:				need to UNION ALL the material descriptions with the returned set from function get_materialid_bystatus ()
							because there may be duplicate names
Example:			SELECT material_id, material_uuid, material_refname FROM get_material_nameref_bystatus (array['active', 'proto'], TRUE) where material_refname_type = 'InChI' order by 1;
*/
DROP FUNCTION get_material_nameref_bystatus (p_status_array VARCHAR[], p_null_bool BOOLEAN );
CREATE OR REPLACE FUNCTION get_material_nameref_bystatus (p_status_array varchar[], p_null_bool boolean)
RETURNS TABLE (
      material_id int8,	
      material_uuid uuid,
			material_refname varchar,
			material_refname_type varchar
) AS $$
BEGIN
	RETURN QUERY SELECT
		mat.material_id,		
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
Name:					get_actor ()
Parameters:		none
Returns:			actor_id, org_id, person_id, systemtool_id, actor_description, org_description, person_lastfirst, systemtool_description
Author:				G. Cattabriga
Date:					2019.12.12
Description:	returns key info on the actor
Notes:				the person_lastfirst is a concat of person.last_name + ',' + person.first_name
							
Example:			SELECT * FROM get_actor () where actor_description like '%ChemAxon: standardize%';
*/
-- DROP FUNCTION get_actor ();
CREATE OR REPLACE FUNCTION get_actor ()
RETURNS TABLE (
      actor_uuid uuid,
			organization_id int8,
			person_id int8,
			systemtool_id int8,
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
		act.actor_uuid, org.organization_id, per.person_id, st.systemtool_id, act.description, stt.description, nt.notetext as actor_notetext,
		org.full_name, 
		case when per.person_id is not null then cast(concat(per.lastname,', ',per.firstname) as varchar) end as lastfirst, 
		st.systemtool_name, st.ver
	from actor act 
	left join organization org on act.organization_id = org.organization_id
	left join person per on act.person_id = per.person_id
	left join systemtool st on act.systemtool_id = st.systemtool_id
	left join status stt on act.status_uuid = stt.status_uuid
	left join note nt on act.note_uuid = nt.note_uuid;
END;
$$ LANGUAGE plpgsql;



/*
Name:					get_m_descriptor_def ()
Parameters:		p_descrp = string used in search over description columns: short_name, calc_definition, description
Returns:			m_descriptor_def_id, m_descriptor_def_uuid, short_name, calc_definition, description, systemtool_name, systemtool_ver
Author:				G. Cattabriga
Date:					2020.01.16
Description:	returns keys (id, uuid) of m_descriptor_def matching p_descrp parameters 
Notes:				
							
Example:			SELECT * FROM get_m_descriptor_def (array['standardize']);
*/
-- DROP FUNCTION get_m_descriptor_def (p_descr VARCHAR[]);
CREATE OR REPLACE FUNCTION get_m_descriptor_def (p_descr VARCHAR[])
RETURNS TABLE (
			m_descriptor_def_uuid uuid,
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
		mdd.m_descriptor_def_uuid, mdd.short_name, st.systemtool_name, mdd.calc_definition, mdd.description, mdd.in_type, mdd.out_type, st.ver
	from m_descriptor_def mdd
	join systemtool st on mdd.systemtool_id = st.systemtool_id
	WHERE mdd.short_name = ANY(p_descr) OR mdd.calc_definition = ANY(p_descr) OR mdd.description = ANY(p_descr); 
END;
$$ LANGUAGE plpgsql;



/*
Name:					get_chemaxon_directory ()
Parameters:		p_systemtool_id = identifier (id) of the chemaxon [software] tool
							p_actor_id = identifier (id) of the actor performing the calculation: this references the relevant software directories in order to run the CLI tool
Returns:			directory as TEXT
Author:				G. Cattabriga
Date:					2020.02.18
Description:	returns the directory chemaxon tool is located; uses actor_pref 
Notes:				
							
Example:			select get_chemaxon_directory((select systemtool_id from systemtool where systemtool_name = 'standardize'), (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary')); (returns the version for cxcalc for actor GC) 
*/
-- DROP FUNCTION get_chemaxon_directory ( p_systemtool_id int8, p_actor int8 )
CREATE OR REPLACE FUNCTION get_chemaxon_directory ( p_systemtool_id int8, p_actor_uuid uuid ) RETURNS TEXT AS $$ 
DECLARE
	v_descr_name varchar;
	v_descr_dir varchar;
BEGIN
	SELECT st.systemtool_name INTO v_descr_name FROM systemtool st WHERE st.systemtool_id = p_systemtool_id;
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
Parameters:		p_systemtool_id = identifier (id) of the chemaxon [software] tool
							p_actor_id = identifier (id) of the actor performing the calculation: this references the relevant software directories in order to run the CLI tool
Returns:			version as TEXT
Author:				G. Cattabriga
Date:					2020.02.12
Description:	returns the version for the specified chemaxon tool in string format 
Notes:				
							
Example:			select get_chemaxon_version((select systemtool_id from systemtool where systemtool_name = 'generatemd'), (select actor_uuid from actor where description = 'Gary Cattabriga')); (returns the version for cxcalc for actor GC) 
*/
-- DROP FUNCTION get_chemaxon_version ( p_systemtool_id int8, p_actor_uuid uuid )
CREATE OR REPLACE FUNCTION get_chemaxon_version ( p_systemtool_id int8, p_actor_uuid uuid ) RETURNS TEXT AS $$ 
DECLARE
	v_descr_name varchar;
	v_descr_dir varchar;
BEGIN
	DROP TABLE IF EXISTS load_temp;
	CREATE TEMP TABLE load_temp ( help_string VARCHAR ) ON COMMIT DROP ;
	SELECT st.systemtool_name INTO v_descr_name FROM systemtool st WHERE st.systemtool_id = p_systemtool_id;
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
Notes:				This function depends on the m_descriptor_eval table for inputs (of val_type) and storage of output
							It also creates a temp file 'temp_in.txt' in the HOME_DIR
							DROP function run_descriptor (p_descriptor_def_uuid uuid, p_alias_name varchar, p_command_opt varchar, p_actor_uuid uuid);
Example:			-- first truncate then populate the m_descriptor_eval table with the inputs 
							truncate table m_descriptor_eval RESTART IDENTITY;
							insert into m_descriptor_eval(in_val.v_type, in_val.v_text) (select 'text', vw.material_refname_description from vw_material vw  where vw.material_refname_type = 'SMILES');
							SELECT * FROM run_descriptor ((SELECT m_descriptor_def_uuid FROM get_m_descriptor_def (array['standardize'])), '--ignore-error', (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary'));
							
							-- example of using a previous calculated descriptor (standardize) as input; where we take the standardized SMILES from all materials
							truncate table m_descriptor_eval RESTART IDENTITY;
							insert into m_descriptor_eval(in_val.v_type, in_val.v_text) 
								select (md.out_val).v_type, (md.out_val).v_text from m_descriptor md where md.m_descriptor_def_uuid = (select m_descriptor_def_uuid from get_m_descriptor_def(array['standardize']));
							SELECT * FROM run_descriptor ((SELECT m_descriptor_def_uuid FROM get_m_descriptor_def (array['molweight'])), '_raw_standard_molweight', '--ignore-error --do-not-display ih', (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary'));
							
							truncate table m_descriptor_eval RESTART IDENTITY;
							insert into m_descriptor_eval(in_val.v_type, in_val.v_text) 
								(select 'text'::val_type, mat.material_refname_description from vw_material mat where mat.material_refname_type = 'SMILES');
							SELECT * FROM run_descriptor ((SELECT m_descriptor_def_uuid FROM get_m_descriptor_def (array['molweight'])), '_raw_molweight', '--ignore-error --do-not-display ih', (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary'));							
*/
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
	-- assign the m_descriptor out_type so we can properly store the calc results into m_descriptor_eval
	select out_type into v_type_out FROM get_m_descriptor_def (array['standardize']);
	DROP TABLE IF EXISTS load_temp_out;
--	DROP TABLE IF EXISTS m_descriptor_eval;
	CREATE TEMP TABLE load_temp_out(load_id serial8, strout VARCHAR ) on COMMIT DROP;

--	CREATE TABLE m_descriptor_eval(eval_id serial8, in_val val, out_val val, actor_uuid uuid, create_date timestamptz NOT NULL DEFAULT NOW());
	
	-- load the variables with actor preference data; for temp directory and chemaxon directory
	select into v_temp_dir pvalue from actor_pref act where act.actor_uuid = p_actor_uuid and act.pkey = 'HOME_DIR';
	select into v_descr_dir get_chemaxon_directory((select systemtool_id from m_descriptor_def mdd where mdd.m_descriptor_def_uuid = p_descriptor_def_uuid), p_actor_uuid);
	select into v_descr_command (select st.systemtool_name from m_descriptor_def mdd join systemtool st on mdd.systemtool_id = st.systemtool_id where mdd.m_descriptor_def_uuid = p_descriptor_def_uuid);
  select into v_descr_param mdd.calc_definition from m_descriptor_def mdd where mdd.m_descriptor_def_uuid = p_descriptor_def_uuid;

	CASE v_descr_command
	when 'cxcalc', 'standardize', 'generatemd' then 
		-- load the version of the descriptor function that will be run, this will be a future validation
		select into v_descr_ver get_chemaxon_version((select systemtool_id from systemtool where systemtool_name = v_descr_command), p_actor_uuid);
		
		-- copy the inputs from m_desriptor_eval into a text file to be read by the command
		-- this is set to work for ONLY single text varchar input
		EXECUTE format ('copy ( select (ev.in_val).v_text from m_descriptor_eval ev) to ''%s%s'' ', v_temp_dir, v_temp_in);  -- '/Users/gcattabriga/tmp/temp_chem.txt';   
		EXECUTE format ('COPY load_temp_out(strout) FROM PROGRAM ''%s%s %s %s %s%s'' ', v_descr_dir, v_descr_command, p_command_opt, v_descr_param, v_temp_dir, v_temp_in);
	else 
		return false;
	end case;
	
	-- update the m_descriptor_eval table with results from commanc execution; found in load_temp_out temp table
	
	update m_descriptor_eval ev set m_descriptor_def_uuid = p_descriptor_def_uuid, 
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
	m_descriptor_alias_name = p_alias_name,
	actor_uuid = p_actor_uuid
	from load_temp_out lto where lto.load_id = ev.eval_id;
	
	RETURN TRUE;
COMMIT;
END;
$$ LANGUAGE plpgsql;


/*
Name:					load_mol_images ()
Parameters:		p_systemtool_id = identifier (id) of the chemaxon [software] tool
							p_actor_uuid = identifier (uuid) of the actor performing the calculation: this references the relevant software directories in order to run the CLI tool
Returns:			version as TEXT
Author:				G. Cattabriga
Date:					2020.02.12
Description:	returns the version for the specified chemaxon tool in string format 
Notes:				
							
Example:			select load_mol_images((select systemtool_id from systemtool where systemtool_name = 'generatemd'), (select actor_uuid from actor where description = 'Gary Cattabriga'));
*/
-- TRUNCATE table load_perov_mol_image cascade;
-- DROP FUNCTION load_mol_images ( p_systemtool_id int8, p_actor_uuid uuid )
CREATE OR REPLACE FUNCTION load_mol_images ( p_systemtool_id int8, p_actor_uuid uuid ) RETURNS bool AS $$ 
DECLARE
	pathname varchar := '/Users/gcattabriga/DRP/demob/cp_inventory_run_20200311/svg/';
	filename VARCHAR := null;
	fcontents varchar := null;
	fullpathname varchar := null;
	fileno int := 0;
BEGIN
	FOR filename IN select pg_ls_dir(pathname) order by 1 LOOP
		 IF (filename ~ '^.*\.(svg)$') THEN
				fcontents = read_file_utf8(pathname||filename);
				fullpathname = pathname || filename;
				fileno = cast(substring(filename, length('out')+1, length(filename) - POSITION('.' in reverse(filename)) - length('out')) as integer);
				insert into "load_perov_mol_image" values (fullpathname, fileno, bytea(fcontents));
		 END IF;
	 END LOOP;
	 RETURN TRUE;
 END; 
$$ LANGUAGE plpgsql;
