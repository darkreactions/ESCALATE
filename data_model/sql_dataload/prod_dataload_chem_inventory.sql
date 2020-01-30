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

 Date: 07/01/2020 13:37:03
*/


-- ----------------------------
-- Table structure for load_chem_inventory
-- ----------------------------
DROP TABLE IF EXISTS "load_chem_inventory";
CREATE TABLE "load_chem_inventory" (
  "ChemicalName" varchar(255) COLLATE "pg_catalog"."default",
  "ChemicalAbbreviation" varchar(255) COLLATE "pg_catalog"."default",
  "MolecularWeight" varchar(255) COLLATE "pg_catalog"."default",
  "Density" varchar(255) COLLATE "pg_catalog"."default",
  "InChI" varchar(255) COLLATE "pg_catalog"."default",
  "InChIKey" varchar(255) COLLATE "pg_catalog"."default",
  "ChemicalCategory" varchar(255) COLLATE "pg_catalog"."default",
  "CanonicalSMILES" varchar(255) COLLATE "pg_catalog"."default",
  "MolecularFormula" varchar(255) COLLATE "pg_catalog"."default",
  "PubChemID" varchar(255) COLLATE "pg_catalog"."default",
  "CatalogDescr" varchar(255) COLLATE "pg_catalog"."default",
  "Synonyms" varchar(255) COLLATE "pg_catalog"."default",
  "CatalogNo" varchar(255) COLLATE "pg_catalog"."default",
  "Sigma-Aldrich URL" varchar(255) COLLATE "pg_catalog"."default",
  "PrimaryInformationSource" varchar(255) COLLATE "pg_catalog"."default",
  "StandardizedSMILES" varchar(255) COLLATE "pg_catalog"."default"
)
;

-- ----------------------------
-- Records of load_chem_inventory
-- ----------------------------
BEGIN;
INSERT INTO "load_chem_inventory" VALUES ('Gamma-Butyrolactone', 'GBL', '86.09', '1.12', 'InChI=1S/C4H6O2/c5-4-2-1-3-6-4/h1-3H2', 'YEJRWHAVMIAJKC-UHFFFAOYSA-N', 'solvent', 'C1CC(=O)OC1', 'C4H6O2', NULL, NULL, NULL, 'Spectrum 1Kg bottle', NULL, '(note: there is also a 3Kg bottle version: product ID id:jLq9jXvYvnwz)', 'O=C1CCCO1');
INSERT INTO "load_chem_inventory" VALUES ('Dimethyl sulfoxide', 'DMSO', '78.129', '1.1', 'InChI=1S/C2H6OS/c1-4(2)3/h1-2H3', 'IAZDPXIOMUYVGZ-UHFFFAOYSA-N', 'solvent', 'CS(=O)C', 'C2H6OS', NULL, NULL, NULL, NULL, NULL, NULL, 'CS(C)=O');
INSERT INTO "load_chem_inventory" VALUES ('Formic Acid', 'FAH', '46.025', '1.22', 'InChI=1S/CH2O2/c2-1-3/h1H,(H,2,3)', 'BDAGIHXWWSANSR-UHFFFAOYSA-N', 'acid', 'C(=O)O', 'CH2O2', NULL, 'Formic acid, reagent grade, 1L', NULL, 'Sigma:F0507-1L', NULL, NULL, 'OC=O');
INSERT INTO "load_chem_inventory" VALUES ('Lead Diiodide', 'PbI2', '461.01', '6.16', 'InChI=1S/2HI.Pb/h2*1H;/q;;+2/p-2', 'RQQRAHKHDFPBMC-UHFFFAOYSA-L', 'inorganic', 'I[Pb]I', 'PbI2', NULL, 'Lead(II) iodide 99%, 50g', NULL, 'Sigma:211168-50G', NULL, NULL, 'I[Pb]I');
INSERT INTO "load_chem_inventory" VALUES ('Ethylammonium Iodide', 'EtNH3I', '173', '2.053408', 'InChI=1S/C2H7N.HI/c1-2-3;/h2-3H2,1H3;1H', 'XFYICZOIWSBQSK-UHFFFAOYSA-N', 'organic', 'CC[NH3+].[I-]', 'C2H8IN', '57461411', 'Ethylammonium Iodide 98%, 25g', NULL, 'Sigma:805823-25G', NULL, NULL, 'CC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Methylammonium iodide', 'MeNH3I', '158.97', '2.341498', 'InChI=1S/CH5N.HI/c1-2;/h2H2,1H3;1H', 'LLWRXQXPJMPHLR-UHFFFAOYSA-N', 'organic', 'C[NH3+].[I-]', 'CH6IN', 'SID329769003', 'Methylammonium iodide', 'Methylammonium iodide, Methanamine hydroiodide, Methanaminium', 'Sigma: 806390-25G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/806390?lang=en&region=US', 'PubChem', 'C[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Phenethylammonium iodide ', 'PhEtNH3I', '249.095', '1.630204', 'InChI=1S/C8H11N.HI/c9-7-6-8-4-2-1-3-5-8;/h1-5H,6-7,9H2;1H', 'UPHCENSIMPJEIS-UHFFFAOYSA-N', 'organic', 'C1=CC=C(C=C1)CC[NH3+].[I-]', 'C8H12IN', 'SID329768971', 'Phenethylammonium iodide', NULL, 'Sigma:805904-25G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/805904?lang=en&region=US', NULL, '[NH3+]CCC1=CC=CC=C1');
INSERT INTO "load_chem_inventory" VALUES ('Acetamidinium iodide', 'AcNH3I', '185.96539', '2.176639', 'InChI=1S/C2H6N2.HI/c1-2(3)4;/h1H3,(H3,3,4);1H', 'GGYGJCFIYJVWIP-UHFFFAOYSA-N', 'organic', 'CC(=[NH2+])N.[I-]', 'C2H7IN2', 'SID329768980', NULL, NULL, 'Sigma:805971-25G', NULL, 'PubChem', 'CC(N)=[NH2+]');
INSERT INTO "load_chem_inventory" VALUES ('n-Butylammonium iodide', 'n-BuNH3I', '201.051', '1.686302', 'InChI=1S/C4H11N.HI/c1-2-3-4-5;/h2-5H2,1H3;1H', 'CALQKRVFTWDYDG-UHFFFAOYSA-N', 'organic', 'CCCC[NH3+].[I-]', 'C4H12IN', NULL, NULL, NULL, 'Sigma: 805874-25G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/805874', NULL, 'CCCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Guanidinium iodide', 'GnNH3I', '186.98', '2.359388', 'InChI=1S/CH5N3.HI/c2-1(3)4;/h(H5,2,3,4);1H', 'UUDRLGYROXTISK-UHFFFAOYSA-N', 'organic', 'C(=[NH2+])(N)N.[I-]', 'CH6IN3', NULL, 'Guanidinium iodide 99%', 'iodide", "Methylamine hydriodide", "Monomethylammonium iodide"', 'Sigma:806056-25G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/806056?lang=en&region=US', 'PubChem', 'NC(N)=[NH2+]');
INSERT INTO "load_chem_inventory" VALUES ('Dichloromethane', 'DCM', '84.93', '1.33', 'InChI=1S/CH2Cl2/c2-1-3/h1H2', 'YMWUJEATGCHHMB-UHFFFAOYSA-N', 'solvent', 'C(Cl)Cl', 'CH2Cl2', NULL, NULL, NULL, NULL, NULL, NULL, 'ClCCl');
INSERT INTO "load_chem_inventory" VALUES ('Dimethylammonium iodide', 'Me2NH2I', '172.97014', '2.03749', 'InChI=1S/C2H7N.HI/c1-3-2;/h3H,1-2H3;1H', 'JMXLWMIFDJCGBV-UHFFFAOYSA-N', 'organic', 'C[NH2+]C.[I-]', 'C2H8IN', NULL, NULL, NULL, 'greatcell: MS111100-100', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/12199010', 'C[NH2+]C');
INSERT INTO "load_chem_inventory" VALUES ('Phenylammonium Iodide', 'PhenylammoniumIodide', '221.041', '1.888168', 'InChI=1S/C6H7N.HI/c7-6-4-2-1-3-5-6;/h1-5H,7H2;1H', 'KFQARYBEAKAXIC-UHFFFAOYSA-N', 'organic', 'C1=CC=C(C=C1)[NH3+].[I-]', 'C6H8IN', '6450296', NULL, NULL, NULL, NULL, NULL, '[NH3+]C1=CC=CC=C1');
INSERT INTO "load_chem_inventory" VALUES ('t-Butylammonium Iodide', 'tButylammoniumIodide', '201.00144', '1.681204', 'InChI=1S/C4H11N.HI/c1-4(2,3)5;/h5H2,1-3H3;1H', 'NLJDBTZLVTWXRG-UHFFFAOYSA-N', 'organic', 'CC(C)(C)[NH3+].[I-]', 'C4H12IN', '22344722', NULL, NULL, 'MS106000-10; sigma: 806102-5G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/806102?lang=en&region=US', 'https://pubchem.ncbi.nlm.nih.gov/compound/22344722', 'CC(C)(C)[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('N-propylammonium Iodide', 'NPropylammoniumIodide', '186.98579', '1.843205', 'InChI=1S/C3H9N.HI/c1-2-3-4;/h2-4H2,1H3;1H', 'GIAPQOZCVIEHNY-UHFFFAOYSA-N', 'organic', '[I-].[NH3+]CCC', 'C3H10IN', NULL, NULL, NULL, NULL, NULL, NULL, 'CCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Formamidinium Iodide', 'FormamidiniumIodide', '171.97', '2.423927', 'InChI=1S/CH4N2.HI/c2-1-3;/h1H,(H3,2,3);1H', 'QHJPGANWSLEMTI-UHFFFAOYSA-N', 'organic', 'C(=N)[NH3+].[I-]', 'CH5IN2', NULL, NULL, NULL, 'greatcell: MS-150000-100', 'https://www.sigmaaldrich.com/catalog/product/aldrich/806048?lang=en&region=US', 'PubChem', '[NH3+]C=N');
INSERT INTO "load_chem_inventory" VALUES ('1,4-Diazabicyclo[2,2,2]octane-1,4-diium Iodide', 'Dabcoiodide', '368', '2.1888', 'InChI=1S/C6H12N2.2HI/c1-2-8-5-3-7(1)4-6-8;;/h1-6H2;2*1H', 'WXTNTIQDYHIFEG-UHFFFAOYSA-N', 'organic', 'C1C[NH+]2CC[NH+]1CC2.[I-].[I-]', 'C6H14I2N2', '129880796', NULL, NULL, NULL, NULL, NULL, 'C1C[NH+]2CC[NH+]1CC2');
INSERT INTO "load_chem_inventory" VALUES ('4-Fluoro-Benzylammonium iodide', '4FluoroBenzylammoniumIodide', '253.058', '1.864177', 'InChI=1S/C7H8FN.HI/c8-7-3-1-6(5-9)2-4-7;/h1-4H,5,9H2;1H', 'LCTUISCIGMWMAT-UHFFFAOYSA-N', 'organic', 'C1(=CC=C(C=C1)F)C[NH3+].[I-]', 'C7H9FIN', NULL, NULL, NULL, NULL, NULL, NULL, '[NH3+]CC1=CC=C(F)C=C1');
INSERT INTO "load_chem_inventory" VALUES ('4-Fluoro-Phenethylammonium iodide', '4FluoroPhenethylammoniumIodide', '266.99202', '1.740239', 'InChI=1S/C8H10FN.HI/c9-8-3-1-7(2-4-8)5-6-10;/h1-4H,5-6,10H2;1H', 'NOHLSFNWSBZSBW-UHFFFAOYSA-N', 'organic', 'C1(=CC=C(C=C1)F)CC[NH3+].[I-]', 'C8H11FIN', NULL, NULL, NULL, NULL, NULL, NULL, '[NH3+]CCC1=CC=C(F)C=C1');
INSERT INTO "load_chem_inventory" VALUES ('4-Fluoro-Phenylammonium iodide', '4FluoroPhenylammoniumIodide', '239.031', '2.014867', 'InChI=1S/C6H6FN.HI/c7-5-1-3-6(8)4-2-5;/h1-4H,8H2;1H', 'FJFIJIDZQADKEE-UHFFFAOYSA-N', 'organic', 'C1(=CC=C(C=C1)F)[NH3+].[I-]', 'C6H7FIN', NULL, NULL, NULL, NULL, NULL, NULL, '[NH3+]C1=CC=C(F)C=C1');
INSERT INTO "load_chem_inventory" VALUES ('4-Methoxy-Phenylammonium iodide', '4MethoxyPhenylammoniumIodide', '251.067', '1.771191', 'InChI=1S/C7H9NO.HI/c1-9-7-4-2-6(8)3-5-7;/h2-5H,8H2,1H3;1H', 'QRFXELVDJSDWHX-UHFFFAOYSA-N', 'organic', 'C1(=CC=C(C=C1)OC)[NH3+].[I-]', 'C7H10INO', NULL, NULL, NULL, NULL, NULL, NULL, 'COC1=CC=C([NH3+])C=C1');
INSERT INTO "load_chem_inventory" VALUES ('4-Trifluoromethyl-Benzylammonium iodide', '4TrifluoromethylBenzylammoniumIodide', '303.065', '1.938294', 'InChI=1S/C8H8F3N.HI/c9-8(10,11)7-3-1-6(5-12)2-4-7;/h1-4H,5,12H2;1H', 'SQXJHWOXNLTOOO-UHFFFAOYSA-N', 'organic', 'C1(=CC=C(C=C1)C(F)(F)F)C[NH3+].[I-]', 'C8H9F3IN', NULL, NULL, NULL, NULL, NULL, NULL, '[NH3+]CC1=CC=C(C=C1)C(F)(F)F');
INSERT INTO "load_chem_inventory" VALUES ('4-Trifluoromethyl-Phenylammonium iodide', '4TrifluoromethylPhenylammoniumIodide', '289.039', '2.074383', 'InChI=1S/C7H6F3N.HI/c8-7(9,10)5-1-3-6(11)4-2-5;/h1-4H,11H2;1H', 'KOAGKPNEVYEZDU-UHFFFAOYSA-N', 'organic', 'C1(=CC=C(C=C1)C(F)(F)F)[NH3+].[I-]', 'C7H7F3IN', NULL, NULL, NULL, NULL, NULL, NULL, '[NH3+]C1=CC=C(C=C1)C(F)(F)F');
INSERT INTO "load_chem_inventory" VALUES ('chlorobenzene', 'CBz', '112.56', '1.11', 'InChI=1S/C6H5Cl/c7-6-4-2-1-3-5-6/h1-5H', 'MVPPADPHJFYWMZ-UHFFFAOYSA-N', 'solvent', 'C1=CC=C(C=C1)Cl', 'C6H5Cl', NULL, NULL, NULL, NULL, NULL, NULL, 'ClC1=CC=CC=C1');
INSERT INTO "load_chem_inventory" VALUES ('Acetamidinium bromide', 'AcNH3Br', '138.99', '1.819847', 'InChI=1S/C2H6N2.BrH/c1-2(3)4;/h1H3,(H3,3,4);1H', 'CWJKVUQGXKYWTR-UHFFFAOYSA-N', 'organic', 'CC(=[NH2+])N.[Br-]', 'C2H7BrN2', '44255193', NULL, NULL, NULL, NULL, NULL, 'CC(N)=[NH2+]');
INSERT INTO "load_chem_inventory" VALUES ('Benzylammonium Bromide', 'benzylammoniumbromide', '188.07', '1.530173', 'InChI=1S/C7H9N.BrH/c8-6-7-4-2-1-3-5-7;/h1-5H,6,8H2;1H', 'QJFMCHRSDOLMHA-UHFFFAOYSA-N', 'organic', 'C1=CC=C(C=C1)C[NH3+].[Br-]', 'C7H10BrN', '12998568', NULL, NULL, 'Sigma: 900885-5G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/900885?lang=en&region=US', 'https://pubchem.ncbi.nlm.nih.gov/compound/12998568', '[NH3+]CC1=CC=CC=C1');
INSERT INTO "load_chem_inventory" VALUES ('Benzylammonium Iodide', 'BenzylammoniumIodide', '235.068', '1.745993', 'InChI=1S/C7H9N.HI/c8-6-7-4-2-1-3-5-7;/h1-5H,6,8H2;1H', 'PPCHYMCMRUGLHR-UHFFFAOYSA-N', 'organic', 'C1=CC=C(C=C1)C[NH3+].[I-]', 'C7H10IN', NULL, 'Benzylammonium Iodide', NULL, 'Sigma: 806196-25G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/806196?lang=en&region=US', 'PubChem', '[NH3+]CC1=CC=CC=C1');
INSERT INTO "load_chem_inventory" VALUES ('Beta Alanine Hydroiodide', 'betaAlanineHydroiodide', '217.01', '2.023364', 'InChI=1S/C3H7NO2.HI/c4-2-1-3(5)6;/h1-2,4H2,(H,5,6);1H', 'XAKAQFUGWUAPJN-UHFFFAOYSA-N', 'organic', '[I-].[NH3+]CCC(O)=O', NULL, NULL, NULL, NULL, NULL, NULL, 'https://cactus.nci.nih.gov/chemical/structure/I.NCCC(O)=O/stdinchikey', '[NH3+]CCC(O)=O');
INSERT INTO "load_chem_inventory" VALUES ('Bismuth iodide', 'BiI3', '589.694', '5.78', 'InChI=1S/Bi.3HI/h;3*1H/q+3;;;/p-3', 'KOECRLKKXSXCPB-UHFFFAOYSA-K', 'inorganic', 'I[Bi](I)I', 'BiI3', NULL, NULL, NULL, 'Sigma: 341010-100G', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/Bismuth_iodide#section=3D-Status', 'I[Bi](I)I');
INSERT INTO "load_chem_inventory" VALUES ('Cesium iodide', 'CsI', '259.81', '4.51', 'InChI=1S/Cs.HI/h;1H/q+1;/p-1', 'XQPRBTXUXXVTKB-UHFFFAOYSA-M', 'inorganic', '[I-].[Cs+]', 'CsI', NULL, NULL, NULL, 'Sigma: 203033-10G', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/24601', '[I-]');
INSERT INTO "load_chem_inventory" VALUES ('Dimethylformamide', 'DMF', '73.095', '0.944', 'InChI=1S/C3H7NO/c1-4(2)3-5/h3H,1-2H3', 'ZMXDDKWLCZADIW-UHFFFAOYSA-N', 'solvent', 'CN(C)C=O', 'C3H7NO', NULL, 'Anhydrous DMF.  Note.  ECL maintains this as a stocked item, so we do not have to both with a product number', NULL, NULL, NULL, NULL, 'CN(C)C=O');
INSERT INTO "load_chem_inventory" VALUES ('Ethane-1,2-diammonium bromide', 'EthylenediamineDihydrobromide', '221.92', '2.067161', 'InChI=1S/C2H8N2.2BrH/c3-1-2-4;;/h1-4H2;2*1H', 'BCQZYUOYVLJOPE-UHFFFAOYSA-N', 'organic', 'C(C[NH3+])[NH3+].[Br-].[Br-]', 'C2H10Br2N2', '164699', NULL, NULL, 'greatcell: MS302002-10; sigma: 900833-25G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/900833?lang=en&region=US', 'https://pubchem.ncbi.nlm.nih.gov/compound/Ethylenediamine-dihydrobromide', '[NH3+]CC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Ethane-1,2-diammonium iodide', 'EthylenediamineDihydriodide', '315.925', '2.544818', 'InChI=1S/C2H8N2.2HI/c3-1-2-4;;/h1-4H2;2*1H', 'IWNWLPUNKAYUAW-UHFFFAOYSA-N', 'organic', 'C(C[NH3+])[NH3+].[I-].[I-]', 'C2H10I2N2', NULL, NULL, NULL, 'Sigma: 900852-25G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/900852?lang=en&region=US', 'https://pubchem.ncbi.nlm.nih.gov/compound/5700-49-2#section=Names-and-Identifiers', '[NH3+]CC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Ethylammonium bromide', 'EtNH3Br', '125.997', '1.671914', 'InChI=1S/C2H7N.BrH/c1-2-3;/h2-3H2,1H3;1H', 'PNZDZRMOBIIQTC-UHFFFAOYSA-N', 'organic', 'CC[NH3+].[Br-]', 'C2H8BrN', NULL, NULL, NULL, 'Sigma: 900868-10G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/900868?lang=en&region=US', 'https://pubchem.ncbi.nlm.nih.gov/compound/68974', 'CC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Formamidinium bromide', 'FABr', '124.97', '2.005249', 'InChI=1S/CH4N2.BrH/c2-1-3;/h1H,(H3,2,3);1H', 'QWANGZFTSGZRPZ-UHFFFAOYSA-N', 'organic', 'C(=[NH2+])N.[Br-]', 'CH5BrN2', '89907631', NULL, NULL, 'Sigma: 900835-25G; GreatCellSolar: CAS RN: 146958-06-7', 'https://www.sigmaaldrich.com/catalog/product/aldrich/900835?lang=en&region=US', NULL, 'NC=[NH2+]');
INSERT INTO "load_chem_inventory" VALUES ('Guanidinium bromide', 'GnNH3Br', '139.984', '1.999305', 'InChI=1S/CH5N3.BrH/c2-1(3)4;/h(H5,2,3,4);1H', 'VQNVZLDDLJBKNS-UHFFFAOYSA-N', 'organic', 'C(=[NH2+])(N)N.[Br-]', 'CH6BrN3', '129656112', NULL, NULL, 'Sigma: 900839-10G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/900839?lang=en&region=US', 'https://pubchem.ncbi.nlm.nih.gov/compound/71282', 'NC(N)=[NH2+]');
INSERT INTO "load_chem_inventory" VALUES ('i-Propylammonium iodide', 'iPropylammoniumIodide', '187.02', '1.841935', 'InChI=1S/C3H9N.HI/c1-3(2)4;/h3H,4H2,1-2H3;1H', 'VMLAEGAAHIIWJX-UHFFFAOYSA-N', 'organic', 'CC(C)[NH3+].[I-]', 'C3H10IN', NULL, NULL, NULL, 'greatcell: MS104000-100', 'https://www.sigmaaldrich.com/catalog/product/aldrich/805882?lang=en&region=US', 'https://pubchem.ncbi.nlm.nih.gov/compound/91972165#section=Top', 'CC(C)[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Imidazolium Iodide', 'ImidazoliumIodide', '195.991', '2.34327', 'InChI=1S/C3H4N2.HI/c1-2-5-3-4-1;/h1-3H,(H,4,5);1H', 'JBOIAZWJIACNJF-UHFFFAOYSA-N', 'organic', 'C1=CN=C[NH2+]1.[I-]', 'C3H5IN2', NULL, NULL, NULL, 'greatcell: MS-170000-100', NULL, 'PubChem', '[NH2+]1C=CN=C1');
INSERT INTO "load_chem_inventory" VALUES ('iso-Butylammonium bromide', 'iButylammoniumBromide', '154.05', '1.414965', 'InChI=1S/C4H11N.BrH/c1-4(2)3-5;/h4H,3,5H2,1-2H3;1H', 'RFYSBVUZWGEPBE-UHFFFAOYSA-N', 'organic', 'CC(C)C[NH3+].[Br-]', 'C4H12BrN', '89264112', NULL, NULL, 'greatcell: MS307000-10; sigma: 900869-10G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/900869?lang=en&region=US', 'https://pubchem.ncbi.nlm.nih.gov/compound/89264112', 'CC(C)C[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('iso-Butylammonium iodide', 'iButylammoniumIodide', '201.05', '1.682582', 'InChI=1S/C4H11N.HI/c1-4(2)3-5;/h4H,3,5H2,1-2H3;1H', 'FCTHQYIDLRRROX-UHFFFAOYSA-N', 'organic', '[I-].CC(C)C[NH3+]', 'C4H12IN', NULL, NULL, NULL, 'greatcell: MS107000-100', NULL, 'https://cactus.nci.nih.gov/chemical/structure', 'CC(C)C[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('iso-Pentylammonium iodide', 'IPentylammoniumIodide', '215.01709', '1.55959', 'InChI=1S/C5H13N.HI/c1-5(2)3-4-6;/h5H,3-4,6H2,1-2H3;1H', 'UZHWWTHDRVLCJU-UHFFFAOYSA-N', 'organic', 'CC(CC[NH3+])C.[I-]', 'C5H14IN', NULL, NULL, NULL, NULL, NULL, NULL, 'CC(C)CC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Lead(II) acetate trihydrate', 'LeadAcetate', '379.33', '2.55', 'InChI=1S/2C2H4O2.3H2O.Pb/c2*1-2(3)4;;;;/h2*1H3,(H,3,4);3*1H2;/q;;;;;+2/p-2', 'MCEUZMYFCCOOQO-UHFFFAOYSA-L', 'inorganic', 'CC(=O)O[Pb]OC(=O)C.O.O.O', 'C4H12O7Pb', '16693916', NULL, NULL, 'Sigma: 467863-50G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/467863?lang=en&\region=US', NULL, 'CC(=O)O[Pb]OC(C)=O');
INSERT INTO "load_chem_inventory" VALUES ('Lead(II) bromide', 'PbBr2', '367.008', '6.66', 'InChI=1S/2BrH.Pb/h2*1H;/q;;+2/p-2', 'ZASWJUOMEGBQCQ-UHFFFAOYSA-L', 'inorganic', 'Br[Pb]Br', 'PbBr2', NULL, 'Object[Product,id:7X104vn698bk]', NULL, 'Sigma: 211141-100G', NULL, 'https://www.sigmaaldrich.com/catalog/product/aldrich/211141?lang=en&\region=US', 'Br[Pb]Br');
INSERT INTO "load_chem_inventory" VALUES ('Methylammonium bromide', 'Methylammoniumbromide', '111.97', '1.883462', 'InChI=1S/CH5N.BrH/c1-2;/h2H2,1H3;1H', 'ISWNAMNOYHCTSB-UHFFFAOYSA-N', 'organic', 'C[NH3+].[Br-]', 'CH6BrN', NULL, 'Methylammonium bromide', NULL, 'Sigma: 806498-25G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/806498?lang=en&region=US', NULL, 'C[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Morpholinium Iodide', 'MorpholiniumIodide', '215.03', '1.896504', 'InChI=1S/C4H9NO.HI/c1-3-6-4-2-5-1;/h5H,1-4H2;1H', 'VAWHFUNJDMQUSB-UHFFFAOYSA-N', 'organic', 'C1COCC[NH2+]1.[I-]', 'C4H10INO', '12196071', NULL, NULL, 'MS110640-10', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/Morpholinium-iodide', 'C1COCC[NH2+]1');
INSERT INTO "load_chem_inventory" VALUES ('n-Dodecylammonium bromide', 'nDodecylammoniumBromide', '266.26', '1.064263', 'InChI=1S/C12H27N.BrH/c1-2-3-4-5-6-7-8-9-10-11-12-13;/h2-13H2,1H3;1H', 'VZXFEELLBDNLAL-UHFFFAOYSA-N', 'organic', 'CCCCCCCCCCCC[NH3+].[Br-]', 'C12H28BrN', '21872287', NULL, NULL, 'greatcell: MS300880', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/21872287#section=InChI', 'CCCCCCCCCCCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('n-Dodecylammonium iodide', 'nDodecylammoniumIodide', '313.26', '1.128466', 'InChI=1S/C12H27N.HI/c1-2-3-4-5-6-7-8-9-10-11-12-13;/h2-13H2,1H3;1H', 'PXWSKGXEHZHFJA-UHFFFAOYSA-N', 'organic', '[I-].CCCCCCCCCCCC[NH3+]', 'C12H28IN', NULL, NULL, NULL, 'greatcell: MS100880-100', NULL, 'https://cactus.nci.nih.gov/chemical/structure', 'CCCCCCCCCCCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('n-Hexylammonium iodide', 'nHexylammoniumIodide', '229.105', '1.464001', 'InChI=1S/C6H15N.HI/c1-2-3-4-5-6-7;/h2-7H2,1H3;1H', 'VNAAUNTYIONOHR-UHFFFAOYSA-N', 'organic', 'CCCCCC[NH3+].[I-]', 'C6H16IN', NULL, NULL, NULL, NULL, NULL, NULL, 'CCCCCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('n-Octylammonium Iodide', 'nOctylammoniumIodide', '257.16', '1.31499', 'InChI=1S/C8H19N.HI/c1-2-3-4-5-6-7-8-9;/h2-9H2,1H3;1H', 'HBZSVMFYMAOGRS-UHFFFAOYSA-N', 'organic', 'CCCCCCCC[NH3+].[I-]', 'C8H20IN', '22461615', NULL, 'Octyalazanium', 'MS105500-10', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/22461615', 'CCCCCCCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('neo-Pentylammonium bromide', 'neoPentylammoniumBromide', '168.08', '1.330429', 'InChI=1S/C5H13N.BrH/c1-5(2,3)4-6;/h4,6H2,1-3H3;1H', 'FEUPHURYMJEUIH-UHFFFAOYSA-N', 'organic', 'CC(C)(C)C[NH3+].[Br-]', 'C5H14BrN', '87350950', NULL, '2,2-Dimethylpropylazanium;bromide', 'greatcell: MS300740-10', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/87350950', 'CC(C)(C)C[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('neo-Pentylammonium iodide', 'neoPentylammoniumIodide', '215.01709', '1.555659', 'InChI=1S/C5H13N.HI/c1-5(2,3)4-6;/h4,6H2,1-3H3;1H', 'CQWGDVVCKBJLNX-UHFFFAOYSA-N', 'organic', '[I-].CC(C)(C)C[NH3+]', 'C5H14IN', NULL, NULL, NULL, 'greatcell: MS100740-100', NULL, 'https://cactus.nci.nih.gov/chemical/structure', 'CC(C)(C)C[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Phenethylammonium bromide', 'Phenethylammoniumbromide', '202.09', '1.446421', 'InChI=1S/C8H11N.BrH/c9-7-6-8-4-2-1-3-5-8;/h1-5H,6-7,9H2;1H', 'IRAGENYJMTVCCV-UHFFFAOYSA-N', 'organic', 'c1ccc(cc1)CC[NH3+].[Br-]', 'C8H12BrN', '70441016', NULL, NULL, 'Sigma: 900829-10G', 'https://www.sigmaaldrich.com/catalog/product/aldrich/900829?lang=en&region=US', 'https://pubchem.ncbi.nlm.nih.gov/compound/70441016', '[NH3+]CCc1ccccc1');
INSERT INTO "load_chem_inventory" VALUES ('piperazine dihydrobromide', 'PiperazinediiumDiBromide', '247.96', '1.936635', 'InChI=1S/C4H10N2.2BrH/c1-2-6-4-3-5-1;;/h5-6H,1-4H2;2*1H', 'UXWKNNJFYZFNDI-UHFFFAOYSA-N', 'organic', 'C1C[NH2+]CC[NH2+]1.[Br-].[Br-]', 'C4H12Br2N2', NULL, NULL, NULL, 'greatcell: MS319500', NULL, NULL, 'C1C[NH2+]CC[NH2+]1');
INSERT INTO "load_chem_inventory" VALUES ('Piperazine-1,4-diium iodide', 'PiperazinediiumDiodide', '341.96', '2.352982', 'InChI=1S/C4H10N2.2HI/c1-2-6-4-3-5-1;;/h5-6H,1-4H2;2*1H', 'QZCGFUVVXNFSLE-UHFFFAOYSA-N', 'organic', '[I-].[I-].C1C[NH2+]CC[NH2+]1', NULL, NULL, NULL, NULL, NULL, NULL, 'https://cactus.nci.nih.gov/chemical/structure/%5BI-%5D.%5BI-%5D.C1C%5BNH2+%5DCC%5BNH2+%5D1/stdinchikey', 'C1C[NH2+]CC[NH2+]1');
INSERT INTO "load_chem_inventory" VALUES ('Piperidinium Iodide', 'PiperidiniumIodide', '213.06', '1.720983', 'InChI=1S/C5H11N.HI/c1-2-4-6-5-3-1;/h6H,1-5H2;1H', 'HBPSMMXRESDUSG-UHFFFAOYSA-N', 'organic', 'C1CC[NH2+]CC1.[I-]', 'C5H12IN', '15533240', NULL, NULL, 'MS119800-10', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/15533240', 'C1CC[NH2+]CC1');
INSERT INTO "load_chem_inventory" VALUES ('Poly(vinyl alcohol), Mw89000-98000, >99% hydrolyzed)', 'PVA', '92000', '1234.56', '1S/C2H4O/c1-2-3/h2-3H,1H2', 'IMROMDMJAWUWLK-UHFFFAOYSA-N', 'polymer', 'C{-}(OC(=O)C)C{n+}', 'C2H4O', NULL, NULL, NULL, 'Sigma: 341584-25G', 'https://www.sigmaaldrich.com/catalog/product/ALDRICH/341584?lang=en&\region=US&cm_sp=Insite-_-prodRecCold_xviews-_-prodRecCold5-3', NULL, 'C');
INSERT INTO "load_chem_inventory" VALUES ('Pralidoxime iodide', 'PralidoximeIodide', '264.066', '1.850877', 'InChI=1S/C7H8N2O.HI/c1-9-5-3-2-4-7(9)6-8-10;/h2-6H,1H3;1H/b7-6+;', 'QNBVYCDYFJUNLO-UHDJGPCESA-N', 'organic', 'CN1C=CC=CC1=C[NH+]=O.[I-]', 'C7H9IN2O', NULL, NULL, NULL, NULL, NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/pralidoxime_iodide#section=Names-and-Identifiers', 'CN1C=CC=CC1=C[NH+]=O');
INSERT INTO "load_chem_inventory" VALUES ('Propane-1,3-diammonium iodide', 'Propane13diammoniumIodide', '329.95', '2.10244', 'InChI=1S/C3H10N2.HI/c4-2-1-3-5;/h1-5H2;1H/p+1', 'UMDDLGMCNFAZDX-UHFFFAOYSA-O', 'organic', '[NH3+]CCC[NH3+].[I-].[I-]', 'C3H12IN2', NULL, NULL, NULL, NULL, NULL, NULL, '[NH3+]CCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Pyrrolidinium Bromide', 'pyrrolidiniumBromide', '152.03', '1.587983', 'InChI=1S/C4H9N.BrH/c1-2-4-5-3-1;/h5H,1-4H2;1H', 'VFDOIPKMSSDMCV-UHFFFAOYSA-N', 'organic', 'C1CC[NH2+]C1.[Br-]', 'C4H10BrN', '18621471', NULL, NULL, 'greatcell: MS319700-10', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/18621471', 'C1CC[NH2+]C1');
INSERT INTO "load_chem_inventory" VALUES ('Pyrrolidinium Iodide', 'PyrrolidiniumIodide', '199.035', '1.88354', 'InChI=1S/C4H9N.HI/c1-2-4-5-3-1;/h5H,1-4H2;1H', 'DMFMZFFIQRMJQZ-UHFFFAOYSA-N', 'organic', 'C1CC[NH2+]C1.[I-]', 'C4H10IN', NULL, NULL, NULL, 'greatcell: MS119700-100', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/11159941', 'C1CC[NH2+]C1');
INSERT INTO "load_chem_inventory" VALUES ('Quinuclidin-1-ium bromide', 'QuinuclidiniumBromide', '192.1', '1.422151', 'InChI=1S/C7H13N.BrH/c1-4-8-5-2-7(1)3-6-8;/h7H,1-6H2;1H', 'DYEHDACATJUKSZ-UHFFFAOYSA-N', 'organic', 'C1C[NH+]2CCC1CC2.[Br-]', 'C7H14BrN', '66608461', NULL, '1-Azoniabicyclo[2.2.2]octane;bromide', 'greatcell: MS329300', NULL, 'https://pubchem.ncbi.nlm.nih.gov/compound/66608461', 'C1C[NH+]2CCC1CC2');
INSERT INTO "load_chem_inventory" VALUES ('Quinuclidin-1-ium iodide', 'QuinuclidiniumIodide', '239.1', '1.617795', 'InChI=1S/C7H13N.HI/c1-4-8-5-2-7(1)3-6-8;/h7H,1-6H2;1H', 'LYHPZBKXSHVBDW-UHFFFAOYSA-N', 'organic', 'C1C[NH+]2CCC1CC2.[I-]', NULL, NULL, NULL, NULL, NULL, NULL, 'https://cactus.nci.nih.gov/chemical/structure/%5BI-%5D.C1C%5BNH+%5D2CCC1CC2/stdinchikey', 'C1C[NH+]2CCC1CC2');
INSERT INTO "load_chem_inventory" VALUES ('tert-Octylammonium iodide', 'TertOctylammoniumIodide', '257.157', '1.304114', 'InChI=1S/C8H19N.HI/c1-7(2,3)6-8(4,5)9;/h6,9H2,1-5H3;1H', 'UXYJHTKQEFCXBJ-UHFFFAOYSA-N', 'organic', 'C(CC(C)(C)[NH3+])(C)(C)C.[I-]', 'C8H20IN', NULL, NULL, NULL, NULL, NULL, NULL, 'CC(C)(C)CC(C)(C)[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Pyridinium Iodide', 'PyridiniumIodide', '207.01', '2.051533', 'InChI=1S/C5H5N.HI/c1-2-4-6-5-3-1;/h1-5H;1H', 'BJDYCCHRZIFCGN-UHFFFAOYSA-N', 'organic', 'C1=CC=[NH+]C=C1.[I-]', 'C5H6IN', '6432201', NULL, NULL, NULL, NULL, NULL, 'C1=CC=[NH+]C=C1');
INSERT INTO "load_chem_inventory" VALUES ('Cyclohexylmethylammonium iodide', 'CyclohexylmethylammoniumIodide', '241.11', '1.505014', 'InChI=1S/C7H15N.HI/c1-8-7-5-3-2-4-6-7;/h7-8H,2-6H2,1H3;1H', 'ZEVRFFCPALTVDN-UHFFFAOYSA-N', 'organic', 'C1CCC(CC1)C[NH3+].[I-]', 'C7H16IN', '129790872', NULL, NULL, NULL, NULL, NULL, '[NH3+]CC1CCCCC1');
INSERT INTO "load_chem_inventory" VALUES ('Cyclohexylammonium iodide', 'CyclohexylammoniumIodide', '227.09', '1.605951', 'InChI=1S/C6H13N.HI/c7-6-4-2-1-3-5-6;/h6H,1-5,7H2;1H', 'WGYRINYTHSORGH-UHFFFAOYSA-N', 'organic', 'C1CCC(CC1)[NH3+].[I-]', 'C6H14IN', '89524541', NULL, NULL, NULL, NULL, NULL, '[NH3+]C1CCCCC1');
INSERT INTO "load_chem_inventory" VALUES ('Butane-1,4-diammonium Iodide', 'Butane14diammoniumIodide', '343.98', '2.203123', 'InChI=1S/C4H12N2.2HI/c5-3-1-2-4-6;;/h1-6H2;2*1H', 'XZUCBFLUEBDNSJ-UHFFFAOYSA-N', 'organic', 'C(CC[NH3+])C[NH3+].[I-].[I-]', 'C4H14I2N2', NULL, NULL, NULL, NULL, NULL, NULL, '[NH3+]CCCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('1,4-Benzene diammonium iodide', 'Benzenediaminedihydroiodide', '363.97', '2.340659', 'nChI=1S/C6H8N2.2HI/c7-5-1-2-6(8)4-3-5;;/h1-4H,7-8H2;2*1H', 'RYYSZNVPBLKLRS-UHFFFAOYSA-N', 'organic', 'C1=CC(=CC=C1[NH3+])[NH3+].[I-].[I-]', 'C6H10I2N2', '129655325', NULL, NULL, NULL, NULL, NULL, '[NH3+]C1=CC=C([NH3+])C=C1');
INSERT INTO "load_chem_inventory" VALUES ('5-Azaspiro[4.4]nonan-5-ium iodide', '5Azaspironoiodide', '253.12', '1.527018', 'InChI=1S/C8H16N.HI/c1-2-6-9(5-1)7-3-4-8-9;/h1-8H2;1H/q+1;/p-1', 'DWOWCUCDJIERQX-UHFFFAOYSA-M', 'organic', 'C1CC[N+]2(C1)CCCC2.[I-]', 'C8H16IN', '86209376', NULL, NULL, NULL, NULL, NULL, 'C1CC[N+]2(C1)CCCC2');
INSERT INTO "load_chem_inventory" VALUES ('Diethylammonium iodide', 'Diethylammoniumiodide', '201.05', '1.676932', 'InChI=1S/C4H11N.HI/c1-3-5-4-2;/h5H,3-4H2,1-2H3;1H', 'YYMLRIWBISZOMT-UHFFFAOYSA-N', 'organic', 'CC[NH2+]CC.[I-]', 'C4H12IN', '88320434', NULL, NULL, NULL, NULL, NULL, 'CC[NH2+]CC');
INSERT INTO "load_chem_inventory" VALUES ('2-Pyrrolidin-1-ium-1-ylethylammonium iodide', '2Pyrrolidin1ium1ylethylammoniumiodide', '370.017', '2.078859', 'InChI=1S/C6H14N2.2HI/c7-3-6-8-4-1-2-5-8;;/h1-7H2;2*1H', 'UVLZLKCGKYLKOR-UHFFFAOYSA-N', 'organic', 'C1CC[NH+](C1)CC[NH3+].[I-].[I-]', 'C6H16I2N2', NULL, NULL, NULL, NULL, NULL, NULL, '[NH3+]CC[NH+]1CCCC1');
INSERT INTO "load_chem_inventory" VALUES ('N,N-Dimethylethane- 1,2-diammonium iodide', 'NNDimethylethane12diammoniumiodide', '343.979', '2.180165', 'InChI=1S/C4H12N2.2HI/c1-6(2)4-3-5;;/h3-5H2,1-2H3;2*1H', 'BAMDIFIROXTEEM-UHFFFAOYSA-N', 'organic', 'C[NH+](C)CC[NH3+].[I-].[I-]', 'C4H14I2N2', NULL, NULL, NULL, NULL, NULL, NULL, 'C[NH+](C)CC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('N,N-dimethylpropane- 1,3-diammonium iodide', 'NNdimethylpropane13diammoniumiodide', '358.006', '2.053208', 'InChI=1S/C5H14N2.2HI/c1-7(2)5-3-4-6;;/h3-6H2,1-2H3;2*1H', 'JERSPYRKVMAEJY-UHFFFAOYSA-N', 'organic', 'C[NH+](C)CCC[NH3+].[I-].[I-]', 'C5H16I2N2', NULL, NULL, NULL, NULL, NULL, NULL, 'C[NH+](C)CCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('N,N-Diethylpropane-1,3-diammonium iodide', 'NNDiethylpropane13diammoniumiodide', '386.06', '1.848218', 'InChI=1S/C7H18N2.2HI/c1-3-9(4-2)7-5-6-8;;/h3-8H2,1-2H3;2*1H', 'NXRUEVJQMBGVAT-UHFFFAOYSA-N', 'organic', 'CC[NH+](CC)CCC[NH3+].[I-].[I-]', 'C7H20I2N2', NULL, NULL, NULL, NULL, NULL, NULL, 'CC[NH+](CC)CCC[NH3+]');
INSERT INTO "load_chem_inventory" VALUES ('Di-isopropylammonium iodide', 'Diisopropylammoniumiodide', '229.1', '1.454266', 'InChI=1S/C6H15N.HI/c1-5(2)7-6(3)4;/h5-7H,1-4H3;1H', 'PBGZCCFVBVEIAS-UHFFFAOYSA-N', 'organic', 'CC(C)[NH2+]C(C)C.[I-]', 'C6H16IN', '517666', NULL, NULL, NULL, NULL, NULL, 'CC(C)[NH2+]C(C)C');
INSERT INTO "load_chem_inventory" VALUES ('4-methoxy-phenethylammonium-iodide', '4methoxyphenethylammoniumiodide', '279.12', '1.566776', 'InChI=1S/C9H13NO.HI/c1-11-9-4-2-8(3-5-9)6-7-10;/h2-5H,6-7,10H2,1H3;1H', 'QNNYEDWTOZODAS-UHFFFAOYSA-N', 'organic', '[I-].[NH3+](CCC1=CC=C(C=C1)OC)', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'COC1=CC=C(CC[NH3+])C=C1');
INSERT INTO "load_chem_inventory" VALUES ('Iso-Propylammonium Bromide ', 'IsoPropylammoniumBromide ', '140.02', '1.841935', 'InChI=1S/C3H9N.BrH/c1-3(2)4;/h3H,4H2,1-2H3;1H', 'WGWKNMLSVLOQJB-UHFFFAOYSA-N', 'organic', 'CC(C)[NH3+].[Br-]', 'C3H10BrN', '22495069', NULL, NULL, NULL, NULL, NULL, 'CC(C)[NH3+]');
COMMIT;