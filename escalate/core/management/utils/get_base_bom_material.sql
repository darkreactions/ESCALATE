select 
bom_mat_idx.description as base_bom_material_description,
---
bom.description as bom_material_bom_description,
inv_mat.description as bom_material_inventory_material_description,
bom_mat.alloc_amt_val,
bom_mat.used_amt_val,
bom_mat.putback_amt_val,
--
bom_mat_comp_bom_mat.description as bom_composite_material_bom_material_description,
composite.description as bom_composite_material_composite_description,
component.description as bom_composite_material_component_description
from dev.bom_material_index bom_mat_idx
--bom material
left join dev.bom_material bom_mat on (
	bom_mat_idx.bom_material_uuid = bom_mat.bom_material_uuid
)
left join dev.bom bom on (
	bom_mat.bom_uuid = bom.bom_uuid
)
left join dev.inventory_material inv_mat on (
	bom_mat.inventory_material_uuid = inv_mat.inventory_material_uuid
)
--bom composite
left join dev.bom_material_composite bom_mat_comp on (
	bom_mat_idx.bom_material_composite_uuid = bom_mat_comp.bom_material_composite_uuid
)
left join dev.bom_material bom_mat_comp_bom_mat on (
	bom_mat_comp.bom_material_uuid = bom_mat_comp_bom_mat.bom_material_uuid 
)
left join dev.material_composite mat_comp on (
	bom_mat_comp.material_composite_uuid = mat_comp.material_composite_uuid
)
left join dev.material composite on (
	mat_comp.composite_uuid = composite.material_uuid
)
left join dev.material component on (
	mat_comp.component_uuid = component.material_uuid
)
---
;