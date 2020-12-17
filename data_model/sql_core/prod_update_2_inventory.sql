/*
Name:			prod_update_2_inventory
Parameters:		none
Returns:			
Author:			G. Cattabriga
Date:			2020.01.23
Description:	load data from load_hc_inventory, load_lbl_inventory into inventory, measure
Notes:				
*/

-- create the inventories (one for HC and one for LBL)
insert into vw_inventory (description, owner_uuid, operator_uuid, lab_uuid, actor_uuid, status_uuid)
	values (
	'Haverford Inventory',
	(select actor_uuid from vw_actor where person_last_first like '%Mansoor%'),
	(select actor_uuid from vw_actor where person_last_first like '%Mansoor%'),
	(select actor_uuid from vw_actor where description = 'HC'),
	(select actor_uuid from vw_actor where description = 'T Testuser'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_inventory (description, owner_uuid, operator_uuid, lab_uuid, actor_uuid, status_uuid)
	values (
	'LBL Inventory',
	(select actor_uuid from vw_actor where person_last_first like '%Zhi%'),
	(select actor_uuid from vw_actor where person_last_first like '%Zhi%'),
	(select actor_uuid from vw_actor where description = 'LBL'),
	(select actor_uuid from vw_actor where description = 'T Testuser'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- truncate table inventory;
-- add the hc inventory data from load_hc_inventory 
INSERT INTO inventory_material (inventory_uuid, description, material_uuid, actor_uuid, part_no, onhand_amt, add_date, mod_date)
	select distinct
	    (select inventory_uuid from vw_inventory where description = 'Haverford Inventory'),
	    inv.reagent, mat.material_uuid,
		(SELECT actor_uuid FROM vw_actor where person_last_first like '%Mansoor%'), inv.part_no, 
		(select put_val(
                          (select get_type_def ('data', 'num')),
                             inv.in_stock::text,
                             inv.units)), 
		create_date::timestamptz, now() 
	from load_hc_inventory inv
	join 
		(SELECT * FROM get_material_nameref_bystatus (array['active'], TRUE)) mat 
	on upper(inv.reagent) = upper(mat.material_refname)
	where inv.reagent is not NULL and inv.in_stock is not NULL
ON CONFLICT ON CONSTRAINT un_inventory_material DO UPDATE
	SET mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date,
		onhand_amt = EXCLUDED.onhand_amt,
		part_no = EXCLUDED.part_no;


-- add the lbl inventory_material data from load_lbl_inventory_material
INSERT INTO inventory_material (inventory_uuid, description, material_uuid, actor_uuid, part_no, onhand_amt, add_date, mod_date)
	select distinct
	    (select inventory_uuid from vw_inventory where description = 'LBL Inventory'),
	    inv.reagent, mat.material_uuid,
		(SELECT actor_uuid FROM vw_actor where person_last_first like '%Zhi%'), inv.part_no, (select put_val(
                          (select get_type_def ('data', 'num')),
                             inv.amount::text,
                             inv.units)), create_date::timestamptz, now() 
	from load_lbl_inventory inv
	join 
		(SELECT * FROM get_material_nameref_bystatus (array['active'], TRUE)) mat 
	on upper(inv.reagent) = upper(mat.material_refname)
	where inv.reagent is not NULL and inv.amount is not NULL
ON CONFLICT ON CONSTRAINT un_inventory_material DO UPDATE
	SET mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date,
		onhand_amt = EXCLUDED.onhand_amt,
		part_no = EXCLUDED.part_no;



