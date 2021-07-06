select
cdef.calculation_def_uuid,
cdef.description, 
cdef.short_name, 
cdef.calc_definition,
q.parameter_def_descriptions,
cdef_in_source.short_name as in_source__short_name,
tdef_in_type.description as in_type__description,
cdef_in_opt_source.short_name as in_opt_source__short_name,
tdef_in_opt_type.description as in_opt_type__description,
tdef_out_type.description as out_type__description,
sys.systemtool_name as systemtool_name
from 
dev.calculation_def cdef 
left join dev.calculation_def cdef_in_source on (
	cdef.in_source_uuid = cdef_in_source.calculation_def_uuid
) 
left join dev.type_def tdef_in_type on (
	cdef.in_type_uuid = tdef_in_type.type_def_uuid
) 
left join (
	select 
	cdef.calculation_def_uuid,
	string_agg(pdef.description,',') as parameter_def_descriptions from
	dev.calculation_def cdef left join
		dev.calculation_parameter_def_x cpx on (
		cdef.calculation_def_uuid = cpx.calculation_def_uuid
		)
	left join dev.parameter_def pdef on (
		cpx.parameter_def_uuid = pdef.parameter_def_uuid
	)
	group by cdef.calculation_def_uuid
) q on (
	cdef.calculation_def_uuid = q.calculation_def_uuid
)
left join dev.calculation_def cdef_in_opt_source on (
	cdef.calculation_def_uuid = cdef_in_opt_source.in_opt_source_uuid
)
left join dev.type_def tdef_in_opt_type on (
	cdef.in_opt_type_uuid = tdef_in_opt_type.type_def_uuid
) 
left join dev.type_def tdef_out_type on (
	cdef.out_type_uuid = tdef_out_type.type_def_uuid
) 
left join dev.systemtool sys on (
	cdef.systemtool_uuid = sys.systemtool_uuid
)
;