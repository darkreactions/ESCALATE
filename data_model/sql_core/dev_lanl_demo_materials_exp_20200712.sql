--===================================================================
/*
Name:			dev_lanl_demo_materials_exp_20200712
Author:			G. Cattabriga
Date:			2020.07.12
Description:	a set of SQL code to test out etl/normalization ideas
Notes:			discrete (non-optimized!) -> run at your own peril <-		
*/
--===================================================================
-- table relationships
-- material -> material_x -> material (reference)
--   this relates material to a 'reference' or 'catalog' material (e.g. based on inchikey)
-- material -> measure_x -> measure
-- we are going to fudge the relationship of materials to experiment through material description; normally this would be through experiment->workflow->action->material


-- materials need to be added enmasse. Here, they are being ingested through a table loop one at a time, first pulling in the parents, then the children; 
-- but normally an API POST/PUT or UI would need to be able to insert 1 or more materials and the 'parent' automatically created. This is a todo for the material view
-- hint: use defined data type: material and allow an array [mat1, mat2, ,mat3] of materials to be inserted and automatically create parent 



-- load material info from experimental json (from escalate_report)
-- this will be part of the etl process and all load tables truly temporary
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
		replace(replace(substring(x1.uid, 1, length(x1.uid) - POSITION('_' IN reverse(x1.uid))), 'T', ' '), '_', ':')::timestamp AS exp_date, chemicals ->> 'id' as reagent_no, 
		case when (chemicals ->> 'date') <> 'null' 
		then to_timestamp((chemicals ->> 'date'),'YYYY-MM-DD hh24:mi:ss')::timestamp 
		else null 
		end as create_date, json_array_elements(x1.chemicals -> 'chemicals') as chemical from
			(select exp_json->'run' ->> 'jobserial' as uid, exp_json->'run' ->> 'lab' as lab, exp_json->'run' ->> 'operator' as actor, 
					json_array_elements(ex.exp_json ->'reagent') as chemicals from load_exp_json ex) x1) x2;


-- peek into the experimental json... 
/*
select *, (json_each(exp_json)).* from load_exp_json;

select k1.exp_type, k1.uid, key as _key, value as _value from (select exp_type, uid, key as pkey, value as pval from load_exp_json, json_each(exp_json) where key = 'run') k1, json_each(pval);

select k1.exp_type, k1.uid, key, value from (select exp_type, uid, key as pkey, value as pval from load_exp_json, json_each(exp_json) where key = 'notes') k1, json_each(pval) where json_each.value::text not in ('""', '"null"');

*/


-- create a view -> vw_material_x that we can use to insert into
-- material, material_x, measure_x, measure
-- where material contains the composite and singletons
-- and material_x relates the material to a 'catalog/reference' material through ref_material_uuid (would normally be inventory)
CREATE OR REPLACE FUNCTION upsert_material_demo ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_mat_uuid uuid;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- incomplete
		DELETE FROM material_x
		WHERE material_x_uuid = OLD.material_x_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		RETURN OLD;
	ELSIF (TG_OP = 'INSERT') THEN
		-- this will be a seperate upsert trigger on vw_measure, but for now... do this first to avoid conflict of materials having >1 measure
		INSERT INTO material (description, parent_uuid, status_uuid)
			VALUES(NEW.description, NEW.parent_uuid, NEW.status_uuid)
		ON CONFLICT ON CONSTRAINT un_material DO NOTHING
			returning material_uuid into _mat_uuid;
		IF NEW.ref_material_uuid is not null and _mat_uuid is not null then 
			INSERT INTO material_x (material_uuid, ref_material_uuid)
				VALUES(_mat_uuid, NEW.ref_material_uuid)
			ON CONFLICT ON CONSTRAINT un_material_x DO NOTHING;
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;



-- measure_x, measure
CREATE OR REPLACE FUNCTION upsert_measure_demo ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_meas_uuid uuid;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- incomplete
		DELETE FROM measure_x
		WHERE measure_x_uuid = OLD.measure_x_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		RETURN OLD;
	ELSIF (TG_OP = 'INSERT') THEN
		-- this will be a seperate upsert trigger on vw_measure, but for now... do this first to avoid conflict of materials having >1 measure
		IF (NEW.amount).v_type is not null THEN
		INSERT INTO measure (description, measure_type_uuid, amount, unit, actor_uuid)
			VALUES(NEW.description, NEW.measure_type_uuid, NEW.amount, NEW.unit, NEW.actor_uuid) returning measure_uuid into _meas_uuid;
		INSERT INTO measure_x (ref_measure_uuid, measure_uuid)
			select mt.material_uuid, _meas_uuid from (SELECT distinct material_uuid from material mat where NEW.description = mat.description and /*NEW.parent_uuid = parent_uuid and */NEW.status_uuid = status_uuid) mt;
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;




----------------------------------------
-- get materials, material_x, measure_x, measure
-- DROP VIEW vw_material_demo
----------------------------------------
CREATE OR REPLACE VIEW vw_material_demo AS
SELECT
	mat.material_uuid,
	mat.description,
	mat.parent_uuid,
	mat.status_uuid,
	mat.add_date,
	mat.mod_date,
	mtx.material_x_uuid,
	mtx.ref_material_uuid,
	mtx.material_uuid as material_x_material_uuid,
	ms.measure_uuid,
	ms.measure_type_uuid,
	ms.description as measure_description,
	ms.amount,
	ms.unit,
	ms.actor_uuid,
	msx.measure_x_uuid,
	msx.ref_measure_uuid,
	msx.measure_uuid as measure_x_measure_uuid
FROM
	material mat
LEFT JOIN material_x mtx ON mat.material_uuid = mtx.material_uuid
LEFT JOIN measure_x msx on mat.material_uuid = msx.ref_measure_uuid
LEFT JOIN measure ms ON msx.measure_uuid = ms.measure_uuid;

DROP TRIGGER IF EXISTS trigger_material_demo_upsert ON vw_material_demo;
CREATE TRIGGER trigger_material_demo_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_material_demo
FOR EACH ROW
EXECUTE PROCEDURE upsert_material_demo ( );


----------------------------------------
-- get materials, material_x, measure_x, measure
-- DROP VIEW vw_material_demo
----------------------------------------
CREATE OR REPLACE VIEW vw_measure_demo AS
SELECT
	mat.material_uuid,
	mat.description,
	mat.parent_uuid,
	mat.status_uuid,
	mat.add_date,
	mat.mod_date,
	mtx.material_x_uuid,
	mtx.ref_material_uuid,
	mtx.material_uuid as material_x_material_uuid,
	ms.measure_uuid,
	ms.measure_type_uuid,
	ms.description as measure_description,
	ms.amount,
	ms.unit,
	ms.actor_uuid,
	msx.measure_x_uuid,
	msx.ref_measure_uuid,
	msx.measure_uuid as measure_x_measure_uuid
FROM
	material mat
LEFT JOIN material_x mtx ON mat.material_uuid = mtx.material_uuid
LEFT JOIN measure_x msx on mat.material_uuid = msx.ref_measure_uuid
LEFT JOIN measure ms ON msx.measure_uuid = ms.measure_uuid;

DROP TRIGGER IF EXISTS trigger_measure_demo_upsert ON vw_measure_demo;
CREATE TRIGGER trigger_measure_demo_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_measure_demo
FOR EACH ROW
EXECUTE PROCEDURE upsert_measure_demo ( );


	
-- set up 3 passes of the data to gather:
-- 1) composite (reagent) material -> parent
-- 2) the composite materials -> children
-- 3) singleton materials (no parent, no children) 
-- will eventually use vw_material insert when completed ala exp-flow-act-mat-mea
-- for this demo using description as means to join exp (ugh)	

-- 1) insert into parent (reagent) materials - no measures
insert into vw_material_demo (description, status_uuid)
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
	on (act.actor_description like '%' || mat.actor || '%')
	where mat.inchikey <> 'null'
	) mm
group by mm.uid || ': Reagent ' || mm.reagent_no;


-- 2) insert child materials, measures
insert into vw_material_demo (description, parent_uuid, status_uuid, ref_material_uuid, actor_uuid, measure_type_uuid, amount.v_type, amount.v_num, amount.v_unit, unit)
select mtt.description as description, mxx.parent_uuid, mxx.status_uuid, mtt.material_uuid as ref_material_uuid, mxx.actor_uuid, 
		(select measure_type_uuid from measure_type where description = mzz.m_type) as measure_type_uuid, 'num'::val_type, mzz.amt as val_amt, mzz.unit as val_unit, mzz.unit from
	(select mx.*, mt.material_uuid as parent_uuid from 
		(select mm.*, mm.uid || ': Reagent ' || mm.reagent_no as reagent_descr, (select status_uuid from vw_status where description = 'active') from
			(select mat.*, act.actor_uuid from load_temp_materials mat 
			join 
				(select uid, reagent_no as r_no from load_temp_materials 
				group by uid, reagent_no 
				having count(*) > 1) mc
			on mat.uid = mc.uid and mat.reagent_no = mc.r_no
			left join vw_actor act 
			on (act.actor_description like '%' || mat.actor || '%')
			where mat.inchikey <> 'null'
			) mm) mx 
	left join material mt on mx.reagent_descr = mt.description) mxx 
left join vw_material mtt on mxx.inchikey = mtt.inchikey
cross join lateral (
			VALUES
			('actual', actual_amt, actual_unit),
			('nominal', nominal_amt, nominal_unit))
			as mzz(m_type, amt, unit);

insert into vw_measure_demo (description, parent_uuid, status_uuid, ref_material_uuid, actor_uuid, measure_type_uuid, amount.v_type, amount.v_num, amount.v_unit, unit)
select mtt.description as description, mxx.parent_uuid, mxx.status_uuid, mtt.material_uuid as ref_material_uuid, mxx.actor_uuid, 
		(select measure_type_uuid from measure_type where description = mzz.m_type) as measure_type_uuid, 'num'::val_type, mzz.amt as val_amt, mzz.unit as val_unit, mzz.unit from
	(select mx.*, mt.material_uuid as parent_uuid from 
		(select mm.*, mm.uid || ': Reagent ' || mm.reagent_no as reagent_descr, (select status_uuid from vw_status where description = 'active') from
			(select mat.*, act.actor_uuid from load_temp_materials mat 
			join 
				(select uid, reagent_no as r_no from load_temp_materials 
				group by uid, reagent_no 
				having count(*) > 1) mc
			on mat.uid = mc.uid and mat.reagent_no = mc.r_no
			left join vw_actor act 
			on (act.actor_description like '%' || mat.actor || '%')
			where mat.inchikey <> 'null'
			) mm) mx 
	left join material mt on mx.reagent_descr = mt.description) mxx 
left join vw_material mtt on mxx.inchikey = mtt.inchikey
cross join lateral (
			VALUES
			('actual', actual_amt, actual_unit),
			('nominal', nominal_amt, nominal_unit))
			as mzz(m_type, amt, unit);

-- 3) insert materials, measures with no parents	
insert into vw_material_demo (description, status_uuid, ref_material_uuid)
select mxx.reagent_descr as description, /* mxx.parent_uuid, */mxx.status_uuid, mtt.material_uuid as ref_material_uuid 
	from
	(select mx.*, mt.material_uuid as parent_uuid from 
		(select mm.*, mm.uid || ': Reagent ' || mm.reagent_no as reagent_descr, (select status_uuid from vw_status where description = 'active') from
			(select mat.*, act.actor_uuid from load_temp_materials mat 
			join 
				(select uid, reagent_no as r_no from load_temp_materials 
				group by uid, reagent_no 
				having count(*) = 1) mc
			on mat.uid = mc.uid and mat.reagent_no = mc.r_no
			left join vw_actor act 
			on (act.actor_description like '%' || mat.actor || '%')
			where mat.inchikey <> 'null'
			) mm) mx 
	left join material mt on mx.reagent_descr = mt.description) mxx 
left join vw_material mtt on mxx.inchikey = mtt.inchikey;


insert into vw_measure_demo (description, parent_uuid, status_uuid, ref_material_uuid, actor_uuid, measure_type_uuid, amount.v_type, amount.v_num, amount.v_unit, unit)
select mxx.reagent_descr as description, mxx.parent_uuid, mxx.status_uuid, mtt.material_uuid as ref_material_uuid, mxx.actor_uuid, 
		(select measure_type_uuid from measure_type where description = mzz.m_type) as measure_type_uuid, 'num'::val_type, mzz.amt as val_amt, mzz.unit as val_unit, mzz.unit from
	(select mx.*, mt.material_uuid as parent_uuid from 
		(select mm.*, mm.uid || ': Reagent ' || mm.reagent_no as reagent_descr, (select status_uuid from vw_status where description = 'active') from
			(select mat.*, act.actor_uuid from load_temp_materials mat 
			join 
				(select uid, reagent_no as r_no from load_temp_materials 
				group by uid, reagent_no 
				having count(*) = 1) mc
			on mat.uid = mc.uid and mat.reagent_no = mc.r_no
			left join vw_actor act 
			on (act.actor_description like '%' || mat.actor || '%')
			where mat.inchikey <> 'null'
			) mm) mx 
	left join material mt on mx.reagent_descr = mt.description) mxx 
left join vw_material mtt on mxx.inchikey = mtt.inchikey
cross join lateral (
			VALUES
			('actual', actual_amt, actual_unit),
			('nominal', nominal_amt, nominal_unit))
			as mzz(m_type, amt, unit);


-- example query that pulls the materials for a specific experiment (based on description not relationship to experiment table)
select reagent_uuid, reagent_name, material_uuid, material_description, inchikey, chemical_name, molecular_formula, /*get_val (ms.amount), ms.unit,*/
	max(case when mt.description = 'nominal' then get_val (ms.amount) end) as nominal_val,
	max(ms.unit) as nominal_unit,	
	max(case when mt.description = 'actual' then get_val (ms.amount) end) as actual_val,
	max(ms.unit) as actual_unit
	from 
	(select mp.material_uuid as reagent_uuid, mp.description as reagent_name, mc.material_uuid as material_uuid, vm.description as material_description, vm.inchikey, vm.chemical_name, vm.molecular_formula
		from material mp
	left join material mc on mc.parent_uuid = mp.material_uuid
	left join material_x mtx on mc.material_uuid = mtx.material_uuid
	left join vw_material vm on mtx.ref_material_uuid = vm.material_uuid
	where mc.material_uuid is not null
	union
	-- singletons
	select mp.material_uuid as reagent_uuid, mp.description as reagent_name,  mp.material_uuid as material_uuid, vm.description as material_description, vm.inchikey, vm.chemical_name, vm.molecular_formula
		from material mp
	left join material mc on mc.parent_uuid = mp.material_uuid
	left join material_x mtx on mp.material_uuid = mtx.material_uuid
	left join vw_material vm on mtx.ref_material_uuid = vm.material_uuid
	where mc.material_uuid is null) rx
	left join measure_x mx on rx.material_uuid = mx.ref_measure_uuid
	left join measure ms on mx.measure_uuid = ms.measure_uuid
	left join measure_type mt on ms.measure_type_uuid = mt.measure_type_uuid
where rx.reagent_name like '2017-10-16T17_52_59.000000+00_00_LBL%'
group by reagent_uuid, reagent_name, material_uuid, material_description, inchikey, chemical_name, molecular_formula
order by reagent_name, material_description;
 
	



-- count 'em up
select count(*) from material
select count(*) from material_x
select count(*) from measure
select count(*) from measure_x




