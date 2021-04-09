-- -- ===========================================================================
-- -- set up actions, parameter defs
-- -- ===========================================================================

insert into vw_calculation_def
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid,
	in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid )
	values ('num_array_index', '[x, y, z], 2 -> y',
		(select systemtool_uuid from vw_actor where systemtool_name = 'escalate'),
		'return numeric from indexed array', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'num'),
		null, (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_parameter_def (description, default_val, actor_uuid, status_uuid)
	values
	    ('volume',
        (select put_val((select get_type_def ('data', 'num')), '0', 'mL')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
    	('duration',
        (select put_val((select get_type_def ('data', 'num')), '0', 'mins')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ('speed',
        (select put_val ((select get_type_def ('data', 'num')),'0','rpm')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ('temperature',
        (select put_val((select get_type_def ('data', 'num')), '0', 'degC')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_parameter_def (description, default_val, actor_uuid, status_uuid)
	values
	    ('mass',
        (select put_val((select get_type_def ('data', 'num')), '0', 'mg')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));


insert into vw_action_def (description, actor_uuid, status_uuid) values
	('dispense', (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test')),
	('heat_stir', (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('heat', (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('start_node', (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('end_node', (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test'));


insert into vw_action_def (description, actor_uuid, status_uuid) values
	('dispense_solid', (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test'));
-- add a note to dispense action indicating that source is the dispensed material
-- and destination is the container
insert into vw_note (notetext, actor_uuid, ref_note_uuid) values
	('source material = material to be dispensed, destination material = plate well',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select action_def_uuid from vw_action_def where description = 'dispense'));

insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid)
	values
		((select action_def_uuid from vw_action_def where description = 'dispense'),
    	(select parameter_def_uuid from vw_parameter_def where description = 'volume')),
		((select action_def_uuid from vw_action_def where description = 'heat_stir'),
    	(select parameter_def_uuid from vw_parameter_def where description = 'duration')),
        ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
        (select parameter_def_uuid from vw_parameter_def where description = 'temperature')),
        ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
        (select parameter_def_uuid from vw_parameter_def where description = 'speed')),
        ((select action_def_uuid from vw_action_def where description = 'heat'),
        (select parameter_def_uuid from vw_parameter_def where description = 'duration')),
        ((select action_def_uuid from vw_action_def where description = 'heat'),
        (select parameter_def_uuid from vw_parameter_def where description = 'temperature'));

insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid)
	values
		((select action_def_uuid from vw_action_def where description = 'dispense_solid'),
    	(select parameter_def_uuid from vw_parameter_def where description = 'mass'));
