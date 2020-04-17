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

 Date: 14/04/2020 13:51:07
*/


-- ----------------------------
-- Table structure for escalate_version
-- ----------------------------
DROP TABLE IF EXISTS "escalate_version";
CREATE TABLE "escalate_version" (
  "ver_uuid" uuid NOT NULL DEFAULT uuid_generate_v4(),
  "short_name" varchar COLLATE "pg_catalog"."default",
  "description" varchar COLLATE "pg_catalog"."default",
  "add_date" timestamptz(6) NOT NULL DEFAULT now()
)
;


-- ----------------------------
-- Records of escalate_version
-- ----------------------------
BEGIN;
INSERT INTO "escalate_version" (short_name, description) VALUES ('3.0.0.b1', 'escalate V3 beta');
COMMIT;

-- ----------------------------
-- Uniques structure for table escalate_version
-- ----------------------------
ALTER TABLE "escalate_version" ADD CONSTRAINT "un_escalate_version" UNIQUE ("ver_uuid", "short_name");

-- ----------------------------
-- Primary Key structure for table escalate_version
-- ----------------------------
ALTER TABLE "escalate_version" ADD CONSTRAINT "pk_escalate_version_uuid" PRIMARY KEY ("ver_uuid");

-- ----------------------------
-- Cluster option for table escalate_version
-- ----------------------------
ALTER TABLE "escalate_version" CLUSTER ON "pk_escalate_version_uuid";
