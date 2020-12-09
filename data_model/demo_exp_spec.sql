-- create a dummy exp_spec_def
select * from vw_exp_spec_def;
insert into vw_exp_spec_def (exp_ref_uuid, description) values
((select experiment_uuid from vw_experiment where vw_experiment.description = 'test_experiment'),
 'test_exp_spec_def');
select * from vw_exp_spec_def;

-- create associated parameter_defs
select * from vw_parameter_def;
insert into vw_parameter_def (description, default_val)
                    values
                    ('incubation_duration',
                      (select put_val(
                          (select get_type_def ('data', 'num')),
                             '30',
                             'mins')
                       )
                    ),
                    ('incubation_temp',
                      (select put_val(
                          (select get_type_def ('data', 'num')),
                             '45',
                             'degC')
                       )
                    );

-- assign the exp_spec_defs to the parameter_defs
insert into vw_exp_spec_parameter_def_assign (exp_spec_def_uuid, parameter_def_uuid)
VALUES
    ((select exp_spec_def_uuid from vw_exp_spec_def where description = 'test_exp_spec_def'),
    (select parameter_def_uuid from vw_parameter_def where vw_parameter_def.description = 'incubation_duration')),
    ((select exp_spec_def_uuid from vw_exp_spec_def where description = 'test_exp_spec_def'),
    (select parameter_def_uuid from vw_parameter_def where vw_parameter_def.description = 'incubation_temp'));

select * from vw_exp_spec_parameter_def; -- neato

-- assign def materials
insert into vw_exp_spec_def_material (exp_spec_def_uuid, description, default_material_uuid)
VALUES  ((select exp_spec_def_uuid from vw_exp_spec_def where description = 'test_exp_spec_def'),
        'choice of material 1',
        (select material_uuid from vw_material where description = 'Dichloromethane')),
        ((select exp_spec_def_uuid from vw_exp_spec_def where description = 'test_exp_spec_def'),
        'choice of material 2',
        (select material_uuid from vw_material where description = 'Imidazolium Iodide'));

select * from vw_exp_spec_def_material;

-- instantiate from def
select * from vw_exp_spec;
insert into vw_exp_spec (exp_spec_def_uuid, description)
    VALUES (
    (select exp_spec_def_uuid from vw_exp_spec_def where description = 'test_exp_spec_def'),
    'test_exp_spec'
    );

select * from vw_exp_spec;
select * from vw_exp_spec_parameter;
select * from vw_exp_spec_material;;

update vw_exp_spec_parameter set
parameter_val = (select put_val ((select type_def_uuid from vw_type_def where description = 'num'),'100',
'degC'))
where exp_spec_description = 'test_exp_spec2'
and parameter_def_description = 'incubation_heat';

select * from vw_exp_spec_parameter;

