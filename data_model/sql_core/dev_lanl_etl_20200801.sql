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
select load_json('/Users/gcattabriga/Downloads/GitHub/escalate_wip/lanl_material_example_20200814.json', 'load_lanl_materials_json');


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

drop view vw_materials_json;
drop view vw_material_json;
drop view vw_material_ref_prop_json;
create view vw_materials_json as 
	SELECT
  		jval->'material' AS material,
  		jval->'compound' as compound
 	FROM load_lanl_materials_json;

create view vw_material_json as 
	SELECT
  		mat->>'name' AS material_name,
  		mat->>'type' AS material_type,
   		mat->'vendor_information' AS material_vendor_info, 	
   		mat->'vendor_information'->>'SKU' AS material_vendor_sku,
   		mat->'vendor_information'->>'vendor' AS material_vendor_name,  	   			
  		mat->'material_ref' AS material_ext_ref,
   		mat->'property' AS material_property  		
 	FROM vw_materials_json, json_array_elements(material) mat;


create view vw_material_ref_json as 
	SELECT
		mat.*,
		ref->>'inchikey' as inchikey,
		ref->>'InChI' as inchi
		,(select array_agg(property_name) from (select json_extract_path_text(json_array_elements(material_property), 'name') as property_name from vw_material_ref_json) prop) as property_name
 	FROM vw_material_json mat, json_array_elements(material_ext_ref) ref;


create view vw_material_ref_prop_json as 
	SELECT
		material_name,
		prop->>'name' as property_name
 	FROM vw_material_ref_json ref, json_array_elements(material_property) prop;


select * from vw_materials_json;
select * from vw_material_json;
select * from vw_material_ref_json;
select array_agg(property_name) from (select json_extract_path_text(json_array_elements(material_property), 'name') as property_name from vw_material_ref_json) prop

select mat->>'name' as material_name 
from vw_materials_json, json_array_elements(material) mat
left join select json_extract_path_text(json_array_elements(material_type), 'name') as property_name from vw_materials_json, json_array_elements(material) mat;

select json_extract_path_text(json_array_elements(material_property), 'name') as property_name from vw_material_ref_json
select json_extract_path_text(json_array_elements(material_property), 'name') as property_name from vw_material_ref_json
