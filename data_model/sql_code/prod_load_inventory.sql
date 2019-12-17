/*
Name:					prod_load_INVENTORY
Parameters:		none
Returns:			
Author:				G. Cattabriga
Date:					2019.12.12
Description:	load data from load_hc_inventory, load_lbl_inventory into inventory, measure
Notes:				
*/

-- ----------------------------
-- Table structure for load_hc_inventory
-- ----------------------------
DROP TABLE IF EXISTS load_hc_inventory;
CREATE TABLE load_hc_inventory (
  reagent varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  part_no varchar(255) COLLATE "pg_catalog"."default",
  amount DOUBLE PRECISION,
	units varchar(255) COLLATE "pg_catalog"."default",
  update_date timestamptz NOT NULL DEFAULT NOW(),
  create_date timestamptz NOT NULL DEFAULT '2019-06-01'::timestamptz
);

-- ----------------------------
-- Table structure for load_lbl_inventory
-- ----------------------------
DROP TABLE IF EXISTS load_lbl_inventory;
CREATE TABLE load_lbl_inventory (
  reagent varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  part_no varchar(255) COLLATE "pg_catalog"."default",
  amount DOUBLE PRECISION,
	units varchar(255) COLLATE "pg_catalog"."default",
  update_date timestamptz NOT NULL DEFAULT NOW(),
  create_date timestamptz NOT NULL DEFAULT '2019-06-01'::timestamptz
);

--add in the units
update load_hc_inventory
	set units = 'g'
	where amount is not null;

-- truncate table inventory;
-- add the hc inventory data from load_hc_inventory 
INSERT INTO inventory (description, material_id, actor_id, part_no, onhand_amt, unit, create_dt, mod_date)
	select distinct inv.reagent, mat.material_id, 
		(SELECT actor_id FROM get_actor () where person_lastfirst like '%Mansoor%'), inv.part_no, inv.amount, inv.units, create_date::timestamptz, now() 
	from load_hc_inventory inv
	join 
		(SELECT * FROM get_materialname_bystatus (array['active'], TRUE)) mat 
	on upper(inv.reagent) = upper(mat.material_name)
	where inv.reagent is not NULL and inv.amount is not NULL
ON CONFLICT ON CONSTRAINT un_inventory DO UPDATE
	SET mod_date = EXCLUDED.mod_date,
		onhand_amt = EXCLUDED.onhand_amt,
		unit = EXCLUDED.unit,
		part_no = EXCLUDED.part_no;


-- add the lbl inventory data from load_lbl_inventory 
INSERT INTO inventory (description, material_id, actor_id, part_no, onhand_amt, unit, create_dt, mod_date)
	select distinct inv.reagent, mat.material_id, 
		(SELECT actor_id FROM get_actor () where person_lastfirst like '%Zhi%'), inv.part_no, inv.amount, inv.units, create_date::timestamptz, now() 
	from load_lbl_inventory inv
	join 
		(SELECT * FROM get_materialname_bystatus (array['active'], TRUE)) mat 
	on upper(inv.reagent) = upper(mat.material_name)
	where inv.reagent is not NULL and inv.amount is not NULL
ON CONFLICT ON CONSTRAINT un_inventory DO UPDATE
	SET mod_date = EXCLUDED.mod_date,
		onhand_amt = EXCLUDED.onhand_amt,
		unit = EXCLUDED.unit,
		part_no = EXCLUDED.part_no;



