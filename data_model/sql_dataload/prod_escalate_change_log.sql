/*
 Navicat Premium Data Transfer

 Source Server         : postgres12 escalate
 Source Server Type    : PostgreSQL
 Source Server Version : 120001
 Source Host           : localhost:5432
 Source Catalog        : escalate
 Source Schema         : dev

 Target Server Type    : PostgreSQL
 Target Server Version : 120001
 File Encoding         : 65001

 Date: 14/04/2020 13:50:51
*/


-- ----------------------------
-- Table structure for escalate_change_log
-- ----------------------------
DROP TABLE IF EXISTS "escalate_change_log";
CREATE TABLE "escalate_change_log" (
  "change_log_uuid" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "issue" varchar COLLATE "pg_catalog"."default",
  "object_type" varchar COLLATE "pg_catalog"."default",
  "object_name" varchar COLLATE "pg_catalog"."default",
  "resolution" varchar COLLATE "pg_catalog"."default",
  "author" varchar COLLATE "pg_catalog"."default",
  "status" varchar COLLATE "pg_catalog"."default",
  "create_date" timestamptz(6) NOT NULL DEFAULT now(),
  "close_date" timestamptz(6) NOT NULL DEFAULT now()
)
;


-- ----------------------------
-- Records of escalate_change_log
-- ----------------------------
BEGIN;
INSERT INTO "escalate_change_log" VALUES ('eb1ad3b2-a49c-48e6-a491-da8f8d0fd21e', 'inventory_crate_date', 'view', 'vw_inventory_material', 'fix spelling', 'GC', 'complete', '2020-04-14 13:45:11-04', '2020-04-14 13:45:13-04');
INSERT INTO "escalate_change_log" VALUES ('1709f45b-765c-40d5-88bb-f531a78ff260', 'note_text instead of notetext', 'view', 'vw_m_descriptor', 'fix spelling', 'GC', 'complete', '2020-04-14 13:46:09-04', '2020-04-14 13:46:11-04');
INSERT INTO "escalate_change_log" VALUES ('a0937340-a17e-4449-985d-609a8c450b79', 'no uuid', 'view', 'vw_organization', 'add uuid', 'GC', 'complete', '2020-04-14 13:47:41-04', '2020-04-14 13:47:43-04');
INSERT INTO "escalate_change_log" VALUES ('32362f61-f53c-4f06-8e19-f48c4d57c27d', 'no uuid', 'view', 'vw_note', 'add uuid', 'GC', 'complete', '2020-04-14 13:46:54-04', '2020-04-14 13:46:56-04');
INSERT INTO "escalate_change_log" VALUES ('e59573be-13fe-4a71-b64c-a5cb353d4d37', 'no uuid', 'view', 'vw_person', 'add uuid', 'GC', 'complete', '2020-04-14 13:48:11-04', '2020-04-14 13:48:13-04');
INSERT INTO "escalate_change_log" VALUES ('710de792-e71f-46b6-be24-106b80ef3a3c', 'no uuid', 'view', 'vw_status', 'add uuid', 'GC', 'complete', '2020-04-14 13:48:39-04', '2020-04-14 13:48:41-04');
INSERT INTO "escalate_change_log" VALUES ('f85466b6-548c-4646-bba8-c9829e170c7e', 'vw_material returns error', 'database', 'NULL', '''dev'' schema not in search_pat. add line to backup sql: SELECT set_config(''search_path'', ''dev,''||current_setting(''search_path''), false);', 'GC', 'complete', '2020-04-14 13:50:07-04', '2020-04-14 13:50:10-04');
COMMIT;

-- ----------------------------
-- Primary Key structure for table escalate_change_log
-- ----------------------------
ALTER TABLE "escalate_change_log" ADD CONSTRAINT "pk_escalate_change_log_uuid" PRIMARY KEY ("change_log_uuid");

-- ----------------------------
-- Cluster option for table escalate_change_log
-- ----------------------------
ALTER TABLE "escalate_change_log" CLUSTER ON "pk_escalate_change_log_uuid";
