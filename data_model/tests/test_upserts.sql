BEGIN;
SELECT plan(5);

/*
 ask shekar: can we install pg_TAP to docker container?
 would make my own life easier
*/

SET search_path TO dev;

/*
 a simple upsert exercise
 */

-- does function exist
SELECT has_function('upsert_action');
-- does trigger exist
SELECT has_trigger('vw_action', 'trigger_action_upsert');


-- can we do an insert?
PREPARE ua AS
    insert into vw_action (action_def_uuid, action_description, status_uuid)
            values (
            	(select action_def_uuid from vw_action_def where description = 'heat_stir'),
            	'pg_prove_heat_stir',
            	(select status_uuid from vw_status where description = 'active'));
SELECT lives_ok('ua', 'insert_action');


-- did the insert do the thing we expected
-- this is where the value add of pg_prove is!

PREPARE aps AS
    select *
    from vw_action_parameter
    where action_uuid = (select action_uuid
                         from vw_action
                         where vw_action.action_description = 'pg_prove_heat_stir');
select isnt_empty('aps', 'action_parameters_created');

-- but we could do better than just is/isnt empty

PREPARE expected_pd AS
    select array_agg(parameter_def_uuid)
    from vw_action_parameter_def
    where description = 'heat_stir';

PREPARE actual_pd AS
    select array_agg(parameter_def_uuid)
    from vw_action_parameter
    where action_uuid = (select action_uuid
                         from vw_action
                         where vw_action.action_description = 'pg_prove_heat_stir');

SELECT ok(array_eq('expected_pd'::array, 'actual_pd'::array));

SELECT * FROM finish();
ROLLBACK;