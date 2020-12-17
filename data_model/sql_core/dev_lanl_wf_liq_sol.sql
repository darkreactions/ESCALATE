insert into vw_organization (description, full_name, short_name, address1, address2,
                             city, state_province, zip, country, website_url, phone, parent_uuid) values
                            ('Test Laboratory Organization','NewLabCo','NLC','1001 New Lab Lane',null,
                             'Science City','NY','99999',null,null,null,null);
-- set up a test actor (person) and test status to be used throughout
insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid)
	values ('Bond','Ion','X','123 Testing Ln',null,'Test City','NY','99999',null,null,null,null,null,null);
insert into vw_status (description) values ('dev_test');

-- -- add some chemicals to material so we can use them in an experiment (BOM -> bill of materials)
-- -- added HCl, water and AM-243 into chem inventory.
-- -- ===========================================================================
-- -- add some material types
-- -- ===========================================================================
insert into vw_material_type (description)
values
	('separation target'),
	('gas'),
	('stock solution'),
	('human prepared'),
	('solute');

-- -- ===========================================================================
-- -- add in test materials
-- -- property_def's for the resin
-- -- ===========================================================================
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('particle-size {min, max}', 'particle-size',
	(select get_type_def ('data', 'array_num')),
	'um',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('capacity', 'capacity',
	(select get_type_def ('data', 'num')),
	'meq/mL',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('cross-linkage %', 'cross-linkage',
	(select get_type_def ('data', 'num')),
	'',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('moisture % {min, max}', 'moisture',
	(select get_type_def ('data', 'array_num')),
	'',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));

insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('Resin Class', 'Resin Class',
	(select get_type_def ('data', 'text')),
	'',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));

insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('Functional group', 'functional group',
	(select get_type_def ('data', 'text')),
	'',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));


-- create a resin
-- todo: company name
-- should these be property_defs or do those go somewhere^^
-- gary's preference is for vendor to be a property
-- we also might want things like lot #s, expiry dates, etc.
-- vendor

insert into vw_material (description, actor_uuid, status_uuid) values
	('Eichrom Rare Earth',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));


-- add properties to resin
insert into vw_material_property (material_uuid, property_def_uuid, val_val, property_actor_uuid, property_status_uuid ) values
	((select material_uuid from vw_material where description = 'Eichrom Rare Earth'),
	(select property_def_uuid from vw_property_def where short_description = 'particle-size'),
	'{100, 150}',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_material_property (material_uuid, property_def_uuid, val_val, property_actor_uuid, property_status_uuid ) values
	((select material_uuid from vw_material where description = 'Eichrom Rare Earth'),
	(select property_def_uuid from vw_property_def where short_description = 'functional group'),
	'CMPO',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_material_property (material_uuid, property_def_uuid, val_val, property_actor_uuid, property_status_uuid ) values
	((select material_uuid from vw_material where description = 'Eichrom Rare Earth'),
	(select property_def_uuid from vw_property_def where short_description = 'Resin Class'),
	'Extraction',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'active'));


-- 24 well plate
-- plate and well properties (location, volume, ord (order))
-- creates linked list of plate wells in order of the arrays below
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('plate well count', 'plate_well_cnt',
	(select get_type_def ('data', 'int')),
	null,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('plate well location', 'well_loc',
	(select get_type_def ('data', 'text')),
	null,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('plate well robot order', 'well_ord',
	(select get_type_def ('data', 'int')),
	null,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('plate well volume {min, max}', 'well_vol',
	(select get_type_def ('data', 'array_num')),
	'ml',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- concentratrion is intended to be used to give context to the input of a calculations
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('concentration', 'concentration',
	(select get_type_def ('data', 'num')),
	'',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- add a 24 well plate
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Plate: 24 well', FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add a 48 well plate
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Filter Plate: 48 Well', FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add plate well
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Plate well', FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- assign the 24 plate a well qty property
insert into vw_material_property (material_uuid, property_def_uuid,
	val_val, property_actor_uuid, property_status_uuid ) values (
	(select material_uuid from vw_material where description = 'Plate: 24 well'),
	(select property_def_uuid from vw_property_def where short_description = 'plate_well_cnt'),
	'24',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- assign the 48 plate a well qty property
insert into vw_material_property (material_uuid, property_def_uuid,
	val_val, property_actor_uuid, property_status_uuid ) values (
	(select material_uuid from vw_material where description = 'Filter Plate: 48 Well'),
	(select property_def_uuid from vw_property_def where short_description = 'plate_well_cnt'),
	'48',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- add some hardware to material so we can use in an experiment (24 well plate)
-- insert the well location properties A1-D6 (24)
-- we'll figure out a way to do this more compactly through a higher level insert
DO
$do$
DECLARE
	loc_let varchar;
	loc_num	varchar;
	ord int := 1;
	loc_arr_let varchar[] := array['A','B','C','D','E','F'];
	loc_arr_num varchar[] := array['1','2','3','4','5','6','7','8'];
	prop_loc_def uuid := (select property_def_uuid from vw_property_def where short_description = 'well_loc');
	prop_vol_def uuid := (select property_def_uuid from vw_property_def where short_description = 'well_vol');
	prop_ord_def uuid := (select property_def_uuid from vw_property_def where short_description = 'well_ord');
	act uuid := (select actor_uuid from vw_actor where description = 'Ion Bond');
	st uuid := (select status_uuid from vw_status where description = 'dev_test');
	plate_24_uuid uuid := (select material_uuid from vw_material where description = 'Plate: 24 well');
    plate_48_uuid uuid := (select material_uuid from vw_material where description = 'Filter Plate: 48 Well');
	well_uuid uuid;
	component_uuid uuid;
BEGIN
	FOREACH loc_let IN ARRAY loc_arr_let[1:4]
	LOOP
		FOREACH loc_num IN ARRAY loc_arr_num[1:6]
   		LOOP
		    -- create the well
   			insert into vw_material (description, consumable, actor_uuid, status_uuid) values
				(concat('Plate well#: ',loc_let,loc_num), FALSE,
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_uuid into well_uuid;
		    -- assign the well as a component of the plate
		    insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) values
				(plate_24_uuid, well_uuid, TRUE,
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_composite_uuid into component_uuid;
			-- well #
		    insert into vw_material_property (material_uuid, property_def_uuid,
					val_val, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_ord_def,
						ord::text,
						act, st);
			-- well location
		    insert into vw_material_property (material_uuid, property_def_uuid,
					val_val, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_loc_def,
						concat(loc_let,loc_num),
						act, st);
			-- well volume
		    insert into vw_material_property (material_uuid, property_def_uuid,
					val_val, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_vol_def,
						'{.5,10}',
						act, st);
			ord := ord + 1;
   		END LOOP;
	END LOOP;
END
$do$;



DO
$do$
DECLARE
	loc_let varchar;
	loc_num	varchar;
	ord int := 1;
	loc_arr_let varchar[] := array['A','B','C','D','E','F'];
	loc_arr_num varchar[] := array['1','2','3','4','5','6','7','8'];
	prop_loc_def uuid := (select property_def_uuid from vw_property_def where short_description = 'well_loc');
	prop_vol_def uuid := (select property_def_uuid from vw_property_def where short_description = 'well_vol');
	prop_ord_def uuid := (select property_def_uuid from vw_property_def where short_description = 'well_ord');
	act uuid := (select actor_uuid from vw_actor where description = 'Ion Bond');
	st uuid := (select status_uuid from vw_status where description = 'dev_test');
	plate_24_uuid uuid := (select material_uuid from vw_material where description = 'Plate: 24 well');
    plate_48_uuid uuid := (select material_uuid from vw_material where description = 'Filter Plate: 48 Well');
	well_uuid uuid;
	component_uuid uuid;
BEGIN
	FOREACH loc_let IN ARRAY loc_arr_let[1:6]
	LOOP
		FOREACH loc_num IN ARRAY loc_arr_num[1:8]
   		LOOP
		    -- create the well
   			insert into vw_material (description, consumable, actor_uuid, status_uuid) values
				(concat('Filter Plate well#: ',loc_let,loc_num), FALSE, -- <-- we may want to define a naming scheme for these wells
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_uuid into well_uuid;
		    -- assign the well as a component of the plate
		    insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) values
				(plate_48_uuid, well_uuid, TRUE,
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_composite_uuid into component_uuid;
			-- well #
		    insert into vw_material_property (material_uuid, property_def_uuid,
					val_val, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_ord_def,
						ord::text,
						act, st);
			-- well location
		    insert into vw_material_property (material_uuid, property_def_uuid,
					val_val, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_loc_def,
						concat(loc_let,loc_num),
						act, st);
			-- well volume
		    insert into vw_material_property (material_uuid, property_def_uuid,
					val_val, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_vol_def,
						'{.5,10}',
						act, st);
			ord := ord + 1;
   		END LOOP;
	END LOOP;
END
$do$;

select * from vw_material_composite;
-- create component materials
-- Am-243 (component)
-- insert into vw_material (description, consumable, actor_uuid, status_uuid) values
-- 	('Am-243', TRUE,
-- 	(select actor_uuid from vw_actor where description = 'Ion Bond'),
-- 	(select status_uuid from vw_status where description = 'dev_test'));
-- insert into vw_material (description, consumable, actor_uuid, status_uuid) values
-- 	('Water', TRUE,
-- 	(select actor_uuid from vw_actor where description = 'Ion Bond'),
-- 	(select status_uuid from vw_status where description = 'dev_test'));
-- insert into vw_material (description, consumable, actor_uuid, status_uuid) values
-- 	('Hydrochloric acid', TRUE,
-- 	(select actor_uuid from vw_actor where description = 'Ion Bond'),
-- 	(select status_uuid from vw_status where description = 'dev_test'));

-- Am-243 Stock (composite)
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Am-243 Stock', TRUE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add the components to the composite
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Am-243 Stock'),
	(select material_uuid from vw_material where description = 'Am-243'),
	FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
 	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Am-243 Stock'),
	(select material_uuid from vw_material where description = 'Hydrochloric acid'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'Am-243 Stock'),
	(select material_uuid from vw_material where description = 'Water'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
	);


-- add material_type to materials
insert into vw_material_type_assign (material_uuid, material_type_uuid) values
	((select material_uuid from vw_material where description = 'Am-243'),(select material_type_uuid from vw_material_type where description = 'separation target')),
	((select material_uuid from vw_material where description = 'Hydrochloric acid'),(select material_type_uuid from vw_material_type where description = 'gas')),
	((select material_uuid from vw_material where description = 'Am-243 Stock'),(select material_type_uuid from vw_material_type where description = 'stock solution')),
	((select material_uuid from vw_material where description = 'Am-243 Stock'),(select material_type_uuid from vw_material_type where description = 'human prepared')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Am-243'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Hydrochloric acid'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Water'),
		(select material_type_uuid from vw_material_type where description = 'solvent'));

-- add component properties
-- assign the parent a well qty property
insert into vw_material_property (material_uuid, property_def_uuid,
	val_val, val_unit, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Am-243'),
	(select property_def_uuid from vw_property_def where short_description = 'concentration'),
	'1000', 'dpm/uL',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_material_property (material_uuid, property_def_uuid, -- note that this actually inserts a row in vw_material_composite_property
	val_val, val_unit, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'Am-243 Stock' and component_description = 'Hydrochloric acid'),
	(select property_def_uuid from vw_property_def where short_description = 'concentration'),
	'.1', 'M',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- Next (and last) composite material
-- HCl-12M (composite)
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('HCl-12M', TRUE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add the components
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'HCl-12M'),
	(select material_uuid from vw_material where description = 'Hydrochloric acid'),
	FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'HCl-12M'),
	(select material_uuid from vw_material where description = 'Water'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test')
	);
--
--
-- ===========================================================================
-- add materials to inventory (in order for bom to have something to pull from)
-- start with 24 well plate
-- ===========================================================================
insert into vw_inventory (description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values ('24 well plate',
				(select material_uuid from vw_material where description = 'Plate: 24 well'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# 24wp_123',
				(select put_val((select get_type_def ('data', 'int')),'10','')),
                '2022-12-31',
                'Shelf 1, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
select * from vw_material;
insert into vw_inventory (description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values ('Filter Plate',
				(select material_uuid from vw_material where description = 'Filter Plate: 48 Well'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# 24wp_123',
				(select put_val((select get_type_def ('data', 'int')),'10','')),
                '2022-12-31',
                'Shelf 1, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add water to inventory
insert into vw_inventory (description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values ('Water',
				(select material_uuid from vw_material where description = 'Water'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# h2o',
				(select put_val((select get_type_def ('data', 'num')),'100000','mL')),
                '2021-12-31',
                'Shelf 2, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add hcl to inventory
insert into vw_inventory (description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values ('HCL',
				(select material_uuid from vw_material where description = 'Hydrochloric acid'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# hcl_222',
				(select put_val((select get_type_def ('data', 'num')),'10000','mL')),
                '2021-12-31',
                'Shelf 10, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add resin to inventory
insert into vw_inventory (description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values ('Resin',
				(select material_uuid from vw_material where description = 'Eichrom Rare Earth'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# eichrom_re',
				(select put_val((select get_type_def ('data', 'num')),'1000','g')),
                '2021-12-31',
                'Shelf 5, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add Am-243 Stock to inventory
insert into vw_inventory (description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values ('Am-243 Stock',
				(select material_uuid from vw_material where description = 'Am-243 Stock'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# am-243-stock_002',
				(select put_val((select get_type_def ('data', 'int')),'100','mL')),
                '2021-12-31',
                'Shelf xx, Bin x2',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add HCl-12M to inventory
insert into vw_inventory (description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values ('HCl-12M',
				(select material_uuid from vw_material where description = 'HCl-12M'),
				(select actor_uuid from vw_actor where description = 'Ion Bond'),
				'part# hcl12M_202011',
				(select put_val((select get_type_def ('data', 'int')),'10000','mL')),
                '2022-12-31',
                'Shelf 03, Bin 22',
				(select status_uuid from vw_status where description = 'dev_test')
				);

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
		null, (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_parameter_def (description, default_val, actor_uuid, status_uuid)
	values
	    ('volume',
        (select put_val((select get_type_def ('data', 'num')), '0', 'mL')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')),
    	('duration',
        (select put_val((select get_type_def ('data', 'num')), '0', 'mins')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ('speed',
        (select put_val ((select get_type_def ('data', 'num')),'0','rpm')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ('temperature',
        (select put_val((select get_type_def ('data', 'num')), '0', 'degC')),
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_action_def (description, actor_uuid, status_uuid) values
	('dispense', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test')),
	('heat_stir', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('heat', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('start_node', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test')),
    ('end_node', (select actor_uuid from vw_actor where description = 'Ion Bond'),
    (select status_uuid from vw_status where description = 'dev_test'));
-- add a note to dispense action indicating that source is the dispensed material
-- and destination is the container
insert into vw_note (notetext, actor_uuid, ref_note_uuid) values
	('source material = material to be dispensed, destination material = plate well',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
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

-- ===========================================================================
-- set up some calculations
-- ===========================================================================
-- first one is for determining 12M HCL, Water for various concentrations in 5mL
-- calc_def's first
insert into vw_calculation_def
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid,
	in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid )
	values ('LANL_WF1_HCL12M_5mL_concentration', 'math_op_arr((math_op_arr(array[12, 6, 4, 2, 1, .1, .01, .001], ''/'', 12)), ''*'', 5);', -- todo: can we run numpy?
		(select systemtool_uuid from vw_actor where systemtool_name = 'escalate'),
		'LANL WF1: return array of mL vols for 12M HCL for 5mL target across concentration array', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'num_array'),
		null, (select actor_uuid from vw_actor where description = 'Dev Test123'),
		(select status_uuid from vw_status where description = 'dev_test')
		);
insert into vw_calculation_def
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid,
	in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid )
	values ('LANL_WF1_H2O_5mL_concentration', 'math_op_arr((math_op_arr((math_op_arr(array[12, 6, 4, 2, 1, .1, .01, .001], ''/'', 12)), ''*'', -5)), ''+'', 5);', -- todo: whats with the signs?
		(select systemtool_uuid from vw_actor where systemtool_name = 'escalate'),
		'LANL WF1: return array of mL vols for H2O for 5mL target across concentration array', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'num_array'),
		null, (select actor_uuid from vw_actor where description = 'Dev Test123'),
		(select status_uuid from vw_status where description = 'dev_test')
		);
-- now calculation for HCL
insert into calculation (calculation_def_uuid, in_val, in_opt_val, out_val, actor_uuid, status_uuid) values
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_HCL12M_5mL_concentration'),
    (select put_val((select get_type_def ('data', 'array_num')), '{12.0,6.0,4.0,2.0,1.0,.1,.01,.001}','')),
    null,
    (select put_val((select get_type_def ('data', 'array_num')), (select math_op_arr((math_op_arr(array[12, 6, 4, 2, 1, .1, .01, .001], '/', 12)), '*', 5))::text, 'mL')), -- todo: it doesnt just apply the defn?
 	(select actor_uuid from vw_actor where description = 'Dev Test123'),
	(select status_uuid from vw_status where description = 'dev_test')
);
-- calculation for H2O
--todo this seems pretty manual (it wont be following some of gary's updates)
insert into calculation (calculation_def_uuid, in_val, in_opt_val, out_val, actor_uuid, status_uuid) values
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'LANL_WF1_H2O_5mL_concentration'),
    (select put_val((select get_type_def ('data', 'array_num')), '{12.0,6.0,4.0,2.0,1.0,.1,.01,.001}','')),
    null,
    (select put_val((select get_type_def ('data', 'array_num')), (select math_op_arr((math_op_arr((math_op_arr(array[12, 6, 4, 2, 1, .1, .01, .001], '/', 12)), '*', -5)), '+', 5))::text, 'mL')),
 	(select actor_uuid from vw_actor where description = 'Dev Test123'),
	(select status_uuid from vw_status where description = 'dev_test')
);


-- ===========================================================================
-- set up experiment
-- ===========================================================================
insert into vw_experiment (ref_uid, description, parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid)
	values (
		'test_liq_sol', 'LANL Liquid Solid WF Dev',
		null,
		(select actor_uuid from vw_actor where description = 'NLC'),
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select actor_uuid from vw_actor where description = 'NLC'),
		(select status_uuid from vw_status where description = 'dev_test'));

-- ===========================================================================
-- BOM

-- here is where i can instantiate multiple plates
-- material needs to be in bom for it to be used in actions. Needs to be in inventory for it to be in bom.
-- ===========================================================================

select * from vw_bom_material;
select * from vw_bom;
delete from vw_bom;
delete from vw_bom_material;

insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) values
	((select experiment_uuid from vw_experiment where description = 'LANL Liquid Solid WF Dev'),
	'LANL Liq-Sol Dev Materials ',
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- then add materials (and amounts) to BOM
insert into vw_bom_material (bom_uuid, description, inventory_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Liq-Sol Dev Materials '),
    'HCl-12M',
	(select inventory_uuid from vw_inventory where description = 'HCl-12M'),
	(select put_val((select get_type_def ('data', 'num')), '60.00','mL')), -- todo one cool feature of LS is that it lets you define the protocol first and theninfers these amounts
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Liq-Sol Dev Materials '),
    'H2O',
	(select inventory_uuid from vw_inventory where description = 'Water'),
	(select put_val((select get_type_def ('data', 'num')), '60.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_bom_material (bom_uuid, description, inventory_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Liq-Sol Dev Materials '),
    'Am-243 Stock',
	(select inventory_uuid from vw_inventory where description = 'Am-243 Stock'),
	(select put_val((select get_type_def ('data', 'num')), '1.20','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Liq-Sol Dev Materials '),
    'Resin',
	(select inventory_uuid from vw_inventory where description = 'Resin'),
	(select put_val((select get_type_def ('data', 'num')), '0.60','g')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','g')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','g')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Liq-Sol Dev Materials '),
    'Sample Prep Plate',
	(select inventory_uuid from vw_inventory where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Liq-Sol Dev Materials '),
    'Assay Sample Plate 1',
	(select inventory_uuid from vw_inventory where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Liq-Sol Dev Materials '),
    'Resin Plate',
	(select inventory_uuid from vw_inventory where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));


insert into vw_bom_material (bom_uuid, description, inventory_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Liq-Sol Dev Materials '),
    'Assay Sample Plate 2',
	(select inventory_uuid from vw_inventory where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'LANL Liq-Sol Dev Materials '),
    'Filter Plate',
	(select inventory_uuid from vw_inventory where description = 'Filter Plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Ion Bond'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- ===========================================================================
-- create workflows
-- ===========================================================================
-- create workflow_action_set for H2O
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL Liq-Sol Sample H2O',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- create workflow_action_set for HCL
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL Liq-Sol Sample HCl',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- create workflow_action_set for Rad solution
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL Liq-Sol Sample Am-243',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test')); -- q for gary -- could three action sets be in one workflow? 
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL Liq-Sol Assay Samples',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL Liq-Sol Add Resin',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'LANL Liq-Sol Contact',
		(select actor_uuid from vw_actor where description = 'Ion Bond'),
		(select status_uuid from vw_status where description = 'dev_test'));

-- associate wf's with experiment
insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid)
    values (1,
        (select experiment_uuid from vw_experiment where description = 'LANL Liquid Solid WF Dev'),
        (select workflow_uuid from vw_workflow where description = 'LANL Liq-Sol Sample H2O')),
        (2,
        (select experiment_uuid from vw_experiment where description = 'LANL Liquid Solid WF Dev'),
        (select workflow_uuid from vw_workflow where description = 'LANL Liq-Sol Sample HCl')),
        (3,
        (select experiment_uuid from vw_experiment where description = 'LANL Liquid Solid WF Dev'),
        (select workflow_uuid from vw_workflow where description = 'LANL Liq-Sol Sample Am-243')),
        (4,
        (select experiment_uuid from vw_experiment where description = 'LANL Liquid Solid WF Dev'),
        (select workflow_uuid from vw_workflow where description = 'LANL Liq-Sol Assay Samples')),
        (5,
        (select experiment_uuid from vw_experiment where description = 'LANL Liquid Solid WF Dev'),
        (select workflow_uuid from vw_workflow where description = 'LANL Liq-Sol Add Resin')),
        (6,
        (select experiment_uuid from vw_experiment where description = 'LANL Liquid Solid WF Dev'),
        (select workflow_uuid from vw_workflow where description = 'Contact'));


select * from vw_bom_material;
-- create the action_sets
insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('dispense action_set',
        (select workflow_uuid from vw_workflow where description = 'LANL Liq-Sol Sample H2O'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        null,
        (select calculation_uuid from vw_calculation where short_name = 'LANL_WF1_H2O_5mL_concentration'),
 --       (select arr_val_2_val_arr ((select out_val from vw_calculation where short_name = 'LANL_WF1_H2O_5mL_concentration'))),
        array [(select bom_material_uuid from vw_bom_material where description = 'H2O')],
        array [
            (select bom_material_uuid from vw_bom_material where description = 'Sample Prep Plate: Plate well#: A1'), -- really we need to save the plate uuid into a var when we create it
            (select bom_material_uuid from vw_bom_material where description = 'Sample Prep Plate: Plate well#: A2'),
            (select bom_material_uuid from vw_bom_material where description = 'Sample Prep Plate: Plate well#: A3'),
            (select bom_material_uuid from vw_bom_material where description = 'Sample Prep Plate: Plate well#: A4'),
            (select bom_material_uuid from vw_bom_material where description = 'Sample Prep Plate: Plate well#: A5'),
            (select bom_material_uuid from vw_bom_material where description = 'Sample Prep Plate: Plate well#: A6'),
            (select bom_material_uuid from vw_bom_material where description = 'Sample Prep Plate: Plate well#: B1'),
            (select bom_material_uuid from vw_bom_material where description = 'Sample Prep Plate: Plate well#: B2')],
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));

select * from vw_experiment_workflow_step_object_json;


insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('dispense action_set', -- todo whats this description? its non unique
        (select workflow_uuid from vw_workflow where description = 'LANL Liq-Sol Sample HCl'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        null,
        (select calculation_uuid from vw_calculation where short_name = 'LANL_WF1_HCL12M_5mL_concentration'), -- todo do we exercise for cases w/ one input to many output?
 --       (select arr_val_2_val_arr ((select out_val from vw_calculation where short_name = 'LANL_WF1_H2O_5mL_concentration'))),
        array [(select bom_material_uuid from vw_bom_material where description = 'HCl-12M')],
        array [
            (select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate well#: A1'),
            (select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate well#: A2'),
            (select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate well#: A3'),
            (select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate well#: A4'),
            (select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate well#: A5'),
            (select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate well#: A6'),
            (select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate well#: B1'),
            (select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate well#: B2')],
        (select actor_uuid from vw_actor where description = 'Ion Bond'),
        (select status_uuid from vw_status where description = 'dev_test'));
