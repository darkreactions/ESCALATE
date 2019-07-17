ALTER TABLE "ORGANIZATION" DROP CONSTRAINT "fk_ORGANIZATION_PERSON_1";
ALTER TABLE "ORGANIZATION" DROP CONSTRAINT "fk_ORGANIZATION_EQUIPMENT_1";
ALTER TABLE "WORKFLOW" DROP CONSTRAINT "fk_WORKFLOW_EXPERIMENT_1";
ALTER TABLE "PERSON" DROP CONSTRAINT "fk_PERSON_WORKFLOW_1";
ALTER TABLE "EXPERIMENT" DROP CONSTRAINT "fk_EXPERIMENT_ACTIONPLAN_1";
ALTER TABLE "EXPERIMENT" DROP CONSTRAINT "fk_EXPERIMENT_EXPERIMENT_1";
ALTER TABLE "ACTION_PLAN" DROP CONSTRAINT "fk_ACTIONPLAN_ACTION_1";
ALTER TABLE "INGREDIENT" DROP CONSTRAINT "fk_INGREDIENT_COMPOUND_1";
ALTER TABLE "ACTION" DROP CONSTRAINT "fk_ACTION_ACTIONTYPE_1";
ALTER TABLE "AGGREGATE" DROP CONSTRAINT "fk_COMPOUND_ACTION_INGREDIENT_1";
ALTER TABLE "INGREDIENT" DROP CONSTRAINT "fk_INGREDIENT_ACTION_INGREDIENT_1";
ALTER TABLE "ACTION" DROP CONSTRAINT "fk_ACTION_ACTION_INGREDIENT_1";
ALTER TABLE "ACTION_INGREDIENT" DROP CONSTRAINT "fk_ACTION_INGREDIENT_MEASURE_1";
ALTER TABLE "MEASURE" DROP CONSTRAINT "fk_MEASURE_MEASURE_TYPE_1";
ALTER TABLE "ACTION" DROP CONSTRAINT "fk_ACTION_MEASURE_1";
ALTER TABLE "STATUS" DROP CONSTRAINT "fk_STATUS_WORKFLOW_1";
ALTER TABLE "STATUS" DROP CONSTRAINT "fk_STATUS_EXPERIMENT_1";
ALTER TABLE "ACTION" DROP CONSTRAINT "fk_ACTION_SOURCE_1";
ALTER TABLE "OUTCOME" DROP CONSTRAINT "fk_OUTCOME_SOURCE_1";
ALTER TABLE "EXPERIMENT" DROP CONSTRAINT "fk_EXPERIMENT_OUTCOME_1";
ALTER TABLE "PERSON" DROP CONSTRAINT "fk_PERSON_ACTOR_1";
ALTER TABLE "ORGANIZATION" DROP CONSTRAINT "fk_ORGANIZATION_ACTOR_1";
ALTER TABLE "SYSTEM" DROP CONSTRAINT "fk_EQUIPMENT_ACTOR_1";
ALTER TABLE "MEASURE" DROP CONSTRAINT "fk_MEASURE_DOCUMENT_1";
ALTER TABLE "OUTCOME" DROP CONSTRAINT "fk_OUTCOME_MEASURE_1";
ALTER TABLE "OUTCOME" DROP CONSTRAINT "fk_OUTCOME_COMPOUND_1";
ALTER TABLE "ACTOR" DROP CONSTRAINT "fk_ACTOR_DESCRIPTOR_1";
ALTER TABLE "WORKFLOW" DROP CONSTRAINT "fk_WORKFLOW_DOCUMENT_1";
ALTER TABLE "EXPERIMENT" DROP CONSTRAINT "fk_EXPERIMENT_DOCUMENT_1";
ALTER TABLE "SYSTEM" DROP CONSTRAINT "fk_SYSTEM_SYSTEMTYPE_1";
ALTER TABLE "INGREDIENT" DROP CONSTRAINT "fk_INGREDIENT_INGREDIENTREF_1";
ALTER TABLE "INGREDIENT_REF" DROP CONSTRAINT "fk_INGREDIENTREF_INGREDIENTTYPE_1";
ALTER TABLE "STATUS" DROP CONSTRAINT "fk_STATUS_DESCRIPTOR_1";
ALTER TABLE "DESCRIPTOR" DROP CONSTRAINT "fk_DESCRIPTOR_DESCRIPTOR_CLASS_1";
ALTER TABLE "INGREDIENT" DROP CONSTRAINT "fk_INGREDIENT_DESCRIPTOR_1";
ALTER TABLE "DESCRIPTOR" DROP CONSTRAINT "fk_DESCRIPTOR_DESCRIPTOR_VALUE_1";

DROP TABLE "ORGANIZATION";
DROP TABLE "PERSON";
DROP TABLE "SYSTEM";
DROP TABLE "WORKFLOW";
DROP TABLE "EXPERIMENT";
DROP TABLE "ACTION_PLAN";
DROP TABLE "ACTION_DEF";
DROP TABLE "ACTION";
DROP TABLE "AGGREGATE";
DROP TABLE "INGREDIENT";
DROP TABLE "MEASURE";
DROP TABLE "ACTION_INGREDIENT";
DROP TABLE "MEASURE_TYPE";
DROP TABLE "STATUS";
DROP TABLE "OUTCOME";
DROP TABLE "ACTOR";
DROP TABLE "DESCRIPTOR";
DROP TABLE "OUT";
DROP TABLE "DESCRIPTOR_VALUE";
DROP TABLE "TAG";
DROP TABLE "DOCUMENT";
DROP TABLE "INGREDIENT_REF";
DROP TABLE "SYSTEMTYPE";
DROP TABLE "INGREDIENT_TYPE";
DROP TABLE "DESCRIPTOR_CLASS";

CREATE TABLE "ORGANIZATION" (
"organizationID" int4 NOT NULL,
"description" varchar(255),
"name" varchar(255) NOT NULL,
"address1" varchar(255),
"address2" varchar(255),
"city" varchar(255),
"state" char(2),
"zip" varchar(255),
"website_url" varchar(255),
"phone" varchar(255),
"note" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("organizationID") 
)
WITHOUT OIDS;
CREATE TABLE "PERSON" (
"personID" int4 NOT NULL,
"firstname" varchar(255),
"lastname" varchar(255) NOT NULL,
"middlename" varchar(255),
"address1" varchar(255),
"address2" varchar(255),
"city" varchar(255),
"state" char(2),
"phone" varchar(255),
"email" varchar(255),
"title" varchar(255),
"suffix" varchar(255),
"organizationID" int4,
"note" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("personID") 
)
WITHOUT OIDS;
CREATE TABLE "SYSTEM" (
"systemID" int4 NOT NULL,
"name" varchar(255) NOT NULL,
"description" varchar(255),
"systemtypeID" int4,
"vendor" varchar(255),
"model" varchar(255),
"serial" varchar(255),
"version" varchar(255),
"organizationID" int4,
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("systemID") 
)
WITHOUT OIDS;
CREATE TABLE "WORKFLOW" (
"workflowID" int4 NOT NULL,
"description" varchar(255) NOT NULL,
"ownerID" int4,
"statusID" int4,
"note" varchar(255),
"documentID" int4,
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("workflowID") 
)
WITHOUT OIDS;
CREATE TABLE "EXPERIMENT" (
"experimentID" int4 NOT NULL,
"description" varchar(255),
"parent_experimentID" int4,
"statusID" int4,
"outcomeID" int4,
"documentID" int4,
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("experimentID") 
)
WITHOUT OIDS;
CREATE TABLE "ACTION_PLAN" (
"action_planID" int4 NOT NULL,
"experimentID" int4,
"actionID" int4,
"seq" int4,
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("action_planID") 
)
WITHOUT OIDS;
CREATE TABLE "ACTION_DEF" (
"action_defID" int4 NOT NULL,
"description" varchar(255),
"category" varchar(255),
"note" varchar(255),
"alias" varchar(255),
"add_dt" varchar(255),
"mod_dt" varchar(255),
PRIMARY KEY ("action_defID") 
)
WITHOUT OIDS;
CREATE TABLE "ACTION" (
"actionID" int4 NOT NULL,
"description" varchar(255),
"action_defID" int4,
"measureID" int4,
"performerID" int4,
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("actionID") 
)
WITHOUT OIDS;
CREATE TABLE "AGGREGATE" (
"coumpoundID" int4 NOT NULL,
"description" varchar(255),
"actorID" int4,
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("coumpoundID") 
)
WITHOUT OIDS;
CREATE TABLE "INGREDIENT" (
"ingredientID" int4 NOT NULL,
"description" varchar(255),
"ingredient_refID" int4,
"actorID" int4,
"descriptorID" int4,
"aggregateID" int4,
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("ingredientID") 
)
WITHOUT OIDS;
CREATE TABLE "MEASURE" (
"measureID" int4 NOT NULL,
"measure_typeID" int4,
"amount" numeric(255),
"unit" varchar(255),
"datadocID" int4,
"note" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("measureID") 
)
WITHOUT OIDS;
CREATE TABLE "ACTION_INGREDIENT" (
"action_ingredientID" int4 NOT NULL,
"actionID" int4,
"compoundID" int4,
"ingredientID" int4,
"measureID" int4,
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("action_ingredientID") 
)
WITHOUT OIDS;
CREATE TABLE "MEASURE_TYPE" (
"measure_typeID" int4 NOT NULL,
"description" varchar(255),
"note" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("measure_typeID") 
)
WITHOUT OIDS;
CREATE TABLE "STATUS" (
"statusID" int4 NOT NULL,
"description" varchar(255),
"alias" varchar(255),
"note" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("statusID") 
)
WITHOUT OIDS;
CREATE TABLE "OUTCOME" (
"outcomeID" int4 NOT NULL,
"description" varchar(255),
"actorID" int4,
"measureID" int4,
"datafile" bytea,
"compoundID" int4,
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("outcomeID") 
)
WITHOUT OIDS;
CREATE TABLE "ACTOR" (
"actorID" int4 NOT NULL,
"personID" int4,
"organizationID" int4,
"systemID" int4,
"description" varchar(255),
"note" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("actorID") 
)
WITHOUT OIDS;
CREATE TABLE "DESCRIPTOR" (
"descritptorID" int4 NOT NULL,
"description" varchar(255),
"ingredientID" int4,
"descriptor_classID" int4,
"descriptor_valueID" int4,
"actorID" int4,
"statusID" int4,
"version" varchar(255),
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("descritptorID") 
)
WITHOUT OIDS;
CREATE TABLE "OUT" (
)
WITHOUT OIDS;
CREATE TABLE "DESCRIPTOR_VALUE" (
"dscriptor_valueID" int4 NOT NULL,
"num_value" int4,
"blob_value" bytea,
"add_dt" varchar(255),
"mod_dt" varchar(255),
PRIMARY KEY ("dscriptor_valueID") 
)
WITHOUT OIDS;
CREATE TABLE "TAG" (
"tagID" int4 NOT NULL,
"description" varchar(255),
"note" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("tagID") 
)
WITHOUT OIDS;
CREATE TABLE "DOCUMENT" (
"documentID" int4 NOT NULL,
"description" varchar(255),
"document" bytea,
"doctype" varchar(255),
"version" varchar(255),
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("documentID") 
)
WITHOUT OIDS;
CREATE TABLE "INGREDIENT_REF" (
"ingredient_refID" int4 NOT NULL,
"description" varchar(255),
"ingredient_typeID" int4,
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("ingredient_refID") 
)
WITHOUT OIDS;
CREATE TABLE "SYSTEMTYPE" (
"systemtypeID" int4 NOT NULL,
"description" varchar(255),
"note" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("systemtypeID") 
)
WITHOUT OIDS;
CREATE TABLE "INGREDIENT_TYPE" (
"ingredient_typeID" int4 NOT NULL,
"descritption" varchar(255),
"note" varchar(255),
"alias" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("ingredient_typeID") 
)
WITHOUT OIDS;
CREATE TABLE "DESCRIPTOR_CLASS" (
"descriptot_classID" int4 NOT NULL,
"description" varchar(255),
"note" varchar(255),
"add_dt" timestamp(255),
"mod_dt" timestamp(255),
PRIMARY KEY ("descriptot_classID") 
)
WITHOUT OIDS;

ALTER TABLE "ORGANIZATION" ADD CONSTRAINT "fk_ORGANIZATION_PERSON_1" FOREIGN KEY ("organizationID") REFERENCES "PERSON" ("organizationID");
ALTER TABLE "ORGANIZATION" ADD CONSTRAINT "fk_ORGANIZATION_EQUIPMENT_1" FOREIGN KEY ("organizationID") REFERENCES "SYSTEM" ("organizationID");
ALTER TABLE "WORKFLOW" ADD CONSTRAINT "fk_WORKFLOW_EXPERIMENT_1" FOREIGN KEY ("workflowID") REFERENCES "EXPERIMENT" ("experimentID");
ALTER TABLE "PERSON" ADD CONSTRAINT "fk_PERSON_WORKFLOW_1" FOREIGN KEY ("personID") REFERENCES "WORKFLOW" ("ownerID");
ALTER TABLE "EXPERIMENT" ADD CONSTRAINT "fk_EXPERIMENT_ACTIONPLAN_1" FOREIGN KEY ("experimentID") REFERENCES "ACTION_PLAN" ("experimentID");
ALTER TABLE "EXPERIMENT" ADD CONSTRAINT "fk_EXPERIMENT_EXPERIMENT_1" FOREIGN KEY ("parent_experimentID") REFERENCES "EXPERIMENT" ("experimentID");
ALTER TABLE "ACTION_PLAN" ADD CONSTRAINT "fk_ACTIONPLAN_ACTION_1" FOREIGN KEY ("actionID") REFERENCES "ACTION" ("actionID");
ALTER TABLE "INGREDIENT" ADD CONSTRAINT "fk_INGREDIENT_COMPOUND_1" FOREIGN KEY ("aggregateID") REFERENCES "AGGREGATE" ("coumpoundID");
ALTER TABLE "ACTION" ADD CONSTRAINT "fk_ACTION_ACTIONTYPE_1" FOREIGN KEY ("action_defID") REFERENCES "ACTION_DEF" ("action_defID");
ALTER TABLE "AGGREGATE" ADD CONSTRAINT "fk_COMPOUND_ACTION_INGREDIENT_1" FOREIGN KEY ("coumpoundID") REFERENCES "ACTION_INGREDIENT" ("compoundID");
ALTER TABLE "INGREDIENT" ADD CONSTRAINT "fk_INGREDIENT_ACTION_INGREDIENT_1" FOREIGN KEY ("ingredientID") REFERENCES "ACTION_INGREDIENT" ("ingredientID");
ALTER TABLE "ACTION" ADD CONSTRAINT "fk_ACTION_ACTION_INGREDIENT_1" FOREIGN KEY ("actionID") REFERENCES "ACTION_INGREDIENT" ("action_ingredientID");
ALTER TABLE "ACTION_INGREDIENT" ADD CONSTRAINT "fk_ACTION_INGREDIENT_MEASURE_1" FOREIGN KEY ("action_ingredientID") REFERENCES "MEASURE" ("measureID");
ALTER TABLE "MEASURE" ADD CONSTRAINT "fk_MEASURE_MEASURE_TYPE_1" FOREIGN KEY ("measureID") REFERENCES "MEASURE_TYPE" ("measure_typeID");
ALTER TABLE "ACTION" ADD CONSTRAINT "fk_ACTION_MEASURE_1" FOREIGN KEY ("actionID") REFERENCES "MEASURE" ("measureID");
ALTER TABLE "STATUS" ADD CONSTRAINT "fk_STATUS_WORKFLOW_1" FOREIGN KEY ("statusID") REFERENCES "WORKFLOW" ("statusID");
ALTER TABLE "STATUS" ADD CONSTRAINT "fk_STATUS_EXPERIMENT_1" FOREIGN KEY ("statusID") REFERENCES "EXPERIMENT" ("statusID");
ALTER TABLE "ACTION" ADD CONSTRAINT "fk_ACTION_SOURCE_1" FOREIGN KEY ("performerID") REFERENCES "ACTOR" ("actorID");
ALTER TABLE "OUTCOME" ADD CONSTRAINT "fk_OUTCOME_SOURCE_1" FOREIGN KEY ("actorID") REFERENCES "ACTOR" ("actorID");
ALTER TABLE "EXPERIMENT" ADD CONSTRAINT "fk_EXPERIMENT_OUTCOME_1" FOREIGN KEY ("outcomeID") REFERENCES "OUTCOME" ("outcomeID");
ALTER TABLE "PERSON" ADD CONSTRAINT "fk_PERSON_ACTOR_1" FOREIGN KEY ("personID") REFERENCES "ACTOR" ("personID");
ALTER TABLE "ORGANIZATION" ADD CONSTRAINT "fk_ORGANIZATION_ACTOR_1" FOREIGN KEY ("organizationID") REFERENCES "ACTOR" ("organizationID");
ALTER TABLE "SYSTEM" ADD CONSTRAINT "fk_EQUIPMENT_ACTOR_1" FOREIGN KEY ("systemID") REFERENCES "ACTOR" ("systemID");
ALTER TABLE "MEASURE" ADD CONSTRAINT "fk_MEASURE_DOCUMENT_1" FOREIGN KEY ("datadocID") REFERENCES "DOCUMENT" ("documentID");
ALTER TABLE "OUTCOME" ADD CONSTRAINT "fk_OUTCOME_MEASURE_1" FOREIGN KEY ("measureID") REFERENCES "MEASURE" ("measureID");
ALTER TABLE "OUTCOME" ADD CONSTRAINT "fk_OUTCOME_COMPOUND_1" FOREIGN KEY ("compoundID") REFERENCES "AGGREGATE" ("coumpoundID");
ALTER TABLE "ACTOR" ADD CONSTRAINT "fk_ACTOR_DESCRIPTOR_1" FOREIGN KEY ("actorID") REFERENCES "DESCRIPTOR" ("actorID");
ALTER TABLE "WORKFLOW" ADD CONSTRAINT "fk_WORKFLOW_DOCUMENT_1" FOREIGN KEY ("documentID") REFERENCES "DOCUMENT" ("documentID");
ALTER TABLE "EXPERIMENT" ADD CONSTRAINT "fk_EXPERIMENT_DOCUMENT_1" FOREIGN KEY ("documentID") REFERENCES "DOCUMENT" ("documentID");
ALTER TABLE "SYSTEM" ADD CONSTRAINT "fk_SYSTEM_SYSTEMTYPE_1" FOREIGN KEY ("systemtypeID") REFERENCES "SYSTEMTYPE" ("systemtypeID");
ALTER TABLE "INGREDIENT" ADD CONSTRAINT "fk_INGREDIENT_INGREDIENTREF_1" FOREIGN KEY ("ingredient_refID") REFERENCES "INGREDIENT_REF" ("ingredient_refID");
ALTER TABLE "INGREDIENT_REF" ADD CONSTRAINT "fk_INGREDIENTREF_INGREDIENTTYPE_1" FOREIGN KEY ("ingredient_typeID") REFERENCES "INGREDIENT_TYPE" ("ingredient_typeID");
ALTER TABLE "STATUS" ADD CONSTRAINT "fk_STATUS_DESCRIPTOR_1" FOREIGN KEY ("statusID") REFERENCES "DESCRIPTOR" ("statusID");
ALTER TABLE "DESCRIPTOR" ADD CONSTRAINT "fk_DESCRIPTOR_DESCRIPTOR_CLASS_1" FOREIGN KEY ("descriptor_classID") REFERENCES "DESCRIPTOR_CLASS" ("descriptot_classID");
ALTER TABLE "INGREDIENT" ADD CONSTRAINT "fk_INGREDIENT_DESCRIPTOR_1" FOREIGN KEY ("descriptorID") REFERENCES "DESCRIPTOR" ("descritptorID");
ALTER TABLE "DESCRIPTOR" ADD CONSTRAINT "fk_DESCRIPTOR_DESCRIPTOR_VALUE_1" FOREIGN KEY ("descriptor_valueID") REFERENCES "DESCRIPTOR_VALUE" ("dscriptor_valueID");

