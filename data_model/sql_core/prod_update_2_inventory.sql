/*
Name:			prod_update_2_inventory
Parameters:		none
Returns:			
Author:			G. Cattabriga
Date:			2020.01.23
Description:	load data from load_hc_inventory, load_lbl_inventory into inventory, measure
Notes:				
*/

-- truncate table inventory;
-- add the hc inventory data from load_hc_inventory 
INSERT INTO inventory (description, material_uuid, actor_uuid, part_no, onhand_amt, unit, add_date, mod_date)
	select distinct inv.reagent, mat.material_uuid, 
		(SELECT actor_uuid FROM vw_actor where person_last_first like '%Mansoor%'), inv.part_no, inv.in_stock, inv.units, create_date::timestamptz, now() 
	from load_hc_inventory inv
	join 
		(SELECT * FROM get_material_nameref_bystatus (array['active'], TRUE)) mat 
	on upper(inv.reagent) = upper(mat.material_refname)
	where inv.reagent is not NULL and inv.in_stock is not NULL
ON CONFLICT ON CONSTRAINT un_inventory DO UPDATE
	SET mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date,
		onhand_amt = EXCLUDED.onhand_amt,
		unit = EXCLUDED.unit,
		part_no = EXCLUDED.part_no;


-- add the lbl inventory data from load_lbl_inventory 
INSERT INTO inventory (description, material_uuid, actor_uuid, part_no, onhand_amt, unit, add_date, mod_date)
	select distinct inv.reagent, mat.material_uuid, 
		(SELECT actor_uuid FROM vw_actor where person_last_first like '%Zhi%'), inv.part_no, inv.amount, inv.units, create_date::timestamptz, now() 
	from load_lbl_inventory inv
	join 
		(SELECT * FROM get_material_nameref_bystatus (array['active'], TRUE)) mat 
	on upper(inv.reagent) = upper(mat.material_refname)
	where inv.reagent is not NULL and inv.amount is not NULL
ON CONFLICT ON CONSTRAINT un_inventory DO UPDATE
	SET mod_date = EXCLUDED.mod_date,
		add_date = EXCLUDED.add_date,
		onhand_amt = EXCLUDED.onhand_amt,
		unit = EXCLUDED.unit,
		part_no = EXCLUDED.part_no;



