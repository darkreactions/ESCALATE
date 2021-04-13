-- this is confusing: everything has to be an actor? need to see documentation on what these fields mean
insert into vw_inventory (description, owner_uuid, operator_uuid, lab_uuid, actor_uuid, status_uuid)
	values (
	'HC Test Inventory',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select actor_uuid from vw_actor where description = 'HC'),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));


-- theres a bug here: two inventories created...
select * from inventory;
-- delete from vw_inventory where inventory_uuid = '59ed1dd7-2d45-4416-9834-a2eb8b69587c';
--
--
-- -- hacky workaround for now...
-- CREATE OR REPLACE FUNCTION inventory_uuid()
--   RETURNS uuid AS
--   $$select inventory_uuid from vw_inventory where description = 'HC Test Inventory' LIMIT 1$$ LANGUAGE sql IMMUTABLE;
--
-- select inventory_uuid();
--select * from vw_material;
--select * from vw_experiment;

update vw_material
set material_class = 'model';

-- these are all the raw materials we need to get started!
select * from vw_material where description in ('Gamma-Butyrolactone', 'Formic Acid', 'Lead Diiodide', 'Ethylammonium Iodide');



-- STOCK SOLUTION A: Organic and Inorganic
insert into vw_material (description, consumable, material_class, actor_uuid, status_uuid) values
	('Stock A', TRUE, 'model',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add the components to the composite
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Stock A'),
	(select material_uuid from vw_material where description = 'Lead Diiodide'),
	FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
 	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Stock A'),
	(select material_uuid from vw_material where description = 'Ethylammonium Iodide'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Stock A'),
	(select material_uuid from vw_material where description = 'Gamma-Butyrolactone'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
	);

-- STOCK B: Concentrated Amine
insert into vw_material (description, consumable, material_class) values
	('Stock B', TRUE, 'model');
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Stock B'),
	(select material_uuid from vw_material where description = 'Ethylammonium Iodide'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Stock B'),
	(select material_uuid from vw_material where description = 'Gamma-Butyrolactone'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
	);


insert into vw_material (description, consumable, material_class, actor_uuid, status_uuid) values
	('Stock FAH', TRUE, 'model',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Stock FAH'),
	(select material_uuid from vw_material where description = 'Formic Acid'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Stock FAH'),
	(select material_uuid from vw_material where description = 'Water'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
	);

insert into vw_material_type_assign (material_uuid, material_type_uuid) values
	((select material_uuid from vw_material where description = 'Stock A'),(select material_type_uuid from vw_material_type where description = 'stock solution')),
	((select material_uuid from vw_material where description = 'Stock A'),(select material_type_uuid from vw_material_type where description = 'human prepared')),
    ((select material_uuid from vw_material where description = 'Stock B'),(select material_type_uuid from vw_material_type where description = 'stock solution')),
	((select material_uuid from vw_material where description = 'Stock B'),(select material_type_uuid from vw_material_type where description = 'human prepared')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Stock A' and component_description = 'Lead Diiodide'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Stock A' and component_description = 'Ethylammonium Iodide'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Stock A' and component_description = 'Gamma-Butyrolactone'),
		(select material_type_uuid from vw_material_type where description = 'solvent')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Stock B' and component_description = 'Ethylammonium Iodide'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Stock B' and component_description = 'Gamma-Butyrolactone'),
		(select material_type_uuid from vw_material_type where description = 'solvent'));


select * from vw_material_composite where composite_description like '%Stock%';

insert into vw_material_property (material_uuid, property_def_uuid,
	property_value, property_class, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'Stock A' and component_description = 'Lead Diiodide'),
	(select property_def_uuid from vw_property_def where description = 'concentration_molarity'),
	'1.1',
	'nominal',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_material_property (material_uuid, property_def_uuid,
	property_value, property_class, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'Stock A' and component_description = 'Ethylammonium Iodide'),
	(select property_def_uuid from vw_property_def where description = 'concentration_molarity'),
	'2.2',
    'nominal',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_material_property (material_uuid, property_def_uuid,
	property_value, property_class, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'Stock B' and component_description = 'Ethylammonium Iodide'),
	(select property_def_uuid from vw_property_def where description = 'concentration_molarity'),
	'3.99',
	'nominal',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_material_property (material_uuid, property_def_uuid,
	property_value, property_class, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'Stock FAH' and component_description = 'Formic Acid'),
	(select property_def_uuid from vw_property_def where description = 'concentration_molarity'),
	'23.6',
	'nominal',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

--select composite_description, composite_class, component_description, property_description, property_class, property_value from vw_material_composite_property where composite_description like 'Stock%';
--select * from vw_material where description like '%Stock%';

insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values (
				(select inventory_uuid()),
				'Wf1 Plate',
				(select material_uuid from vw_material where description = 'Plate: 24 well')
				);

insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values (
				(select inventory_uuid()),
				'Stock A',
				(select material_uuid from vw_material where description = 'Stock A')
				);

insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values (
				(select inventory_uuid()),
				'Stock B',
				(select material_uuid from vw_material where description = 'Stock B')
				);

insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values (
				(select inventory_uuid()),
				'Stock FAH',
				(select material_uuid from vw_material where description = 'Stock FAH')
				);
insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values (
				(select inventory_uuid()),
				'Neat GBL',
				(select material_uuid from vw_material where description = 'Gamma-Butyrolactone')
				);


insert into vw_experiment (ref_uid,
                           description,
                           -- experiment_type,
                           parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid)
	values (
		'test_wf_1', 'test_wf_1',
	    --(select experiment_type_uuid from vw_experiment_type where description = 'template'),
		null,
		(select actor_uuid from vw_actor where description = 'HC'),
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select actor_uuid from vw_actor where description = 'HC'),
		(select status_uuid from vw_status where description = 'dev_test'));


insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) values
	((select experiment_uuid from vw_experiment where description = 'test_wf_1'),
	'Test WF1 Materials',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- then add materials to BOM
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Test WF1 Materials'),
    'Acid',
	(select inventory_material_uuid from vw_inventory_material where description = 'Stock FAH'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Test WF1 Materials'),
    'Solvent',
	(select inventory_material_uuid from vw_inventory_material where description = 'Neat GBL'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Test WF1 Materials'),
    'Stock A',
	(select inventory_material_uuid from vw_inventory_material where description = 'Stock A'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Test WF1 Materials'),
    'Stock B',
	(select inventory_material_uuid from vw_inventory_material where description = 'Stock B'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Test WF1 Materials'),
    'Plate',
	(select inventory_material_uuid from vw_inventory_material where description = 'Wf1 Plate'));


insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Preheat Plate',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
		((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Dispense Solvent',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
		((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Dispense Stock A',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Dispense Stock B',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Dispense Acid Vol 1',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Heat Stir 1',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Dispense Acid Vol 2',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Heat Stir 2',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ((select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Heat',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid)
    values
--            (1,
--         (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
--         (select workflow_uuid from vw_workflow where description = 'Preheat Plate')),
        (1,
        (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
        (select workflow_uuid from vw_workflow where description = 'Dispense Solvent')),
        (2,
        (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
        (select workflow_uuid from vw_workflow where description = 'Dispense Stock A')),
        (3,
        (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
        (select workflow_uuid from vw_workflow where description = 'Dispense Stock B')),
        (4,
        (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
        (select workflow_uuid from vw_workflow where description = 'Dispense Acid Vol 1')),
--         (6,
--         (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
--         (select workflow_uuid from vw_workflow where description = 'Heat Stir 1')),
        (5,
        (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
        (select workflow_uuid from vw_workflow where description = 'Dispense Acid Vol 2'));
--         (8,
--         (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
--         (select workflow_uuid from vw_workflow where description = 'Heat Stir 2')),
--         (9,
--         (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
--         (select workflow_uuid from vw_workflow where description = 'Heat'));

-- dispense workflow action sets
insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val_nominal, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Solvent',
        (select workflow_uuid from vw_workflow where description = 'Dispense Solvent'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array [(select put_val(get_type_def('data', 'num'),'1', 'mL')),
               (select put_val(get_type_def('data', 'num'),'2', 'mL'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Solvent')], -- this has to come from bom_material_index...
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A1%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A2%'and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1'))],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val_nominal, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Stock A',
        (select workflow_uuid from vw_workflow where description = 'Dispense Stock A'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array [(select put_val(get_type_def('data', 'num'),'1', 'mL')),
               (select put_val(get_type_def('data', 'num'),'2', 'mL'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Stock A')], -- this has to come from bom_material_index...
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A1%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A2%'and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1'))],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val_nominal, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Stock B',
        (select workflow_uuid from vw_workflow where description = 'Dispense Stock B'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array [(select put_val(get_type_def('data', 'num'),'1', 'mL')),
               (select put_val(get_type_def('data', 'num'),'2', 'mL'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Stock B')], -- this has to come from bom_material_index...
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A1%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A2%'and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1'))],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));


insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val_nominal, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Acid Vol 1',
        (select workflow_uuid from vw_workflow where description = 'Dispense Acid Vol 1'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array [(select put_val(get_type_def('data', 'num'),'1', 'mL')),
               (select put_val(get_type_def('data', 'num'),'2', 'mL'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Acid')], -- this has to come from bom_material_index...
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A1%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A2%'and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1'))],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));


insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val_nominal, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Acid Vol 2',
        (select workflow_uuid from vw_workflow where description = 'Dispense Acid Vol 2'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array [(select put_val(get_type_def('data', 'num'),'1', 'mL')),
               (select put_val(get_type_def('data', 'num'),'2', 'mL'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Acid')], -- this has to come from bom_material_index...
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A1%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A2%'and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1'))],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));


select * from vw_experiment_workflow_bom_step_object_parameter_json;


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
-- update vw_action_parameter set parameter_val_nominal = (
--     select put_val((select get_type_def('data', 'num')), '15', 'mins'))
--     where action_description = 'Heat Stir 1'
--         and parameter_def_description = 'duration';
-- update vw_action_parameter set parameter_val_nominal = (
--     select put_val((select get_type_def('data', 'num')), '750', 'rpm'))
--     where action_description = 'Heat Stir 1'
--         and parameter_def_description = 'speed';
-- update vw_action_parameter set parameter_val_nominal = (
--     select put_val((select get_type_def('data', 'num')), '95', 'degC'))
--     where action_description = 'Heat Stir 1'
--         and parameter_def_description = 'temperature';