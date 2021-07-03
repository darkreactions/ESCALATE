select 
cdef.description, 
cdef.short_name, 
cdef.calc_definition,
-- cpx.parameter_def_uuid as parameter_def_uuid,
'' as parameter_def,
cdef_in_source.short_name as in_source__short_name,
tdef_in_type.description as in_type__description,
cdef_in_opt_source.short_name as in_opt_source__short_name,
tdef_in_opt_type.description as in_opt_type__description,
tdef_out_type.description as out_type__description,
sys.systemtool_name as systemtool_name
from 
dev.calculation_def as cdef 
left join dev.calculation_def as cdef_in_source on (
	cdef.in_source_uuid = cdef_in_source.calculation_def_uuid
) 
left join dev.type_def as tdef_in_type on (
	cdef.in_type_uuid = tdef_in_type.type_def_uuid
) 
-- left join dev.calculation_parameter_def_x as cpx on (
-- 	cdef.calculation_def_uuid = cpx.calculation_def_uuid
-- ) 
left join dev.calculation_def as cdef_in_opt_source on (
	cdef.calculation_def_uuid = cdef_in_opt_source.in_opt_source_uuid
)
left join dev.type_def as tdef_in_opt_type on (
	cdef.in_opt_type_uuid = tdef_in_opt_type.type_def_uuid
) 
left join dev.type_def as tdef_out_type on (
	cdef.out_type_uuid = tdef_out_type.type_def_uuid
) 
left join dev.systemtool as sys on (
	cdef.systemtool_uuid = sys.systemtool_uuid
)
;