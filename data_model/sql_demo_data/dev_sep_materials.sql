set search_path to 'dev';
-- -- add some chemicals to material so we can use them in an experiment (BOM -> bill of materials)
-- -- added HCl, water and CoCl2 into chem inventory.
-- -- ===========================================================================
-- -- add some material types
-- -- ===========================================================================

-- note: these might already be in your db!
insert into vw_material_type (description)
values
	('separation target'),
	('gas'),
	('stock solution'),
	('human prepared');

-- -- ===========================================================================
-- -- add in test materials
-- -- property_def's for the resin
-- -- ===========================================================================
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('particle-size {min, max}', 'particle-size',
	(select get_type_def ('data', 'array_num')),
	'um',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('mesh {min, max}', 'mesh',
	(select get_type_def ('data', 'array_num')),
	'count',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('capacity', 'capacity',
	(select get_type_def ('data', 'num')),
	'meq/mL',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('cross-linkage %', 'cross-linkage',
	(select get_type_def ('data', 'num')),
	'',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('moisture % {min, max}', 'moisture',
	(select get_type_def ('data', 'array_num')),
	'',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('Resin Class', 'Resin Class',
	(select get_type_def ('data', 'text')),
	'',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('Functional group', 'functional group',
	(select get_type_def ('data', 'text')),
	'',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid, property_def_class ) values
	('concentration_molarity', 'molar',
	(select get_type_def ('data', 'num')),
	'mol/L',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active'),
	 'intrinsic');
-- manufacturer
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('manufacturer', 'manufacturer',
	(select get_type_def ('data', 'text')),
	NULL,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_material (description, actor_uuid, status_uuid) values
	('Rare Earth',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active')),
	('TRU',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active')),
	('BDGA',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active')),
	('Anion, AG1-X8',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active')),
	('Cation, 50WX8',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'active'));


-- add properties to resin
insert into vw_material_property (material_uuid, property_def_uuid, property_value) values
	((select material_uuid from vw_material where description = 'Rare Earth'),
	(select property_def_uuid from vw_property_def where short_description = 'particle-size'),
	'{100, 150}'),
	((select material_uuid from vw_material where description = 'Rare Earth'),
	(select property_def_uuid from vw_property_def where short_description = 'functional group'),
	'CMPO'),
	((select material_uuid from vw_material where description = 'Rare Earth'),
	(select property_def_uuid from vw_property_def where short_description = 'Resin Class'),
	'Extraction'),
    ((select material_uuid from vw_material where description = 'Rare Earth'),
     (select property_def_uuid from vw_property_def where short_description = 'Manufacturer'),
	'Eichrom');

insert into vw_material_property (material_uuid, property_def_uuid, property_value) values
	((select material_uuid from vw_material where description = 'TRU'),
	(select property_def_uuid from vw_property_def where short_description = 'particle-size'),
	'{50, 100}'),
	((select material_uuid from vw_material where description = 'TRU'),
	(select property_def_uuid from vw_property_def where short_description = 'functional group'),
	'CMPO'),
	((select material_uuid from vw_material where description = 'TRU'),
	(select property_def_uuid from vw_property_def where short_description = 'Resin Class'),
	'Extraction'),
    ((select material_uuid from vw_material where description = 'TRU'),
     (select property_def_uuid from vw_property_def where short_description = 'Manufacturer'),
	'Eichrom');

insert into vw_material_property (material_uuid, property_def_uuid, property_value) values
	((select material_uuid from vw_material where description = 'BGDA'),
	(select property_def_uuid from vw_property_def where short_description = 'particle-size'),
	'{50, 100}'),
	((select material_uuid from vw_material where description = 'BGDA'),
	(select property_def_uuid from vw_property_def where short_description = 'functional group'),
	'Brannched DGA'),
	((select material_uuid from vw_material where description = 'BGDA'),
	(select property_def_uuid from vw_property_def where short_description = 'Resin Class'),
	'Extraction'),
    ((select material_uuid from vw_material where description = 'BGDA'),
     (select property_def_uuid from vw_property_def where short_description = 'Manufacturer'),
	'Eichrom');

insert into vw_material_property (material_uuid, property_def_uuid, property_value) values
	((select material_uuid from vw_material where description = 'Cation, 50WX8'),
	(select property_def_uuid from vw_property_def where short_description = 'mesh'),
	'{200, 400}'),
	((select material_uuid from vw_material where description = 'Cation, 50WX8'),
	(select property_def_uuid from vw_property_def where short_description = 'functional group'),
	'H+ form'),
	((select material_uuid from vw_material where description = 'Cation, 50WX8'),
	(select property_def_uuid from vw_property_def where short_description = 'Resin Class'),
	'ion-exchange'),
    ((select material_uuid from vw_material where description = 'Cation, 50WX8'),
     (select property_def_uuid from vw_property_def where short_description = 'Manufacturer'),
	'Dowex');

insert into vw_material_property (material_uuid, property_def_uuid, property_value) values
	((select material_uuid from vw_material where description = 'Anion, AG1-X8'),
	(select property_def_uuid from vw_property_def where short_description = 'mesh'),
	'{200, 400}'),
	((select material_uuid from vw_material where description = 'Anion, AG1-X8'),
	(select property_def_uuid from vw_property_def where short_description = 'functional group'),
	'Cl- form'),
	((select material_uuid from vw_material where description = 'Anion, AG1-X8'),
	(select property_def_uuid from vw_property_def where short_description = 'Resin Class'),
	'ion-exchange'),
    ((select material_uuid from vw_material where description = 'Anion, AG1-X8'),
     (select property_def_uuid from vw_property_def where short_description = 'Manufacturer'),
	'Dowex');

-- 24 well plate
-- plate and well properties (location, volume, ord (order))
-- creates linked list of plate wells in order of the arrays below
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('plate well count', 'plate_well_cnt',
	(select get_type_def ('data', 'int')),
	null,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('plate well location', 'well_loc',
	(select get_type_def ('data', 'text')),
	null,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('plate well robot order', 'well_ord',
	(select get_type_def ('data', 'int')),
	null,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('plate well volume {min, max}', 'well_vol',
	(select get_type_def ('data', 'array_num')),
	'mL',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- concentratrion is intended to be used to give context to the input of a calculations
insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values
	('concentration', 'concentration',
	(select get_type_def ('data', 'num')),
	'',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- add a 24 well plate
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Plate: 24 well', FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add a 48 well plate
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Filter Plate: 48 Well', FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add plate well

insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Plate well', FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- assign the 24 plate a well qty property
insert into vw_material_property (material_uuid, property_def_uuid,
	property_value, property_actor_uuid, property_status_uuid ) values (
	(select material_uuid from vw_material where description = 'Plate: 24 well'),
	(select property_def_uuid from vw_property_def where short_description = 'plate_well_cnt'),
	'24',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- assign the 48 plate a well qty property
insert into vw_material_property (material_uuid, property_def_uuid,
	property_value, property_actor_uuid, property_status_uuid ) values (
	(select material_uuid from vw_material where description = 'Filter Plate: 48 Well'),
	(select property_def_uuid from vw_property_def where short_description = 'plate_well_cnt'),
	'48',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
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
	act uuid := (select actor_uuid from vw_actor where description = 'Mike Tynes');
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
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_uuid into well_uuid;
		    -- assign the well as a component of the plate
		    insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) values
				(plate_24_uuid, well_uuid, TRUE,
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_composite_uuid into component_uuid;
			-- well #
		    insert into vw_material_property (material_uuid, property_def_uuid,
					property_value, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_ord_def,
						ord::text,
						act, st);
			-- well location
		    insert into vw_material_property (material_uuid, property_def_uuid,
					property_value, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_loc_def,
						concat(loc_let,loc_num),
						act, st);
			-- well volume
		    insert into vw_material_property (material_uuid, property_def_uuid,
					property_value, property_actor_uuid, property_status_uuid ) values (
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
	act uuid := (select actor_uuid from vw_actor where description = 'Mike Tynes');
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
				(concat('Filter Plate well#: ',loc_let,loc_num), FALSE, -- todo had to call this something different from wells above else violate uniqueness constraint
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_uuid into well_uuid;
		    -- assign the well as a component of the plate
		    insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) values
				(plate_48_uuid, well_uuid, TRUE,
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				(select status_uuid from vw_status where description = 'dev_test')) returning material_composite_uuid into component_uuid;
			-- well #
		    insert into vw_material_property (material_uuid, property_def_uuid,
					property_value, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_ord_def,
						ord::text,
						act, st);
			-- well location
		    insert into vw_material_property (material_uuid, property_def_uuid,
					property_value, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_loc_def,
						concat(loc_let,loc_num),
						act, st);
			-- well volume
		    insert into vw_material_property (material_uuid, property_def_uuid,
					property_value, property_actor_uuid, property_status_uuid ) values (
						component_uuid, prop_vol_def,
						'{.5,10}',
						act, st);
			ord := ord + 1;
   		END LOOP;
	END LOOP;
END
$do$;

---create component materials
--CoCl2 (component)
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('CoCl2', TRUE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Water', TRUE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('Hydrochloric acid', TRUE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- CoCl2 Stock (composite)
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('CoCl2 Stock', TRUE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add the components to the composite
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'CoCl2 Stock'),
	(select material_uuid from vw_material where description = 'CoCl2'),
	FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
 	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'CoCl2 Stock'),
	(select material_uuid from vw_material where description = 'Hydrochloric acid'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'CoCl2 Stock'),
	(select material_uuid from vw_material where description = 'Water'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
	);


-- add material_type to materials
insert into vw_material_type_assign (material_uuid, material_type_uuid) values
	((select material_uuid from vw_material where description = 'CoCl2'),(select material_type_uuid from vw_material_type where description = 'separation target')),
	((select material_uuid from vw_material where description = 'Hydrochloric acid'),(select material_type_uuid from vw_material_type where description = 'gas')),
	((select material_uuid from vw_material where description = 'CoCl2 Stock'),(select material_type_uuid from vw_material_type where description = 'stock solution')),
	((select material_uuid from vw_material where description = 'CoCl2 Stock'),(select material_type_uuid from vw_material_type where description = 'human prepared')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'CoCl2 Stock' and component_description = 'CoCl2'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'CoCl2 Stock' and component_description = 'Hydrochloric acid'),
		(select material_type_uuid from vw_material_type where description = 'solute')),
	((select material_composite_uuid from vw_material_composite where composite_description = 'CoCl2 Stock' and component_description = 'Water'),
		(select material_type_uuid from vw_material_type where description = 'solvent'));

-- add component properties
-- assign the parent a well qty property
insert into vw_material_property (material_uuid, property_def_uuid,
	property_value, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'CoCl2 Stock' and component_description = 'CoCl2'),
	(select property_def_uuid from vw_property_def where description = 'concentration_molarity'),
	'6',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));



insert into vw_material_property (material_uuid, property_def_uuid, -- note that this actually inserts a row in vw_material_composite_property
	property_value, property_actor_uuid, property_status_uuid ) values (
	(select material_composite_uuid from vw_material_composite where composite_description = 'CoCl2 Stock' and component_description = 'Hydrochloric acid'),
	(select property_def_uuid from vw_property_def where short_description = 'molar'),
	'.1',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- Next (and last) composite material
-- HCl-12M (composite)
insert into vw_material (description, consumable, actor_uuid, status_uuid) values
	('HCl-12M', TRUE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- add the components
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'HCl-12M'),
	(select material_uuid from vw_material where description = 'Hydrochloric acid'),
	FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
	);
insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) VALUES
	((select material_uuid from vw_material where description = 'HCl-12M'),
	(select material_uuid from vw_material where description = 'Water'),
		FALSE,
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
	);
--
--
-- ===========================================================================
-- add materials to inventory (in order for bom to have something to pull from)
-- start with 24 well plate
-- ===========================================================================
insert into vw_inventory (description, owner_uuid, operator_uuid, lab_uuid, actor_uuid, status_uuid)
	values (
	'Test Inventory',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select actor_uuid from vw_actor where description = 'TC'),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'24 well plate',
				(select material_uuid from vw_material where description = 'Plate: 24 well'),
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				'part# 24wp_123',
				(select put_val((select get_type_def ('data', 'int')),'10','')),
                '2022-12-31',
                'Shelf 1, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);

insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'Filter Plate',
				(select material_uuid from vw_material where description = 'Filter Plate: 48 Well'),
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				'part# 24wp_123',
				(select put_val((select get_type_def ('data', 'int')),'10','')),
                '2022-12-31',
                'Shelf 1, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);

-- add water to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'Water',
				(select material_uuid from vw_material where description = 'Water'),
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				'part# h2o',
				(select put_val((select get_type_def ('data', 'num')),'5000','mL')),
                '2021-12-31',
                'Shelf 2, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add hcl to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'HCL',
				(select material_uuid from vw_material where description = 'Hydrochloric acid'),
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				'part# hcl_222',
				(select put_val((select get_type_def ('data', 'num')),'1000','mL')),
                '2021-12-31',
                'Shelf 10, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add resin to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'Resin: RE',
				(select material_uuid from vw_material where description = 'Rare Earth'),
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				'part# EichromRE',
				(select put_val((select get_type_def ('data', 'num')),'100','g')),
                '2021-12-31',
                'Shelf 5, Bin 1',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add CoCl2 Stock to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'CoCl2 Stock',
				(select material_uuid from vw_material where description = 'CoCl2 Stock'),
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				'part# CoCl2-stock_002',
				(select put_val((select get_type_def ('data', 'int')),'100','mL')),
                '2021-12-31',
                'Shelf xx, Bin x2',
				(select status_uuid from vw_status where description = 'dev_test')
				);
-- add HCl-12M to inventory_material
insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid,
	part_no, onhand_amt, expiration_date, location, status_uuid)
				values (
				(select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				'HCl-12M',
				(select material_uuid from vw_material where description = 'HCl-12M'),
				(select actor_uuid from vw_actor where description = 'Mike Tynes'),
				'part# hcl12M_202011',
				(select put_val((select get_type_def ('data', 'int')),'1000','mL')),
                '2022-12-31',
                'Shelf 03, Bin 22',
				(select status_uuid from vw_status where description = 'dev_test')
				);

insert into vw_inventory_material (inventory_uuid, description, material_uuid)
				values
				((select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				 'Resin: TRU',
				(select material_uuid from vw_material where description = 'TRU')),
				((select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				 'Resin: BDGA',
				(select material_uuid from vw_material where description = 'BDGA')),
				((select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				 'Resin: AG1-X8',
				(select material_uuid from vw_material where description = 'Anion, AG1-X8')),
				((select inventory_uuid from vw_inventory where description = 'Test Inventory'),
				 'Resin: 50WX8',
				(select material_uuid from vw_material where description = 'Cation, 50WX8'));