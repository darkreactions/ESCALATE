/*
 Navicat Premium Data Transfer

 Source Server         : postgres12
 Source Server Type    : PostgreSQL
 Source Server Version : 110005
 Source Host           : localhost:5432
 Source Catalog        : ESCALATEv3
 Source Schema         : dev

 Target Server Type    : PostgreSQL
 Target Server Version : 110005
 File Encoding         : 65001

 Date: 16/01/2020 16:40:41
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
  "systemtool_ver" varchar(255) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of load_perov_desc_def
-- ----------------------------
BEGIN;
INSERT INTO "load_perov_desc_def" VALUES ('molweight', 'mass', 'molecule mass calculation', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('atomcount_c', 'atomcount -z 6', 'number of carbon atoms in the molecule ', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('atomcount_n', 'atomcount -z 7 ', 'number of nitrogen atoms in the molecule ', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('avgpol', 'avgpol', 'average molecular polarizability calculation', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('molpol', 'molpol ', 'molecular polarizability calculation', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('refractivity', 'refractivity ', 'refractivity calculation', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('aliphaticringcount', 'aliphaticringcount ', 'aliphatic ring count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('aromaticringcount', 'aromaticringcount ', 'aromatic ring count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('aromaticatomcount', 'aromaticatomcount', 'aromatic atom count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('bondcount', 'bondcount', 'bond count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('carboaliphaticringcount', 'carboaliphaticringcount', 'carboaliphatic ring count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('carboaromaticringcount', 'carboaromaticringcount', 'carboaromatic ring count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('carboringcount', 'carboringcount', 'carbo ring count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('chainatomcount', 'chainatomcount', 'chain atom count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('chiralcentercount', 'chiralcentercount', 'the number of tetrahedral stereogenic center atoms', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('ringatomcount', 'ringatomcount', 'ring atom count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('smallestringsize', 'smallestringsize', 'smallest ring size', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('largestringsize', 'largestringsize', 'largest ring size', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('heteroaliphaticringcount', 'heteroaliphaticringcount', 'heteroaliphatic ring count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('rotatablebondcount', 'rotatablebondcount', 'rotatable bond count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('balabanindex', 'balabanindex', 'the balaban index', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('cyclomaticnumber', 'cyclomaticnumber', 'the cyclomatic number', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('hyperwienerindex', 'hyperwienerindex', 'hyper wiener index', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('wienerindex', 'wienerindex', 'wiener index', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('wienerpolarity', 'wienerpolarity ', 'wiener polarity', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('minimalprojectionarea', 'minimalprojectionarea ', 'calculates the minimal projection area', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('maximalprojectionarea', 'maximalprojectionarea ', 'calculates the maximal projection area', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('minimalprojectionradius', 'minimalprojectionradius ', 'calculates the minimal projection radius', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('maximalprojectionradius', 'maximalprojectionradius ', 'calculates the maximal projection radius', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('lengthperpendiculartotheminarea', 'minimalprojectionsize ', 'calculates the size of the molecule perpendicular to the minimal projection area surface', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('lengthperpendiculartothemaxarea', 'maximalprojectionsize  ', 'calculates the size of the molecule perpendicular to the maximal projection area surface', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('vanderwaalsvolume', 'volume ', 'calculates the van der waals volume of the molecule', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('vanderwaalssurfacearea', 'vdwsa', 'van der waals surface area calculation', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('asa', 'wateraccessiblesurfacearea', 'asa, asa+, asa-, asa_h, asa_p', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('polarsurfacearea', 'polarsurfacearea ', 'topological polar surface area calculation (2d)', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('acceptorcount', 'acceptorcount', 'hydrogen bond acceptor atom count in molecule', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('accsitecount', 'acceptorsitecount', 'hydrogen bond acceptor multiplicity in molecule', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('donorcount', 'donorcount', 'hydrogen bond donor atom count in molecule', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('donsitecount', 'donorsitecount', 'hydrogen bond donor multiplicity in molecule', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('maximalprojectionsize', 'maximalprojectionsize', 'calculates the size of the molecule perpendicular to the maximal projection area surface', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('minimalprojectionsize', 'minimalprojectionsize', 'calculates the size of the molecule perpendicular to the minimal projection area surface', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('molsurfaceareavdwp', 'molecularsurfacearea -t vanderwaals -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('msareavdwp', 'msa -t vanderwaals -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('molsurfaceareaasap', 'molecularsurfacearea -t ASA+ -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('msareaasap', 'msa -t ASA+ -H 3.0', 'molecular surface area calculation (3d)', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('protpolarsurfacearea', 'polarsurfacearea -H 3.0', 'topological polar surface area calculation (2d)', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('protpsa', 'psa -H 3.0', 'topological polar surface area calculation (2d)', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('hacceptorcount', 'acceptorcount -H 3.0', 'hydrogen bond acceptor atom count in molecule', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('hdonorcount', 'donorcount -H 3.0', 'hydrogen bond donor atom count in molecule', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('ecpf4_256_6', 'generatemd -k ECFP -2 -f 256 -n 6', 'chemical fingerprint ecpf', 'generatemd', '19.6.0');
INSERT INTO "load_perov_desc_def" VALUES ('fr_amidine', 'fr_amidine', 'number of amidine groups', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_dihydropyridine', 'fr_dihydropyridine', 'number of dihydropyridines', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_guanido', 'fr_guanido', 'number of guanidine groups', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_piperdine', 'fr_piperdine', 'number of piperdine rings', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_piperzine', 'fr_piperzine', 'number of piperzine rings', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_pyridine', 'fr_pyridine', 'number of pyridine rings', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('asa-', 'wateraccessiblesurfacearea asa-', 'asa-', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('asa_h', 'wateraccessiblesurfacearea asa_h', 'asa_h', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('asa_p', 'wateraccessiblesurfacearea asa_p', 'asa_p', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('asa+', 'wateraccessiblesurfacearea asa+', 'asa+', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('fr_nh2', 'fr_NH2', 'number of secondary amines', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_nh1', 'fr_NH1', 'number of primary amines', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_nh0', 'fr_NH0', 'number of tertiary amines', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_quatn', 'fr_quatN', 'number of quarternary nitrogens', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_arn', 'fr_ArN', 'number of aromatic nitrogens', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_ar_nh', 'fr_Ar_NH', 'number of aromatic amines', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('fr_imine', 'fr_Imine', 'number of imines', 'RDKit', '19.03.4');
INSERT INTO "load_perov_desc_def" VALUES ('aliphaticatomcount', 'aliphaticatomcount', 'aliphatic atom count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('heteroaromaticringcount', 'heteroaromaticringcount', 'heteroaromatic ring count', 'cxcalc', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('standardize', '-c removefragment:method=keeplargest', 'smiles standardized', 'standardize', '19.27.0');
INSERT INTO "load_perov_desc_def" VALUES ('molimage', 'svg', 'smiles svg image', 'molconvert', '19.27.0');
COMMIT;
