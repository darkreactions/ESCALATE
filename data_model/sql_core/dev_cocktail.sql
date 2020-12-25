-- ==========================================================
-- Test out the data model by making some cocktails
-- ==========================================================

-- josh is going to make these in his Wirtshaus
insert into vw_organization (description, full_name, short_name,
                             address1, address2, city, state_province,
                             zip, country, website_url, phone, parent_uuid) values
                             ('Schrierwirtshaus', 'Schrierwirtshaus GmbH', 'SWH',
                             '100 Fancy Apartment Ave',null,
                             'New York','NY','99999',null,null,null,null);
insert into vw_person (last_name, first_name, middle_name,
                       address1, address2, city, state_province,
                       zip, country, phone, email, title, suffix, organization_uuid) values
                      ('Schrier', 'Joshua', null,'100 Fancy Apartment Ave',null,
                       'New York','NY','99999',null,null,null,null,null,null);

--insert into vw_status (description) values ('dev_test');

-- insert into vw_material_type (description)
-- values
-- 	('stock solution'),
-- 	('human prepared'),
-- 	('solute');


-- =============================
-- Define all relevant materials
-- =============================
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Cocktail Shaker', FALSE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	('Highball Glass', FALSE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	('Lime Slice', TRUE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	('Lime Juice', TRUE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	('Mint Leaf', TRUE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	('White Rum', TRUE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	('Granulated Sugar', TRUE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	('Simple Syrup', TRUE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	('Ice Cube', TRUE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	('Club Soda', TRUE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- add the components to the composite
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Simple Syrup'),
	(select material_uuid from vw_material where description = 'Granulated Sugar'),
	FALSE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')),
	((select material_uuid from vw_material where description = 'Simple Syrup'),
	(select material_uuid from vw_material where description = 'Water'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test')
	);


-- add material_type to materials
insert into vw_material_type_assign (material_uuid, material_type_uuid) values
	((select material_uuid from vw_material where description = 'Simple Syrup'),(select material_type_uuid from vw_material_type where description = 'stock solution')),
	((select material_uuid from vw_material where description = 'Simple Syrup'),(select material_type_uuid from vw_material_type where description = 'human prepared')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Simple Syrup' and component_description = 'Granulated Sugar'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Simple Syrup' and component_description = 'Water'),
		(select material_type_uuid from vw_material_type where description = 'solvent'));

--add component properties
insert into vw_material_property (material_uuid, property_def_uuid,
	property_value, property_value_unit, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'Simple Syrup' and component_description = 'Granulated Sugar'),
	(select property_def_uuid from vw_property_def where short_description = 'concentration'),
	'1', 'vol/vol',
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));


-- ================================
-- define actions and parameters
-- ================================
insert into vw_action_def (description, actor_uuid, status_uuid) values
	--('dispense', (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
    --(select status_uuid from vw_status where description = 'dev_test')),
	('shake', (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
    (select status_uuid from vw_status where description = 'dev_test')),
	('muddle', (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
    (select status_uuid from vw_status where description = 'dev_test')),
	('strain', (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
    (select status_uuid from vw_status where description = 'dev_test')),
	('transfer_discrete', (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
    (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_parameter_def (description, default_val, actor_uuid, status_uuid)
	values
	    ('duration_qualitative',
        (select put_val((select get_type_def ('data', 'text')), 'briefly', '')),
        (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test')),
	    ('intensity_qualitative',
        (select put_val((select get_type_def ('data', 'text')), 'gently', '')),
        (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test')),
-- 	    ('volume',
--         (select put_val((select get_type_def ('data', 'num')), '0', 'floz')),
--         (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
-- 		(select status_uuid from vw_status where description = 'dev_test')),
	    ('count',
        (select put_val((select get_type_def ('data', 'int')), '0', 'count')),
        (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid)
	values ((select action_def_uuid from vw_action_def where description = 'shake'),
    	(select parameter_def_uuid from vw_parameter_def where description = 'duration_qualitative')),
        ((select action_def_uuid from vw_action_def where description = 'muddle'),
        (select parameter_def_uuid from vw_parameter_def where description = 'intensity_qualitative')),
--         ((select action_def_uuid from vw_action_def where description = 'dispense'),
--         (select parameter_def_uuid from vw_parameter_def where description = 'volume')),
        ((select action_def_uuid from vw_action_def where description = 'transfer_discrete'),
        (select parameter_def_uuid from vw_parameter_def where description = 'count'));

--=======================
-- Set up inventory
--=======================

--create inventory container
insert into vw_inventory (description, owner_uuid, operator_uuid, lab_uuid, actor_uuid, status_uuid)
	values (
	'JS Cupboard',
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select actor_uuid from vw_actor where description = 'SWH'),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- add (unspecified amount) of materials to the inventory
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid) values
    ((select inventory_uuid from vw_inventory where description = 'JS Cupboard'),
     'Simple Syrup',
     (select material_uuid from vw_material where description = 'Simple Syrup'),
     (select actor_uuid from vw_actor where description = 'Joshua Schrier'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'),
	 'Cocktail Shaker',
	 (select material_uuid from vw_material where description = 'Cocktail Shaker'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'),
	 'Highball Glass',
	 (select material_uuid from vw_material where description = 'Highball Glass'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'),
	 'Lime Slice',
	 (select material_uuid from vw_material where description = 'Lime Slice'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'),
	 'Lime Juice',
	 (select material_uuid from vw_material where description = 'Lime Juice'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'),
	 'Club Soda',
	 (select material_uuid from vw_material where description = 'Club Soda'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'),
	 'Mint Leaf',
	 (select material_uuid from vw_material where description = 'Mint Leaf'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'),
	 'White Rum',
	 (select material_uuid from vw_material where description = 'White Rum'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'),
	 'Granulated Sugar',
	 (select material_uuid from vw_material where description = 'Granulated Sugar'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'), 'Water',
	 (select material_uuid from vw_material where description = 'Water'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, status_uuid) values
	((select inventory_uuid from vw_inventory where description = 'JS Cupboard'), 'Ice Cube',
	 (select material_uuid from vw_material where description = 'Ice Cube'),
	 (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	 (select status_uuid from vw_status where description = 'dev_test'));

-- ===========================================================================
-- set up experiment
-- ===========================================================================
insert into vw_experiment (ref_uid, description, parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid)
	values (
		'mojito_uid', 'JS Test Mojito', null,
		(select actor_uuid from vw_actor where description = 'JWH'),
		(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select actor_uuid from vw_actor where description = 'JWH'),
		(select status_uuid from vw_status where description = 'dev_test'));

-- ==================================================================
-- Bill of Materials (bom)
-- ==================================================================

-- create bom (container)
insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) values
	((select experiment_uuid from vw_experiment where description = 'JS Test Mojito'),
	'JS Test BOM',
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- then add materials (and amounts) to BOM
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'JS Test BOM'),
    'Cocktail Shaker',
	(select inventory_material_uuid from vw_inventory_material where description = 'Cocktail Shaker'),
	(select put_val((select get_type_def ('data', 'int')), '1','count')),
	(select put_val((select get_type_def ('data', 'int')), '1','count')),
	(select put_val((select get_type_def ('data', 'int')), '1','count')),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'JS Test BOM'),
    'Highball Glass',
	(select inventory_material_uuid from vw_inventory_material where description = 'Highball Glass'),
	(select put_val((select get_type_def ('data', 'int')), '1','count')),
	(select put_val((select get_type_def ('data', 'int')), '1','count')),
	(select put_val((select get_type_def ('data', 'int')), '1','count')),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));


insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'JS Test BOM'),
    'Mint Leaf',
	(select inventory_material_uuid from vw_inventory_material where description = 'Mint Leaf'),
	(select put_val((select get_type_def ('data', 'int')), '3','count')),
	(select put_val((select get_type_def ('data', 'int')), '0','count')),
	(select put_val((select get_type_def ('data', 'int')), '0','count')),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'JS Test BOM'),
    'Ice Cube',
	(select inventory_material_uuid from vw_inventory_material where description = 'Ice Cube'),
	(select put_val((select get_type_def ('data', 'int')), '5','count')),
	(select put_val((select get_type_def ('data', 'int')), '0','count')),
	(select put_val((select get_type_def ('data', 'int')), '0','count')),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'JS Test BOM'),
    'Simple Syrup',
	(select inventory_material_uuid from vw_inventory_material where description = 'Simple Syrup'),
	(select put_val((select get_type_def ('data', 'num')), '.5','floz')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','floz')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','floz')),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'JS Test BOM'),
    'White Rum',
	(select inventory_material_uuid from vw_inventory_material where description = 'White Rum'),
	(select put_val((select get_type_def ('data', 'num')), '2','floz')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','floz')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','floz')),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'JS Test BOM'),
    'Club Soda',
	(select inventory_material_uuid from vw_inventory_material where description = 'Club Soda'),
	(select put_val((select get_type_def ('data', 'num')), '1','splash')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','floz')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','floz')),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));


insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'JS Test BOM'),
    'Lime Juice',
	(select inventory_material_uuid from vw_inventory_material where description = 'Lime Juice'),
	(select put_val((select get_type_def ('data', 'num')), '.75','floz')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','floz')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','floz')),
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'dev_test'));


--- =========================================
--- Create workflows for the experiment
--- =========================================

insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values
	(
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Mint to Shaker',
		(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test')),
	(
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Syrup to Shaker',
		(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test')),
	(
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Muddle',
		(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test')),
	(
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Rum to Shaker',
		(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test')),
	(
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Lime Juice to Shaker',
		(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test')),
    (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Shake',
		(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test')),
    (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Ice to Glass',
		(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test')),
    (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Mojito to Glass',
		(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
		(select status_uuid from vw_status where description = 'dev_test'));

-- and add them to the experiment
-- (we could also just create workflow step objects and chain together with parent
--  instead of having a separate workflow for each action)
-- todo: discuss w/ gary how these approaches could be mixed
insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid)
    values (1,
        (select experiment_uuid from vw_experiment where description =  'JS Test Mojito'),
        (select workflow_uuid from vw_workflow where description = 'Mint to Shaker')),
           (2,
        (select experiment_uuid from vw_experiment where description = 'JS Test Mojito'),
        (select workflow_uuid from vw_workflow where description = 'Syrup to Shaker')),
           (3,
        (select experiment_uuid from vw_experiment where description = 'JS Test Mojito'),
        (select workflow_uuid from vw_workflow where description = 'Muddle')),
           (4,
        (select experiment_uuid from vw_experiment where description = 'JS Test Mojito'),
        (select workflow_uuid from vw_workflow where description = 'Rum to Shaker')),
           (5,
        (select experiment_uuid from vw_experiment where description = 'JS Test Mojito'),
        (select workflow_uuid from vw_workflow where description = 'Lime Juice to Shaker')),
           (6,
        (select experiment_uuid from vw_experiment where description = 'JS Test Mojito'),
        (select workflow_uuid from vw_workflow where description = 'Shake')),
           (7,
        (select experiment_uuid from vw_experiment where description = 'JS Test Mojito'),
        (select workflow_uuid from vw_workflow where description = 'Ice to Glass')),
           (8,
        (select experiment_uuid from vw_experiment where description = 'JS Test Mojito'),
        (select workflow_uuid from vw_workflow where description = 'Mojito to Glass'));


-- add actions to each sub workflow
insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('mint_to_shaker',
        (select workflow_uuid from vw_workflow where description = 'Mint to Shaker'),
        (select action_def_uuid from vw_action_def where description = 'transfer_discrete'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'transfer_discrete' and parameter_description = 'count'),
        array [(select put_val((select get_type_def('data', 'int')), '3', 'count'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Mint Leaf')],
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Cocktail Shaker')],
        (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
        (select status_uuid from vw_status where description = 'dev_test'));


-- these inserts take like >30 seconds on mike's machine is that normal? (toward the end they start taking more like 1.5 mins...)
-- todo: try to run them directly rather than through an IDE: see if its faster.
-- if not: optimize them...
insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('muddle',
        (select workflow_uuid from vw_workflow where description = 'Muddle'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'muddle' and parameter_description = 'intensity_qualitative'),
        array [(select put_val((select get_type_def('data', 'text')), 'lightly', ''))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Cocktail Shaker')],
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Cocktail Shaker')],
        (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
        (select status_uuid from vw_status where description = 'dev_test'));


insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('rum_to_shaker',
        (select workflow_uuid from vw_workflow where description = 'Rum to Shaker'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array [(select put_val((select get_type_def('data', 'num')), '2', 'floz'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'White Rum')],
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Cocktail Shaker')],
        (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
        (select status_uuid from vw_status where description = 'dev_test'));
--stopped here
insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('lime_juice_to_shaker',
        (select workflow_uuid from vw_workflow where description = 'Lime Juice to Shaker'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array [(select put_val((select type_def_uuid from vw_type_def where vw_type_def.description='num'), '.75', 'floz'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Lime Juice')],
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Cocktail Shaker')],
        (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('shake',
        (select workflow_uuid from vw_workflow where description = 'Shake'),
        (select action_def_uuid from vw_action_def where description = 'shake'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'shake' and parameter_description = 'duration_qualitative'),
        array [(select put_val((select get_type_def('data', 'text')), 'briefly', ''))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Cocktail Shaker')],
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Cocktail Shaker')],
        (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('ice_to_glass',
        (select workflow_uuid from vw_workflow where description = 'Ice to Glass'),
        (select action_def_uuid from vw_action_def where description = 'transfer_discrete'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'transfer_discrete' and parameter_description = 'count'),
        array [(select put_val((select get_type_def('data', 'int')), '5', 'count'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Ice Cube')],
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Highball Glass')],
        (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
    values ('mojito_to_glass',
            (select workflow_uuid from vw_workflow where description = 'Ice to Glass'),
            (select action_def_uuid from vw_action_def where description = 'strain'),
            null, null, null, null, null, null,
            null,
            array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Cocktail Shaker')],
            array [(select bom_material_index_uuid from vw_bom_material_index where description = 'Highball Glass')],
            (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
            (select status_uuid from vw_status where description = 'dev_test'));

-- ===========================================================================
-- Outcomes/Measures
-- ===========================================================================
insert into vw_outcome (experiment_uuid, description, actor_uuid, status_uuid)
	values (
		(select experiment_uuid from vw_experiment where description = 'JS Test Mojito'),
		'JS Test Experiment Outcome',
 	    (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	    (select status_uuid from vw_status where description = 'dev_test'));

-- property to be measured
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('taste', 'taste',
	(select get_type_def ('data', 'text')),
	'',
	(select actor_uuid from vw_actor where description = 'Joshua Schrier'),
	(select status_uuid from vw_status where description = 'active'));
-- measure definition
insert into vw_measure_def (default_measure_type_uuid, description, default_measure_value, property_def_uuid, actor_uuid, status_uuid) values
   ((select measure_type_uuid from vw_measure_type where description = 'manual'),
   'sample taste',
   (select put_val(
        (select get_type_def ('data', 'text')),
        '',
        '')),
    (select property_def_uuid from vw_property_def where description = 'taste'),
   (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
   (select status_uuid from vw_status where description = 'active'));

-- populate that measure with a value
-- todo: discuss default measure values w/gary.
-- e.g.: do we pre-populate the measures w/ null and then update them w/ the observed values?
insert into vw_measure (measure_def_uuid, measure_type_uuid, ref_measure_uuid, description, measure_value, actor_uuid, status_uuid) values
   ((select measure_def_uuid from vw_measure_def where description = 'sample taste'),
    (select measure_type_uuid from vw_measure_type where description = 'manual'),
    (select outcome_uuid from vw_outcome where description = 'JS Test Experiment Outcome'),
   'sample mojito taste',
   (select put_val(
        (select get_type_def ('data', 'text')),
        'great!',
        '')),
    (select actor_uuid from vw_actor where description = 'Joshua Schrier'),
    (select status_uuid from vw_status where description = 'dev_test'));


-- select * from vw_experiment_workflow_bom_step_object_parameter_json;
-- select * from vw_experiment_bom_workflow_measure_json;