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
INSERT INTO "escalate_change_log" (issue, object_type, object_name, resolution, author, status, create_date, close_date) VALUES ('inventory_crate_date', 'view', 'vw_inventory_material', 'fix spelling', 'GC', 'complete', '2020-04-14 13:45:11-04', '2020-04-14 13:45:13-04');
INSERT INTO "escalate_change_log" (issue, object_type, object_name, resolution, author, status, create_date, close_date) VALUES ('note_text instead of notetext', 'view', 'vw_m_descriptor', 'fix spelling', 'GC', 'complete', '2020-04-14 13:46:09-04', '2020-04-14 13:46:11-04');
INSERT INTO "escalate_change_log" (issue, object_type, object_name, resolution, author, status, create_date, close_date) VALUES ('no uuid', 'view', 'vw_organization', 'add uuid', 'GC', 'complete', '2020-04-14 13:47:41-04', '2020-04-14 13:47:43-04');
INSERT INTO "escalate_change_log" (issue, object_type, object_name, resolution, author, status, create_date, close_date) VALUES ('no uuid', 'view', 'vw_note', 'add uuid', 'GC', 'complete', '2020-04-14 13:46:54-04', '2020-04-14 13:46:56-04');
INSERT INTO "escalate_change_log" (issue, object_type, object_name, resolution, author, status, create_date, close_date) VALUES ('no uuid', 'view', 'vw_person', 'add uuid', 'GC', 'complete', '2020-04-14 13:48:11-04', '2020-04-14 13:48:13-04');
INSERT INTO "escalate_change_log" (issue, object_type, object_name, resolution, author, status, create_date, close_date) VALUES ('no uuid', 'view', 'vw_status', 'add uuid', 'GC', 'complete', '2020-04-14 13:48:39-04', '2020-04-14 13:48:41-04');
INSERT INTO "escalate_change_log" (issue, object_type, object_name, resolution, author, status, create_date, close_date) VALUES ('vw_material returns error', 'database', 'NULL', '''dev'' schema not in search_pat. add line to backup sql: SELECT set_config(''search_path'', ''dev,''||current_setting(''search_path''), false);', 'GC', 'complete', '2020-04-14 13:50:07-04', '2020-04-14 13:50:10-04');
INSERT INTO "escalate_change_log" (issue, object_type, object_name, resolution, author, status, create_date, close_date) VALUES ('edocument needs filename', 'table', 'edocument', 'add title, filename and source to edocument', 'GC', 'complete', '2020-04-15 13:50:07-04', '2020-04-15 14:50:10-04');
COMMIT;

-- ----------------------------
-- Primary Key structure for table escalate_change_log
-- ----------------------------
ALTER TABLE "escalate_change_log" ADD CONSTRAINT "pk_escalate_change_log_uuid" PRIMARY KEY ("change_log_uuid");

-- ----------------------------
-- Cluster option for table escalate_change_log
-- ----------------------------
ALTER TABLE "escalate_change_log" CLUSTER ON "pk_escalate_change_log_uuid";
