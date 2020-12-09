
--==============
-- tables
--==============


-- exp spec def
DROP TABLE EXP_SPEC_DEF CASCADE;
CREATE TABLE exp_spec_def (
    exp_spec_def_uuid uuid DEFAULT uuid_generate_v4(),
    exp_ref_uuid uuid NOT NULL,
    description varchar COLLATE "pg_catalog"."default" NOT NULL,
	add_date timestamptz NOT NULL DEFAULT NOW(),
	mod_date timestamptz NOT NULL DEFAULT NOW()
);
ALTER TABLE exp_spec_def
	ADD CONSTRAINT "pk_exp_spec_def_exp_spec_def_uuid" PRIMARY KEY (exp_spec_def_uuid);
		--ADD CONSTRAINT "un_exp_spec_def" UNIQUE (description);
CLUSTER exp_spec_def
USING "pk_exp_spec_def_exp_spec_def_uuid";
ALTER TABLE exp_spec_def
    ADD CONSTRAINT fk_exp_spec_exp_1 FOREIGN KEY (exp_ref_uuid) REFERENCES experiment (experiment_uuid);



-- exp spec parameter def x
DROP TABLE exp_spec_parameter_def_x CASCADE;
CREATE TABLE exp_spec_parameter_def_x (
    exp_spec_parameter_def_x_uuid uuid DEFAULT uuid_generate_v4(),
    exp_spec_def_uuid uuid NOT NULL,
    parameter_def_uuid uuid NOT NULL
);
ALTER TABLE exp_spec_parameter_def_x
    ADD CONSTRAINT "pk_exp_spec_parameter_def_x_exp_spec_parameter_def_x_uuid" PRIMARY KEY (exp_spec_parameter_def_x_uuid);
CLUSTER exp_spec_parameter_def_x
USING "pk_exp_spec_parameter_def_x_exp_spec_parameter_def_x_uuid";
ALTER TABLE exp_spec_parameter_def_x
    ADD CONSTRAINT fk_exp_spec_parameter_def_x_exp_spec_def_1 FOREIGN KEY (exp_spec_def_uuid) REFERENCES exp_spec_def (exp_spec_def_uuid),
        ADD CONSTRAINT fk_exp_spec_parameter_def_x_parameter_def_1 FOREIGN KEY (parameter_def_uuid) REFERENCES parameter_def (parameter_def_uuid);


-- exp spec def material
DROP TABLE exp_spec_def_material CASCADE;
CREATE TABLE exp_spec_def_material (     -- a named slot for a material in an exp_spec_def
    exp_spec_def_material_uuid uuid DEFAULT uuid_generate_v4(),
    exp_spec_def_uuid uuid NOT NULL,      -- fk to exp_spec_def
    description varchar,                  -- the name for the slot
    default_material_uuid uuid NOT NULL   -- fk to material
);
ALTER TABLE exp_spec_def_material
    ADD CONSTRAINT "pk_exp_spec_def_material_exp_spec_def_material_uuid" PRIMARY KEY (exp_spec_def_material_uuid);
        --ADD CONSTRAINT "un_exp_spec_def_material" UNIQUE (description);
CLUSTER exp_spec_def_material
USING "pk_exp_spec_def_material_exp_spec_def_material_uuid";
ALTER TABLE exp_spec_def_material
    ADD CONSTRAINT fk_exp_spec_def_material_material_1 FOREIGN KEY (default_material_uuid) REFERENCES material (material_uuid),
         ADD CONSTRAINT fk_exp_spec_def_material_exp_spec_def_1 FOREIGN KEY (exp_spec_def_uuid) REFERENCES exp_spec_def (exp_spec_def_uuid);


drop table exp_spec cascade;
CREATE TABLE exp_spec (
    exp_spec_uuid uuid DEFAULT uuid_generate_v4(),
    exp_spec_def_uuid uuid NOT NULL,
    description varchar
);
ALTER TABLE exp_spec
    ADD CONSTRAINT "pk_exp_spec_exp_spec_uuid" PRIMARY KEY (exp_spec_uuid);
        --ADD CONSTRAINT "un_exp_spec" UNIQUE (description);
CLUSTER exp_spec
USING "pk_exp_spec_exp_spec_uuid";
ALTER TABLE exp_spec
    ADD CONSTRAINT fk_exp_spec_exp_spec_def_1 FOREIGN KEY (exp_spec_def_uuid) REFERENCES exp_spec_def (exp_spec_def_uuid);


drop table exp_spec_material CASCADE;
CREATE TABLE exp_spec_material (
    exp_spec_material_uuid uuid DEFAULT uuid_generate_v4(),
    exp_spec_uuid uuid NOT NULL,              -- fk to exp_spec
    exp_spec_def_material_uuid uuid NOT NULL, -- fk to espdm
    material_uuid uuid                        -- fk to material
);
ALTER TABLE exp_spec_material
    ADD CONSTRAINT "pk_exp_spec_material_exp_spec_material_uuid" PRIMARY KEY (exp_spec_material_uuid);
CLUSTER exp_spec_material
USING "pk_exp_spec_material_exp_spec_material_uuid";
ALTER TABLE exp_spec_material
    ADD CONSTRAINT fk_exp_spec_material_exp_spec_1 FOREIGN KEY (exp_spec_uuid) REFERENCES exp_spec (exp_spec_uuid),
    ADD CONSTRAINT fk_exp_spec_material_exp_spec_def_material FOREIGN KEY (exp_spec_def_material_uuid) REFERENCES exp_spec_def_material (exp_spec_def_material_uuid),
    ADD CONSTRAINT fk_exp_spec_material_material FOREIGN KEY (material_uuid) REFERENCES material (material_uuid);


--=====================
-- views
--=====================


CREATE OR REPLACE VIEW vw_exp_spec_def AS
SELECT
    es.exp_spec_def_uuid,
    es.exp_ref_uuid,
    es.description,
    es.add_date,
    es.mod_date
FROM exp_spec_def es;


CREATE OR REPLACE VIEW vw_exp_spec_parameter_def AS
 SELECT
     espd.exp_spec_parameter_def_x_uuid,
     esd.exp_spec_def_uuid,
     esd.description,
     espd.parameter_def_uuid,
     pd.description as parameter_description,
     pd.default_val,
     pd.required,
     pd.val_type_uuid as parameter_val_type_uuid,
     pd.val_type_description as parameter_val_type_description,
     pd.valunit as parameter_unit,
     pd.actor_uuid as parameter_actor_uuid,
     pd.actor_description as parameter_actor_description,
     pd.status_uuid as parameter_status_uuid,
     pd.status_description as parameter_status_description,
     pd.add_date as parameter_add_date,
     pd.mod_date as parameter_mod_date
 FROM exp_spec_def esd
 LEFT JOIN exp_spec_parameter_def_x espd ON esd.exp_spec_def_uuid = espd.exp_spec_def_uuid
 LEFT JOIN vw_parameter_def pd ON espd.parameter_def_uuid = pd.parameter_def_uuid;

----------------------------------------
 -- view exp_spec_parameter_def_assign
----------------------------------------
CREATE OR REPLACE VIEW vw_exp_spec_parameter_def_assign AS
SELECT
    exp_spec_parameter_def_x_uuid,
 	parameter_def_uuid,
 	exp_spec_def_uuid
FROM exp_spec_parameter_def_x;
DROP TRIGGER IF EXISTS trigger_exp_spec_parameter_def_assign ON vw_exp_spec_parameter_def_assign;
CREATE TRIGGER trigger_exp_spec_parameter_def_assign INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_exp_spec_parameter_def_assign
FOR EACH ROW
EXECUTE PROCEDURE upsert_exp_spec_parameter_def_assign ( );


CREATE OR REPLACE VIEW vw_exp_spec AS
SELECT exp_spec_uuid,
       exp_spec_def_uuid,
       description
FROM exp_spec;
DROP TRIGGER IF EXISTS trigger_exp_spec_upsert ON vw_exp_spec;
CREATE TRIGGER trigger_exp_spec_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_exp_spec
FOR EACH ROW
EXECUTE PROCEDURE upsert_exp_spec ( );

----------------------------------------
-- view exp_spec_parameter
----------------------------------------
CREATE OR REPLACE VIEW vw_exp_spec_parameter AS
SELECT
	es.exp_spec_uuid,
	es.exp_spec_def_uuid,
	es.description as exp_spec_description,
	p.parameter_uuid,
	p.parameter_def_uuid,
	p.parameter_def_description,
	p.parameter_val,
	p.actor_uuid as parameter_actor_uuid,
	p.status_uuid as parameter_status_uuid,
	p.add_date as parameter_add_date,
	p.mod_date as parameter_mod_date
FROM exp_spec es
LEFT JOIN vw_exp_spec_def esd ON es.exp_spec_def_uuid = esd.exp_spec_def_uuid
LEFT JOIN vw_parameter p ON es.exp_spec_uuid = p.ref_parameter_uuid;

DROP TRIGGER IF EXISTS trigger_exp_spec_parameter_upsert ON vw_exp_spec_parameter;
CREATE TRIGGER trigger_exp_spec_parameter_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_exp_spec_parameter
FOR EACH ROW
EXECUTE PROCEDURE upsert_exp_spec_parameter ( );

CREATE OR REPLACE VIEW vw_exp_spec_def_material  AS
SELECT
    esdm.exp_spec_def_material_uuid,
    esdm.exp_spec_def_uuid,
    esdm.description,
    esdm.default_material_uuid,
    vm.description as default_material_description
FROM exp_spec_def_material esdm
LEFT JOIN vw_material vm on default_material_uuid = vm.material_uuid;
DROP TRIGGER IF EXISTS trigger_exp_spec_def_material_upsert ON vw_exp_spec_def_material;
CREATE TRIGGER trigger_exp_spec_def_material_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_exp_spec_def_material
FOR EACH ROW
EXECUTE PROCEDURE upsert_exp_spec_def_material ( );


CREATE OR REPLACE VIEW vw_exp_spec_material AS
SELECT
    esm.exp_spec_material_uuid,
    esm.exp_spec_uuid,
    esm.exp_spec_def_material_uuid,
    esm.material_uuid,
    m.description as material_description
FROM exp_spec_material esm
LEFT JOIN material m on esm.material_uuid = m.material_uuid;
DROP TRIGGER IF EXISTS trigger_exp_spec_material_upsert ON vw_exp_spec_material;
CREATE TRIGGER trigger_exp_spec_material_upsert INSTEAD OF INSERT
OR UPDATE
OR DELETE ON vw_exp_spec_material
FOR EACH ROW
EXECUTE PROCEDURE upsert_exp_spec_material ( );
--========================
-- upserts
--========================

/*
    Name:			upsert_exp_spec_parameter()
    Parameters:
    Returns:		void
    Author:			M.Tynes
    Date:			2020.10.13
    Description:	trigger proc that deletes, inserts or updates exp_spec_parameter record based on TG_OP (trigger operation)
    Notes:          Will fail silently if exp_spec def not associated w/ specified parameter def.
                    This function is run inside of upsert_exp_spec.
    Example:
        -- this creates three exp_spec parameters implicitly
        insert into vw_exp_spec (exp_spec_def_uuid, exp_spec_description)
            values ((select exp_spec_def_uuid from vw_exp_spec_def where description = 'heat_stir'), 'example_heat_stir');
        -- which can be modified explicitly:
        update vw_exp_spec_parameter
            set parameter_val = (select put_val (
            (select val_type_uuid from vw_parameter_def where description = 'speed'),
             '8888',
            (select valunit from vw_parameter_def where description = 'speed'))
            )
            where (exp_spec_description = 'example_heat_stir' AND parameter_def_description = 'speed');
        -- cleanup
        delete from vw_exp_spec_parameter where exp_spec_description = 'example_heat_stir';
*/
CREATE OR REPLACE FUNCTION upsert_exp_spec_parameter()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF (TG_OP = 'INSERT') THEN
        IF (NEW.parameter_def_uuid IN
        -- q: should this (and similar action one) actually throw an error?
        -- followup: can django handle pg errors?
        -- only create exp_spec parameters when the exp_spec and parameter definitions are already associated
                (select parameter_def_uuid
                 from vw_exp_spec_parameter_def
                 where exp_spec_def_uuid = (select exp_spec_def_uuid from vw_exp_spec where exp_spec_uuid = NEW.exp_spec_uuid))
            )
        THEN
            INSERT INTO vw_parameter (parameter_def_uuid, parameter_val, ref_parameter_uuid, actor_uuid, status_uuid)
                VALUES (NEW.parameter_def_uuid, NEW.parameter_val, NEW.exp_spec_uuid, NEW.parameter_actor_uuid, NEW.parameter_status_uuid);
		END IF;
		RETURN NEW;
	ELSIF(TG_OP = 'DELETE') THEN
        DELETE
        FROM vw_parameter
        WHERE ref_parameter_uuid = OLD.exp_spec_uuid;
    RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE
            parameter
        SET
            parameter_val = NEW.parameter_val,
            actor_uuid = NEW.parameter_actor_uuid,
            status_uuid = NEW.parameter_status_uuid,
            mod_date = now()
        WHERE
            parameter_uuid = NEW.parameter_uuid;
        RETURN NEW;
    END IF;
END;
$$
LANGUAGE plpgsql;



/*
    Name:           upsert_exp_spec_material()
    Parameters:
    Returns:        void
    Author:         M.Tynes
    Date:           2020.10.13
    Description:    trigger proc that deletes, inserts or updates exp_spec_material record based on TG_OP (trigger operation)
    Notes:          Will fail silently if exp_spec def not associated w/ specified material def.
                    This function is run inside of upsert_exp_spec.
    Example:
        -- this creates three exp_spec materials implicitly
        insert into vw_exp_spec (exp_spec_def_uuid, exp_spec_description)
            values ((select exp_spec_def_uuid from vw_exp_spec_def where description = 'heat_stir'), 'example_heat_stir');
        -- which can be modified explicitly:
        update vw_exp_spec_material
        -- cleanup
        delete from vw_exp_spec_material where exp_spec_description = 'example_heat_stir';
*/
CREATE OR REPLACE FUNCTION upsert_exp_spec_material()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        IF (NEW.exp_spec_def_material_uuid IN
        -- q: should this (and similar action one) actually throw an error?
        -- followup: can django handle pg errors?
        -- only create exp_spec materials when the exp_spec and material definitions are already associated
                (select exp_spec_def_material_uuid
                 from vw_exp_spec_def_material
                 where exp_spec_def_uuid = (select exp_spec_def_uuid from vw_exp_spec where exp_spec_uuid = NEW.exp_spec_uuid))
            )
        THEN
        INSERT INTO exp_spec_material (exp_spec_uuid, exp_spec_def_material_uuid, material_uuid)
            VALUES (NEW.exp_spec_uuid, NEW.exp_spec_def_material_uuid, NEW.material_uuid);
         END IF;
        RETURN NEW;
    ELSIF(TG_OP = 'DELETE') THEN
        DELETE
        FROM exp_spec_material
        WHERE exp_spec_material_uuid = NEW.exp_spec_material_uuid;
    RETURN OLD;
    ELSIF (TG_OP = 'UPDATE') THEN
        UPDATE
            exp_spec_material
        SET
            material_uuid = NEW.material_uuid
--             actor_uuid = NEW.material_actor_uuid,
--             status_uuid = NEW.material_status_uuid,
--             mod_date = now()
        WHERE
            exp_spec_material_uuid = NEW.exp_spec_material_uuid;
        RETURN NEW;
    END IF;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION upsert_exp_spec_parameter_def_assign ()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF(TG_OP = 'DELETE') THEN
        DELETE FROM exp_spec_parameter_def_x
        WHERE (exp_spec_def_uuid = OLD.exp_spec_def_uuid)
            and(parameter_def_uuid = OLD.parameter_def_uuid);
        RETURN OLD;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO exp_spec_parameter_def_x (exp_spec_def_uuid, parameter_def_uuid)
        VALUES(NEW.exp_spec_def_uuid,
               NEW.parameter_def_uuid);
        RETURN NEW;
    END IF;
END;
$$
LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION upsert_exp_spec_def_material ()
    RETURNS TRIGGER
    AS $$
BEGIN
    IF(TG_OP = 'DELETE') THEN
        DELETE FROM exp_spec_def_material
        WHERE (exp_spec_def_material_uuid = OLD.exp_spec_def_material_uuid);
        RETURN OLD;
    ELSIF (TG_OP = 'INSERT') THEN
        INSERT INTO exp_spec_def_material (exp_spec_def_uuid, description, default_material_uuid)
        VALUES (NEW.exp_spec_def_uuid, NEW.description, NEW.default_material_uuid);
        RETURN NEW;
    ELSEIF TG_OP = 'UPDATE' THEN
        UPDATE exp_spec_def_material
        SET
            exp_spec_def_uuid = NEW.exp_spec_def_uuid,
            description = NEW.description,
            default_material_uuid = NEW.default_material_uuid
        WHERE exp_spec_def_material_uuid = NEW.exp_spec_def_material_uuid;
        RETURN NEW;
    END IF;
END;
$$
LANGUAGE plpgsql;


/*
    Name:			upsert_exp_spec()
    Parameters:
    Returns:		void
    Author:			M.Tynes
    Date:			2020.10.07
    Description:	trigger proc that deletes, inserts or updates exp_spec record based on TG_OP (trigger operation)

    Notes:          On INSERT, creates:
                        1. An item in the vw_exp_spec that points back to an exp_spec_def.
                        2. n items in the vw_exp_spec_parameter where n is the # of parameter_defs assigned to exp_spec_def
                        3. m items in the vw_exp_spec_material where m is the # of materials assigned to exp_spec_def
*/
CREATE OR REPLACE FUNCTION upsert_exp_spec()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
	    -- delete the asssociated parameter records
		DELETE FROM vw_parameter
		WHERE ref_parameter_uuid = OLD.exp_spec_uuid;
	    -- then delete the exp_spec record
		DELETE FROM exp_spec
		WHERE exp_spec_uuid = OLD.exp_spec_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.exp_spec_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'INSERT') THEN
        -- check if exp_spec def exists
	    IF (select exists
                (select exp_spec_def_uuid
                 from vw_exp_spec_def
                 where exp_spec_def_uuid = NEW.exp_spec_def_uuid)
            )
        THEN
            -- first create exp_spec instance
			INSERT INTO exp_spec (exp_spec_def_uuid, description)
				VALUES (NEW.exp_spec_def_uuid, NEW.description)
				returning exp_spec_uuid into NEW.exp_spec_uuid;
			-- then create exp_spec parameter instances for every parameter_def associated w/ this exp_spec_def
			-- and populate w/ default values
            INSERT INTO vw_exp_spec_parameter (exp_spec_uuid, parameter_def_uuid, parameter_val)
                (select
                    NEW.exp_spec_uuid as exp_spec_uuid,
                    parameter_def_uuid,
                    default_val
                from vw_exp_spec_parameter_def
                where exp_spec_def_uuid = NEW.exp_spec_def_uuid);

			-- finally create exp_spec_material instances for every material associated w/ this exp_spec_def
			INSERT INTO vw_exp_spec_material (exp_spec_uuid, exp_spec_def_material_uuid, material_uuid)
			    (select
                    NEW.exp_spec_uuid as exp_spec_uuid,
                    exp_spec_def_material_uuid,
                    default_material_uuid
                from vw_exp_spec_def_material
                where exp_spec_def_uuid = NEW.exp_spec_def_uuid);
			RETURN NEW;
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;

-- next steps:
insert into vw_exp_spec (experiment_uuid)
values ('foo');

select *  from vw_experiment_parameters where experiment_uuid = 'foo'
-- just expose to the level of action set
-- the update is going to have to re-compute the action set parameters and calculation outputs