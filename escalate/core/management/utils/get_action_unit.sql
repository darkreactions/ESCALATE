select
act.description as action_description,
wf.description as action_wrokflow_description,
bom_mat_idx_source.description as source_material_description,
-- source_bom_mat.description as source_material_bom_material_description,
source_bom_mat_bom.description as source_material_bom_description,

bom_mat_idx_dest.description as destination_material_description,
-- dest_bom_mat.description as destination_material_bom_material_description,
dest_bom_mat_bom.description as destination_material_bom_description
from
dev.action act
left join dev.workflow wf on (
	act.workflow_uuid = wf.workflow_uuid
)
--------------
left join dev.bom_material_index bom_mat_idx_source on (
	act.source_material_uuid = bom_mat_idx_source.bom_material_index_uuid
)
left join dev.bom_material source_bom_mat on (
	bom_mat_idx_source.bom_material_uuid = source_bom_mat.bom_material_uuid
)
-- left join dev.bom_material_composite source_bom_mat_comp on (
-- 	bom_mat_idx_source.bom_material_composite_uuid = source_bom_mat_comp.bom_material_composite_uuid
-- )
-- left join dev.bom_material source_bom_mat on (
-- 	source_bom_mat_comp.bom_material_uuid = source_bom_mat.bom_material_uuid
-- )
left join dev.bom source_bom_mat_bom on (
	source_bom_mat.bom_uuid = source_bom_mat_bom.bom_uuid
)
------------
left join dev.bom_material_index bom_mat_idx_dest on (
	act.destination_material_uuid = bom_mat_idx_dest.bom_material_index_uuid
)
left join dev.bom_material dest_bom_mat on (
	bom_mat_idx_dest.bom_material_uuid = dest_bom_mat.bom_material_uuid
)
-- left join dev.bom_material_composite dest_bom_mat_comp on (
-- 	bom_mat_idx_dest.bom_material_composite_uuid = dest_bom_mat_comp.bom_material_composite_uuid
-- )
-- left join dev.bom_material dest_bom_mat on (
-- 	dest_bom_mat_comp.bom_material_uuid = dest_bom_mat.bom_material_uuid
-- )
left join dev.bom dest_bom_mat_bom on (
	dest_bom_mat.bom_uuid = dest_bom_mat_bom.bom_uuid
)
;