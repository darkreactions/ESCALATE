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
Name:					load_csv(_csv varchar, _csv varchar)
Parameters:		fname = string of source filename, full location
							tname = string of destination load_table
Returns:			count of records loaded, or NULL is failed
Author:				G. Cattabriga
Date:					2020.05.15
Description:	loads csv file (_csv) into load table (_table) 
Notes:				assumes a column header row
							drop function if exists load_csv(_csv varchar, _table varchar) cascade;
Example:			select load_csv('/Users/gcattabriga/Downloads/GitHub/ESCALATE_report/iodides/REPORT/iodides.csv', 'load_v2_iodides_temp');
*/
CREATE OR REPLACE FUNCTION load_csv(_csv varchar, _table varchar)
  RETURNS int AS
$func$
DECLARE
   row_ct int;
BEGIN
   -- create staging table for 1st row as  single text column 
	CREATE TEMP TABLE tmp0(cols varchar) ON COMMIT DROP;
   -- fetch 1st row
	EXECUTE format($$COPY tmp0 FROM PROGRAM 'head -n1 %I'$$, _csv);
   -- create actual temp table with all columns text
	EXECUTE (
      SELECT format('CREATE TEMP TABLE %I(', _table)
          || string_agg(quote_ident(col) || ' text', ',')
          || ')'
      FROM  (SELECT cols FROM tmp0 LIMIT 1) t
         , unnest(string_to_array(t.cols, ',')) col
     );
   -- Import data
   EXECUTE format($$COPY %I FROM %L WITH (format csv, HEADER, NULL 'null')$$, _table, _csv);
		-- get row count
	 GET DIAGNOSTICS row_ct = ROW_COUNT;
   return row_ct;
END
$func$  LANGUAGE plpgsql;


/*
Name:					load_experiment(_table)
Parameters:		fname = string of source filename, full location
							tname = string of destination load_table
Returns:			count of records loaded, or NULL is failed
Author:				G. Cattabriga
Date:					2020.05.15
Description:	loads csv file (_csv) into load table (_table) 
Notes:				assumes the following columns: _exp_no, _raw_operator, _raw_user_generated_experimentname, _raw_datecreated, _raw_lab, _raw_labwareid, 
							drop function if exists load_csv(_csv varchar, _table varchar) cascade;
Example:			select load_csv('/Users/gcattabriga/Downloads/GitHub/ESCALATE_report/iodides/REPORT/iodides.csv', 'load_v2_iodides_temp');
*/