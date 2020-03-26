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

 Date: 26/03/2020 09:38:12
*/


-- ----------------------------
-- Table structure for load_lbl_inventory
-- ----------------------------
DROP TABLE IF EXISTS "load_lbl_inventory";
CREATE TABLE "load_lbl_inventory" (
  "reagent" varchar(255) COLLATE "pg_catalog"."default" NOT NULL,
  "part_no" varchar(255) COLLATE "pg_catalog"."default",
  "amount" float8,
  "units" varchar(255) COLLATE "pg_catalog"."default",
  "update_date" timestamptz(6) NOT NULL DEFAULT now(),
  "create_date" timestamptz(6) NOT NULL DEFAULT '2019-05-31 20:00:00-04'::timestamp with time zone
)
;


-- ----------------------------
-- Records of load_lbl_inventory
-- ----------------------------
BEGIN;
INSERT INTO "load_lbl_inventory" VALUES ('MeNH3I', '806390-25G (MS101000-100)', 406, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('EtNH3I', '805823-25G', 112.5, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-BuNH3I', '805874-25G', 225, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('PhenEtNH3I', '805904-25G', 395, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('PbI2', '211168-50G', 326, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('GBL', 'B1198-3KG', 3000, 'mL', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Formic Acid', NULL, 100, 'mL', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Formamidinium Iodide', 'MS-150000-100', 200, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Guanidinium Iodide', '806056-25G', 5, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Imidazolium Iodide', 'MS-170000-100', 50, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Acetamidinium Iodide', '805971-25G', 35, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Benzylammonium Iodide', '806196-25G', 45, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('neo-Pentylammonium iodide', 'MS100740-100', 18, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('iso-Propylammonium iodide', 'MS104000-100', 40, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('iso-Butylammonium iodide', 'MS107000-100', 480, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Dimethylammonium iodide', 'MS111100-100 (805831-25G)', 54.2, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Dodecylammonium iodide', 'MS100880-100', 75, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Pyrrolidinium Iodide', 'MS119700-100', 517, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Ethane-1,2-diammonium iodide', NULL, 200, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Cesium iodide', NULL, 100, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Bismuth iodide', NULL, 100, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Lead Bromide', '211141-100G', 80, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('MeNH3Br', 'MS301000-100', 150, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('EtNH3Br', '900868-25G', 80, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Methoxy-Phenylammonium iodide', 'MS100610-100', 69, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('iso-Pentylammonium iodide', 'MS100710-100', 90, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Propylammonium iodide', 'MS103000-100', 27, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Fluoro-Phenylammonium iodide', 'MS100620-100', 140, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('tert-Octylammonium iodide', 'MS100830-100', 74, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Cyclohexylammonium iodide', 'MS100840-100', 66, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Fluoro- Benzylammonium iodide', 'MS100730-100', 76.5, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Hexylammonium iodide', 'MS100860-100', 185, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Trifluoromethyl-Benzylammonium iodide', 'MS100780-100', 64, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Trifluoromethyl-Phenylammonium iodide', 'MS100790-100', 60, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Cyclohexylmethylammonium iodide', 'MS101840-50', 78, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Fluoro-Phenethylammonium iodide', 'MS100720-100', 54, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Propane-1,3-diammonium iodide', 'MS103003-100', 100, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('2-Pyrrolidin-1-ium-1-ylethylammonium iodide', 'MS122972-100', 200, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('5-Azaspiro[4.4]nonan-5-ium iodide', 'MS199700-100', 200, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('1,4-Benzene diammonium iodide', 'MS108005-100', 186.5, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Butane-1,4-diammonium iodide', 'MS104040-100', 200, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('t-Butylammonium iodide', 'MS106000-100', 163, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('1,4-Diazabicyclo[2,2,2]octane-1,4-diium iodide', 'MS129400-100', 200, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Diethylammonium iodide', 'MS112200-100', 179, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('N,N-Dimethylethane- 1,2-diammonium iodide', 'MS122112-100', 200, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('N,N-dimethylpropane- 1,3-diammonium iodide', 'MS123113-100', 200, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('N,N-Diethylpropane-1,3-diammonium iodide', 'MS123223-100', 185.5, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Octylammonium Iodide', 'MS105500-100', 173, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Phenylammonium iodide', 'MS108000-25', 860, 'g', '2019-05-08 20:00:00-04', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Piperidinium iodide', 'MS119800-100', 180, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Pyridinium iodide', 'MS129810-100', 175, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Alanine Hydroiodide', 'need to find a cheaper source', NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Piperazine-1,4-diium iodide', 'MS119500-100', 200, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Pralidoxime iodide', 'need to find a source ', NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Quinuclidin-1-ium iodide', NULL, 20, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Morpholinium Iodide', 'MS110640-100', 159.5, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Methoxy-Phenaethylammonium Iodide', NULL, 50, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Di-isopropylammonium Iodide', NULL, 50, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Proposed Bromides', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('2-Pyrrolidin-1-ium-1-ylethylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Acetamidinium bromide', NULL, 100, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('5-Azaspiro[4.4]nonan-5-ium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('1,4-Benzenediammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Benzylammonium bromide', NULL, 100, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Butane-1,4-diammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('iso-Butylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Butylammonium bromide', NULL, 100, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('t-Butylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Cyclohexylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Cyclohexylmethylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('1,4-Diazabicyclo[2,2,2]octane-1,4-diium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Diethylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Dimethylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('N,N-Dimethylethane- 1,2-diammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('N,N-dimethylpropane-1,3-diammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Dodecylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Ethane-1,2-diammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Ethylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Fluoro-Phenylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Fluoro- Benzylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Fluoro- Phenethylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Formamidinium bromide', NULL, 54, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Guanidinium bromide', NULL, 100, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Hexylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Imidazolium bromide', NULL, 100, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Methoxy-Phenethylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Methoxy-Phenylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Methylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('N,N-Diethylpropane-1,3-diammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Octylammonium Bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('tert-Octylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Pentylammonium Bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('i-Pentylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('neo-Pentylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Phenethylammonium bromide', NULL, 100, 'g', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Phenylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Piperazine-1,4-diium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Piperidinium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Propane-1,3-diammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('iso-Propylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('n-Propylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Pyrrolidinium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('Quinuclidin-1-ium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Trifluoromethyl-Benzylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
INSERT INTO "load_lbl_inventory" VALUES ('4-Trifluoromethyl-Phenylammonium bromide', NULL, NULL, '', '0001-12-31 19:03:58-04:56:02 BC', '2019-05-31 20:00:00-04');
COMMIT;
