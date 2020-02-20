/*
 Navicat Premium Data Transfer

 Source Server         : postgres12
 Source Server Type    : PostgreSQL
 Source Server Version : 120001
 Source Host           : localhost:5432
 Source Catalog        : escalate
 Source Schema         : dev

 Target Server Type    : PostgreSQL
 Target Server Version : 120001
 File Encoding         : 65001

 Date: 18/02/2020 13:15:23
*/


-- ----------------------------
-- Table structure for actor_pref
-- ----------------------------
DROP TABLE IF EXISTS "dev"."actor_pref";
CREATE TABLE "dev"."actor_pref" (
  "actor_pref_id" int8 NOT NULL DEFAULT nextval('"dev".actor_pref_actor_pref_id_seq'::regclass),
  "actor_pref_uuid" uuid DEFAULT dev.uuid_generate_v4(),
  "actor_id" int8,
  "pkey" varchar(255) COLLATE "pg_catalog"."default",
  "pvalue" varchar COLLATE "pg_catalog"."default",
  "note_id" int8,
  "add_date" timestamptz(6) NOT NULL DEFAULT now(),
  "mod_date" timestamptz(6) NOT NULL DEFAULT now()
)
;
ALTER TABLE "dev"."actor_pref" OWNER TO "gcattabriga";

-- ----------------------------
-- Records of actor_pref
-- ----------------------------
BEGIN;
INSERT INTO "dev"."actor_pref" VALUES (1, '6df5a871-b1da-41a8-ba74-0f860e687bc6', 4, 'MARVINSUITE_DIR', '/Applications/MarvinSuite/bin/', NULL, '2020-02-18 13:01:59.709746-05', '2020-02-18 13:01:59.709746-05');
INSERT INTO "dev"."actor_pref" VALUES (2, 'dff47728-622c-4b7b-a36e-1d55c2d981ae', 4, 'CHEMAXON_DIR', '/Applications/ChemAxon/JChemSuite/bin/', NULL, '2020-02-18 13:01:59.709746-05', '2020-02-18 13:01:59.709746-05');
COMMIT;

-- ----------------------------
-- Triggers structure for table actor_pref
-- ----------------------------
CREATE TRIGGER "set_timestamp" BEFORE UPDATE ON "dev"."actor_pref"
FOR EACH ROW
EXECUTE PROCEDURE "dev"."trigger_set_timestamp"();

-- ----------------------------
-- Primary Key structure for table actor_pref
-- ----------------------------
ALTER TABLE "dev"."actor_pref" ADD CONSTRAINT "pk_actor_pref_id" PRIMARY KEY ("actor_pref_id");

-- ----------------------------
-- Cluster option for table actor_pref
-- ----------------------------
ALTER TABLE "dev"."actor_pref" CLUSTER ON "pk_actor_pref_id";

-- ----------------------------
-- Foreign Keys structure for table actor_pref
-- ----------------------------
ALTER TABLE "dev"."actor_pref" ADD CONSTRAINT "fk_actor_pref_actor_1" FOREIGN KEY ("actor_id") REFERENCES "dev"."actor" ("actor_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
ALTER TABLE "dev"."actor_pref" ADD CONSTRAINT "fk_actor_pref_note_1" FOREIGN KEY ("note_id") REFERENCES "dev"."note" ("note_id") ON DELETE NO ACTION ON UPDATE NO ACTION;
