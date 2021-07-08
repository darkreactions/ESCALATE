select
mat.description,
mat.material_class,
mat.consumable,
aa.material_identifier_descriptions,
aa.material_identifier_def_descriptions,
bb.material_type_descriptions
from dev.material mat
left join (
	select 
	mat.material_uuid,
	string_agg(matref.description,'|') as material_identifier_descriptions,
	string_agg(matrefdef.description,'|') as material_identifier_def_descriptions
	from 
	dev.material mat left join 
	dev.material_refname_x matrefx on (
		mat.material_uuid = matrefx.material_uuid
	) 
	left join dev.material_refname matref on (
		matrefx.material_refname_uuid = matref.material_refname_uuid
	)
	left join dev.material_refname_def matrefdef on (
		matref.material_refname_def_uuid = matrefdef.material_refname_def_uuid
	)
	group by mat.material_uuid
) aa on (
mat.material_uuid = aa.material_uuid
)
left join (
	select 
	mat.material_uuid,
	string_agg(mattype.description,'|') as material_type_descriptions from 
	dev.material mat left join 
	dev.material_type_x mattypex on (
		mat.material_uuid = mattypex.material_uuid
	) 
	left join dev.material_type mattype on (
		mattypex.material_type_uuid = mattype.material_type_uuid
	)
	group by mat.material_uuid
) bb on (
mat.material_uuid = bb.material_uuid
) 
;