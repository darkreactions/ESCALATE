/*
Name:			prod_etl
Parameters:		none
Returns:		none
Author:			G. Cattabriga
Date:			2020.04.23
Description:	ETL functions and execution
Notes:											
*/



/*
Name:			load_mol_images ()
Parameters:		p_systemtool_uuid = identifier (id) of the chemaxon [software] tool
				p_actor_uuid = identifier (uuid) of the actor performing the calculation: this references the relevant software directories in order to run the CLI tool
Returns:		version as TEXT
Author:			G. Cattabriga
Date:			2020.02.12
Description:	returns the version for the specified chemaxon tool in string format 
Notes:				
							
Example:		select load_mol_images((select systemtool_uuid from systemtool where systemtool_name = 'generatemd'), (select actor_uuid from actor where description = 'Gary Cattabriga'));
*/
-- TRUNCATE table load_perov_mol_image cascade;
-- DROP FUNCTION IF EXISTS load_mol_images ( p_systemtool_uuid int8, p_actor_uuid uuid ) cascade;
CREATE OR REPLACE FUNCTION load_mol_images (p_systemtool_uuid uuid, p_actor_uuid uuid)
	RETURNS bool
	AS $$
DECLARE
	pathname varchar := '/Users/gcattabriga/DRP/demob/cp_inventory_run_20200630/chem_images/';
	fullfilename VARCHAR := NULL;
	filename VARCHAR := NULL;
	fcontents varchar := NULL;
	fullpathname varchar := NULL;
	underscorepos int;
BEGIN
	FOR fullfilename IN
	SELECT
		pg_ls_dir(pathname)
	ORDER BY
		1 LOOP
			IF(fullfilename ~ '^.*\.(svg)$') THEN
				fcontents = read_file (pathname || fullfilename);
				fullpathname = pathname || fullfilename;
				underscorepos = POSITION('_' IN fullfilename);
				filename = substring(fullfilename, underscorepos + 1, length(fullfilename) - POSITION('.' IN reverse(fullfilename)) - underscorepos);
				INSERT INTO "load_perov_mol_image"
					values(fullpathname, fullfilename, filename, bytea (fcontents));
			END IF;
		END LOOP;
	RETURN TRUE;
END;
$$
LANGUAGE plpgsql;


/*
Name:			load_edocuments (p_actor_uuid uuid)
Parameters:		p_actor_uuid = identifier (uuid) of the actor owning this edocument
Returns:		boolean T or F
Author:			G. Cattabriga
Date:			2020.04.07
Description:	loads edocuments into the load table 
Notes:				
							
Example:		select load_edocuments((select actor_uuid from actor where description = 'Ian Pendleton'));
*/
-- DROP FUNCTION IF EXISTS load_edocuments (p_actor_uuid uuid) cascade;
CREATE OR REPLACE FUNCTION load_edocuments (p_actor_uuid uuid)
	RETURNS bool
	AS $$
DECLARE
	pathname varchar := '/Users/gcattabriga/Downloads/GitHub/escalate_wip/';
	filename VARCHAR := NULL;
	fullfilename VARCHAR := NULL;
	fullpathname varchar := NULL;
	fcontents varchar := NULL;
BEGIN
	FOR fullfilename IN
	SELECT
		pg_ls_dir(pathname)
	ORDER BY
		1 LOOP
			IF(fullfilename ~ '^.*\.(pdf)$') THEN
				fcontents = pg_read_binary_file(pathname || fullfilename);
				fullpathname = pathname || fullfilename;
				filename = substring(fullfilename, 1, length(fullfilename) - POSITION('.' IN reverse(fullfilename)));
				INSERT INTO load_edocument (description, document_type, edocument, actor_uuid)
					values(filename, 'blob_pdf'::val_type, bytea (fcontents), p_actor_uuid);
			END IF;
		END LOOP;
	RETURN TRUE;
END;
$$
LANGUAGE plpgsql;



/*
Name:			load_csv(_csv varchar, _table varchar)
Parameters:		_csv = string of source filename, full location
				_table = string of destination load_table
Returns:		count of records loaded, or NULL is failed
Author:			G. Cattabriga
Date:			2020.05.15
Description:	loads csv file (_csv) into load table (_table) 
Notes:			assumes a column header row
							drop function if exists load_csv(_csv varchar, _table varchar) cascade;
Example:		select load_csv('/Users/gcattabriga/Downloads/GitHub/ESCALATE_report/iodides/REPORT/iodides.csv', 'load_v2_iodides_temp');
*/
CREATE OR REPLACE FUNCTION load_csv (_csv varchar, _table varchar)
	RETURNS int
	AS $func$
DECLARE
	row_ct int;
BEGIN
	-- create staging table for 1st row as  single text column
	CREATE TEMP TABLE tmp0 (
		cols varchar ) ON COMMIT DROP;
	-- fetch 1st row
	EXECUTE format($$COPY tmp0 FROM PROGRAM 'head -n1 %I' $$, _csv);
	-- create actual temp table with all columns text
	EXECUTE (
		SELECT
			format('CREATE TEMP TABLE %I(', _table) || string_agg(quote_ident(col) || ' text', ',') || ')'
		FROM (
			SELECT
				cols
			FROM
				tmp0
			LIMIT 1) t,
		unnest(string_to_array(t.cols, ',')) col);
	-- Import data
	EXECUTE format($$ COPY % I FROM % L WITH (
			format csv,
			HEADER,
			NULL 'null'
) $$,
		_table,
		_csv
);
	-- get row count
	GET DIAGNOSTICS row_ct = ROW_COUNT;
	RETURN row_ct;
END $func$
LANGUAGE plpgsql;


/*
Name:			load_experiment_json(_jsondir varchar, _exp_type varchar)
Parameters:		_jsondir = directory of experimental json files
				_exp_type = experiment type (e.g. wf1_iodides, wf1_bromides, wf3_alloying, wf3_iodide) 
Returns:		count of records loaded, or NULL is failed
Author:			G. Cattabriga
Date:			2020.07.10
Description:	loads experiment json into load_exp_json table 
Notes:			assumes load_exp_json exists with at least the following columns: uid, exp_type, exp_json, add_date 
Example:		select load_experiment_json ('/Users/gcattabriga/Downloads/GitHub/ESCALATE_report/iodides/', 'wf1_iodides');
*/
CREATE OR REPLACE FUNCTION load_experiment_json (_jsondir varchar, _exp_type varchar)
	RETURNS int
	AS $$
DECLARE
	pathname varchar := _jsondir;  				--'/Users/gcattabriga/escalate_report/TEST_DATA/';
	filename VARCHAR := null;
	uid VARCHAR := null;
	fcontents varchar := null;
	fullpathname varchar := null;
	exp_type varchar := _exp_type;
	row_ct int := 0;
BEGIN
	FOR filename IN select pg_ls_dir(pathname) order by 1 LOOP
		 IF (filename ~ '^.*\.(json)$') THEN
				fcontents = read_file_utf8(pathname||filename);
				fullpathname = pathname || filename;
				uid = left(filename, length(filename) - POSITION('.' in reverse(filename)));
				insert into "load_exp_json" values (exp_type, uid, cast(fcontents as jsonb), CURRENT_TIMESTAMP);
				row_ct := row_ct + 1;
		 END IF;
	 END LOOP;
 	-- get row count
	RETURN row_ct;
END $$
LANGUAGE plpgsql;


DROP TABLE IF EXISTS "dev"."load_exp_json";
CREATE TABLE "dev"."load_exp_json" (
	"exp_type" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "uid" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "exp_json" json,
  "add_dt" timestamptz(6)
);
ALTER TABLE "dev"."load_exp_json" ADD CONSTRAINT "load_exp_json_pkey" PRIMARY KEY ("uid");

select load_experiment_json ('/Users/gcattabriga/Downloads/GitHub/ESCALATE_report/wf1_iodides/', 'wf1_iodides');
select load_experiment_json ('/Users/gcattabriga/Downloads/GitHub/ESCALATE_report/wf1_bromides/', 'wf1_bromides');
select load_experiment_json ('/Users/gcattabriga/Downloads/GitHub/ESCALATE_report/wf3_iodide/', 'wf3_iodide');
select load_experiment_json ('/Users/gcattabriga/Downloads/GitHub/ESCALATE_report/wf3_alloying/', 'wf3_alloying');

DROP TABLE load_temp_materials;
CREATE TABLE load_temp_materials AS
select x2.uid, x2.lab, x2.actor, x2.exp_date, x2.reagent_no, x2.create_date, 
	chemical ->> 'InChIKey' as inchikey, 
	case 
		when (position('null' in chemical ->> 'actual_amount') = 0) 
		then left(chemical ->> 'actual_amount', position(':' in chemical ->> 'actual_amount')-1)::float8 
		else null 
	end as actual_amt,
	case 
		when (position('null' in chemical ->> 'actual_amount') = 0) 
		then right(chemical ->> 'actual_amount', length(chemical ->> 'actual_amount') - position(':' in chemical ->> 'actual_amount'))
		else null 
	end as actual_unit,
	case 
		when (position('null' in chemical ->> 'nominal_amount') = 0) 
		then left(chemical ->> 'nominal_amount', position(':' in chemical ->> 'nominal_amount')-1)::float8 
		else null 
	end as nominal_amt,
	case 
		when (position('null' in chemical ->> 'nominal_amount') = 0) 
		then right(chemical ->> 'nominal_amount', length(chemical ->> 'nominal_amount') - position(':' in chemical ->> 'nominal_amount'))
		else null 
	end as nominal_unit
from
	(select x1.uid, x1.lab, x1.actor,
		replace(replace(substring(x1.uid, 1, length(x1.uid) - POSITION('_' IN reverse(x1.uid))), 'T', ' '), '_', ':')::timestamp AS exp_date, chemicals -> 'id' as reagent_no, 
		case when (chemicals ->> 'date') <> 'null' 
		then to_timestamp((chemicals ->> 'date'),'YYYY-MM-DD hh24:mi:ss')::timestamp 
		else null 
		end as create_date, jsonb_array_elements(x1.chemicals -> 'chemicals') as chemical from
			(select exp_json->'run' ->> 'jobserial' as uid, exp_json->'run' ->> 'lab' as lab, exp_json->'run' ->> 'operator' as actor, 
					jsonb_array_elements(ex.exp_json ->'reagent') as chemicals from load_exp_json ex) x1) x2;


-- materials with parent
select mat.*, act.actor_uuid, vm.material_uuid from load_temp_materials mat 
join 
	(select uid, reagent_no as r_no from load_temp_materials 
	group by uid, reagent_no 
	having count(*) > 1) mc
on mat.uid = mc.uid and mat.reagent_no = mc.r_no
left join vw_material vm 
on mat.inchikey = vm.inchikey
left join vw_actor act 
on mat.actor like act.actor_description
where mat.inchikey <> 'null'
order by 1, 5

-- insert into materials as a parent
insert into material (description, status_uuid)
select mm.uid || ': Reagent ' || mm.reagent_no as reagent_descr, (select status_uuid from vw_status where description = 'active') 
from
	(select mat.*, act.actor_uuid, vm.material_uuid from load_temp_materials mat 
	join 
		(select uid, reagent_no as r_no from load_temp_materials 
		group by uid, reagent_no 
		having count(*) > 1) mc
	on mat.uid = mc.uid and mat.reagent_no = mc.r_no
	left join vw_material vm 
	on mat.inchikey = vm.inchikey
	left join vw_actor act 
	on mat.actor like act.actor_description
	where mat.inchikey <> 'null'
	order by 1, 5) mm
group by mm.uid || ': Reagent ' || mm.reagent_no

-- materials with a parent	
insert into material (description, parent_uuid, status_uuid)
select mxx.inchikey as description, mxx.parent_uuid, mxx.status_uuid from
	(select mx.*, mt.material_uuid as parent_uuid from 
		(select mm.*, mm.uid || ': Reagent ' || mm.reagent_no as reagent_descr, (select status_uuid from vw_status where description = 'active') from
			(select mat.*, act.actor_uuid from load_temp_materials mat 
			join 
				(select uid, reagent_no as r_no from load_temp_materials 
				group by uid, reagent_no 
				having count(*) > 1) mc
			on mat.uid = mc.uid and mat.reagent_no = mc.r_no
			left join vw_actor act 
			on mat.actor like act.actor_description
			where mat.inchikey <> 'null'
			order by 1, 5) mm) mx 
	left join material mt on mx.reagent_descr = mt.description) mxx 
left join vw_material mtt on mxx.inchikey = mtt.inchikey


insert into material (description, parent_uuid, status_uuid)
select mxx.inchikey as description, mxx.parent_uuid, mxx.status_uuid from
	(select mx.*, mt.material_uuid from 
		(select mm.*, mm.uid || ': Reagent ' || mm.reagent_no as reagent_descr, (select status_uuid from vw_status where description = 'active') from
			(select mat.*, act.actor_uuid from load_temp_materials mat 
			join 
				(select uid, reagent_no as r_no from load_temp_materials 
				group by uid, reagent_no 
				having count(*) = 1) mc
			on mat.uid = mc.uid and mat.reagent_no = mc.r_no
			left join vw_actor act 
			on mat.actor like act.actor_description
			where mat.inchikey <> 'null'
			order by 1, 5) mm) mx 
	left join vw_material mt on mx.inchikey = mt.inchikey order by 1, 5) mxx 


-- insert into measure 
insert into measure (measure_type_uuid, description, amount.v_type, amount.v_num, amount.v_unit, unit, actor_uuid)
select distinct (select measure_type_uuid from measure_type where description = 'actual') as measure_type_uuid, mtt.material_uuid,'num'::val_type, mxx.actual_amt, mxx.actual_unit as val_unit, mxx.actual_unit, mxx.actor_uuid from
	(select mx.*, mt.material_uuid as parent_uuid from 
		(select mm.*, mm.uid || ': Reagent ' || mm.reagent_no as reagent_descr, (select status_uuid from vw_status where description = 'active') from
			(select mat.*, act.actor_uuid from load_temp_materials mat 
			join 
				(select uid, reagent_no as r_no from load_temp_materials 
				group by uid, reagent_no 
				having count(*) > 1) mc
			on mat.uid = mc.uid and mat.reagent_no = mc.r_no
			left join vw_actor act 
			on mat.actor like act.actor_description
			where mat.inchikey <> 'null'
			order by 1, 5) mm) mx 
	left join material mt on mx.reagent_descr = mt.description) mxx 
left join vw_material mtt on mxx.inchikey = mtt.inchikey


insert into measure_x (measure_uuid, ref_measure_uuid)
select ms.measure_uuid, mt.material_uuid  from measure ms 
join material mt on ms.description = mt.material_uuid::text


select * from material mat 
right join 
	(select distinct material_uuid from material mat
	where mat.description like '%2017-10-17T16_00_00.000000+00_00_LBL%') mp
on mat.parent_uuid = mp.material_uuid
where mt2.description like '%2017-10-17T16_00_00.000000+00_00_LBL%'


select mt1.material_uuid, mt1.description, mt1.parent_uuid, mt2.status_uuid, *  from material mt1
join material mt2 on mt1.parent_uuid = mt2.material_uuid
where mt2.description like '%2017-10-17T16_00_00.000000+00_00_LBL%'


-- materials with no parent
insert into material (description, parent_uuid, status_uuid)
select mat.*, vm.material_uuid from load_temp_materials mat 
join 
	(select uid, reagent_no as r_no from load_temp_materials 
	group by uid, reagent_no 
	having count(*) = 1) mp
on mat.uid = mp.uid and mat.reagent_no = mp.r_no
left join vw_material vm 
on mat.inchikey = vm.inchikey
where mat.inchikey <> 'null'
order by 1
*/

/*
Name:			load_escalate_experiment()
Parameters:		fname = string of source filename, full location
				tname = string of destination load_table
Returns:		count of records loaded, or NULL is failed
Author:			G. Cattabriga
Date:			2020.06.10
Description:	loads experiment load file (_loadtable) into experiment table 
Notes:			assumes the following columns: _exp_no, _raw_operator, _raw_user_generated_experimentname, _raw_datecreated, _raw_lab, _raw_labwareid, 
				drop function if exists load_experiment(_loadtable) cascade;
Example:		select load_csv('/Users/gcattabriga/Downloads/GitHub/ESCALATE_report/iodides/REPORT/iodides.csv', 'load_v2_iodides_temp');
*/
CREATE OR REPLACE FUNCTION load_escalate_experiments (_loadtable varchar)
	RETURNS int
	AS $$
DECLARE
	row_ct1 int;
	row_ct2 int;
BEGIN
	-- create a temp table so we can reference
	EXECUTE format('CREATE TEMP TABLE ttable ON COMMIT DROP AS SELECT * FROM %I', _loadtable);
	-- load in the [parent] experiments
	INSERT INTO experiment (description, ref_uid, owner_uuid, operator_uuid, lab_uuid, create_date, status_uuid)
SELECT DISTINCT
	CASE _loadtable
	WHEN 'load_v2_bromides' THEN
		'WF1 Bromides'
	WHEN 'load_v2_iodides' THEN
		'WF1 Iodides'
	WHEN 'load_v2_wf3_alloying' THEN
		'WF3 HalideAlloying'
	WHEN 'load_v2_wf3_iodides' THEN
		'WF3 Iodide'
	END AS description,
	ex1._exp AS ref_uid,
	(
		SELECT
			actor_uuid
		FROM
			vw_actor
		WHERE (org_short_name =
		right(ex1._exp, POSITION('_' IN reverse(ex1._exp)) - 1)
		AND systemtool_uuid IS NULL
		AND person_uuid IS NULL)) AS _owner_uuid, (
	SELECT
		actor_uuid
	FROM
		vw_actor
	WHERE (actor_description LIKE '%' ||
	left(ex1._raw_operator, 7) || '%')) AS _operator_uuid, (
	SELECT
		actor_uuid
	FROM
		vw_actor
	WHERE (org_short_name =
	right(ex1._exp, POSITION('_' IN reverse(ex1._exp)) - 1)
	AND systemtool_uuid IS NULL
	AND person_uuid IS NULL)) AS _lab_uuid, replace(replace(substring(ex1._exp, 1, length(ex1._exp) - POSITION('_' IN reverse(ex1._exp))), 'T', ' '), '_', ':')::timestamp AS _exp_date, (
	SELECT
		status_uuid
	FROM
		status
	WHERE
		description = 'active') AS status_uuid
FROM (
	SELECT
		_exp_no,
		substring(_exp_no, 1, length(_exp_no) - POSITION('_' IN reverse(_exp_no))) AS _exp,
		_raw_operator
	FROM
		ttable) ex1;
	-- get row count
	GET DIAGNOSTICS row_ct1 = ROW_COUNT;
	-- load in the [children] experiments
	INSERT INTO experiment (description, ref_uid, parent_uuid, owner_uuid, operator_uuid, lab_uuid, create_date, status_uuid)
SELECT
	CASE _loadtable
	WHEN 'load_v2_bromides' THEN
		'WF1 Bromides'
	WHEN 'load_v2_iodides' THEN
		'WF1 Iodides'
	WHEN 'load_v2_wf3_alloying' THEN
		'WF3 HalideAlloying'
	WHEN 'load_v2_wf3_iodides' THEN
		'WF3 Iodide'
	END AS description,
	ex1._exp_no AS ref_uid,
	(
		SELECT
			experiment_uuid
		FROM
			experiment ex2
		WHERE (ex2.ref_uid = substring(_exp_no, 1, length(_exp_no) - POSITION('_' IN reverse(_exp_no))))) AS parent_uuid, (
		SELECT
			actor_uuid
		FROM
			vw_actor
		WHERE (org_short_name =
		right(ex1._exp, POSITION('_' IN reverse(ex1._exp)) - 1)
		AND systemtool_uuid IS NULL
		AND person_uuid IS NULL)) AS _owner_uuid, (
	SELECT
		actor_uuid
	FROM
		vw_actor
	WHERE (actor_description LIKE '%' ||
	left(ex1._raw_operator, 7) || '%')) AS _operator_uuid, (
	SELECT
		actor_uuid
	FROM
		vw_actor
	WHERE (org_short_name =
	right(ex1._exp, POSITION('_' IN reverse(ex1._exp)) - 1)
	AND systemtool_uuid IS NULL
	AND person_uuid IS NULL)) AS _lab_uuid, replace(replace(substring(ex1._exp, 1, length(ex1._exp) - POSITION('_' IN reverse(ex1._exp))), 'T', ' '), '_', ':')::timestamp AS _exp_date, (
	SELECT
		status_uuid
	FROM
		status
	WHERE
		description = 'active') AS status_uuid
FROM (
	SELECT
		_exp_no,
		substring(_exp_no, 1, length(_exp_no) - POSITION('_' IN reverse(_exp_no))) AS _exp,
		_raw_operator,
		_raw_notes
	FROM
		ttable) ex1;
	-- get row count
	GET DIAGNOSTICS row_ct2 = ROW_COUNT;
	RETURN (row_ct1 + row_ct2);
END
$$
LANGUAGE plpgsql;


select load_escalate_experiments('load_v2_iodides');
select load_escalate_experiments('load_v2_bromides');
select load_escalate_experiments('load_v2_wf3_alloying');
select load_escalate_experiments('load_v2_wf3_iodides');

-- select count(*) from experiment where parent_uuid is null;
-- delete from experiment;
-- select * from load_v2_iodides where "_raw_participantname" is not null
