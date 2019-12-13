--
-- PostgreSQL database dump
--

-- Dumped from database version 11.5
-- Dumped by pg_dump version 12.0

-- Started on 2019-12-13 10:04:05 EST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE "escalate";
--
-- TOC entry 3855 (class 1262 OID 16569)
-- Name: ESCALATEv3; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE "escalate" WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'C' LC_CTYPE = 'C';


\connect "escalate"

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 8 (class 2615 OID 132835)
-- Name: dev; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA dev;


--
-- TOC entry 375 (class 1255 OID 138887)
-- Name: get_materialid_bystatus(character varying[], boolean); Type: FUNCTION; Schema: dev; Owner: -
--

CREATE FUNCTION dev.get_materialid_bystatus(p_status_array character varying[], p_null_bool boolean) RETURNS TABLE(material_id bigint)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
			mat.material_id
		FROM
			material mat
			LEFT JOIN status st ON mat.status_id = st.status_id
		WHERE
		CASE		
			WHEN p_null_bool THEN 
				st.description = ANY(p_status_array) OR st.description IS NULL 
			ELSE st.description = ANY(p_status_array) 
		END;
END;
$$;


--
-- TOC entry 377 (class 1255 OID 138890)
-- Name: get_materialname_bystatus(character varying[], boolean); Type: FUNCTION; Schema: dev; Owner: -
--

CREATE FUNCTION dev.get_materialname_bystatus(p_status_arr character varying[], p_null_bool boolean) RETURNS TABLE(material_id bigint, material_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		mat.material_id,
		mat.description AS mname 
	FROM get_materialid_bystatus ( p_status_arr, p_null_bool ) act
	JOIN material mat ON act.material_id = mat.material_id 
	UNION ALL
	SELECT mnm.material_id, mnm.description 
	FROM material_name mnm
	JOIN 
		(SELECT mat.material_id 
		FROM get_materialid_bystatus ( p_status_arr, p_null_bool ) act
		JOIN material mat ON 
		act.material_id = mat.material_id) AS mid 
	ON mnm.material_id = mid.material_id;
END;
$$;


--
-- TOC entry 376 (class 1255 OID 138888)
-- Name: get_materialname_bystatus(character varying, boolean); Type: FUNCTION; Schema: dev; Owner: -
--

CREATE FUNCTION dev.get_materialname_bystatus(p_status character varying, p_null_bool boolean) RETURNS TABLE(material_id bigint, material_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
	RETURN QUERY SELECT
		mat.material_id,
		mat.description AS mname 
	FROM get_materialid_bystatus ( p_status_arr, p_null_bool ) act
	JOIN material mat ON act.material_id = mat.material_id 
	UNION ALL
	SELECT mnm.material_id, mnm.description 
	FROM material_name mnm
	JOIN 
		(SELECT mat.material_id 
		FROM get_materialid_bystatus ( p_status_arr, p_null_bool ) act
		JOIN material mat ON 
		act.material_id = mat.material_id) AS mid 
	ON mnm.material_id = mid.material_id;
END;
$$;


--
-- TOC entry 336 (class 1255 OID 132836)
-- Name: isdate(character varying); Type: FUNCTION; Schema: dev; Owner: -
--

CREATE FUNCTION dev.isdate(txt character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ BEGIN
		perform txt :: DATE;
	RETURN TRUE;
	EXCEPTION 
	WHEN OTHERS THEN
		RETURN FALSE;
END;
$$;


--
-- TOC entry 337 (class 1255 OID 132837)
-- Name: read_dirfiles(character varying); Type: FUNCTION; Schema: dev; Owner: -
--

CREATE FUNCTION dev.read_dirfiles(path character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$ DECLARE
	copycmd TEXT;
BEGIN
	IF ( PATH = '' ) THEN
			RETURN FALSE;
	ELSE 
		DROP TABLE IF EXISTS load_dirFILES;
		CREATE TABLE load_dirFILES ( filename TEXT );
		EXECUTE format ( 'COPY load_dirFILES FROM PROGRAM ''find %s -maxdepth 10 -type f'' ', PATH );
			RETURN TRUE;	
	END IF;
	EXCEPTION 
	WHEN OTHERS THEN
		RETURN FALSE;
END $$;


--
-- TOC entry 350 (class 1255 OID 132838)
-- Name: read_file_utf8(character varying); Type: FUNCTION; Schema: dev; Owner: -
--

CREATE FUNCTION dev.read_file_utf8(path character varying) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  var_file_oid OID;
  var_record   RECORD;
  var_result   BYTEA := '';
	var_resultt	 TEXT;
BEGIN
  SELECT lo_import(path)
  INTO var_file_oid;
  FOR var_record IN (SELECT data
                     FROM pg_largeobject
                     WHERE loid = var_file_oid
                     ORDER BY pageno) LOOP
  var_result = var_result || var_record.data;
  END LOOP;
  PERFORM lo_unlink(var_file_oid);
	var_resultt = regexp_replace(convert_from(var_result, 'utf8'), E'[\\n\\r] +', '', 'g' );
  RETURN var_resultt;
END;
$$;


--
-- TOC entry 351 (class 1255 OID 132839)
-- Name: trigger_set_timestamp(); Type: FUNCTION; Schema: dev; Owner: -
--

CREATE FUNCTION dev.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.mod_date = NOW();
  RETURN NEW;
END;
$$;


--
-- TOC entry 373 (class 1255 OID 138149)
-- Name: usp_get_material_bystatus(character varying, boolean); Type: PROCEDURE; Schema: dev; Owner: -
--

CREATE PROCEDURE dev.usp_get_material_bystatus(p_status character varying, p_null boolean)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
	SELECT
			mat.material_id
		FROM
			material mat
			LEFT JOIN status st ON mat.status_id = st.status_id 
		WHERE
		CASE		
			WHEN p_null THEN 
				st.description = p_status OR st.description IS NULL 
			ELSE st.description = 'active' 
		END; 
	END;
$$;


--
-- TOC entry 374 (class 1255 OID 138151)
-- Name: usp_get_material_bystatus(character varying, boolean, refcursor); Type: PROCEDURE; Schema: dev; Owner: -
--

CREATE PROCEDURE dev.usp_get_material_bystatus(p_status character varying, p_null boolean, INOUT resultset refcursor)
    LANGUAGE plpgsql
    AS $$ 
BEGIN
	open resultset for SELECT
			mat.material_id
		FROM
			material mat
			LEFT JOIN status st ON mat.status_id = st.status_id 
		WHERE
		CASE		
			WHEN p_null THEN 
				st.description = p_status OR st.description IS NULL 
			ELSE st.description = 'active' 
		END;
END;
$$;


SET default_tablespace = '';


--
-- TOC entry 304 (class 1259 OID 138341)
-- Name: actor; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.actor (
    actor_id bigint NOT NULL,
    actor_uuid uuid DEFAULT dev.uuid_generate_v4(),
    person_id bigint,
    organization_id bigint,
    systemtool_id bigint,
    description character varying(255),
    status_id bigint,
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 240 (class 1259 OID 132947)
-- Name: actor_actor_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.actor_actor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 303 (class 1259 OID 138339)
-- Name: actor_actor_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.actor_actor_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3869 (class 0 OID 0)
-- Dependencies: 303
-- Name: actor_actor_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.actor_actor_id_seq1 OWNED BY dev.actor.actor_id;


--
-- TOC entry 241 (class 1259 OID 132952)
-- Name: alt_material_name_alt_material_name_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.alt_material_name_alt_material_name_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 328 (class 1259 OID 138470)
-- Name: edocument; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.edocument (
    edocument_id bigint NOT NULL,
    edocument_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying,
    edocument bytea,
    edoc_type character varying(255),
    ver character varying(255),
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 242 (class 1259 OID 132957)
-- Name: edocument_edocument_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.edocument_edocument_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 327 (class 1259 OID 138468)
-- Name: edocument_edocument_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.edocument_edocument_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3870 (class 0 OID 0)
-- Dependencies: 327
-- Name: edocument_edocument_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.edocument_edocument_id_seq1 OWNED BY dev.edocument.edocument_id;


--
-- TOC entry 243 (class 1259 OID 132959)
-- Name: files; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.files (
    filename text
);


--
-- TOC entry 320 (class 1259 OID 138425)
-- Name: inventory; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.inventory (
    inventory_id bigint NOT NULL,
    inventory_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying,
    material_id bigint,
    actor_id bigint,
    part_no character varying,
    measure_id bigint,
    create_dt timestamp with time zone,
    expiration_dt timestamp with time zone,
    inventory_location character varying(255),
    status_id bigint,
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 244 (class 1259 OID 132968)
-- Name: inventory_inventory_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.inventory_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 319 (class 1259 OID 138423)
-- Name: inventory_inventory_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.inventory_inventory_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3871 (class 0 OID 0)
-- Dependencies: 319
-- Name: inventory_inventory_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.inventory_inventory_id_seq1 OWNED BY dev.inventory.inventory_id;


--
-- TOC entry 245 (class 1259 OID 132970)
-- Name: load_EXPDATA_JSON; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev."load_EXPDATA_JSON" (
    uid character varying(255) NOT NULL,
    exp_json jsonb,
    add_dt timestamp(6) with time zone
);


--
-- TOC entry 246 (class 1259 OID 132976)
-- Name: load_allamines_tier3_2; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_allamines_tier3_2 (
    smiles character varying(1023),
    id integer NOT NULL
);


--
-- TOC entry 247 (class 1259 OID 132982)
-- Name: load_allamines_tier3_2_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_allamines_tier3_2_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3872 (class 0 OID 0)
-- Dependencies: 247
-- Name: load_allamines_tier3_2_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_allamines_tier3_2_id_seq OWNED BY dev.load_allamines_tier3_2.id;


--
-- TOC entry 248 (class 1259 OID 132984)
-- Name: load_allamines_tier3_2_out_2_desc; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_allamines_tier3_2_out_2_desc (
    smiles character varying(1023),
    carbo_ring_cnt real,
    chain_atom_cnt real,
    chiral_center_cnt real,
    ring_atom_cnt real,
    smallest_ring_size real,
    largest_ring_size real,
    heteroaliphatic_ring_cnt real,
    heteroaromatic_ring_cnt real,
    rotatable_bond_cnt real,
    balaban_index real,
    cyclomatic_no real,
    hyper_wiener_index real,
    wiener_index real,
    wiener_polarity real,
    id bigint NOT NULL
);


--
-- TOC entry 279 (class 1259 OID 133949)
-- Name: load_allamines_tier3_2_out_2_desc_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_allamines_tier3_2_out_2_desc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3873 (class 0 OID 0)
-- Dependencies: 279
-- Name: load_allamines_tier3_2_out_2_desc_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_allamines_tier3_2_out_2_desc_id_seq OWNED BY dev.load_allamines_tier3_2_out_2_desc.id;


--
-- TOC entry 249 (class 1259 OID 132990)
-- Name: load_allamines_tier3_2_out_3_desc; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_allamines_tier3_2_out_3_desc (
    smiles character varying(1023),
    van_der_waals_vol real,
    acceptorcount real,
    accsitecount real,
    donorcount real,
    donsitecount real,
    acceptorcount1 real,
    donorcount1 real,
    id bigint NOT NULL
);


--
-- TOC entry 280 (class 1259 OID 133958)
-- Name: load_allamines_tier3_2_out_3_desc_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_allamines_tier3_2_out_3_desc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3874 (class 0 OID 0)
-- Dependencies: 280
-- Name: load_allamines_tier3_2_out_3_desc_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_allamines_tier3_2_out_3_desc_id_seq OWNED BY dev.load_allamines_tier3_2_out_3_desc.id;


--
-- TOC entry 250 (class 1259 OID 132996)
-- Name: load_allamines_tier3_2_standardized_k; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_allamines_tier3_2_standardized_k (
    smiles character varying(1023),
    id integer NOT NULL
);


--
-- TOC entry 251 (class 1259 OID 133002)
-- Name: load_allamines_tier3_2_standardized_k_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_allamines_tier3_2_standardized_k_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3875 (class 0 OID 0)
-- Dependencies: 251
-- Name: load_allamines_tier3_2_standardized_k_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_allamines_tier3_2_standardized_k_id_seq OWNED BY dev.load_allamines_tier3_2_standardized_k.id;


--
-- TOC entry 252 (class 1259 OID 133004)
-- Name: load_chem_inventory; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_chem_inventory (
    "ChemicalName" character varying(255),
    "ChemicalAbbreviation" character varying(255),
    "MolecularWeight" character varying(255),
    "Density" character varying(255),
    "InChI" character varying(255),
    "InChIKey" character varying(255),
    "ChemicalCategory" character varying(255),
    "CanonicalSMILES" character varying(255),
    "MolecularFormula" character varying(255),
    "PubChemID" character varying(255),
    "CatalogDescr" character varying(255),
    "Synonyms" character varying(255),
    "CatalogNo" character varying(255),
    "Sigma-Aldrich URL" character varying(255),
    "PrimaryInformationSource" character varying(255)
);


--
-- TOC entry 253 (class 1259 OID 133010)
-- Name: load_dirfiles; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_dirfiles (
    filename text
);


--
-- TOC entry 254 (class 1259 OID 133016)
-- Name: load_emole; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_emole (
    isosmiles character varying(1023),
    version_id integer,
    parent_id integer,
    smiid bigint NOT NULL
);


--
-- TOC entry 255 (class 1259 OID 133022)
-- Name: load_emole_smiid_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_emole_smiid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3876 (class 0 OID 0)
-- Dependencies: 255
-- Name: load_emole_smiid_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_emole_smiid_seq OWNED BY dev.load_emole.smiid;


--
-- TOC entry 256 (class 1259 OID 133024)
-- Name: load_emole_standardized; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_emole_standardized (
    smiles character varying(1023),
    "smiID" bigint NOT NULL
);


--
-- TOC entry 257 (class 1259 OID 133030)
-- Name: load_emole_standardized_smiID_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev."load_emole_standardized_smiID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3877 (class 0 OID 0)
-- Dependencies: 257
-- Name: load_emole_standardized_smiID_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev."load_emole_standardized_smiID_seq" OWNED BY dev.load_emole_standardized."smiID";


--
-- TOC entry 258 (class 1259 OID 133032)
-- Name: load_hc_inventory; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_hc_inventory (
    "Reagent (/abbreviation)" character varying(255),
    "Part #" character varying(255),
    "Stock bottles" character varying(255),
    "Remaining Amount (g)" character varying(255),
    "Date Updated" character varying(255),
    "Last Updated by" character varying(255),
    f7 character varying(255),
    f8 character varying(255),
    f9 character varying(255),
    f10 character varying(255),
    f11 character varying(255),
    f12 character varying(255),
    f13 character varying(255),
    f14 character varying(255),
    f15 character varying(255),
    f16 character varying(255),
    f17 character varying(255),
    f18 character varying(255),
    f19 character varying(255),
    f20 character varying(255),
    f21 character varying(255),
    f22 character varying(255),
    f23 character varying(255),
    f24 character varying(255)
);


--
-- TOC entry 259 (class 1259 OID 133038)
-- Name: load_lbl_inventory; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_lbl_inventory (
    "No" character varying(255),
    " " character varying(255),
    "Estimated for 96 vials of each chemicals)" character varying(255),
    "Stock" character varying(255),
    "Part #" character varying(255),
    "bulk order price" character varying(255),
    "Purchased" character varying(255),
    "Date Updated" character varying(255),
    f9 character varying(255),
    f10 character varying(255),
    f11 character varying(255),
    f12 character varying(255),
    f13 character varying(255),
    f14 character varying(255),
    f15 character varying(255),
    f16 character varying(255),
    f17 character varying(255),
    f18 character varying(255),
    f19 character varying(255),
    f20 character varying(255),
    f21 character varying(255),
    f22 character varying(255),
    f23 character varying(255),
    f24 character varying(255),
    f25 character varying(255),
    f26 character varying(255),
    f27 character varying(255)
);


--
-- TOC entry 260 (class 1259 OID 133044)
-- Name: load_perov_desc; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_perov_desc (
    _raw_inchikey character varying(255),
    _raw_smiles character varying(255),
    _raw_molweight numeric(255,0),
    _raw_smiles_standard character varying(255),
    _raw_standard_molweight numeric(255,0),
    "_prototype_ECPF4_256_6" character varying(256),
    "_feat_AtomCount_C" numeric(255,0),
    "_feat_AtomCount_N" numeric(255,0),
    "_feat_AvgPol" numeric(255,0),
    "_feat_MolPol" numeric(255,0),
    "_feat_Refractivity" numeric(255,0),
    "_feat_AliphaticRingCount" numeric(255,0),
    "_feat_AromaticRingCount" numeric(255,0),
    "_feat_Aliphatic AtomCount" numeric(255,0),
    "_feat_AromaticAtomCount" numeric(255,0),
    "_feat_BondCount" numeric(255,0),
    "_feat_CarboaliphaticRingCount" numeric(255,0),
    "_feat_CarboaromaticRingCount" numeric(255,0),
    "_feat_CarboRingCount" numeric(255,0),
    "_feat_ChainAtomCount" numeric(255,0),
    "_feat_ChiralCenterCount" numeric(255,0),
    "_feat_RingAtomCount" numeric(255,0),
    "_feat_SmallestRingSize" numeric(255,0),
    "_feat_LargestRingSize" numeric(255,0),
    "_feat_HeteroaliphaticRingCount" numeric(255,0),
    "_feat_HeteroaromaticRing Count" numeric(255,0),
    "_feat_RotatableBondCount" numeric(255,0),
    "_feat_BalabanIndex" numeric(255,0),
    "_feat_CyclomaticNumber" numeric(255,0),
    "_feat_HyperWienerIndex" numeric(255,0),
    "_feat_WienerIndex" numeric(255,0),
    "_feat_WienerPolarity" numeric(255,0),
    "_feat_MinimalProjectionArea" numeric(255,0),
    "_feat_MaximalProjectionArea" numeric(255,0),
    "_feat_MinimalProjectionRadius" numeric(255,0),
    "_feat_MaximalProjectionRadius" numeric(255,0),
    "_feat_LengthPerpendicularToTheMinArea" numeric(255,0),
    "_feat_LengthPerpendicularToTheMaxArea" numeric(255,0),
    "_feat_VanderWaalsVolume" numeric(255,0),
    "_feat_VanderWaalsSurfaceArea" numeric(255,0),
    "_feat_ASA" numeric(255,0),
    "_feat_ASA+" numeric(255,0),
    "_feat_ASA-" numeric(255,0),
    "_feat_ASA_H" numeric(255,0),
    "_feat_ASA_P" numeric(255,0),
    "_feat_PolarSurfaceArea" numeric(255,0),
    _feat_acceptorcount numeric(255,0),
    "_feat_Accsitecount" numeric(255,0),
    _feat_donorcount numeric(255,0),
    _feat_donsitecount numeric(255,0),
    "_feat_fr_NH2" numeric(255,0),
    "_feat_fr_NH1" numeric(255,0),
    "_feat_fr_NH0" numeric(255,0),
    "_feat_fr_quatN" numeric(255,0),
    "_feat_fr_ArN" numeric(255,0),
    "_feat_fr_Ar_NH" numeric(255,0),
    "_feat_fr_Imine" numeric(255,0),
    _feat_fr_amidine numeric(255,0),
    _feat_fr_dihydropyridine numeric(255,0),
    _feat_fr_guanido numeric(255,0),
    _feat_fr_piperdine numeric(255,0),
    _feat_fr_piperzine numeric(255,0),
    _feat_fr_pyridine numeric(255,0),
    _feat_maximalprojectionsize numeric(255,0),
    _feat_minimalprojectionsize numeric(255,0),
    "_feat_molsurfaceareaVDWp" numeric(255,0),
    "_feat_msareaVDWp" numeric(255,0),
    "_feat_molsurfaceareaASAp" numeric(255,0),
    "_feat_msareaASAp" numeric(255,0),
    "_feat_ProtPolarSurfaceArea" numeric(255,0),
    "_feat_Protpsa" numeric(255,0),
    "_feat_Hacceptorcount" numeric(255,0),
    "_feat_Hdonorcount" numeric(255,0)
);


--
-- TOC entry 282 (class 1259 OID 133971)
-- Name: load_version2_smiles; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_version2_smiles (
    sid bigint NOT NULL,
    smiles character varying(1023),
    version_id character varying(255),
    parent_id character varying(255)
);


--
-- TOC entry 281 (class 1259 OID 133969)
-- Name: load_version2_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_version2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3878 (class 0 OID 0)
-- Dependencies: 281
-- Name: load_version2_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_version2_id_seq OWNED BY dev.load_version2_smiles.sid;


--
-- TOC entry 290 (class 1259 OID 136340)
-- Name: load_version2_out_1_desc; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_version2_out_1_desc (
    sid bigint NOT NULL,
    smiles character varying(1023),
    molecular_weight double precision,
    atom_count_c double precision,
    atom_count_n double precision,
    avg_pol double precision,
    mol_pol double precision,
    refractivity double precision
);


--
-- TOC entry 289 (class 1259 OID 136338)
-- Name: load_version2_out_1_desc_sid_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_version2_out_1_desc_sid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3879 (class 0 OID 0)
-- Dependencies: 289
-- Name: load_version2_out_1_desc_sid_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_version2_out_1_desc_sid_seq OWNED BY dev.load_version2_out_1_desc.sid;


--
-- TOC entry 292 (class 1259 OID 136351)
-- Name: load_version2_out_2_desc; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_version2_out_2_desc (
    sid bigint NOT NULL,
    smiles character varying(1023),
    aliphatic_ring_cnt real,
    aromatic_ring_cnt real,
    aliphatic_atom_cnt real,
    aromatic_atom_cnt real,
    bond_cnt real,
    carboaliphatic_ring_cnt real,
    carboaromatic_ring_cnt real
);


--
-- TOC entry 291 (class 1259 OID 136349)
-- Name: load_version2_out_2_desc_sid_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_version2_out_2_desc_sid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3880 (class 0 OID 0)
-- Dependencies: 291
-- Name: load_version2_out_2_desc_sid_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_version2_out_2_desc_sid_seq OWNED BY dev.load_version2_out_2_desc.sid;


--
-- TOC entry 294 (class 1259 OID 136362)
-- Name: load_version2_out_3_ecpf_desc; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_version2_out_3_ecpf_desc (
    sid bigint NOT NULL,
    ecpf_256_6 character varying(256)
);


--
-- TOC entry 293 (class 1259 OID 136360)
-- Name: load_version2_out_3_ecpf_desc_sid_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_version2_out_3_ecpf_desc_sid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3881 (class 0 OID 0)
-- Dependencies: 293
-- Name: load_version2_out_3_ecpf_desc_sid_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_version2_out_3_ecpf_desc_sid_seq OWNED BY dev.load_version2_out_3_ecpf_desc.sid;


--
-- TOC entry 286 (class 1259 OID 136313)
-- Name: load_version2_smiles_name; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_version2_smiles_name (
    sid bigint NOT NULL,
    description character varying(2047)
);


--
-- TOC entry 285 (class 1259 OID 136311)
-- Name: load_version2_smiles_name_sid_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_version2_smiles_name_sid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3882 (class 0 OID 0)
-- Dependencies: 285
-- Name: load_version2_smiles_name_sid_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_version2_smiles_name_sid_seq OWNED BY dev.load_version2_smiles_name.sid;


--
-- TOC entry 284 (class 1259 OID 133986)
-- Name: load_version2_smiles_standard_k; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_version2_smiles_standard_k (
    sid bigint NOT NULL,
    smiles_standard_k character varying(1023)
);


--
-- TOC entry 288 (class 1259 OID 136326)
-- Name: load_version2_smiles_standard_k_name; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.load_version2_smiles_standard_k_name (
    sid bigint NOT NULL,
    description character varying(2047)
);


--
-- TOC entry 287 (class 1259 OID 136324)
-- Name: load_version2_smiles_standard_k_name_sid_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_version2_smiles_standard_k_name_sid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3883 (class 0 OID 0)
-- Dependencies: 287
-- Name: load_version2_smiles_standard_k_name_sid_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_version2_smiles_standard_k_name_sid_seq OWNED BY dev.load_version2_smiles_standard_k_name.sid;


--
-- TOC entry 283 (class 1259 OID 133984)
-- Name: load_version2_standard_k_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.load_version2_standard_k_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3884 (class 0 OID 0)
-- Dependencies: 283
-- Name: load_version2_standard_k_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.load_version2_standard_k_id_seq OWNED BY dev.load_version2_smiles_standard_k.sid;


--
-- TOC entry 314 (class 1259 OID 138392)
-- Name: m_descriptor; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.m_descriptor (
    m_descriptor_id bigint NOT NULL,
    m_descriptor_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying,
    material_id bigint,
    m_descriptor_class_id bigint,
    m_descriptor_value_id bigint,
    actor_id bigint,
    status_id bigint,
    ver character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 316 (class 1259 OID 138404)
-- Name: m_descriptor_class; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.m_descriptor_class (
    m_descriptor_class_id bigint NOT NULL,
    m_descriptor_class_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 261 (class 1259 OID 133071)
-- Name: m_descriptor_class_m_descriptor_class_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.m_descriptor_class_m_descriptor_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 315 (class 1259 OID 138402)
-- Name: m_descriptor_class_m_descriptor_class_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.m_descriptor_class_m_descriptor_class_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3885 (class 0 OID 0)
-- Dependencies: 315
-- Name: m_descriptor_class_m_descriptor_class_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.m_descriptor_class_m_descriptor_class_id_seq1 OWNED BY dev.m_descriptor_class.m_descriptor_class_id;


--
-- TOC entry 262 (class 1259 OID 133073)
-- Name: m_descriptor_m_descriptor_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.m_descriptor_m_descriptor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 313 (class 1259 OID 138390)
-- Name: m_descriptor_m_descriptor_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.m_descriptor_m_descriptor_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3886 (class 0 OID 0)
-- Dependencies: 313
-- Name: m_descriptor_m_descriptor_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.m_descriptor_m_descriptor_id_seq1 OWNED BY dev.m_descriptor.m_descriptor_id;


--
-- TOC entry 318 (class 1259 OID 138413)
-- Name: m_descriptor_value; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.m_descriptor_value (
    m_descriptor_value_id bigint NOT NULL,
    m_descriptor_value_uuid uuid DEFAULT dev.uuid_generate_v4(),
    num_value double precision,
    blob_value bytea,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 263 (class 1259 OID 133078)
-- Name: m_descriptor_value_m_descriptor_value_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.m_descriptor_value_m_descriptor_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 317 (class 1259 OID 138411)
-- Name: m_descriptor_value_m_descriptor_value_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.m_descriptor_value_m_descriptor_value_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3887 (class 0 OID 0)
-- Dependencies: 317
-- Name: m_descriptor_value_m_descriptor_value_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.m_descriptor_value_m_descriptor_value_id_seq1 OWNED BY dev.m_descriptor_value.m_descriptor_value_id;


--
-- TOC entry 306 (class 1259 OID 138350)
-- Name: material; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.material (
    material_id bigint NOT NULL,
    material_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying NOT NULL,
    parent_material_id bigint,
    status_id bigint,
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 264 (class 1259 OID 133083)
-- Name: material_material_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.material_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 305 (class 1259 OID 138348)
-- Name: material_material_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.material_material_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3888 (class 0 OID 0)
-- Dependencies: 305
-- Name: material_material_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.material_material_id_seq1 OWNED BY dev.material.material_id;


--
-- TOC entry 312 (class 1259 OID 138380)
-- Name: material_name; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.material_name (
    material_name_id bigint NOT NULL,
    material_name_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying,
    material_id bigint,
    material_name_type character varying(255),
    reference character varying(255),
    status_id bigint,
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 311 (class 1259 OID 138378)
-- Name: material_name_material_name_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.material_name_material_name_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3889 (class 0 OID 0)
-- Dependencies: 311
-- Name: material_name_material_name_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.material_name_material_name_id_seq OWNED BY dev.material_name.material_name_id;


--
-- TOC entry 310 (class 1259 OID 138371)
-- Name: material_ref; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.material_ref (
    material_ref_id bigint NOT NULL,
    material_ref_uuid uuid DEFAULT dev.uuid_generate_v4(),
    material_id bigint,
    material_type_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 265 (class 1259 OID 133088)
-- Name: material_ref_material_ref_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.material_ref_material_ref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 309 (class 1259 OID 138369)
-- Name: material_ref_material_ref_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.material_ref_material_ref_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3890 (class 0 OID 0)
-- Dependencies: 309
-- Name: material_ref_material_ref_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.material_ref_material_ref_id_seq1 OWNED BY dev.material_ref.material_ref_id;


--
-- TOC entry 308 (class 1259 OID 138362)
-- Name: material_type; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.material_type (
    material_type_id bigint NOT NULL,
    material_type_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 266 (class 1259 OID 133093)
-- Name: material_type_material_type_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.material_type_material_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 307 (class 1259 OID 138360)
-- Name: material_type_material_type_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.material_type_material_type_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3891 (class 0 OID 0)
-- Dependencies: 307
-- Name: material_type_material_type_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.material_type_material_type_id_seq1 OWNED BY dev.material_type.material_type_id;


--
-- TOC entry 322 (class 1259 OID 138437)
-- Name: measure; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.measure (
    measure_id bigint NOT NULL,
    measure_uuid uuid DEFAULT dev.uuid_generate_v4(),
    measure_type_id bigint,
    amount double precision,
    unit character varying(255),
    blob_amount bytea,
    document_id bigint,
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 267 (class 1259 OID 133098)
-- Name: measure_measure_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.measure_measure_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 321 (class 1259 OID 138435)
-- Name: measure_measure_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.measure_measure_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3892 (class 0 OID 0)
-- Dependencies: 321
-- Name: measure_measure_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.measure_measure_id_seq1 OWNED BY dev.measure.measure_id;


--
-- TOC entry 324 (class 1259 OID 138449)
-- Name: measure_type; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.measure_type (
    measure_type_id bigint NOT NULL,
    measure_type_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 268 (class 1259 OID 133103)
-- Name: measure_type_measure_type_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.measure_type_measure_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 323 (class 1259 OID 138447)
-- Name: measure_type_measure_type_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.measure_type_measure_type_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3893 (class 0 OID 0)
-- Dependencies: 323
-- Name: measure_type_measure_type_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.measure_type_measure_type_id_seq1 OWNED BY dev.measure_type.measure_type_id;


--
-- TOC entry 326 (class 1259 OID 138458)
-- Name: note; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.note (
    note_id bigint NOT NULL,
    note_uuid uuid DEFAULT dev.uuid_generate_v4(),
    notetext character varying,
    edocument_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 269 (class 1259 OID 133108)
-- Name: note_note_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.note_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 325 (class 1259 OID 138456)
-- Name: note_note_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.note_note_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3894 (class 0 OID 0)
-- Dependencies: 325
-- Name: note_note_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.note_note_id_seq1 OWNED BY dev.note.note_id;


--
-- TOC entry 296 (class 1259 OID 138296)
-- Name: organization; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.organization (
    organization_id bigint NOT NULL,
    organization_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    full_name character varying(255) NOT NULL,
    short_name character varying(255),
    address1 character varying(255),
    address2 character varying(255),
    city character varying(255),
    state_province character(3),
    zip character varying(255),
    country character varying(255),
    website_url character varying(255),
    phone character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 3895 (class 0 OID 0)
-- Dependencies: 296
-- Name: TABLE organization; Type: COMMENT; Schema: dev; Owner: -
--

COMMENT ON TABLE dev.organization IS 'organization information for ESCALATE users, vendors, and other actors';


--
-- TOC entry 3896 (class 0 OID 0)
-- Dependencies: 296
-- Name: COLUMN organization.organization_id; Type: COMMENT; Schema: dev; Owner: -
--

COMMENT ON COLUMN dev.organization.organization_id IS 'Primary key for organization records';


--
-- TOC entry 270 (class 1259 OID 133113)
-- Name: organization_organization_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.organization_organization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 295 (class 1259 OID 138294)
-- Name: organization_organization_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.organization_organization_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3897 (class 0 OID 0)
-- Dependencies: 295
-- Name: organization_organization_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.organization_organization_id_seq1 OWNED BY dev.organization.organization_id;


--
-- TOC entry 298 (class 1259 OID 138308)
-- Name: person; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.person (
    person_id bigint NOT NULL,
    person_uuid uuid DEFAULT dev.uuid_generate_v4(),
    firstname character varying(255),
    lastname character varying(255) NOT NULL,
    middlename character varying(255),
    address1 character varying(255),
    address2 character varying(255),
    city character varying(255),
    stateprovince character(3),
    phone character varying(255),
    email character varying(255),
    title character varying(255),
    suffix character varying(255),
    organization_id bigint,
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 271 (class 1259 OID 133118)
-- Name: person_person_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.person_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 297 (class 1259 OID 138306)
-- Name: person_person_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.person_person_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3898 (class 0 OID 0)
-- Dependencies: 297
-- Name: person_person_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.person_person_id_seq1 OWNED BY dev.person.person_id;


--
-- TOC entry 334 (class 1259 OID 138503)
-- Name: status; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.status (
    status_id bigint NOT NULL,
    description character varying(255),
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 333 (class 1259 OID 138501)
-- Name: status_status_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.status_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3899 (class 0 OID 0)
-- Dependencies: 333
-- Name: status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.status_status_id_seq OWNED BY dev.status.status_id;


--
-- TOC entry 300 (class 1259 OID 138320)
-- Name: systemtool; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.systemtool (
    systemtool_id bigint NOT NULL,
    systemtool_uuid uuid DEFAULT dev.uuid_generate_v4(),
    systemtool_name character varying(255) NOT NULL,
    description character varying(255),
    systemtool_type_id bigint,
    vendor character varying(255),
    model character varying(255),
    serial character varying(255),
    ver character varying(255),
    organization_id bigint,
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 272 (class 1259 OID 133123)
-- Name: systemtool_systemtool_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.systemtool_systemtool_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 299 (class 1259 OID 138318)
-- Name: systemtool_systemtool_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.systemtool_systemtool_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 299
-- Name: systemtool_systemtool_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.systemtool_systemtool_id_seq1 OWNED BY dev.systemtool.systemtool_id;


--
-- TOC entry 302 (class 1259 OID 138332)
-- Name: systemtool_type; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.systemtool_type (
    systemtool_type_id bigint NOT NULL,
    systemtool_type_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 273 (class 1259 OID 133128)
-- Name: systemtool_type_systemtool_type_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.systemtool_type_systemtool_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 301 (class 1259 OID 138330)
-- Name: systemtool_type_systemtool_type_id_seq1; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.systemtool_type_systemtool_type_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 301
-- Name: systemtool_type_systemtool_type_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.systemtool_type_systemtool_type_id_seq1 OWNED BY dev.systemtool_type.systemtool_type_id;


--
-- TOC entry 330 (class 1259 OID 138482)
-- Name: tag; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.tag (
    tag_id bigint NOT NULL,
    tag_uuid uuid DEFAULT dev.uuid_generate_v4(),
    tag_type_id bigint,
    description character varying,
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 329 (class 1259 OID 138480)
-- Name: tag_tag_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.tag_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 329
-- Name: tag_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.tag_tag_id_seq OWNED BY dev.tag.tag_id;


--
-- TOC entry 332 (class 1259 OID 138494)
-- Name: tag_type; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.tag_type (
    tag_type_id bigint NOT NULL,
    tag_type_uuid uuid DEFAULT dev.uuid_generate_v4(),
    short_desscription character varying(32),
    description character varying(255),
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


--
-- TOC entry 331 (class 1259 OID 138492)
-- Name: tag_type_tag_type_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.tag_type_tag_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 331
-- Name: tag_type_tag_type_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.tag_type_tag_type_id_seq OWNED BY dev.tag_type.tag_type_id;


--
-- TOC entry 274 (class 1259 OID 133130)
-- Name: trigger_test; Type: TABLE; Schema: dev; Owner: -
--

CREATE TABLE dev.trigger_test (
    tt_id integer NOT NULL,
    smiles text,
    val text
);


--
-- TOC entry 275 (class 1259 OID 133136)
-- Name: trigger_test_tt_id_seq; Type: SEQUENCE; Schema: dev; Owner: -
--

CREATE SEQUENCE dev.trigger_test_tt_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3904 (class 0 OID 0)
-- Dependencies: 275
-- Name: trigger_test_tt_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: -
--

ALTER SEQUENCE dev.trigger_test_tt_id_seq OWNED BY dev.trigger_test.tt_id;


--
-- TOC entry 3522 (class 2604 OID 138344)
-- Name: actor actor_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.actor ALTER COLUMN actor_id SET DEFAULT nextval('dev.actor_actor_id_seq1'::regclass);


--
-- TOC entry 3570 (class 2604 OID 138473)
-- Name: edocument edocument_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.edocument ALTER COLUMN edocument_id SET DEFAULT nextval('dev.edocument_edocument_id_seq1'::regclass);


--
-- TOC entry 3554 (class 2604 OID 138428)
-- Name: inventory inventory_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.inventory ALTER COLUMN inventory_id SET DEFAULT nextval('dev.inventory_inventory_id_seq1'::regclass);


--
-- TOC entry 3492 (class 2604 OID 133547)
-- Name: load_allamines_tier3_2 id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_allamines_tier3_2 ALTER COLUMN id SET DEFAULT nextval('dev.load_allamines_tier3_2_id_seq'::regclass);


--
-- TOC entry 3493 (class 2604 OID 133951)
-- Name: load_allamines_tier3_2_out_2_desc id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_allamines_tier3_2_out_2_desc ALTER COLUMN id SET DEFAULT nextval('dev.load_allamines_tier3_2_out_2_desc_id_seq'::regclass);


--
-- TOC entry 3494 (class 2604 OID 133960)
-- Name: load_allamines_tier3_2_out_3_desc id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_allamines_tier3_2_out_3_desc ALTER COLUMN id SET DEFAULT nextval('dev.load_allamines_tier3_2_out_3_desc_id_seq'::regclass);


--
-- TOC entry 3495 (class 2604 OID 133548)
-- Name: load_allamines_tier3_2_standardized_k id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_allamines_tier3_2_standardized_k ALTER COLUMN id SET DEFAULT nextval('dev.load_allamines_tier3_2_standardized_k_id_seq'::regclass);


--
-- TOC entry 3496 (class 2604 OID 133549)
-- Name: load_emole smiid; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_emole ALTER COLUMN smiid SET DEFAULT nextval('dev.load_emole_smiid_seq'::regclass);


--
-- TOC entry 3497 (class 2604 OID 133550)
-- Name: load_emole_standardized smiID; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_emole_standardized ALTER COLUMN "smiID" SET DEFAULT nextval('dev."load_emole_standardized_smiID_seq"'::regclass);


--
-- TOC entry 3503 (class 2604 OID 136343)
-- Name: load_version2_out_1_desc sid; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_out_1_desc ALTER COLUMN sid SET DEFAULT nextval('dev.load_version2_out_1_desc_sid_seq'::regclass);


--
-- TOC entry 3504 (class 2604 OID 136354)
-- Name: load_version2_out_2_desc sid; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_out_2_desc ALTER COLUMN sid SET DEFAULT nextval('dev.load_version2_out_2_desc_sid_seq'::regclass);


--
-- TOC entry 3505 (class 2604 OID 136365)
-- Name: load_version2_out_3_ecpf_desc sid; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_out_3_ecpf_desc ALTER COLUMN sid SET DEFAULT nextval('dev.load_version2_out_3_ecpf_desc_sid_seq'::regclass);


--
-- TOC entry 3499 (class 2604 OID 133974)
-- Name: load_version2_smiles sid; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_smiles ALTER COLUMN sid SET DEFAULT nextval('dev.load_version2_id_seq'::regclass);


--
-- TOC entry 3501 (class 2604 OID 136316)
-- Name: load_version2_smiles_name sid; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_smiles_name ALTER COLUMN sid SET DEFAULT nextval('dev.load_version2_smiles_name_sid_seq'::regclass);


--
-- TOC entry 3500 (class 2604 OID 133989)
-- Name: load_version2_smiles_standard_k sid; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_smiles_standard_k ALTER COLUMN sid SET DEFAULT nextval('dev.load_version2_standard_k_id_seq'::regclass);


--
-- TOC entry 3502 (class 2604 OID 136329)
-- Name: load_version2_smiles_standard_k_name sid; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_smiles_standard_k_name ALTER COLUMN sid SET DEFAULT nextval('dev.load_version2_smiles_standard_k_name_sid_seq'::regclass);


--
-- TOC entry 3542 (class 2604 OID 138395)
-- Name: m_descriptor m_descriptor_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor ALTER COLUMN m_descriptor_id SET DEFAULT nextval('dev.m_descriptor_m_descriptor_id_seq1'::regclass);


--
-- TOC entry 3546 (class 2604 OID 138407)
-- Name: m_descriptor_class m_descriptor_class_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor_class ALTER COLUMN m_descriptor_class_id SET DEFAULT nextval('dev.m_descriptor_class_m_descriptor_class_id_seq1'::regclass);


--
-- TOC entry 3550 (class 2604 OID 138416)
-- Name: m_descriptor_value m_descriptor_value_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor_value ALTER COLUMN m_descriptor_value_id SET DEFAULT nextval('dev.m_descriptor_value_m_descriptor_value_id_seq1'::regclass);


--
-- TOC entry 3526 (class 2604 OID 138353)
-- Name: material material_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material ALTER COLUMN material_id SET DEFAULT nextval('dev.material_material_id_seq1'::regclass);


--
-- TOC entry 3538 (class 2604 OID 138383)
-- Name: material_name material_name_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_name ALTER COLUMN material_name_id SET DEFAULT nextval('dev.material_name_material_name_id_seq'::regclass);


--
-- TOC entry 3534 (class 2604 OID 138374)
-- Name: material_ref material_ref_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_ref ALTER COLUMN material_ref_id SET DEFAULT nextval('dev.material_ref_material_ref_id_seq1'::regclass);


--
-- TOC entry 3530 (class 2604 OID 138365)
-- Name: material_type material_type_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_type ALTER COLUMN material_type_id SET DEFAULT nextval('dev.material_type_material_type_id_seq1'::regclass);


--
-- TOC entry 3558 (class 2604 OID 138440)
-- Name: measure measure_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.measure ALTER COLUMN measure_id SET DEFAULT nextval('dev.measure_measure_id_seq1'::regclass);


--
-- TOC entry 3562 (class 2604 OID 138452)
-- Name: measure_type measure_type_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.measure_type ALTER COLUMN measure_type_id SET DEFAULT nextval('dev.measure_type_measure_type_id_seq1'::regclass);


--
-- TOC entry 3566 (class 2604 OID 138461)
-- Name: note note_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.note ALTER COLUMN note_id SET DEFAULT nextval('dev.note_note_id_seq1'::regclass);


--
-- TOC entry 3506 (class 2604 OID 138299)
-- Name: organization organization_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.organization ALTER COLUMN organization_id SET DEFAULT nextval('dev.organization_organization_id_seq1'::regclass);


--
-- TOC entry 3510 (class 2604 OID 138311)
-- Name: person person_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.person ALTER COLUMN person_id SET DEFAULT nextval('dev.person_person_id_seq1'::regclass);


--
-- TOC entry 3582 (class 2604 OID 138506)
-- Name: status status_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.status ALTER COLUMN status_id SET DEFAULT nextval('dev.status_status_id_seq'::regclass);


--
-- TOC entry 3514 (class 2604 OID 138323)
-- Name: systemtool systemtool_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.systemtool ALTER COLUMN systemtool_id SET DEFAULT nextval('dev.systemtool_systemtool_id_seq1'::regclass);


--
-- TOC entry 3518 (class 2604 OID 138335)
-- Name: systemtool_type systemtool_type_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.systemtool_type ALTER COLUMN systemtool_type_id SET DEFAULT nextval('dev.systemtool_type_systemtool_type_id_seq1'::regclass);


--
-- TOC entry 3574 (class 2604 OID 138485)
-- Name: tag tag_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.tag ALTER COLUMN tag_id SET DEFAULT nextval('dev.tag_tag_id_seq'::regclass);


--
-- TOC entry 3578 (class 2604 OID 138497)
-- Name: tag_type tag_type_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.tag_type ALTER COLUMN tag_type_id SET DEFAULT nextval('dev.tag_type_tag_type_id_seq'::regclass);


--
-- TOC entry 3498 (class 2604 OID 133551)
-- Name: trigger_test tt_id; Type: DEFAULT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.trigger_test ALTER COLUMN tt_id SET DEFAULT nextval('dev.trigger_test_tt_id_seq'::regclass);


--
-- TOC entry 3586 (class 2606 OID 133245)
-- Name: ACTION_INGREDIENT ACTION_INGREDIENT_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev."ACTION_INGREDIENT"
    ADD CONSTRAINT "ACTION_INGREDIENT_pkey" PRIMARY KEY ("action_ingredientID");


--
-- TOC entry 3588 (class 2606 OID 133247)
-- Name: ACTION_PLAN ACTION_PLAN_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev."ACTION_PLAN"
    ADD CONSTRAINT "ACTION_PLAN_pkey" PRIMARY KEY ("action_planID");


--
-- TOC entry 3624 (class 2606 OID 138545)
-- Name: actor idx_actor; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT idx_actor UNIQUE (person_id, organization_id, systemtool_id);


--
-- TOC entry 3590 (class 2606 OID 133249)
-- Name: load_EXPDATA_JSON load_EXPDATA_JSON_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev."load_EXPDATA_JSON"
    ADD CONSTRAINT "load_EXPDATA_JSON_pkey" PRIMARY KEY (uid);


--
-- TOC entry 3592 (class 2606 OID 133251)
-- Name: load_allamines_tier3_2 load_allamines_tier3_2_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_allamines_tier3_2
    ADD CONSTRAINT load_allamines_tier3_2_pkey PRIMARY KEY (id);


--
-- TOC entry 3594 (class 2606 OID 133253)
-- Name: load_allamines_tier3_2_standardized_k load_allamines_tier3_2_standardized_k_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_allamines_tier3_2_standardized_k
    ADD CONSTRAINT load_allamines_tier3_2_standardized_k_pkey PRIMARY KEY (id);


--
-- TOC entry 3596 (class 2606 OID 133255)
-- Name: load_emole load_emole_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_emole
    ADD CONSTRAINT load_emole_pkey PRIMARY KEY (smiid);


--
-- TOC entry 3598 (class 2606 OID 133257)
-- Name: load_emole_standardized load_emole_standardized_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_emole_standardized
    ADD CONSTRAINT load_emole_standardized_pkey PRIMARY KEY ("smiID");


--
-- TOC entry 3610 (class 2606 OID 136348)
-- Name: load_version2_out_1_desc load_version2_out_1_desc_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_out_1_desc
    ADD CONSTRAINT load_version2_out_1_desc_pkey PRIMARY KEY (sid);


--
-- TOC entry 3612 (class 2606 OID 136359)
-- Name: load_version2_out_2_desc load_version2_out_2_desc_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_out_2_desc
    ADD CONSTRAINT load_version2_out_2_desc_pkey PRIMARY KEY (sid);


--
-- TOC entry 3614 (class 2606 OID 136367)
-- Name: load_version2_out_3_ecpf_desc load_version2_out_3_ecpf_desc_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_out_3_ecpf_desc
    ADD CONSTRAINT load_version2_out_3_ecpf_desc_pkey PRIMARY KEY (sid);


--
-- TOC entry 3602 (class 2606 OID 136258)
-- Name: load_version2_smiles load_version2_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_smiles
    ADD CONSTRAINT load_version2_pkey PRIMARY KEY (sid);


--
-- TOC entry 3606 (class 2606 OID 136321)
-- Name: load_version2_smiles_name load_version2_smiles_name_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_smiles_name
    ADD CONSTRAINT load_version2_smiles_name_pkey PRIMARY KEY (sid);


--
-- TOC entry 3608 (class 2606 OID 136334)
-- Name: load_version2_smiles_standard_k_name load_version2_smiles_standard_k_name_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_smiles_standard_k_name
    ADD CONSTRAINT load_version2_smiles_standard_k_name_pkey PRIMARY KEY (sid);


--
-- TOC entry 3604 (class 2606 OID 136262)
-- Name: load_version2_smiles_standard_k load_version2_standard_k_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.load_version2_smiles_standard_k
    ADD CONSTRAINT load_version2_standard_k_pkey PRIMARY KEY (sid);


--
-- TOC entry 3626 (class 2606 OID 138543)
-- Name: actor pk_actor_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT pk_actor_id PRIMARY KEY (actor_id);

ALTER TABLE dev.actor CLUSTER ON pk_actor_id;


--
-- TOC entry 3650 (class 2606 OID 138639)
-- Name: edocument pk_edocument_edocument_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.edocument
    ADD CONSTRAINT pk_edocument_edocument_id PRIMARY KEY (edocument_id);

ALTER TABLE dev.edocument CLUSTER ON pk_edocument_edocument_id;


--
-- TOC entry 3642 (class 2606 OID 138606)
-- Name: inventory pk_inventory_inventory_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT pk_inventory_inventory_id PRIMARY KEY (inventory_id);

ALTER TABLE dev.inventory CLUSTER ON pk_inventory_inventory_id;


--
-- TOC entry 3638 (class 2606 OID 138591)
-- Name: m_descriptor_class pk_m_descriptor_class_m_descriptor_class_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor_class
    ADD CONSTRAINT pk_m_descriptor_class_m_descriptor_class_id PRIMARY KEY (m_descriptor_class_id);

ALTER TABLE dev.m_descriptor_class CLUSTER ON pk_m_descriptor_class_m_descriptor_class_id;


--
-- TOC entry 3636 (class 2606 OID 138582)
-- Name: m_descriptor pk_m_descriptor_m_descriptor_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT pk_m_descriptor_m_descriptor_id PRIMARY KEY (m_descriptor_id);

ALTER TABLE dev.m_descriptor CLUSTER ON pk_m_descriptor_m_descriptor_id;


--
-- TOC entry 3640 (class 2606 OID 138597)
-- Name: m_descriptor_value pk_m_descriptor_value_m_descriptor_value_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor_value
    ADD CONSTRAINT pk_m_descriptor_value_m_descriptor_value_id PRIMARY KEY (m_descriptor_value_id);

ALTER TABLE dev.m_descriptor_value CLUSTER ON pk_m_descriptor_value_m_descriptor_value_id;


--
-- TOC entry 3628 (class 2606 OID 138552)
-- Name: material pk_material_material_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material
    ADD CONSTRAINT pk_material_material_id PRIMARY KEY (material_id);

ALTER TABLE dev.material CLUSTER ON pk_material_material_id;


--
-- TOC entry 3634 (class 2606 OID 138573)
-- Name: material_name pk_material_name_material_name_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_name
    ADD CONSTRAINT pk_material_name_material_name_id PRIMARY KEY (material_name_id);

ALTER TABLE dev.material_name CLUSTER ON pk_material_name_material_name_id;


--
-- TOC entry 3632 (class 2606 OID 138567)
-- Name: material_ref pk_material_ref_material_ref_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_ref
    ADD CONSTRAINT pk_material_ref_material_ref_id PRIMARY KEY (material_ref_id);

ALTER TABLE dev.material_ref CLUSTER ON pk_material_ref_material_ref_id;


--
-- TOC entry 3630 (class 2606 OID 138561)
-- Name: material_type pk_material_type_material_type_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_type
    ADD CONSTRAINT pk_material_type_material_type_id PRIMARY KEY (material_type_id);

ALTER TABLE dev.material_type CLUSTER ON pk_material_type_material_type_id;


--
-- TOC entry 3644 (class 2606 OID 138615)
-- Name: measure pk_measure_measure_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.measure
    ADD CONSTRAINT pk_measure_measure_id PRIMARY KEY (measure_id);

ALTER TABLE dev.measure CLUSTER ON pk_measure_measure_id;


--
-- TOC entry 3646 (class 2606 OID 138624)
-- Name: measure_type pk_measure_type_measure_type_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.measure_type
    ADD CONSTRAINT pk_measure_type_measure_type_id PRIMARY KEY (measure_type_id);

ALTER TABLE dev.measure_type CLUSTER ON pk_measure_type_measure_type_id;


--
-- TOC entry 3648 (class 2606 OID 138630)
-- Name: note pk_note_note_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.note
    ADD CONSTRAINT pk_note_note_id PRIMARY KEY (note_id);

ALTER TABLE dev.note CLUSTER ON pk_note_note_id;


--
-- TOC entry 3616 (class 2606 OID 138510)
-- Name: organization pk_organization_organization_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.organization
    ADD CONSTRAINT pk_organization_organization_id PRIMARY KEY (organization_id);

ALTER TABLE dev.organization CLUSTER ON pk_organization_organization_id;


--
-- TOC entry 3618 (class 2606 OID 138519)
-- Name: person pk_person_person_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.person
    ADD CONSTRAINT pk_person_person_id PRIMARY KEY (person_id);

ALTER TABLE dev.person CLUSTER ON pk_person_person_id;


--
-- TOC entry 3656 (class 2606 OID 138663)
-- Name: status pk_status_status_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.status
    ADD CONSTRAINT pk_status_status_id PRIMARY KEY (status_id);

ALTER TABLE dev.status CLUSTER ON pk_status_status_id;


--
-- TOC entry 3620 (class 2606 OID 138528)
-- Name: systemtool pk_systemtool_systemtool_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.systemtool
    ADD CONSTRAINT pk_systemtool_systemtool_id PRIMARY KEY (systemtool_id);

ALTER TABLE dev.systemtool CLUSTER ON pk_systemtool_systemtool_id;


--
-- TOC entry 3622 (class 2606 OID 138537)
-- Name: systemtool_type pk_systemtool_systemtool_type_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.systemtool_type
    ADD CONSTRAINT pk_systemtool_systemtool_type_id PRIMARY KEY (systemtool_type_id);

ALTER TABLE dev.systemtool_type CLUSTER ON pk_systemtool_systemtool_type_id;


--
-- TOC entry 3652 (class 2606 OID 138648)
-- Name: tag pk_tag_tag_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.tag
    ADD CONSTRAINT pk_tag_tag_id PRIMARY KEY (tag_id);

ALTER TABLE dev.tag CLUSTER ON pk_tag_tag_id;


--
-- TOC entry 3654 (class 2606 OID 138657)
-- Name: tag_type pk_tag_tag_type_id; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.tag_type
    ADD CONSTRAINT pk_tag_tag_type_id PRIMARY KEY (tag_type_id);

ALTER TABLE dev.tag_type CLUSTER ON pk_tag_tag_type_id;


--
-- TOC entry 3600 (class 2606 OID 133261)
-- Name: trigger_test trigger_test_pkey; Type: CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.trigger_test
    ADD CONSTRAINT trigger_test_pkey PRIMARY KEY (tt_id);


--
-- TOC entry 3694 (class 2620 OID 133262)
-- Name: ACTION set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."ACTION" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3695 (class 2620 OID 133263)
-- Name: ACTION_DEF set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."ACTION_DEF" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3696 (class 2620 OID 133264)
-- Name: ACTION_INGREDIENT set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."ACTION_INGREDIENT" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3698 (class 2620 OID 133265)
-- Name: ACTION_PLAN set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."ACTION_PLAN" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3699 (class 2620 OID 133266)
-- Name: AGGREGATE set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."AGGREGATE" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3700 (class 2620 OID 133267)
-- Name: EXPERIMENT set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."EXPERIMENT" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3701 (class 2620 OID 133268)
-- Name: INGREDIENT set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."INGREDIENT" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3702 (class 2620 OID 133269)
-- Name: INGREDIENT_REF set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."INGREDIENT_REF" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3703 (class 2620 OID 133270)
-- Name: INGREDIENT_TYPE set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."INGREDIENT_TYPE" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3704 (class 2620 OID 133271)
-- Name: OUTCOME set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."OUTCOME" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3706 (class 2620 OID 133272)
-- Name: STATUS set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."STATUS" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3707 (class 2620 OID 133273)
-- Name: TAG set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."TAG" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3708 (class 2620 OID 133274)
-- Name: WORKFLOW set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."WORKFLOW" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3697 (class 2620 OID 133275)
-- Name: ACTION_MATERIAL set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."ACTION_MATERIAL" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3705 (class 2620 OID 133276)
-- Name: RULE set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev."RULE" FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3716 (class 2620 OID 138853)
-- Name: material_ref set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.material_ref FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3717 (class 2620 OID 138854)
-- Name: material_name set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.material_name FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3718 (class 2620 OID 138855)
-- Name: m_descriptor set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.m_descriptor FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3710 (class 2620 OID 138856)
-- Name: person set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.person FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3712 (class 2620 OID 138857)
-- Name: systemtool_type set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.systemtool_type FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3711 (class 2620 OID 138858)
-- Name: systemtool set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.systemtool FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3713 (class 2620 OID 138859)
-- Name: actor set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.actor FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3714 (class 2620 OID 138860)
-- Name: material set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.material FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3715 (class 2620 OID 138861)
-- Name: material_type set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.material_type FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3724 (class 2620 OID 138862)
-- Name: note set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.note FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3709 (class 2620 OID 138863)
-- Name: organization set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.organization FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3728 (class 2620 OID 138864)
-- Name: status set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.status FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3719 (class 2620 OID 138865)
-- Name: m_descriptor_class set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.m_descriptor_class FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3720 (class 2620 OID 138866)
-- Name: m_descriptor_value set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.m_descriptor_value FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3721 (class 2620 OID 138867)
-- Name: inventory set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.inventory FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3722 (class 2620 OID 138868)
-- Name: measure set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.measure FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3723 (class 2620 OID 138869)
-- Name: measure_type set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.measure_type FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3725 (class 2620 OID 138870)
-- Name: edocument set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.edocument FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3727 (class 2620 OID 138871)
-- Name: tag_type set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.tag_type FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3726 (class 2620 OID 138872)
-- Name: tag set_timestamp; Type: TRIGGER; Schema: dev; Owner: -
--

CREATE TRIGGER set_timestamp BEFORE UPDATE ON dev.tag FOR EACH ROW EXECUTE PROCEDURE dev.trigger_set_timestamp();


--
-- TOC entry 3668 (class 2606 OID 138723)
-- Name: actor fk_actor_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT fk_actor_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3665 (class 2606 OID 138708)
-- Name: actor fk_actor_organization_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT fk_actor_organization_1 FOREIGN KEY (organization_id) REFERENCES dev.organization(organization_id);


--
-- TOC entry 3664 (class 2606 OID 138703)
-- Name: actor fk_actor_person_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT fk_actor_person_1 FOREIGN KEY (person_id) REFERENCES dev.person(person_id);


--
-- TOC entry 3667 (class 2606 OID 138718)
-- Name: actor fk_actor_status_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT fk_actor_status_1 FOREIGN KEY (status_id) REFERENCES dev.status(status_id);


--
-- TOC entry 3666 (class 2606 OID 138713)
-- Name: actor fk_actor_systemtool_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT fk_actor_systemtool_1 FOREIGN KEY (systemtool_id) REFERENCES dev.systemtool(systemtool_id);


--
-- TOC entry 3686 (class 2606 OID 138813)
-- Name: inventory fk_inventory_actor_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT fk_inventory_actor_1 FOREIGN KEY (actor_id) REFERENCES dev.actor(actor_id);


--
-- TOC entry 3685 (class 2606 OID 138808)
-- Name: inventory fk_inventory_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT fk_inventory_material_1 FOREIGN KEY (material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3687 (class 2606 OID 138818)
-- Name: inventory fk_inventory_measure_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT fk_inventory_measure_1 FOREIGN KEY (measure_id) REFERENCES dev.measure(measure_id);


--
-- TOC entry 3689 (class 2606 OID 138828)
-- Name: inventory fk_inventory_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT fk_inventory_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3688 (class 2606 OID 138823)
-- Name: inventory fk_inventory_status_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT fk_inventory_status_1 FOREIGN KEY (status_id) REFERENCES dev.status(status_id);


--
-- TOC entry 3679 (class 2606 OID 138778)
-- Name: m_descriptor fk_m_descriptor_actor_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_actor_1 FOREIGN KEY (actor_id) REFERENCES dev.actor(actor_id);


--
-- TOC entry 3684 (class 2606 OID 138803)
-- Name: m_descriptor_class fk_m_descriptor_class_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor_class
    ADD CONSTRAINT fk_m_descriptor_class_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3680 (class 2606 OID 138783)
-- Name: m_descriptor fk_m_descriptor_m_descriptor_class_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_m_descriptor_class_1 FOREIGN KEY (m_descriptor_class_id) REFERENCES dev.m_descriptor_class(m_descriptor_class_id);


--
-- TOC entry 3681 (class 2606 OID 138788)
-- Name: m_descriptor fk_m_descriptor_m_descriptor_value_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_m_descriptor_value_1 FOREIGN KEY (m_descriptor_value_id) REFERENCES dev.m_descriptor_value(m_descriptor_value_id);


--
-- TOC entry 3678 (class 2606 OID 138773)
-- Name: m_descriptor fk_m_descriptor_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_material_1 FOREIGN KEY (material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3683 (class 2606 OID 138798)
-- Name: m_descriptor fk_m_descriptor_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3682 (class 2606 OID 138793)
-- Name: m_descriptor fk_m_descriptor_status_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_status_1 FOREIGN KEY (status_id) REFERENCES dev.status(status_id);


--
-- TOC entry 3669 (class 2606 OID 138728)
-- Name: material fk_material_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material
    ADD CONSTRAINT fk_material_material_1 FOREIGN KEY (parent_material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3675 (class 2606 OID 138758)
-- Name: material_name fk_material_name_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_name
    ADD CONSTRAINT fk_material_name_material_1 FOREIGN KEY (material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3677 (class 2606 OID 138768)
-- Name: material_name fk_material_name_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_name
    ADD CONSTRAINT fk_material_name_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3676 (class 2606 OID 138763)
-- Name: material_name fk_material_name_status_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_name
    ADD CONSTRAINT fk_material_name_status_1 FOREIGN KEY (status_id) REFERENCES dev.status(status_id);


--
-- TOC entry 3671 (class 2606 OID 138738)
-- Name: material fk_material_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material
    ADD CONSTRAINT fk_material_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3673 (class 2606 OID 138748)
-- Name: material_ref fk_material_ref_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_ref
    ADD CONSTRAINT fk_material_ref_material_1 FOREIGN KEY (material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3674 (class 2606 OID 138753)
-- Name: material_ref fk_material_ref_material_type_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_ref
    ADD CONSTRAINT fk_material_ref_material_type_1 FOREIGN KEY (material_type_id) REFERENCES dev.material_type(material_type_id);


--
-- TOC entry 3670 (class 2606 OID 138733)
-- Name: material fk_material_status_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material
    ADD CONSTRAINT fk_material_status_1 FOREIGN KEY (status_id) REFERENCES dev.status(status_id);


--
-- TOC entry 3672 (class 2606 OID 138743)
-- Name: material_type fk_material_type_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.material_type
    ADD CONSTRAINT fk_material_type_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3690 (class 2606 OID 138833)
-- Name: measure_type fk_measure_type_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.measure_type
    ADD CONSTRAINT fk_measure_type_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3691 (class 2606 OID 138838)
-- Name: note fk_note_edocument_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.note
    ADD CONSTRAINT fk_note_edocument_1 FOREIGN KEY (edocument_id) REFERENCES dev.edocument(edocument_id);


--
-- TOC entry 3657 (class 2606 OID 138668)
-- Name: organization fk_organization_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.organization
    ADD CONSTRAINT fk_organization_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3659 (class 2606 OID 138678)
-- Name: person fk_person_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.person
    ADD CONSTRAINT fk_person_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3658 (class 2606 OID 138673)
-- Name: person fk_person_organization_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.person
    ADD CONSTRAINT fk_person_organization_1 FOREIGN KEY (organization_id) REFERENCES dev.organization(organization_id);


--
-- TOC entry 3662 (class 2606 OID 138693)
-- Name: systemtool fk_systemtool_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.systemtool
    ADD CONSTRAINT fk_systemtool_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3661 (class 2606 OID 138688)
-- Name: systemtool fk_systemtool_organization_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.systemtool
    ADD CONSTRAINT fk_systemtool_organization_1 FOREIGN KEY (organization_id) REFERENCES dev.organization(organization_id);


--
-- TOC entry 3660 (class 2606 OID 138683)
-- Name: systemtool fk_systemtool_systemtool_type_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.systemtool
    ADD CONSTRAINT fk_systemtool_systemtool_type_1 FOREIGN KEY (systemtool_type_id) REFERENCES dev.systemtool_type(systemtool_type_id);


--
-- TOC entry 3663 (class 2606 OID 138698)
-- Name: systemtool_type fk_systemtool_type_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.systemtool_type
    ADD CONSTRAINT fk_systemtool_type_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3693 (class 2606 OID 138848)
-- Name: tag fk_tag_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.tag
    ADD CONSTRAINT fk_tag_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3692 (class 2606 OID 138843)
-- Name: tag fk_tag_tag_type_1; Type: FK CONSTRAINT; Schema: dev; Owner: -
--

ALTER TABLE ONLY dev.tag
    ADD CONSTRAINT fk_tag_tag_type_1 FOREIGN KEY (tag_type_id) REFERENCES dev.tag_type(tag_type_id);


-- Completed on 2019-12-13 10:04:06 EST

--
-- PostgreSQL database dump complete
--

