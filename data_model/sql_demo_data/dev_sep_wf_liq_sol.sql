set search_path to 'dev';

-- ===========================================================================
-- set up some calculations
-- ===========================================================================
-- define the calculation parameters, calculations and then join together
insert into vw_parameter_def (description, default_val, actor_uuid, status_uuid)
	values
	    ('hcl_concentrations',
        (select put_val((select get_type_def ('data', 'array_num')),
            '{12.0,6.0,4.0,2.0,1.0,.1,.01,.001}', 'M')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
    	('total_vol',
        (select put_val((select get_type_def ('data', 'num')), '5', 'mL')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')),
        ('stock_concentration',
        (select put_val ((select get_type_def ('data', 'num')),'12','M')),
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- first one is for determining 12M HCL, Water for various concentrations in 5mL
-- calc_def's first
insert into vw_calculation_def
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid,
	in_opt_type_uuid, out_type_uuid, out_unit, calculation_class_uuid, actor_uuid, status_uuid )
	values ('TC_WF1_HCL12M_5mL_concentration',
	        'math_op_arr(math_op_arr(''hcl_concentrations'', ''/'', stock_concentration), ''*'', total_vol)',
		(select systemtool_uuid from vw_actor where systemtool_name = 'postgres'),
		'WF1: return array of mL vols for 12M HCL for 5mL target across concentration array', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'array_num'), 'mL',
		null, (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')
		);
insert into vw_calculation_def
	(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid,
	in_opt_type_uuid, out_type_uuid, out_unit, calculation_class_uuid, actor_uuid, status_uuid )
	values ('TC_WF1_H2O_5mL_concentration',
	        'math_op_arr(math_op_arr(math_op_arr(''hcl_concentrations'', ''/'', stock_concentration), ''*'', (math_op(0, ''-'', total_vol))), ''+'', total_vol)',
		(select systemtool_uuid from vw_actor where systemtool_name = 'postgres'),
		'WF1: return array of mL vols for H2O for 5mL target across concentration array', null, null, null, null,
		(select type_def_uuid from vw_type_def where category = 'data' and description = 'array_num'), 'mL',
		null, (select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')
		);
insert into vw_calculation_parameter_def (calculation_def_uuid, parameter_def_uuid)
    values (
        (select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'hcl_concentrations')),
        ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'total_vol')),
        ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'stock_concentration'));
insert into vw_calculation_parameter_def (calculation_def_uuid, parameter_def_uuid)
    values (
        (select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_H2O_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'hcl_concentrations')),
        ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_H2O_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'total_vol')),
        ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_H2O_5mL_concentration'),
        (select parameter_def_uuid from vw_parameter_def where description = 'stock_concentration'));
-- now create the calculation for HCL
insert into vw_calculation (calculation_def_uuid, calculation_alias_name, in_val, in_opt_val, out_val, actor_uuid, status_uuid) values
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
    'TC_WF1_HCL12M_5mL_concentration',
    null,
    null,
    (select do_calculation((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'))),
 	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
);
-- calculation for H2O
insert into vw_calculation (calculation_def_uuid, calculation_alias_name, in_val, in_opt_val, out_val, actor_uuid, status_uuid) values
(
    (select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_H2O_5mL_concentration'),
    'TC_WF1_H2O_5mL_concentration',
    null,
    null,
    (select do_calculation((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_H2O_5mL_concentration'))),
 	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test')
);  -- todo: i still dont really understand this

-- ===========================================================================
-- set up experiment
-- ===========================================================================
-- insert into vw_experiment_type (description) values ('template');
-- I dont love this solution because it requires weird ad-hoccery in experiment copy.

insert into vw_experiment (ref_uid,
                           description,
                           -- experiment_type,
                           parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid)
	values (
		'test_liq_sol', 'liquid_solid_extraction',
	    --(select experiment_type_uuid from vw_experiment_type where description = 'template'),
		null,
		(select actor_uuid from vw_actor where description = 'TC'),
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select actor_uuid from vw_actor where description = 'TC'),
		(select status_uuid from vw_status where description = 'dev_test'));

-- ===========================================================================
-- BOM

-- here is where i can instantiate multiple plates
-- material needs to be in bom for it to be used in actions. Needs to be in inventory for it to be in bom.
-- ===========================================================================

insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) values
	((select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
	'Liq-Sol Dev Materials ',
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
-- then add materials (and amounts) to BOM
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials '),
    'HCl-12M',
	(select inventory_material_uuid from vw_inventory_material where description = 'HCl-12M'),
	(select put_val((select get_type_def ('data', 'num')), '60.00','mL')), -- todo one cool feature of LS is that it lets you define the protocol first and theninfers these amounts
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials '),
    'H2O',
	(select inventory_material_uuid from vw_inventory_material where description = 'Water'),
	(select put_val((select get_type_def ('data', 'num')), '60.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials '),
    'Metal Stock',
	(select inventory_material_uuid from vw_inventory_material where description = 'CoCl2 Stock'),
	(select put_val((select get_type_def ('data', 'num')), '1.20','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','mL')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials '),
    'Resin',
	(select inventory_material_uuid from vw_inventory_material where description = 'Resin: RE'),
	(select put_val((select get_type_def ('data', 'num')), '0.60','g')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','g')),
	(select put_val((select get_type_def ('data', 'num')), '0.00','g')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials '),
    'Sample Prep Plate',
	(select inventory_material_uuid from vw_inventory_material where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials '),
    'Assay Sample Plate 1',
	(select inventory_material_uuid from vw_inventory_material where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials '),
    'Resin Plate',
	(select inventory_material_uuid from vw_inventory_material where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));


insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials '),
    'Assay Sample Plate 2',
	(select inventory_material_uuid from vw_inventory_material where description = '24 well plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid) values (
	(select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials '),
    'Filter Plate',
	(select inventory_material_uuid from vw_inventory_material where description = 'Filter Plate'),
	(select put_val((select get_type_def ('data', 'int')), '1','')),
	null,
	(select put_val((select get_type_def ('data', 'int')), '0','')),
	(select actor_uuid from vw_actor where description = 'Mike Tynes'),
	(select status_uuid from vw_status where description = 'dev_test'));

-- ===========================================================================
-- create workflows
-- ===========================================================================
-- create workflow_action_set for H2O
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Liq-Sol Sample H2O', -- todo: combine sample prep into one workflow w/ parent actions
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- create workflow_action_set for HCL
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Liq-Sol Sample HCl',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));
-- create workflow_action_set for metal solution
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Liq-Sol Sample CoCl2',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test')); -- q for gary -- could three action sets be in one workflow?
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Liq-Sol Assay Samples',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Liq-Sol Add Resin',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Liq-Sol Sample to Resin',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
	values (
		(select workflow_type_uuid from vw_workflow_type where description = 'template'),
		'Liq-Sol Contact Vortex',
		(select actor_uuid from vw_actor where description = 'Mike Tynes'),
		(select status_uuid from vw_status where description = 'dev_test'));

-- associate wf's with experiment
insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid)
    values (1,
        (select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Sample H2O')),
        (2,
        (select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Sample HCl')),
        (3,
        (select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Sample CoCl2')),
        (4,
        (select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Assay Samples')),
        (5,
        (select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Add Resin'));
insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid) values
        (6,
        (select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Sample to Resin'));
insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid) values
        (7,
        (select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Contact Vortex'));

-- create the action_sets


-- create the action_sets
insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values ('Dispense Sample H2O',
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Sample H2O'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        null,
        (select calculation_uuid from vw_calculation where short_name = 'TC_WF1_H2O_5mL_concentration'),
 --       (select arr_val_2_val_arr ((select out_val from vw_calculation where short_name = 'TC_WF1_H2O_5mL_concentration'))),
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'H2O')],
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A2%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A3%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A4%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A5%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A6%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%B1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description = 'Sample Prep Plate%B2%')],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values  ('Dispense Sample HCl',
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Sample HCl'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        null,
        (select calculation_uuid from vw_calculation where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'HCl-12M')],
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A2%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A3%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A4%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A5%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A6%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%B1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%B2%')],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values  ('Dispense Metal Stock',
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Sample CoCl2'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array[(select put_val((select get_type_def('data', 'num')), '.1', 'mL'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description = 'CoCl2 Stock')],
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A2%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A3%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A4%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A5%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A6%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%B1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%B2%')],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values  ('Transfer Sample for Assay',
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Assay Samples'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array[(select put_val((select get_type_def('data', 'num')), '.1', 'mL'))],
        null,
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A2%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A3%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A4%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A5%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A6%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%B1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%B2%')],
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Assay Sample Plate 1%A1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Assay Sample Plate 1%A2%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Assay Sample Plate 1%A3%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Assay Sample Plate 1%A4%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Assay Sample Plate 1%A5%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Assay Sample Plate 1%A6%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Assay Sample Plate 1%B1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Assay Sample Plate 1%B2%')],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));

insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values  ('Add Resin',
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Add Resin'),
        (select action_def_uuid from vw_action_def where description = 'dispense_solid'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense_solid' and parameter_description = 'mass'),
        array[(select put_val((select get_type_def('data', 'num')), '50', 'mg'))],
        null,
        array [(select bom_material_index_uuid from vw_bom_material_index where description like '%Resin' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials'))],
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A1%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A2%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A3%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A4%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A5%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A6%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%B1%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%B2%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials'))],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));


insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration,
                                    repeating,
                                    parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid,
                                    actor_uuid, status_uuid)
values  ('Sample to Resin',
        (select workflow_uuid from vw_workflow where description = 'Liq-Sol Sample to Resin'),
        (select action_def_uuid from vw_action_def where description = 'dispense'),
        null, null, null, null,
        (select parameter_def_uuid
         from vw_action_parameter_def
         where description = 'dispense' and parameter_description = 'volume'),
        array[(select put_val((select get_type_def('data', 'num')), '.1', 'mL'))],
        null,
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A2%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A3%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A4%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A5%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%A6%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%B1%'),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Sample Prep Plate%B2%')],
        array [
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A1%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A2%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A3%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A4%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A5%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%A6%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%B1%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials')),
            (select bom_material_index_uuid from vw_bom_material_index where
                description like '%Resin Plate%B2%' and bom_uuid = (select bom_uuid from vw_bom where description = 'Liq-Sol Dev Materials'))],
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));


insert into vw_action (action_def_uuid, workflow_uuid, action_description, actor_uuid, status_uuid)
	values (
    	(select action_def_uuid from vw_action_def where description = 'heat_stir'),
    	(select workflow_uuid from vw_workflow where description = 'Liq-Sol Contact Vortex'),
        'Heat Stir Sample Plate',
        (select actor_uuid from vw_actor where description = 'Mike Tynes'),
        (select status_uuid from vw_status where description = 'dev_test'));
insert into vw_workflow_object (workflow_uuid, action_uuid)
	values (
	    (select workflow_uuid from vw_workflow where description = 'Liq-Sol Contact Vortex'),
		(select action_uuid from vw_action where action_description = 'Heat Stir Sample Plate'));
insert into vw_workflow_step (workflow_uuid, workflow_object_uuid, parent_uuid, status_uuid)
	values (
		(select workflow_uuid from vw_workflow where description = 'Liq-Sol Contact Vortex'),
		(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'Heat Stir Sample Plate')),
        null,
        (select status_uuid from vw_status where description = 'dev_test'));


update vw_action_parameter set parameter_val = (
    select put_val((select get_type_def('data', 'num')), '45', 'mins'))
    where action_description = 'Heat Stir Sample Plate'
        and parameter_def_description = 'duration';
update vw_action_parameter set parameter_val = (
    select put_val((select get_type_def('data', 'num')), '500', 'rpm'))
    where action_description = 'Heat Stir Sample Plate'
        and parameter_def_description = 'speed';
update vw_action_parameter set parameter_val = (
    select put_val((select get_type_def('data', 'num')), '30', 'degC'))
    where action_description = 'Heat Stir Sample Plate'
        and parameter_def_description = 'temperature';

select concat('end create liquid solid,', now());

-- select * from vw_experiment_workflow_bom_step_object_parameter_json;
-- select * from vw_experiment_bom_workflow_measure_json;

--select * from vw_inventory_material;
--select * from vw_experiment;
-- call replicate_experiment_copy
-- ('liquid_solid_extraction', 10);

-- select experiment_copy ((select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
--                         'liquid_liquid_extraction');
-- select experiment_copy ((select experiment_uuid from vw_experiment where description = 'liquid_solid_extraction'),
--                         'precipitation');


--
-- select *
-- from vw_experiment_parameter;
-- where workflow like 'TC%HCl';
--
-- -- these two copies share a parameter because of the way calculation and parameter def are intertwined
--
-- select * from vw_experiment_parameter
-- where experiment = 'experiment copy #1'
--   and workflow_seq = 1

--   and parameter_def_description = 'hcl_concentrations';
--
-- update vw_experiment_parameter
-- set
--     parameter_value = array[(select put_val(get_type_def('data', 'array_num'), '{12.0, 12.0, 12.0, 12.0, 1.0, 1.0, 1.0, 1.0}', ''))]
-- where experiment = 'experiment copy #1'
--   and workflow_seq = 1
--   and parameter_def_description = 'hcl_concentrations';
--
--
-- select * from vw_parameter;
-- select * from vw_parameter_def;
--
-- select * from vw_calculation where actor_description = 'Mike Tynes';
--
--
-- select * from vw_action_parameter;
-- select * from vw_workflow_action_set;

-- select * from vw_experiment;

