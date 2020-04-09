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

 Date: 09/04/2020 09:37:01
*/


-- ----------------------------
-- Table structure for load_perov_desc_def
-- ----------------------------
DROP TABLE IF EXISTS "load_perov_desc_def";
CREATE TABLE "load_perov_desc_def" (
  "short_name" varchar(255) COLLATE "pg_catalog"."default",
  "calc_definition" varchar(255) COLLATE "pg_catalog"."default",
  "description" varchar(255) COLLATE "pg_catalog"."default",
  "systemtool_name" varchar(255) COLLATE "pg_catalog"."default",
  "systemtool_ver" varchar(255) COLLATE "pg_catalog"."default",
  "in_calc_source" varchar(255) COLLATE "pg_catalog"."default",
  "in_type" varchar(255) COLLATE "pg_catalog"."default",
  "in_opt_calc_source" varchar(255) COLLATE "pg_catalog"."default",
  "in_opt_type" varchar(255) COLLATE "pg_catalog"."default",
  "out_type" varchar(255) COLLATE "pg_catalog"."default"
)
;


-- ----------------------------
-- Records of load_perov_desc_def
-- ----------------------------
BEGIN;
INSERT INTO "load_perov_desc_def" VALUES ('molweight', 'mass', 'molecule mass calculation', 'cxcalc', '19.27.0', NULL, 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('standardize', '-c removefragment:method=keeplargest', 'smiles standardized', 'standardize', '19.27.0', NULL, 'text', NULL, NULL, 'text');
INSERT INTO "load_perov_desc_def" VALUES ('molimage', 'svg', 'smiles svg image', 'molconvert', '19.27.0', NULL, 'text', NULL, NULL, 'blob_svg');
INSERT INTO "load_perov_desc_def" VALUES ('density', 'density', 'calculate density', 'escalate', '3.0.0', NULL, 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('molweight_standardize', 'mass', 'molecule mass calculation from (standardized) smiles', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('atomcount_n_standardize', 'atomcount -z 7 ', 'number of nitrogen atoms in the molecule ', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('avgpol_standardize', 'avgpol', 'average molecular polarizability calculation', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('molpol_standardize', 'molpol ', 'molecular polarizability calculation', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('refractivity_standardize', 'refractivity ', 'refractivity calculation', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('aliphaticringcount_standardize', 'aliphaticringcount ', 'aliphatic ring count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('aromaticringcount_standardize', 'aromaticringcount ', 'aromatic ring count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('aromaticatomcount_standardize', 'aromaticatomcount', 'aromatic atom count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('bondcount_standardize', 'bondcount', 'bond count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('carboaliphaticringcount_standardize', 'carboaliphaticringcount', 'carboaliphatic ring count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('carboaromaticringcount_standardize', 'carboaromaticringcount', 'carboaromatic ring count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('carboringcount_standardize', 'carboringcount', 'carbo ring count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('chainatomcount_standardize', 'chainatomcount', 'chain atom count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('ringatomcount_standardize', 'ringatomcount', 'ring atom count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('smallestringsize_standardize', 'smallestringsize', 'smallest ring size', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('largestringsize_standardize', 'largestringsize', 'largest ring size', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('heteroaliphaticringcount_standardize', 'heteroaliphaticringcount', 'heteroaliphatic ring count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('rotatablebondcount_standardize', 'rotatablebondcount', 'rotatable bond count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('balabanindex_standardize', 'balabanindex', 'the balaban index', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('cyclomaticnumber_standardize', 'cyclomaticnumber', 'the cyclomatic number', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('hyperwienerindex_standardize', 'hyperwienerindex', 'hyper wiener index', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('wienerindex_standardize', 'wienerindex', 'wiener index', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('wienerpolarity_standardize', 'wienerpolarity ', 'wiener polarity', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('minimalprojectionarea_standardize', 'minimalprojectionarea ', 'calculates the minimal projection area', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('maximalprojectionarea_standardize', 'maximalprojectionarea ', 'calculates the maximal projection area', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('maximalprojectionradius_standardize', 'maximalprojectionradius ', 'calculates the maximal projection radius', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('lengthperpendiculartotheminarea_standardize', 'minimalprojectionsize ', 'calculates the size of the molecule perpendicular to the minimal projection area surface', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('lengthperpendiculartothemaxarea_standardize', 'maximalprojectionsize  ', 'calculates the size of the molecule perpendicular to the maximal projection area surface', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('vanderwaalsvolume_standardize', 'volume ', 'calculates the van der waals volume of the molecule', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('vanderwaalssurfacearea_standardize', 'vdwsa', 'van der waals surface area calculation', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('asa_standardize', 'wateraccessiblesurfacearea asa', 'asa, asa+, asa-, asa_h, asa_p', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('polarsurfacearea_standardize', 'polarsurfacearea ', 'topological polar surface area calculation (2d)', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('acceptorcount_standardize', 'acceptorcount', 'hydrogen bond acceptor atom count in molecule', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('accsitecount_standardize', 'acceptorsitecount', 'hydrogen bond acceptor multiplicity in molecule', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('donorcount_standardize', 'donorcount', 'hydrogen bond donor atom count in molecule', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('donsitecount_standardize', 'donorsitecount', 'hydrogen bond donor multiplicity in molecule', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('maximalprojectionsize_standardize', 'maximalprojectionsize', 'calculates the size of the molecule perpendicular to the maximal projection area surface', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('molsurfaceareavdwp_standardize', 'molecularsurfacearea -t vanderwaals -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('msareavdwp_standardize', 'msa -t vanderwaals -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('molsurfaceareaasap_standardize', 'molecularsurfacearea -t ASA+ -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('msareaasap_standardize', 'msa -t ASA+ -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('protpolarsurfacearea_standardize', 'polarsurfacearea -H 3.0', 'topological polar surface area calculation (2d)', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('protpsa_standardize', 'psa -H 3.0', 'topological polar surface area calculation (2d)', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('hacceptorcount_standardize', 'acceptorcount -H 3.0', 'hydrogen bond acceptor atom count in molecule', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('hdonorcount_standardize', 'donorcount -H 3.0', 'hydrogen bond donor atom count in molecule', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_amidine_standardize', 'fr_amidine', 'number of amidine groups', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_dihydropyridine_standardize', 'fr_dihydropyridine', 'number of dihydropyridines', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_guanido_standardize', 'fr_guanido', 'number of guanidine groups', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_piperdine_standardize', 'fr_piperdine', 'number of piperdine rings', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_piperzine_standardize', 'fr_piperzine', 'number of piperzine rings', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_pyridine_standardize', 'fr_pyridine', 'number of pyridine rings', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('asa-_standardize', 'wateraccessiblesurfacearea asa-', 'asa-', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('asa_h_standardize', 'wateraccessiblesurfacearea asa_h', 'asa_h', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('asa_p_standardize', 'wateraccessiblesurfacearea asa_p', 'asa_p', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('asa+_standardize', 'wateraccessiblesurfacearea asa+', 'asa+', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_nh2_standardize', 'fr_NH2', 'number of secondary amines', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_nh1_standardize', 'fr_NH1', 'number of primary amines', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_nh0_standardize', 'fr_NH0', 'number of tertiary amines', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_quatn_standardize', 'fr_quatN', 'number of quarternary nitrogens', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_arn_standardize', 'fr_ArN', 'number of aromatic nitrogens', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_ar_nh_standardize', 'fr_Ar_NH', 'number of aromatic amines', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('fr_imine_standardize', 'fr_Imine', 'number of imines', 'RDKit', '19.03.4', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('aliphaticatomcount_standardize', 'aliphaticatomcount', 'aliphatic atom count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('ecpf4_256_6_standardize', '-k ECFP -2 -f 256 -n 6', 'chemical fingerprint ecpf', 'generatemd', '19.6.0', 'standardize', 'text', NULL, NULL, 'blob_text');
INSERT INTO "load_perov_desc_def" VALUES ('atomcount_c_standardize', 'atomcount -z 6', 'number of carbon atoms in the molecule ', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('chiralcentercount_standardize', 'chiralcentercount', 'the number of tetrahedral stereogenic center atoms', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('minimalprojectionradius_standardize', 'minimalprojectionradius ', 'calculates the minimal projection radius', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('minimalprojectionsize_standardize', 'minimalprojectionsize', 'calculates the size of the molecule perpendicular to the minimal projection area surface', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('heteroaromaticringcount_standardize', 'heteroaromaticringcount', 'heteroaromatic ring count', 'cxcalc', '19.27.0', 'standardize', 'text', NULL, NULL, 'int');
INSERT INTO "load_perov_desc_def" VALUES ('charge_cnt_standardize', 'get_charge_count', 'number of postive charges (+) in the SMILES string', 'escalate', '3.0.0', 'standardize', 'text', NULL, NULL, 'num');
INSERT INTO "load_perov_desc_def" VALUES ('chrg_per_vol_standardize', 'charge_cnt / vanderwaalsvolume', 'charge count / vanderwaalsvolume', 'escalate', '3.0.0', 'charge_cnt_standardize', 'int', 'vanderwaalsvolume_standardize', 'int', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('chrg_per_asa_standardize', 'charge_cnt / asa-', 'charge_cnt / asa-', 'escalate', '3.0.0', 'charge_cnt_standardize', 'int', 'asa-_standardize', 'int', 'num');
COMMIT;
