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

 Date: 09/04/2020 09:36:19
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
  "create_date" timestamptz(6) NOT NULL DEFAULT '2019-05-31 20:00:00-04'::timestamp with time zone,
  "updated_by" varchar(255) COLLATE "pg_catalog"."default",
  "in_stock" float4,
  "remaining_stock" float4
)
;

-- ----------------------------
-- Records of load_hc_inventory
-- ----------------------------
BEGIN;
INSERT INTO "load_hc_inventory" VALUES ('Lead Iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 7, 350);
INSERT INTO "load_hc_inventory" VALUES ('Methylammonium iodide', '806390-25G (MS101000-100)', NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 4, 200);
INSERT INTO "load_hc_inventory" VALUES ('Ethylammonium iodide', '805823-25G', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 6, 200);
INSERT INTO "load_hc_inventory" VALUES ('n-Butylammonium Iodide', 'MS106000', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 8, 130);
INSERT INTO "load_hc_inventory" VALUES ('Phenethylammonium iodide ', '805904-25G', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 6, 105);
INSERT INTO "load_hc_inventory" VALUES ('Formamidinium Iodide', 'MS-150000', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 150);
INSERT INTO "load_hc_inventory" VALUES ('Guanidinium Iodide', '806056', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 200);
INSERT INTO "load_hc_inventory" VALUES ('Imidazolium Iodide', 'MS-170000-100', NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 4, 125);
INSERT INTO "load_hc_inventory" VALUES ('Acetamidinium Iodide', '805971-25G', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 55);
INSERT INTO "load_hc_inventory" VALUES ('Benzylammonium Iodide', '806196-25G', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 5, 200);
INSERT INTO "load_hc_inventory" VALUES ('neo-Pentylammonium iodide', 'MS100740-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('iso-Butylammonium iodide', 'MS107000-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 15);
INSERT INTO "load_hc_inventory" VALUES ('Dimethylammonium iodide', 'MS111100-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 8, 155);
INSERT INTO "load_hc_inventory" VALUES ('n-Dodecylammonium iodide', 'MS100880-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 22);
INSERT INTO "load_hc_inventory" VALUES ('Pyrrolidinium Iodide', 'MS119700-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 100);
INSERT INTO "load_hc_inventory" VALUES ('N-propylammonium Iodide', '805858-25G', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 4, 100);
INSERT INTO "load_hc_inventory" VALUES ('Quinuclidinium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 30);
INSERT INTO "load_hc_inventory" VALUES ('Piperazine-1,4-diium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Cyclohexylammonium iodide', 'MS100840-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 25);
INSERT INTO "load_hc_inventory" VALUES ('tert-Octylammonium iodide', 'MS100830-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 25);
INSERT INTO "load_hc_inventory" VALUES ('4-Trifluoromethyl-Phenylammonium iodide', 'MS100790-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('4-Methoxy-Phenylammonium iodide', 'MS100610-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Propane-1,3-diammonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 50);
INSERT INTO "load_hc_inventory" VALUES ('4-Fluoro-Phenylammonium iodide', 'MS100620-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 25);
INSERT INTO "load_hc_inventory" VALUES ('iso-Pentylammonium iodide', 'MS100710-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 50);
INSERT INTO "load_hc_inventory" VALUES ('n-Hexylammonium iodide', 'MS100860-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 4, 35);
INSERT INTO "load_hc_inventory" VALUES ('4-Fluoro- Benzylammonium iodide', 'MS100730-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 5, 140);
INSERT INTO "load_hc_inventory" VALUES ('4-Trifluoromethyl-Benzylammonium iodide', 'MS100780-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 105);
INSERT INTO "load_hc_inventory" VALUES ('4-Fluoro-Phenethylammonium iodide', 'MS100720-100', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 4, 20);
INSERT INTO "load_hc_inventory" VALUES ('Cyclohexylmethylammonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 6, 60);
INSERT INTO "load_hc_inventory" VALUES ('Ethane-1,2-diammonium iodide', 'MS102002-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 10, 145);
INSERT INTO "load_hc_inventory" VALUES ('Butane-1,4 Diammonium Iodide', 'MS104040-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 4, 35);
INSERT INTO "load_hc_inventory" VALUES ('Phenylammonium Iodide', 'MS108000-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 15, 135);
INSERT INTO "load_hc_inventory" VALUES ('Morpholinium Iodide', 'MS110640-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 4, 125);
INSERT INTO "load_hc_inventory" VALUES ('Piperidinium Iodide', 'MS119800-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 30);
INSERT INTO "load_hc_inventory" VALUES ('t-Butylammonium Iodide', 'MS106000-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 6, 90);
INSERT INTO "load_hc_inventory" VALUES ('n-Octylammonium Iodide', 'MS105500-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 4, 40);
INSERT INTO "load_hc_inventory" VALUES ('1,4-Diazabicyclo[2,2,2]octane-1,4-diium Iodide', 'MS129400-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 15);
INSERT INTO "load_hc_inventory" VALUES ('5-Azaspiro[4.4]nonan-5-ium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 10);
INSERT INTO "load_hc_inventory" VALUES ('Pyridinium Iodide', 'MS129810-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('iso-Propylammonium iodide', 'MS104000-10', NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 5, 75);
INSERT INTO "load_hc_inventory" VALUES ('Di-isopropylammonium Iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 50);
INSERT INTO "load_hc_inventory" VALUES ('Diethylammonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('1,4-Benzene diammonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 15);
INSERT INTO "load_hc_inventory" VALUES ('N,N-Dimethylethane- 1,2-diammonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 15);
INSERT INTO "load_hc_inventory" VALUES ('N,N-Diethylpropane-1,3-diammonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('2-Pyrrolidin-1-ium-1-ylethylammonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('N,N-dimethylpropane- 1,3-diammonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('4-methoxy-phenethylammonium-iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 60);
INSERT INTO "load_hc_inventory" VALUES ('Methyl phenyl phosphonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 50);
INSERT INTO "load_hc_inventory" VALUES ('Ethyl phenyl phosphonium iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 100);
INSERT INTO "load_hc_inventory" VALUES ('Bismuth III Iodide', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 25);
INSERT INTO "load_hc_inventory" VALUES ('Indium III Chloride', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('Indium II Chloride', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('Lead Bromide', '211141-100G', NULL, NULL, '2000-01-01 04:36:30-05', '2019-05-31 20:00:00-04', 'Mansoor', 13, 50);
INSERT INTO "load_hc_inventory" VALUES ('Methylammonium Bromide', '806498-25g', NULL, NULL, '2000-01-01 04:36:31-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 105);
INSERT INTO "load_hc_inventory" VALUES ('Ethylammonium bromine', '900868', NULL, NULL, '2000-01-01 04:36:32-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 135);
INSERT INTO "load_hc_inventory" VALUES ('Imidazolium Bromide', NULL, NULL, NULL, '2000-01-01 04:36:33-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 110);
INSERT INTO "load_hc_inventory" VALUES ('Acetamidinium Bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 108);
INSERT INTO "load_hc_inventory" VALUES ('n-Butylammonium Bromide', '4992019', NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 1066.9658);
INSERT INTO "load_hc_inventory" VALUES ('formamidinium bromide', '146958-06-7', NULL, NULL, '2000-01-01 04:36:36-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 145);
INSERT INTO "load_hc_inventory" VALUES ('phenethylammonium bromide', '53916-94-2', NULL, NULL, '2000-01-01 04:36:37-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 50);
INSERT INTO "load_hc_inventory" VALUES ('guanidinium bromide', '900839-25g', NULL, NULL, '2000-01-01 04:36:38-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 125);
INSERT INTO "load_hc_inventory" VALUES ('benzylammonium bromide', '900885-5g', NULL, NULL, '2000-01-01 04:36:39-05', '2019-05-31 20:00:00-04', 'Mansoor', 6, 125);
INSERT INTO "load_hc_inventory" VALUES ('ethane-1,2-diammonium bromide', '624-59-9', NULL, NULL, '2000-01-01 04:36:40-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('piperazine-1,4-diium bromide', '21152417', NULL, NULL, '2000-01-01 04:36:41-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 110);
INSERT INTO "load_hc_inventory" VALUES ('n-dodecylammonium bromide', '26204-55-7', NULL, NULL, '2000-01-01 04:36:42-05', '2019-05-31 20:00:00-04', 'Mansoor', NULL, NULL);
INSERT INTO "load_hc_inventory" VALUES ('dimethylammonium bromide', '1830936', NULL, NULL, '2000-01-01 04:36:43-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 15);
INSERT INTO "load_hc_inventory" VALUES ('neo-pentylammonium bromide', 'missing CAS RN', NULL, NULL, '2000-01-01 04:36:44-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('pyrrolidinium bromide', '55810-80-5', NULL, NULL, '2000-01-01 04:36:45-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('quinuclidinium bromide', '60662-68-2', NULL, NULL, '2000-01-01 04:36:46-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('iso-butylammonium bromide', 'batch#: 569205', NULL, NULL, '2000-01-01 04:36:47-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 110);
INSERT INTO "load_hc_inventory" VALUES ('iso-propylammonium bromide', '29552-58-7', NULL, NULL, '2000-01-01 04:36:48-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 110);
INSERT INTO "load_hc_inventory" VALUES ('n-Dodecylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:49-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('2-Pyrrolidin-1-ium-1-ylethylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:50-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Butane-1,4-diammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:51-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Cyclohexylmethylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:52-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Di-iso-Propylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:53-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Diethylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:54-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('N,N-dimethylpropane-1,3-diammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:55-05', '2019-05-31 20:00:00-04', 'Mansoor', 4, 120);
INSERT INTO "load_hc_inventory" VALUES ('N,N-Dimethylethane- 1,2-diammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:56-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Hexane-1,6-diammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:57-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Morpholinium bromide', NULL, NULL, NULL, '2000-01-01 04:36:58-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 120);
INSERT INTO "load_hc_inventory" VALUES ('4-Trifluoromethyl-Benzylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:36:59-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('4 Methoxy phenylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('4 Trifluromethyl phenyammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 3, 30);
INSERT INTO "load_hc_inventory" VALUES ('2 Methoxyethylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Propane 1,3 diammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('4 Methoxy phenethylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('n-Hexylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 100);
INSERT INTO "load_hc_inventory" VALUES ('n-Octylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 100);
INSERT INTO "load_hc_inventory" VALUES ('N-propylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 100);
INSERT INTO "load_hc_inventory" VALUES ('t-Butylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 100);
INSERT INTO "load_hc_inventory" VALUES ('4-Trifluoromethyl-Phenylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('2 Methoxyethylammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('N,N-Diethylethane- 1,2-diammonium bromide', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Morpholinium Chloride', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Quinclidinium Chloride', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('2-Pyrrolidin-1-ium-1-ylethylammonium chloride', NULL, NULL, NULL, '2000-01-01 04:38:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 2, 20);
INSERT INTO "load_hc_inventory" VALUES ('Indium III Chloride', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('Indium II Chloride', NULL, NULL, NULL, '2000-01-01 04:37:00-05', '2019-05-31 20:00:00-04', 'Mansoor', 1, 10);
INSERT INTO "load_hc_inventory" VALUES ('N,N-Dimethylformamide (/DMF)', '227056-1L', NULL, NULL, '2000-01-01 04:36:41-05', '2019-05-31 20:00:00-04', NULL, 2, 2);
INSERT INTO "load_hc_inventory" VALUES ('GBL', 'B1198-3KG', NULL, NULL, '0001-01-01 00:00:00-04:56:02', '2019-05-31 20:00:00-04', NULL, 500, 1.5);
INSERT INTO "load_hc_inventory" VALUES ('Formic Acid', NULL, NULL, NULL, '0001-01-01 00:00:00-04:56:02', '2019-05-31 20:00:00-04', NULL, 100, NULL);
INSERT INTO "load_hc_inventory" VALUES ('Lead Oxide', '211907-100G', NULL, NULL, '0001-01-01 00:00:00-04:56:02', '2019-05-31 20:00:00-04', NULL, 90, NULL);
INSERT INTO "load_hc_inventory" VALUES ('Cesium iodide', NULL, NULL, NULL, '0001-01-01 00:00:00-04:56:02', '2019-05-31 20:00:00-04', NULL, 10, NULL);
INSERT INTO "load_hc_inventory" VALUES ('Bismuth iodide', NULL, NULL, NULL, '0001-01-01 00:00:00-04:56:02', '2019-05-31 20:00:00-04', NULL, 25, NULL);
INSERT INTO "load_hc_inventory" VALUES ('DMSO', NULL, NULL, NULL, '0001-01-01 00:00:00-04:56:02', '2019-05-31 20:00:00-04', NULL, 1, 1);
COMMIT;
