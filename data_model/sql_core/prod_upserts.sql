--======================================================================
/*
Name:			prod_upsert
Parameters:		none
Returns:		NA
Author:			G. Cattabriga
Date:			2020.09.15
Description:	contain the upsert functions used in ESCALATE
Notes:				
*/
--======================================================================

/*
Name:			upsert_tag_type()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.06.20
Description:	trigger proc that deletes, inserts or updates tag_type record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_tag_type (type, description) values ('TESTDEV', 'tags used to help identify development cycle phase');
 				insert into vw_tag_type (type) values ('TESTDEV');
 				update vw_tag_type set description = 'tags used to help identify development cycle phase; e.g. SPEC, TEST, DEV' where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (type = 'TESTDEV'));
 				update vw_tag_type set type = 'TESTDEV1', description = 'tags used to help identify development cycle phase; e.g. SPEC, TEST, DEV' where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (type = 'TESTDEV'));
 				delete from vw_tag_type where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (type = 'TESTDEV'));
 				delete from vw_tag_type where tag_type_uuid = (select tag_type_uuid from vw_tag_type where (type = 'TESTDEV1'));
 */
CREATE OR REPLACE FUNCTION upsert_tag_type ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the tag_type record
		DELETE FROM tag_type
		WHERE tag_type_uuid = OLD.tag_type_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		DELETE FROM vw_note
		WHERE ref_note_uuid = OLD.tag_type_uuid;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			tag_type
		SET
			type = NEW.type,
			description = NEW.description,
			mod_date = now()
		WHERE
			tag_type.tag_type_uuid = NEW.tag_type_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO tag_type (type, description)
			VALUES(NEW.type, NEW.description) returning tag_type_uuid into NEW.tag_type_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_tag()
Parameters:		trigger proc that deletes, inserts or updates tag record based on TG_OP (trigger operation)				
Returns:		void
Author:			G. Cattabriga
Date:			2020.06.22
Description:	trigger proc that deletes, inserts or updates tag record based on TG_OP (trigger operation)
Notes:			will not be able to delete a tag if any connected records in tag_x exist 
 
Example:		-- insert new tag  (tag_uuid = NULL, ref_tag_uuid = NULL)
 				insert into vw_tag (display_text, description, actor_uuid, tag_type_uuid) 
 					values ('invalid', 'invalid experiment', (select actor_uuid from vw_actor where person_last_name = 'Alves'), null);
 				update vw_tag set description = 'invalid experiment with stuff added', 
 					tag_type_uuid = (select tag_type_uuid from vw_tag_type where type = 'experiment') 
 					where tag_uuid = (select tag_uuid from vw_tag where (display_text = 'invalid'));	
 				delete from vw_tag where tag_uuid = (select tag_uuid from vw_tag where (display_text = 'invalid' and type = 'experiment'));						
 */
CREATE OR REPLACE FUNCTION upsert_tag ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_tag_uuid uuid;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM tag
		WHERE tag_uuid = OLD.tag_uuid;
		-- delete any associated notes using the tag_uuid
		DELETE FROM vw_note
		WHERE ref_note_uuid = OLD.tag_uuid;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			tag
		SET
			display_text = NEW.display_text,
			description = NEW.description,
			tag_type_uuid = NEW.tag_type_uuid,
			actor_uuid = NEW.actor_uuid,
			mod_date = now()
		WHERE
			tag.tag_uuid = NEW.tag_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO tag (display_text, description, tag_type_uuid, actor_uuid)
			VALUES(NEW.display_text, NEW.description, NEW.tag_type_uuid, NEW.actor_uuid) returning tag_uuid into NEW.tag_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_tag_assign()
Parameters:		trigger proc that deletes, inserts or updates tag_x record based on TG_OP (trigger operation)				
Returns:		void
Author:			G. Cattabriga
Date:			2020.06.22
Description:	trigger proc that deletes, inserts or updates tag_x record based on TG_OP (trigger operation)
Notes:			requires both ref_tag_uuid and tag_uuid
 
Example:		-- insert new tag_assign (ref_tag) 
 				insert into vw_tag_assign (tag_uuid, ref_tag_uuid) values ((select tag_uuid from vw_tag 
 					where (display_text = 'inactive' and vw_tag.type = 'actor')), (select actor_uuid from vw_actor where person_last_name = 'Alves') );
 				delete from vw_tag_assign where tag_uuid = (select tag_uuid from vw_tag 
 					where (display_text = 'inactive' and vw_tag.type = 'actor') and ref_tag_uuid = (select actor_uuid from vw_actor where person_last_name = 'Alves') );						
 */
CREATE OR REPLACE FUNCTION upsert_tag_assign ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_tag_uuid uuid;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM tag_x
		WHERE (tag_uuid = OLD.tag_uuid)
			and(ref_tag_uuid = OLD.ref_tag_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO tag_x (ref_tag_uuid, tag_uuid)
		VALUES(NEW.ref_tag_uuid, NEW.tag_uuid);
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_udf_def()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.06.22
Description:	trigger proc that deletes, inserts or updates udf_def record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_udf_def (description, val_type_uuid) 
					values ('user defined 1', (select type_def_uuid from vw_type_def where category = 'data' and description = 'text'));
				update vw_udf_def set unit = 'test-unit' where
 					udf_def_uuid = (select udf_def_uuid from vw_udf_def where (description = 'user defined 1'));
 				delete from vw_udf_def where udf_def_uuid = (select udf_def_uuid from udf_def where (description = 'user defined 1'));
 */
CREATE OR REPLACE FUNCTION upsert_udf_def ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the udf_def record
		DELETE FROM udf_def
		WHERE udf_def_uuid = OLD.udf_def_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- then delete any associated note record
		DELETE FROM vw_note
		WHERE ref_note_uuid = OLD.udf_def_uuid;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			udf_def
		SET
			val_type_uuid = NEW.val_type_uuid,
			description = NEW.description,
			unit = NEW.unit,
			mod_date = now()
		WHERE
			udf_def.udf_def_uuid = NEW.udf_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO udf_def (description, val_type_uuid, unit)
			VALUES(NEW.description, NEW.val_type_uuid, NEW.unit) returning udf_def_uuid into NEW.udf_def_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_udf()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.09.07
Description:	trigger proc that deletes, inserts or updates udf record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_udf (ref_udf_uuid, udf_def_uuid, udf_val_val) values 
					((select actor_uuid from vw_actor where description = 'HC'),
					(select udf_def_uuid from vw_udf_def where description = 'user defined 1') 
					, 'some text: a, b, c, d');
 				update vw_udf set udf_val_val = 'some more text: a, b, c, d, e, f' where
 					udf_def_uuid = (select udf_def_uuid from vw_udf_def where (description = 'user defined 1'));
 				delete from vw_udf where udf_def_uuid = (select udf_def_uuid from udf_def where (description = 'user defined 1'));
 */
CREATE OR REPLACE FUNCTION upsert_udf ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the udf_x record
		DELETE FROM udf_x
		WHERE udf_uuid = OLD.udf_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		DELETE FROM udf
		WHERE udf_uuid = OLD.udf_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- then delete any associated note record
		DELETE FROM vw_note
		WHERE ref_note_uuid = OLD.udf_def_uuid;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			udf
		SET
			udf_val = (select put_val (NEW.udf_val_type_uuid, NEW.udf_val_val, NEW.udf_val_unit)),
			mod_date = now()
		WHERE
			udf.udf_uuid = NEW.udf_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF NEW.udf_def_uuid is null THEN
			return null;
		END IF;
		INSERT INTO udf (udf_def_uuid, udf_val)
			VALUES(NEW.udf_def_uuid, 
				(select put_val ((select val_type_uuid from vw_udf_def where udf_def_uuid = NEW.udf_def_uuid), 
					NEW.udf_val_val, 
					(select unit from vw_udf_def where udf_def_uuid = NEW.udf_def_uuid)))) returning udf_uuid into NEW.udf_uuid;
		INSERT INTO udf_x (ref_udf_uuid, udf_uuid)
			VALUES (NEW.ref_udf_uuid, NEW.udf_uuid);
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_status()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.06.20
Description:	trigger proc that deletes, inserts or updates status record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_status (description) values ('testtest');
 				update vw_status set description = 'testtest status' where status_uuid = (select status_uuid from vw_status where (description = 'testtest'));
 				delete from vw_status where status_uuid = (select status_uuid from vw_status where (description = 'testtest status'));
 */
CREATE OR REPLACE FUNCTION upsert_status ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the status record
		DELETE FROM status
		WHERE status_uuid = OLD.status_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		DELETE FROM vw_note
		WHERE ref_note_uuid = OLD.status_uuid;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			status
		SET
			description = NEW.description,
			mod_date = now()
		WHERE
			status.status_uuid = NEW.status_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO status (description)
			VALUES(NEW.description) returning status_uuid into NEW.status_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;



/*
Name:			upsert_type_def()
Parameters:		type_def_category (enum type) and description required on insert 

Returns:		void
Author:			G. Cattabriga
Date:			2020.09.01
Description:	trigger proc that deletes, inserts or updates note and note_x (for the object ref_note_uuid) based on TG_OP (trigger operation)
Notes:			must have ref_note_uuid in order to return appropriate notes for that entity
 
Example:		insert into vw_type_def (category, description) values ('data', 'bool');
				insert into vw_type_def (category, description) values ('file', 'pdf');
				update vw_type_def set description = 'svg' where type_def_uuid = (select type_def_uuid from 
					vw_type_def where category = 'file' and description = 'pdf');
				delete from vw_type_def where type_def_uuid = (select type_def_uuid from vw_type_def where category = 'data' and description = 'bool');
				delete from vw_type_def where type_def_uuid = (select type_def_uuid from vw_type_def where category = 'file' and description = 'svg');	
 */
CREATE OR REPLACE FUNCTION upsert_type_def ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM type_def
		WHERE type_def_uuid = OLD.type_def_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			type_def
		SET
			category = NEW.category,
			description = NEW.description,
			mod_date = now()
		WHERE
			type_def.type_def_uuid = NEW.type_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO type_def (category, description)
			VALUES(NEW.category, NEW.description)
		RETURNING type_def_uuid INTO NEW.type_def_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_note()
Parameters:		ref_note_uuid required on insert 

Returns:		void
Author:			G. Cattabriga
Date:			2020.06.26
Description:	trigger proc that deletes, inserts or updates note and note_x (for the object ref_note_uuid) based on TG_OP (trigger operation)
Notes:			must have ref_note_uuid in order to return appropriate notes for that entity
 
Example:		insert into vw_note (notetext, actor_uuid, ref_note_uuid) values ('test note', (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'), (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));
 insert into vw_note (notetext, actor_uuid) values ('test note', (select actor_uuid from vw_actor where person_last_name = 'Cattabriga'));

 				update vw_note set notetext = 'test note with additional text...' where note_uuid = (select note_uuid from vw_note where (notetext = 'test note'));
 				delete from vw_note where note_uuid = (select note_uuid from vw_note where (notetext = 'test note with additional text...'));
 				--- delete all notes associated with a given entity
 				insert into vw_note (notetext, actor_uuid, ref_note_uuid) values ('test note 1', (select actor_uuid from vw_actor where person_last_name = 'Alves'), (select actor_uuid from vw_actor where person_last_name = 'Alves'));
 				insert into vw_note (notetext, actor_uuid, ref_note_uuid) values ('test note 2', (select actor_uuid from vw_actor where person_last_name = 'Alves'), (select actor_uuid from vw_actor where person_last_name = 'Alves'));
 				insert into vw_note (notetext, actor_uuid, ref_note_uuid) values ('test note 2', (select actor_uuid from vw_actor where person_last_name = 'Alves'), (select actor_uuid from vw_actor where person_last_name = 'Alves'));
 				delete from vw_note where note_uuid in (select note_uuid from vw_note where actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Alves'));
 */
CREATE OR REPLACE FUNCTION upsert_note ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_note_uuid uuid;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM note_x
		WHERE note_x_uuid = OLD.note_x_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		DELETE FROM note
		WHERE note_uuid = OLD.note_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			note
		SET
			notetext = NEW.notetext,
			mod_date = now()
		WHERE
			note.note_uuid = NEW.note_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF NEW.ref_note_uuid IS NULL THEN
			RETURN NULL;
		END IF;
		INSERT INTO note (notetext, actor_uuid)
			VALUES(NEW.notetext, NEW.actor_uuid)
		RETURNING
			note_uuid INTO _note_uuid;
		INSERT INTO note_x (ref_note_uuid, note_uuid)
			VALUES(NEW.ref_note_uuid, _note_uuid) returning _note_uuid into NEW.note_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_edocument()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.12
Description:	trigger proc that deletes, inserts or updates edocument record based on TG_OP (trigger operation)
Notes:				
 
Example:		-- just insert the document, with no association to an entity
				insert into vw_edocument (title, description, filename, source, edocument, doc_type_uuid, doc_ver,
					actor_uuid, status_uuid, ref_edocument_uuid) 
					values ('Test document 1', 'This is a test document', null, null, 'a bunch of text cast as a blob'::bytea, (select type_def_uuid from vw_type_def where category = 'file' and description = 'text'), null,
					(select actor_uuid from vw_actor where description = 'Gary Cattabriga'), (select status_uuid from vw_status where description = 'active'),
					null);
				-- now associate the edocument to an actor
				update vw_edocument set ref_edocument_uuid = (select actor_uuid from vw_actor where description = 'Gary Cattabriga') where 
					edocument_uuid = (select edocument_uuid from vw_edocument where title = 'Test document 1');
				delete from vw_edocument where edocument_uuid = (select edocument_uuid from vw_edocument where title = 'Test document 1');

*/
CREATE OR REPLACE FUNCTION upsert_edocument ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_edocument_uuid uuid;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the document_x record if exists
		DELETE FROM edocument_x
		WHERE edocument_x_uuid = OLD.edocument_x_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		DELETE FROM edocument
		WHERE edocument_uuid = OLD.edocument_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		DELETE FROM vw_note
		WHERE ref_note_uuid = OLD.edocument_uuid;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			edocument
		SET
			title = NEW.title,
			description = NEW.description,
			filename = NEW.filename,
			source = NEW.source,
			edocument = NEW.edocument,
			doc_type_uuid = NEW.doc_type_uuid,
			doc_ver = NEW.doc_ver,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			edocument.edocument_uuid = NEW.edocument_uuid;
		INSERT INTO edocument_x (ref_edocument_uuid, edocument_uuid)
				VALUES(NEW.ref_edocument_uuid, NEW.edocument_uuid) ON CONFLICT DO NOTHING;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO edocument (title, description, filename, source, edocument, doc_type_uuid, doc_ver, actor_uuid, status_uuid)
			VALUES(NEW.title, NEW.description, NEW.filename, NEW.source, NEW.edocument, NEW.doc_type_uuid, NEW.doc_ver,
			NEW.actor_uuid, NEW.status_uuid)
		RETURNING edocument_uuid INTO NEW.edocument_uuid;
		IF NEW.ref_edocument_uuid IS NOT NULL THEN
			INSERT INTO edocument_x (ref_edocument_uuid, edocument_uuid)
				VALUES(NEW.ref_edocument_uuid, NEW.edocument_uuid);
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


--======================================================================
--======================================================================

/*
Name:				upsert_actor ()
Parameters:		

Returns:			void
Author:				G. Cattabriga
Date:				2020.07.15
Description:		trigger proc that deletes, inserts or updates actor 
Notes:				there is going to be a lot of dependencies on actor, so a 'delete' will need a lot of cleanup first; easier to just change status to 'inactive' or something like that
 
Example:			insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) 
						values ('Tester','Lester','Fester','1313 Mockingbird Ln',null,'Munsterville','NY',null,null,null,null,null,null,null) returning *;
					delete from vw_person where person_uuid = (select person_uuid from vw_person 
						where (last_name = 'Tester' and first_name = 'Lester'));
					insert into vw_actor (person_uuid, description, status_uuid) 
						values ((select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester')), 'Lester the Actor', 
						(select status_uuid from vw_status where description = 'active')) returning *;
					-- now add a note
					insert into vw_note (notetext, actor_uuid, ref_note_uuid) 
						values ('test note for Lester the Actor', (select actor_uuid from vw_actor where person_last_name = 'Tester'), 
						(select actor_uuid from vw_actor where person_last_name = 'Tester'));
					-- assign a tag
					insert into vw_tag_assign (tag_uuid, ref_tag_uuid) 
						values ((select tag_uuid from vw_tag where (display_text = 'do_not_use' and type = 'actor')), 
						(select actor_uuid from vw_actor where person_last_name = 'Tester'));
					-- assign a udf
					insert into vw_udf (ref_udf_uuid, udf_def_uuid, udf_val_val) values
					((select actor_uuid from vw_actor where person_last_name = 'Tester'), 
					(select udf_def_uuid from vw_udf_def where description = 'batch count'),
					'123 -> batch no. test');					
					-- update the description for the actor
					update vw_actor set description = 'new description for Lester the Actor' 
						where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));
 					update vw_actor set organization_uuid = (select organization_uuid from vw_organization where full_name = 'Haverford College') 
 						where person_uuid = (select person_uuid from person where (last_name = 'Tester' and first_name = 'Lester'));
					delete from vw_actor where actor_uuid in (select actor_uuid from vw_actor where description = 'Lester the Actor');
					delete from vw_note where note_uuid in (select note_uuid from vw_note where actor_uuid = (select actor_uuid from vw_actor where person_last_name = 'Tester'));
 					delete from vw_actor where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));
 */
CREATE OR REPLACE FUNCTION upsert_actor ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete all the actor_pref records
		DELETE FROM vw_actor_pref
		WHERE actor_uuid = OLD.actor_uuid;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.actor_uuid);
		-- then delete the actor record
		DELETE FROM actor
		WHERE actor_uuid = OLD.actor_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- then delete the associated [sub]actor (org, person, systemtool)
		IF OLD.organization_uuid is not NULL THEN
			DELETE FROM vw_organization WHERE organization_uuid = OLD.organization_uuid;
		ELSIF OLD.person_uuid is not NULL THEN
			DELETE FROM vw_person WHERE person_uuid = OLD.person_uuid;	
		ELSIF OLD.person_uuid is not NULL THEN
			DELETE FROM vw_systemtool WHERE systemtool_uuid = OLD.systemtool_uuid;
		END IF;	
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			actor
		SET
			organization_uuid = NEW.organization_uuid,
			person_uuid = NEW.person_uuid,
			systemtool_uuid = NEW.systemtool_uuid,
			description = NEW.description,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			actor.actor_uuid = NEW.actor_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF (NEW.organization_uuid is NULL and NEW.person_uuid is NULL and NEW.systemtool_uuid is NULL) THEN
			RETURN NULL;
		ELSE
			INSERT INTO actor (organization_uuid, person_uuid, systemtool_uuid, description, status_uuid)
				VALUES(NEW.organization_uuid, NEW.person_uuid, NEW.systemtool_uuid, NEW.description, NEW.status_uuid) returning actor_uuid into NEW.actor_uuid;
			RETURN NEW;
		END IF;
	END IF;
END;
$$
LANGUAGE plpgsql;



/*
Name:			upsert_actor_pref()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.07.20
Description:	trigger proc that deletes, inserts or updates actor_pref record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_actor_pref (actor_uuid, pkey, pvalue) values ((select actor_uuid from vw_actor where person_last_name = 'Tester'), 'test_key', 'test_value');
 				update vw_actor_pref set pvalue = 'new_new_test_value' where actor_pref_uuid = (select actor_pref_uuid from vw_actor_pref where actor_uuid = (select actor_uuid from vw_actor where description = 'Lester Fester Tester') and pkey = 'test_key');
 				delete from vw_actor_pref where actor_pref_uuid = (select actor_pref_uuid from vw_actor_pref where actor_uuid = (select actor_uuid from vw_actor where description = 'Lester Fester Tester'));
 */
CREATE OR REPLACE FUNCTION upsert_actor_pref ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the actor_pref record
		DELETE FROM actor_pref
		WHERE actor_pref_uuid = OLD.actor_pref_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.actor_pref_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			actor_pref
		SET
			pkey = NEW.pkey,
			pvalue = NEW.pvalue,
			mod_date = now()
		WHERE
			actor_pref.actor_pref_uuid = NEW.actor_pref_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO actor_pref (actor_uuid, pkey, pvalue)
			VALUES(NEW.actor_uuid, NEW.pkey, NEW.pvalue) returning actor_pref_uuid into NEW.actor_pref_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;



/*
Name:				upsert_organization ()
Parameters:		

Returns:			void
Author:				G. Cattabriga
Date:				2020.06.16
Description:		trigger proc that deletes, inserts or updates organization record based on TG_OP (trigger operation)
Notes:				added functionality to insert a NEW organization into a NEW actor
							
Example:			-- note: this insert also inserts record into actor
					insert into vw_organization (description, full_name, short_name, address1, address2, city, state_province, zip, country, website_url, phone, parent_uuid) values ('some description here','IBM','IBM','1001 IBM Lane',null,'Some City','NY',null,null,null,null,null);
					update vw_organization set description = 'some [new] description here', city = 'Some [new] City', zip = '00000' where full_name = 'IBM';
					update vw_organization set parent_uuid =  (select organization_uuid from organization where organization.full_name = 'Haverford College') where full_name = 'IBM';
					-- if related actor exists, will not be able to delete
					delete from vw_organization where full_name = 'IBM';
					delete from vw_actor where organization_uuid = (select organization_uuid from vw_organization where full_name = 'IBM');
			
*/
CREATE OR REPLACE FUNCTION upsert_organization ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_org_uuid uuid;
	_org_description varchar;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the ornanization record
		DELETE FROM organization
		WHERE organization_uuid = OLD.organization_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.organization_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			organization
		SET
			description = NEW.description,
			full_name = NEW.full_name,
			short_name = NEW.short_name,
			address1 = NEW.address1,
			address2 = NEW.address2,
			city = NEW.city,
			state_province = NEW.state_province,
			zip = NEW.zip,
			country = NEW.country,
			website_url = NEW.website_url,
			phone = NEW.phone,
			parent_uuid = NEW.parent_uuid,
			mod_date = now()
		WHERE
			organization.full_name = NEW.full_name;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO organization (description, full_name, short_name, address1, address2, city, state_province, zip, country, website_url, phone, parent_uuid) VALUES(NEW.description, NEW.full_name, NEW.short_name, NEW.address1, NEW.address2, NEW.city, NEW.state_province, NEW.zip, NEW.country, NEW.website_url, NEW.phone, NEW.parent_uuid) returning organization_uuid, short_name into _org_uuid, _org_description;
		insert into vw_actor (organization_uuid, description, status_uuid) values (_org_uuid, _org_description, (select status_uuid from vw_status where description = 'active')) returning _org_uuid into NEW.organization_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:				upsert_person ()
Parameters:		

Returns:			void
Author:				G. Cattabriga
Date:				2020.06.17
Description:		trigger proc that deletes, inserts or updates person record based on TG_OP (trigger operation)
Notes:				added functionality to insert a NEW organization into a NEW actor
 
Example:			-- note: this insert also inserts record into actor
					insert into vw_person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) 
					values ('Tester','Lester','Fester','1313 Mockingbird Ln',null,'Munsterville','NY',null,null,null,null,null,null,null) returning *;
 					update vw_person set title = 'Mr', city = 'Some [new] City', zip = '99999', email = 'TesterL@scarythings.xxx' where person_uuid = 
 					(select person_uuid from person where (last_name = 'Tester' and first_name = 'Lester')) returning *;
 					update vw_person set organization_uuid =  (select organization_uuid from organization where organization.full_name = 'Haverford College') where (last_name = 'Tester' and first_name = 'Lester') returning *;
 					delete from vw_person where person_uuid = (select person_uuid from person where (last_name = 'Tester' and first_name = 'Lester'));
					delete from vw_actor where person_uuid = (select person_uuid from vw_person where (last_name = 'Tester' and first_name = 'Lester'));
 */
CREATE OR REPLACE FUNCTION upsert_person ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_person_uuid uuid;
	_person_first_name varchar;
	_person_middle_name varchar;
	_person_last_name varchar;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the person record
		DELETE FROM person
		WHERE person_uuid = OLD.person_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.person_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			person
		SET
			last_name = NEW.last_name,
			first_name = NEW.first_name,
			middle_name = NEW.middle_name,
			address1 = NEW.address1,
			address2 = NEW.address2,
			city = NEW.city,
			state_province = NEW.state_province,
			zip = NEW.zip,
			country = NEW.country,
			phone = NEW.phone,
			email = NEW.email,
			title = NEW.title,
			suffix = NEW.suffix,
			organization_uuid = NEW.organization_uuid,
			mod_date = now()
		WHERE
			person.person_uuid = NEW.person_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO person (last_name, first_name, middle_name, address1, address2, city, state_province, zip, country, phone, email, title, suffix, organization_uuid) VALUES(NEW.last_name, NEW.first_name, NEW.middle_name, NEW.address1, NEW.address2, NEW.city, NEW.state_province, NEW.zip, NEW.country, NEW.phone, NEW.email, NEW.title, NEW.suffix, NEW.organization_uuid) returning person_uuid, first_name, middle_name, last_name  into _person_uuid, _person_first_name, _person_middle_name, _person_last_name;
		insert into vw_actor (person_uuid, description, status_uuid) values (_person_uuid, trim(concat(_person_first_name,' ', _person_last_name)), (select status_uuid from vw_status where description = 'active')) returning _person_uuid into NEW.person_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_systemtool()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.06.17
Description:	trigger proc that deletes, inserts or updates systemtool record based on TG_OP (trigger operation)
Notes:			added functionality to insert a NEW organization into a NEW actor
 
Example:		-- note: this insert also inserts record into actor
				insert into vw_systemtool (systemtool_name, description, systemtool_type_uuid, vendor_organization_uuid, model, serial, ver) values ('MRROBOT', 'MR Robot to you',(select systemtool_type_uuid from vw_systemtool_type where description = 'API'),(select organization_uuid from vw_organization where full_name = 'ChemAxon'),'super duper', null, '1.0') returning *;
 				update vw_systemtool set serial = 'ABC-1234' where systemtool_uuid = (select systemtool_uuid from vw_systemtool where (systemtool_name = 'MRROBOT'));
 				update vw_systemtool set ver = '1.1' where systemtool_uuid = (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT');
 				update vw_systemtool set ver = '1.2' where systemtool_uuid = (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT' and ver = '1.1');
 				delete from actor where systemtool_uuid in (select systemtool_uuid from systemtool where systemtool_name = 'MRROBOT');
 				delete from vw_systemtool where systemtool_uuid in (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT');
 				delete from vw_systemtool where systemtool_uuid = (select systemtool_uuid from vw_systemtool where systemtool_name = 'MRROBOT' and ver = '1.1');

 */
CREATE OR REPLACE FUNCTION upsert_systemtool ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_systemtool_uuid uuid;
	_systemtool_description varchar;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the systemtool record
		DELETE FROM systemtool
		WHERE systemtool_uuid = OLD.systemtool_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.systemtool_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		-- check to see if it's a version change of the tool. if so, then create a new record
		if(OLD.ver != NEW.ver) THEN
			INSERT INTO systemtool (systemtool_name, description, systemtool_type_uuid, vendor_organization_uuid, model, serial, ver) VALUES(NEW.systemtool_name, NEW.description, NEW.systemtool_type_uuid, NEW.vendor_organization_uuid, NEW.model, NEW.serial, NEW.ver) returning systemtool_uuid, description into _systemtool_uuid, _systemtool_description;
			insert into vw_actor (systemtool_uuid, description, status_uuid) values (_systemtool_uuid, _systemtool_description, (select status_uuid from vw_status where description = 'active'));			
			RETURN NEW;
		ELSE
			UPDATE
				systemtool
			SET
				systemtool_name = NEW.systemtool_name,
				description = NEW.description,
				systemtool_type_uuid = NEW.systemtool_type_uuid,
				vendor_organization_uuid = NEW.vendor_organization_uuid,
				model = NEW.model,
				serial = NEW.serial,
				ver = NEW.ver,
				mod_date = now()
			WHERE
				systemtool.systemtool_uuid = NEW.systemtool_uuid;
			RETURN NEW;
		END IF;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO systemtool (systemtool_name, description, systemtool_type_uuid, vendor_organization_uuid, model, serial, ver) VALUES(NEW.systemtool_name, NEW.description, NEW.systemtool_type_uuid, NEW.vendor_organization_uuid, NEW.model, NEW.serial, NEW.ver) returning systemtool_uuid, description into _systemtool_uuid, _systemtool_description;
		insert into vw_actor (systemtool_uuid, description, status_uuid) values (_systemtool_uuid, _systemtool_description, (select status_uuid from vw_status where description = 'active')) returning _systemtool_uuid into NEW.systemtool_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_systemtool_type()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.06.17
Description:	trigger proc that deletes, inserts or updates systemtool_type record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_systemtool_type (description) values ('TEST Systemtool Type');
				delete from vw_systemtool_type where systemtool_type_uuid = (select systemtool_type_uuid from vw_systemtool_type where (description = 'TEST Systemtool Type'));
 */
CREATE OR REPLACE FUNCTION upsert_systemtool_type ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the systemtool_type record
		DELETE FROM systemtool_type
		WHERE systemtool_type_uuid = OLD.systemtool_type_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.systemtool_type_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			systemtool_type
		SET
			description = NEW.description,
			mod_date = now()
		WHERE
			systemtool_type.systemtool_type_uuid = NEW.systemtool_type_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO systemtool_type (description)
			VALUES(NEW.description) returning systemtool_type_uuid into NEW.systemtool_type_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;



/*
Name:			upsert_material_type()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.06.24
Description:	trigger proc that deletes, inserts or updates material_type record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_material_type (description) values ('materialtype_test');
 				delete from vw_material_type where material_type_uuid = (select material_type_uuid from vw_material_type where (description = 'materialtype_test'));
 */
CREATE OR REPLACE FUNCTION upsert_material_type ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the material_type record
		DELETE FROM material_type
		WHERE material_type_uuid = OLD.material_type_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.material_type_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			material_type
		SET
			description = NEW.description,
			mod_date = now()
		WHERE
			material_type.material_type_uuid = NEW.material_type_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO material_type (description)
			VALUES(NEW.description) returning material_type_uuid into NEW.material_type_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_material_refname_def()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.06.26
Description:	trigger proc that deletes, inserts or updates material_refname_def record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_material_refname_def (description) values ('materialrefnamedef_test');
 				delete from vw_material_refname_def where material_refname_def_uuid = (select material_refname_def_uuid from vw_material_refname_def where (description = 'materialrefnamedef_test'));
 */
CREATE OR REPLACE FUNCTION upsert_material_refname_def ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the material_refname_def record
		DELETE FROM material_refname_def
		WHERE material_refname_def_uuid = OLD.material_refname_def_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.material_refname_def_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			material_refname_def
		SET
			description = NEW.description,
			mod_date = now()
		WHERE
			material_refname_def.material_refname_def_uuid = NEW.material_refname_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO material_refname_def (description)
			VALUES(NEW.description) returning material_refname_def_uuid into NEW.material_refname_def_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_material()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.07.20
Description:	trigger proc that deletes, inserts or updates material record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_material (material_description) values ('materialrefnamedef_test');
 				delete from vw_material_refname_def where material_refname_def_uuid = (select material_refname_def_uuid from vw_material_refname_def where (description = 'materialrefnamedef_test'));
 */
CREATE OR REPLACE FUNCTION upsert_material ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the material_refname_def record
		DELETE FROM material
		WHERE material_uuid = OLD.material_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.material_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			material
		SET
			description = NEW.description,
			mod_date = now()
		WHERE
			material.material_uuid = NEW.material_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO material (description)
			VALUES(NEW.description) returning material_uuid into NEW.material_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_property_def()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.03
Description:	trigger proc that deletes, inserts or updates property_def record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid ) values 
											('particle-size {min, max}', 'particle-size', 
											(select get_type_def ('data', 'array_num')), 
											'mesh', 
											null,
											(select status_uuid from vw_status where description = 'active')
											);
				update vw_property_def set short_description = 'particle-size',
											actor_uuid = (select actor_uuid from vw_actor where org_short_name = 'LANL') where (short_description = 'particle-size');
 				delete from vw_property_def where short_description = 'particle-size';
 */
CREATE OR REPLACE FUNCTION upsert_property_def ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the property_def record
		DELETE FROM property_def
		WHERE property_def_uuid = OLD.property_def_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.property_def_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			property_def
		SET
			description = NEW.description,
			short_description = NEW.short_description,
			val_type_uuid = NEW.val_type_uuid,
			valunit = NEW.valunit,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			property_def.property_def_uuid = NEW.property_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO property_def (description, short_description, val_type_uuid, valunit, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.short_description, NEW.val_type_uuid, NEW.valunit, NEW.actor_uuid, NEW.status_uuid) returning property_def_uuid into NEW.property_def_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_property()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.04
Description:	trigger proc that deletes, inserts or updates property record based on TG_OP (trigger operation)
Notes:			AVOID THIS FUNCTION as it will isolate property records	
 
Example:		insert into vw_property (property_def_uuid, property_val, actor_uuid, status_uuid ) values (
											(select property_def_uuid from vw_property_def where short_description = 'particle-size'),
											(select put_val (
												(select val_type_uuid from vw_property_def where short_description = 'particle-size'),
												'{100, 200}'::int[],
												(select valunit from vw_property_def where short_description = 'particle-size'))), 
											(select actor_uuid from vw_actor where org_short_name = 'LANL'),
											(select status_uuid from vw_status where description = 'active')
											);
 				delete from vw_property where (property_val = (select put_val (
												(select val_type_uuid from vw_property_def where short_description = 'particle-size'),
												'{100, 200}'::int[],
												(select valunit from vw_property_def where short_description = 'particle-size'))));
 */
CREATE OR REPLACE FUNCTION upsert_property ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the property record
		DELETE FROM property
		WHERE property_uuid = OLD.property_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.property_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			property
		SET
			property_val = NEW.property_val,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			property.property_uuid = NEW.property_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF (select exists (select property_def_uuid from vw_property_def where property_def_uuid = NEW.property_def_uuid)) THEN
			INSERT INTO property (property_def_uuid, property_val, actor_uuid, status_uuid)
				VALUES(NEW.property_def_uuid, NEW.property_val, NEW.actor_uuid, NEW.status_uuid) returning property_uuid into NEW.property_uuid;
			RETURN NEW;
		END IF;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_material_property()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.04
Description:	trigger proc that deletes, inserts or updates property record based on TG_OP (trigger operation)
Notes:			this will check to see if property_def exists, also will add entry into property_x to join material_uuid with property_uuid
				on insert, will inherit the data type and unit from property_def	
 
Example:		insert into vw_material_property (material_uuid, property_def_uuid, 
					val_val, property_actor_uuid, property_status_uuid ) 
					values ((select material_uuid from vw_material where description = 'Formic Acid'),
							(select property_def_uuid from vw_property_def where short_description = 'particle-size'),
							'{100, 200}', 
							null,
							(select status_uuid from vw_status where description = 'active')
				) returning *;
				update vw_material_property set property_actor_uuid = (select actor_uuid from vw_actor where org_short_name = 'LANL') where material_uuid = 
				(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'particle-size';
				update vw_material_property set val_val = '{100, 900}' where material_uuid = 
				(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'particle-size';
 				delete from vw_material_property where material_uuid = 
				(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'particle-size';
 */
CREATE OR REPLACE FUNCTION upsert_material_property ()
	RETURNS TRIGGER
	AS $$
DECLARE
	_property_uuid uuid;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the property_x record
		DELETE FROM property_x
		WHERE property_uuid = OLD.property_uuid and material_uuid = OLD.material_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		DELETE FROM property
		WHERE property_uuid = OLD.property_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.property_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			property
		SET
			property_val = 
				(select put_val (NEW.v_type_uuid, NEW.val_val, NEW.val_unit)),
			actor_uuid = NEW.property_actor_uuid,
			status_uuid = NEW.property_status_uuid,
			mod_date = now()
		WHERE
			property.property_uuid = NEW.property_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF (select exists (select property_def_uuid from vw_property_def where property_def_uuid = NEW.property_def_uuid)) THEN
			IF (NEW.material_uuid is null) or (NEW.property_uuid is not null) THEN
				return null;
			END IF;
			INSERT INTO property (property_def_uuid, property_val, actor_uuid, status_uuid)
				VALUES(NEW.property_def_uuid, 
					(select put_val ((select val_type_uuid from vw_property_def where property_def_uuid = NEW.property_def_uuid), 
					NEW.val_val, 
					(select valunit from vw_property_def where property_def_uuid = NEW.property_def_uuid))),	
				NEW.property_actor_uuid, NEW.property_status_uuid)
			RETURNING property_uuid into NEW.property_uuid;
			INSERT INTO property_x (material_uuid, property_uuid)
				VALUES (NEW.material_uuid, NEW.property_uuid) returning property_x_uuid into NEW.property_x_uuid;
			RETURN NEW;
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_calculation_def()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.17
Description:	trigger proc that deletes, inserts or updates calculation_def record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_calculation_def (short_name, calc_definition, systemtool_uuid, description, in_source, in_type_uuid, in_opt_source, in_opt_type_uuid, 						out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid ) 
					values ('test_calc_def', 'function param1 param2', 
					(select systemtool_uuid from vw_actor where description = 'Molecule Standardizer'),
					'testing calculation definition upsert', 'standardize', 
					(select type_def_uuid from vw_type_def where category = 'data' and description = 'text'),
					null, null, 
					(select type_def_uuid from vw_type_def where category = 'data' and description = 'int'),
					null, (select actor_uuid from vw_actor where description = 'Gary Cattabriga'),
					(select status_uuid from vw_status where description = 'active')		
					) returning *;

	
 */
CREATE OR REPLACE FUNCTION upsert_calculation_def ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the property_def record
		DELETE FROM calculation_def
		WHERE calculation_def_uuid = OLD.calculation_def_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.calculation_def_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			calculation_def
		SET
			short_name = NEW.short_name,
			calc_definition = NEW.calc_definition,
			systemtool_uuid = NEW.systemtool_uuid,
			description = NEW.description,
			in_source_uuid = NEW.in_source_uuid,
			in_type_uuid = NEW.in_type_uuid,
			in_opt_source = NEW.in_opt_source,
			in_opt_type_uuid = NEW.in_opt_type_uuid,	
			out_type_uuid = NEW.out_type_uuid,		
			calculation_class_uuid = NEW.calculation_class_uuid,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			calculation_def.calculation_def_uuid = NEW.calculation_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO calculation_def (short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source, in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid)
			VALUES(NEW.short_name, NEW.calc_definition, NEW.systemtool_uuid, NEW.description, NEW.in_source, NEW.in_type_uuid, NEW.in_opt_source, NEW.in_opt_type_uuid, NEW.out_type_uuid, NEW.calculation_class_uuid, NEW.actor_uuid, NEW.status_uuid) returning calculation_def_uuid into NEW.calculation_def_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_calculation()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.19
Description:	trigger proc that deletes, inserts or updates calculation record based on TG_OP (trigger operation)
Notes:			this will check to see if calculation_def exists	
 
Example:		

 */
CREATE OR REPLACE FUNCTION upsert_calculation ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the property record
		DELETE FROM calculation
		WHERE calculation_uuid = OLD.calculation_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.calculation_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			calculation
		SET
			calculation_alias_name = NEW.calculation_alias_name,
			in_val = NEW.in_val,
			in_opt_val = NEW.in_opt_val,
			out_val = NEW.out_val,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			calculation.calculation_uuid = NEW.calculation_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF (select exists (select calculation_def_uuid from vw_calculation_def where calculation_def_uuid = NEW.calculation_def_uuid)) THEN
			INSERT INTO property (calculation_def_uuid, calculation_alias_name, in_val, in_opt_val, out_val, actor_uuid, status_uuid)
				VALUES(NEW.calculation_def_uuid, NEW.in_val, NEW.in_opt_val, NEW.OUT_val, NEW.actor_uuid, NEW.status_uuid) returning calculation_uuid into NEW.calculation_uuid;
			RETURN NEW;
		END IF;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_workflow()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.20
Description:	trigger proc that deletes, inserts or updates workflow record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_workflow (workflow_description) values ('workflow_test');
 				delete from vw_workflow where workflow_uuid = ;
 */
CREATE OR REPLACE FUNCTION upsert_workflow ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the material_refname_def record
		DELETE FROM workflow
		WHERE workflow_uuid = OLD.workflow_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.workflow_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			workflow		
		SET
			description = NEW.description,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			workflow.workflow_uuid = NEW.workflow_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO workflow (description, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.actor_uuid, NEW.status_uuid) returning workflow_uuid into NEW.workflow_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_parameter_def()
Parameters:		

Returns:		void
Author:			M. Tynes
Date:			2020.09.15
Description:	trigger proc that deletes, inserts or updates parameter_def record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_parameter_def (description, val_type_uuid, valunit, actor_uuid) values
                                             ('beard_moisturize_dur', (select get_type_def ('data', 'num')), 'hours', (select actor_uuid from vw_actor where description = 'HC'));
				update vw_parameter_def set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'beard_moisturize_dur';
 				delete from vw_parameter_def where description = 'beard_moisturize_dur';
              	insert into vw_parameter_def (description, val_type_uuid, valunit, actor_uuid, status_uuid) values
                              ('duration', (select get_type_def ('data', 'num')), 'hours', 
                              	(select actor_uuid from vw_actor where description = 'HC'), 
                              	(select status_uuid from vw_status where description = 'active')),
                              ('speed', (select get_type_def ('data', 'num')), 'rpm', 
                              	(select actor_uuid from vw_actor where description = 'HC'),
                              	(select status_uuid from vw_status where description = 'active')),
                              ('temperature', (select get_type_def ('data', 'num')), 'degC', 
                              	(select actor_uuid from vw_actor where description = 'HC'),
                              	(select status_uuid from vw_status where description = 'active'));
 */
CREATE OR REPLACE FUNCTION upsert_parameter_def ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
	    -- first delete the property_def record
		DELETE FROM parameter_def
		WHERE parameter_def_uuid = OLD.parameter_def_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.parameter_def_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
	    UPDATE
			parameter_def
		SET
			description = NEW.description,
			val_type_uuid = NEW.val_type_uuid,
			valunit = NEW.valunit,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			parameter_def.parameter_def_uuid = NEW.parameter_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
	    INSERT INTO parameter_def (description, val_type_uuid, valunit, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.val_type_uuid, NEW.valunit, NEW.actor_uuid, NEW.status_uuid) returning parameter_def_uuid into NEW.parameter_def_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
 Name:			upsert_action_def()
 Parameters:

 Returns:		void
 Author:		M. Tynes
 Date:			2020.09.22
 Description:	trigger proc that deletes, inserts or updates action_def record based on TG_OP (trigger operation)
 Notes:

 Example:		insert into vw_action_def (description, actor_uuid) values
                                           ('moisturize_beard', (select actor_uuid from vw_actor where description = 'Ian Pendleton'));
 				update vw_action_def set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'moisturize_beard';
  				delete from vw_action_def where description = 'moisturize_beard';

                insert into vw_action_def (description, actor_uuid, status_uuid) values
                                           ('heat_stir', (select actor_uuid from vw_actor where description = 'Ian Pendleton'),
                                           	(select status_uuid from vw_status where description = 'active')),
                                           ('heat', (select actor_uuid from vw_actor where description = 'Ian Pendleton'),
                                           	(select status_uuid from vw_status where description = 'active'));
  */
 CREATE OR REPLACE FUNCTION upsert_action_def ()
 	RETURNS TRIGGER
 	AS $$
 BEGIN
 	IF(TG_OP = 'DELETE') THEN
 	    -- first delete the property_def record
 		DELETE FROM action_def
 		WHERE action_def_uuid = OLD.action_def_uuid;
 		IF NOT FOUND THEN
 			RETURN NULL;
 		END IF;
 		-- delete any assigned records
 		PERFORM delete_assigned_recs (OLD.action_def_uuid);
 		RETURN OLD;
 	ELSIF (TG_OP = 'UPDATE') THEN
 	    UPDATE
 			action_def
 		SET
 			description = NEW.description,
 			actor_uuid = NEW.actor_uuid,
 			status_uuid = NEW.status_uuid,
 			mod_date = now()
 		WHERE
 			action_def.action_def_uuid = NEW.action_def_uuid;
 		RETURN NEW;
 	ELSIF (TG_OP = 'INSERT') THEN
 	    INSERT INTO action_def (description, actor_uuid, status_uuid)
 			VALUES(NEW.description, NEW.actor_uuid, NEW.status_uuid)
 			returning action_def_uuid into NEW.action_def_uuid;
 		RETURN NEW;
 	END IF;
 END;
 $$
 LANGUAGE plpgsql;


/*
 Name:			upsert_action_parameter_def_assign()
 Parameters:		trigger proc that deletes, inserts or updates action_parameter_def_x record based on TG_OP (trigger operation)
 Returns:		void
 Author:			G. Cattabriga
 Date:			2020.06.22
 Description:	trigger proc that deletes, inserts or updates action_parameter_def_x record based on TG_OP (trigger operation)
 Notes:			requires both ref_action_parameter_def_uuid and action_parameter_def_uuid

 Example:        insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid)
                                                     VALUES ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
                                                             (select parameter_def_uuid from vw_parameter_def where description = 'duration')),
                                                            ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
                                                             (select parameter_def_uuid from vw_parameter_def where description = 'temperature')),
                                                            ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
                                                             (select parameter_def_uuid from vw_parameter_def where description = 'speed')),
                                                             ((select action_def_uuid from vw_action_def where description = 'heat'),
                                                             (select parameter_def_uuid from vw_parameter_def where description = 'duration')),
                                                            ((select action_def_uuid from vw_action_def where description = 'heat'),
                                                             (select parameter_def_uuid from vw_parameter_def where description = 'temperature'));

  */
 CREATE OR REPLACE FUNCTION upsert_action_parameter_def_assign ()
 	RETURNS TRIGGER
 	AS $$
 BEGIN
 	IF(TG_OP = 'DELETE') THEN
 		DELETE FROM action_parameter_def_x
 		WHERE (action_def_uuid = OLD.action_def_uuid)
 			and(parameter_def_uuid = OLD.parameter_def_uuid);
 		RETURN OLD;
 	ELSIF (TG_OP = 'UPDATE') THEN
 		RETURN NEW;
 	ELSIF (TG_OP = 'INSERT') THEN
 		INSERT INTO action_parameter_def_x (action_def_uuid, parameter_def_uuid)
 		VALUES(NEW.action_def_uuid, NEW.parameter_def_uuid);
 		RETURN NEW;
 	END IF;
 END;
 $$
 LANGUAGE plpgsql;


/*
Name:			upsert_parameter()
Parameters:		

Returns:		void
Author:			M.Tynes
Date:			2020.09.18
Description:	trigger proc that deletes, inserts or updates parameter record based on TG_OP (trigger operation)
Notes:
 
Example:		insert into vw_parameter (parameter_def_uuid, ref_parameter_uuid, parameter_val, actor_uuid, status_uuid ) values (
											(select parameter_def_uuid from vw_parameter_def where description = 'beard_moisturize_dur'),
                                            (select person_uuid from vw_person where last_name = 'Pendleton'),
											(select put_val (
												(select val_type_uuid from vw_parameter_def where description = 'beard_moisturize_dur'),
												'10',
												(select valunit from vw_parameter_def where description = 'beard_moisturize_dur'))),
											(select actor_uuid from vw_actor where org_short_name = 'LANL'),
											(select status_uuid from vw_status where description = 'active')
											);
				update vw_parameter set parameter_val = (select put_val (
                                                    (select val_type_uuid from vw_parameter_def where description = 'beard_moisturize_dur'),
												    '36',
												    (select valunit from vw_parameter_def where description = 'beard_moisturize_dur')))
                                                where parameter_def_description = 'beard_moisturize_dur'
 				delete from vw_parameter where parameter_def_description = 'beard_moisturize_dur' AND ref_parameter_uuid = (select person_uuid from vw_person where last_name = 'Pendleton');
 */
CREATE OR REPLACE FUNCTION upsert_parameter()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
	    -- first delete parameter_x record
		DELETE FROM parameter_x
		WHERE parameter_x_uuid = OLD.parameter_x_uuid;
	    -- then delete the parameter record
		DELETE FROM parameter
		WHERE parameter_uuid = OLD.parameter_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.parameter_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
	    UPDATE
			parameter
		SET
			parameter_val = NEW.parameter_val,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			parameter.parameter_uuid = NEW.parameter_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
        IF (select exists
                (select parameter_def_uuid
                 from vw_parameter_def
                 where parameter_def_uuid = NEW.parameter_def_uuid)
            )
        THEN
			INSERT INTO parameter (parameter_def_uuid, parameter_val, actor_uuid, status_uuid)
				VALUES(NEW.parameter_def_uuid, NEW.parameter_val, NEW.actor_uuid, NEW.status_uuid)
				returning parameter_uuid into NEW.parameter_uuid;
			INSERT INTO parameter_x (parameter_uuid, ref_parameter_uuid)
			    VALUES(NEW.parameter_uuid, NEW.ref_parameter_uuid);
			RETURN NEW;
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;



/*
Name:			upsert_workflow_type()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.09.10
Description:	trigger proc that deletes, inserts or updates workflow_type record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_workflow_type (description) values ('workflowtype_test');
 				delete from vw_workflow_type where workflow_type_uuid = (select workflow_type_uuid from vw_workflow_type where (description = 'workflowtype_test'));
 */
CREATE OR REPLACE FUNCTION upsert_workflow_type ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the material_type record
		DELETE FROM workflow_type
		WHERE workflow_type_uuid = OLD.workflow_type_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.workflow_type_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			workflow_type
		SET
			description = NEW.description,
			mod_date = now()
		WHERE
			workflow_type.workflow_type_uuid = NEW.workflow_type_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO workflow_type (description)
			VALUES(NEW.description) returning workflow_type_uuid into NEW.workflow_type_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;