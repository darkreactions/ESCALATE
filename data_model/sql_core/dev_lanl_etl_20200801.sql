--===================================================================
/*
Name:			dev_lanl_etl_20200801
Author:			G. Cattabriga
Date:			2020.08.01
Description:	a set of SQL code to test out etl/normalization ideas
Notes:			discrete (non-optimized!) -> run at your own peril <-		
*/
--===================================================================

-- load material json into load table
select load_json('/Users/gcattabriga/Downloads/GitHub/escalate_wip/lanl_material_example_20200729.json', 'load_lanl_materials_json');

select *, (json_each(json_val)).* from load_lanl_materials_json;

SELECT json_val::json->'materials' as prop FROM load_lanl_materials_json;


select key as _key, value as _value from (select key as pkey, value as pval from load_lanl_materials_json, json_each(json_val) where key = 'properties') k1, json_each(pval);

select k1.exp_type, k1.uid, key, value from (select exp_type, uid, key as pkey, value as pval from load_exp_json, json_each(exp_json) where key = 'notes') k1, json_each(pval) where json_each.value::text not in ('""', '"null"');




select json_build_object
