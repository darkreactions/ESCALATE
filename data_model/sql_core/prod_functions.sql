--======================================================================
/*
Name:			prod_functions
Parameters:		none
Returns:		NA
Author:			G. Cattabriga
Date:			2019.12.02
Description:	contain the core functions used in ESCALATE sql
Notes:				
*/
--======================================================================


---------------------------------------
-- Make sure postgres extensions are 
-- installed
---------------------------------------
-- SET CLIENT_ENCODING=latin1;
-- CREATE EXTENSION IF NOT EXISTS tablefunc SCHEMA prod;
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp" SCHEMA prod;

/*
Name:			trigger_set_timestamp
Parameters:		none
Returns:		'new' (now) timestamp
Author:			G. Cattabriga
Date:			2019.12.02
Description:	update the mod_dt (modify date) column with current date with timezone
Notes:			this creates both the function and the trigger (for all tables with mod_dt)
*/
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
	NEW.mod_date = NOW();
	RETURN NEW;
END;
$$
LANGUAGE plpgsql;

/*
Name:			get_column_count(_table varchar)
Parameters:		none
Returns:		table of column and non-null counts
Author:			G. Cattabriga
Date:			2019.01.01
Description:	counts the number of occurrences (non-null) in each row of _table
Notes:
Example:		select c.t_column_name as col_name, c.t_count as count from get_column_count( 'load_v2_bromides') c;

*/
CREATE OR REPLACE FUNCTION get_column_count (_table varchar)
	RETURNS TABLE (
		t_column_name text, t_count int8)
	LANGUAGE plpgsql
	AS $BODY$
DECLARE
	_tabname varchar := $1;
	_sql_statement text;
BEGIN
	SELECT
		STRING_AGG('SELECT ''' || column_name || ''',' || ' count("' || column_name || '")  FROM ' || table_name, ' UNION ALL ') INTO _sql_statement
	FROM
		information_schema.columns
	WHERE
		table_name = _tabname;
	IF _sql_statement IS NOT NULL THEN
		RETURN QUERY EXECUTE _sql_statement;
	END IF;
END
$BODY$;


---------------------------------------
-- set_timestamp trigger
---------------------------------------
-- drop trigger_set_timestamp triggers
DO $$
DECLARE
	_t text;
BEGIN
	FOR _t IN
	SELECT
		table_name
	FROM
		information_schema.columns
	WHERE
		column_name = 'mod_date'
		AND table_schema = 'dev' LOOP
			EXECUTE format('DROP TRIGGER IF EXISTS set_timestamp ON %I', _t);
		END LOOP;
END;
$$
LANGUAGE plpgsql;

-- create trigger_set_timestamp triggers
DO $$
DECLARE
	_t text;
BEGIN
	FOR _t IN
	SELECT
		table_name
	FROM
		information_schema.columns
	WHERE
		column_name = 'mod_date'
		AND table_schema = 'dev' LOOP
			EXECUTE format('CREATE TRIGGER set_timestamp
                         BEFORE UPDATE ON %I
                         FOR EACH ROW EXECUTE PROCEDURE trigger_set_timestamp()', _t);
		END LOOP;
END;
$$
LANGUAGE plpgsql;


/*
Name:			if_modified()
Parameters:		none
Returns:		'new' if update or insert, 'old' if delete
Author:			G. Cattabriga
Date:			2020.05.12
Description:	Track changes to a table at the statement and/or row level.
Notes:			Optional parameters to trigger in CREATE TRIGGER call:
					param 0: boolean, whether to log the query text. Default 't'.
					param 1: text[], columns to ignore in updates. Default [].
					Updates to ignored cols are omitted from changed_fields.

					Updates with only ignored cols changed are not inserted
					into the audit log.

					Almost all the processing work is still done for updates
					that ignored. If you need to save the load, you need to use
					WHEN clause on the trigger instead.

					No warning or error is issued if ignored_cols contains columns
					that do not exist in the target table. This lets you specify
					a standard set of ignored columns.
*/
CREATE OR REPLACE FUNCTION if_modified_func ()
	RETURNS TRIGGER
	AS $body$
DECLARE
	_audit_row sys_audit;
	_excluded_cols text [] = ARRAY []::text [];
BEGIN
	IF TG_WHEN <> 'AFTER' THEN
		RAISE EXCEPTION 'if_modified_func() may only run as an AFTER trigger';
	END IF;
	_audit_row = ROW (nextval('sys_audit_event_id_seq'), -- event_id
		TG_TABLE_SCHEMA::text, -- schema_name
		TG_TABLE_NAME::text, -- table_name
		TG_RELID, -- relation OID for much quicker searches
		session_user::text, -- session_user_name
		CURRENT_TIMESTAMP, -- action_tstamp_tx
		statement_timestamp(), -- action_tstamp_stm
		clock_timestamp(), -- action_tstamp_clk
		txid_current(), -- transaction ID
		current_setting('application_name'), -- client application
		inet_client_addr(), -- client_addr
		inet_client_port(), -- client_port
		current_query(), -- top-level query or queries (if multistatement) from client
		substring(TG_OP, 1, 1), -- action
		NULL,
		NULL, -- row_data, changed_fields
		'f' -- statement_only
);
	IF NOT TG_ARGV [0]::boolean IS DISTINCT FROM 'f'::boolean THEN
		_audit_row.client_query = NULL;
	END IF;
	IF TG_ARGV [1] IS NOT NULL THEN
		_excluded_cols = TG_ARGV [1]::text [];
	END IF;
	IF(TG_OP = 'UPDATE' AND TG_LEVEL = 'ROW') THEN
		_audit_row.row_data = hstore (OLD.*) - _excluded_cols;
		_audit_row.changed_fields = (hstore (NEW.*) - _audit_row.row_data) - _excluded_cols;
		IF _audit_row.changed_fields = hstore ('') THEN
			-- All changed fields are ignored. Skip this update.
			RETURN NULL;
		END IF;
	ELSIF (TG_OP = 'DELETE'
			AND TG_LEVEL = 'ROW') THEN
		_audit_row.row_data = hstore (OLD.*) - _excluded_cols;
	ELSIF (TG_OP = 'INSERT'
			AND TG_LEVEL = 'ROW') THEN
		_audit_row.row_data = hstore (NEW.*) - _excluded_cols;
	ELSIF (TG_LEVEL = 'STATEMENT'
			AND TG_OP IN('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')) THEN
		_audit_row.statement_only = 't';
	ELSE
		RAISE EXCEPTION '[if_modified_func] - Trigger func added as trigger for unhandled case: %, %', TG_OP, TG_LEVEL;
	END IF;
	INSERT INTO sys_audit
		VALUES(_audit_row.*);
	RETURN NULL;
END;
$body$
LANGUAGE plpgsql;


/*
Name:			audit_table(target_table regclass, audit_rows boolean, audit_query_text boolean, ignored_cols text[])
Parameters:		target_table:     Table name, schema qualified if not on search_path
				audit_rows:       Record each row change, or only audit at a statement level
				audit_query_text: Record the text of the client query that triggered the audit event?
				ignored_cols:     Columns to exclude from update diffs, ignore updates that change only ignored cols.
Returns:		void
Author:			G. Cattabriga
Date:			2020.05.12
Description:	Add auditing support to a table.
Notes:	
Example:		to initiate auditing:   SELECT audit_table('person');
										SELECT audit_table('organization');
				to cancel auditing:		DROP TRIGGER audit_trigger_row ON person;
										DROP TRIGGER audit_trigger_stm ON person;
*/
CREATE OR REPLACE FUNCTION audit_table (target_table regclass, audit_rows boolean, audit_query_text boolean, ignored_cols text [])
	RETURNS void
	AS $body$
DECLARE
	_stm_targets text = 'INSERT OR UPDATE OR DELETE OR TRUNCATE';
	_q_txt text;
	_ignored_cols_snip text = '';
BEGIN
	EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_row ON ' || target_table;
	EXECUTE 'DROP TRIGGER IF EXISTS audit_trigger_stm ON ' || target_table;
	IF audit_rows THEN
		IF array_length(ignored_cols, 1) > 0 THEN
			_ignored_cols_snip = ', ' || quote_literal(ignored_cols);
		END IF;
		_q_txt = 'CREATE TRIGGER audit_trigger_row AFTER INSERT OR UPDATE OR DELETE ON ' || target_table || ' FOR EACH ROW EXECUTE PROCEDURE if_modified_func(' || quote_literal(audit_query_text) || _ignored_cols_snip || ');';
		RAISE NOTICE '%', _q_txt;
		EXECUTE _q_txt;
		_stm_targets = 'TRUNCATE';
	ELSE
	END IF;
	_q_txt = 'CREATE TRIGGER audit_trigger_stm AFTER ' || _stm_targets || ' ON ' || target_table || ' FOR EACH STATEMENT EXECUTE PROCEDURE if_modified_func(' || quote_literal(audit_query_text) || ');';
	RAISE NOTICE '%', _q_txt;
	EXECUTE _q_txt;
END;
$body$
LANGUAGE 'plpgsql';

CREATE OR REPLACE FUNCTION audit_table (target_table regclass, audit_rows boolean, audit_query_text boolean)
	RETURNS void
	AS $body$
	SELECT
		audit_table ($1,
			$2,
			$3,
			ARRAY []::text []);
$body$
LANGUAGE SQL;

CREATE OR REPLACE FUNCTION audit_table (target_table regclass)
	RETURNS void
	AS $body$
	SELECT
		audit_table ($1,
			BOOLEAN 't',
			BOOLEAN 't');
$body$
LANGUAGE 'sql';

-----------------------------
-- turn on auditing
-----------------------------
-- SELECT audit_table('person');
-- SELECT audit_table('organization');
-- SELECT audit_table('systemtool');
-- SELECT audit_table('systemtool_type');
-- SELECT audit_table('actor');
-- SELECT audit_table('actor_pref');
-- SELECT audit_table('edocument');
-- SELECT audit_table('edocument_x');
-- SELECT audit_table('bom');
-- SELECT audit_table('experiment');
-- SELECT audit_table('experiment_workflow');
-- SELECT audit_table('material');
-- SELECT audit_table('material_x');
-- SELECT audit_table('material_type');
-- SELECT audit_table('material_type_x');
-- SELECT audit_table('material_refname');
-- SELECT audit_table('material_refname_x');
-- SELECT audit_table('material_refname_def');
-- SELECT audit_table('outcome');
-- SELECT audit_table('outcome_type');
-- SELECT audit_table('outcome_x');
-- SELECT audit_table('property');
-- SELECT audit_table('property_def');
-- SELECT audit_table('property_x');
-- SELECT audit_table('calculation_class');
-- SELECT audit_table('calculation_def');
-- SELECT audit_table('calculation');
-- SELECT audit_table('calculation_eval');
-- SELECT audit_table('inventory');
-- SELECT audit_table('inventory_material');
-- SELECT audit_table('measure');
-- SELECT audit_table('measure_x');
-- SELECT audit_table('measure_type');
-- SELECT audit_table('note_x');
-- SELECT audit_table('note');
-- SELECT audit_table('tag_type');
-- SELECT audit_table('tag_x');
-- SELECT audit_table('tag');
-- SELECT audit_table('type_def');
-- SELECT audit_table('udf_def');
-- SELECT audit_table('udf');
-- SELECT audit_table('workflow');
-- SELECT audit_table('workflow_step');
-- SELECT audit_table('workflow_state_def');
-- SELECT audit_table('workflow_state');
-- SELECT audit_table('workflow_action_def');
-- SELECT audit_table('workflow_action');
-- SELECT audit_table('workflow_action_condition');


/*
Name:			read_file_utf8
Parameters:		path (varchar)
Returns:		string (text) of the file
Author:			G. Cattabriga
Date:			2019.07.24
Description:	read the contents of a text file, stripping out carriage returns, line feeds 
 and following spaces
Notes:			used primarily with json files that have CR, LF and needless spaces
 */
CREATE OR REPLACE FUNCTION read_file_utf8 (path CHARACTER VARYING)
	RETURNS TEXT
	AS $$
DECLARE
	_file_oid OID;
	_record RECORD;
	_result BYTEA := '';
	_resultt TEXT;
BEGIN
	SELECT
		lo_import(path) INTO _file_oid;
	FOR _record IN(
		SELECT
			data FROM pg_largeobject
		WHERE
			loid = _file_oid
		ORDER BY
			pageno)
	LOOP
		_result = _result || _record.data;
	END LOOP;
	PERFORM
		lo_unlink(_file_oid);
	_resultt = regexp_replace(convert_from(_result, 'utf8'), E'[\\n\\r] +', '', 'g');
	RETURN _resultt;
END;
$$
LANGUAGE plpgsql;


/*
Name:			read_file
Parameters:		path (varchar)
Returns:		string (text) of the file
Author:			G. Cattabriga
Date:			2019.07.24
Description:	read the contents of a text file, retains all chars, including the control chars
Notes:			used for any non-json text file
*/
CREATE OR REPLACE FUNCTION read_file (path CHARACTER VARYING)
	RETURNS TEXT
	AS $$
DECLARE
	_file_oid OID;
	_record RECORD;
	_result BYTEA := '';
BEGIN
	SELECT
		lo_import(path) INTO _file_oid;
	FOR _record IN(
		SELECT
			data FROM pg_largeobject
		WHERE
			loid = _file_oid
		ORDER BY
			pageno)
	LOOP
		_result = _result || _record.data;
	END LOOP;
	PERFORM
		lo_unlink(_file_oid);
	RETURN _result;
END;
$$
LANGUAGE plpgsql;


/*
Name:			isdate
Parameters:		str (varchar) that contains string to test
Returns:		TRUE or FALSE
Author:			G. Cattabriga
Date:			2019.07.24
Description:	if str can be cast to a date, then return TRUE, else FALSE
Notes:
*/
-- DROP FUNCTION IF EXISTS isdate (txt VARCHAR) CASCADE;
CREATE OR REPLACE FUNCTION isdate (txt VARCHAR)
	RETURNS BOOLEAN
	AS $$
BEGIN
	PERFORM
		txt::DATE;
	RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
	RETURN FALSE;
END;
$$
LANGUAGE plpgsql;


/*
Name:			read_dirfiles
Parameters:		path (varchar) that contains directory path string
Returns:		TRUE or FALSE
Author:			G. Cattabriga
Date:			2019.07.31
Description:	creates load_FILES table populated with all file[names] starting with the 
						[path] directory and all subdirectory
						The filenames have full path including file extension
Notes:			Not much in the way of validation; only checks to see if there is a non-null
						'path' string in the function parameter, which will return FALSE
						Any other error (exception) will return FALSE
*/
CREATE OR REPLACE FUNCTION read_dirfiles (PATH CHARACTER VARYING)
	RETURNS BOOLEAN
	AS $$
BEGIN
	IF(PATH = '') THEN
		RETURN FALSE;
	ELSE
		DROP TABLE IF EXISTS load_dirFILES;
		CREATE TABLE load_dirFILES (
			filename TEXT
		);
		EXECUTE format('COPY load_dirFILES FROM PROGRAM ''find %s -maxdepth 10 -type f'' ', PATH);
		RETURN TRUE;
	END IF;
EXCEPTION
WHEN OTHERS THEN
	RETURN FALSE;
END
$$
LANGUAGE plpgsql;



/*
Name:			parse_filename
Parameters:		none
Returns:		TRUE or FALSE
Author:			G. Cattabriga
Date:			2019.07.31
Description:	creates load_FILES table populated with all file[names] starting with the 
						[path] directory and all subdirectory
						The filenames have full path including file extension
Notes:			Not much in the way of validation; only checks to see if there is a non-null
						'path' string in the function parameter, which will return FALSE
						Any other error (exception) will return FALSE
*/

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
Name:			get_table_uuids()
Parameters:		none
Returns:		table of key column uuids and table name
Author:			G. Cattabriga
Date:			2020.07.06
Description:	returns a table of all primary key UUIDs and their respective TABLE NAME
Notes:			presumes schema = 'dev' and primary key is named *_uuid

Example:		select * from get_table_uuids();
*/
-- DROP FUNCTION get_table_uuids();
CREATE OR REPLACE FUNCTION get_table_uuids ()
	RETURNS TABLE (
		ref_uuid uuid, entity text)
	AS $$
DECLARE
	_rec record;
BEGIN
	FOR _rec IN
	SELECT
		kcu.table_schema,
		kcu.table_name,
		tco.constraint_name,
		kcu.column_name AS key_column
	FROM
		information_schema.table_constraints tco
		JOIN information_schema.key_column_usage kcu ON kcu.constraint_name = tco.constraint_name
			AND kcu.constraint_schema = tco.constraint_schema
			AND kcu.constraint_name = tco.constraint_name
	WHERE
		tco.constraint_type = 'PRIMARY KEY'
		AND kcu.table_schema = 'dev'
		and(kcu.column_name LIKE '%_uuid%')
	ORDER BY
		kcu.table_schema,
		kcu.table_name LOOP
			RETURN QUERY EXECUTE format('SELECT %I as ref_uuid, %L as entity FROM %I', _rec.key_column, _rec.table_name, _rec.table_name);
		END LOOP;
END;
$$
LANGUAGE plpgsql;



/*
Name:			get_materialid_bystatus (p_status_arr, p_null_bool)
Parameters:		p_status_array = array of status description (e.g. array['active', 'proto']) 
--					where ANY of the status descriptions match
--				p_null_bool = true or false to include null status in returned set
Returns:		dataset of material_uuid's 
Author:			G. Cattabriga
Date:			2019.12.12
Description:	return material id's with specific status
Notes:				
Example:		SELECT * FROM get_material_uuid_bystatus (array['active', 'proto'], TRUE);
*/
-- DROP FUNCTION IF EXISTS get_material_uuid_bystatus (p_status_array VARCHAR [], p_null_bool BOOLEAN) CASCADE;
CREATE OR REPLACE FUNCTION get_material_uuid_bystatus (p_status_array varchar [], p_null_bool boolean)
	RETURNS TABLE (
		material_uuid uuid, material_description varchar)
	AS $$
BEGIN
	RETURN QUERY
	SELECT
		mat.material_uuid,
		mat.description
	FROM
		material mat
	LEFT JOIN status st ON mat.status_uuid = st.status_uuid
WHERE
	CASE WHEN p_null_bool THEN
		st.description = ANY (p_status_array)
		OR st.description IS NULL
	ELSE
		st.description = ANY (p_status_array)
	END;
END;
$$
LANGUAGE plpgsql;


/*
Name:			get_material_nameref_bystatus (p_status_arr, p_null_bool)
Parameters:		p_status_array = array of status description (e.g. array['active', 'proto']) 
					where ANY of the status descriptions match
					p_null_bool = true or false to include null status in returned set
Returns:			dataset of material names, including alternative names
Author:			G. Cattabriga
Date:			2019.12.12
Description:	return material id, material name based on specific status
Notes:			need to UNION ALL the material descriptions with the returned set from function get_materialid_bystatus ()
						because there may be duplicate names
Example:		SELECT * FROM get_material_nameref_bystatus (array['active', 'proto'], TRUE) where material_refname_def = 'InChI' order by 1;
*/
-- DROP FUNCTION IF EXISTS get_material_nameref_bystatus (p_status_array VARCHAR[], p_null_bool BOOLEAN ) cascade;
CREATE OR REPLACE FUNCTION get_material_nameref_bystatus (p_status_array varchar [], p_null_bool boolean)
	RETURNS TABLE (
		material_uuid uuid, material_refname varchar, material_refname_def varchar)
	AS $$
BEGIN
	RETURN QUERY
	SELECT
		mat.material_uuid,
		mnm.description AS mname,
		mt.description AS material_refname_def
	FROM
		get_material_uuid_bystatus (p_status_array,
			p_null_bool) mat
		JOIN material_refname_x mx ON mat.material_uuid = mx.material_uuid
		JOIN material_refname mnm ON mx.material_refname_uuid = mnm.material_refname_uuid
		JOIN material_refname_def mt ON mnm.material_refname_def_uuid = mt.material_refname_def_uuid;
END;
$$
LANGUAGE plpgsql;


/*
Name:			get_material_bydescr_bystatus (p_descr VARCHAR, p_status_array VARCHAR[], p_null_bool BOOLEAN );
Parameters:		p_descr = varchar of string (to be searched in material and material_ref description)
				p_status_array = array of status description (e.g. array['active', 'proto']) 
					where ANY of the status descriptions match
				p_null_bool = true or false to include null status in returned set
Returns:		material_uuid, 
Author:			G. Cattabriga
Date:			2020.4.1
Description:	return material uuid, material description, material_ref uuid, material_ref description based on specific status
Notes:				need to UNION ALL the material descriptions with the returned set from function get_materialid_bystatus ()
							because there may be duplicate names
Example:		SELECT * FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE);
*/
-- DROP FUNCTION IF EXISTS get_material_bydescr_bystatus (p_descr varchar, p_status_array VARCHAR[], p_null_bool BOOLEAN ) cascade;
CREATE OR REPLACE FUNCTION get_material_bydescr_bystatus (p_descr varchar, p_status_array VARCHAR [], p_null_bool BOOLEAN)
	RETURNS TABLE (
		material_uuid uuid, material_description varchar, material_refname_uuid uuid, material_refname_description VARCHAR, material_refname_def varchar)
	AS $$
BEGIN
	RETURN QUERY
	SELECT
		mat.material_uuid,
		mat.material_description AS material_description,
		mnm.material_refname_uuid,
		mnm.description AS material_refname_description,
		mt.description AS material_refname_def
	FROM
		get_material_uuid_bystatus (p_status_array,
			p_null_bool) mat
		JOIN material_refname_x mx ON mat.material_uuid = mx.material_uuid
		JOIN material_refname mnm ON mx.material_refname_uuid = mnm.material_refname_uuid
		JOIN material_refname_def mt ON mnm.material_refname_def_uuid = mt.material_refname_def_uuid
	WHERE
		mat.material_description = p_descr
		OR mnm.description = p_descr;
END;
$$
LANGUAGE plpgsql;


/*
Name:			get_material_type (p_material_uuid uuid)
Parameters:		p_material_uuid uuid of material to retrieve material_type(s)
Returns:		array of material_type descriptions
Author:			G. Cattabriga
Date:			2020.04.08
Description:	returns varchar array of material_types associated with a material (uuid)
Notes:				
							
Example:		SELECT * FROM get_material_type ((SELECT material_uuid FROM get_material_bydescr_bystatus ('CC(C)(C)[NH3+].[I-]', array['active'], TRUE)));
*/
-- DROP FUNCTION IF EXISTS get_material_type (p_material_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION get_material_type (p_material_uuid uuid)
	RETURNS varchar []
	AS $$
BEGIN
	RETURN (
		SELECT
			array_agg(mt.description)
		FROM
			material mat
		LEFT JOIN material_type_x mtx ON mat.material_uuid = mtx.material_uuid
		LEFT JOIN material_type mt ON mtx.material_type_uuid = mt.material_type_uuid
	WHERE
		mat.material_uuid = p_material_uuid);
END;
$$
LANGUAGE plpgsql;



/*
Name:			get_calculation_def ()
Parameters:		p_descrp = string used in search over description columns: short_name, calc_definition, description
Returns:		calculation_def_uuid, short_name, systemtool_name, in_type_uuid, out_type_uuid, systemtool_ver
Author:			G. Cattabriga
Date:			2020.01.16
Description:	returns keys (uuid) of calculation_def matching p_descrp parameters 
Notes:				
							
Example:		SELECT * FROM get_calculation_def (array['standardize']);
*/                                                    
-- DROP FUNCTION IF EXISTS get_calculation_def (p_descr VARCHAR[]) cascade;
CREATE OR REPLACE FUNCTION get_calculation_def (p_descr VARCHAR [])
	RETURNS TABLE (
		calculation_def_uuid uuid, short_name varchar, systemtool_name varchar, calc_definition varchar, description varchar, in_type_uuid uuid, out_type_uuid uuid, systemtool_version varchar)
	AS $$
BEGIN
	RETURN QUERY
	SELECT
		mdd.calculation_def_uuid,
		mdd.short_name,
		st.systemtool_name,
		mdd.calc_definition,
		mdd.description,
		mdd.in_type_uuid,
		mdd.out_type_uuid,
		st.ver
	FROM
		calculation_def mdd
		JOIN systemtool st ON mdd.systemtool_uuid = st.systemtool_uuid
		LEFT JOIN type_def td ON mdd.in_type_uuid = td.type_def_uuid
		LEFT JOIN type_def tdd ON mdd.out_type_uuid = tdd.type_def_uuid
	WHERE
		mdd.short_name = ANY (p_descr)
		OR mdd.calc_definition = ANY (p_descr)
		OR mdd.description = ANY (p_descr);
END;
$$
LANGUAGE plpgsql;




/*
Name:			get_calculation (p_material_refname varchar, p_descr VARCHAR)
Parameters:		p_material_refname = string of material (e.g. SMILES)
				p_descrp = string used in search over description columns: short_name, calc_definition, description
Returns:		calculation_uuid
Author:			G. Cattabriga
Date:			2020.04.01
Description:	returns uuid of calculation
Notes:				
							
Example:		SELECT * FROM get_calculation ('C1=CC=C(C=C1)CC[NH3+].[I-]', array['standardize']);
				SELECT * FROM get_calculation ('C1CC[NH2+]C1.[I-]', array['standardize']);	
				SELECT * FROM get_calculation ('C1CC[NH2+]C1.[I-]', array['charge_cnt_standardize']);
				SELECT * FROM get_calculation ('CN(C)C=O', array['charge_cnt_standardize']);	
				SELECT * FROM get_calculation ('CN(C)C=O');												
*/
-- DROP FUNCTION IF EXISTS get_calculation (p_material_refname varchar, p_descr VARCHAR[]) cascade;
CREATE OR REPLACE FUNCTION get_calculation (p_material_refname varchar, p_descr VARCHAR [] = NULL)
	RETURNS TABLE (
		calculation_uuid uuid)
	AS $$
BEGIN
	RETURN query (WITH RECURSIVE calculation_chain AS (
			SELECT
				cal.calculation_uuid,
				(cal.in_val).v_source_uuid
			FROM
				calculation cal
			WHERE (cal.in_val).v_text = p_material_refname
		UNION
		SELECT
			md2.calculation_uuid,
			(md2.in_val).v_source_uuid
		FROM
			calculation md2
			INNER JOIN calculation_chain dc ON dc.calculation_uuid = (md2.in_val).v_source_uuid
)
	SELECT
		md.calculation_uuid
	FROM
		calculation_chain dc
		JOIN calculation md ON dc.calculation_uuid = md.calculation_uuid
		JOIN calculation_def mdd ON md.calculation_def_uuid = mdd.calculation_def_uuid
	WHERE (p_descr IS NULL)
	or(mdd.short_name = ANY (p_descr)
		OR mdd.calc_definition = ANY (p_descr)
		OR mdd.description = ANY (p_descr))
);
END;
$$
LANGUAGE plpgsql;


/*
Name:			get_val_json (p_in val)
Parameters:		p_in = value of composite type 'val'
Returns:		returns the val value in json form, keys = type, value, unit
Author:			G. Cattabriga
Date:			2020.07.31
Description:	returns value from a 'val' type composite in json, otherwise null 
Notes:				
							
Example:		SELECT get_val_json (concat('(', 
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
					(select edocument_uuid from vw_edocument where title = 'Experiment Specification, Capture and Laboratory Automation Technology (ESCALATE): a software pipeline for automated chemical experimentation and data management'),
					',,,)')::val);
				SELECT get_val_json (concat('(',
					(select type_def_uuid from vw_type_def where category = 'data' and description ='bool'),
					',,,,,,,,,,TRUE,)')::val);		
*/
-- DROP FUNCTION IF EXISTS get_val_json (p_in val) cascade;
CREATE OR REPLACE FUNCTION get_val_json (p_in val)
	RETURNS json
	AS $$
DECLARE
	_p_type varchar;
BEGIN
	select description into _p_type from vw_type_def where type_def_uuid = p_in.v_type_uuid;
	CASE WHEN _p_type = 'int' THEN
		RETURN json_build_object(
			'data_type', _p_type,
			'value', p_in.v_int, 
			'unit', p_in.v_unit 
			);
	WHEN _p_type = 'array_int' THEN
		RETURN json_build_object(
			'data_type', _p_type,
			'value', p_in.v_int_array, 
			'unit', p_in.v_unit 
			);	
	WHEN _p_type = 'num' THEN
		RETURN json_build_object(
			'data_type', _p_type,
			'value', p_in.v_num, 
			'unit', p_in.v_unit 
			);	
	WHEN _p_type = 'array_num' THEN
		RETURN json_build_object(
			'data_type', _p_type,
			'value', p_in.v_num_array, 
			'unit', p_in.v_unit 
			);			
	WHEN _p_type = 'text' THEN
		RETURN json_build_object(
			'data_type', _p_type,
			'value', p_in.v_text
			);	
	WHEN _p_type = 'array_text' THEN
		RETURN json_build_object(
			'data_type', _p_type,
			'value', p_in.v_text_array 
			);
	WHEN _p_type = 'blob' THEN											
		RETURN json_build_object(
			'data_type', _p_type,
			'value', p_in.v_edocument_uuid 
			);	
	WHEN _p_type = 'bool' THEN
		RETURN json_build_object(
			'data_type', _p_type,
			'value', p_in.v_bool
			);	
	WHEN _p_type = 'array_bool' THEN
		RETURN json_build_object(
			'data_type', _p_type,
			'value', p_in.v_bool_array
			);			
	ELSE
		RETURN (NULL);
	END CASE;
END;
$$
LANGUAGE plpgsql;



/*
Name:			get_val_actual (p_in anyelement, p_val val)
Parameters:		p_in = data_type of the composite field, p_val = actual value of composite type 'val'
Returns:		returns the value in it's actual type (e.g. int8, int8[], text, etc)
Author:			G. Cattabriga
Date:			2020.04.16
Description:	returns value from a 'val' type composite, otherwise null 
Notes:				
							
Example:		SELECT get_val_actual (null::int8, concat('(',
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
*/
-- DROP FUNCTION IF EXISTS get_val_actual (p_in anyelement, p_val val) cascade;
CREATE OR REPLACE FUNCTION get_val_actual (p_in anyelement, p_val val)
	RETURNS anyelement
	AS $$
DECLARE
	_p_type varchar;
BEGIN
	select description into _p_type from vw_type_def where type_def_uuid = p_val.v_type_uuid;
	CASE WHEN _p_type = 'int' THEN
		RETURN (p_val.v_int);
	WHEN _p_type = 'array_int' THEN
		RETURN (p_val.v_int_array);
	WHEN _p_type = 'num' THEN
		RETURN (p_val.v_num);
	WHEN _p_type = 'array_num' THEN
		RETURN (p_val.v_num_array);
	WHEN _p_type = 'text' THEN
		RETURN (p_val.v_text);
	WHEN _p_type = 'array_text' THEN
		RETURN (p_val.v_text_array);
	WHEN _p_type = 'blob' THEN
		RETURN (p_val.v_edocument_uuid);
	WHEN _p_type = 'bool' THEN
		RETURN (p_val.v_bool);
	WHEN _p_type = 'array_bool' THEN
		RETURN (p_val.v_bool_array);
	ELSE
		RETURN (NULL);
	END CASE;
END;
$$
LANGUAGE plpgsql;


/*
Name:			get_val (p_in val)
Parameters:		p_in = value of composite type 'val'
Returns:		returns the val type, val unit and val value as a table (v_type text, v_unit text, v_val text)
Author:			G. Cattabriga
Date:			2020.04.16
Description:	returns type, unit and value (all as text) from a 'val' type composite 
Notes:				
							
Example:		SELECT get_val (concat('(', 
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
				SELECT val_val from get_val (concat('(',
					(select type_def_uuid from vw_type_def where category = 'data' and description ='int'),
					',,,,15,,,,,,,)')::val);			
				SELECT get_val (concat('(',
					(select type_def_uuid from vw_type_def where category = 'data' and description ='array_int'),
					',,,,,"{1,2,3,4,5}",,,,,,)')::val);
				SELECT get_val.val_val from get_val (concat('(',
					(select type_def_uuid from vw_type_def where category = 'data' and description ='array_int'),
					',,,,,"{1,2,3,4,5}",,,,,,)')::val);
				SELECT get_val (concat('(',
					(select type_def_uuid from vw_type_def where category = 'data' and description ='blob'),				
					',,,,,,,,',
					(select edocument_uuid from vw_edocument where title = 'Experiment Specification, Capture and Laboratory Automation Technology (ESCALATE): a software pipeline for automated chemical experimentation and data management'),
					',,,)')::val);
				SELECT get_val (concat('(',
					(select type_def_uuid from vw_type_def where category = 'data' and description ='bool'),
					',,,,,,,,,,TRUE,)')::val);	
				SELECT get_val (concat('(',
					(select type_def_uuid from vw_type_def where category = 'data' and description ='fred'),
					',,,,,,,,,,TRUE,)')::val);

*/
-- DROP FUNCTION IF EXISTS get_val (p_in val) cascade;
CREATE OR REPLACE FUNCTION get_val (p_in val)
RETURNS table (val_type text, val_unit text, val_val text) 
AS $$
DECLARE
	_p_type text;
BEGIN
	select description into _p_type from vw_type_def where type_def_uuid = p_in.v_type_uuid;
	CASE 
		WHEN _p_type = 'int' THEN return query select _p_type as val_type, p_in.v_unit::text as val_unit, p_in.v_int::text as val_val;
		WHEN _p_type = 'array_int' THEN return query select _p_type as val_type, p_in.v_unit::text as v_unit, p_in.v_int_array::text as val_val;
		WHEN _p_type = 'num' THEN return query select _p_type as val_type, p_in.v_unit::text as v_unit, p_in.v_num::text as val_val;
		WHEN _p_type = 'array_num' THEN return query select _p_type as val_type, p_in.v_unit::text as v_unit, p_in.v_num_array::text as val_val;
		WHEN _p_type = 'text' THEN return query select _p_type as val_type, p_in.v_unit::text as v_unit, p_in.v_text::text as val_val;
		WHEN _p_type = 'array_text' THEN return query select _p_type as val_type, p_in.v_unit::text as v_unit, p_in.v_text_array::text as val_val;
		WHEN _p_type = 'blob' THEN return query select _p_type as val_type, p_in.v_unit::text as val_unit, 
			(encode((select edocument from edocument where edocument_uuid = p_in.v_edocument_uuid),'escape'))::text as val_val;
		WHEN _p_type = 'bool' THEN return query select _p_type as val_type, p_in.v_unit::text as v_unit, p_in.v_bool::text as val_val;
		WHEN _p_type = 'array_bool' THEN return query select _p_type as val_type, p_in.v_unit::text as val_unit, p_in.v_bool_array::text as val_val;
		ELSE return;
	END CASE;	
END;
$$ LANGUAGE plpgsql;


/*
Name:			get_val_units (p_in val)
Parameters:		p_in = value of composite type 'val'
Returns:		returns unit (text)
Author:			G. Cattabriga
Date:			2020.04.16
Description:	returns unit (as text) from a 'val' type composite 
Notes:				
							
Example:		SELECT get_val_unit (concat('(', 
					(select type_def_uuid from vw_type_def where category = 'data' and description ='text'),
					',inchikey,"[I-].[NH3+](CCC1=CC=C(C=C1)OC)",,,,,,,,,)')::val);
				SELECT get_val_unit (concat('(',
					(select type_def_uuid from vw_type_def where category = 'data' and description ='num'),
					',ergs,,,,,266.99,,,,,)')::val);
				SELECT get_val_unit (concat('(',
					(select type_def_uuid from vw_type_def where category = 'data' and description ='int'),
					',mols,,,15,,,,,,,)')::val);							
*/
-- DROP FUNCTION IF EXISTS get_val_unit (p_in val) cascade;
CREATE OR REPLACE FUNCTION get_val_unit (p_in val)
returns text AS $$
BEGIN
	return (p_in.v_unit);
END;
$$ LANGUAGE plpgsql;



/*
Name:			get_type_def (_category type_def_category, _description varchar)
Parameters:		_category = type_def category, _description = type_def description
Returns:		returns uuid of type_def
Author:			G. Cattabriga
Date:			2020.09.01
Description:	returns uuid of type_def or null
Notes:				
							
Example:		select get_type_def ('data', 'text');
				select get_type_def ('data', 'bool');
				select get_type_def ('data', 'blob');	
				select get_type_def ('file', 'svg');	
				select get_type_def ('data', 'fred');				
*/
-- DROP FUNCTION IF EXISTS get_type_def (_category varchar, _description varchar) cascade;
CREATE OR REPLACE FUNCTION get_type_def (_category varchar, _description varchar)
returns uuid AS $$
BEGIN
	return (select type_def_uuid from vw_type_def where category = _category::type_def_category and description = _description);
END;
$$ LANGUAGE plpgsql;


/*
Name:			put_val (p_type_uuid uuid, p_val anyelement, p_unit text )
Parameters:		p_type is the data type as defined by val_type enum, p_val is the value to be inserted, p_unit is the unit in text
Returns:		val composite or null
Author:			G. Cattabriga
Date:			08.02.2020
Description:	function to insert a value and it's type into the composite value data type 
Notes:			this will cast the p_val text into it's requisite type	
							
Example:		SELECT put_val ((select get_type_def ('data', 'text')),'[I-].[NH3+](CCC1=CC=C(C=C1)OC)'::text, 'inchikey');
				SELECT put_val ((select get_type_def ('data', 'text')),'fred'::text, null);
				SELECT put_val ((select get_type_def ('data', 'int')), '5', 'ergs');
				SELECT put_val ((select get_type_def ('data', 'num')), '1.2345', 'ergs');
				SELECT put_val ((select get_type_def ('data', 'array_int')), '{1,2,3,4}', 'ergs');
				SELECT put_val ((select get_type_def ('data', 'array_num')), '{1.01,2,3,404.237}', 'ergs');
				SELECT put_val ((select get_type_def ('data', 'bool')), 'FALSE', null);
				SELECT put_val ((select get_type_def ('data', 'array_bool')), '{FALSE,TRUE,TRUE,FALSE}', null);
				select get_val((SELECT put_val ((select get_type_def ('data', 'int')), '5', 'ergs')));
				select get_val((SELECT put_val ((select get_type_def ('data', 'array_int')), '{1,2,3,4}', 'ergs')));				
*/
-- DROP FUNCTION IF EXISTS put_val (p_type_uuid uuid, p_val text, p_unit text ) cascade;
CREATE OR REPLACE FUNCTION put_val (p_type_uuid uuid, p_val text, p_unit text )
	RETURNS val
	AS $$
DECLARE
	_out_val val;
	_p_type varchar;
BEGIN
	select description into _p_type from vw_type_def where type_def_uuid = p_type_uuid;
	_out_val.v_type_uuid = p_type_uuid;
	_out_val.v_unit = p_unit::text;
	IF _p_type = 'int' THEN
		_out_val.v_int = p_val::int8;
	ELSIF _p_type = 'array_int' THEN
		_out_val.v_int_array = p_val::int8[];
	ELSIF _p_type = 'num' THEN
		_out_val.v_num = p_val::numeric;
	ELSIF _p_type = 'array_num' THEN
		_out_val.v_num_array = p_val::numeric[];
	ELSIF _p_type = 'text' THEN
		_out_val.v_text = p_val::text;
	ELSIF _p_type = 'array_text' THEN
		_out_val.v_text = p_val::text[];
	ELSIF _p_type::text LIKE 'blob%' THEN
		_out_val.v_edocument_uuid = p_val::uuid;
	ELSIF _p_type = 'bool' THEN
		_out_val.v_bool = p_val::BOOLEAN;
	ELSIF _p_type = 'array_bool' THEN
		_out_val.v_bool_array = p_val::BOOLEAN[];
	END IF;
	RETURN _out_val;
END;
$$
LANGUAGE plpgsql;


/*
Name:			arr_val_2_val_arr (arr_val val)
Parameters:		the arr of vals (in a val)
Returns:		array of val
Author:			G. Cattabriga
Date:			12.07.2020
Description:	function to convert an array (in a val) to an array of val's
Notes:			will only work with array types: array_bool, array_int, array_num, array_text

Example:        select arr_val_2_val_arr ((select out_val from vw_calculation where short_name = 'LANL_WF1_H2O_5mL_concentration'));
*/
-- DROP FUNCTION IF EXISTS arr_val_2_val_arr (arr_val val) cascade;
CREATE OR REPLACE FUNCTION arr_val_2_val_arr (arr_val val)
	RETURNS val[]
	AS $$
DECLARE
    _arr_unit text := (select val_unit from get_val(arr_val));
    _arr_val text[] := (select val_val::text[] from get_val(arr_val));
    _arr_type text := (select val_unit from get_val(arr_val));
    _loop_txt text;
    _out_element int := 1;
    _out_val val[];
    _out_type_uuid uuid;
    _type_def_uuid uuid := arr_val.v_type_uuid;
BEGIN
    IF arr_val.v_type_uuid in (select _type_def_uuid from vw_type_def where category = 'data' and description like 'array_%') THEN
        CASE _arr_type
            WHEN 'array_bool' THEN _out_type_uuid := (select type_def_uuid from vw_type_def where category = 'data' and description like 'bool');
            WHEN 'array_int' THEN _out_type_uuid := (select type_def_uuid from vw_type_def where category = 'data' and description like 'int');
            WHEN 'array_num' THEN _out_type_uuid := (select type_def_uuid from vw_type_def where category = 'data' and description like 'num');
            ELSE _out_type_uuid := (select type_def_uuid from vw_type_def where category = 'data' and description like 'text');
        END CASE;
		FOREACH _loop_txt IN ARRAY _arr_val
            LOOP
                _out_val[_out_element] := put_val(_out_type_uuid, _loop_txt, _arr_unit);
                _out_element := _out_element + 1;
            END LOOP;
    END IF;
	RETURN _out_val;
END;
$$
LANGUAGE plpgsql;


/*
Name:			get_chemaxon_directory ()
Parameters:		p_systemtool_uuid = identifier (id) of the chemaxon [software] tool
				p_actor_uuid = identifier (uuid) of the actor performing the calculation: this references the relevant software directories in order to run the CLI tool
Returns:		directory as TEXT
Author:			G. Cattabriga
Date:			2020.02.18
Description:	returns the directory chemaxon tool is located; uses actor_pref 
Notes:				
							
Example:		select get_chemaxon_directory((select systemtool_uuid from systemtool where systemtool_name = 'standardize'), (SELECT actor_uuid FROM vw_actor where person_last_first like 'Cattabriga, Gary')); (returns the version for cxcalc for actor GC) 
*/
-- DROP FUNCTION IF EXISTS get_chemaxon_directory ( p_systemtool_uuid int8, p_actor int8 ) cascade;
CREATE OR REPLACE FUNCTION get_chemaxon_directory (p_systemtool_uuid uuid, p_actor_uuid uuid)
	RETURNS TEXT
	AS $$
DECLARE
	_descr_name varchar;
BEGIN
	SELECT
		st.systemtool_name INTO _descr_name
	FROM
		systemtool st
	WHERE
		st.systemtool_uuid = p_systemtool_uuid;
	CASE _descr_name
	WHEN 'cxcalc',
	'standardize',
	'molconvert' THEN
		RETURN (
			SELECT
				ap.pvalue
			FROM
				actor_pref ap
			WHERE
				ap.actor_uuid = p_actor_uuid
				AND ap.pkey = 'MARVINSUITE_DIR');
	WHEN 'generatemd' THEN
		RETURN (
			SELECT
				ap.pvalue
			FROM
				actor_pref ap
			WHERE
				ap.actor_uuid = p_actor_uuid
				AND ap.pkey = 'CHEMAXON_DIR');
	END CASE;
	COMMIT;
	END;
$$
LANGUAGE plpgsql;



/*
Name:			get_chemaxon_version ()
Parameters:		p_systemtool_uuid = identifier (uuid) of the chemaxon [software] tool
				p_actor_uuid = identifier (uuid) of the actor performing the calculation: this references the relevant software directories in order to run the CLI tool
Returns:		version as TEXT
Author:			G. Cattabriga
Date:			2020.02.12
Description:	returns the version for the specified chemaxon tool in string format 
Notes:				
							
Example:		select get_chemaxon_version((select systemtool_uuid from systemtool where systemtool_name = 'generatemd'), (select actor_uuid from actor where description = 'Gary Cattabriga')); (returns the version for cxcalc for actor GC) 
*/
-- DROP FUNCTION IF EXISTS get_chemaxon_version ( p_systemtool_uuid int8, p_actor_uuid uuid ) cascade;
CREATE OR REPLACE FUNCTION get_chemaxon_version ( p_systemtool_uuid uuid, p_actor_uuid uuid ) RETURNS TEXT AS $$ 
DECLARE
	_descr_name varchar;
	_descr_dir varchar;
BEGIN
	DROP TABLE IF EXISTS load_temp;
	CREATE TEMP TABLE load_temp ( help_string VARCHAR ) ON COMMIT DROP ;
	SELECT st.systemtool_name INTO _descr_name FROM systemtool st WHERE st.systemtool_uuid = p_systemtool_uuid;
	CASE _descr_name
			WHEN 'cxcalc','standardize','molconvert' THEN
				SELECT ap.pvalue INTO _descr_dir FROM actor_pref ap WHERE ap.actor_uuid = p_actor_uuid AND ap.pkey = 'MARVINSUITE_DIR';
			WHEN 'generatemd' THEN
				SELECT ap.pvalue INTO _descr_dir FROM actor_pref ap WHERE ap.actor_uuid = p_actor_uuid AND ap.pkey = 'CHEMAXON_DIR';
	END CASE;
	EXECUTE format ( 'COPY load_temp FROM PROGRAM ''%s%s -h'' ', _descr_dir, _descr_name );
	RETURN ( SELECT SUBSTRING ( help_string FROM '[0-9]{1,2}[.][0-9]{1,2}[.][0-9]{1,2}' ) FROM load_temp WHERE SUBSTRING ( help_string FROM '[0-9]{1,2}[.][0-9]{1,2}[.][0-9]{1,2}' ) IS NOT NULL );
END;
$$ LANGUAGE plpgsql;


/*
Name:			run_descriptor_calc ()
Parameters:		p_descriptor_def_uuid = the uuid of the descriptor definition you want executed
				p_alias_name = an alternate name to reference this specific descriptor created. For example, the molweight cxcalc can be run on raw SMILES or standardized SMILES; this is a way to distinguish between the two when outputting
				p_command_opt = any optional commands to be included in the execution. For example '--ignore-error'
				p_actor_uuid = uuid of the actor requesting the run
Returns:		boolean (true if executed normally, false if not
Author:			G. Cattabriga
Date:			2020.03.20
Description:	runs a descriptor calculation on a specified input 
Notes:			This function depends on the calculation_eval table for inputs (of val_type) and storage of output
				It also creates a temp file 'temp_in.txt' in the HOME_DIR
				DROP function run_descriptor (p_descriptor_def_uuid uuid, p_alias_name varchar, p_command_opt varchar, p_actor_uuid uuid);
Example:		-- first truncate then populate the calculation_eval table with the inputs 
					truncate table calculation_eval RESTART IDENTITY;
					insert into calculation_eval(in_val.v_type, in_val.v_text) (select 'text', vw.material_refname_description from vw_material vw  where vw.material_refname_def = 'SMILES');
				SELECT * FROM run_descriptor ((SELECT calculation_def_uuid FROM get_calculation_def (array['standardize'])), '--ignore-error', (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary'));
							
				-- example of using a previous calculated descriptor (standardize) as input; where we take the standardized SMILES from all materials
							truncate table calculation_eval RESTART IDENTITY;
							insert into calculation_eval(in_val.v_type, in_val.v_text) 
								select (md.out_val).v_type, (md.out_val).v_text from calculation md where md.calculation_def_uuid = (select calculation_def_uuid from get_calculation_def(array['standardize']));
				SELECT * FROM run_descriptor ((SELECT calculation_def_uuid FROM get_calculation_def (array['molweight'])), '_raw_standard_molweight', '--ignore-error --do-not-display ih', (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary'));
							
				truncate table calculation_eval RESTART IDENTITY;
				insert into calculation_eval(in_val.v_type, in_val.v_text) 
					(select 'text'::val_type, mat.material_refname_description from vw_material mat where mat.material_refname_def = 'SMILES');
				SELECT * FROM run_descriptor ((SELECT calculation_def_uuid FROM get_calculation_def (array['molweight'])), '_raw_molweight', '--ignore-error --do-not-display ih', (SELECT actor_uuid FROM get_actor () where person_lastfirst like 'Cattabriga, Gary'));							
*/
-- DROP FUNCTION IF EXISTS run_descriptor (p_descriptor_def_uuid uuid, p_alias_name varchar, p_command_opt varchar, p_actor_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION run_descriptor (p_descriptor_def_uuid uuid, p_alias_name varchar, p_command_opt varchar, p_actor_uuid uuid)
	RETURNS BOOLEAN
	AS $$
DECLARE
	_descr_dir varchar;
	_descr_command varchar;
	_descr_param varchar;
	_descr_ver varchar;
	_temp_dir varchar;
	_temp_in varchar := 'temp_in.txt';
	_type_out varchar;
BEGIN
	-- assign the calculation out_type so we can properly store the calc results into calculation_eval
	SELECT
		out_type_uuid INTO _type_out
	FROM
		get_calculation_def (ARRAY ['standardize']);
	DROP TABLE IF EXISTS load_temp_out;
	--	DROP TABLE IF EXISTS calculation_eval;
	CREATE TEMP TABLE load_temp_out (
		load_id serial8,
		strout VARCHAR ) ON COMMIT DROP;
	--	CREATE TABLE calculation_eval(eval_id serial8, in_val val, out_val val, actor_uuid uuid, create_date timestamptz NOT NULL DEFAULT NOW());
	-- load the variables with actor preference data; for temp directory and chemaxon directory
	SELECT
		INTO _temp_dir pvalue
	FROM
		actor_pref act
	WHERE
		act.actor_uuid = p_actor_uuid
		AND act.pkey = 'HOME_DIR';
	SELECT
		INTO _descr_dir get_chemaxon_directory ((
				SELECT
					systemtool_uuid
				FROM
					calculation_def mdd
				WHERE
					mdd.calculation_def_uuid = p_descriptor_def_uuid), p_actor_uuid);
	SELECT
		INTO _descr_command (
			SELECT
				st.systemtool_name
			FROM
				calculation_def mdd
				JOIN systemtool st ON mdd.systemtool_uuid = st.systemtool_uuid
			WHERE
				mdd.calculation_def_uuid = p_descriptor_def_uuid);
	SELECT
		INTO _descr_param mdd.calc_definition
	FROM
		calculation_def mdd
	WHERE
		mdd.calculation_def_uuid = p_descriptor_def_uuid;
	CASE _descr_command
	WHEN 'cxcalc',
	'standardize',
	'generatemd' THEN
		-- load the version of the descriptor function that will be run, this will be a future validation
		SELECT
			INTO _descr_ver get_chemaxon_version ((
					SELECT
						systemtool_uuid
					FROM
						systemtool
					WHERE
						systemtool_name = _descr_command), p_actor_uuid);
	    -- copy the inputs from m_descriptor_eval into a text file to be read by the command
	    -- this is set to work for ONLY single text varchar input
	    EXECUTE format('copy ( select (ev.in_val).v_text from calculation_eval ev) to ''%s%s'' ', _temp_dir, _temp_in);
	    -- '/Users/gcattabriga/tmp/temp_chem.txt';
	    EXECUTE format('COPY load_temp_out(strout) FROM PROGRAM ''%s%s %s %s %s%s'' ', _descr_dir, _descr_command, p_command_opt, _descr_param, _temp_dir, _temp_in);
    ELSE
	    RETURN FALSE;
	END CASE;
	-- update the calculation_eval table with results from command execution; found in load_temp_out temp table
	UPDATE
		calculation_eval ev
	SET
		calculation_def_uuid = p_descriptor_def_uuid,
		out_val.v_type_uuid = _type_out::val_type,
		out_val.v_text = CASE _type_out
		WHEN 'text' THEN
			strout
		END,
		out_val.v_num = CASE _type_out
		WHEN 'num' THEN
			strout::numeric
		END,
		calculation_alias_name = p_alias_name,
		actor_uuid = p_actor_uuid
	FROM
		load_temp_out lto
	WHERE
		lto.load_id = ev.eval_id;
	RETURN TRUE;
	END;
$$
LANGUAGE plpgsql;


/*
Name:			get_charge_count (p_mol_smiles varchar) 
Parameters:		p_mol_smiles = SMILES string representing molecule
Returns:		count of '+'s as INT
Author:			G. Cattabriga
Date:			2020.03.13
Description:	returns the count of [+] charges in a SMILES string 
Notes:			if p_mol_smiles is null, will return null (non-count); so you can check for null input
							
Example:		select get_charge_count('C1C[NH+]2CC[NH+]1CC2');
				select get_charge_count(null);
*/
-- DROP FUNCTION IF EXISTS get_charge_count (p_mol_smiles varchar) cascade;
CREATE OR REPLACE FUNCTION get_charge_count (p_mol_smiles varchar)
	RETURNS int
	AS $$
BEGIN
	IF(p_mol_smiles IS NOT NULL) THEN
		RETURN (CHAR_LENGTH(p_mol_smiles) - CHAR_LENGTH(REPLACE(p_mol_smiles, '+', '')));
	ELSE
		RETURN NULL;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			math_op (p_in_num numeric, p_op text, p_in_opt_num numeric default null) 
Parameters:		p_op = basic math operation ('+', '/', '-', '*'. etc)
				p_in_num, p_in_opt_num = numeric input values
Returns:		results of math operation as NUM
Author:			G. Cattabriga
Date:			2020.03.13
Description:	returns the result of a basic math operation
Notes:			up to caller to cast into desired num type (e.g. int)
Example:		select math_op(12, '/', 6);
				select math_op(101, '*', 11);
				select math_op(5, '!');
                select math_op(2, '*', (select math_op(3, '+', 4)));
                select math_op(array[1, 2, 3], '*', 2);
                select math_op('fred', '*', 2);
*/
-- DROP FUNCTION IF EXISTS math_op (p_op text, p_in_num numeric, p_in_opt_num numeric) cascade;
CREATE OR REPLACE FUNCTION math_op (p_in_num numeric, p_op text, p_in_opt_num numeric DEFAULT NULL)
	RETURNS numeric
	AS $$
DECLARE
	i numeric;
BEGIN
	CASE WHEN p_op in('/', '*', '+', '-', '%', '^', '!', '|/', '@') THEN
		EXECUTE format('select %s %s %s', p_in_num, p_op, p_in_opt_num) INTO i;
	    RETURN i;
    ELSE
	    RETURN NULL;
	END CASE;
END;
$$
LANGUAGE plpgsql;


/*
Name:			math_op_array (p_in_num numeric[], p_op text, p_in_opt_num numeric default null)
Parameters:		p_op = basic math operation ('+', '/', '-', '*'. etc)
				p_in_num = numeric array, p_in_opt_num = numeric input values
Returns:		results of math operation as NUM array num[]
Author:			G. Cattabriga
Date:			2020.12.7
Description:	returns the result of a basic math operation on a numeric operation
Notes:
Example:		select math_op_arr(array[101], '*', 11);
                select math_op_arr(array[12, 6, 4], '/', 12);
                select math_op_arr(array[12, 6, 4, 2, 1, .1, .01, .001], '/', 12);
                select math_op_arr((math_op_arr(array[12, 6, 4, 2, 1, .1, .01, .001], '/', 12)), '*', 5);
                select math_op_arr((math_op_arr('{12, 6, 4, 2, 1, .1, .01, .001}', '/', 12)), '*', 5);
                select math_op_arr(5, '-', (math_op_arr((math_op_arr(array[12, 6, 4, 2, 1, .1, .01, .001], '/', 12)), '*', 5)));
 */
-- DROP FUNCTION IF EXISTS math_op_arr (p_in_num numeric[], p_op text, p_in_opt_num numeric[]) cascade;
CREATE OR REPLACE FUNCTION math_op_arr (p_in_num numeric[], p_op text, p_in_opt_num numeric DEFAULT NULL)
	RETURNS numeric[]
	AS $$
DECLARE
	_i numeric;
    _inx int := 1;
    _r numeric;
    _res numeric[];
BEGIN
    IF p_op in('/', '*', '+', '-', '%', '^', '!', '|/', '@') THEN
        FOREACH _i IN ARRAY p_in_num
            LOOP
                EXECUTE format('select %s::numeric %s %s::numeric', _i, p_op, p_in_opt_num) INTO _r;
                _res[_inx] := _r;
                _inx := _inx + 1;
            END LOOP;
        RETURN _res;
    ELSE
        RETURN NULL;
    END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			do_calculation (p_calculation_def_uuid uuid)
Parameters:		calculation_def_uuid
Returns:		results of math operation as a val type
Author:			G. Cattabriga
Date:			2020.12.14
Description:	returns the results of a basic postgres math operation; will bring in any associated parameters
Notes:          array parameter names need to be [double] quoted in the calc definition
Example:		select do_calculation(
                    (select calculation_def_uuid from vw_calculation_def
                    where short_name = 'LANL_WF1_HCL12M_5mL_concentration'))
                select do_calculation(
                    (select calculation_def_uuid from vw_calculation_def
                    where short_name = 'LANL_WF1_H2O_5mL_concentration'))
 */

-- DROP FUNCTION IF EXISTS do_calculation (p_calculation_def_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION do_calculation (p_calculation_def_uuid uuid)
	RETURNS val
	AS $$
DECLARE
    -- seed the _calc_def string from the calculation_def
    _calc_def varchar := concat('select ',(select calc_definition from vw_calculation_def where calculation_def_uuid = p_calculation_def_uuid));
    _out_type_uuid uuid := (select out_type_uuid from vw_calculation_def where calculation_def_uuid = p_calculation_def_uuid);
    _out_unit varchar := (select out_unit from vw_calculation_def where calculation_def_uuid = p_calculation_def_uuid);
    _param_rec record;
    _r text;
BEGIN
    -- create temp table to store the parameter name and values associated with the calculation_def
    create temp table _param_table as
        select row_number() over (order by null) as id, parameter_def_description, (select val_val from get_val (default_val) as val_val)
        from vw_calculation_parameter_def
        where calculation_def_uuid = p_calculation_def_uuid;
    -- loop through the temp table and replace any parameter names with assoc. values
    FOR _param_rec IN (select * from _param_table) LOOP
        _calc_def := replace(_calc_def, _param_rec.parameter_def_description, _param_rec.val_val);
    END LOOP;
    EXECUTE _calc_def INTO _r;
    drop table _param_table;
    RETURN  put_val(_out_type_uuid, _r, _out_unit);
END;
$$
LANGUAGE plpgsql;


/*
Name:			delete_assigned_recs (p_ref_uuid uuid) 
Parameters:		p_ref_uuid = the reference uuid used to identify the associated records
Returns:		
Author:			G. Cattabriga
Date:			2020.09.18
Description:	removes associated records to p_ref_uuid for the following entities: note, tag, udf 
Notes:			
Example:		insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) 
						values ('Tester','Lester','Fester','1313 Mockingbird Ln',null,'Munsterville','NY',null,null,null,null,null,null,null) returning *;
				insert into vw_note (notetext, actor_uuid, ref_note_uuid) 
						values ('test note for Lester the Actor', (select actor_uuid from vw_actor where person_last_name = 'Tester'), 
						(select actor_uuid from vw_actor where person_last_name = 'Tester'));
				insert into vw_tag_assign (tag_uuid, ref_tag_uuid) 
						values ((select tag_uuid from vw_tag where (display_text = 'do_not_use' and type = 'actor')), 
						(select actor_uuid from vw_actor where person_last_name = 'Tester'));
				insert into vw_udf (ref_udf_uuid, udf_def_uuid, udf_val_val) values
					((select actor_uuid from vw_actor where person_last_name = 'Tester'), 
					(select udf_def_uuid from vw_udf_def where description = 'batch count'),
					'123 -> batch no. test');
				select delete_assigned_recs ((select actor_uuid from vw_actor where description = 'Lester Tester'));				
*/
-- DROP FUNCTION IF EXISTS delete_assigned_recs (p_ref_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION delete_assigned_recs (p_ref_uuid uuid)
	RETURNS TABLE (entity text, ref_uuid uuid)
	AS $$
DECLARE
	_note_uuid uuid;
	_tag_uuid uuid;
	_udf_uuid uuid;
BEGIN
	create temp table _tbldel (entity text, ref_uuid uuid);
	delete from vw_note WHERE ref_note_uuid = p_ref_uuid returning note_uuid into _note_uuid;
 	delete from vw_tag_assign WHERE ref_tag_uuid = p_ref_uuid returning tag_uuid into _tag_uuid;
	delete from vw_udf WHERE ref_udf_uuid = p_ref_uuid returning udf_uuid into _udf_uuid;

	IF _note_uuid IS NOT NULL THEN
		INSERT INTO _tbldel (entity, ref_uuid) values('note', _note_uuid);
	END IF;
	IF _tag_uuid IS NOT NULL THEN
		INSERT INTO _tbldel (entity, ref_uuid) values('tag', _tag_uuid);
	END IF;
	IF _udf_uuid IS NOT NULL THEN
		INSERT INTO _tbldel (entity, ref_uuid) values('udf', _udf_uuid);
	END IF;

    RETURN QUERY SELECT * from _tbldel; 
       
    drop table _tbldel;
END;
$$
LANGUAGE plpgsql;


/*
Name:			stack_clear () 
Parameters:		
Returns:		number of stack items deleted
Author:			G. Cattabriga
Date:			2020.10.13
Description:	delete all items in the LIFO stack (calculation_stack); reset id (serial) to 1
Notes:			
Example:		select stack_clear ();				
*/
-- DROP FUNCTION IF EXISTS stack_clear () cascade;
CREATE OR REPLACE FUNCTION stack_clear ()
	RETURNS int
	AS $$
DECLARE
	_cnt int;
BEGIN
	SELECT count(*) from calculation_stack into _cnt; 
	DELETE FROM calculation_stack;
	ALTER SEQUENCE calculation_stack_calculation_stack_id_seq RESTART WITH 1;
	RETURN _cnt;
END;
$$
LANGUAGE plpgsql;


/*
Name:			stack_push (p_val val) 
Parameters:		p_val = value (val) pushing onto the stack
Returns:		id (index) of calculation_stack
Author:			G. Cattabriga
Date:			2020.10.10
Description:	pushes value (p_val) onto stack (calculation_stack) 
Notes:			to remove 'top' stack value, use: stack_pop () 
Example:		select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '100', 'C'))::val);
				select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '50', 'C'))::val);
				select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '10', 'C'))::val);				
*/
-- DROP FUNCTION IF EXISTS stack_push (p_val val) cascade;
CREATE OR REPLACE FUNCTION stack_push (p_val val)
	RETURNS int4
	AS $$
DECLARE
	_id int4;	
BEGIN
	IF get_val(p_val) IS NOT NULL THEN 
		INSERT into calculation_stack (stack_val) values (p_val) returning calculation_stack_id into _id;
	END IF;
	RETURN _id; 
END;
$$
LANGUAGE plpgsql;


/*
Name:			stack_pop () 
Parameters:		
Returns:		value (val) of top stack item (LIFO)
Author:			G. Cattabriga
Date:			2020.10.10
Description:	pops value off from stack (calculation_stack) in LIFO manner 
Notes:			this will get the 'newest' (max calculation_stack_id) item from the stack and delete
Example:		select stack_pop ();				
*/
-- DROP FUNCTION IF EXISTS stack_pop () cascade;
CREATE OR REPLACE FUNCTION stack_pop ()
	RETURNS val
	AS $$
DECLARE
	_val text;
BEGIN
	IF (select count(*) from calculation_stack) > 0 THEN 
		SELECT stack_val::text from calculation_stack  WHERE calculation_stack_id = (SELECT MAX(calculation_stack_id) FROM calculation_stack) into _val; 
		DELETE FROM calculation_stack WHERE calculation_stack_id = (SELECT MAX(calculation_stack_id) FROM calculation_stack);
		RETURN _val::val;
	ELSE
		RETURN NULL;
	END IF;
END;
$$
LANGUAGE plpgsql;



/*
Name:			stack_dup () 
Parameters:		
Returns:		void
Author:			G. Cattabriga
Date:			2020.10.13
Description:	duplicates the top value - pops val, then pushes twice 
Notes:			
Example:		select stack_clear ();
				select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '1', 'C'))::val);
				select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '2', 'C'))::val);
				select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '3', 'C'))::val);	
				select stack_dup ();				
*/
-- DROP FUNCTION IF EXISTS stack_dup () cascade;
CREATE OR REPLACE FUNCTION stack_dup ()
	RETURNS void
	AS $$
DECLARE
	_val text;
BEGIN
	SELECT stack_pop () into _val; 
	PERFORM stack_push (_val::val);
	PERFORM stack_push (_val::val);
END;
$$
LANGUAGE plpgsql;


/*
Name:			stack_swap () 
Parameters:		
Returns:		void
Author:			G. Cattabriga
Date:			2020.10.13
Description:	swaps the two top values - pops val, pops val, then push, push 
Notes:			
Example:		select stack_clear ();
				select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '1', 'C'))::val);
				select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '2', 'C'))::val);
				select stack_push ((SELECT put_val ((select get_type_def ('data', 'int')::uuid), '3', 'C'))::val);	
				select stack_swap ();				
*/
-- DROP FUNCTION IF EXISTS stack_swap () cascade;
CREATE OR REPLACE FUNCTION stack_swap ()
	RETURNS void
	AS $$
DECLARE
	_val1 text;
	_val2 text;
BEGIN
	SELECT stack_pop () into _val1; 
	SELECT stack_pop () into _val2; 
	PERFORM stack_push (_val1::val);
	PERFORM stack_push (_val2::val);	
END;
$$
LANGUAGE plpgsql;



/*
Name:			tag_to_array (p_ref_uuid uuid)
Parameters:
Returns:		void
Author:			G. Cattabriga
Date:			2020.12.18
Description:	returns the tags associated with the uuid (p_ref_uuid) in an array (text[])
Notes:
Example:		insert into vw_tag_assign (tag_uuid, ref_tag_uuid) values
                    ((select tag_uuid from vw_tag where (display_text = 'inactive' and vw_tag.type = 'actor')),
                    (select actor_uuid from vw_actor where person_last_name = 'Cattabriga')),
                    ((select tag_uuid from vw_tag where (display_text = 'temporary' and vw_tag.type = 'actor')),
                    (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));
                select tag_to_array ((select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));
*/
-- DROP FUNCTION IF EXISTS tag_to_array (p_ref_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION tag_to_array (p_ref_uuid uuid)
	RETURNS text[]
	AS $$
BEGIN
    IF (select exists (select tag_x_uuid from vw_tag_assign where ref_tag_uuid = p_ref_uuid)) THEN
        RETURN
            (select array_agg(display_text) from vw_tag t join
            (select tag_uuid from vw_tag_assign where ref_tag_uuid = p_ref_uuid) ta
            on t.tag_uuid = ta.tag_uuid);
    ELSE
        RETURN null;
    END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			note_to_array (p_ref_uuid uuid)
Parameters:
Returns:		void
Author:			G. Cattabriga
Date:			2020.12.18
Description:	returns the notes associated with the uuid (p_ref_uuid) in an array (text[])
Notes:
Example:		insert into vw_note (notetext, actor_uuid, ref_note_uuid) values
                    ('this is note 1. blah blah blah',
                    (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'),
                    (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));
                insert into vw_note (notetext, ref_note_uuid) values
                    ('this is note 2. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                    (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));
                select note_to_array ((select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));
*/
-- DROP FUNCTION IF EXISTS note_to_array (p_ref_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION note_to_array (p_ref_uuid uuid)
	RETURNS text[]
	AS $$
BEGIN
    IF (select exists (select note_x_uuid from vw_note where ref_note_uuid = p_ref_uuid)) THEN
        RETURN
            (select array_agg(concat('''',notetext,'''')) from vw_note n join
            (select note_uuid from note_x where ref_note_uuid = p_ref_uuid) nx
            on n.note_uuid = nx.note_uuid);
    ELSE
        RETURN null;
    END IF;
END;
$$
LANGUAGE plpgsql;


-- ===========================================================================
-- JSON Rendering Functions by entity
-- ===========================================================================

/*
Name:			experiment_outcome_measure_json ()
Parameters:
Returns:		table (experiment_uuid uuid, outcome_measure json)
Author:			G. Cattabriga
Date:			2020.12.20
Description:	returns table (experiment_uuid uuid, outcome_measure json) of ALL outcome measure by experiment
Notes:
Example:		select experiment_outcome_measure_json ();
*/
-- DROP FUNCTION IF EXISTS experiment_outcome_measure_json () cascade;
CREATE OR REPLACE FUNCTION experiment_outcome_measure_json ()
	RETURNS text[]
	AS $$
BEGIN
    IF (select exists (select note_x_uuid from vw_note where ref_note_uuid = p_ref_uuid)) THEN
        RETURN
            (select array_agg(concat('''',notetext,'''')) from vw_note n join
            (select note_uuid from note_x where ref_note_uuid = p_ref_uuid) nx
            on n.note_uuid = nx.note_uuid);
    END IF;
END;
$$
LANGUAGE plpgsql;