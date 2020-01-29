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
Example:			SELECT * FROM get_materialid_bystatus (array['active', 'proto'], TRUE);
*/
DROP FUNCTION get_materialid_bystatus (p_status_array VARCHAR[], p_null_bool BOOLEAN);
CREATE OR REPLACE FUNCTION get_materialid_bystatus (p_status_array varchar[], p_null_bool boolean)
RETURNS TABLE (
      material_id INT8
) AS $$
BEGIN
	RETURN QUERY SELECT
			mat.material_id
		FROM
			material mat
			LEFT JOIN status st ON mat.status_id = st.status_id
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
Example:			SELECT * FROM get_materialnameref_bystatus (array['active', 'proto'], TRUE);
*/
DROP FUNCTION get_materialnameref_bystatus (p_status_array VARCHAR[], p_null_bool BOOLEAN );
CREATE OR REPLACE FUNCTION get_materialnameref_bystatus (p_status_array varchar[], p_null_bool boolean)
RETURNS TABLE (
      material_id int8,
			material_refname varchar,
			material_refname_type varchar
) AS $$
BEGIN
	RETURN QUERY SELECT
		mat.material_id,
		mnm.description AS mname,
		mnm.material_refname_type as material_refname_type
	FROM get_materialid_bystatus ( p_status_array, p_null_bool ) mat
	JOIN material_refname_x mx ON mat.material_id = mx.material_id 
	JOIN material_refname mnm ON mx.material_refname_id = mnm.material_refname_id;
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
Name:					get_descriptor_def ()
Parameters:		p_descrp = string used in search over description columns: short_name, calc_definition, description
Returns:			m_descriptor_def_id, m_descriptor_def_uuid, short_name, calc_definition, description
Author:				G. Cattabriga
Date:					2020.01.16
Description:	returns keys (id, uuid) of m_descriptor_def matching p_descrp parameters 
Notes:				
							
Example:			SELECT * FROM get_descriptor_def (array['molconvert']);
*/
DROP FUNCTION get_m_descriptor_def (p_descr VARCHAR[]);
CREATE OR REPLACE FUNCTION get_m_descriptor_def (p_descr VARCHAR[])
RETURNS TABLE (
			m_descriptor_def_id int8,
			m_descriptor_def_uuid uuid,
			short_name varchar,
			calc_definition varchar,
			description varchar
) AS $$
BEGIN
	RETURN QUERY SELECT
		mdd.m_descriptor_def_id, mdd.m_descriptor_def_uuid, mdd.short_name, mdd.calc_definition, mdd.description
	from m_descriptor_def mdd
	WHERE mdd.short_name = ANY(p_descr) OR mdd.calc_definition = ANY(p_descr) OR mdd.description = ANY(p_descr); 
END;
$$ LANGUAGE plpgsql;
