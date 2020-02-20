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

 Date: 18/02/2020 16:00:01
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
  "calc_type" varchar(255) COLLATE "pg_catalog"."default"
)
;
ALTER TABLE "load_perov_desc_def" OWNER TO "gcattabriga";

-- ----------------------------
-- Records of load_perov_desc_def
-- ----------------------------
BEGIN;
INSERT INTO "load_perov_desc_def" VALUES ('molweight', '-g mass', 'molecule mass calculation', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('atomcount_n', '-g atomcount -z 7 ', 'number of nitrogen atoms in the molecule ', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('avgpol', '-g avgpol', 'average molecular polarizability calculation', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('molpol', '-g molpol ', 'molecular polarizability calculation', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('refractivity', '-g refractivity ', 'refractivity calculation', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('aliphaticringcount', '-g aliphaticringcount ', 'aliphatic ring count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('aromaticringcount', '-g aromaticringcount ', 'aromatic ring count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('aromaticatomcount', '-g aromaticatomcount', 'aromatic atom count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('bondcount', '-g bondcount', 'bond count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('carboaliphaticringcount', '-g carboaliphaticringcount', 'carboaliphatic ring count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('carboaromaticringcount', '-g carboaromaticringcount', 'carboaromatic ring count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('carboringcount', '-g carboringcount', 'carbo ring count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('chainatomcount', '-g chainatomcount', 'chain atom count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('ringatomcount', '-g ringatomcount', 'ring atom count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('smallestringsize', '-g smallestringsize', 'smallest ring size', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('largestringsize', '-g largestringsize', 'largest ring size', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('heteroaliphaticringcount', '-g heteroaliphaticringcount', 'heteroaliphatic ring count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('rotatablebondcount', '-g rotatablebondcount', 'rotatable bond count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('balabanindex', '-g balabanindex', 'the balaban index', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('cyclomaticnumber', '-g cyclomaticnumber', 'the cyclomatic number', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('hyperwienerindex', '-g hyperwienerindex', 'hyper wiener index', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('wienerindex', '-g wienerindex', 'wiener index', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('wienerpolarity', '-g wienerpolarity ', 'wiener polarity', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('minimalprojectionarea', '-g minimalprojectionarea ', 'calculates the minimal projection area', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('maximalprojectionarea', '-g maximalprojectionarea ', 'calculates the maximal projection area', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('maximalprojectionradius', '-g maximalprojectionradius ', 'calculates the maximal projection radius', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('lengthperpendiculartotheminarea', '-g minimalprojectionsize ', 'calculates the size of the molecule perpendicular to the minimal projection area surface', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('lengthperpendiculartothemaxarea', '-g maximalprojectionsize  ', 'calculates the size of the molecule perpendicular to the maximal projection area surface', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('vanderwaalsvolume', '-g volume ', 'calculates the van der waals volume of the molecule', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('vanderwaalssurfacearea', '-g vdwsa', 'van der waals surface area calculation', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('asa', '-g wateraccessiblesurfacearea', 'asa, asa+, asa-, asa_h, asa_p', 'cxcalc', '19.27.0', 'num_array');
INSERT INTO "load_perov_desc_def" VALUES ('polarsurfacearea', '-g polarsurfacearea ', 'topological polar surface area calculation (2d)', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('acceptorcount', '-g acceptorcount', 'hydrogen bond acceptor atom count in molecule', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('accsitecount', '-g acceptorsitecount', 'hydrogen bond acceptor multiplicity in molecule', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('donorcount', '-g donorcount', 'hydrogen bond donor atom count in molecule', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('donsitecount', '-g donorsitecount', 'hydrogen bond donor multiplicity in molecule', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('maximalprojectionsize', '-g maximalprojectionsize', 'calculates the size of the molecule perpendicular to the maximal projection area surface', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('molsurfaceareavdwp', '-g molecularsurfacearea -t vanderwaals -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('msareavdwp', '-g msa -t vanderwaals -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('molsurfaceareaasap', '-g molecularsurfacearea -t ASA+ -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('msareaasap', '-g msa -t ASA+ -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('protpolarsurfacearea', '-g polarsurfacearea -H 3.0', 'topological polar surface area calculation (2d)', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('protpsa', '-g psa -H 3.0', 'topological polar surface area calculation (2d)', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('hacceptorcount', '-g acceptorcount -H 3.0', 'hydrogen bond acceptor atom count in molecule', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('hdonorcount', '-g donorcount -H 3.0', 'hydrogen bond donor atom count in molecule', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('ecpf4_256_6', '-k ECFP -2 -f 256 -n 6', 'chemical fingerprint ecpf', 'generatemd', '19.6.0', 'blob');
INSERT INTO "load_perov_desc_def" VALUES ('fr_amidine', 'fr_amidine', 'number of amidine groups', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_dihydropyridine', 'fr_dihydropyridine', 'number of dihydropyridines', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_guanido', 'fr_guanido', 'number of guanidine groups', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_piperdine', 'fr_piperdine', 'number of piperdine rings', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_piperzine', 'fr_piperzine', 'number of piperzine rings', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_pyridine', 'fr_pyridine', 'number of pyridine rings', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('asa-', '-g wateraccessiblesurfacearea asa-', 'asa-', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('asa_h', '-g wateraccessiblesurfacearea asa_h', 'asa_h', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('asa_p', '-g wateraccessiblesurfacearea asa_p', 'asa_p', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('asa+', '-g wateraccessiblesurfacearea asa+', 'asa+', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_nh2', 'fr_NH2', 'number of secondary amines', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_nh1', 'fr_NH1', 'number of primary amines', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_nh0', 'fr_NH0', 'number of tertiary amines', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_quatn', 'fr_quatN', 'number of quarternary nitrogens', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_arn', 'fr_ArN', 'number of aromatic nitrogens', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_ar_nh', 'fr_Ar_NH', 'number of aromatic amines', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('fr_imine', 'fr_Imine', 'number of imines', 'RDKit', '19.03.4', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('aliphaticatomcount', '-g aliphaticatomcount', 'aliphatic atom count', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('molimage', '-g svg', 'smiles svg image', 'molconvert', '19.27.0', 'blob');
INSERT INTO "load_perov_desc_def" VALUES ('standardize', '-g -c removefragment:method=keeplargest', 'smiles standardized', 'standardize', '19.27.0', 'text');
INSERT INTO "load_perov_desc_def" VALUES ('atomcount_c', '-g atomcount -z 6', 'number of carbon atoms in the molecule ', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('chiralcentercount', '-g chiralcentercount', 'the number of tetrahedral stereogenic center atoms', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('minimalprojectionradius', '-g minimalprojectionradius ', 'calculates the minimal projection radius', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('minimalprojectionsize', '-g minimalprojectionsize', 'calculates the size of the molecule perpendicular to the minimal projection area surface', 'cxcalc', '19.27.0', 'num');
INSERT INTO "load_perov_desc_def" VALUES ('heteroaromaticringcount', '-g heteroaromaticringcount', 'heteroaromatic ring count', 'cxcalc', '19.27.0', 'num');
COMMIT;
