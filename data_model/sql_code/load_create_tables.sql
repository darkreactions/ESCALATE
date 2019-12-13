-- ----------------------------
-- Table structure for load_version2_smiles_name
-- ----------------------------
DROP TABLE IF EXISTS load_version2_smiles_name cascade;
CREATE TABLE load_version2_smiles_name (
  sid serial8,
  description varchar(2047) COLLATE "pg_catalog"."default");
ALTER TABLE load_version2_smiles_name ADD PRIMARY KEY ("sid");


DROP TABLE IF EXISTS load_version2_smiles_standard_k_name cascade;
CREATE TABLE load_version2_smiles_standard_k_name (
  sid serial8,
  description varchar(2047) COLLATE "pg_catalog"."default");
ALTER TABLE load_version2_smiles_standard_k_name ADD PRIMARY KEY ("sid");


DROP TABLE IF EXISTS load_version2_out_1_desc cascade;
CREATE TABLE load_version2_out_1_desc (
  sid serial8,
	smiles varchar(1023) COLLATE "pg_catalog"."default",
  molecular_weight float8,
  atom_count_c float8,
  atom_count_n float8,
  avg_pol float8,
  mol_pol float8,
  refractivity float8);
ALTER TABLE load_version2_out_1_desc ADD PRIMARY KEY (sid);

DROP TABLE IF EXISTS load_version2_out_2_desc cascade;
CREATE TABLE load_version2_out_2_desc (
	sid serial8,
  smiles varchar(1023) COLLATE "pg_catalog"."default",
  aliphatic_ring_cnt float4,
  aromatic_ring_cnt float4,
  aliphatic_atom_cnt float4,
  aromatic_atom_cnt float4,
  bond_cnt float4,
  carboaliphatic_ring_cnt float4,
  carboaromatic_ring_cnt float4);
ALTER TABLE load_version2_out_2_desc ADD PRIMARY KEY (sid);

DROP TABLE IF EXISTS load_version2_out_3_ecpf_desc;
CREATE TABLE load_version2_out_3_ecpf_desc (
  sid serial8,
  ecpf_256_6 varchar(256) COLLATE "pg_catalog"."default");
ALTER TABLE load_version2_out_3_ecpf_desc ADD PRIMARY KEY (sid);



select org.sid, org.smiles, std.smiles_standard_k, orgn.description, stdn.description
from load_version2_smiles org 
join load_version2_smiles_standard_k std
on org.sid = std.sid
join load_version2_smiles_name orgn
on org.sid = orgn.sid
join load_version2_smiles_standard_k_name stdn
on org.sid = stdn.sid

select count(*)
from load_version2_out_1_desc

select count(*)
from load_version2_out_3_ecpf_desc

select *
from load_version2_out_1_desc