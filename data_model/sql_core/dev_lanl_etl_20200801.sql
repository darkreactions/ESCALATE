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

select (json_to_recordset(json_val)) from load_lanl_materials_json;





