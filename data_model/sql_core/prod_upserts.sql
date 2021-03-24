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
		    actor_uuid = NEW.actor_uuid,
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
	_org_description varchar;
	_org_uuid uuid;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the organization record
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
	_person_first_name varchar;
	_person_last_name varchar;
	_person_middle_name varchar;
	_person_uuid uuid;
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
	_systemtool_description varchar;
	_systemtool_uuid uuid;
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
Name:			upsert_measure_type()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.11.01
Description:	trigger proc that deletes, inserts or updates measure_type record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_measure_type (description, actor_uuid, status_uuid) values 
					('TEST measure type',
					(select actor_uuid from vw_actor where org_short_name = 'HC'),
					null);
				update vw_measure_type set 
						status_uuid = (select status_uuid from vw_status where description = 'active') where (description = 'TEST measure type');
				delete from vw_measure_type where measure_type_uuid = (select measure_type_uuid from vw_measure_type where (description = 'TEST measure type'));
 */
CREATE OR REPLACE FUNCTION upsert_measure_type ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the measure_type record
		DELETE FROM measure_type
		WHERE measure_type_uuid = OLD.measure_type_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.measure_type_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			measure_type
		SET
			description = NEW.description,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			measure_type.measure_type_uuid = NEW.measure_type_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO measure_type (description, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.actor_uuid, NEW.status_uuid) returning measure_type_uuid into NEW.measure_type_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_measure()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.11.01
Description:	trigger proc that deletes, inserts or updates measure record based on TG_OP (trigger operation)
Notes:			this must be associated with an entity (i.e. ref_measure_uuid cannot be NULL)	
 
Example:		insert into vw_measure (measure_def_uuid, measure_type_uuid, ref_measure_uuid, description, measure_value, actor_uuid, status_uuid) values
					(
                    null,
                    null,
					(select material_uuid from vw_material where description = 'Formic Acid'),
					'TEST measure',
					(select put_val(
                          (select get_type_def ('data', 'num')),
                             '3.1415926535',
                             'slice')),
					(select actor_uuid from vw_actor where org_short_name = 'HC'),
					null);
				update vw_measure set 
						status_uuid = (select status_uuid from vw_status where description = 'active') where (description = 'TEST measure');
				delete from vw_measure where measure_uuid = (select measure_uuid from vw_measure where description = 'TEST measure');
 */
CREATE OR REPLACE FUNCTION upsert_measure ()
	RETURNS TRIGGER
	AS $$
DECLARE
    _measure_type_uuid uuid;
    _measure_value val;
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the measure_x record
		DELETE FROM measure_x
		WHERE measure_uuid = OLD.measure_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		DELETE FROM measure
		WHERE measure_uuid = OLD.measure_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.measure_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			measure
		SET
		    measure_def_uuid = NEW.measure_def_uuid,
			measure_type_uuid = NEW.measure_type_uuid,
			description = NEW.description,
			measure_value = NEW.measure_value,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			measure.measure_uuid = NEW.measure_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF (NEW.ref_measure_uuid is not null) THEN
		    IF (NEW.measure_type_uuid is null and NEW.measure_def_uuid is not null) THEN
                _measure_type_uuid := (select default_measure_type_uuid from vw_measure_def where measure_def_uuid = NEW.measure_def_uuid);
            ELSE
		        _measure_type_uuid := NEW.measure_type_uuid;
            END IF;
		    IF (NEW.measure_value is null and NEW.measure_def_uuid is not null) THEN
                _measure_value := (select default_measure_value from vw_measure_def where measure_def_uuid = NEW.measure_def_uuid);
            ELSE
		        _measure_value := NEW.measure_value;
            END IF;
			INSERT INTO measure (measure_def_uuid, measure_type_uuid, description, measure_value, actor_uuid, status_uuid)
				VALUES(
				       NEW.measure_def_uuid, _measure_type_uuid, NEW.description,
				       _measure_value, NEW.actor_uuid, NEW.status_uuid) returning measure_uuid into NEW.measure_uuid;
			INSERT INTO measure_x (ref_measure_uuid, measure_uuid)
				VALUES (NEW.ref_measure_uuid, NEW.measure_uuid);
			RETURN NEW;
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_measure_def()
Parameters:

Returns:		void
Author:			G. Cattabriga
Date:			2020.11.01
Description:	trigger proc that deletes, inserts or updates measure_def record based on TG_OP (trigger operation)
Notes:			this should be associate with a property_def (though not enforced)

Example:		insert into vw_measure_def (default_measure_type_uuid, description, default_measure_value, property_def_uuid, actor_uuid, status_uuid) values
					((select measure_type_uuid from vw_measure_type where description = 'manual'),
					'TEST plate temperature',
					(select put_val(
                          (select get_type_def ('data', 'num')),
                             '0.0',
                             'C')),
                    (select property_def_uuid from vw_property_def where description = 'temperature'),
					(select actor_uuid from vw_actor where org_short_name = 'HC'),
					null);
				update vw_measure_def set
						status_uuid = (select status_uuid from vw_status where description = 'active') where (description = 'TEST plate temperature');
				delete from vw_measure_def where measure_def_uuid = (select measure_def_uuid from vw_measure_def where description = 'TEST plate temperature');
 */
CREATE OR REPLACE FUNCTION upsert_measure_def ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the measure_x record
		DELETE FROM measure_def
		WHERE measure_def_uuid = OLD.measure_def_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.measure_def_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			measure_def
		SET
			default_measure_type_uuid = NEW.default_measure_type_uuid,
			description = NEW.description,
			default_measure_value = NEW.default_measure_value,
		    property_def_uuid = NEW.property_def_uuid,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			measure_def.measure_def_uuid = NEW.measure_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
			INSERT INTO measure_def (default_measure_type_uuid, description, default_measure_value, property_def_uuid, actor_uuid, status_uuid)
				VALUES(NEW.default_measure_type_uuid, NEW.description, NEW.default_measure_value, NEW.property_def_uuid, NEW.actor_uuid, NEW.status_uuid) returning measure_def_uuid into NEW.measure_def_uuid;
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
		    actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
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
 
Example:		insert into vw_material (description) values ('materialrefnamedef_test');
 				delete from vw_material where material_uuid = (select material_uuid from vw_material where (description = 'materialrefnamedef_test'));
 */
CREATE OR REPLACE FUNCTION upsert_material ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
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
			material_class = NEW.material_class,
			consumable = NEW.consumable,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			material.material_uuid = NEW.material_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF NEW.consumable is null 
			THEN NEW.consumable = TRUE; 
		END IF;
		INSERT INTO material (description, material_class, consumable, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.material_class, NEW.consumable, NEW.actor_uuid, NEW.status_uuid) returning material_uuid into NEW.material_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_material_composite()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.11.23
Description:	trigger proc that deletes, inserts or updates material_composite record based on TG_OP (trigger operation)
Notes:			this associates a component material to it's composite (parent)	
 
Example:		insert into vw_material (description) values ('plate well');
				insert into vw_material (description) values ('24 well plate');
				insert into vw_material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid) values
					((select material_uuid from vw_material where description = '24 well plate'),
					(select material_uuid from vw_material where description = 'plate well'),
					TRUE,
					(select actor_uuid from vw_actor where description = 'T Testuser')
					(select status_uuid from vw_status where description = 'active')
					);
				delete from vw_material_composite where composite_uuid = (select material_uuid from vw_material where description = '24 well plate');
 				delete from vw_material where material_uuid = (select material_uuid from vw_material where description = '24 well plate');
				delete from vw_material where material_uuid = (select material_uuid from vw_material where description = 'plate well');
 */
CREATE OR REPLACE FUNCTION upsert_material_composite ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM material_composite
		WHERE material_composite_uuid = OLD.material_composite_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			material_composite
		SET
			composite_uuid = NEW.composite_uuid,
			component_uuid = NEW.component_uuid,
			addressable = NEW.addressable,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			material_composite.material_composite_uuid = NEW.material_composite_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO material_composite (composite_uuid, component_uuid, addressable, actor_uuid, status_uuid)
			VALUES(NEW.composite_uuid, NEW.component_uuid, NEW.addressable, NEW.actor_uuid, NEW.status_uuid)
			returning material_composite_uuid
			into NEW.material_composite_uuid;

		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_material_type_assign()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.10.20
Description:	trigger proc that deletes, inserts or updates material_type_x record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_material_type_assign (material_uuid, material_type_uuid) values 
					((select material_uuid from vw_material where description = 'Hydrochloric acid'),
					(select material_type_uuid from vw_material_type where description = 'solvent'));
 				delete from vw_material_type_assign where material_uuid = (select material_uuid from vw_material where description = 'Hydrochloric acid') and
 					material_type_uuid = (select material_type_uuid from vw_material_type where description = 'solvent');
 */
CREATE OR REPLACE FUNCTION upsert_material_type_assign ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM material_type_x
		WHERE material_type_x_uuid = OLD.material_type_x_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			material_type_x
		SET
			material_uuid = NEW.material_uuid,
			material_type_uuid = NEW.material_type_uuid,
			mod_date = now()
		WHERE
			material_type_x.material_type_x_uuid = NEW.material_type_x_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO material_type_x (material_uuid, material_type_uuid)
			VALUES(NEW.material_uuid, NEW.material_type_uuid) returning material_uuid into NEW.material_uuid;
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
											actor_uuid = (select actor_uuid from vw_actor where org_short_name = 'TC') where (short_description = 'particle-size');
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
			property_def_class = NEW.property_def_class,
			valunit = NEW.valunit,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			property_def.property_def_uuid = NEW.property_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO property_def (description, short_description, val_type_uuid, property_def_class, valunit, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.short_description, NEW.val_type_uuid, NEW.property_def_class, NEW.valunit, NEW.actor_uuid, NEW.status_uuid) returning property_def_uuid into NEW.property_def_uuid;
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
											(select property_def_uuid from vw_property_def where short_description = 'duration),
											(select put_val (
												(select val_type_uuid from vw_property_def where short_description = 'particle-size'),
												'{100, 200}',
												(select valunit from vw_property_def where short_description = 'particle-size'))), 
											(select actor_uuid from vw_actor where org_short_name = 'TC'),
											(select status_uuid from vw_status where description = 'active')
											);
                update vw_property set property_val =
                    (select put_val (
                        (select val_type_uuid from vw_property_def where short_description = 'capacity'),
						'9.99',
				        (select valunit from vw_property_def where short_description = 'capacity'))) where short_description = 'capacity';
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
			type_uuid = NEW.type_uuid,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			property.property_uuid = NEW.property_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF (select exists (select property_def_uuid from vw_property_def where property_def_uuid = NEW.property_def_uuid)) THEN
			INSERT INTO property (property_def_uuid, type_uuid, property_val, actor_uuid, status_uuid)
				VALUES(NEW.property_def_uuid, NEW.type_uuid, NEW.property_val, NEW.actor_uuid, NEW.status_uuid) returning property_uuid into NEW.property_uuid;
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
					property_value, property_actor_uuid, property_status_uuid )
					values ((select material_uuid from vw_material where description = 'Formic Acid'),
							(select property_def_uuid from vw_property_def where short_description = 'particle-size'),
							'{100, 200}', 
							null,
							(select status_uuid from vw_status where description = 'active')
				) returning *;
				update vw_material_property set property_actor_uuid = (select actor_uuid from vw_actor where org_short_name = 'TC') where material_uuid = 
				(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'particle-size';
				update vw_material_property set val_val = '{100, 900}' where material_uuid = 
				(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'particle-size';
 				delete from vw_material_property where material_uuid = 
				(select material_uuid from vw_material where description = 'Formic Acid') and property_short_description = 'particle-size';
 */
CREATE OR REPLACE FUNCTION upsert_material_property ()
	RETURNS TRIGGER
	AS $$
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
				(select put_val (NEW.property_value_type_uuid, NEW.property_value, NEW.property_value_unit)),
			actor_uuid = NEW.property_actor_uuid,
			status_uuid = NEW.property_status_uuid,
		    property_class = NEW.property_class,
			mod_date = now()
		WHERE
			property.property_uuid = NEW.property_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF (select exists (select property_def_uuid from vw_property_def where property_def_uuid = NEW.property_def_uuid)) THEN
			IF (NEW.material_uuid is null) or (NEW.property_uuid is not null) THEN
				return null;
			END IF;
			INSERT INTO property (property_def_uuid, property_val, property_class, actor_uuid, status_uuid)
				VALUES(NEW.property_def_uuid, 
					(select put_val ((select val_type_uuid from vw_property_def where property_def_uuid = NEW.property_def_uuid), 
					NEW.property_value,
					(select valunit from vw_property_def where property_def_uuid = NEW.property_def_uuid))),	
				NEW.property_class, NEW.property_actor_uuid, NEW.property_status_uuid)
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
Name:			upsert_inventory()
Parameters:

Returns:		void
Author:			G. Cattabriga
Date:			2020.12.27
Description:	trigger proc that deletes, inserts or updates inventory record based on TG_OP (trigger operation)
Notes:

Example:		insert into vw_inventory (description, owner_uuid, operator_uuid, lab_uuid, actor_uuid, status_uuid)
					values (
						'test_inventory',
						(select actor_uuid from vw_actor where description = 'HC'),
						(select actor_uuid from vw_actor where description = 'T Testuser'),
						(select actor_uuid from vw_actor where description = 'HC'),
                        (select actor_uuid from vw_actor where description = 'T Testuser'),
						null);
				update vw_inventory set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'test_experiment';
 				delete from vw_inventory where description = 'test_inventory';
 */
CREATE OR REPLACE FUNCTION upsert_inventory ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM inventory
		WHERE inventory_uuid = OLD.inventory_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.inventory_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			inventory
		SET
			description = NEW.description,
			owner_uuid = NEW.owner_uuid,
			operator_uuid = NEW.operator_uuid,
			lab_uuid = NEW.lab_uuid,
		    actor_uuid = NEW.actor.uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			inventory.inventory_uuid = NEW.inventory_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO inventory (description, owner_uuid, operator_uuid, lab_uuid, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.owner_uuid, NEW.operator_uuid, NEW.lab_uuid, NEW.actor_uuid, NEW.status_uuid) returning inventory_uuid into NEW.inventory_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_inventory_material()
Parameters:		
Returns:		void
Author:			G. Cattabriga
Date:			2020.10.30
Description:	trigger proc that deletes, inserts or updates inventory_material record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_inventory_material (inventory_uuid, description, material_uuid, actor_uuid, part_no, onhand_amt, expiration_date, location, status_uuid)
				values (
                (select inventory_uuid from vw_inventory where description = 'test_inventory'),
                '24 well plate',
				(select material_uuid from vw_material where description = '24 well plate'),
				(select actor_uuid from vw_actor where description = 'T Testuser'),
				'xxx_123_24',
				(select put_val(
                          (select get_type_def ('data', 'int')),
                             '3',
                             '')),
                '2021-12-31',
                'Shelf 3, Bin 2',
				(select status_uuid from vw_status where description = 'active')
				);
 */
CREATE OR REPLACE FUNCTION upsert_inventory_material ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM inventory_material
		WHERE inventory_material_uuid = OLD.inventory_material_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.inventory_material_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			inventory_material
		SET
			inventory_uuid = NEW.inventory_uuid,
		    description = NEW.description,
			material_uuid = NEW.material_uuid,
			part_no = NEW.part_no,
			onhand_amt = NEW.onhand_amt,
		    expiration_date = NEW.expiration_date,
			location = NEW.location,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			inventory_material.inventory_material_uuid = NEW.inventory_material_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO inventory_material (inventory_uuid, description, material_uuid, part_no, onhand_amt, expiration_date, location, actor_uuid, status_uuid)
			VALUES(NEW.inventory_uuid, NEW.description, NEW.material_uuid, NEW.part_no, NEW.onhand_amt, NEW.expiration_date, NEW.location, NEW.actor_uuid, NEW.status_uuid) returning inventory_material_uuid into NEW.inventory_material_uuid;
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
Notes:			for postgres calculations (math_op, math_op_arr) make sure parameter reference names in a
                calc definition have  '' around them
                e.g. 'math_op_arr(math_op_arr(''hcl_concentrations'', '/', stock_concentration), '*', total_vol)'
Example:		insert into vw_calculation_def (short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, 	
					in_opt_type_uuid, out_type_uuid, calculation_property_def_class, actor_uuid, status_uuid )
					values ('test_calc_def', 'function param1 param2', 
					(select systemtool_uuid from vw_actor where description = 'Molecule Standardizer'),
					'testing calculation definition upsert', 
					(select calculation_def_uuid from vw_calculation_def where short_name = 'standardize'), 
					(select type_def_uuid from vw_type_def where category = 'data' and description = 'text'),
					null, null, 
					(select type_def_uuid from vw_type_def where category = 'data' and description = 'int'),
					null, (select actor_uuid from vw_actor where description = 'Gary Cattabriga'),
					(select status_uuid from vw_status where description = 'active')		
					) returning *;
				delete from vw_calculation_def where short_name = 'test_calc_def';
 */
CREATE OR REPLACE FUNCTION upsert_calculation_def ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
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
			in_opt_source_uuid = NEW.in_opt_source_uuid,
			in_opt_type_uuid = NEW.in_opt_type_uuid,	
			out_type_uuid = NEW.out_type_uuid,
		    out_unit = NEW.out_unit,
			calculation_class_uuid = NEW.calculation_class_uuid,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			calculation_def.calculation_def_uuid = NEW.calculation_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO calculation_def (short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, in_opt_type_uuid, out_type_uuid, out_unit, calculation_class_uuid, actor_uuid, status_uuid)
			VALUES(NEW.short_name, NEW.calc_definition, NEW.systemtool_uuid, NEW.description, NEW.in_source_uuid, NEW.in_type_uuid, NEW.in_opt_source_uuid, NEW.in_opt_type_uuid, NEW.out_type_uuid, NEW.out_unit, NEW.calculation_class_uuid, NEW.actor_uuid, NEW.status_uuid) returning calculation_def_uuid into NEW.calculation_def_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_calculation()
Parameters:		(short_name, calc_definition, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, in_opt_type_uuid, out_type_uuid, systemtool_uuid, actor_uuid)

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.19
Description:	trigger proc that deletes, inserts or updates calculation record based on TG_OP (trigger operation)
Notes:			this will check to see if calculation_def exists	
 
Example:		insert into vw_calculation (short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, 	
					in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid ) 
					values ('test_calc_def', 'function param1 param2', 
					(select systemtool_uuid from vw_actor where description = 'Molecule Standardizer'),
					'testing calculation definition upsert', 
					(select calculation_def_uuid from vw_calculation_def where short_name = 'standardize'), 
					(select type_def_uuid from vw_type_def where category = 'data' and description = 'text'),
					null, null, 
					(select type_def_uuid from vw_type_def where category = 'data' and description = 'int'),
					null, (select actor_uuid from vw_actor where description = 'Gary Cattabriga'),
					(select status_uuid from vw_status where description = 'active')		
					) returning *;
				delete from vw_calculation where short_name = 'test_calc_def';
 */
CREATE OR REPLACE FUNCTION upsert_calculation ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
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
		    IF (select systemtool_name from vw_calculation_def where
		                calculation_def_uuid = NEW.calculation_def_uuid) = 'postgres' and NEW.out_val is null THEN
			    NEW.out_val := (select do_calculation(NEW.calculation_def_uuid));
			END IF;
		    INSERT INTO calculation (calculation_def_uuid, calculation_alias_name, in_val, in_opt_val, out_val, actor_uuid, status_uuid)
			    VALUES(NEW.calculation_def_uuid, NEW.calculation_alias_name, NEW.in_val, NEW.in_opt_val, NEW.out_val, NEW.actor_uuid, NEW.status_uuid) returning calculation_uuid into NEW.calculation_uuid;
		    RETURN NEW;
		END IF;
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


/*
Name:			upsert_workflow()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.20
Description:	trigger proc that deletes, inserts or updates workflow record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid) 
					values (
						(select workflow_type_uuid from vw_workflow_type where description = 'template'),
						'workflow_test_2',
						(select actor_uuid from vw_actor where description = 'T Testuser'),
						null);
				update vw_workflow set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'workflow_test'; 
 				delete from vw_workflow where description = 'workflow_test' ;
 */
CREATE OR REPLACE FUNCTION upsert_workflow ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
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
			workflow_type_uuid = NEW.workflow_type_uuid,
		    parent_uuid = NEW.parent_uuid,
			description = NEW.description,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			workflow.workflow_uuid = NEW.workflow_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
			VALUES(NEW.workflow_type_uuid, NEW.description, NEW.actor_uuid, NEW.status_uuid) returning workflow_uuid into NEW.workflow_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_workflow_object()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.20
Description:	trigger proc that deletes, inserts or updates workflow_object records based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_workflow_object (workflow_uuid, action_uuid) 
					values (
						(select action_uuid from vw_action where action_description = 'example_heat'));
				insert into vw_workflow_object (workflow_uuid, condition_uuid) 
					values (
						(select condition_uuid from vw_condition where  condition_description = 'temp > threshold ?'));
				insert into vw_workflow_object (workflow_uuid, action_uuid) 
					values (
						(select action_uuid from vw_action where action_description = 'example_heat_stir'));
				insert into vw_workflow_object (workflow_uuid, action_uuid) 
					values (
						(select action_uuid from vw_action where action_description = 'start'));
				insert into vw_workflow_object (workflow_uuid, action_uuid) 
					values (
						(select action_uuid from vw_action where action_description = 'end'));
				update vw_workflow_object set status_uuid = (select status_uuid from vw_status 
					where description = 'active') where (object_type = 'action' and object_description = 'start'); 
 				delete from vw_workflow_object where (object_type = 'action' and object_description = 'start');
*/
CREATE OR REPLACE FUNCTION upsert_workflow_object ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM workflow_object
		WHERE workflow_object_uuid = OLD.workflow_object_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			workflow_object		
		SET
			workflow_uuid = NEW.workflow_uuid,
		    workflow_action_set_uuid = NEW.workflow_action_set_uuid,
			action_uuid = NEW.action_uuid,
			condition_uuid = NEW.condition_uuid,
		    status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			workflow_object.workflow_object_uuid = NEW.workflow_object_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		IF NEW.action_uuid IS NOT NULL THEN
			INSERT INTO workflow_object (workflow_uuid, workflow_action_set_uuid, action_uuid)
				VALUES (NEW.workflow_uuid, NEW.workflow_action_set_uuid, NEW.action_uuid) returning workflow_object_uuid into NEW.workflow_object_uuid;
		ELSIF NEW.condition_uuid IS NOT NULL THEN
			INSERT INTO workflow_object (workflow_uuid, workflow_action_set_uuid, condition_uuid)
				VALUES (NEW.workflow_uuid, NEW.workflow_action_set_uuid, NEW.condition_uuid) returning workflow_object_uuid into NEW.workflow_object_uuid;
		END IF;	
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;



/*
Name:			upsert_workflow_step()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.08.20
Description:	trigger proc that deletes, inserts or updates workflow_step AND workflow_object records based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_workflow_step (workflow_uuid, parent_uuid, workflow_object_uuid, status_uuid) 
					values (
						(select workflow_uuid from vw_workflow where description = 'workflow_test'),
						null,
						(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'start')),
						null);
				insert into vw_workflow_step (workflow_uuid, parent_uuid, workflow_object_uuid, status_uuid) 
					values (
						(select workflow_uuid from vw_workflow where description = 'workflow_test'),
						(select workflow_step_uuid from vw_workflow_step where (object_type = 'action' and object_description = 'start')),	
						(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'example_heat_stir')),					
						(select status_uuid from vw_status where description = 'active')
						);
				insert into vw_workflow_step (workflow_uuid, parent_uuid, workflow_object_uuid, status_uuid)  
					values (
						(select workflow_uuid from vw_workflow where description = 'workflow_test'),
						(select workflow_step_uuid from vw_workflow_step where (object_type = 'action' and object_description = 'example_heat_stir')),	
						(select workflow_object_uuid from vw_workflow_object where (object_type = 'condition' and object_description = 'temp > threshold ?')),					
						(select status_uuid from vw_status where description = 'active')
						);
				insert into vw_workflow_step (workflow_uuid, parent_uuid, workflow_object_uuid, status_uuid) 
					values (
						(select workflow_uuid from vw_workflow where description = 'workflow_test'),
						(select workflow_step_uuid from vw_workflow_step where (object_type = 'condition' and object_description = 'temp > threshold ?')),
						(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'example_heat_stir')),						
						(select status_uuid from vw_status where description = 'active')
						);
				insert into vw_workflow_step (workflow_uuid, parent_uuid, workflow_object_uuid, status_uuid)  
					values (
						(select workflow_uuid from vw_workflow where description = 'workflow_test'),
						(select workflow_step_uuid from vw_workflow_step where (object_type = 'condition' and object_description = 'temp > threshold ?')),	
						(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'example_heat')),					
						(select status_uuid from vw_status where description = 'active')
						);
				insert into vw_workflow_step (workflow_uuid, parent_uuid, workflow_object_uuid, status_uuid)  
					values (
						(select workflow_uuid from vw_workflow where description = 'workflow_test'),
						(select workflow_step_uuid from vw_workflow_step where (object_type = 'action' and object_description = 'example_heat')),	
						(select workflow_object_uuid from vw_workflow_object where (object_type = 'action' and object_description = 'end')),					
						(select status_uuid from vw_status where description = 'active')
						);
				update vw_workflow_step set status_uuid = (select status_uuid from vw_status 
					where description = 'active') where (object_type = 'action' and object_description = 'start'); 
 				delete from vw_workflow_step where (initial_object_type = 'action' and initial_object_description = 'start');
 */
CREATE OR REPLACE FUNCTION upsert_workflow_step ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM workflow_step
		WHERE workflow_step_uuid = OLD.workflow_step_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			workflow_step		
		SET
			workflow_uuid = NEW.workflow_uuid,
			parent_uuid = NEW.parent_uuid,
			workflow_object_uuid = NEW.workflow_object_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			workflow_step.workflow_step_uuid = NEW.workflow_step_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO workflow_step (workflow_uuid, workflow_action_set_uuid, parent_uuid, workflow_object_uuid, status_uuid)
			VALUES(NEW.workflow_uuid, NEW.workflow_action_set_uuid, NEW.parent_uuid, NEW.workflow_object_uuid, NEW.status_uuid) returning workflow_step_uuid into NEW.workflow_step_uuid;
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
 Notes:         Deletes elements in vw_action_parameter_def_assign
 Example:		insert into vw_action_def (description, actor_uuid, status_uuid) values
                                           ('heat_stir', (select actor_uuid from vw_actor where description = 'Ian Pendleton'),
                                           	(select status_uuid from vw_status where description = 'active')),
                                           ('heat', (select actor_uuid from vw_actor where description = 'Ian Pendleton'),
                                        	(select status_uuid from vw_status where description = 'active'));
                delete from vw_action_def where description in ('heat_stir', 'heat');
*/
 CREATE OR REPLACE FUNCTION upsert_action_def ()
 	RETURNS TRIGGER
 	AS $$
 BEGIN
 	IF(TG_OP = 'DELETE') THEN
 	    -- un-assign parameter defs from this action def
 	    DELETE FROM vw_action_parameter_def_assign where action_def_uuid = OLD.action_def_uuid;
 	    -- delete the action_def record
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
Name:			upsert_parameter_def()
Parameters:		
Returns:		void
Author:			M. Tynes
Date:			2020.10.26
Description:	trigger proc that deletes, inserts or updates parameter_def record based on TG_OP (trigger operation)
Notes:			Default val determines the datatype and unit of the parameter def
 
Example:		insert into vw_parameter_def (description, default_val)
                    values
                    ('duration',
                      (select put_val(
                          (select get_type_def ('data', 'num')),
                             '0',
                             'mins')
                       )
                    ),
                    ('speed',
                     (select put_val (
                       (select get_type_def ('data', 'num')),
                       '0',
                       'rpm')
                      )
                    ),
                    ('temperature',
                     (select put_val(
                       (select get_type_def ('data', 'num')),
                         '0',
                         'degC'))
                    );
                update vw_parameter_def
                    set status_uuid = (select status_uuid from vw_status where description = 'active')
                    where description = 'temperature';
                delete from vw_parameter_def where description in ('duration', 'speed', 'temperature');
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
		    default_val = NEW.default_val,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			parameter_def.parameter_def_uuid = NEW.parameter_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
	    IF NEW.required IS NULL
	        THEN NEW.required = TRUE;
	    END IF;
	    INSERT INTO parameter_def (description, default_val, required, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.default_val, NEW.required, NEW.actor_uuid, NEW.status_uuid)
			returning parameter_def_uuid into NEW.parameter_def_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
 Name:			upsert_calculation_parameter_def()
 Parameters:	trigger proc that deletes, inserts or updates calculation_parameter_def_x record based on TG_OP (trigger operation)
 Returns:		void
 Author:		G. Cattabriga
 Date:			2020.12.13
 Description:	trigger proc that deletes, inserts or updates calculation_parameter_def_x record based on TG_OP (trigger operation)
 Notes:			requires both ref_calculation_parameter_def_uuid and calculation_parameter_def_uuid
                NOTE: this MAY supercede upsert_calculation_parameter_def_assign
 Example:       insert into vw_calculation_parameter_def (calculation_def_uuid, parameter_def_uuid)
                     values ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'hcl_concentration')),
                            ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'total_vol')),
                            ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'stock_concentration'));
                delete from vw_calculation_parameter_def
                    where calculation_def_uuid = (select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration')
                    and parameter_def_uuid in (select parameter_def_uuid
                                               from vw_parameter_def
                                               where description in ('hcl_concentration', 'total_vol', 'stock_concentration'));
*/
CREATE OR REPLACE FUNCTION upsert_calculation_parameter_def ()
 	RETURNS TRIGGER
 	AS $$
BEGIN
 	IF(TG_OP = 'DELETE') THEN
 		DELETE FROM calculation_parameter_def_x
 		WHERE (calculation_def_uuid = OLD.calculation_def_uuid)
 			and(parameter_def_uuid = OLD.parameter_def_uuid);
 		RETURN OLD;
 	ELSIF (TG_OP = 'INSERT') THEN
 		INSERT INTO calculation_parameter_def_x (calculation_def_uuid, parameter_def_uuid)
 		VALUES(NEW.calculation_def_uuid,
 		       NEW.parameter_def_uuid);
 		RETURN NEW;
 	END IF;
END;
$$
LANGUAGE plpgsql;




/*
 Name:			upsert_calculation_parameter_def_assign()
 Parameters:	trigger proc that deletes, inserts or updates calculation_parameter_def_x record based on TG_OP (trigger operation)
 Returns:		void
 Author:		G. Cattabriga
 Date:			2020.12.13
 Description:	trigger proc that deletes, inserts or updates calculation_parameter_def_x record based on TG_OP (trigger operation)
 Notes:			requires both ref_calculation_parameter_def_uuid and calculation_parameter_def_uuid
 Example:       insert into vw_calculation_parameter_def_assign (calculation_def_uuid, parameter_def_uuid)
                     values ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'hcl_concentration')),
                            ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'total_vol')),
                            ((select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'stock_concentration'));
                delete from vw_calculation_parameter_def_assign
                    where calculation_def_uuid = (select calculation_def_uuid from vw_calculation_def where short_name = 'TC_WF1_HCL12M_5mL_concentration')
                    and parameter_def_uuid in (select parameter_def_uuid
                                               from vw_parameter_def
                                               where description in ('hcl_concentration', 'total_vol', 'stock_concentration'));
*/
CREATE OR REPLACE FUNCTION upsert_calculation_parameter_def_assign ()
 	RETURNS TRIGGER
 	AS $$
BEGIN
 	IF(TG_OP = 'DELETE') THEN
 		DELETE FROM calculation_parameter_def_x
 		WHERE (calculation_def_uuid = OLD.calculation_def_uuid)
 			and(parameter_def_uuid = OLD.parameter_def_uuid);
 		RETURN OLD;
 	ELSIF (TG_OP = 'INSERT') THEN
 		INSERT INTO calculation_parameter_def_x (calculation_def_uuid, parameter_def_uuid)
 		VALUES(NEW.calculation_def_uuid,
 		       NEW.parameter_def_uuid);
 		RETURN NEW;
 	END IF;
END;
$$
LANGUAGE plpgsql;


/*
    Name:			upsert_calculation_parameter()
    Parameters:
    Returns:		void
    Author:			G.Cattabriga
    Date:			2020.12.13
    Description:	trigger proc that deletes, inserts or updates calculation_parameter record based on TG_OP (trigger operation)
    Notes:

    Example:        update vw_calculation_parameter set parameter_val =
                        (select put_val ((select val_type_uuid from vw_parameter_def where description = 'speed'),
                        '8888',
                        (select valunit from vw_parameter_def where description = 'speed')))
                     where (calculation_description = 'TC_WF1_HCL12M_5mL_concentration' AND parameter_def_description = 'speed');

*/
CREATE OR REPLACE FUNCTION upsert_calculation_parameter()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
	    DELETE
	    FROM vw_parameter
	    WHERE ref_parameter_uuid = OLD.calculation_uuid;
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
	ELSIF (TG_OP = 'INSERT') THEN
        IF (NEW.parameter_def_uuid IN
        -- only create action parameters when the action and parameter definitions are already associated
                (select parameter_def_uuid
                 from vw_calculation_parameter_def
                 where calculation_def_uuid = (select calculation_def_uuid from vw_calculation where calculation_uuid = NEW.calculation_uuid))
            )
        THEN
            INSERT INTO vw_parameter (parameter_def_uuid, parameter_val, ref_parameter_uuid, actor_uuid, status_uuid)
                VALUES (NEW.parameter_def_uuid, NEW.parameter_val, NEW.action_uuid, NEW.parameter_actor_uuid, NEW.parameter_status_uuid);
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
 Name:			upsert_action_parameter_def_assign()
 Parameters:	trigger proc that deletes, inserts or updates action_parameter_def_x record based on TG_OP (trigger operation)
 Returns:		void
 Author:		M. Tynes
 Date:			2020.10.26
 Description:	trigger proc that deletes, inserts or updates action_parameter_def_x record based on TG_OP (trigger operation)
 Notes:			requires both ref_action_parameter_def_uuid and action_parameter_def_uuid
 Example:       insert into vw_action_parameter_def_assign (action_def_uuid, parameter_def_uuid)
                     values ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'duration')),
                            ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'temperature')),
                            ((select action_def_uuid from vw_action_def where description = 'heat_stir'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'speed')),
                             ((select action_def_uuid from vw_action_def where description = 'heat'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'duration')),
                            ((select action_def_uuid from vw_action_def where description = 'heat'),
                             (select parameter_def_uuid from vw_parameter_def where description = 'temperature'));
                delete
                    from vw_action_parameter_def_assign
                    where action_def_uuid = (select action_def_uuid from vw_action_def where description = 'heat_stir')
                    and parameter_def_uuid in (select parameter_def_uuid
                                               from vw_parameter_def
                                               where description in ('speed', 'duration', 'temperature'));
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
 	ELSIF (TG_OP = 'INSERT') THEN
 		INSERT INTO action_parameter_def_x (action_def_uuid, parameter_def_uuid)
 		VALUES(NEW.action_def_uuid,
 		       NEW.parameter_def_uuid);
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
Notes:          Preferred use is through upsert_action_parameter
 
Example:		insert into vw_parameter (parameter_def_uuid, ref_parameter_uuid, parameter_val, actor_uuid, status_uuid ) values (
											(select parameter_def_uuid from vw_parameter_def where description = 'duration'),
                                            (select person_uuid from vw_person where last_name = 'Pendleton'),
											(select put_val (
												(select val_type_uuid from vw_parameter_def where description = 'duration'),
												'10',
												(select valunit from vw_parameter_def where description = 'duration'))),
											(select actor_uuid from vw_actor where org_short_name = 'TC'),
											(select status_uuid from vw_status where description = 'active')
											);
                insert into vw_parameter (parameter_def_uuid, ref_parameter_uuid, parameter_val, actor_uuid, status_uuid ) values (
					    (select parameter_def_uuid from vw_parameter_def where description = 'duration'),
                        (select person_uuid from vw_person where last_name = 'Pendleton'),
					    (select put_val (
                            (select val_type_uuid from vw_parameter_def where description = 'duration'),
							'10',
					        (select valunit from vw_parameter_def where description = 'duration'))),
					    (select actor_uuid from vw_actor where org_short_name = 'TC'),
					    (select status_uuid from vw_status where description = 'active'));
				update vw_parameter set parameter_val = (select put_val (
                                                    (select val_type_uuid from vw_parameter_def where description = 'duration'),
												    '36',
												    (select valunit from vw_parameter_def where description = 'duration')))
                                                where parameter_def_description = 'duration';
 				delete from vw_parameter where parameter_def_description = 'duration' AND ref_parameter_uuid = (select person_uuid from vw_person where last_name = 'Pendleton');
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
    Name:			upsert_action()
    Parameters:
    Returns:		void
    Author:			M.Tynes
    Date:			2020.10.07
    Description:	trigger proc that deletes, inserts or updates action record based on TG_OP (trigger operation)
                       
    Notes:          On INSERT, creates:
                        1. An item in the vw_action that points back to an action_def.
                        2. k items in the vw_action_parameter where k is the # of parameter_defs assigned to action_def
                    The items in vw_action_parameter are created with the respective default values from vw_parameter_def,
                    which can be updated through vw_action_parameter.
    Example:
        insert into vw_action (action_def_uuid, workflow_uuid, action_description, status_uuid)
            values (
            	(select action_def_uuid from vw_action_def where description = 'heat_stir'),
            	(select workflow_uuid from vw_workflow where description = 'workflow_test'), 
            	'example_heat_stir',
            	(select status_uuid from vw_status where description = 'active'));
        update vw_action set actor_uuid = (select actor_uuid from vw_actor where description = 'Ian Pendleton')
            where action_description = 'example_heat_stir';
		insert into vw_action (action_def_uuid, workflow_uuid, action_description, actor_uuid, status_uuid)
            values (
            	(select action_def_uuid from vw_action_def where description = 'heat'),
            	(select workflow_uuid from vw_workflow where description = 'workflow_test'),            	 
            	'example_heat',
            	(select actor_uuid from vw_actor where description = 'Ian Pendleton'),
            	(select status_uuid from vw_status where description = 'active'));
        -- note: you may want to play around with vw_action_parameter before running this delete
        delete from vw_action where action_description = 'example_heat_stir';
        delete from vw_action where action_description = 'example_heat';
*/
CREATE OR REPLACE FUNCTION upsert_action()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
	    -- delete the associated parameter records
		DELETE FROM vw_parameter 
		WHERE ref_parameter_uuid = OLD.action_uuid;	
	    -- then delete the action record
		DELETE FROM action
		WHERE action_uuid = OLD.action_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.action_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
	    UPDATE
			action
		SET
		    action_def_uuid = NEW.action_def_uuid,
		    workflow_uuid = NEW.workflow_uuid,
            description = NEW.action_description,
            start_date = NEW.start_date,
            end_date = NEW.end_date,
            duration = NEW.duration,
            repeating = NEW.repeating,
            ref_parameter_uuid = NEW.ref_parameter_uuid,
            calculation_def_uuid = NEW.calculation_def_uuid,
            source_material_uuid = NEW.source_material_uuid,
            destination_material_uuid = NEW.destination_material_uuid,
            actor_uuid = NEW.actor_uuid,
            status_uuid = NEW.status_uuid,
            mod_date = now()
		WHERE
			action.action_uuid = NEW.action_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
        -- check if action def exists
	    IF (select exists
                (select action_def_uuid
                 from vw_action_def
                 where action_def_uuid = NEW.action_def_uuid)
            )
        THEN
            -- first create action instance
			INSERT INTO action (action_def_uuid, workflow_uuid, workflow_action_set_uuid, description, start_date, end_date, duration, repeating,
			                    ref_parameter_uuid, calculation_def_uuid, source_material_uuid, destination_material_uuid,
			                    actor_uuid, status_uuid)
				VALUES (NEW.action_def_uuid, NEW.workflow_uuid, NEW.workflow_action_set_uuid, NEW.action_description, NEW.start_date, NEW.end_date, NEW.duration, NEW.repeating,
				        NEW.ref_parameter_uuid, NEW.calculation_def_uuid, NEW.source_material_uuid,
				        NEW.destination_material_uuid, NEW.actor_uuid, NEW.status_uuid)
				returning action_uuid into NEW.action_uuid;
			-- then create action parameter instances for every parameter_def associated w/ this action_def
			-- and populate w/ default values
            INSERT INTO vw_action_parameter (action_uuid, parameter_def_uuid, parameter_val, parameter_actor_uuid, parameter_status_uuid)
                (select
                    NEW.action_uuid as action_uuid,
                    parameter_def_uuid,
                    default_val,
                    NEW.actor_uuid,
                    NEW.status_uuid
                from vw_action_parameter_def
                where action_def_uuid = NEW.action_def_uuid);
			RETURN NEW;
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
    Name:			upsert_action_parameter()
    Parameters:
    Returns:		void
    Author:			M.Tynes
    Date:			2020.10.13
    Description:	trigger proc that deletes, inserts or updates action_parameter record based on TG_OP (trigger operation)
    Notes:          Will fail silently if action def not associated w/ specified parameter def.
                    This function is run inside of upsert_action.
    Example:
        -- this creates three action parameters implicitly
        insert into vw_action (action_def_uuid, action_description)
            values ((select action_def_uuid from vw_action_def where description = 'heat_stir'), 'example_heat_stir');
        -- which can be modified explicitly:
        update vw_action_parameter
            set parameter_val = (select put_val (
            (select val_type_uuid from vw_parameter_def where description = 'speed'),
             '8888',
            (select valunit from vw_parameter_def where description = 'speed'))
            )
            where (action_description = 'example_heat_stir' AND parameter_def_description = 'speed');
        -- cleanup
        delete from vw_action_parameter where action_description = 'example_heat_stir';
*/
CREATE OR REPLACE FUNCTION upsert_action_parameter()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
	    DELETE
	    FROM vw_parameter
	    WHERE ref_parameter_uuid = OLD.action_uuid;
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
	ELSIF (TG_OP = 'INSERT') THEN
        IF (NEW.parameter_def_uuid IN
        -- only create action parameters when the action and parameter definitions are already associated
                (select parameter_def_uuid
                 from vw_action_parameter_def
                 where action_def_uuid = (select action_def_uuid from vw_action where action_uuid = NEW.action_uuid))
            )
        THEN
            INSERT INTO vw_parameter (parameter_def_uuid, parameter_val, ref_parameter_uuid, actor_uuid, status_uuid)
                VALUES (NEW.parameter_def_uuid, NEW.parameter_val, NEW.action_uuid, NEW.parameter_actor_uuid, NEW.parameter_status_uuid);
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_condition_def()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.10.06
Description:	trigger proc that deletes, inserts or updates condition_def record based on TG_OP (trigger operation)
Notes:			think of the conditions (and related calculation) as stack-based -> LIFO ala forth	
Example:		insert into vw_condition_def (description, actor_uuid) values
                                           ('temp > threshold ?', (select actor_uuid from vw_actor where description = 'T Testuser'));
 				update vw_condition_def set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'temp > threshold ?';
  				delete from vw_condition_def where description = 'temp > threshold ?';
*/
CREATE OR REPLACE FUNCTION upsert_condition_def ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
	    -- first delete the condition_def record
		DELETE FROM condition_def
		WHERE condition_def_uuid = OLD.condition_def_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.condition_def_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
	    UPDATE
			condition_def
		SET
			description = NEW.description,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			condition_def.condition_def_uuid = NEW.condition_def_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
	    INSERT INTO condition_def (description, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.actor_uuid, NEW.status_uuid) returning condition_def_uuid into NEW.condition_def_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;

 
/*
Name:			upsert_condition_calculation_def_assign()
Parameters:		trigger proc that deletes, inserts or updates condition_calculation_def_x record based on TG_OP (trigger operation)
Returns:		void
Author:			G. Cattabriga
Date:			2020.10.06
Description:	trigger proc that deletes, inserts or updates condition_calculation_def_x record based on TG_OP (trigger operation)
Notes:			requires condition_def_uuid and calculation_def_uuid

Example:       	-- first create a calculation
				insert into vw_calculation_def 
					(short_name, calc_definition, systemtool_uuid, description, in_source_uuid, in_type_uuid, in_opt_source_uuid, 		
					in_opt_type_uuid, out_type_uuid, calculation_class_uuid, actor_uuid, status_uuid ) 
				values ('greater_than', 'pop A, pop B, >', 
					(select systemtool_uuid from vw_actor where systemtool_name = 'escalate'),
					'B > A ? (pop B, pop A, >?) returning true or false', null, null, null, null,
					(select type_def_uuid from vw_type_def where category = 'data' and description = 'bool'),
					null, (select actor_uuid from vw_actor where description = 'T Testuser'),
					(select status_uuid from vw_status where description = 'active')		
					);
				insert into vw_condition_calculation_def_assign (condition_def_uuid, calculation_def_uuid)
					VALUES ((select condition_def_uuid from vw_condition_def where description = 'temp > threshold ?'),
						(select calculation_def_uuid from vw_calculation_def where short_name = 'greater_than'));	
				delete from vw_condition_calculation_def_assign where
					condition_def_uuid = (select condition_def_uuid from vw_condition_def where description = 'temp > threshold ?') and
					calculation_def_uuid = (select calculation_def_uuid from vw_calculation_def where short_name = 'greater_than');
				delete from vw_calculation_def where short_name = 'greater_than';	
*/
CREATE OR REPLACE FUNCTION upsert_condition_calculation_def_assign()
 	RETURNS TRIGGER
 	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
 		DELETE FROM condition_calculation_def_x
 		WHERE (condition_def_uuid = OLD.condition_def_uuid)
 			and(calculation_def_uuid = OLD.calculation_def_uuid);
 		RETURN OLD;
 	ELSIF (TG_OP = 'UPDATE') THEN
	    UPDATE
			condition_calculation_def_x
		SET
			condition_def_uuid = NEW.condition_def_uuid,
			calculation_def_uuid = NEW.calculation_def_uuid,
			mod_date = now()
		WHERE
			condition_calculation_def_x.condition_calculation_def_x_uuid = NEW.condition_calculation_def_x_uuid;
		RETURN NEW;
 	ELSIF (TG_OP = 'INSERT') THEN
 		INSERT INTO condition_calculation_def_x (condition_def_uuid, calculation_def_uuid)
 		VALUES(NEW.condition_def_uuid, NEW.calculation_def_uuid);
 		RETURN NEW;
 	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_condition()
Parameters:		trigger proc that deletes, inserts or updates condition record based on TG_OP (trigger operation)
Returns:		void
Author:			G. Cattabriga
Date:			2020.10.06
Description:	trigger proc that deletes, inserts or updates condition record based on TG_OP (trigger operation)
Notes:			requires condition_calculation_def_x_uuid

Example:       	insert into vw_condition 
					(condition_calculation_def_x_uuid, in_val, out_val, actor_uuid, status_uuid)
				values (
					(select condition_calculation_def_x_uuid from vw_condition_calculation_def_assign where condition_description = 'temp > threshold ?'),
					(ARRAY[(SELECT put_val ((select get_type_def ('data', 'num')), '100', 'C'))]), 
					(ARRAY[(SELECT put_val ((select get_type_def ('data', 'bool')), 'FALSE', null))]),
					(select actor_uuid from vw_actor where description = 'T Testuser'),
					(select status_uuid from vw_status where description = 'active')		
					);
				update vw_condition set 
					in_val = (ARRAY[(SELECT put_val ((select get_type_def ('data', 'num')), '120', 'C'))]) where condition_description = 'temp > threshold ?'; 
				delete from vw_condition where condition_description = 'temp > threshold ?';
*/
CREATE OR REPLACE FUNCTION upsert_condition()
 	RETURNS TRIGGER
 	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
 		DELETE FROM condition
 		WHERE (condition_uuid = OLD.condition_uuid);
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.condition_uuid);
		RETURN OLD;
 	ELSIF (TG_OP = 'UPDATE') THEN
	    UPDATE
			condition
		SET
			workflow_uuid = NEW.workflow_uuid,
		    workflow_action_set_uuid = NEW.workflow_action_set_uuid,
		    condition_calculation_def_x_uuid = NEW.condition_calculation_def_x_uuid,
			in_val = NEW.in_val,
			out_val = NEW.out_val,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			condition.condition_uuid = NEW.condition_uuid;
		RETURN NEW;
 	ELSIF (TG_OP = 'INSERT') THEN
 		INSERT INTO condition (workflow_uuid, workflow_action_set_uuid, condition_calculation_def_x_uuid, in_val, out_val, actor_uuid, status_uuid)
 		VALUES(NEW.workflow_uuid, NEW.workflow_action_set_uuid, NEW.condition_calculation_def_x_uuid, NEW.in_val, NEW.out_val, NEW.actor_uuid, NEW.status_uuid);
 		RETURN NEW;
 	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_condition_path()
Parameters:		trigger proc that deletes, inserts or updates condition_path record based on TG_OP (trigger operation)
Returns:		void
Author:			G. Cattabriga
Date:			2020.11.02
Description:	trigger proc that deletes, inserts or updates condition_path record based on TG_OP (trigger operation)
Notes:			

Example:       	insert into vw_condition_path 
					(condition_uuid, condition_out_val, workflow_step_uuid)
				values (
					(select condition_uuid from vw_condition where condition_description = 'temp > threshold ?'),
					((SELECT put_val ((select get_type_def ('data', 'bool')), 'FALSE', null))),
					(select workflow_step_uuid from vw_workflow_step 
						where (object_description = 'example_heat_stir' and parent_object_description = 'temp > threshold ?')));
				insert into vw_condition_path 
					(condition_uuid, condition_out_val, workflow_step_uuid)
				values (
					(select condition_uuid from vw_condition where condition_description = 'temp > threshold ?'),
					((SELECT put_val ((select get_type_def ('data', 'bool')), 'FALSE', null))),
					(select workflow_step_uuid from vw_workflow_step 
						where (object_description = 'example_heat' and parent_object_description = 'temp > threshold ?')));
				update vw_condition_path set 
					condition_out_val = ((SELECT put_val ((select get_type_def ('data', 'bool')), 'TRUE', null))) 
						where condition_path_uuid = 
							(select condition_path_uuid from vw_condition_path 
								where condition_uuid = (select condition_uuid from vw_condition where condition_description = 'temp > threshold ?') and 
								workflow_step_uuid = (select workflow_step_uuid from vw_workflow_step 
						where (workflow_description = 'test_workflow' and object_type = 'action' and object_description = 'example_heat'))); 
				delete from vw_condition_path where condition_uuid = (select condition_uuid from vw_condition where condition_description = 'temp > threshold ?');
*/
CREATE OR REPLACE FUNCTION upsert_condition_path()
 	RETURNS TRIGGER
 	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
 		DELETE FROM condition_path
 		WHERE (condition_path_uuid = OLD.condition_path_uuid);
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.condition_path_uuid);
		RETURN OLD;
 	ELSIF (TG_OP = 'UPDATE') THEN
	    UPDATE
			condition_path
		SET
			condition_uuid = NEW.condition_uuid,
			condition_out_val = NEW.condition_out_val,
			workflow_step_uuid = NEW.workflow_step_uuid,
			mod_date = now()
		WHERE
			condition_path.condition_path_uuid = NEW.condition_path_uuid;
		RETURN NEW;
 	ELSIF (TG_OP = 'INSERT') THEN
 		INSERT INTO condition_path (condition_uuid, condition_out_val, workflow_step_uuid)
 		VALUES(NEW.condition_uuid,NEW.condition_out_val, NEW.workflow_step_uuid);
 		RETURN NEW;
 	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_experiment_type()
Parameters:

Returns:		void
Author:			G. Cattabriga
Date:			2020.12.30
Description:	trigger proc that deletes, inserts or updates experiment_type record based on TG_OP (trigger operation)
Notes:

Example:		insert into vw_experiment_type (description, actor_uuid, status_uuid) values
					('TEST experiment type',
					(select actor_uuid from vw_actor where org_short_name = 'HC'),
					null);
				update vw_experiment_type set
						status_uuid = (select status_uuid from vw_status where description = 'active') where (description = 'TEST measure type');
				delete from vw_experiment_type where experiment_type_uuid = (select experiment_type_uuid from vw_experiment_type
                    where (description = 'TEST experiment type'));
 */
CREATE OR REPLACE FUNCTION upsert_experiment_type ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- first delete the experiment_type record
		DELETE FROM experiment_type
		WHERE experiment_type_uuid = OLD.experiment_type_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.experiment_type_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			experiment_type
		SET
			description = NEW.description,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			experiment_type.experiment_type_uuid = NEW.experiment_type_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO experiment_type (description, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.actor_uuid, NEW.status_uuid) returning experiment_type_uuid into NEW.experiment_type_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_experiment()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.10.20
Description:	trigger proc that deletes, inserts or updates experiment record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_experiment (ref_uid, description, parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid) 
					values (
						'test_red_uid', 'test_experiment',
						null,
						(select actor_uuid from vw_actor where description = 'HC'),						
						(select actor_uuid from vw_actor where description = 'T Testuser'),
						(select actor_uuid from vw_actor where description = 'HC'),
						null);
				update vw_experiment set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'test_experiment'; 
 				delete from vw_experiment where description = 'test_experiment';
 */
CREATE OR REPLACE FUNCTION upsert_experiment ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM experiment
		WHERE experiment_uuid = OLD.experiment_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.experiment_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			experiment		
		SET
			ref_uid = NEW.ref_uid,
			description = NEW.description,
			parent_uuid = NEW.parent_uuid,
			owner_uuid = NEW.owner_uuid,
			operator_uuid = NEW.operator_uuid,			
			lab_uuid = NEW.lab_uuid,			
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			experiment.experiment_uuid = NEW.experiment_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO experiment (ref_uid, description, parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid)
			VALUES(NEW.ref_uid, NEW.description, NEW.parent_uuid, NEW.owner_uuid, NEW.operator_uuid, NEW.lab_uuid, NEW.status_uuid) returning experiment_uuid into NEW.experiment_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_experiment_workflow()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.10.30
Description:	trigger proc that deletes, inserts or updates experiment_workflow record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid) 
					values (
						2, 
						(select experiment_uuid from vw_experiment where description = 'test_experiment'),
						(select workflow_uuid from vw_workflow where description = 'workflow_test_2'));
 				delete from vw_experiment_workflow 
 					where experiment_uuid = (select experiment_uuid from vw_experiment where description = 'test_experiment');
 */
CREATE OR REPLACE FUNCTION upsert_experiment_workflow ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM experiment_workflow
		WHERE experiment_workflow_uuid = OLD.experiment_workflow_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.experiment_workflow_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			experiment_workflow
		SET
			experiment_workflow_seq = NEW.experiment_workflow_seq,
			experiment_uuid = NEW.experiment_uuid,
			workflow_uuid = NEW.workflow_uuid,
			mod_date = now()
		WHERE
			experiment_workflow.experiment_uuid = NEW.experiment_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid)
			VALUES(NEW.experiment_workflow_seq, NEW.experiment_uuid, NEW.workflow_uuid) returning experiment_workflow_uuid into NEW.experiment_workflow_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_bom()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.11.01
Description:	trigger proc that deletes, inserts or updates bom record based on TG_OP (trigger operation)
Notes:				
 
Example:		insert into vw_bom (experiment_uuid, description, actor_uuid, status_uuid) 
					values (
						(select experiment_uuid from vw_experiment where description = 'test_experiment'),
						'test_bom',					
						(select actor_uuid from vw_actor where description = 'T Testuser'),
						(select status_uuid from vw_status where description = 'test'));
				update vw_bom set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'test_bom'; 
 				delete from vw_bom where description = 'test_bom';
 */
CREATE OR REPLACE FUNCTION upsert_bom ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM bom
		WHERE bom_uuid = OLD.bom_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.bom_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			bom		
		SET
			experiment_uuid = NEW.experiment_uuid,
			description = NEW.description,
			actor_uuid = NEW.actor_uuid,			
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			bom.bom_uuid = NEW.bom_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO bom (experiment_uuid, description, actor_uuid, status_uuid)
			VALUES(NEW.experiment_uuid, NEW.description, NEW.actor_uuid, NEW.status_uuid) returning bom_uuid into NEW.bom_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_bom_material_composite()
Parameters:
Returns:		void
Author:			G. Cattabriga
Date:			2020.12.22
Description:	trigger proc that deletes, inserts or updates bom_material_composite record based on TG_OP (trigger operation)
Notes:			do not call this directly - instead use vw_bom_material as the way to insert, update and delete bom_materials

Example:		insert into vw_bom_material_composite (description, bom_material_uuid, material_composite_uuid, actor_uuid, status_uuid)
					values (
                        'Test Plate: Plate well#: A1',
						(select material_composite_uuid from vw_material_composite where component_description = 'Plate well#: A1'),
						(select material_composite_uuid from vw_material_composite where component_description = 'Plate well#: A1'),
						(select actor_uuid from vw_actor where description = 'T Testuser'),
						(select status_uuid from vw_status where description = 'test'));
				update vw_bom_material_composite set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'Test Plate: Plate well#: A1';
 				delete from vw_bom where description = 'Test Plate: Plate well#: A1';
 */
CREATE OR REPLACE FUNCTION upsert_bom_material_composite ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
	    DELETE FROM bom_material_index
	    WHERE bom_material_composite_uuid = OLD.bom_material_composite_uuid;
		DELETE FROM bom_material_composite
		WHERE bom_material_composite_uuid = OLD.bom_material_composite_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.bom_material_composite_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			bom_material_composite
		SET
			description = NEW.description,
		    bom_material_uuid = NEW.bom_material_uuid,
		    material_composite_uuid = NEW.material_composite_uuid,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			bom_material_composite.bom_material_composite_uuid = NEW.bom_material_composite_uuid;
		UPDATE bom_material_index
		SET
			description = NEW.description,
			mod_date = now()
		WHERE bom_material_index.bom_material_composite_uuid = NEW.bom_material_composite_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO bom_material_composite (description, bom_material_uuid, material_composite_uuid, actor_uuid, status_uuid)
			VALUES(NEW.description, NEW.bom_material_uuid, NEW.material_composite_uuid, NEW.actor_uuid, NEW.status_uuid) returning bom_material_composite_uuid into NEW.bom_material_composite_uuid;
		INSERT INTO bom_material_index (description, bom_material_composite_uuid)
		    VALUES(NEW.description, NEW.bom_material_composite_uuid);
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_bom_material()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.11.01
Description:	trigger proc that deletes, inserts or updates experiment record based on TG_OP (trigger operation)
Notes:			the amounts refer to measures	
 
Example:		insert into vw_bom_material (bom_uuid, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid)
					values (
						(select bom_uuid from vw_bom where description = 'test_bom'),
						(select inventory_material_uuid from vw_inventory_material where description = 'HCL'),
						(select put_val((select get_type_def ('data', 'num')), '500.00','mL')),
						null, null,				
						(select actor_uuid from vw_actor where description = 'T Testuser'),
						(select status_uuid from vw_status where description = 'test'));
				update vw_bom_material set status_uuid = (select status_uuid from vw_status where description = 'active') 
					where inventory_material_uuid = (select inventory_material_uuid from vw_inventory_material where description = 'HCL');
				update vw_bom_material set used_amt_val = (select put_val((select get_type_def ('data', 'num')), '487.21','mL')) 
					where inventory_material_uuid = (select inventory_material_uuid from vw_inventory_material where description = 'HCL');
 				delete from vw_bom_material where description = 'Sample Prep Plate';
 */	
CREATE OR REPLACE FUNCTION upsert_bom_material ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
	    DELETE FROM bom_material_index
	    WHERE bom_material_uuid = OLD.bom_material_uuid;
	    DELETE FROM vw_bom_material_composite
                where bom_material_description = OLD.description ;
		DELETE FROM bom_material
		WHERE bom_material_uuid = OLD.bom_material_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.bom_material_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			bom_material		
		SET
			bom_uuid = NEW.bom_uuid,
		    description = NEW.description,
			inventory_material_uuid = NEW.inventory_material_uuid,
			alloc_amt_val = NEW.alloc_amt_val,
			used_amt_val = NEW.used_amt_val,		
			putback_amt_val = NEW.putback_amt_val,		
			actor_uuid = NEW.actor_uuid,			
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			bom_material.bom_material_uuid = NEW.bom_material_uuid;
		UPDATE bom_material_index
		SET
			description = NEW.description,
			mod_date = now()
		WHERE bom_material_index.bom_material_uuid = NEW.bom_material_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO bom_material (bom_uuid, description, inventory_material_uuid, alloc_amt_val, used_amt_val, putback_amt_val, actor_uuid, status_uuid)
			VALUES(NEW.bom_uuid, NEW.description, NEW.inventory_material_uuid,  NEW.alloc_amt_val, NEW.used_amt_val, NEW.putback_amt_val, NEW.actor_uuid, NEW.status_uuid) returning bom_material_uuid into NEW.bom_material_uuid;
		-- check to see if it's a non-consumable and composite so we can bring the [addressable ]composites into the BOM 
		IF not (select material_consumable from vw_inventory_material where inventory_material_uuid = NEW.inventory_material_uuid) and
			(select material_composite_flg from vw_inventory_material where inventory_material_uuid = NEW.inventory_material_uuid) THEN
			INSERT INTO vw_bom_material_composite (description, bom_material_uuid, material_composite_uuid, actor_uuid, status_uuid)
				select concat(NEW.description,': ',component_description), NEW.bom_material_uuid,
				       material_composite_uuid, NEW.actor_uuid, NEW.status_uuid
		  		from vw_material_composite where
						composite_uuid = (SELECT material_uuid from inventory_material where
						inventory_material_uuid = NEW.inventory_material_uuid);
		END IF;
		INSERT INTO bom_material_index (description, bom_material_uuid)
		    VALUES(NEW.description, NEW.bom_material_uuid);
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_outcome()
Parameters:

Returns:		void
Author:			G. Cattabriga
Date:			2020.12.10
Description:	trigger proc that deletes, inserts or updates outcome record based on TG_OP (trigger operation)
Notes:

Example:		insert into vw_outcome (experiment_uuid, description, actor_uuid, status_uuid)
					values (
						(select experiment_uuid from vw_experiment where description = 'TC Test Experiment Template'),
						'test_outcome',
						(select actor_uuid from vw_actor where description = 'T Testuser'),
						(select status_uuid from vw_status where description = 'test'));
				update vw_outcome set status_uuid = (select status_uuid from vw_status where description = 'active') where description = 'test_outcome';
 				delete from vw_outcome where description = 'test_outcome';
 */
CREATE OR REPLACE FUNCTION upsert_outcome ()
	RETURNS TRIGGER
	AS $$
BEGIN
	IF(TG_OP = 'DELETE') THEN
		DELETE FROM outcome
		WHERE outcome_uuid = OLD.outcome_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.outcome_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'UPDATE') THEN
		UPDATE
			outcome
		SET
			experiment_uuid = NEW.experiment_uuid,
			description = NEW.description,
			actor_uuid = NEW.actor_uuid,
			status_uuid = NEW.status_uuid,
			mod_date = now()
		WHERE
			outcome.outcome_uuid = NEW.outcome_uuid;
		RETURN NEW;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO outcome (experiment_uuid, description, actor_uuid, status_uuid)
			VALUES(NEW.experiment_uuid, NEW.description, NEW.actor_uuid, NEW.status_uuid) returning outcome_uuid into NEW.outcome_uuid;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;


/*
Name:			upsert_workflow_action_set()
Parameters:		

Returns:		void
Author:			G. Cattabriga
Date:			2020.12.01
Description:	trigger proc that deletes or inserts (no updates!) workflow_action_set record based on TG_OP (trigger operation)
Notes:			this will build a workflow of repeating action with one-to-many or many-to-many materials, varying parameter (explicit or calculation)
                !!!!! This expects to live in a workflow alone. That is, do not insert other actions or action sets into the workflow this  !!!!!
                !!!!! is assigned, otherwise it could break the experiment_copy function !!!!!
 
Example:		-- insert a one-to-many workflow_action_set (one source into many destinations)
				insert into vw_experiment (ref_uid, description, parent_uuid, owner_uuid, operator_uuid, lab_uuid, status_uuid)
					values (
						'test_red_uid', 'test_experiment',
						null,
						(select actor_uuid from vw_actor where description = 'HC'),
						(select actor_uuid from vw_actor where description = 'T Testuser'),
						(select actor_uuid from vw_actor where description = 'HC'),
						null);
                insert into vw_workflow (workflow_type_uuid, description, actor_uuid, status_uuid)
					values (
						(select workflow_type_uuid from vw_workflow_type where description = 'template'),
						'test_workflow_action_set',
						(select actor_uuid from vw_actor where description = 'Ion Bond'),
						(select status_uuid from vw_status where description = 'dev_test'));
				-- associate it with an experiment
				insert into vw_experiment_workflow (experiment_workflow_seq, experiment_uuid, workflow_uuid) 
					values (
						1, 
						(select experiment_uuid from vw_experiment where description = 'test_experiment'),
						(select workflow_uuid from vw_workflow where description = 'test_workflow_action_set'));

				insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration, repeating, 
													parameter_def_uuid, parameter_val, source_material_uuid, destination_material_uuid, actor_uuid, status_uuid) values (
						'test dispense action_set',
						(select workflow_uuid from vw_workflow where description = 'test_workflow_action_set'),
						(select action_def_uuid from vw_action_def where description = 'dispense'),
						null, null, null, null,
						(select parameter_def_uuid from vw_action_parameter_def where description = 'dispense' and parameter_description = 'volume'),
						array[(select put_val ((select val_type_uuid from vw_parameter_def where description = 'volume'),'10.1',
													(select valunit from vw_parameter_def where description = 'volume'))),
												(select put_val ((select val_type_uuid from vw_parameter_def where description = 'volume'),'9.2',
													(select valunit from vw_parameter_def where description = 'volume'))), 
												(select put_val ((select val_type_uuid from vw_parameter_def where description = 'volume'),'8.3',
													(select valunit from vw_parameter_def where description = 'volume')))],
						array[(select bom_material_uuid from vw_bom_material where bom_material_description = 'HCl-12M')],
						array[
							(select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate: well# B1'),
							(select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate: well# B2'),
							(select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate: well# B3')],						
						(select actor_uuid from vw_actor where description = 'Ion Bond'),
						(select status_uuid from vw_status where description = 'dev_test')
						); 
						
						-- this is a many to many example; with a single parameter value
						insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration, repeating, 
													parameter_def_uuid, parameter_val, source_material_uuid, destination_material_uuid, actor_uuid, status_uuid) values (
						'test dispense action_set',
						(select workflow_uuid from vw_workflow where description = 'test_workflow_action_set'),
						(select action_def_uuid from vw_action_def where description = 'dispense'),
						null, null, null, null,
						(select parameter_def_uuid from vw_action_parameter_def where description = 'dispense' and parameter_description = 'volume'),
						array[(select put_val ((select val_type_uuid from vw_parameter_def where description = 'volume'),'50',
													(select valunit from vw_parameter_def where description = 'volume')))],
						array[
							(select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate: well# A1'),
							(select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate: well# A2'),
							(select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate: well# A3')],
						array[
							(select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate: well# B1'),
							(select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate: well# B2'),
							(select bom_material_uuid from vw_bom_material where bom_material_description = 'Plate: well# B3')],						
						(select actor_uuid from vw_actor where description = 'Ion Bond'),
						(select status_uuid from vw_status where description = 'dev_test')
						); 	
						
						delete from vw_workflow_action_set where workflow_action_set_uuid = (select workflow_action_set_uuid from vw_workflow_action_set where description = 'test dispense action_set');
 */	
CREATE OR REPLACE FUNCTION upsert_workflow_action_set()
	RETURNS TRIGGER
	AS $$
DECLARE
	_action_uuid uuid;
    _calc_arr val[] ;
    _calc_flg boolean := FALSE;
	_d_uuid uuid;
	_object_uuid uuid;
	_s_uuid uuid;
	_src_cnt int := 1;
	_step_uuid uuid := null;
	_val_cnt int := 1;
	_val_len int := array_length(NEW.parameter_val, 1);

BEGIN
	IF(TG_OP = 'DELETE') THEN
		-- working backwards...
		-- delete the workflow_step
		delete from workflow_step cascade where workflow_action_set_uuid = OLD.workflow_action_set_uuid;
		-- delete the workflow_object 
		delete from workflow_object where workflow_action_set_uuid = OLD.workflow_action_set_uuid;
		-- delete the vw_action_parameter
		delete from action where workflow_action_set_uuid = OLD.workflow_action_set_uuid;
		-- now delete the workflow_action_set record
		DELETE FROM workflow_action_set
		WHERE workflow_action_set_uuid = OLD.workflow_action_set_uuid;
		IF NOT FOUND THEN
			RETURN NULL;
		END IF;
		-- delete any assigned records
		PERFORM delete_assigned_recs (OLD.workflow_action_set_uuid);
		RETURN OLD;
	ELSIF (TG_OP = 'INSERT') THEN
	    -- check to see if there is a calculation_uuid so we can transpose it into a calc_array;
	    IF (NEW.calculation_uuid is not null and NEW.parameter_val is null) THEN
            _calc_flg := TRUE;
            _calc_arr := (select arr_val_2_val_arr ((select out_val from vw_calculation where calculation_uuid = NEW.calculation_uuid)));
            _val_len := array_length(_calc_arr, 1);
        END IF;
		-- first insert into workflow_action_set
		insert into workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration, repeating, 
											parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid, actor_uuid, status_uuid) VALUES
			(NEW.description, NEW.workflow_uuid, NEW.action_def_uuid, NEW.start_date, NEW.end_date, NEW.duration, NEW.repeating, 
				NEW.parameter_def_uuid, NEW.parameter_val, NEW.calculation_uuid, NEW.source_material_uuid, NEW.destination_material_uuid,
				NEW.actor_uuid, NEW.status_uuid) returning workflow_action_set_uuid into NEW.workflow_action_set_uuid;
		-- now build the actions in the workflow
		-- check to see if this is a one to many (one source to many dest) 
		-- if more than one element in source array then it's a positional ([1] -> [1]) loop
		IF (array_length(NEW.source_material_uuid, 1) = 1) THEN
			_s_uuid := NEW.source_material_uuid[1];
			-- go through the loop for every destination material
			FOREACH _d_uuid IN ARRAY NEW.destination_material_uuid
			LOOP 
	        	insert into vw_action (action_def_uuid, workflow_uuid, workflow_action_set_uuid, action_description, source_material_uuid, destination_material_uuid, actor_uuid, status_uuid)
	            values (NEW.action_def_uuid, NEW.workflow_uuid, NEW.workflow_action_set_uuid,
	            	concat(NEW.description, ': ',(select description from vw_bom_material_index where bom_material_index_uuid = _s_uuid), ' -> ',
	            					(select description from vw_bom_material_index where bom_material_index_uuid = _d_uuid)),
	            	_s_uuid, _d_uuid, NEW.actor_uuid, NEW.status_uuid) returning action_uuid into _action_uuid;
				-- assign parameter value
	        	IF _calc_flg THEN
                    update vw_action_parameter set
                        parameter_val = (select put_val (
                            (select val_type_uuid from vw_parameter_def where parameter_def_uuid = NEW.parameter_def_uuid),
                            (select val_val from get_val (_calc_arr[_val_cnt])),
                            (select valunit from vw_parameter_def where parameter_def_uuid = NEW.parameter_def_uuid)))
                    where action_uuid = _action_uuid;
                ELSE
                    update vw_action_parameter set
                        parameter_val = (select put_val (
                            (select val_type_uuid from vw_parameter_def where parameter_def_uuid = NEW.parameter_def_uuid),
                            (select val_val from get_val (NEW.parameter_val[_val_cnt])),
                            (select valunit from vw_parameter_def where parameter_def_uuid = NEW.parameter_def_uuid)))
                    where action_uuid = _action_uuid;
                END IF;
				-- create the workflow_object
				insert into vw_workflow_object (workflow_uuid, workflow_action_set_uuid, action_uuid)
					values (NEW.workflow_uuid, NEW.workflow_action_set_uuid, _action_uuid) returning workflow_object_uuid into _object_uuid;
				-- create the workflow_step
				insert into vw_workflow_step (workflow_uuid, workflow_action_set_uuid, workflow_object_uuid, parent_uuid, status_uuid)
					values (NEW.workflow_uuid, NEW.workflow_action_set_uuid, _object_uuid, _step_uuid, NEW.status_uuid) returning workflow_step_uuid into _step_uuid;
				-- increment the parameter pointer
				IF _val_cnt < _val_len 
					THEN _val_cnt := _val_cnt + 1; 
				END IF;
			END LOOP;
		ELSIF (array_length(NEW.source_material_uuid, 1) > 0 and array_length(NEW.destination_material_uuid, 1) > 0) THEN
			-- check to make sure there are 1 or more elements in each array
			-- this will loop through the source array for as many times as there are assoc dest elements
		    FOREACH _s_uuid IN ARRAY NEW.source_material_uuid
			LOOP
				_d_uuid := NEW.destination_material_uuid[_src_cnt];
	        	insert into vw_action (action_def_uuid, workflow_uuid, workflow_action_set_uuid, action_description, source_material_uuid, destination_material_uuid, actor_uuid, status_uuid)
	            values (NEW.action_def_uuid, NEW.workflow_uuid, NEW.workflow_action_set_uuid,
	            	concat(NEW.description, ': ',(select description from vw_bom_material_index where bom_material_index_uuid = _s_uuid), ' -> ',
	            					(select description from vw_bom_material_index where bom_material_index_uuid = _d_uuid)),
	            	_s_uuid, _d_uuid, NEW.actor_uuid, NEW.status_uuid) returning action_uuid into _action_uuid;
				-- assign parameter value
				IF _calc_flg THEN
                    update vw_action_parameter set
                        parameter_val = (select put_val (
                            (select val_type_uuid from vw_parameter_def where parameter_def_uuid = NEW.parameter_def_uuid),
                            (select val_val from get_val (_calc_arr[1])),
                            (select valunit from vw_parameter_def where parameter_def_uuid = NEW.parameter_def_uuid)))
                    where action_uuid = _action_uuid;
                ELSE
                    update vw_action_parameter set
                        parameter_val = (select put_val (
                            (select val_type_uuid from vw_parameter_def where parameter_def_uuid = NEW.parameter_def_uuid),
                            (select val_val from get_val (NEW.parameter_val[1])),
                            (select valunit from vw_parameter_def where parameter_def_uuid = NEW.parameter_def_uuid)))
                    where action_uuid = _action_uuid;
                END IF;
				-- create the workflow_object
				insert into vw_workflow_object (workflow_uuid, workflow_action_set_uuid, action_uuid)
					values (NEW.workflow_uuid, NEW.workflow_action_set_uuid, _action_uuid) returning workflow_object_uuid into _object_uuid;
				-- create the workflow_step
				insert into vw_workflow_step (workflow_uuid, workflow_action_set_uuid, workflow_object_uuid, parent_uuid, status_uuid)
					values (NEW.workflow_uuid, NEW.workflow_action_set_uuid, _object_uuid, _step_uuid, NEW.status_uuid) returning workflow_step_uuid into _step_uuid;
				-- increment the source element pointer; bail if it is greater than the destination count
				_src_cnt := _src_cnt + 1;
				IF _src_cnt > array_length(NEW.destination_material_uuid, 1) THEN
					EXIT;
				END IF;
			END LOOP; 
		END IF;
		RETURN NEW;
	END IF;
END;
$$
LANGUAGE plpgsql;



/*
Name:			upsert_experiment_parameter()
Parameters:
Returns:		void
Author:			G. Cattabriga
Date:			2020.12.26
Description:    trigger proc that executes only on an update (to the list of actions)
                The update process depends on action type (action, action_set):
                it may only update a parameter value (action) or,
                delete a set of actions and rebuild the actions based on new parameter (action_set)
Notes:			todo: this may or may not need to address changes to materials. Not sure if that will be a separate proc

                The view (vw_experiment_parameter) returns values (val) in array form, as workflow_action_set allows for
                an array of values as input

Example:        update vw_experiment_parameter
                    set parameter_value =
                        array[(select put_val ((select val_type_uuid from vw_parameter_def where description = 'temperature'), '999.99',
                            (select valunit from vw_parameter_def where description = 'temperature')))]
                where experiment = 'TC Test Experiment Template' and object_description = 'Heat Sample Prep Plate'
                    and parameter_def_description = 'temperature';

                update vw_experiment_parameter
                    set parameter_value =
                        array[(select put_val ((select val_type_uuid from vw_parameter_def where description = 'total_vol'), '2.5',
                            (select valunit from vw_parameter_def where description = 'total_vol')))]
                where experiment = 'TC Test Experiment Template' and object_description = 'dispense H2O into SamplePrep Plate action_set'
                    and parameter_def_description = 'total_vol';
                update vw_experiment_parameter
                    set parameter_value =
                        array[(select put_val ((select val_type_uuid from vw_parameter_def where description = 'total_vol'), '2.5',
                            (select valunit from vw_parameter_def where description = 'total_vol')))]
                where experiment = 'TC Test Experiment Template' and object_description = 'dispense HCL into SamplePrep Plate action_set'
                    and parameter_def_description = 'total_vol';

                update vw_experiment_parameter
                    set parameter_value =
                        array[(select put_val ((select val_type_uuid from vw_parameter_def where description = 'total_vol'), '9.9',
                            (select valunit from vw_parameter_def where description = 'volume')))]
                where experiment = 'TC Test Experiment Template' and object_description = 'dispense Am-Stock into SamplePrep Plate action_set'
                    and parameter_def_description = 'volume';

 */
CREATE OR REPLACE FUNCTION upsert_experiment_parameter ()
	RETURNS TRIGGER
	AS $$
DECLARE
    _calculation_uuid uuid;
BEGIN
	IF(TG_OP = 'UPDATE') THEN
        CASE
            WHEN NEW.workflow_object = 'action' THEN
                UPDATE
                    parameter
		        SET
		            -- as there is only one parameter val that can be passed, but the incoming parameter is an array, we can point to the first element
		            parameter_val = NEW.parameter_value[1],
                    mod_date = now()
		        WHERE
		            parameter.parameter_uuid = NEW.parameter_uuid;
            RETURN NEW;
            WHEN NEW.workflow_object = 'action_set' THEN
                -- save off the workflow_action_set row
                create temp table _workflow_action_set as
                select * from vw_workflow_action_set
                where workflow_action_set_uuid = NEW.object_uuid;
                -- delete the workflow objects and steps
                delete from workflow_step
                where workflow_action_set_uuid = NEW.object_uuid;
                delete from workflow_object
                where workflow_action_set_uuid = NEW.object_uuid;
                -- delete the workflow_action_set actions
                delete from action
                where workflow_action_set_uuid = NEW.object_uuid;
                -- delete the workflow_action_set
                delete from workflow_action_set
                where workflow_action_set_uuid = NEW.object_uuid;
                -- determine if we need to recalc the calculation
                IF (select calculation_uuid from _workflow_action_set) is not null THEN
                    -- save the calculation row because we need to delete and re-insert
                    create temp table _calculation as
                    select * from vw_calculation
                    where calculation_uuid = (select calculation_uuid from _workflow_action_set);
                    -- now update the parameter_def value
                    UPDATE
                        parameter_def
		            SET
		                default_val = NEW.parameter_value[1],
                        mod_date = now()
		            WHERE
		                parameter_def.parameter_def_uuid = NEW.parameter_uuid;
                    -- delete the calculation record
                    delete from vw_calculation where calculation_uuid = (select calculation_uuid from _calculation);
                    insert into vw_calculation (calculation_def_uuid, calculation_alias_name, in_val, in_opt_val, out_val, actor_uuid, status_uuid)
                        ((select calculation_def_uuid, calculation_alias_name, in_val, in_opt_val,
                            (select do_calculation(((select calculation_def_uuid from _calculation)))),
                            actor_uuid, status_uuid
                        from _calculation)) returning calculation_uuid into _calculation_uuid;
                    insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration, repeating,
                        parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid, actor_uuid, status_uuid)
                        ((select description, workflow_uuid, action_def_uuid, start_date, end_date, duration, repeating,
                        parameter_def_uuid, parameter_val, _calculation_uuid, source_material_uuid, destination_material_uuid, actor_uuid, status_uuid from _workflow_action_set));
                    drop table _calculation;
                ELSIF (select parameter_val from _workflow_action_set) is not null THEN
                    insert into vw_workflow_action_set (description, workflow_uuid, action_def_uuid, start_date, end_date, duration, repeating,
                        parameter_def_uuid, parameter_val, calculation_uuid, source_material_uuid, destination_material_uuid, actor_uuid, status_uuid)
                        ((select description, workflow_uuid, action_def_uuid, start_date, end_date, duration, repeating,
                        parameter_def_uuid, NEW.parameter_value, calculation_uuid, source_material_uuid, destination_material_uuid, actor_uuid, status_uuid from _workflow_action_set));
                END IF;
                drop table _workflow_action_set;
                RETURN NEW;
        END CASE;
	END IF;
END;
$$
LANGUAGE plpgsql;
