
-- these are all the raw materials we need to get started!
select * from vw_material where description in ('Gamma-Butyrolactone', 'Formic Acid', 'Lead Diiodide', 'Ethylammonium Iodide');

insert into vw_action_def (description) values ('bring_to_temperature');
insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid) values
(
 (select action_def_uuid from vw_action_def where description = 'bring_to_temperature'),
 (select parameter_def_uuid from vw_parameter_def where description='temperature')
);

insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'HC Test Inventory'),
				'Lead Diiodide',
				(select material_uuid from vw_material where description = 'Lead Diiodide')
				);

insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'HC Test Inventory'),
				'Ethylammonium Iodide',
				(select material_uuid from vw_material where description = 'Ethylammonium Iodide')
				);

insert into vw_material (description) values ('Tube: 5mL'); -- for mixing stocks
insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'HC Test Inventory'),
				'Tube: 5mL',
				(select material_uuid from vw_material where description = 'Tube: 5mL')
				);

insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'HC Test Inventory'),
				'Plate: 96 Well',
				(select material_uuid from vw_material where description = 'Plate: 96 Well')
				);



insert into vw_experiment (ref_uid,
                           description,
                           -- experiment_type,
                           parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid)
	values (
		'perovskite_demo', 'perovskite_demo',
	    --(select experiment_type_uuid from vw_experiment_type where description = 'template'),
		null,
		(select actor_uuid from vw_actor where description = 'HC'),
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select actor_uuid from vw_actor where description = 'HC'),
		(select status_uuid from vw_status where description = 'dev_test'));


insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) values
	((select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
	'Perovskite Demo Materials',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- then add materials to BOM
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Perovskite Demo Materials'),
    'Acid',
	(select inventory_material_uuid from vw_inventory_material where description = 'Stock FAH'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Perovskite Demo Materials'),
    'Solvent',
	(select inventory_material_uuid from vw_inventory_material where description = 'Neat GBL'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Perovskite Demo Materials'),
    'Organic',
	(select inventory_material_uuid from vw_inventory_material where description = 'Ethylammonium Iodide'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Perovskite Demo Materials'),
    'Inorganic',
	(select inventory_material_uuid from vw_inventory_material where description = 'Lead Diiodide'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Perovskite Demo Materials'),
    'Plate',
	(select inventory_material_uuid from vw_inventory_material where description = 'Wf1 Plate')); -- todo: replace with 96 well
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Perovskite Demo Materials'),
    'Stock A Vial',
	(select inventory_material_uuid from vw_inventory_material where description = 'Tube: 5mL'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Perovskite Demo Materials'),
    'Stock B Vial',
	(select inventory_material_uuid from vw_inventory_material where description = 'Tube: 5mL'));


insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Preheat Plate',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Prepare Stock A',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Prepare Stock B',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
		((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Dispense Solvent',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
		((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Dispense Stock A',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Dispense Stock B',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Dispense Acid Vol 1',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Heat Stir 1',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Dispense Acid Vol 2',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Heat Stir 2',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Perovskite Demo: Heat',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid)
    values
        (1,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Preheat Plate')),
        (2,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A')),
        (3,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock B')),
        (4,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Solvent')),
        (5,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Stock A')),
        (6,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Stock B')),
        (7,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Acid Vol 1')),
        (8,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat Stir 1')),
        (9,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Acid Vol 2')),
        (10,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat Stir 2')),
        (11,
        (select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat'));


insert into vw_calculation_def (short_name, description, calc_definition) values
(
    'sampleSolvent',
    'Null calculation: dispense solvent into samples',
    'null'
),
(
    'sampleStockA',
    'Null calculation: dispense stock A into samples',
    'null'
),
(
    'sampleStockB',
    'Null calculation: dispense stock B into samples',
    'null'
),
(
    'sampleAcid1',
    'Null calculation: dispense Acid 1 into samples',
    'null'
),
(
    'sampleAcid2',
    'Null calculation: dispense Acid 2 into samples',
    'null'
);


insert into vw_parameter_def (description, default_val) values
(
    'Sample Solvent Volume',
     (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY[96]))::text, 'mL'))
),
('Sample Stock A Volume',
 (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY [96]))::text, 'mL'))
),
(
    'Sample Stock B Volume',
     (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY[96]))::text, 'mL'))
),
(
    'Sample Acid Volume 1',
     (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY[96]))::text, 'mL'))
),
(
    'Sample Acid Volume 2',
     (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY[96]))::text, 'mL'))
);

insert into vw_calculation_parameter_def (calculation_def_uuid, parameter_def_uuid) values
(
    (select calculation_def_uuid
     from vw_calculation_def
     where short_name = 'sampleSolvent'),
    (select parameter_def_uuid
     from vw_parameter_def
     where description = 'Sample Solvent Volume')
),
(
    (select calculation_def_uuid
     from vw_calculation_def
     where short_name = 'sampleStockA'),
    (select parameter_def_uuid
     from vw_parameter_def
     where description = 'Sample Stock A Volume')
),
(
    (select calculation_def_uuid
     from vw_calculation_def
     where short_name = 'sampleStockB'),
    (select parameter_def_uuid
     from vw_parameter_def
     where description = 'Sample Stock B Volume')
),
(
    (select calculation_def_uuid
     from vw_calculation_def
     where short_name = 'sampleAcid1'),
    (select parameter_def_uuid
     from vw_parameter_def
     where description = 'Sample Acid Volume 1')
),
(
    (select calculation_def_uuid
     from vw_calculation_def
     where short_name = 'sampleAcid2'),
    (select parameter_def_uuid
     from vw_parameter_def
     where description = 'Sample Acid Volume 2')
);



insert into vw_calculation (calculation_def_uuid, calculation_alias_name,out_val) values
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'sampleSolvent'),
    'sampleSolvent',
    (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY[96]))::text, 'mL'))

),
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'sampleStockA'),
    'sampleStockA',
    (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY[96]))::text, 'mL'))

),
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'sampleStockB'),
    'sampleStockB',
    (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY[96]))::text, 'mL'))

),
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'sampleAcid1'),
    'sampleAcid1',
    (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY[96]))::text, 'mL'))

),
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'sampleAcid2'),
    'sampleAcid2',
    (select put_val(get_type_def('data', 'array_num'), (select array_fill(0., ARRAY[96]))::text, 'mL'))

);


-- dispense workflow action sets
-- delete from vw_workflow_action_set where description = 'Perovskite Demo: Dispense Solvent';
insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Perovskite Demo: Dispense Solvent',
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Solvent'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        --array [(select put_val(get_type_def('data', 'num'),'0', 'mL'))],
        null,
        (select calculation_uuid from vw_calculation where calculation_alias_name = 'sampleSolvent'),
        --null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Solvent'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo'))], -- this has to come from bom_material_index...
        (select array(
            (select bom_material_index_uuid from vw_bom_material_index where
                description similar to '%Plate well%'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')
            )
        )),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Stock A',
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Stock A'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        --array [(select put_val(get_type_def('data', 'num'),'0', 'mL'))],
        null,
        (select calculation_uuid from vw_calculation where calculation_alias_name = 'sampleStockA'),
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Stock A Vial'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo'))], -- this has to come from bom_material_index...
        (select array(
            (select bom_material_index_uuid from vw_bom_material_index where
                description similar to '%Plate well%'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')
            )
        )),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Stock B',
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Stock B'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        --array [(select put_val(get_type_def('data', 'num'),'0', 'mL'))],
        null,
        (select calculation_uuid from vw_calculation where calculation_alias_name = 'sampleStockB'),
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Stock B Vial'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo'))], -- this has to come from bom_material_index...
        (select array(
            (select bom_material_index_uuid from vw_bom_material_index where
                description similar to '%Plate well%'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')
            )
        )),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));


insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Acid Vol 1',
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Acid Vol 1'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        --array [(select put_val(get_type_def('data', 'num'),'0', 'mL'))],
        null,
        (select calculation_uuid from vw_calculation where calculation_alias_name = 'sampleAcid1'),
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Acid'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo'))], -- this has to come from bom_material_index...
        (select array(
            (select bom_material_index_uuid from vw_bom_material_index where
                description similar to '%Plate well%'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')
            )
        )),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));


insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Acid Vol 2',
        (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Dispense Acid Vol 2'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        --array [(select put_val(get_type_def('data', 'num'),'0', 'mL'))],
        null,
        (select calculation_uuid from vw_calculation where calculation_alias_name = 'sampleAcid2'),
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Acid'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo'))], -- this has to come from bom_material_index...
        (select array(
            (select bom_material_index_uuid from vw_bom_material_index where
                description similar to '%Plate well%'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')
            )
        )),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));


-- Stock A
insert into vw_action (action_def_uuid, workflow_uuid, action_description,
                       source_material_uuid,
                       destination_material_uuid,
                       actor_uuid, status_uuid)
	values (

    	(select action_def_uuid from vw_action_def where description = 'dispense'),
    	(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A'),
        'Perovskite Demo: Add Solvent to Stock A',
	    (select bom_material_index_uuid from vw_bom_material_index where description = 'Solvent'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
	    (select bom_material_index_uuid from vw_bom_material_index where description = 'Stock A Vial'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test')),

	    ((select action_def_uuid from vw_action_def where description = 'dispense_solid'),
    	(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A'),
        'Perovskite Demo: Add Organic to Stock A',
	    (select bom_material_index_uuid from vw_bom_material_index where description = 'Organic'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
	    (select bom_material_index_uuid from vw_bom_material_index where description = 'Stock A Vial'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test')),

	    ((select action_def_uuid from vw_action_def where description = 'dispense_solid'),
    	(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A'),
        'Perovskite Demo: Add Inorganic to Stock A',
	     (select bom_material_index_uuid from vw_bom_material_index where description = 'Inorganic'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
	    (select bom_material_index_uuid from vw_bom_material_index where description = 'Stock A Vial'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test')),
        ((select action_def_uuid from vw_action_def where description = 'dispense'),
    	(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock B'),
        'Perovskite Demo: Add Solvent to Stock B',
	    (select bom_material_index_uuid from vw_bom_material_index where description = 'Solvent'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
	    (select bom_material_index_uuid from vw_bom_material_index where description = 'Stock B Vial'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test')),

        ((select action_def_uuid from vw_action_def where description = 'dispense_solid'),
    	(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock B'),
        'Perovskite Demo: Add Organic to Stock B',
	    (select bom_material_index_uuid from vw_bom_material_index where description = 'Organic'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
	    (select bom_material_index_uuid from vw_bom_material_index where description = 'Stock B Vial'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A'),
		(select action_uuid from vw_action where action_description = 'Perovskite Demo: Add Solvent to Stock A')),
	    (
	    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A'),
		(select action_uuid from vw_action where action_description = 'Perovskite Demo: Add Organic to Stock A')),
	    (
	    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A'),
		(select action_uuid from vw_action where action_description = 'Perovskite Demo: Add Inorganic to Stock A'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Perovskite Demo: Add Solvent to Stock A')),
        null,
        (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Perovskite Demo: Add Organic to Stock A')),
		(select workflow_step_uuid from vw_workflow_step where workflow_object_uuid =
		    (select workflow_object_uuid from vw_workflow_object where
		        object_type = 'action'
		        and object_description = 'Perovskite Demo: Add Solvent to Stock A')),
        (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock A'),
		(select workflow_object_uuid
		from vw_workflow_object
		where object_type = 'action'
		and object_description = 'Perovskite Demo: Add Inorganic'),
		(select workflow_step_uuid
		from vw_workflow_step
		where workflow_object_uuid =
		      (select workflow_object_uuid
		       from vw_workflow_object
		       where
		       object_type = 'action'
		       and object_description = 'Perovskite Demo: Add Organic to Stock A')),
        (select status_uuid from vw_status where description = 'dev_test'));

-- Stock B
insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock B'),
		(select action_uuid from vw_action where action_description = 'Perovskite Demo: Add Solvent to Stock B')),
	    (
	    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock B'),
		(select action_uuid from vw_action where action_description = 'Perovskite Demo: Add Organic to Stock B'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock B'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Perovskite Demo: Add Solvent to Stock B')),
        null,
        (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Prepare Stock B'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Perovskite Demo: Add Organic to Stock B')),
		(select workflow_step_uuid from vw_workflow_step where workflow_object_uuid = (select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Perovskite Demo: Add Solvent to Stock B'))),
        (select status_uuid from vw_status where description = 'dev_test'));


-- heat and heat stirs
insert into vw_action (action_def_uuid, workflow_uuid, action_description,
                       source_material_uuid,
                       destination_material_uuid,
                       actor_uuid, status_uuid) values
    ((select action_def_uuid from vw_action_def where description = 'bring_to_temperature'),
    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Preheat Plate'),
    'Perovskite Demo: Preheat Plate',
	(select bom_material_index_uuid from vw_bom_material_index where description = 'Plate'
        and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
	(select bom_material_index_uuid from vw_bom_material_index where description = 'Plate'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
    (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test')),

    ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat Stir 1'),
    'Perovskite Demo: Heat Stir 1',
	(select bom_material_index_uuid from vw_bom_material_index where description = 'Plate'
        and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
	(select bom_material_index_uuid from vw_bom_material_index where description = 'Plate'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
    (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat Stir 2'),
    'Perovskite Demo: Heat Stir 2',
	(select bom_material_index_uuid from vw_bom_material_index where description = 'Plate'
        and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
	(select bom_material_index_uuid from vw_bom_material_index where description = 'Plate'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
    (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ((select action_def_uuid from vw_action_def where description = 'heat'),
    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat'),
    'Perovskite Demo: Heat',
	(select bom_material_index_uuid from vw_bom_material_index where description = 'Plate'
        and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
	(select bom_material_index_uuid from vw_bom_material_index where description = 'Plate'
                and bom_uuid =
                    (select bom_uuid from vw_bom where experiment_description = 'perovskite_demo')),
    (select actor_uuid from vw_actor where description = 'Mike Tynes'),
    (select status_uuid from vw_status where description = 'dev_test'));


insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Preheat Plate'),
		(select action_uuid from vw_action where action_description = 'Perovskite Demo: Preheat Plate')),
	    (
	    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat Stir 1'),
		(select action_uuid from vw_action where action_description = 'Perovskite Demo: Heat Stir 1')),
	    (
	    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat Stir 2'),
		(select action_uuid from vw_action where action_description = 'Perovskite Demo: Heat Stir 2')),
	    (
	    (select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat'),
		(select action_uuid from vw_action where action_description = 'Perovskite Demo: Heat'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values
	(
		(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Preheat Plate'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Perovskite Demo: Preheat Plate')),
        null,
        (select status_uuid from vw_status where description = 'dev_test')
    ),
    (
		(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat Stir 1'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Perovskite Demo: Heat Stir 1')),
        null,
        (select status_uuid from vw_status where description = 'dev_test')
    ),
    (
		(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat Stir 2'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Perovskite Demo: Heat Stir 2')),
        null,
        (select status_uuid from vw_status where description = 'dev_test')
    ),
    (
		(select workflow_uuid from vw_workflow where description = 'Perovskite Demo: Heat'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Perovskite Demo: Heat')),
        null,
        (select status_uuid from vw_status where description = 'dev_test')
    );
-- select experiment_copy ((select experiment_uuid from vw_experiment where description = 'perovskite_demo'),
--                         'perov_instance_1');


-- heat and heat stirs we dont do these as wafss because waffs cant handle multi-parameter actions :shrug:
-- i wonder if it makes more sense to just have a 'set heat'...
-- insert into vw_action (action_def_uuid, workflow_uuid, action_description, actor_uuid, status_uuid)
-- 	values (
--     	(select action_def_uuid from vw_action_def where description = 'heat_stir'),
--     	(select workflow_uuid from vw_workflow where description = 'Heat Stir 1'),
--         'Heat Stir 1',
--         (select actor_uuid from vw_actor where description = 'Mike Tynes'),
--         (select status_uuid from vw_status where description = 'dev_test'));
-- insert into vw_workflow_object (workflow_uuid, action_uuid)
-- 	values (
-- 	    (select workflow_uuid from vw_workflow where description = 'Heat Stir 1'),
-- 		(select action_uuid from vw_action where action_description = 'Heat Stir 1'));
-- insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
-- 	values (
-- 		(select workflow_uuid from vw_workflow where description = 'Heat Stir 1'),
-- 		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Heat Stir 1')),
--         null,
--         (select status_uuid from vw_status where description = 'dev_test'));
-- update vw_action_parameter set parameter_val = (
--     select put_val((select get_type_def('data', 'num')), '15', 'mins'))
--     where action_description = 'Heat Stir 1'
--         and parameter_def_description = 'duration';
-- update vw_action_parameter set parameter_val = (
--     select put_val((select get_type_def('data', 'num')), '750', 'rpm'))
--     where action_description = 'Heat Stir 1'
--         and parameter_def_description = 'speed';
-- update vw_action_parameter set parameter_val = (
--     select put_val((select get_type_def('data', 'num')), '95', 'degC'))
--     where action_description = 'Heat Stir 1'
--         and parameter_def_description = 'temperature';