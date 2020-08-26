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


select jval->'material' as mat from load_lanl_materials_json ex
select jval->'compound' as mat from load_lanl_materials_json ex

-- get the material names
select mat.jval->'name' as m_name from 
	(select json_array_elements(jval->'material') as jval from load_lanl_materials_json) mat
-- get the material types
select mat.jval->'name' as m_name, json_array_elements(jval->'type') as m_type from 
	(select json_array_elements(jval->'material') as jval from load_lanl_materials_json) mat
-- get the material ext references
select mat.jval->'name' as m_name, json_array_elements(jval->'external-ref') as m_ref from 
	(select json_array_elements(jval->'material') as jval from load_lanl_materials_json) mat
-- get the material property
select prop.m_prop->'name' as prop_name from 
	(select mat.jval->'name' as m_name, json_array_elements(jval->'property') as m_prop from 
		(select json_array_elements(jval->'material') as jval from load_lanl_materials_json) mat) prop



	
select com.jval->'name' as compound_name from 
	(select json_array_elements(jval->'compound') as jval from load_lanl_materials_json) com





