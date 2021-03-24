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

select composite_description, composite_class, component_description, property_description, property_class, property_value from vw_material_composite_property where composite_description like 'Stock%';

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
    'Stock FAH',
	(select inventory_material_uuid from vw_inventory_material where description = 'Stock FAH'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid) values (
	(select bom_uuid from vw_bom where description = 'Test WF1 Materials'),
    'Neat GBL',
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
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Dispense GBL',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid)
    values (1,
        (select experiment_uuid from vw_experiment where description = 'test_wf_1'),
        (select workflow_uuid from vw_workflow where description = 'Dispense GBL'));


insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense GBL',
        (select workflow_uuid from vw_workflow where description = 'Dispense GBL'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array [(select put_val(get_type_def('data', 'num'),'1', 'mL'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Neat GBL')], -- this has to come from bom_material_index...
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A1%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A2%'and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A3%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A4%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%SPlate%A5%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%A6%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Plate%B1%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description = '%Plate%B2%' and bom_uuid = (select bom_uuid from vw_bom where experiment_description = 'test_wf_1'))],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));

select * from vw_experiment_workflow_bom_step_object_parameter_json;