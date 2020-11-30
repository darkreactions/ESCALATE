BEGIN;

SET search_path TO dev;

SELECT plan(2);

PREPARE mb AS INSERT INTO vw_action_def (description, actor_uuid)
                VALUES ('moisturize_beard', (select actor_uuid from vw_actor where description = 'Ian Pendleton'));
SELECT lives_ok('mb', 'insert into vw_action_def');

SELECT is(actor_description, 'Ian Pendleton') from vw_action_def where description = 'moisturize_beard';
SELECT isnt(actor_description, 'Mike Tynes', 'Test if ian is mike') from vw_action_def where description = 'moisturize_beard';

SELECT * from finish();
ROLLBACK;
