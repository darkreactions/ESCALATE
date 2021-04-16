-- CREATE EXPERIMENT
insert into vw_experiment (ref_uid,
                           description,
                           -- experiment_type,
                           parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid)
	values (
		'test_resin_weigh',
		'resin_weighing',
		null,
		(select actor_uuid from vw_actor where description = 'TC'),
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select actor_uuid from vw_actor where description = 'TC'),
		(select status_uuid from vw_status where description = 'dev_test'));

-- CREATE BOM
insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) values
	((select experiment_uuid from vw_experiment where description = 'resin_weighing'),
	'resin weighing Dev Materials',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- ADD materials (and amounts) to BOM
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'resin weighing Dev Materials'),
    'Resin',
	(select inventory_material_uuid from vw_inventory_material where material_description = 'Rare Earth'), -- would be nice to pull all resins in one pass -- perhaps with a note?
	(select put_val((select get_type_def ('data', 'num')), '60.00','mg')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mg')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mg')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'resin weighing Dev Materials'),
    'Resin Plate',
	(select inventory_material_uuid from vw_inventory_material where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));


-- Add workflow
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'weigh resins', -- todo: combine sample prep into one workflow w/ parent actions
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid)
    values (1,
        (select experiment_uuid from vw_experiment where description = 'resin_weighing'),
        (select workflow_uuid from vw_workflow where description = 'weigh resins'));

insert into vw_workflow_action_set (description,
                                    workflow_uuid,
                                    action_def_uuid,
                                    start_date,
                                    end_date,
                                    duration,
                                    repeating,
                                    parameter_def_uuid,
                                    parameter_val_nominal,
                                    calculation_uuid,
                                    source_material_uuid,
                                    destination_material_uuid,
                                    actor_uuid,
                                    status_uuid)
values ('Dispense Resin',
        (select workflow_uuid from vw_workflow where description = 'weigh resins'),
        (select action_def_uuid from vw_action_def where description = 'dispense_solid'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense_solid' and parameter_description = 'mass'),
        array[(select put_val((select get_type_def('data', 'num')), '5', 'mg'))],
        null,
        array [(select bom_material_index_uuid
                    from vw_bom_material_index
                    where description = 'Resin'
                    and bom_uuid = (select bom_uuid from vw_bom where description = 'resin weighing Dev Materials'))
            ],
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A1%' and bom_uuid = (select bom_uuid from vw_bom where description = 'resin weighing Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A2%' and bom_uuid = (select bom_uuid from vw_bom where description = 'resin weighing Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A3%' and bom_uuid = (select bom_uuid from vw_bom where description = 'resin weighing Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A4%' and bom_uuid = (select bom_uuid from vw_bom where description = 'resin weighing Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A5%' and bom_uuid = (select bom_uuid from vw_bom where description = 'resin weighing Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A6%' and bom_uuid = (select bom_uuid from vw_bom where description = 'resin weighing Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%B1%' and bom_uuid = (select bom_uuid from vw_bom where description = 'resin weighing Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%B2%' and bom_uuid = (select bom_uuid from vw_bom where description = 'resin weighing Dev Materials'))],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));
