/*
 Navicat Premium Data Transfer

 Source Server         : docker_escalate
 Source Server Type    : PostgreSQL
 Source Server Version : 120001
 Source Host           : 0.0.0.0:54320
 Source Catalog        : escalate
 Source Schema         : dev

 Target Server Type    : PostgreSQL
 Target Server Version : 120001
 File Encoding         : 65001

 Date: 22/01/2020 09:40:04
*/


-- ----------------------------
-- Table structure for load_hc_inventory
-- ----------------------------
DROP TABLE IF EXISTS "load_hc_inventory";
CREATE TABLE "load_hc_inventory" (
  "reagent" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "part_no" varchar(255) COLLATE "pg_catalog"."default",
  "amount" float8,
  "units" varchar(255) COLLATE "pg_catalog"."default",
  "update_date" timestamptz(6) NOT NULL DEFAULT now(),
  "create_date" timestamptz(6) NOT NULL DEFAULT '2019-06-01 00:00:00+00'::timestamp with time zone
)
;

-- ----------------------------
-- Records of load_hc_inventory
-- ----------------------------
BEGIN;
INSERT INTO "load_hc_inventory" VALUES ('Lead Bromide', '211141-100G', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Methylammonium Bromide', '806498-25g', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Ethylammonium bromine', '900868-25g', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Imidazolium Bromide', NULL, NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('formamidinium bromide', '146958-06-7', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('phenethylammonium bromide', '53916-94-2', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('guanidinium bromide', '900839-25g', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('benzylammonium bromide', '900885-5g', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('ethane-1,2-diammonium bromide', '624-59-9', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('piperazine-1,4-diium bromide', '', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('n-dodecylammonium bromide', '26204-55-7', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('dimethylammonium bromide', '6912-12-05', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('neo-pentylammonium bromide', 'missing CAS RN', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('pyrrolidinium bromide', '55810-80-5', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('quinuclidinium bromide', '60662-68-2', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('iso-butylammonium bromide', 'batch#: 569205', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('iso-propylammonium bromide', '29552-58-7', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Formic Acid', NULL, NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Lead Oxide', '211907-100G', NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Cesium iodide', NULL, NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Bismuth iodide', NULL, NULL, NULL, '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Lead Iodide', NULL, 200, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Methylammonium iodide', '806390-25G (MS101000-100)', 0, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Ethylammonium iodide', '805823-25G', 100, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('n-Butylammonium Iodide', 'MS106000', 130, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Phenethylammonium iodide ', '805904-25G', 105, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Formamidinium Iodide', 'MS-150000', 50, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Guanidinium Iodide', '806056', 100, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Imidazolium Iodide', 'MS-170000-100', 5, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Acetamidinium Iodide', '805971-25G', 5, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Benzylammonium Iodide', '806196-25G', 100, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('neo-Pentylammonium iodide', 'MS100740-100', 20, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('iso-Butylammonium iodide', 'MS107000-100', 15, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Dimethylammonium iodide', 'MS111100-100', 155, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('n-Dodecylammonium iodide', 'MS100880-100', 2, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Pyrrolidinium Iodide', 'MS119700-100', 100, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('N-propylammonium Iodide', '805858-25G', 100, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Quinuclidinium iodide', NULL, 10, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Piperazine-1,4-diium iodide', NULL, 20, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Cyclohexylammonium iodide', 'MS100840-100', 5, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('tert-Octylammonium iodide', 'MS100830-100', 5, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('4-Trifluoromethyl-Phenylammonium iodide', 'MS100790-100', 10, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('4-Methoxy-Phenylammonium iodide', 'MS100610-100', 0, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Propane-1,3-diammonium iodide', NULL, 50, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('4-Fluoro-Phenylammonium iodide', 'MS100620-100', 5, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('iso-Pentylammonium iodide', 'MS100710-100', 50, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('n-Hexylammonium iodide', 'MS100860-100', 35, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('4-Fluoro- Benzylammonium iodide', 'MS100730-10', 140, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('4-Trifluoromethyl-Benzylammonium iodide', 'MS100780-100', 105, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('4-Fluoro-Phenethylammonium iodide', 'MS100720-100', 0, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Cyclohexylmethylammonium iodide', NULL, 60, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Ethane-1,2-diammonium iodide', 'MS102002-10', 145, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Butane-1,4 Diammonium Iodide', 'MS104040-10', 35, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Phenylammonium Iodide', 'MS108000-10', 135, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Morpholinium Iodide', 'MS110640-10', 25, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Piperidinium Iodide', 'MS119800-10', 30, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('t-Butylammonium Iodide', 'MS106000-10', 90, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('n-Octylammonium Iodide', 'MS105500-10', 40, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('1,4-Diazabicyclo[2,2,2]octane-1,4-diium Iodide', 'MS129400-10', 15, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('5-Azaspiro[4.4]nonan-5-ium iodide', NULL, 10, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Pyridinium Iodide', 'MS129810-10', 20, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('iso-Propylammonium iodide', 'MS104000-10', 75, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Di-isopropylammonium Iodide', NULL, 50, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Diethylammonium iodide', NULL, 10, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('1,4-Benzene diammonium iodide', NULL, 15, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('N,N-Dimethylethane- 1,2-diammonium iodide', NULL, 15, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('N,N-Diethylpropane-1,3-diammonium iodide', NULL, 20, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('2-Pyrrolidin-1-ium-1-ylethylammonium iodide', NULL, 20, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('N,N-dimethylpropane- 1,3-diammonium iodide', NULL, 20, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('4-methoxy-phenethylammonium-iodide', NULL, 60, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Methyl phenyl phosphonium iodide', NULL, 50, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Ethyl phenyl phosphonium iodide', NULL, 100, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Bismuth III Iodide', NULL, 25, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Indium III Chloride', NULL, 10, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Indium II Chloride', NULL, 10, 'g', '2019-10-28 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('Acetamidinium Bromide', NULL, 8.5924, 'g', '2019-06-18 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('n-Butylammonium Bromide', '', 6.9658, 'g', '2019-06-18 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('N,N-Dimethylformamide (/DMF)', '227056-1L', 0, 'g', '2019-06-25 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('GBL', 'B1198-3KG', 0, 'g', '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
INSERT INTO "load_hc_inventory" VALUES ('DMSO', NULL, 0, 'g', '0001-01-01 00:00:00+00', '2019-06-01 00:00:00+00');
COMMIT;
