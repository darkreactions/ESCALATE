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
Example:			SELECT material_id, material_uuid, material_refname FROM get_material_nameref_bystatus (array['active', 'proto'], TRUE) where material_refname_type = 'SMILES' order by 1;
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
		mnm.material_refname_type as material_refname_type
	FROM get_material_uuid_bystatus ( p_status_array, p_null_bool ) mat
	JOIN material_refname_x mx ON mat.material_uuid = mx.material_uuid 
	JOIN material_refname mnm ON mx.material_refname_uuid = mnm.material_refname_uuid;
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
							
Example:			SELECT * FROM get_actor () where person_lastfirst like '%Mansoor%';
*/
/*
DROP FUNCTION get_actor ();
CREATE OR REPLACE FUNCTION get_actor ()
RETURNS TABLE (
      actor_id int8,
			organization_id int8,
			person_id int8,
			systemtool_id int8,
			actor_description varchar,
			org_description varchar,
			person_lastfirst varchar,
			systemtool_name varchar,
			systemtool_version varchar
) AS $$
BEGIN
	RETURN QUERY SELECT
		act.actor_id, org.organization_id, per.person_id, st.systemtool_id, act.description, stt.description as actor_status, nt.notetext as actor.notetext
		org.full_name, 
		case when per.person_id is not null then cast(concat(per.lastname,', ',per.firstname) as varchar) end as lastfirst, 
		st.systemtool_name, st.ver
	from actor act 
	left join organization org on act.organization_id = org.organization_id
	left join person per on act.person_id = per.person_id
	left join systemtool st on act.systemtool_id = st.systemtool_id;
END;
$$ LANGUAGE plpgsql;
*/


/*
Name:					get_m_descriptor_def ()
Parameters:		p_descrp = string used in search over description columns: short_name, calc_definition, description
Returns:			m_descriptor_def_id, m_descriptor_def_uuid, short_name, calc_definition, description, systemtool_name, systemtool_ver
Author:				G. Cattabriga
Date:					2020.01.16
Description:	returns keys (id, uuid) of m_descriptor_def matching p_descrp parameters 
Notes:				
							
Example:			SELECT * FROM get_m_descriptor_def (array['molimage']);
*/
-- DROP FUNCTION get_m_descriptor_def (p_descr VARCHAR[]);
CREATE OR REPLACE FUNCTION get_m_descriptor_def (p_descr VARCHAR[])
RETURNS TABLE (
			m_descriptor_def_uuid uuid,
			short_name varchar,
			calc_definition varchar,
			description varchar,
			systemtool_name varchar,
			systemtool_version varchar
) AS $$
BEGIN
	RETURN QUERY SELECT
		mdd.m_descriptor_def_uuid, mdd.short_name, mdd.calc_definition, mdd.description, st.systemtool_name, st.ver
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
							
Example:			select get_chemaxon_directory((select systemtool_id from systemtool where systemtool_name = 'standardize'), (select actor_uuid from actor where description = 'Gary Cattabriga')); (returns the version for cxcalc for actor GC) 
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
							
Example:			select get_chemaxon_version((select systemtool_id from systemtool where systemtool_name = 'generatemd'), (select actor_id from actor where description = 'Gary Cattabriga')); (returns the version for cxcalc for actor GC) 
*/
-- DROP FUNCTION get_chemaxon_version ( p_systemtool_id int8, p_actor int8 )
CREATE OR REPLACE FUNCTION get_chemaxon_version ( p_systemtool_id int8, p_actor_id int8 ) RETURNS TEXT AS $$ 
DECLARE
	v_descr_name varchar;
	v_descr_dir varchar;
BEGIN
	DROP TABLE IF EXISTS load_temp;
	CREATE TEMP TABLE load_temp ( help_string VARCHAR ) ON COMMIT DROP ;
	SELECT st.systemtool_name INTO v_descr_name FROM systemtool st WHERE st.systemtool_id = p_systemtool_id;
	CASE v_descr_name 
			WHEN 'cxcalc','standardize','molconvert' THEN
				SELECT ap.pvalue INTO v_descr_dir FROM actor_pref ap WHERE ap.actor_id = p_actor_id AND ap.pkey = 'MARVINSUITE_DIR';	
			WHEN 'generatemd' THEN
				SELECT ap.pvalue INTO v_descr_dir FROM actor_pref ap WHERE ap.actor_id = p_actor_id AND ap.pkey = 'CHEMAXON_DIR';		
	END CASE;
		EXECUTE format ( 'COPY load_temp FROM PROGRAM ''%s%s -h'' ', v_descr_dir, v_descr_name );
		RETURN ( SELECT SUBSTRING ( help_string FROM '[0-9]{1,2}[.][0-9]{1,2}[.][0-9]{1,2}' ) FROM load_temp WHERE SUBSTRING ( help_string FROM '[0-9]{1,2}[.][0-9]{1,2}[.][0-9]{1,2}' ) IS NOT NULL );
	COMMIT;	
END;
$$ LANGUAGE plpgsql;


/*
Name:					run_descriptor_calc ()
Parameters:		p_exec_dir = string used to designate the descriptor calculator location directory
							p_descr_def = reference to m_descriptor_def_id that will be used
Returns:			m_descriptor_def_id, m_descriptor_def_uuid, short_name, calc_definition, description
Author:				G. Cattabriga
Date:					2020.01.16
Description:	returns keys (id, uuid) of m_descriptor_def matching p_descrp parameters 
Notes:				
							DROP function run_descriptor_calc();
Example:			SELECT * FROM run_descriptor_calc (cast('69' as bigint), cast('4' as bigint));
*/
CREATE OR REPLACE FUNCTION run_descriptor_calc(p_descriptor_def_id int8, p_actor_id int8)
RETURNS TABLE (
			descr_calc_id int8,
			descr_calc_in varchar,
			descr_calc_out_blobval bytea,	
			descr_calc_out_blobtype varchar,
			descr_calc_out_numarray DOUBLE PRECISION[],	
			m_descriptor_def_id int8,
			ver varchar,
			actor_id int8
) AS $$
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
BEGIN
	DROP TABLE IF EXISTS load_temp_out;
	DROP TABLE IF EXISTS load_temp_in;
	CREATE TEMP TABLE load_temp_out(load_id serial8, strout VARCHAR ) on COMMIT DROP;
	CREATE TEMP TABLE load_temp_in(load_id serial8, strin VARCHAR ) ON COMMIT DROP;
	
	-- load the variables with actor preference data; for temp directory and chemaxon directory
	select into v_temp_dir pvalue from actor_pref act where act.actor_id = p_actor_id and act.pkey = 'HOME_DIR';
	select into v_descr_dir get_chemaxon_directory((select systemtool_id from m_descriptor_def mdd where mdd.m_descriptor_def_id = p_descriptor_def_id), p_actor_id);
	select into v_descr_command (select st.systemtool_name from m_descriptor_def mdd join systemtool st on mdd.systemtool_id = st.systemtool_id where mdd.m_descriptor_def_id = p_descriptor_def_id);
  select into v_descr_param mdd.calc_definition from m_descriptor_def mdd where mdd.m_descriptor_def_id = p_descriptor_def_id;
	
	-- load the version of the descriptor function that will be run 
	select into v_descr_ver get_chemaxon_version((select systemtool_id from systemtool where systemtool_name = 'standardize'), p_actor_id);

	-- insert into load_temp_in(strin) (select mn.smiles from load_version2_smiles mn limit 5000);
	-- insert into load_temp_in(strin) (select vw.material_refname_description from vw_material vw  where vw.material_refname_type = 'SMILES');

	EXECUTE format ('copy ( select strin from load_temp_in) to ''%s%s'' ', v_temp_dir, v_temp_in);  -- '/Users/gcattabriga/tmp/temp_chem.txt';   
	EXECUTE format ('COPY load_temp_out(strout) FROM PROGRAM ''%s%s %s %s%s'' ', v_descr_dir, v_descr_command, v_descr_param, v_temp_dir, v_temp_in);
	lout.strout
	
	
	RETURN QUERY select lin.load_id, lin.strin, 
			case 
			
			, p_descriptor_def_id, v_descr_ver, p_actor_id from load_temp_in lin join load_temp_out lout on lin.load_id = lout.load_id order by 1;
	-- COMMIT;
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
							
Example:			select get_chemaxon_version((select systemtool_id from systemtool where systemtool_name = 'generatemd'), (select actor_uuid from actor where description = 'Gary Cattabriga')); (returns the version for cxcalc for actor GC) 
*/
-- DROP FUNCTION load_mol_images ( p_systemtool_id int8, p_actor_uuid uuid )
CREATE OR REPLACE FUNCTION load_mol_images ( p_systemtool_id int8, p_actor_uuid uuid ) RETURNS TEXT AS $$ 
DECLARE
	pathname varchar := '/Users/gcattabriga/DRP/demob/cp_inventory_run_20191104/svg/';
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
 END; $$
$$ LANGUAGE plpgsql;
