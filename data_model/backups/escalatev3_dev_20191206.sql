--
-- PostgreSQL database dump
--

-- Dumped from database version 12.1 (Debian 12.1-1.pgdg100+1)
-- Dumped by pg_dump version 12.0

-- Started on 2019-12-06 14:08:39 EST

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
-- TOC entry 11 (class 2615 OID 16405)
-- Name: dev; Type: SCHEMA; Schema: -; Owner: escalate
--

CREATE SCHEMA dev;


ALTER SCHEMA dev OWNER TO escalate;

--
-- TOC entry 358 (class 1255 OID 17322)
-- Name: isdate(character varying); Type: FUNCTION; Schema: dev; Owner: escalate
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


ALTER FUNCTION dev.isdate(txt character varying) OWNER TO escalate;

--
-- TOC entry 359 (class 1255 OID 17323)
-- Name: read_dirfiles(character varying); Type: FUNCTION; Schema: dev; Owner: escalate
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


ALTER FUNCTION dev.read_dirfiles(path character varying) OWNER TO escalate;

--
-- TOC entry 372 (class 1255 OID 17324)
-- Name: read_file_utf8(character varying); Type: FUNCTION; Schema: dev; Owner: escalate
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


ALTER FUNCTION dev.read_file_utf8(path character varying) OWNER TO escalate;

--
-- TOC entry 373 (class 1255 OID 17325)
-- Name: trigger_set_timestamp(); Type: FUNCTION; Schema: dev; Owner: escalate
--

CREATE FUNCTION dev.trigger_set_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.mod_date = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION dev.trigger_set_timestamp() OWNER TO escalate;

--
-- TOC entry 209 (class 1259 OID 17012)
-- Name: DOCUMENT_documentID_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev."DOCUMENT_documentID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev."DOCUMENT_documentID_seq" OWNER TO escalate;

--
-- TOC entry 210 (class 1259 OID 17014)
-- Name: NOTE_noteID_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev."NOTE_noteID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev."NOTE_noteID_seq" OWNER TO escalate;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 321 (class 1259 OID 27813)
-- Name: actor; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.actor (
    actor_id bigint NOT NULL,
    actor_uuid uuid DEFAULT dev.uuid_generate_v4(),
    person_id bigint,
    organization_id bigint,
    systemtool_id bigint,
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.actor OWNER TO escalate;

--
-- TOC entry 211 (class 1259 OID 17016)
-- Name: actor_actor_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.actor_actor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.actor_actor_id_seq OWNER TO escalate;

--
-- TOC entry 320 (class 1259 OID 27811)
-- Name: actor_actor_id_seq1; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.actor_actor_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.actor_actor_id_seq1 OWNER TO escalate;

--
-- TOC entry 3548 (class 0 OID 0)
-- Dependencies: 320
-- Name: actor_actor_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.actor_actor_id_seq1 OWNED BY dev.actor.actor_id;


--
-- TOC entry 329 (class 1259 OID 27849)
-- Name: alt_material_name; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.alt_material_name (
    alt_material_name_id bigint NOT NULL,
    alt_material_name_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    material_id bigint,
    alt_material_name_type character varying(255),
    reference character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.alt_material_name OWNER TO escalate;

--
-- TOC entry 212 (class 1259 OID 17018)
-- Name: alt_material_name_alt_material_name_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.alt_material_name_alt_material_name_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.alt_material_name_alt_material_name_id_seq OWNER TO escalate;

--
-- TOC entry 328 (class 1259 OID 27847)
-- Name: alt_material_name_alt_material_name_id_seq1; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.alt_material_name_alt_material_name_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.alt_material_name_alt_material_name_id_seq1 OWNER TO escalate;

--
-- TOC entry 3549 (class 0 OID 0)
-- Dependencies: 328
-- Name: alt_material_name_alt_material_name_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.alt_material_name_alt_material_name_id_seq1 OWNED BY dev.alt_material_name.alt_material_name_id;


--
-- TOC entry 345 (class 1259 OID 27933)
-- Name: edocument; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.edocument (
    edocument_id bigint NOT NULL,
    edocument_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    edocument bytea,
    edoc_type character varying(255),
    ver character varying(255),
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.edocument OWNER TO escalate;

--
-- TOC entry 344 (class 1259 OID 27931)
-- Name: edocument_edocument_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.edocument_edocument_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.edocument_edocument_id_seq OWNER TO escalate;

--
-- TOC entry 3550 (class 0 OID 0)
-- Dependencies: 344
-- Name: edocument_edocument_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.edocument_edocument_id_seq OWNED BY dev.edocument.edocument_id;


--
-- TOC entry 337 (class 1259 OID 27894)
-- Name: inventory; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.inventory (
    inventory_id bigint NOT NULL,
    inventory_uuid uuid DEFAULT dev.uuid_generate_v4(),
    material_id bigint,
    actor_id bigint,
    measure_id bigint,
    create_dt timestamp with time zone,
    expiration_dt timestamp with time zone,
    inventory_location character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.inventory OWNER TO escalate;

--
-- TOC entry 336 (class 1259 OID 27892)
-- Name: inventory_inventory_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.inventory_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.inventory_inventory_id_seq OWNER TO escalate;

--
-- TOC entry 3551 (class 0 OID 0)
-- Dependencies: 336
-- Name: inventory_inventory_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.inventory_inventory_id_seq OWNED BY dev.inventory.inventory_id;


--
-- TOC entry 213 (class 1259 OID 17020)
-- Name: load_allamines_tier3_2_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.load_allamines_tier3_2_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE dev.load_allamines_tier3_2_id_seq OWNER TO escalate;

--
-- TOC entry 214 (class 1259 OID 17022)
-- Name: load_allamines_tier3_2_standardized_k_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.load_allamines_tier3_2_standardized_k_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE dev.load_allamines_tier3_2_standardized_k_id_seq OWNER TO escalate;

--
-- TOC entry 228 (class 1259 OID 24971)
-- Name: load_chem_inventory; Type: TABLE; Schema: dev; Owner: escalate
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


ALTER TABLE dev.load_chem_inventory OWNER TO escalate;

--
-- TOC entry 215 (class 1259 OID 17024)
-- Name: load_emole_smiid_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.load_emole_smiid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE dev.load_emole_smiid_seq OWNER TO escalate;

--
-- TOC entry 216 (class 1259 OID 17026)
-- Name: load_emole_standardized_smiID_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev."load_emole_standardized_smiID_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev."load_emole_standardized_smiID_seq" OWNER TO escalate;

--
-- TOC entry 230 (class 1259 OID 24984)
-- Name: load_hc_inventory; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.load_hc_inventory (
    chemical character varying(255),
    part_no character varying(255),
    stock_bottles character varying(255),
    remaining_amt character varying(255),
    update_date character varying(255),
    lastupdate_date character varying(255)
);


ALTER TABLE dev.load_hc_inventory OWNER TO escalate;

--
-- TOC entry 231 (class 1259 OID 24990)
-- Name: load_lbl_inventory; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.load_lbl_inventory (
    no character varying(255),
    chemical character varying(255),
    est_96_vials_amt character varying(255),
    stock character varying(255),
    part_no character varying(255),
    bulk_order_price character varying(255),
    purch_date character varying(255),
    update_date character varying(255)
);


ALTER TABLE dev.load_lbl_inventory OWNER TO escalate;

--
-- TOC entry 229 (class 1259 OID 24978)
-- Name: load_perov_desc; Type: TABLE; Schema: dev; Owner: escalate
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


ALTER TABLE dev.load_perov_desc OWNER TO escalate;

--
-- TOC entry 331 (class 1259 OID 27861)
-- Name: m_descriptor; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.m_descriptor (
    m_descriptor_id bigint NOT NULL,
    m_descriptor_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
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


ALTER TABLE dev.m_descriptor OWNER TO escalate;

--
-- TOC entry 333 (class 1259 OID 27873)
-- Name: m_descriptor_class; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.m_descriptor_class (
    m_descriptor_class_id bigint NOT NULL,
    m_descriptor_class_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.m_descriptor_class OWNER TO escalate;

--
-- TOC entry 332 (class 1259 OID 27871)
-- Name: m_descriptor_class_m_descriptor_class_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.m_descriptor_class_m_descriptor_class_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.m_descriptor_class_m_descriptor_class_id_seq OWNER TO escalate;

--
-- TOC entry 3552 (class 0 OID 0)
-- Dependencies: 332
-- Name: m_descriptor_class_m_descriptor_class_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.m_descriptor_class_m_descriptor_class_id_seq OWNED BY dev.m_descriptor_class.m_descriptor_class_id;


--
-- TOC entry 330 (class 1259 OID 27859)
-- Name: m_descriptor_m_descriptor_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.m_descriptor_m_descriptor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.m_descriptor_m_descriptor_id_seq OWNER TO escalate;

--
-- TOC entry 3553 (class 0 OID 0)
-- Dependencies: 330
-- Name: m_descriptor_m_descriptor_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.m_descriptor_m_descriptor_id_seq OWNED BY dev.m_descriptor.m_descriptor_id;


--
-- TOC entry 335 (class 1259 OID 27882)
-- Name: m_descriptor_value; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.m_descriptor_value (
    m_descriptor_value_id bigint NOT NULL,
    m_descriptor_value_uuid uuid DEFAULT dev.uuid_generate_v4(),
    num_value double precision,
    blob_value bytea,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.m_descriptor_value OWNER TO escalate;

--
-- TOC entry 334 (class 1259 OID 27880)
-- Name: m_descriptor_value_m_descriptor_value_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.m_descriptor_value_m_descriptor_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.m_descriptor_value_m_descriptor_value_id_seq OWNER TO escalate;

--
-- TOC entry 3554 (class 0 OID 0)
-- Dependencies: 334
-- Name: m_descriptor_value_m_descriptor_value_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.m_descriptor_value_m_descriptor_value_id_seq OWNED BY dev.m_descriptor_value.m_descriptor_value_id;


--
-- TOC entry 323 (class 1259 OID 27822)
-- Name: material; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.material (
    material_id bigint NOT NULL,
    material_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255) NOT NULL,
    parent_material_id bigint,
    actor_id bigint,
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.material OWNER TO escalate;

--
-- TOC entry 217 (class 1259 OID 17028)
-- Name: material_material_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.material_material_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.material_material_id_seq OWNER TO escalate;

--
-- TOC entry 322 (class 1259 OID 27820)
-- Name: material_material_id_seq1; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.material_material_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.material_material_id_seq1 OWNER TO escalate;

--
-- TOC entry 3555 (class 0 OID 0)
-- Dependencies: 322
-- Name: material_material_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.material_material_id_seq1 OWNED BY dev.material.material_id;


--
-- TOC entry 327 (class 1259 OID 27840)
-- Name: material_ref; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.material_ref (
    material_ref_id bigint NOT NULL,
    material_ref_uuid uuid DEFAULT dev.uuid_generate_v4(),
    material_id bigint,
    material_type_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.material_ref OWNER TO escalate;

--
-- TOC entry 218 (class 1259 OID 17030)
-- Name: material_ref_material_ref_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.material_ref_material_ref_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.material_ref_material_ref_id_seq OWNER TO escalate;

--
-- TOC entry 326 (class 1259 OID 27838)
-- Name: material_ref_material_ref_id_seq1; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.material_ref_material_ref_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.material_ref_material_ref_id_seq1 OWNER TO escalate;

--
-- TOC entry 3556 (class 0 OID 0)
-- Dependencies: 326
-- Name: material_ref_material_ref_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.material_ref_material_ref_id_seq1 OWNED BY dev.material_ref.material_ref_id;


--
-- TOC entry 325 (class 1259 OID 27831)
-- Name: material_type; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.material_type (
    material_type_id bigint NOT NULL,
    material_type_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.material_type OWNER TO escalate;

--
-- TOC entry 219 (class 1259 OID 17032)
-- Name: material_type_material_type_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.material_type_material_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.material_type_material_type_id_seq OWNER TO escalate;

--
-- TOC entry 324 (class 1259 OID 27829)
-- Name: material_type_material_type_id_seq1; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.material_type_material_type_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.material_type_material_type_id_seq1 OWNER TO escalate;

--
-- TOC entry 3557 (class 0 OID 0)
-- Dependencies: 324
-- Name: material_type_material_type_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.material_type_material_type_id_seq1 OWNED BY dev.material_type.material_type_id;


--
-- TOC entry 339 (class 1259 OID 27903)
-- Name: measure; Type: TABLE; Schema: dev; Owner: escalate
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


ALTER TABLE dev.measure OWNER TO escalate;

--
-- TOC entry 338 (class 1259 OID 27901)
-- Name: measure_measure_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.measure_measure_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.measure_measure_id_seq OWNER TO escalate;

--
-- TOC entry 3558 (class 0 OID 0)
-- Dependencies: 338
-- Name: measure_measure_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.measure_measure_id_seq OWNED BY dev.measure.measure_id;


--
-- TOC entry 341 (class 1259 OID 27915)
-- Name: measure_type; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.measure_type (
    measure_type_id bigint NOT NULL,
    measure_type_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.measure_type OWNER TO escalate;

--
-- TOC entry 340 (class 1259 OID 27913)
-- Name: measure_type_measure_type_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.measure_type_measure_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.measure_type_measure_type_id_seq OWNER TO escalate;

--
-- TOC entry 3559 (class 0 OID 0)
-- Dependencies: 340
-- Name: measure_type_measure_type_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.measure_type_measure_type_id_seq OWNED BY dev.measure_type.measure_type_id;


--
-- TOC entry 343 (class 1259 OID 27924)
-- Name: note; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.note (
    note_id bigint NOT NULL,
    note_uuid uuid DEFAULT dev.uuid_generate_v4(),
    notetext character varying(255),
    edocument_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.note OWNER TO escalate;

--
-- TOC entry 342 (class 1259 OID 27922)
-- Name: note_note_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.note_note_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.note_note_id_seq OWNER TO escalate;

--
-- TOC entry 3560 (class 0 OID 0)
-- Dependencies: 342
-- Name: note_note_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.note_note_id_seq OWNED BY dev.note.note_id;


--
-- TOC entry 313 (class 1259 OID 27768)
-- Name: organization; Type: TABLE; Schema: dev; Owner: escalate
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


ALTER TABLE dev.organization OWNER TO escalate;

--
-- TOC entry 220 (class 1259 OID 17034)
-- Name: organization_organization_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.organization_organization_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.organization_organization_id_seq OWNER TO escalate;

--
-- TOC entry 312 (class 1259 OID 27766)
-- Name: organization_organization_id_seq1; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.organization_organization_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.organization_organization_id_seq1 OWNER TO escalate;

--
-- TOC entry 3561 (class 0 OID 0)
-- Dependencies: 312
-- Name: organization_organization_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.organization_organization_id_seq1 OWNED BY dev.organization.organization_id;


--
-- TOC entry 315 (class 1259 OID 27780)
-- Name: person; Type: TABLE; Schema: dev; Owner: escalate
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


ALTER TABLE dev.person OWNER TO escalate;

--
-- TOC entry 221 (class 1259 OID 17036)
-- Name: person_person_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.person_person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.person_person_id_seq OWNER TO escalate;

--
-- TOC entry 314 (class 1259 OID 27778)
-- Name: person_person_id_seq1; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.person_person_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.person_person_id_seq1 OWNER TO escalate;

--
-- TOC entry 3562 (class 0 OID 0)
-- Dependencies: 314
-- Name: person_person_id_seq1; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.person_person_id_seq1 OWNED BY dev.person.person_id;


--
-- TOC entry 351 (class 1259 OID 27963)
-- Name: status; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.status (
    status_id bigint NOT NULL,
    description character varying(255),
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.status OWNER TO escalate;

--
-- TOC entry 350 (class 1259 OID 27961)
-- Name: status_status_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.status_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.status_status_id_seq OWNER TO escalate;

--
-- TOC entry 3563 (class 0 OID 0)
-- Dependencies: 350
-- Name: status_status_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.status_status_id_seq OWNED BY dev.status.status_id;


--
-- TOC entry 222 (class 1259 OID 17038)
-- Name: system_system_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.system_system_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.system_system_id_seq OWNER TO escalate;

--
-- TOC entry 317 (class 1259 OID 27792)
-- Name: systemtool; Type: TABLE; Schema: dev; Owner: escalate
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


ALTER TABLE dev.systemtool OWNER TO escalate;

--
-- TOC entry 316 (class 1259 OID 27790)
-- Name: systemtool_systemtool_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.systemtool_systemtool_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.systemtool_systemtool_id_seq OWNER TO escalate;

--
-- TOC entry 3564 (class 0 OID 0)
-- Dependencies: 316
-- Name: systemtool_systemtool_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.systemtool_systemtool_id_seq OWNED BY dev.systemtool.systemtool_id;


--
-- TOC entry 319 (class 1259 OID 27804)
-- Name: systemtool_type; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.systemtool_type (
    systemtool_type_id bigint NOT NULL,
    systemtool_type_uuid uuid DEFAULT dev.uuid_generate_v4(),
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.systemtool_type OWNER TO escalate;

--
-- TOC entry 318 (class 1259 OID 27802)
-- Name: systemtool_type_systemtool_type_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.systemtool_type_systemtool_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.systemtool_type_systemtool_type_id_seq OWNER TO escalate;

--
-- TOC entry 3565 (class 0 OID 0)
-- Dependencies: 318
-- Name: systemtool_type_systemtool_type_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.systemtool_type_systemtool_type_id_seq OWNED BY dev.systemtool_type.systemtool_type_id;


--
-- TOC entry 223 (class 1259 OID 17040)
-- Name: systemtype_systemtype_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.systemtype_systemtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.systemtype_systemtype_id_seq OWNER TO escalate;

--
-- TOC entry 347 (class 1259 OID 27945)
-- Name: tag; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.tag (
    tag_id bigint NOT NULL,
    tag_uuid uuid DEFAULT dev.uuid_generate_v4(),
    tag_type_id bigint,
    description character varying(255),
    note_id bigint,
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.tag OWNER TO escalate;

--
-- TOC entry 346 (class 1259 OID 27943)
-- Name: tag_tag_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.tag_tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.tag_tag_id_seq OWNER TO escalate;

--
-- TOC entry 3566 (class 0 OID 0)
-- Dependencies: 346
-- Name: tag_tag_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.tag_tag_id_seq OWNED BY dev.tag.tag_id;


--
-- TOC entry 349 (class 1259 OID 27954)
-- Name: tag_type; Type: TABLE; Schema: dev; Owner: escalate
--

CREATE TABLE dev.tag_type (
    tag_type_id bigint NOT NULL,
    tag_type_uuid uuid DEFAULT dev.uuid_generate_v4(),
    short_desscription character varying(32),
    description character varying(255),
    add_date timestamp with time zone DEFAULT now() NOT NULL,
    mod_date timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE dev.tag_type OWNER TO escalate;

--
-- TOC entry 348 (class 1259 OID 27952)
-- Name: tag_type_tag_type_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.tag_type_tag_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE dev.tag_type_tag_type_id_seq OWNER TO escalate;

--
-- TOC entry 3567 (class 0 OID 0)
-- Dependencies: 348
-- Name: tag_type_tag_type_id_seq; Type: SEQUENCE OWNED BY; Schema: dev; Owner: escalate
--

ALTER SEQUENCE dev.tag_type_tag_type_id_seq OWNED BY dev.tag_type.tag_type_id;


--
-- TOC entry 224 (class 1259 OID 17042)
-- Name: trigger_test_tt_id_seq; Type: SEQUENCE; Schema: dev; Owner: escalate
--

CREATE SEQUENCE dev.trigger_test_tt_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE dev.trigger_test_tt_id_seq OWNER TO escalate;

--
-- TOC entry 3218 (class 2604 OID 27816)
-- Name: actor actor_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.actor ALTER COLUMN actor_id SET DEFAULT nextval('dev.actor_actor_id_seq1'::regclass);


--
-- TOC entry 3234 (class 2604 OID 27852)
-- Name: alt_material_name alt_material_name_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.alt_material_name ALTER COLUMN alt_material_name_id SET DEFAULT nextval('dev.alt_material_name_alt_material_name_id_seq1'::regclass);


--
-- TOC entry 3266 (class 2604 OID 27936)
-- Name: edocument edocument_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.edocument ALTER COLUMN edocument_id SET DEFAULT nextval('dev.edocument_edocument_id_seq'::regclass);


--
-- TOC entry 3250 (class 2604 OID 27897)
-- Name: inventory inventory_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.inventory ALTER COLUMN inventory_id SET DEFAULT nextval('dev.inventory_inventory_id_seq'::regclass);


--
-- TOC entry 3238 (class 2604 OID 27864)
-- Name: m_descriptor m_descriptor_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor ALTER COLUMN m_descriptor_id SET DEFAULT nextval('dev.m_descriptor_m_descriptor_id_seq'::regclass);


--
-- TOC entry 3242 (class 2604 OID 27876)
-- Name: m_descriptor_class m_descriptor_class_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor_class ALTER COLUMN m_descriptor_class_id SET DEFAULT nextval('dev.m_descriptor_class_m_descriptor_class_id_seq'::regclass);


--
-- TOC entry 3246 (class 2604 OID 27885)
-- Name: m_descriptor_value m_descriptor_value_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor_value ALTER COLUMN m_descriptor_value_id SET DEFAULT nextval('dev.m_descriptor_value_m_descriptor_value_id_seq'::regclass);


--
-- TOC entry 3222 (class 2604 OID 27825)
-- Name: material material_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material ALTER COLUMN material_id SET DEFAULT nextval('dev.material_material_id_seq1'::regclass);


--
-- TOC entry 3230 (class 2604 OID 27843)
-- Name: material_ref material_ref_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material_ref ALTER COLUMN material_ref_id SET DEFAULT nextval('dev.material_ref_material_ref_id_seq1'::regclass);


--
-- TOC entry 3226 (class 2604 OID 27834)
-- Name: material_type material_type_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material_type ALTER COLUMN material_type_id SET DEFAULT nextval('dev.material_type_material_type_id_seq1'::regclass);


--
-- TOC entry 3254 (class 2604 OID 27906)
-- Name: measure measure_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.measure ALTER COLUMN measure_id SET DEFAULT nextval('dev.measure_measure_id_seq'::regclass);


--
-- TOC entry 3258 (class 2604 OID 27918)
-- Name: measure_type measure_type_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.measure_type ALTER COLUMN measure_type_id SET DEFAULT nextval('dev.measure_type_measure_type_id_seq'::regclass);


--
-- TOC entry 3262 (class 2604 OID 27927)
-- Name: note note_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.note ALTER COLUMN note_id SET DEFAULT nextval('dev.note_note_id_seq'::regclass);


--
-- TOC entry 3202 (class 2604 OID 27771)
-- Name: organization organization_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.organization ALTER COLUMN organization_id SET DEFAULT nextval('dev.organization_organization_id_seq1'::regclass);


--
-- TOC entry 3206 (class 2604 OID 27783)
-- Name: person person_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.person ALTER COLUMN person_id SET DEFAULT nextval('dev.person_person_id_seq1'::regclass);


--
-- TOC entry 3278 (class 2604 OID 27966)
-- Name: status status_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.status ALTER COLUMN status_id SET DEFAULT nextval('dev.status_status_id_seq'::regclass);


--
-- TOC entry 3210 (class 2604 OID 27795)
-- Name: systemtool systemtool_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.systemtool ALTER COLUMN systemtool_id SET DEFAULT nextval('dev.systemtool_systemtool_id_seq'::regclass);


--
-- TOC entry 3214 (class 2604 OID 27807)
-- Name: systemtool_type systemtool_type_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.systemtool_type ALTER COLUMN systemtool_type_id SET DEFAULT nextval('dev.systemtool_type_systemtool_type_id_seq'::regclass);


--
-- TOC entry 3270 (class 2604 OID 27948)
-- Name: tag tag_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.tag ALTER COLUMN tag_id SET DEFAULT nextval('dev.tag_tag_id_seq'::regclass);


--
-- TOC entry 3274 (class 2604 OID 27957)
-- Name: tag_type tag_type_id; Type: DEFAULT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.tag_type ALTER COLUMN tag_type_id SET DEFAULT nextval('dev.tag_type_tag_type_id_seq'::regclass);


--
-- TOC entry 3512 (class 0 OID 27813)
-- Dependencies: 321
-- Data for Name: actor; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.actor (actor_id, actor_uuid, person_id, organization_id, systemtool_id, description, note_id, add_date, mod_date) FROM stdin;
1	ac4ab6a6-5ae1-42fe-9554-1190a4da006b	\N	1	\N	Haverford College	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
2	32f722b7-b26b-44dc-867c-2f1f37b2b2a3	\N	2	\N	LBL	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
3	93d1ed2f-4316-426b-bbb7-ee49676696d5	\N	3	\N	LBL	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
4	b6c99b6b-a2eb-452e-a0a3-4779c3d3bb09	\N	4	\N	LBL	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
5	f9239c0a-5939-48d2-a24f-7f1ac48a2105	\N	5	\N	LBL	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
6	a631d94e-2b3b-4ce8-ae7b-1e1bed4e1745	\N	6	\N	LBL	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
7	d65173c8-59f0-4b6c-a052-df01c9902dd6	\N	5	1	ChemAxon: standardize	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
8	5d5bec2f-9e69-400f-9755-4f6d6e3e8d4c	\N	5	2	ChemAxon: cxcalc	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
9	87bfee07-581f-4091-b5cf-95b143820df8	\N	5	3	ChemAxon: generatemd	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
10	5bee6f30-bdd8-4d98-b4ae-b4897c2fdb76	\N	6	4	RDKit: Python toolkit	\N	2019-12-06 18:34:56.310845+00	2019-12-06 18:34:56.310845+00
\.


--
-- TOC entry 3520 (class 0 OID 27849)
-- Dependencies: 329
-- Data for Name: alt_material_name; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.alt_material_name (alt_material_name_id, alt_material_name_uuid, description, material_id, alt_material_name_type, reference, note_id, add_date, mod_date) FROM stdin;
1	14544ab4-0ce6-4e99-882c-7b48a2d72353	GBL	1	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
2	6ae43559-cb91-488b-b8e8-0431cc7bb0ba	DMSO	2	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
3	220ad565-ae9d-4025-bdce-27d3696afb2e	FAH	3	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
4	3540c235-56c8-4579-a8c2-fdc6bcf2f6d5	PbI2	4	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
5	6cf78900-6bc8-4f5d-a8e5-7e17294b816f	EtNH3I	5	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
6	e1b38590-654d-4017-a733-3abb568049f3	MeNH3I	6	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
7	afb1475a-6d4f-45ba-9023-9899ffead6e6	PhEtNH3I	7	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
8	e8aa73c9-7c35-4baa-a96d-f8f8600b88f6	AcNH3I	8	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
9	3264abd6-596d-418e-a804-44c378bdf838	n-BuNH3I	9	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
10	141aa8f0-d9cd-4816-b731-5081e4c7869f	GnNH3I	10	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
11	1bd778e8-38b1-464d-ba95-9049435a88dc	DCM	11	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
12	6f5033e9-a656-4244-9d2b-77ee80635699	Me2NH2I	12	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
13	f154cde7-0818-4060-9438-532c5fbc7f04	PhenylammoniumIodide	13	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
14	a4c0f7fb-1228-4b2e-88a7-78d0e48a108e	tButylammoniumIodide	14	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
15	d3afbf42-44d6-456d-af3a-4ff122cc217b	NPropylammoniumIodide	15	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
16	2ef4b9e4-b37d-42c8-83f7-f33f5c8dcc87	FormamidiniumIodide	16	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
17	346de03c-99f2-4f4e-a9e8-1d2fc76d694f	Dabcoiodide	17	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
18	0a85324b-7078-4c72-8d70-51d45c2d42e3	4FluoroBenzylammoniumIodide	18	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
19	0c7a5f22-5a9a-4347-99aa-aa59a010d459	4FluoroPhenethylammoniumIodide	19	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
20	5ce5e70b-ce2b-4282-91dd-c7a6602238f5	4FluoroPhenylammoniumIodide	20	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
21	23e66310-169d-4485-a257-6738f6bf1261	4MethoxyPhenylammoniumIodide	21	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
22	09832906-c07d-4984-b28d-ff04a2bdacaa	4TrifluoromethylBenzylammoniumIodide	22	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
23	cf0b794c-f9a7-4369-89af-88bb2a027632	4TrifluoromethylPhenylammoniumIodide	23	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
24	91544ee7-3dbc-4831-8073-15d960ec36bb	CBz	24	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
25	60c12b88-3aaf-4f42-a0cf-2d36fc9442cc	AcNH3Br	25	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
26	ca328adb-63ca-400a-a963-727a80de225b	benzylammoniumbromide	26	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
27	fa858945-b798-45bc-9240-bbb28b5d407c	BenzylammoniumIodide	27	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
28	a249e4f2-b03a-4e06-9660-ca9196e8d1e8	betaAlanineHydroiodide	28	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
29	57a4f87d-347a-4076-a914-a8c498c7d8db	BiI3	29	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
30	76d3edc1-64af-49fe-95e2-9ca4e8e1737c	CsI	30	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
31	bff691bd-b4b4-4ef3-b304-d9be1c26bca0	DMF	31	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
32	81442d21-953f-4bc8-bc4a-9d2a4f8e2ae1	EthylenediamineDihydrobromide	32	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
33	7cb12f6b-8e36-4984-b27e-f4a6c3029620	EthylenediamineDihydriodide	33	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
34	7af7d6da-d3bf-4599-9d87-748333630592	EtNH3Br	34	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
35	a6650e0d-fcac-499c-a576-e064c8bb638f	FABr	35	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
36	42c6e1b3-2d49-42a8-a48b-79e2a56d903e	GnNH3Br	36	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
37	e29f226a-e760-4e38-b624-33fb79e60707	iPropylammoniumIodide	37	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
38	2b3d1534-30c4-4afa-8eab-686c70e7bf08	ImidazoliumIodide	38	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
39	377cebca-3c58-42cc-a80b-570fa65d81bc	iButylammoniumBromide	39	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
40	faf3bffd-36b3-4512-b05c-817cff976871	iButylammoniumIodide	40	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
41	7c1dd520-e67d-479b-850f-af3698ba313d	IPentylammoniumIodide	41	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
42	3dde41af-ef2d-4172-bfd6-d2c9d642a62e	LeadAcetate	42	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
43	cd51d2f0-19ab-4ddb-b4bc-911e84b11113	PbBr2	43	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
44	89300edb-ab11-4aab-8c2a-6f52b6cc3a69	Methylammoniumbromide	44	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
45	7d7144d6-ec9b-4aeb-b78e-f81bacdf6d16	MorpholiniumIodide	45	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
46	375cb4a6-51e3-444c-b023-1da806714e65	nDodecylammoniumBromide	46	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
47	37e732fd-ebe9-4448-91d6-93e89a19d35e	nDodecylammoniumIodide	47	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
48	7a6ce466-425c-42b8-893e-d2a3f6bf7230	nHexylammoniumIodide	48	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
49	cfc5f926-3954-472b-9c55-3300121392f3	nOctylammoniumIodide	49	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
50	38505bde-6e82-4a82-a704-a813ee039b26	neoPentylammoniumBromide	50	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
51	4e278ceb-6049-4f2d-910a-3592cd3a5e04	neoPentylammoniumIodide	51	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
52	35d1131a-1343-499a-80d7-1f303dd05468	Phenethylammoniumbromide	52	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
53	7b9758c8-95b7-4e79-a4e9-f779fb69abd6	PiperazinediiumDiBromide	53	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
54	6ab6a609-3fc8-44fa-a6c8-d02a496606dd	PiperazinediiumDiodide	54	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
55	0768f3b9-98e1-4f44-aa1e-e40dcb3b1e46	PiperidiniumIodide	55	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
56	c518c80d-2e18-455b-9c9a-2906bff979af	PVA	56	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
57	5c1bb528-2309-45c4-8980-427ad2f30a5d	PralidoximeIodide	57	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
58	a6adaa73-59bd-4c48-8aa8-7cd27a5a58a4	Propane13diammoniumIodide	58	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
59	cf244f10-30cd-4160-8ddf-b9ec10f2a95d	pyrrolidiniumBromide	59	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
60	c97ec599-0fe3-4779-9a9a-1c4a431aa788	PyrrolidiniumIodide	60	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
61	18138bea-9d2a-4a11-9563-1e5fa2e4d425	QuinuclidiniumBromide	61	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
62	cfaf2b36-462d-4726-a352-8392b3bf865d	QuinuclidiniumIodide	62	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
63	2315e3e2-1c92-4499-887d-25de85cb35e6	TertOctylammoniumIodide	63	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
64	4d4bfe7e-ecb6-4c8b-8ac9-2be1e9aaf34a	PyridiniumIodide	64	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
65	3fc33424-b95a-449a-8ee6-8568c2b75487	CyclohexylmethylammoniumIodide	65	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
66	78eaf385-7b33-49b0-8b5d-e95e7e742721	CyclohexylammoniumIodide	66	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
67	617cc076-d383-4035-a620-4ea0f56d0946	Butane14diammoniumIodide	67	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
68	00e29680-d9eb-4834-91a1-78415b814325	Benzenediaminedihydroiodide	68	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
69	fcddba24-5a27-4ce1-b925-973b4d8f2cfd	5Azaspironoiodide	69	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
70	e5fc48d6-b37f-47c6-b9c9-cc257afd7aef	Diethylammoniumiodide	70	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
71	72aca5ff-153c-4d2c-821c-e85a199c376f	2Pyrrolidin1ium1ylethylammoniumiodide	71	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
72	2fab15d4-2921-4348-945e-71d84a8485f0	NNDimethylethane12diammoniumiodide	72	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
73	208b913a-a2b2-4358-9231-01aaa37bf002	NNdimethylpropane13diammoniumiodide	73	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
74	bdf83ce4-c8e3-45f3-836d-4eb2e248cdcc	NNDiethylpropane13diammoniumiodide	74	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
75	3b4412f3-6ca5-43a8-bca3-9ff38f3256f1	Diisopropylammoniumiodide	75	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
76	42140174-b087-40d7-b66d-5fff33f64873	4methoxyphenethylammoniumiodide	76	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
77	f61c8e8c-b3ba-45a1-a698-000e051a4202	IsoPropylammoniumBromide 	77	Abbreviation	\N	\N	2019-12-06 18:35:16.705118+00	2019-12-06 18:35:16.705118+00
78	91d96032-d107-4a7d-b097-218f9c8097d3	InChI=1S/C4H6O2/c5-4-2-1-3-6-4/h1-3H2	1	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
79	29bdc6af-4b8c-4c8c-b6dd-cec905d328b1	InChI=1S/C2H6OS/c1-4(2)3/h1-2H3	2	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
80	33a6304a-2212-4363-ba54-6473c0c40708	InChI=1S/CH2O2/c2-1-3/h1H,(H,2,3)	3	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
81	b7dbf595-2c5b-4af4-afc2-3bb3b7d0735c	InChI=1S/2HI.Pb/h2*1H;/q;;+2/p-2	4	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
82	a0a3e0d9-e944-453a-a11f-1844ccb1bcd8	InChI=1S/C2H7N.HI/c1-2-3;/h2-3H2,1H3;1H	5	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
83	f0f88613-2eab-4dae-83b4-2a200e063e7d	InChI=1S/CH5N.HI/c1-2;/h2H2,1H3;1H	6	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
84	7e6d1469-7393-4551-93cc-fac1a07c47a7	InChI=1S/C8H11N.HI/c9-7-6-8-4-2-1-3-5-8;/h1-5H,6-7,9H2;1H	7	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
85	17919bcd-1647-48bd-bab9-00221360c29c	InChI=1S/C2H6N2.HI/c1-2(3)4;/h1H3,(H3,3,4);1H	8	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
86	639eec41-efb4-4cfb-a93e-5b3163a075e4	InChI=1S/C4H11N.HI/c1-2-3-4-5;/h2-5H2,1H3;1H	9	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
87	6621ddc9-1bcf-4832-b72f-35191b940594	InChI=1S/CH5N3.HI/c2-1(3)4;/h(H5,2,3,4);1H	10	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
88	c258268e-7c8a-4de5-8c80-77542a85a425	InChI=1S/CH2Cl2/c2-1-3/h1H2	11	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
89	66776166-ad6a-4fb9-a265-0401f2fb20b8	InChI=1S/C2H7N.HI/c1-3-2;/h3H,1-2H3;1H	12	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
90	ea09065f-429d-4b98-a94d-e5b3a6dffa5c	InChI=1S/C6H7N.HI/c7-6-4-2-1-3-5-6;/h1-5H,7H2;1H	13	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
91	0d4b9ffb-d79a-4904-aaaa-c0e60041f66b	InChI=1S/C4H11N.HI/c1-4(2,3)5;/h5H2,1-3H3;1H	14	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
92	869b2962-8f6c-40d9-a584-a6b98871d555	InChI=1S/C3H9N.HI/c1-2-3-4;/h2-4H2,1H3;1H	15	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
93	3ed5dca3-2c89-484f-bf5e-d9657e17fb98	InChI=1S/CH4N2.HI/c2-1-3;/h1H,(H3,2,3);1H	16	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
94	3a586083-893f-4822-a68c-a67a9d48d419	InChI=1S/C6H12N2.2HI/c1-2-8-5-3-7(1)4-6-8;;/h1-6H2;2*1H	17	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
95	f9f3f889-7718-408d-aa4f-4935d047cc37	InChI=1S/C7H8FN.HI/c8-7-3-1-6(5-9)2-4-7;/h1-4H,5,9H2;1H	18	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
96	2fb4e7c1-ad54-4cac-9707-fbdc0865ade2	InChI=1S/C8H10FN.HI/c9-8-3-1-7(2-4-8)5-6-10;/h1-4H,5-6,10H2;1H	19	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
97	52cf891d-c3bc-4805-8b4b-0cae4f32987f	InChI=1S/C6H6FN.HI/c7-5-1-3-6(8)4-2-5;/h1-4H,8H2;1H	20	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
98	d9ad78f1-ee71-4d38-a9bd-e55de9ce0267	InChI=1S/C7H9NO.HI/c1-9-7-4-2-6(8)3-5-7;/h2-5H,8H2,1H3;1H	21	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
99	e200ff30-33a4-4297-89ce-0aa7c656bce2	InChI=1S/C8H8F3N.HI/c9-8(10,11)7-3-1-6(5-12)2-4-7;/h1-4H,5,12H2;1H	22	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
100	d28c15c2-6e87-43a4-970e-cdba57038a8a	InChI=1S/C7H6F3N.HI/c8-7(9,10)5-1-3-6(11)4-2-5;/h1-4H,11H2;1H	23	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
101	335f5624-491d-4f71-b83d-ac1da517c6e3	InChI=1S/C6H5Cl/c7-6-4-2-1-3-5-6/h1-5H	24	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
102	dda700dc-c752-433d-aee3-adfead78c895	InChI=1S/C2H6N2.BrH/c1-2(3)4;/h1H3,(H3,3,4);1H	25	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
103	8fb4d0f4-acd6-40a0-a0ec-fb2eb981e085	InChI=1S/C7H9N.BrH/c8-6-7-4-2-1-3-5-7;/h1-5H,6,8H2;1H	26	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
104	012b193d-6a8f-4ed9-9bf3-0e7fc89374b6	InChI=1S/C7H9N.HI/c8-6-7-4-2-1-3-5-7;/h1-5H,6,8H2;1H	27	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
105	4365b4c5-9e45-4bbd-a567-b3d53e1e25e9	InChI=1S/C3H7NO2.HI/c4-2-1-3(5)6;/h1-2,4H2,(H,5,6);1H	28	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
106	08e88598-2e9a-43e2-bcdd-8a0c2eef32cf	InChI=1S/Bi.3HI/h;3*1H/q+3;;;/p-3	29	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
107	4ffaf11a-fc57-4118-a818-74b9f5aabe4e	InChI=1S/Cs.HI/h;1H/q+1;/p-1	30	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
108	91c5684c-3efa-4ef6-8055-70ad703c2dd5	InChI=1S/C3H7NO/c1-4(2)3-5/h3H,1-2H3	31	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
109	0b0a5d55-2d1b-46a2-a574-086982788af2	InChI=1S/C2H8N2.2BrH/c3-1-2-4;;/h1-4H2;2*1H	32	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
110	20b4d508-fa4a-4954-9975-b4d0d2316f47	InChI=1S/C2H8N2.2HI/c3-1-2-4;;/h1-4H2;2*1H	33	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
111	fc619cc7-b1bf-443e-a828-1e913aff5376	InChI=1S/C2H7N.BrH/c1-2-3;/h2-3H2,1H3;1H	34	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
112	eec26e2d-7b85-4d9e-b6d2-7a5543e0abf0	InChI=1S/CH4N2.BrH/c2-1-3;/h1H,(H3,2,3);1H	35	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
113	8c8f2836-55a1-47d9-b42d-da8bee2d87b0	InChI=1S/CH5N3.BrH/c2-1(3)4;/h(H5,2,3,4);1H	36	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
114	82a4fa06-91c7-4ecd-87a0-a7abf40375a8	InChI=1S/C3H9N.HI/c1-3(2)4;/h3H,4H2,1-2H3;1H	37	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
115	4c1a4713-ff0c-4647-8056-eb35525368cc	InChI=1S/C3H4N2.HI/c1-2-5-3-4-1;/h1-3H,(H,4,5);1H	38	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
116	cf0b5751-2470-4a56-aa0f-d961cea20555	InChI=1S/C4H11N.BrH/c1-4(2)3-5;/h4H,3,5H2,1-2H3;1H	39	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
117	89e52be7-0e2c-4ed2-a1a5-8d10d33f8ecc	InChI=1S/C4H11N.HI/c1-4(2)3-5;/h4H,3,5H2,1-2H3;1H	40	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
118	0dea42ac-5287-47a0-98ad-637ea43e8729	InChI=1S/C5H13N.HI/c1-5(2)3-4-6;/h5H,3-4,6H2,1-2H3;1H	41	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
119	d5e606cf-219a-46c0-b689-5d3afa4915fe	InChI=1S/2C2H4O2.3H2O.Pb/c2*1-2(3)4;;;;/h2*1H3,(H,3,4);3*1H2;/q;;;;;+2/p-2	42	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
120	cec1d6a1-f264-4037-8873-261d72e81b98	InChI=1S/2BrH.Pb/h2*1H;/q;;+2/p-2	43	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
121	32d17c5d-5dcf-46b5-a260-c09f4bc47c6f	InChI=1S/CH5N.BrH/c1-2;/h2H2,1H3;1H	44	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
122	192efd1d-04de-43aa-b778-12220df64831	InChI=1S/C4H9NO.HI/c1-3-6-4-2-5-1;/h5H,1-4H2;1H	45	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
123	5b620200-d66b-4134-be80-a19c25f891b9	InChI=1S/C12H27N.BrH/c1-2-3-4-5-6-7-8-9-10-11-12-13;/h2-13H2,1H3;1H	46	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
124	0663d5be-25db-468f-bda0-dec329186732	InChI=1S/C12H27N.HI/c1-2-3-4-5-6-7-8-9-10-11-12-13;/h2-13H2,1H3;1H	47	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
183	0041f480-7f8a-4012-8c9c-4769770785e6	KOECRLKKXSXCPB-UHFFFAOYSA-K	29	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
125	d46659f9-33a8-477d-bdb4-572670323aa4	InChI=1S/C6H15N.HI/c1-2-3-4-5-6-7;/h2-7H2,1H3;1H	48	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
126	444fc8e3-4726-40ee-a0f2-b7387a3f37ab	InChI=1S/C8H19N.HI/c1-2-3-4-5-6-7-8-9;/h2-9H2,1H3;1H	49	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
127	ba149bea-6e54-4c02-a39c-f3408c5d7d0f	InChI=1S/C5H13N.BrH/c1-5(2,3)4-6;/h4,6H2,1-3H3;1H	50	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
128	d15b3c60-12af-4121-a396-dc88712fda20	InChI=1S/C5H13N.HI/c1-5(2,3)4-6;/h4,6H2,1-3H3;1H	51	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
129	34267fb7-f309-4181-919b-b00765f22987	InChI=1S/C8H11N.BrH/c9-7-6-8-4-2-1-3-5-8;/h1-5H,6-7,9H2;1H	52	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
130	0d889fe8-c9d2-444c-ad01-19a59b9644a4	InChI=1S/C4H10N2.2BrH/c1-2-6-4-3-5-1;;/h5-6H,1-4H2;2*1H	53	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
131	ad4a72c5-f29e-479c-a204-e5d3dba6c3cc	InChI=1S/C4H10N2.2HI/c1-2-6-4-3-5-1;;/h5-6H,1-4H2;2*1H	54	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
132	426bf048-02a1-462d-87e1-03b7dec93342	InChI=1S/C5H11N.HI/c1-2-4-6-5-3-1;/h6H,1-5H2;1H	55	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
133	370f43c9-ff1c-4aca-a5be-003801ff0f66	1S/C2H4O/c1-2-3/h2-3H,1H2	56	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
134	923cf198-b3ea-4abd-8249-6f6ce8377002	InChI=1S/C7H8N2O.HI/c1-9-5-3-2-4-7(9)6-8-10;/h2-6H,1H3;1H/b7-6+;	57	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
135	66c0f84f-56cf-4b67-b16b-9420465e84db	InChI=1S/C3H10N2.HI/c4-2-1-3-5;/h1-5H2;1H/p+1	58	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
136	a7784009-bcfe-44df-8adf-561a483ad0ad	InChI=1S/C4H9N.BrH/c1-2-4-5-3-1;/h5H,1-4H2;1H	59	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
137	afab43d7-7962-4977-9e74-236ce6af07d0	InChI=1S/C4H9N.HI/c1-2-4-5-3-1;/h5H,1-4H2;1H	60	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
138	03356826-d664-456b-aef7-5355bf45bb3f	InChI=1S/C7H13N.BrH/c1-4-8-5-2-7(1)3-6-8;/h7H,1-6H2;1H	61	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
139	803842ab-7c06-4ffc-b5b4-33e81e9df167	InChI=1S/C7H13N.HI/c1-4-8-5-2-7(1)3-6-8;/h7H,1-6H2;1H	62	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
140	7b07012b-35af-43e3-94d4-7bc3b25fa82b	InChI=1S/C8H19N.HI/c1-7(2,3)6-8(4,5)9;/h6,9H2,1-5H3;1H	63	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
141	28cf874d-a2a0-4b22-84f0-046f0923ac59	InChI=1S/C5H5N.HI/c1-2-4-6-5-3-1;/h1-5H;1H	64	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
142	457d7f9a-fd10-4c08-9e57-659373398274	InChI=1S/C7H15N.HI/c1-8-7-5-3-2-4-6-7;/h7-8H,2-6H2,1H3;1H	65	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
143	8986f21f-a9f0-426f-8164-2b326c0ca711	InChI=1S/C6H13N.HI/c7-6-4-2-1-3-5-6;/h6H,1-5,7H2;1H	66	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
144	035777cb-bfdf-401e-8061-4183963dd026	InChI=1S/C4H12N2.2HI/c5-3-1-2-4-6;;/h1-6H2;2*1H	67	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
145	9bf93075-1146-432f-b248-e630120deb7c	nChI=1S/C6H8N2.2HI/c7-5-1-2-6(8)4-3-5;;/h1-4H,7-8H2;2*1H	68	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
146	61d3d1e8-5b20-4ef2-9055-0110ab95fd9b	InChI=1S/C8H16N.HI/c1-2-6-9(5-1)7-3-4-8-9;/h1-8H2;1H/q+1;/p-1	69	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
147	926836bc-c822-435c-934f-03f6580f0cbe	InChI=1S/C4H11N.HI/c1-3-5-4-2;/h5H,3-4H2,1-2H3;1H	70	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
148	89b0ab01-1555-4c18-a0d1-62b08c2fc0ff	InChI=1S/C6H14N2.2HI/c7-3-6-8-4-1-2-5-8;;/h1-7H2;2*1H	71	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
149	2116a7e3-0dcc-4ed8-9a5a-b493eb881aa6	InChI=1S/C4H12N2.2HI/c1-6(2)4-3-5;;/h3-5H2,1-2H3;2*1H	72	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
150	43e967ec-3355-463f-aa00-dd686ffe38e9	InChI=1S/C5H14N2.2HI/c1-7(2)5-3-4-6;;/h3-6H2,1-2H3;2*1H	73	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
151	3e3d01cf-260f-4dca-970d-d9a80142e7a0	InChI=1S/C7H18N2.2HI/c1-3-9(4-2)7-5-6-8;;/h3-8H2,1-2H3;2*1H	74	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
152	7baacfec-bf55-48e4-b7a3-36d8f910f33f	InChI=1S/C6H15N.HI/c1-5(2)7-6(3)4;/h5-7H,1-4H3;1H	75	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
153	f93cf1e7-550a-4275-9056-8f6011c6dec3	InChI=1S/C9H13NO.HI/c1-11-9-4-2-8(3-5-9)6-7-10;/h2-5H,6-7,10H2,1H3;1H	76	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
154	286acdfb-a067-4f04-8522-f72579fdad00	InChI=1S/C3H9N.BrH/c1-3(2)4;/h3H,4H2,1-2H3;1H	77	InChi	\N	\N	2019-12-06 18:35:16.708279+00	2019-12-06 18:35:16.708279+00
155	3b8df4db-2326-4147-8579-ace8ec8cedcf	YEJRWHAVMIAJKC-UHFFFAOYSA-N	1	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
156	62c0aa67-f4ee-4680-98b9-8869cb7441c5	IAZDPXIOMUYVGZ-UHFFFAOYSA-N	2	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
157	efbac6fa-f566-4478-a445-5a211cd78062	BDAGIHXWWSANSR-UHFFFAOYSA-N	3	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
158	adb609ca-b88b-4eaa-9afc-63c33fbd43ba	RQQRAHKHDFPBMC-UHFFFAOYSA-L	4	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
159	69f71008-abb3-471d-b4c0-bb55fd3f0ebe	XFYICZOIWSBQSK-UHFFFAOYSA-N	5	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
160	8d1c1255-cb00-4b72-8718-cce5ba60e77f	LLWRXQXPJMPHLR-UHFFFAOYSA-N	6	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
161	fce14f86-e8dc-4f6a-a9f6-767bc89423eb	UPHCENSIMPJEIS-UHFFFAOYSA-N	7	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
162	845a121e-5160-498e-b21c-d27d5a5bc5dd	GGYGJCFIYJVWIP-UHFFFAOYSA-N	8	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
163	f48116c5-9f8d-4e2e-884f-a500bb7cc9ea	CALQKRVFTWDYDG-UHFFFAOYSA-N	9	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
164	c98beebc-9b4d-4b52-b58d-ecb2e0309a0e	UUDRLGYROXTISK-UHFFFAOYSA-N	10	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
165	3c8ec435-92fc-4c1d-9cfc-1e181d605bdd	YMWUJEATGCHHMB-UHFFFAOYSA-N	11	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
166	84cfa140-2908-44b0-8421-ab43c08473d0	JMXLWMIFDJCGBV-UHFFFAOYSA-N	12	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
167	7cd135d6-3718-44bc-8447-d99020bc962d	KFQARYBEAKAXIC-UHFFFAOYSA-N	13	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
168	e382f4a9-3df2-4cfd-952c-5031b6abaa67	NLJDBTZLVTWXRG-UHFFFAOYSA-N	14	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
169	7a852171-f7cf-4f1b-9aee-819a69c88473	GIAPQOZCVIEHNY-UHFFFAOYSA-N	15	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
170	7e4b7a1b-8447-4c08-a144-e44f23234dae	QHJPGANWSLEMTI-UHFFFAOYSA-N	16	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
171	6ef9a0a1-7d0c-4f52-a72b-e6211a4de0e1	WXTNTIQDYHIFEG-UHFFFAOYSA-N	17	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
172	73e6fb37-af4d-40ef-ac01-e5c1c717bcd4	LCTUISCIGMWMAT-UHFFFAOYSA-N	18	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
173	f2e615ce-79b1-430d-83e2-813eda8f2f03	NOHLSFNWSBZSBW-UHFFFAOYSA-N	19	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
174	a27f3450-af1e-400d-b485-1c6139487863	FJFIJIDZQADKEE-UHFFFAOYSA-N	20	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
175	c2f006f5-5c31-4194-b533-7131019aa079	QRFXELVDJSDWHX-UHFFFAOYSA-N	21	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
176	d0f8c479-f991-4392-be4d-97505854f4ba	SQXJHWOXNLTOOO-UHFFFAOYSA-N	22	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
177	39c646a5-95dc-4d09-acf1-7819bee0ba61	KOAGKPNEVYEZDU-UHFFFAOYSA-N	23	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
178	a0886b1d-9a66-446b-8ca4-0b8b1cb0af37	MVPPADPHJFYWMZ-UHFFFAOYSA-N	24	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
179	8e66a6e7-75ee-40ac-a154-665d94bb77aa	CWJKVUQGXKYWTR-UHFFFAOYSA-N	25	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
180	649cebac-16ef-43d3-8665-833610ede1ce	QJFMCHRSDOLMHA-UHFFFAOYSA-N	26	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
181	f95a47e7-88cd-40eb-b324-bc3de35daad1	PPCHYMCMRUGLHR-UHFFFAOYSA-N	27	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
182	6fd090dd-6285-449d-a3ec-6a4a6dda7b78	XAKAQFUGWUAPJN-UHFFFAOYSA-N	28	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
184	0d8d4ee5-6bdc-4d27-b69d-59f088d738c5	XQPRBTXUXXVTKB-UHFFFAOYSA-M	30	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
185	3c18ec05-79a0-4739-a12d-7586a3d0ef72	ZMXDDKWLCZADIW-UHFFFAOYSA-N	31	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
186	a33d12a2-800a-481c-8ecf-dde8bb413437	BCQZYUOYVLJOPE-UHFFFAOYSA-N	32	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
187	85f7fbf7-75ad-44cb-9fb7-ff1707bbba57	IWNWLPUNKAYUAW-UHFFFAOYSA-N	33	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
188	6b76c433-eef9-4010-a7b2-39d6f80c0f0b	PNZDZRMOBIIQTC-UHFFFAOYSA-N	34	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
189	bcc73524-6385-4519-8200-8ceaaab04806	QWANGZFTSGZRPZ-UHFFFAOYSA-N	35	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
190	62233e39-164c-44df-aaa1-259ca11f2f96	VQNVZLDDLJBKNS-UHFFFAOYSA-N	36	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
191	95dd9c1c-c6ed-4cbf-83a3-14096e535bcf	VMLAEGAAHIIWJX-UHFFFAOYSA-N	37	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
192	8dd1c33b-e5c0-4d33-a7bd-4fc5b3d0023f	JBOIAZWJIACNJF-UHFFFAOYSA-N	38	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
193	b52a929a-e044-4308-86e7-42b73bbcad12	RFYSBVUZWGEPBE-UHFFFAOYSA-N	39	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
194	4f0a0baf-a6ef-40d8-bd24-abe33f29de45	FCTHQYIDLRRROX-UHFFFAOYSA-N	40	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
195	5f1eb322-0d97-4b3b-8c32-70778cce3729	UZHWWTHDRVLCJU-UHFFFAOYSA-N	41	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
196	feb87706-3ae4-4a89-bb07-d7f0b36bf035	MCEUZMYFCCOOQO-UHFFFAOYSA-L	42	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
197	8e048420-ddaf-49be-8b1a-1d63c4057df6	ZASWJUOMEGBQCQ-UHFFFAOYSA-L	43	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
198	d4b99fae-cfee-48be-90cb-ffb0965c4109	ISWNAMNOYHCTSB-UHFFFAOYSA-N	44	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
199	5ff9692a-dabb-462a-b76e-a5fdea472058	VAWHFUNJDMQUSB-UHFFFAOYSA-N	45	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
200	7ea9b49a-a418-4844-84e8-b629367494d7	VZXFEELLBDNLAL-UHFFFAOYSA-N	46	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
201	ba3d8ad3-f383-45bb-9742-317965b7e535	PXWSKGXEHZHFJA-UHFFFAOYSA-N	47	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
202	f093f36c-3abc-4b7d-a196-99918a6f0d81	VNAAUNTYIONOHR-UHFFFAOYSA-N	48	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
203	29edc0c0-02f2-4775-8368-dac9f49c46a2	HBZSVMFYMAOGRS-UHFFFAOYSA-N	49	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
204	68f9a1ab-c100-4c55-b0ec-8697bfc7e4a5	FEUPHURYMJEUIH-UHFFFAOYSA-N	50	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
205	165423aa-5c44-41e6-86f4-1ba55387fb3c	CQWGDVVCKBJLNX-UHFFFAOYSA-N	51	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
206	40ede866-41bb-4ebf-a5d0-afdd548e58cb	IRAGENYJMTVCCV-UHFFFAOYSA-N	52	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
207	1eb4e8e1-4ec9-4652-b788-8b09c28d5a15	UXWKNNJFYZFNDI-UHFFFAOYSA-N	53	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
208	84448dea-1209-470b-9f06-493c63366376	QZCGFUVVXNFSLE-UHFFFAOYSA-N	54	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
209	e209df89-7a82-421e-9916-aef892421b23	HBPSMMXRESDUSG-UHFFFAOYSA-N	55	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
210	d50faa01-440f-4895-aec6-3281ec18a4e4	IMROMDMJAWUWLK-UHFFFAOYSA-N	56	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
211	62ad650c-2e69-46dd-9102-282b32d92349	QNBVYCDYFJUNLO-UHDJGPCESA-N	57	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
212	95a25ed7-b380-4b74-bcb4-4e54be173a65	UMDDLGMCNFAZDX-UHFFFAOYSA-O	58	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
213	4ab45d6c-94df-48ad-a3ae-28b6411cab34	VFDOIPKMSSDMCV-UHFFFAOYSA-N	59	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
214	358d2eb5-4aee-4cf1-bad2-28c9ffb85230	DMFMZFFIQRMJQZ-UHFFFAOYSA-N	60	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
215	7153a17e-b8ed-47f5-b03e-d572e39a34b4	DYEHDACATJUKSZ-UHFFFAOYSA-N	61	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
216	9c6e2ab4-0acd-4b25-aedf-ad4fa97ea47a	LYHPZBKXSHVBDW-UHFFFAOYSA-N	62	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
217	7c1755ed-859d-4af6-b0bf-a8ccd8c986e9	UXYJHTKQEFCXBJ-UHFFFAOYSA-N	63	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
218	b1dddfdd-154a-4582-9c29-ab29ebbb6373	BJDYCCHRZIFCGN-UHFFFAOYSA-N	64	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
219	f118bd16-7da6-45bc-b5e6-894d08961111	ZEVRFFCPALTVDN-UHFFFAOYSA-N	65	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
220	140ad9f0-0442-4f66-b052-db6dff10fd68	WGYRINYTHSORGH-UHFFFAOYSA-N	66	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
221	37ce60b2-5d0f-4999-bf9c-21862ff68b02	XZUCBFLUEBDNSJ-UHFFFAOYSA-N	67	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
222	35833747-31e2-4b83-9a34-a87fb7bee28b	RYYSZNVPBLKLRS-UHFFFAOYSA-N	68	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
223	ae5bfe62-ca78-4379-8e4a-97ddd5d99cab	DWOWCUCDJIERQX-UHFFFAOYSA-M	69	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
224	044c75e4-b736-4073-9741-23d8a0ec018a	YYMLRIWBISZOMT-UHFFFAOYSA-N	70	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
225	08b641e6-7c10-4ba3-8aad-b43ae8d6edb5	UVLZLKCGKYLKOR-UHFFFAOYSA-N	71	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
226	62c62863-b0a3-4625-ad27-ea89796ae94a	BAMDIFIROXTEEM-UHFFFAOYSA-N	72	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
227	5b840e14-7d1c-4398-866f-c54d91063105	JERSPYRKVMAEJY-UHFFFAOYSA-N	73	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
228	bf5be158-c523-4d8f-b0de-acd7145e6d87	NXRUEVJQMBGVAT-UHFFFAOYSA-N	74	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
229	82daa4b6-b3cb-432d-b905-9e2ae32345f2	PBGZCCFVBVEIAS-UHFFFAOYSA-N	75	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
230	94ecc73a-589c-4521-b45c-d718e8f3163a	QNNYEDWTOZODAS-UHFFFAOYSA-N	76	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
231	4f6fb692-fe81-4b8e-88db-cda67148aafe	WGWKNMLSVLOQJB-UHFFFAOYSA-N	77	InChiKey	\N	\N	2019-12-06 18:35:16.710851+00	2019-12-06 18:35:16.710851+00
232	f19937d0-ffcb-4b79-8809-c16be93ad2fa	C1CC(=O)OC1	1	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
233	1856e419-75d3-4a27-995c-21e020de9942	CS(=O)C	2	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
234	d801ee68-4ad4-4740-a0f2-cf8490e7eab8	C(=O)O	3	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
235	97bfd912-b83e-4b01-9290-c1347d492428	I[Pb]I	4	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
236	51711994-be08-4f80-89d6-2d2ab11d2a24	CC[NH3+].[I-]	5	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
237	3cfd0853-a54c-4336-9cf3-c9cfb3646bee	C[NH3+].[I-]	6	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
238	a849f1f9-458c-4336-a857-a3d397f727d8	C1=CC=C(C=C1)CC[NH3+].[I-]	7	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
239	a95b4cec-b91d-466e-98d1-dab198a11ccb	CC(=[NH2+])N.[I-]	8	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
240	ad5138f0-a1f0-4f70-b238-b0a2be328a9c	CCCC[NH3+].[I-]	9	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
241	bad4b609-8acc-460c-ac8f-821ad0848a6e	C(=[NH2+])(N)N.[I-]	10	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
242	5b635d15-02a6-4f90-8dc4-89480921885e	C(Cl)Cl	11	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
243	e1efe4b2-a13f-4a4a-b52d-7f50386c1838	C[NH2+]C.[I-]	12	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
244	d3d036b0-f17b-4b8a-af02-e7efa9a6ea8b	C1=CC=C(C=C1)[NH3+].[I-]	13	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
245	04335818-19b1-4fb0-9856-6b3ee49c8195	CC(C)(C)[NH3+].[I-]	14	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
246	d48f7561-b8a3-4aa5-ac63-52a2e61b718b	[I-].[NH3+]CCC	15	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
247	b55659e3-7999-495f-bd22-68784846fbfc	C(=N)[NH3+].[I-]	16	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
248	e6a52d44-f9d3-4d4e-a396-5baa7485d91f	C1C[NH+]2CC[NH+]1CC2.[I-].[I-]	17	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
249	9ff62470-e9e2-4c2e-84ad-431a348d215b	C1(=CC=C(C=C1)F)C[NH3+].[I-]	18	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
250	6f791587-dc60-4cc2-aa6d-4466703f9d7f	C1(=CC=C(C=C1)F)CC[NH3+].[I-]	19	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
251	f2706c19-c497-4dcd-abbc-de7739713016	C1(=CC=C(C=C1)F)[NH3+].[I-]	20	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
252	f541c6ba-90fb-4cdb-aaec-b3088b78070e	C1(=CC=C(C=C1)OC)[NH3+].[I-]	21	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
253	c943549d-74a4-41e7-b81e-0f69e8ad8650	C1(=CC=C(C=C1)C(F)(F)F)C[NH3+].[I-]	22	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
254	61de3586-6d67-487b-9558-9dc5ca880d88	C1(=CC=C(C=C1)C(F)(F)F)[NH3+].[I-]	23	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
255	89864139-c529-47d4-b1f6-4c2e98989109	C1=CC=C(C=C1)Cl	24	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
256	4bbc6db2-dbb1-4ac4-94f8-8b0135b88782	CC(=[NH2+])N.[Br-]	25	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
257	04621bd4-7de9-4ccb-9576-74a3d4980ec6	C1=CC=C(C=C1)C[NH3+].[Br-]	26	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
258	8f5c9725-7c87-4814-abfc-40d5206a0d42	C1=CC=C(C=C1)C[NH3+].[I-]	27	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
259	84f265d4-487c-4905-9bbe-6a2991538d11	[I-].[NH3+]CCC(O)=O	28	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
260	01758e3b-1026-4cc1-b700-b60a3935098a	I[Bi](I)I	29	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
261	b714421a-9a67-4f58-879d-0ee5900491ef	[I-].[Cs+]	30	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
262	1cc5ce9d-2e9b-466b-a8d3-8afbf5cfde43	CN(C)C=O	31	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
263	931d90b1-cecd-4ef2-b31d-86c884de4322	C(C[NH3+])[NH3+].[Br-].[Br-]	32	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
264	96be5400-1cd5-4456-bbfa-2c79d5d76f3e	C(C[NH3+])[NH3+].[I-].[I-]	33	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
265	dda65e9c-3bec-4c4b-9d9e-9584ea234543	CC[NH3+].[Br-]	34	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
266	94d0d3e4-9310-422c-8b3f-7042c7ffcb56	C(=[NH2+])N.[Br-]	35	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
267	42e5e08f-dbc0-4366-ae27-53606eba289f	C(=[NH2+])(N)N.[Br-]	36	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
268	6daba15a-b034-4f0c-9ee4-7dbeec1944d7	CC(C)[NH3+].[I-]	37	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
269	8d8c4a39-01fb-4f1a-b8ed-72788b444677	C1=CN=C[NH2+]1.[I-]	38	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
270	12fa0404-976a-4866-b1dc-eadf63615e61	CC(C)C[NH3+].[Br-]	39	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
271	83c6fbf7-f6f3-4b7b-8f0c-4c3f740f668d	[I-].CC(C)C[NH3+]	40	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
272	7cea0687-0a93-40d4-80af-913ddf404046	CC(CC[NH3+])C.[I-]	41	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
273	63e3ccfc-027e-42f5-bfae-80867b8f1c88	CC(=O)O[Pb]OC(=O)C.O.O.O	42	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
274	a1fa7c50-347a-46b4-a2ba-2cd5ce8d117f	Br[Pb]Br	43	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
275	7eb60c15-4125-4fdf-8b10-24f72adbdab8	C[NH3+].[Br-]	44	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
276	86616e21-7d2b-471d-b754-a8f2e86604e0	C1COCC[NH2+]1.[I-]	45	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
277	ef8dce64-b6e6-4ca2-aba6-72f76955be65	CCCCCCCCCCCC[NH3+].[Br-]	46	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
278	8b4c72f5-3a15-46bb-88d5-a8531086ca0e	[I-].CCCCCCCCCCCC[NH3+]	47	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
279	b861659d-a5bf-466a-a7fd-913f2a30b55b	CCCCCC[NH3+].[I-]	48	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
280	31c6cba4-3e27-4ee3-93fe-51349d3f1b01	CCCCCCCC[NH3+].[I-]	49	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
281	90b870a5-63e9-4090-b72d-ae9152e7d73b	CC(C)(C)C[NH3+].[Br-]	50	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
282	0f0328e5-63c3-4286-9d7b-e0876d4d2337	[I-].CC(C)(C)C[NH3+]	51	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
283	9dfb059a-942d-4f7f-8b11-522bd9f1f17e	c1ccc(cc1)CC[NH3+].[Br-]	52	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
284	26d13485-ac28-4682-b16a-1053b8df049f	C1C[NH2+]CC[NH2+]1.[Br-].[Br-]	53	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
285	0532d21f-6258-4658-882e-69f443c3cfb9	[I-].[I-].C1C[NH2+]CC[NH2+]1	54	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
286	762ed820-1a44-4f74-9705-b4494f38ccd1	C1CC[NH2+]CC1.[I-]	55	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
287	a10f683a-d907-4fcb-8993-577d932ec76d	C{-}(OC(=O)C)C{n+}	56	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
288	3a45c2df-8f66-429a-8ecc-91be32d4933a	CN1C=CC=CC1=C[NH+]=O.[I-]	57	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
289	b9f93573-49d1-44a8-90a9-6d69431b7eb5	[NH3+]CCC[NH3+].[I-].[I-]	58	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
290	cece141f-e307-481b-a39a-4b4e9e8c0db4	C1CC[NH2+]C1.[Br-]	59	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
291	5c6f3685-3698-4f0d-8ea1-dd4c9b7d5a90	C1CC[NH2+]C1.[I-]	60	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
292	d400cfa8-e3d5-4201-902d-a9c650d2a471	C1C[NH+]2CCC1CC2.[Br-]	61	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
293	77f29553-70b1-4380-9d1e-25641c6786d8	C1C[NH+]2CCC1CC2.[I-]	62	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
294	d50d3f41-1bea-4c75-9db7-4d45d4ed4324	C(CC(C)(C)[NH3+])(C)(C)C.[I-]	63	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
295	103e81a1-8c16-472b-a6aa-4614d5b968c7	C1=CC=[NH+]C=C1.[I-]	64	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
296	973ea616-5a46-4677-9ec6-97e1db005e11	C1CCC(CC1)C[NH3+].[I-]	65	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
297	d5748876-3cbd-4f74-9c03-8d8ca1c563ca	C1CCC(CC1)[NH3+].[I-]	66	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
298	423ed52c-fa5e-4e15-b64c-2094db308fce	C(CC[NH3+])C[NH3+].[I-].[I-]	67	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
299	c76e16eb-2e15-42bd-a44a-c50de4ebf29c	C1=CC(=CC=C1[NH3+])[NH3+].[I-].[I-]	68	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
300	e1c86721-b4c0-45b3-ab26-05156e337a8a	C1CC[N+]2(C1)CCCC2.[I-]	69	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
301	afb33ae5-3731-4e8f-abe4-08cee081b477	CC[NH2+]CC.[I-]	70	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
302	6acbc97a-c5f6-4992-b839-eec65b8a53ac	C1CC[NH+](C1)CC[NH3+].[I-].[I-]	71	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
303	6646aa8d-e723-4e33-b9c0-40b24f30afe4	C[NH+](C)CC[NH3+].[I-].[I-]	72	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
304	900fd8c6-6381-4f92-8a30-d47ed1463135	C[NH+](C)CCC[NH3+].[I-].[I-]	73	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
305	aabb7baf-1427-44a9-9df6-3a0e4cc7ecd5	CC[NH+](CC)CCC[NH3+].[I-].[I-]	74	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
306	05d6da81-a529-49ee-a6b9-2649d657c565	CC(C)[NH2+]C(C)C.[I-]	75	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
307	7b7cb7ed-8a25-4131-ac75-2f1b83ec515b	[I-].[NH3+](CCC1=CC=C(C=C1)OC)	76	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
308	1d114387-2672-4f1a-93f9-b628c29b21bf	CC(C)[NH3+].[Br-]	77	SMILES	\N	\N	2019-12-06 18:35:16.713392+00	2019-12-06 18:35:16.713392+00
309	7af020c8-c330-4d0b-b243-643665f225b5	C4H6O2	1	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
310	8a66d177-4be7-4b25-b7f3-74ba002a1fb4	C2H6OS	2	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
311	dbbd1ff5-4ce7-450d-b445-f22f46c3583f	CH2O2	3	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
312	5d14cfe8-3466-4d57-a4d5-6be536495849	PbI2	4	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
313	986caf3a-7b9d-405b-9087-9424557dfb26	C2H8IN	5	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
314	bae09871-5f57-4bd4-9a3c-67ea3b6e43aa	CH6IN	6	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
315	ff6f8ced-4e1d-4873-b062-8d24a98fe1a5	C8H12IN	7	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
316	604aaac3-2917-4894-bbb3-d899f1c9cc89	C2H7IN2	8	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
317	931adf94-aa16-4bad-9042-0d1d7b762f7e	C4H12IN	9	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
318	bc6e759a-e56f-4a07-a42c-05b558e13db6	CH6IN3	10	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
319	c10215a5-f201-4e65-a099-8e1b7f817015	CH2Cl2	11	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
320	ed7c0a8a-2d7d-458c-9391-166cb16441d7	C2H8IN	12	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
321	90cf44a4-ac89-4d4b-9d92-ece1eda6edd1	C6H8IN	13	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
322	696ff60f-f41f-4a0f-a02f-0d7020e461db	C4H12IN	14	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
323	4066fd50-9fdb-4936-a2f1-656acb462d66	C3H10IN	15	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
324	b193d83f-bca9-4dd6-b19c-c5d923c639cb	CH5IN2	16	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
325	0cad335e-bdfe-402f-8e49-d43bfcf35bd6	C6H14I2N2	17	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
326	9925ce4f-f465-4cfd-ac67-54376526d6f7	C7H9FIN	18	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
327	676bd5f9-adf5-4f46-8307-13332f3c3b0e	C8H11FIN	19	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
328	cc82f7f1-0452-4606-bcb3-41f45cb8dd7d	C6H7FIN	20	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
329	2ade752c-b37e-446c-931a-7bd818bcdf1c	C7H10INO	21	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
330	1da4bea8-cf18-4812-ab90-195ba962aa1b	C8H9F3IN	22	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
331	6b9381c6-4a28-4497-ae95-de73bdc01eb5	C7H7F3IN	23	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
332	16eb0707-09a9-44eb-a2c2-b269b805536b	C6H5Cl	24	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
333	23843077-27b6-4c77-96d2-b9d94daf1370	C2H7BrN2	25	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
334	3ff58e9f-8985-4398-87fe-b8b44a82447a	C7H10BrN	26	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
335	d29662ee-c7d1-44e9-9371-6f613161c2b7	C7H10IN	27	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
336	688b7a72-0e83-4d60-9bd8-af80bce3c233	\N	28	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
337	998bdbed-f215-48a5-94d5-fb00c1220208	BiI3	29	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
338	1973b82b-6328-4663-b5ca-7a1d6454b894	CsI	30	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
339	eccec05b-b9fe-401b-9a17-abdf6c1e9ddf	C3H7NO	31	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
340	787ba75c-ded0-4556-8bda-4711a131797a	C2H10Br2N2	32	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
341	39e465ef-19d0-4e18-b506-bbb6269825ba	C2H10I2N2	33	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
342	6c050576-fa6c-40e3-bc5b-547dae7a4558	C2H8BrN	34	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
343	3a3512e0-ecad-4400-8dc4-3e899e3f7823	CH5BrN2	35	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
344	dc75b911-9c87-4684-baf0-3dac9c29a3d6	CH6BrN3	36	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
345	0984f5bb-d14a-4af9-8a12-002e95538398	C3H10IN	37	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
346	efbb7396-81e4-4840-9859-59498c901c40	C3H5IN2	38	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
347	a7e70fdc-a175-41c7-965a-b480f663d64f	C4H12BrN	39	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
348	bd0ebae3-841d-4fe3-a6f5-38e028d23dc8	C4H12IN	40	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
349	c351481b-b693-4d3f-b750-63f85e013482	C5H14IN	41	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
350	abcba647-67f9-460a-b1aa-db6e1160c6f5	C4H12O7Pb	42	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
351	1a86bc8c-4bbd-4901-a221-e052c23ecbe9	PbBr2	43	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
352	0d610e32-5099-4dd7-b492-7cfc58e5cd67	CH6BrN	44	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
353	0ebf312a-93e3-4240-8efe-656d770b7f3a	C4H10INO	45	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
354	8286a0ee-9e85-4cc6-ab16-b9a8404ad95c	C12H28BrN	46	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
355	fbabe2ef-dbba-431d-89c7-70251301bffd	C12H28IN	47	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
356	8baeb3f7-2d7a-40f3-b2bb-15e83ae207a2	C6H16IN	48	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
357	3715c532-a182-4e66-a24f-dc75332401bb	C8H20IN	49	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
358	a6a143d9-b536-4c58-809e-1c9a34231360	C5H14BrN	50	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
359	b4767524-a98a-4295-9eff-0c480b87af82	C5H14IN	51	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
360	b0fbc9d3-09a5-4c68-b834-abffcdc31c54	C8H12BrN	52	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
361	866d0395-599d-4fcd-bb0b-6c4b819403ca	C4H12Br2N2	53	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
362	2a647c2e-973e-4299-a7fa-e369f91e5850	\N	54	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
363	21b37445-c87f-4300-adb0-534703aac685	C5H12IN	55	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
364	7c62cdfc-645d-436c-b87e-b3b902f89ee1	C2H4O	56	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
365	45da165f-e523-4243-858b-e8555a3847b7	C7H9IN2O	57	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
366	4fafcbe4-0a40-43b6-b9bf-5e606b8eddda	C3H12IN2	58	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
367	9ea72b8e-1849-4eb8-92ca-4b0b5a9fb958	C4H10BrN	59	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
368	46abff06-a314-440c-86ed-f22f2e232fb4	C4H10IN	60	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
369	53a15335-76d0-4cf9-80c5-b12da2053446	C7H14BrN	61	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
370	1f142050-a437-4075-ae22-701dac6d02a2	\N	62	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
371	e78342f9-2f86-4796-b08a-e565ecfa8bd2	C8H20IN	63	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
372	5305d24a-d863-4607-8e34-323f92ec495a	C5H6IN	64	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
373	cd7fd4e2-ea1c-4727-8088-de2a9d3cc499	C7H16IN	65	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
374	2fc5d42b-d189-4e76-bef4-1d07dd6de485	C6H14IN	66	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
375	0d89d9d6-fda0-4cf8-b0c3-d14941c02107	C4H14I2N2	67	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
376	36834e90-a41c-4c9b-a879-5f0ca8b3ca29	C6H10I2N2	68	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
377	15f4f73e-5fc9-4a08-a074-ba6a537e5508	C8H16IN	69	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
378	93e95514-1b7d-48ac-8f1c-ebdccee476a4	C4H12IN	70	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
379	a9d53555-1888-42a8-a215-1f54fb2c9b3c	C6H16I2N2	71	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
380	bc5a4999-fe92-475b-ba05-65bf85afaab2	C4H14I2N2	72	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
381	6bee8423-d50e-4622-8886-264263bc4905	C5H16I2N2	73	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
382	047e2e25-7b5e-4f2e-b141-888fc6451206	C7H20I2N2	74	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
383	c9740172-5756-449d-b661-7c080b41d88c	C6H16IN	75	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
384	375ca144-aaf1-4c61-a55d-6422ae91ba2d	\N	76	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
385	9c7607d8-4108-4b52-a203-d6476a6ba38a	C3H10BrN	77	Molecular Formula	\N	\N	2019-12-06 18:35:16.715988+00	2019-12-06 18:35:16.715988+00
\.


--
-- TOC entry 3536 (class 0 OID 27933)
-- Dependencies: 345
-- Data for Name: edocument; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.edocument (edocument_id, edocument_uuid, description, edocument, edoc_type, ver, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3528 (class 0 OID 27894)
-- Dependencies: 337
-- Data for Name: inventory; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.inventory (inventory_id, inventory_uuid, material_id, actor_id, measure_id, create_dt, expiration_dt, inventory_location, note_id, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3499 (class 0 OID 24971)
-- Dependencies: 228
-- Data for Name: load_chem_inventory; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.load_chem_inventory ("ChemicalName", "ChemicalAbbreviation", "MolecularWeight", "Density", "InChI", "InChIKey", "ChemicalCategory", "CanonicalSMILES", "MolecularFormula", "PubChemID", "CatalogDescr", "Synonyms", "CatalogNo", "Sigma-Aldrich URL", "PrimaryInformationSource") FROM stdin;
Gamma-Butyrolactone	GBL	86.09	1.12	InChI=1S/C4H6O2/c5-4-2-1-3-6-4/h1-3H2	YEJRWHAVMIAJKC-UHFFFAOYSA-N	solvent	C1CC(=O)OC1	C4H6O2	\N	\N	\N	Spectrum 1Kg bottle	\N	(note: there is also a 3Kg bottle version: product ID id:jLq9jXvYvnwz)
Dimethyl sulfoxide	DMSO	78.129	1.1	InChI=1S/C2H6OS/c1-4(2)3/h1-2H3	IAZDPXIOMUYVGZ-UHFFFAOYSA-N	solvent	CS(=O)C	C2H6OS	\N	\N	\N	\N	\N	\N
Formic Acid	FAH	46.025	1.22	InChI=1S/CH2O2/c2-1-3/h1H,(H,2,3)	BDAGIHXWWSANSR-UHFFFAOYSA-N	acid	C(=O)O	CH2O2	\N	Formic acid, reagent grade, 1L	\N	Sigma:F0507-1L	\N	\N
Lead Diiodide	PbI2	461.01	6.16	InChI=1S/2HI.Pb/h2*1H;/q;;+2/p-2	RQQRAHKHDFPBMC-UHFFFAOYSA-L	inorganic	I[Pb]I	PbI2	\N	Lead(II) iodide 99%, 50g	\N	Sigma:211168-50G	\N	\N
Ethylammonium Iodide	EtNH3I	173	2.053408	InChI=1S/C2H7N.HI/c1-2-3;/h2-3H2,1H3;1H	XFYICZOIWSBQSK-UHFFFAOYSA-N	organic	CC[NH3+].[I-]	C2H8IN	57461411	Ethylammonium Iodide 98%, 25g	\N	Sigma:805823-25G	\N	\N
Methylammonium iodide	MeNH3I	158.97	2.341498	InChI=1S/CH5N.HI/c1-2;/h2H2,1H3;1H	LLWRXQXPJMPHLR-UHFFFAOYSA-N	organic	C[NH3+].[I-]	CH6IN	SID329769003	Methylammonium iodide	Methylammonium iodide, "Methanamine hydroiodide", "Methanaminium \\	Sigma: 806390-25G	https://www.sigmaaldrich.com/catalog/product/aldrich/806390?lang=en&region=US	PubChem
Phenethylammonium iodide 	PhEtNH3I	249.095	1.630204	InChI=1S/C8H11N.HI/c9-7-6-8-4-2-1-3-5-8;/h1-5H,6-7,9H2;1H	UPHCENSIMPJEIS-UHFFFAOYSA-N	organic	C1=CC=C(C=C1)CC[NH3+].[I-]	C8H12IN	SID329768971	Phenethylammonium iodide	\N	Sigma:805904-25G	https://www.sigmaaldrich.com/catalog/product/aldrich/805904?lang=en&region=US	\N
Acetamidinium iodide	AcNH3I	185.96539	2.176639	InChI=1S/C2H6N2.HI/c1-2(3)4;/h1H3,(H3,3,4);1H	GGYGJCFIYJVWIP-UHFFFAOYSA-N	organic	CC(=[NH2+])N.[I-]	C2H7IN2	SID329768980	\N	\N	Sigma:805971-25G	\N	PubChem
n-Butylammonium iodide	n-BuNH3I	201.051	1.686302	InChI=1S/C4H11N.HI/c1-2-3-4-5;/h2-5H2,1H3;1H	CALQKRVFTWDYDG-UHFFFAOYSA-N	organic	CCCC[NH3+].[I-]	C4H12IN	\N	\N	\N	Sigma: 805874-25G	https://www.sigmaaldrich.com/catalog/product/aldrich/805874	\N
Guanidinium iodide	GnNH3I	186.98	2.359388	InChI=1S/CH5N3.HI/c2-1(3)4;/h(H5,2,3,4);1H	UUDRLGYROXTISK-UHFFFAOYSA-N	organic	C(=[NH2+])(N)N.[I-]	CH6IN3	\N	Guanidinium iodide 99%	iodide", "Methylamine hydriodide", "Monomethylammonium iodide"	Sigma:806056-25G	https://www.sigmaaldrich.com/catalog/product/aldrich/806056?lang=en&region=US	PubChem
Dichloromethane	DCM	84.93	1.33	InChI=1S/CH2Cl2/c2-1-3/h1H2	YMWUJEATGCHHMB-UHFFFAOYSA-N	solvent	C(Cl)Cl	CH2Cl2	\N	\N	\N	\N	\N	\N
Dimethylammonium iodide	Me2NH2I	172.97014	2.03749	InChI=1S/C2H7N.HI/c1-3-2;/h3H,1-2H3;1H	JMXLWMIFDJCGBV-UHFFFAOYSA-N	organic	C[NH2+]C.[I-]	C2H8IN	\N	\N	\N	greatcell: MS111100-100	\N	https://pubchem.ncbi.nlm.nih.gov/compound/12199010
Phenylammonium Iodide	PhenylammoniumIodide	221.041	1.888168	InChI=1S/C6H7N.HI/c7-6-4-2-1-3-5-6;/h1-5H,7H2;1H	KFQARYBEAKAXIC-UHFFFAOYSA-N	organic	C1=CC=C(C=C1)[NH3+].[I-]	C6H8IN	6450296	\N	\N	\N	\N	\N
t-Butylammonium Iodide	tButylammoniumIodide	201.00144	1.681204	InChI=1S/C4H11N.HI/c1-4(2,3)5;/h5H2,1-3H3;1H	NLJDBTZLVTWXRG-UHFFFAOYSA-N	organic	CC(C)(C)[NH3+].[I-]	C4H12IN	22344722	\N	\N	MS106000-10; sigma: 806102-5G	https://www.sigmaaldrich.com/catalog/product/aldrich/806102?lang=en&region=US	https://pubchem.ncbi.nlm.nih.gov/compound/22344722
N-propylammonium Iodide	NPropylammoniumIodide	186.98579	1.843205	InChI=1S/C3H9N.HI/c1-2-3-4;/h2-4H2,1H3;1H	GIAPQOZCVIEHNY-UHFFFAOYSA-N	organic	[I-].[NH3+]CCC	C3H10IN	\N	\N	\N	\N	\N	\N
Formamidinium Iodide	FormamidiniumIodide	171.97	2.423927	InChI=1S/CH4N2.HI/c2-1-3;/h1H,(H3,2,3);1H	QHJPGANWSLEMTI-UHFFFAOYSA-N	organic	C(=N)[NH3+].[I-]	CH5IN2	\N	\N	\N	greatcell: MS-150000-100	https://www.sigmaaldrich.com/catalog/product/aldrich/806048?lang=en&region=US	PubChem
1,4-Diazabicyclo[2,2,2]octane-1,4-diium Iodide	Dabcoiodide	368	2.1888	InChI=1S/C6H12N2.2HI/c1-2-8-5-3-7(1)4-6-8;;/h1-6H2;2*1H	WXTNTIQDYHIFEG-UHFFFAOYSA-N	organic	C1C[NH+]2CC[NH+]1CC2.[I-].[I-]	C6H14I2N2	129880796	\N	\N	\N	\N	\N
4-Fluoro-Benzylammonium iodide	4FluoroBenzylammoniumIodide	253.058	1.864177	InChI=1S/C7H8FN.HI/c8-7-3-1-6(5-9)2-4-7;/h1-4H,5,9H2;1H	LCTUISCIGMWMAT-UHFFFAOYSA-N	organic	C1(=CC=C(C=C1)F)C[NH3+].[I-]	C7H9FIN	\N	\N	\N	\N	\N	\N
4-Fluoro-Phenethylammonium iodide	4FluoroPhenethylammoniumIodide	266.99202	1.740239	InChI=1S/C8H10FN.HI/c9-8-3-1-7(2-4-8)5-6-10;/h1-4H,5-6,10H2;1H	NOHLSFNWSBZSBW-UHFFFAOYSA-N	organic	C1(=CC=C(C=C1)F)CC[NH3+].[I-]	C8H11FIN	\N	\N	\N	\N	\N	\N
4-Fluoro-Phenylammonium iodide	4FluoroPhenylammoniumIodide	239.031	2.014867	InChI=1S/C6H6FN.HI/c7-5-1-3-6(8)4-2-5;/h1-4H,8H2;1H	FJFIJIDZQADKEE-UHFFFAOYSA-N	organic	C1(=CC=C(C=C1)F)[NH3+].[I-]	C6H7FIN	\N	\N	\N	\N	\N	\N
4-Methoxy-Phenylammonium iodide	4MethoxyPhenylammoniumIodide	251.067	1.771191	InChI=1S/C7H9NO.HI/c1-9-7-4-2-6(8)3-5-7;/h2-5H,8H2,1H3;1H	QRFXELVDJSDWHX-UHFFFAOYSA-N	organic	C1(=CC=C(C=C1)OC)[NH3+].[I-]	C7H10INO	\N	\N	\N	\N	\N	\N
4-Trifluoromethyl-Benzylammonium iodide	4TrifluoromethylBenzylammoniumIodide	303.065	1.938294	InChI=1S/C8H8F3N.HI/c9-8(10,11)7-3-1-6(5-12)2-4-7;/h1-4H,5,12H2;1H	SQXJHWOXNLTOOO-UHFFFAOYSA-N	organic	C1(=CC=C(C=C1)C(F)(F)F)C[NH3+].[I-]	C8H9F3IN	\N	\N	\N	\N	\N	\N
4-Trifluoromethyl-Phenylammonium iodide	4TrifluoromethylPhenylammoniumIodide	289.039	2.074383	InChI=1S/C7H6F3N.HI/c8-7(9,10)5-1-3-6(11)4-2-5;/h1-4H,11H2;1H	KOAGKPNEVYEZDU-UHFFFAOYSA-N	organic	C1(=CC=C(C=C1)C(F)(F)F)[NH3+].[I-]	C7H7F3IN	\N	\N	\N	\N	\N	\N
chlorobenzene	CBz	112.56	1.11	InChI=1S/C6H5Cl/c7-6-4-2-1-3-5-6/h1-5H	MVPPADPHJFYWMZ-UHFFFAOYSA-N	solvent	C1=CC=C(C=C1)Cl	C6H5Cl	\N	\N	\N	\N	\N	\N
Acetamidinium bromide	AcNH3Br	138.99	1.819847	InChI=1S/C2H6N2.BrH/c1-2(3)4;/h1H3,(H3,3,4);1H	CWJKVUQGXKYWTR-UHFFFAOYSA-N	organic	CC(=[NH2+])N.[Br-]	C2H7BrN2	44255193	\N	\N	\N	\N	\N
Benzylammonium Bromide	benzylammoniumbromide	188.07	1.530173	InChI=1S/C7H9N.BrH/c8-6-7-4-2-1-3-5-7;/h1-5H,6,8H2;1H	QJFMCHRSDOLMHA-UHFFFAOYSA-N	organic	C1=CC=C(C=C1)C[NH3+].[Br-]	C7H10BrN	12998568	\N	\N	Sigma: 900885-5G	https://www.sigmaaldrich.com/catalog/product/aldrich/900885?lang=en&region=US	https://pubchem.ncbi.nlm.nih.gov/compound/12998568
Benzylammonium Iodide	BenzylammoniumIodide	235.068	1.745993	InChI=1S/C7H9N.HI/c8-6-7-4-2-1-3-5-7;/h1-5H,6,8H2;1H	PPCHYMCMRUGLHR-UHFFFAOYSA-N	organic	C1=CC=C(C=C1)C[NH3+].[I-]	C7H10IN	\N	Benzylammonium Iodide	\N	Sigma: 806196-25G	https://www.sigmaaldrich.com/catalog/product/aldrich/806196?lang=en&region=US	PubChem
Beta Alanine Hydroiodide	betaAlanineHydroiodide	217.01	2.023364	InChI=1S/C3H7NO2.HI/c4-2-1-3(5)6;/h1-2,4H2,(H,5,6);1H	XAKAQFUGWUAPJN-UHFFFAOYSA-N	organic	[I-].[NH3+]CCC(O)=O	\N	\N	\N	\N	\N	\N	https://cactus.nci.nih.gov/chemical/structure/I.NCCC(O)=O/stdinchikey
Bismuth iodide	BiI3	589.694	5.78	InChI=1S/Bi.3HI/h;3*1H/q+3;;;/p-3	KOECRLKKXSXCPB-UHFFFAOYSA-K	inorganic	I[Bi](I)I	BiI3	\N	\N	\N	Sigma: 341010-100G	\N	https://pubchem.ncbi.nlm.nih.gov/compound/Bismuth_iodide#section=3D-Status
Cesium iodide	CsI	259.81	4.51	InChI=1S/Cs.HI/h;1H/q+1;/p-1	XQPRBTXUXXVTKB-UHFFFAOYSA-M	inorganic	[I-].[Cs+]	CsI	\N	\N	\N	Sigma: 203033-10G	\N	https://pubchem.ncbi.nlm.nih.gov/compound/24601
Dimethylformamide	DMF	73.095	0.944	InChI=1S/C3H7NO/c1-4(2)3-5/h3H,1-2H3	ZMXDDKWLCZADIW-UHFFFAOYSA-N	solvent	CN(C)C=O	C3H7NO	\N	Anhydrous DMF.  Note.  ECL maintains this as a stocked item, so we do not have to both with a product number	\N	\N	\N	\N
Ethane-1,2-diammonium bromide	EthylenediamineDihydrobromide	221.92	2.067161	InChI=1S/C2H8N2.2BrH/c3-1-2-4;;/h1-4H2;2*1H	BCQZYUOYVLJOPE-UHFFFAOYSA-N	organic	C(C[NH3+])[NH3+].[Br-].[Br-]	C2H10Br2N2	164699	\N	\N	greatcell: MS302002-10; sigma: 900833-25G	https://www.sigmaaldrich.com/catalog/product/aldrich/900833?lang=en&region=US	https://pubchem.ncbi.nlm.nih.gov/compound/Ethylenediamine-dihydrobromide
Ethane-1,2-diammonium iodide	EthylenediamineDihydriodide	315.925	2.544818	InChI=1S/C2H8N2.2HI/c3-1-2-4;;/h1-4H2;2*1H	IWNWLPUNKAYUAW-UHFFFAOYSA-N	organic	C(C[NH3+])[NH3+].[I-].[I-]	C2H10I2N2	\N	\N	\N	Sigma: 900852-25G	https://www.sigmaaldrich.com/catalog/product/aldrich/900852?lang=en&region=US	https://pubchem.ncbi.nlm.nih.gov/compound/5700-49-2#section=Names-and-Identifiers
Ethylammonium bromide	EtNH3Br	125.997	1.671914	InChI=1S/C2H7N.BrH/c1-2-3;/h2-3H2,1H3;1H	PNZDZRMOBIIQTC-UHFFFAOYSA-N	organic	CC[NH3+].[Br-]	C2H8BrN	\N	\N	\N	Sigma: 900868-10G	https://www.sigmaaldrich.com/catalog/product/aldrich/900868?lang=en&region=US	https://pubchem.ncbi.nlm.nih.gov/compound/68974
Formamidinium bromide	FABr	124.97	2.005249	InChI=1S/CH4N2.BrH/c2-1-3;/h1H,(H3,2,3);1H	QWANGZFTSGZRPZ-UHFFFAOYSA-N	organic	C(=[NH2+])N.[Br-]	CH5BrN2	89907631	\N	\N	Sigma: 900835-25G; GreatCellSolar: CAS RN: 146958-06-7	https://www.sigmaaldrich.com/catalog/product/aldrich/900835?lang=en&region=US	\N
Guanidinium bromide	GnNH3Br	139.984	1.999305	InChI=1S/CH5N3.BrH/c2-1(3)4;/h(H5,2,3,4);1H	VQNVZLDDLJBKNS-UHFFFAOYSA-N	organic	C(=[NH2+])(N)N.[Br-]	CH6BrN3	129656112	\N	\N	Sigma: 900839-10G	https://www.sigmaaldrich.com/catalog/product/aldrich/900839?lang=en&region=US	https://pubchem.ncbi.nlm.nih.gov/compound/71282
i-Propylammonium iodide	iPropylammoniumIodide	187.02	1.841935	InChI=1S/C3H9N.HI/c1-3(2)4;/h3H,4H2,1-2H3;1H	VMLAEGAAHIIWJX-UHFFFAOYSA-N	organic	CC(C)[NH3+].[I-]	C3H10IN	\N	\N	\N	greatcell: MS104000-100	https://www.sigmaaldrich.com/catalog/product/aldrich/805882?lang=en&region=US	https://pubchem.ncbi.nlm.nih.gov/compound/91972165#section=Top
Imidazolium Iodide	ImidazoliumIodide	195.991	2.34327	InChI=1S/C3H4N2.HI/c1-2-5-3-4-1;/h1-3H,(H,4,5);1H	JBOIAZWJIACNJF-UHFFFAOYSA-N	organic	C1=CN=C[NH2+]1.[I-]	C3H5IN2	\N	\N	\N	greatcell: MS-170000-100	\N	PubChem
iso-Butylammonium bromide	iButylammoniumBromide	154.05	1.414965	InChI=1S/C4H11N.BrH/c1-4(2)3-5;/h4H,3,5H2,1-2H3;1H	RFYSBVUZWGEPBE-UHFFFAOYSA-N	organic	CC(C)C[NH3+].[Br-]	C4H12BrN	89264112	\N	\N	greatcell: MS307000-10; sigma: 900869-10G	https://www.sigmaaldrich.com/catalog/product/aldrich/900869?lang=en&region=US	https://pubchem.ncbi.nlm.nih.gov/compound/89264112
iso-Butylammonium iodide	iButylammoniumIodide	201.05	1.682582	InChI=1S/C4H11N.HI/c1-4(2)3-5;/h4H,3,5H2,1-2H3;1H	FCTHQYIDLRRROX-UHFFFAOYSA-N	organic	[I-].CC(C)C[NH3+]	C4H12IN	\N	\N	\N	greatcell: MS107000-100	\N	https://cactus.nci.nih.gov/chemical/structure
iso-Pentylammonium iodide	IPentylammoniumIodide	215.01709	1.55959	InChI=1S/C5H13N.HI/c1-5(2)3-4-6;/h5H,3-4,6H2,1-2H3;1H	UZHWWTHDRVLCJU-UHFFFAOYSA-N	organic	CC(CC[NH3+])C.[I-]	C5H14IN	\N	\N	\N	\N	\N	\N
Lead(II) acetate trihydrate	LeadAcetate	379.33	2.55	InChI=1S/2C2H4O2.3H2O.Pb/c2*1-2(3)4;;;;/h2*1H3,(H,3,4);3*1H2;/q;;;;;+2/p-2	MCEUZMYFCCOOQO-UHFFFAOYSA-L	inorganic	CC(=O)O[Pb]OC(=O)C.O.O.O	C4H12O7Pb	16693916	\N	\N	Sigma: 467863-50G	https://www.sigmaaldrich.com/catalog/product/aldrich/467863?lang=en&\\region=US	\N
Lead(II) bromide	PbBr2	367.008	6.66	InChI=1S/2BrH.Pb/h2*1H;/q;;+2/p-2	ZASWJUOMEGBQCQ-UHFFFAOYSA-L	inorganic	Br[Pb]Br	PbBr2	\N	Object[Product,id:7X104vn698bk]	\N	Sigma: 211141-100G	\N	https://www.sigmaaldrich.com/catalog/product/aldrich/211141?lang=en&\\region=US
Methylammonium bromide	Methylammoniumbromide	111.97	1.883462	InChI=1S/CH5N.BrH/c1-2;/h2H2,1H3;1H	ISWNAMNOYHCTSB-UHFFFAOYSA-N	organic	C[NH3+].[Br-]	CH6BrN	\N	Methylammonium bromide	\N	Sigma: 806498-25G	https://www.sigmaaldrich.com/catalog/product/aldrich/806498?lang=en&region=US	\N
Morpholinium Iodide	MorpholiniumIodide	215.03	1.896504	InChI=1S/C4H9NO.HI/c1-3-6-4-2-5-1;/h5H,1-4H2;1H	VAWHFUNJDMQUSB-UHFFFAOYSA-N	organic	C1COCC[NH2+]1.[I-]	C4H10INO	12196071	\N	\N	MS110640-10	\N	https://pubchem.ncbi.nlm.nih.gov/compound/Morpholinium-iodide
n-Dodecylammonium bromide	nDodecylammoniumBromide	266.26	1.064263	InChI=1S/C12H27N.BrH/c1-2-3-4-5-6-7-8-9-10-11-12-13;/h2-13H2,1H3;1H	VZXFEELLBDNLAL-UHFFFAOYSA-N	organic	CCCCCCCCCCCC[NH3+].[Br-]	C12H28BrN	21872287	\N	\N	greatcell: MS300880	\N	https://pubchem.ncbi.nlm.nih.gov/compound/21872287#section=InChI
n-Dodecylammonium iodide	nDodecylammoniumIodide	313.26	1.128466	InChI=1S/C12H27N.HI/c1-2-3-4-5-6-7-8-9-10-11-12-13;/h2-13H2,1H3;1H	PXWSKGXEHZHFJA-UHFFFAOYSA-N	organic	[I-].CCCCCCCCCCCC[NH3+]	C12H28IN	\N	\N	\N	greatcell: MS100880-100	\N	https://cactus.nci.nih.gov/chemical/structure
n-Hexylammonium iodide	nHexylammoniumIodide	229.105	1.464001	InChI=1S/C6H15N.HI/c1-2-3-4-5-6-7;/h2-7H2,1H3;1H	VNAAUNTYIONOHR-UHFFFAOYSA-N	organic	CCCCCC[NH3+].[I-]	C6H16IN	\N	\N	\N	\N	\N	\N
n-Octylammonium Iodide	nOctylammoniumIodide	257.16	1.31499	InChI=1S/C8H19N.HI/c1-2-3-4-5-6-7-8-9;/h2-9H2,1H3;1H	HBZSVMFYMAOGRS-UHFFFAOYSA-N	organic	CCCCCCCC[NH3+].[I-]	C8H20IN	22461615	\N	Octyalazanium	MS105500-10	\N	https://pubchem.ncbi.nlm.nih.gov/compound/22461615
neo-Pentylammonium bromide	neoPentylammoniumBromide	168.08	1.330429	InChI=1S/C5H13N.BrH/c1-5(2,3)4-6;/h4,6H2,1-3H3;1H	FEUPHURYMJEUIH-UHFFFAOYSA-N	organic	CC(C)(C)C[NH3+].[Br-]	C5H14BrN	87350950	\N	2,2-Dimethylpropylazanium;bromide	greatcell: MS300740-10	\N	https://pubchem.ncbi.nlm.nih.gov/compound/87350950
neo-Pentylammonium iodide	neoPentylammoniumIodide	215.01709	1.555659	InChI=1S/C5H13N.HI/c1-5(2,3)4-6;/h4,6H2,1-3H3;1H	CQWGDVVCKBJLNX-UHFFFAOYSA-N	organic	[I-].CC(C)(C)C[NH3+]	C5H14IN	\N	\N	\N	greatcell: MS100740-100	\N	https://cactus.nci.nih.gov/chemical/structure
Phenethylammonium bromide	Phenethylammoniumbromide	202.09	1.446421	InChI=1S/C8H11N.BrH/c9-7-6-8-4-2-1-3-5-8;/h1-5H,6-7,9H2;1H	IRAGENYJMTVCCV-UHFFFAOYSA-N	organic	c1ccc(cc1)CC[NH3+].[Br-]	C8H12BrN	70441016	\N	\N	Sigma: 900829-10G	https://www.sigmaaldrich.com/catalog/product/aldrich/900829?lang=en&region=US	https://pubchem.ncbi.nlm.nih.gov/compound/70441016
piperazine dihydrobromide	PiperazinediiumDiBromide	247.96	1.936635	InChI=1S/C4H10N2.2BrH/c1-2-6-4-3-5-1;;/h5-6H,1-4H2;2*1H	UXWKNNJFYZFNDI-UHFFFAOYSA-N	organic	C1C[NH2+]CC[NH2+]1.[Br-].[Br-]	C4H12Br2N2	\N	\N	\N	greatcell: MS319500	\N	\N
Piperazine-1,4-diium iodide	PiperazinediiumDiodide	341.96	2.352982	InChI=1S/C4H10N2.2HI/c1-2-6-4-3-5-1;;/h5-6H,1-4H2;2*1H	QZCGFUVVXNFSLE-UHFFFAOYSA-N	organic	[I-].[I-].C1C[NH2+]CC[NH2+]1	\N	\N	\N	\N	\N	\N	https://cactus.nci.nih.gov/chemical/structure/%5BI-%5D.%5BI-%5D.C1C%5BNH2+%5DCC%5BNH2+%5D1/stdinchikey
Piperidinium Iodide	PiperidiniumIodide	213.06	1.720983	InChI=1S/C5H11N.HI/c1-2-4-6-5-3-1;/h6H,1-5H2;1H	HBPSMMXRESDUSG-UHFFFAOYSA-N	organic	C1CC[NH2+]CC1.[I-]	C5H12IN	15533240	\N	\N	MS119800-10	\N	https://pubchem.ncbi.nlm.nih.gov/compound/15533240
Poly(vinyl alcohol), Mw89000-98000, >99% hydrolyzed)	PVA	92000	1234.56	1S/C2H4O/c1-2-3/h2-3H,1H2	IMROMDMJAWUWLK-UHFFFAOYSA-N	polymer	C{-}(OC(=O)C)C{n+}	C2H4O	\N	\N	\N	Sigma: 341584-25G	https://www.sigmaaldrich.com/catalog/product/ALDRICH/341584?lang=en&\\region=US&cm_sp=Insite-_-prodRecCold_xviews-_-prodRecCold5-3	\N
Pralidoxime iodide	PralidoximeIodide	264.066	1.850877	InChI=1S/C7H8N2O.HI/c1-9-5-3-2-4-7(9)6-8-10;/h2-6H,1H3;1H/b7-6+;	QNBVYCDYFJUNLO-UHDJGPCESA-N	organic	CN1C=CC=CC1=C[NH+]=O.[I-]	C7H9IN2O	\N	\N	\N	\N	\N	https://pubchem.ncbi.nlm.nih.gov/compound/pralidoxime_iodide#section=Names-and-Identifiers
Propane-1,3-diammonium iodide	Propane13diammoniumIodide	329.95	2.10244	InChI=1S/C3H10N2.HI/c4-2-1-3-5;/h1-5H2;1H/p+1	UMDDLGMCNFAZDX-UHFFFAOYSA-O	organic	[NH3+]CCC[NH3+].[I-].[I-]	C3H12IN2	\N	\N	\N	\N	\N	\N
Pyrrolidinium Bromide	pyrrolidiniumBromide	152.03	1.587983	InChI=1S/C4H9N.BrH/c1-2-4-5-3-1;/h5H,1-4H2;1H	VFDOIPKMSSDMCV-UHFFFAOYSA-N	organic	C1CC[NH2+]C1.[Br-]	C4H10BrN	18621471	\N	\N	greatcell: MS319700-10	\N	https://pubchem.ncbi.nlm.nih.gov/compound/18621471
Pyrrolidinium Iodide	PyrrolidiniumIodide	199.035	1.88354	InChI=1S/C4H9N.HI/c1-2-4-5-3-1;/h5H,1-4H2;1H	DMFMZFFIQRMJQZ-UHFFFAOYSA-N	organic	C1CC[NH2+]C1.[I-]	C4H10IN	\N	\N	\N	greatcell: MS119700-100	\N	https://pubchem.ncbi.nlm.nih.gov/compound/11159941
Quinuclidin-1-ium bromide	QuinuclidiniumBromide	192.1	1.422151	InChI=1S/C7H13N.BrH/c1-4-8-5-2-7(1)3-6-8;/h7H,1-6H2;1H	DYEHDACATJUKSZ-UHFFFAOYSA-N	organic	C1C[NH+]2CCC1CC2.[Br-]	C7H14BrN	66608461	\N	1-Azoniabicyclo[2.2.2]octane;bromide	greatcell: MS329300	\N	https://pubchem.ncbi.nlm.nih.gov/compound/66608461
Quinuclidin-1-ium iodide	QuinuclidiniumIodide	239.1	1.617795	InChI=1S/C7H13N.HI/c1-4-8-5-2-7(1)3-6-8;/h7H,1-6H2;1H	LYHPZBKXSHVBDW-UHFFFAOYSA-N	organic	C1C[NH+]2CCC1CC2.[I-]	\N	\N	\N	\N	\N	\N	https://cactus.nci.nih.gov/chemical/structure/%5BI-%5D.C1C%5BNH+%5D2CCC1CC2/stdinchikey
tert-Octylammonium iodide	TertOctylammoniumIodide	257.157	1.304114	InChI=1S/C8H19N.HI/c1-7(2,3)6-8(4,5)9;/h6,9H2,1-5H3;1H	UXYJHTKQEFCXBJ-UHFFFAOYSA-N	organic	C(CC(C)(C)[NH3+])(C)(C)C.[I-]	C8H20IN	\N	\N	\N	\N	\N	\N
Pyridinium Iodide	PyridiniumIodide	207.01	2.051533	InChI=1S/C5H5N.HI/c1-2-4-6-5-3-1;/h1-5H;1H	BJDYCCHRZIFCGN-UHFFFAOYSA-N	organic	C1=CC=[NH+]C=C1.[I-]	C5H6IN	6432201	\N	\N	\N	\N	\N
Cyclohexylmethylammonium iodide	CyclohexylmethylammoniumIodide	241.11	1.505014	InChI=1S/C7H15N.HI/c1-8-7-5-3-2-4-6-7;/h7-8H,2-6H2,1H3;1H	ZEVRFFCPALTVDN-UHFFFAOYSA-N	organic	C1CCC(CC1)C[NH3+].[I-]	C7H16IN	129790872	\N	\N	\N	\N	\N
Cyclohexylammonium iodide	CyclohexylammoniumIodide	227.09	1.605951	InChI=1S/C6H13N.HI/c7-6-4-2-1-3-5-6;/h6H,1-5,7H2;1H	WGYRINYTHSORGH-UHFFFAOYSA-N	organic	C1CCC(CC1)[NH3+].[I-]	C6H14IN	89524541	\N	\N	\N	\N	\N
Butane-1,4-diammonium Iodide	Butane14diammoniumIodide	343.98	2.203123	InChI=1S/C4H12N2.2HI/c5-3-1-2-4-6;;/h1-6H2;2*1H	XZUCBFLUEBDNSJ-UHFFFAOYSA-N	organic	C(CC[NH3+])C[NH3+].[I-].[I-]	C4H14I2N2	\N	\N	\N	\N	\N	\N
1,4-Benzene diammonium iodide	Benzenediaminedihydroiodide	363.97	2.340659	nChI=1S/C6H8N2.2HI/c7-5-1-2-6(8)4-3-5;;/h1-4H,7-8H2;2*1H	RYYSZNVPBLKLRS-UHFFFAOYSA-N	organic	C1=CC(=CC=C1[NH3+])[NH3+].[I-].[I-]	C6H10I2N2	129655325	\N	\N	\N	\N	\N
5-Azaspiro[4.4]nonan-5-ium iodide	5Azaspironoiodide	253.12	1.527018	InChI=1S/C8H16N.HI/c1-2-6-9(5-1)7-3-4-8-9;/h1-8H2;1H/q+1;/p-1	DWOWCUCDJIERQX-UHFFFAOYSA-M	organic	C1CC[N+]2(C1)CCCC2.[I-]	C8H16IN	86209376	\N	\N	\N	\N	\N
Diethylammonium iodide	Diethylammoniumiodide	201.05	1.676932	InChI=1S/C4H11N.HI/c1-3-5-4-2;/h5H,3-4H2,1-2H3;1H	YYMLRIWBISZOMT-UHFFFAOYSA-N	organic	CC[NH2+]CC.[I-]	C4H12IN	88320434	\N	\N	\N	\N	\N
2-Pyrrolidin-1-ium-1-ylethylammonium iodide	2Pyrrolidin1ium1ylethylammoniumiodide	370.017	2.078859	InChI=1S/C6H14N2.2HI/c7-3-6-8-4-1-2-5-8;;/h1-7H2;2*1H	UVLZLKCGKYLKOR-UHFFFAOYSA-N	organic	C1CC[NH+](C1)CC[NH3+].[I-].[I-]	C6H16I2N2	\N	\N	\N	\N	\N	\N
N,N-Dimethylethane- 1,2-diammonium iodide	NNDimethylethane12diammoniumiodide	343.979	2.180165	InChI=1S/C4H12N2.2HI/c1-6(2)4-3-5;;/h3-5H2,1-2H3;2*1H	BAMDIFIROXTEEM-UHFFFAOYSA-N	organic	C[NH+](C)CC[NH3+].[I-].[I-]	C4H14I2N2	\N	\N	\N	\N	\N	\N
N,N-dimethylpropane- 1,3-diammonium iodide	NNdimethylpropane13diammoniumiodide	358.006	2.053208	InChI=1S/C5H14N2.2HI/c1-7(2)5-3-4-6;;/h3-6H2,1-2H3;2*1H	JERSPYRKVMAEJY-UHFFFAOYSA-N	organic	C[NH+](C)CCC[NH3+].[I-].[I-]	C5H16I2N2	\N	\N	\N	\N	\N	\N
N,N-Diethylpropane-1,3-diammonium iodide	NNDiethylpropane13diammoniumiodide	386.06	1.848218	InChI=1S/C7H18N2.2HI/c1-3-9(4-2)7-5-6-8;;/h3-8H2,1-2H3;2*1H	NXRUEVJQMBGVAT-UHFFFAOYSA-N	organic	CC[NH+](CC)CCC[NH3+].[I-].[I-]	C7H20I2N2	\N	\N	\N	\N	\N	\N
Di-isopropylammonium iodide	Diisopropylammoniumiodide	229.1	1.454266	InChI=1S/C6H15N.HI/c1-5(2)7-6(3)4;/h5-7H,1-4H3;1H	PBGZCCFVBVEIAS-UHFFFAOYSA-N	organic	CC(C)[NH2+]C(C)C.[I-]	C6H16IN	517666	\N	\N	\N	\N	\N
4-methoxy-phenethylammonium-iodide	4methoxyphenethylammoniumiodide	279.12	1.566776	InChI=1S/C9H13NO.HI/c1-11-9-4-2-8(3-5-9)6-7-10;/h2-5H,6-7,10H2,1H3;1H	QNNYEDWTOZODAS-UHFFFAOYSA-N	organic	[I-].[NH3+](CCC1=CC=C(C=C1)OC)	\N	\N	\N	\N	\N	\N	\N
Iso-Propylammonium Bromide 	IsoPropylammoniumBromide 	140.02	1.841935	InChI=1S/C3H9N.BrH/c1-3(2)4;/h3H,4H2,1-2H3;1H	WGWKNMLSVLOQJB-UHFFFAOYSA-N	organic	CC(C)[NH3+].[Br-]	C3H10BrN	22495069	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3501 (class 0 OID 24984)
-- Dependencies: 230
-- Data for Name: load_hc_inventory; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.load_hc_inventory (chemical, part_no, stock_bottles, remaining_amt, update_date, lastupdate_date) FROM stdin;
Lead Iodide	\N	4	200	2019-10-28	Mansoor
Methylammonium iodide	806390-25G (MS101000-100)	3	100	2019-11-05	Mansoor
Ethylammonium iodide	805823-25G	5	100	2019-10-28	Mansoor
n-Butylammonium Iodide	MS106000	8	130	2019-10-28	Mansoor
Phenethylammonium iodide 	805904-25G	6	105	2019-10-28	Mansoor
Formamidinium Iodide	MS-150000	2	50	2019-10-28	Mansoor
Guanidinium Iodide	806056	2	100	2019-10-28	Mansoor
Imidazolium Iodide	MS-170000-100	3	25	2019-11-05	Mansoor
Acetamidinium Iodide	805971-25G	2	55	2019-11-05	Mansoor
Benzylammonium Iodide	806196-25G	4	100	2019-10-28	Mansoor
neo-Pentylammonium iodide	MS100740-100	2	20	2019-10-28	Mansoor
iso-Butylammonium iodide	MS107000-100	2	15	2019-10-28	Mansoor
Dimethylammonium iodide	MS111100-100	8	155	2019-10-28	Mansoor
n-Dodecylammonium iodide	MS100880-100	3	22	2019-11-05	Mansoor
Pyrrolidinium Iodide	MS119700-100	2	100	2019-10-28	Mansoor
N-propylammonium Iodide	805858-25G	4	100	2019-10-28	Mansoor
Quinuclidinium iodide	\N	3	30	2019-10-28	Mansoor
Piperazine-1,4-diium iodide	\N	2	20	2019-10-28	Mansoor
Cyclohexylammonium iodide	MS100840-100	3	25	2019-11-05	Mansoor
tert-Octylammonium iodide	MS100830-100	3	25	2019-11-05	Mansoor
4-Trifluoromethyl-Phenylammonium iodide	MS100790-100	1	10	2019-10-28	Mansoor
4-Methoxy-Phenylammonium iodide	MS100610-100	2	20	2019-11-05	Mansoor
Propane-1,3-diammonium iodide	\N	1	50	2019-10-28	Mansoor
4-Fluoro-Phenylammonium iodide	MS100620-100	3	25	2019-11-05	Mansoor
iso-Pentylammonium iodide	MS100710-100	1	50	2019-10-28	Mansoor
n-Hexylammonium iodide	MS100860-100	4	35	2019-10-28	Mansoor
4-Fluoro- Benzylammonium iodide	MS100730-10	5	140	2019-10-28	Mansoor
4-Trifluoromethyl-Benzylammonium iodide	MS100780-100	2	105	2019-10-28	Mansoor
4-Fluoro-Phenethylammonium iodide	MS100720-100	4	20	2019-11-05	Mansoor
Cyclohexylmethylammonium iodide	\N	6	60	2019-10-28	Mansoor
Ethane-1,2-diammonium iodide	MS102002-10	10	145	2019-10-28	Mansoor
Butane-1,4 Diammonium Iodide	MS104040-10	4	35	2019-10-28	Mansoor
Phenylammonium Iodide	MS108000-10	15	135	2019-10-28	Mansoor
Morpholinium Iodide	MS110640-10	3	25	2019-10-28	Mansoor
Piperidinium Iodide	MS119800-10	3	30	2019-10-28	Mansoor
t-Butylammonium Iodide	MS106000-10	6	90	2019-10-28	Mansoor
n-Octylammonium Iodide	MS105500-10	4	40	2019-10-28	Mansoor
1,4-Diazabicyclo[2,2,2]octane-1,4-diium Iodide	MS129400-10	2	15	2019-10-28	Mansoor
5-Azaspiro[4.4]nonan-5-ium iodide	\N	2	10	2019-10-28	Mansoor
Pyridinium Iodide	MS129810-10	2	20	2019-10-28	Mansoor
iso-Propylammonium iodide	MS104000-10	5	75	2019-10-28	Mansoor
Di-isopropylammonium Iodide	\N	1	50	2019-10-28	Mansoor
Diethylammonium iodide	\N	1	10	2019-10-28	Mansoor
1,4-Benzene diammonium iodide	\N	2	15	2019-10-28	Mansoor
N,N-Dimethylethane- 1,2-diammonium iodide	\N	2	15	2019-10-28	Mansoor
N,N-Diethylpropane-1,3-diammonium iodide	\N	2	20	2019-10-28	Mansoor
2-Pyrrolidin-1-ium-1-ylethylammonium iodide	\N	2	20	2019-10-28	Mansoor
N,N-dimethylpropane- 1,3-diammonium iodide	\N	2	20	2019-10-28	Mansoor
4-methoxy-phenethylammonium-iodide	\N	2	60	2019-10-28	Mansoor
Methyl phenyl phosphonium iodide	\N	2	50	2019-10-28	Mansoor
Ethyl phenyl phosphonium iodide	\N	2	100	2019-10-28	Mansoor
Bismuth III Iodide	\N	1	25	2019-10-28	Mansoor
Indium III Chloride	\N	1	10	2019-10-28	Mansoor
Indium II Chloride	\N	1	10	2019-10-28	Mansoor
Lead Bromide	211141-100G	\N	\N	\N	\N
Methylammonium Bromide	806498-25g	25g	\N	\N	\N
Ethylammonium bromine	900868-25g	10 g	\N	\N	\N
Imidazolium Bromide	\N	10 g	\N	\N	\N
Acetamidinium Bromide	\N	10 g	8.5924	2019-06-18	\N
n-Butylammonium Bromide		10 g	6.9658	2019-06-18	\N
formamidinium bromide	146958-06-7	50g	\N	\N	\N
phenethylammonium bromide	53916-94-2	50g	\N	\N	\N
guanidinium bromide	900839-25g	25g	\N	\N	\N
benzylammonium bromide	900885-5g	5g	\N	\N	\N
ethane-1,2-diammonium bromide	624-59-9	10g	\N	\N	\N
piperazine-1,4-diium bromide		10g	\N	\N	\N
n-dodecylammonium bromide	26204-55-7	10g	\N	\N	\N
dimethylammonium bromide	6912-12-05	10g	\N	\N	\N
neo-pentylammonium bromide	missing CAS RN	10g	\N	\N	\N
pyrrolidinium bromide	55810-80-5	10g	\N	\N	\N
quinuclidinium bromide	60662-68-2	10g	\N	\N	\N
iso-butylammonium bromide	batch#: 569205	10g	\N	\N	\N
iso-propylammonium bromide	29552-58-7	10g	\N	\N	\N
N,N-Dimethylformamide (/DMF)	227056-1L	1L x 2	2L 	2019-06-25	\N
GBL	B1198-3KG	500 gx3	1.5L	\N	\N
Formic Acid	\N	100 ml	\N	\N	\N
Lead Oxide	211907-100G	90 g	\N	\N	\N
Cesium iodide	\N	10 g	\N	\N	\N
Bismuth iodide	\N	25 g	\N	\N	\N
DMSO	\N	1 L	1L	\N	\N
Lead Iodide	\N	4	200	2019-10-28	Mansoor
Methylammonium iodide	806390-25G (MS101000-100)	3	100	2019-11-05	Mansoor
Ethylammonium iodide	805823-25G	5	100	2019-10-28	Mansoor
n-Butylammonium Iodide	MS106000	8	130	2019-10-28	Mansoor
Phenethylammonium iodide 	805904-25G	6	105	2019-10-28	Mansoor
Formamidinium Iodide	MS-150000	2	50	2019-10-28	Mansoor
Guanidinium Iodide	806056	2	100	2019-10-28	Mansoor
Imidazolium Iodide	MS-170000-100	3	25	2019-11-05	Mansoor
Acetamidinium Iodide	805971-25G	2	55	2019-11-05	Mansoor
Benzylammonium Iodide	806196-25G	4	100	2019-10-28	Mansoor
neo-Pentylammonium iodide	MS100740-100	2	20	2019-10-28	Mansoor
iso-Butylammonium iodide	MS107000-100	2	15	2019-10-28	Mansoor
Dimethylammonium iodide	MS111100-100	8	155	2019-10-28	Mansoor
n-Dodecylammonium iodide	MS100880-100	3	22	2019-11-05	Mansoor
Pyrrolidinium Iodide	MS119700-100	2	100	2019-10-28	Mansoor
N-propylammonium Iodide	805858-25G	4	100	2019-10-28	Mansoor
Quinuclidinium iodide	\N	3	30	2019-10-28	Mansoor
Piperazine-1,4-diium iodide	\N	2	20	2019-10-28	Mansoor
Cyclohexylammonium iodide	MS100840-100	3	25	2019-11-05	Mansoor
tert-Octylammonium iodide	MS100830-100	3	25	2019-11-05	Mansoor
4-Trifluoromethyl-Phenylammonium iodide	MS100790-100	1	10	2019-10-28	Mansoor
4-Methoxy-Phenylammonium iodide	MS100610-100	2	20	2019-11-05	Mansoor
Propane-1,3-diammonium iodide	\N	1	50	2019-10-28	Mansoor
4-Fluoro-Phenylammonium iodide	MS100620-100	3	25	2019-11-05	Mansoor
iso-Pentylammonium iodide	MS100710-100	1	50	2019-10-28	Mansoor
n-Hexylammonium iodide	MS100860-100	4	35	2019-10-28	Mansoor
4-Fluoro- Benzylammonium iodide	MS100730-10	5	140	2019-10-28	Mansoor
4-Trifluoromethyl-Benzylammonium iodide	MS100780-100	2	105	2019-10-28	Mansoor
4-Fluoro-Phenethylammonium iodide	MS100720-100	4	20	2019-11-05	Mansoor
Cyclohexylmethylammonium iodide	\N	6	60	2019-10-28	Mansoor
Ethane-1,2-diammonium iodide	MS102002-10	10	145	2019-10-28	Mansoor
Butane-1,4 Diammonium Iodide	MS104040-10	4	35	2019-10-28	Mansoor
Phenylammonium Iodide	MS108000-10	15	135	2019-10-28	Mansoor
Morpholinium Iodide	MS110640-10	3	25	2019-10-28	Mansoor
Piperidinium Iodide	MS119800-10	3	30	2019-10-28	Mansoor
t-Butylammonium Iodide	MS106000-10	6	90	2019-10-28	Mansoor
n-Octylammonium Iodide	MS105500-10	4	40	2019-10-28	Mansoor
1,4-Diazabicyclo[2,2,2]octane-1,4-diium Iodide	MS129400-10	2	15	2019-10-28	Mansoor
5-Azaspiro[4.4]nonan-5-ium iodide	\N	2	10	2019-10-28	Mansoor
Pyridinium Iodide	MS129810-10	2	20	2019-10-28	Mansoor
iso-Propylammonium iodide	MS104000-10	5	75	2019-10-28	Mansoor
Di-isopropylammonium Iodide	\N	1	50	2019-10-28	Mansoor
Diethylammonium iodide	\N	1	10	2019-10-28	Mansoor
1,4-Benzene diammonium iodide	\N	2	15	2019-10-28	Mansoor
N,N-Dimethylethane- 1,2-diammonium iodide	\N	2	15	2019-10-28	Mansoor
N,N-Diethylpropane-1,3-diammonium iodide	\N	2	20	2019-10-28	Mansoor
2-Pyrrolidin-1-ium-1-ylethylammonium iodide	\N	2	20	2019-10-28	Mansoor
N,N-dimethylpropane- 1,3-diammonium iodide	\N	2	20	2019-10-28	Mansoor
4-methoxy-phenethylammonium-iodide	\N	2	60	2019-10-28	Mansoor
Methyl phenyl phosphonium iodide	\N	2	50	2019-10-28	Mansoor
Ethyl phenyl phosphonium iodide	\N	2	100	2019-10-28	Mansoor
Bismuth III Iodide	\N	1	25	2019-10-28	Mansoor
Indium III Chloride	\N	1	10	2019-10-28	Mansoor
Indium II Chloride	\N	1	10	2019-10-28	Mansoor
Lead Bromide	211141-100G	\N	\N	\N	\N
Methylammonium Bromide	806498-25g	25g	\N	\N	\N
Ethylammonium bromine	900868-25g	10 g	\N	\N	\N
Imidazolium Bromide	\N	10 g	\N	\N	\N
Acetamidinium Bromide	\N	10 g	8.5924	2019-06-18	\N
n-Butylammonium Bromide		10 g	6.9658	2019-06-18	\N
formamidinium bromide	146958-06-7	50g	\N	\N	\N
phenethylammonium bromide	53916-94-2	50g	\N	\N	\N
guanidinium bromide	900839-25g	25g	\N	\N	\N
benzylammonium bromide	900885-5g	5g	\N	\N	\N
ethane-1,2-diammonium bromide	624-59-9	10g	\N	\N	\N
piperazine-1,4-diium bromide		10g	\N	\N	\N
n-dodecylammonium bromide	26204-55-7	10g	\N	\N	\N
dimethylammonium bromide	6912-12-05	10g	\N	\N	\N
neo-pentylammonium bromide	missing CAS RN	10g	\N	\N	\N
pyrrolidinium bromide	55810-80-5	10g	\N	\N	\N
quinuclidinium bromide	60662-68-2	10g	\N	\N	\N
iso-butylammonium bromide	batch#: 569205	10g	\N	\N	\N
iso-propylammonium bromide	29552-58-7	10g	\N	\N	\N
N,N-Dimethylformamide (/DMF)	227056-1L	1L x 2	2L 	2019-06-25	\N
GBL	B1198-3KG	500 gx3	1.5L	\N	\N
Formic Acid	\N	100 ml	\N	\N	\N
Lead Oxide	211907-100G	90 g	\N	\N	\N
Cesium iodide	\N	10 g	\N	\N	\N
Bismuth iodide	\N	25 g	\N	\N	\N
DMSO	\N	1 L	1L	\N	\N
\.


--
-- TOC entry 3502 (class 0 OID 24990)
-- Dependencies: 231
-- Data for Name: load_lbl_inventory; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.load_lbl_inventory (no, chemical, est_96_vials_amt, stock, part_no, bulk_order_price, purch_date, update_date) FROM stdin;
1	MeNH3I	20 g	406 g	806390-25G (MS101000-100)	\N	\N	2019-05-09
2	EtNH3I	30 g	112.5 g	805823-25G	5.64	\N	2019-05-09
3	n-BuNH3I	30 g	225 g	805874-25G	8.83	\N	2019-05-09
4	PhenEtNH3I	27 g	395 g	805904-25G	\N	\N	2019-05-09
\N	PbI2	40 g	326 g	211168-50G	0.66	\N	2019-05-09
\N	GBL	50 mL	>3000 mL	B1198-3KG	\N	\N	2019-05-09
\N	Formic Acid	8 mL	>100mL	\N	\N	\N	2019-05-09
5	Formamidinium Iodide	\N	200 g	MS-150000-100	\N	\N	2019-05-09
6	Guanidinium Iodide	\N	5 g	806056-25G	\N	\N	2019-05-09
7	Imidazolium Iodide	\N	50 g	MS-170000-100	\N	\N	2019-05-09
8	Acetamidinium Iodide	\N	35 g	805971-25G	\N	50 g	2019-05-09
9	Benzylammonium Iodide	\N	45 g	806196-25G	\N	\N	2019-05-09
10	neo-Pentylammonium iodide	\N	18 g	MS100740-100	\N	\N	2019-05-09
11	iso-Propylammonium iodide	\N	40 g	MS104000-100	\N	\N	2019-05-09
12	iso-Butylammonium iodide	\N	480 g	MS107000-100	\N	\N	2019-05-09
13	Dimethylammonium iodide	`	54.2 g	MS111100-100 (805831-25G)	\N	50 g	2019-05-09
14	n-Dodecylammonium iodide	\N	75 g	MS100880-100	\N	\N	2019-05-09
15	Pyrrolidinium Iodide	\N	517 g	MS119700-100	\N	\N	2019-05-09
16	Ethane-1,2-diammonium iodide	\N	200 g	\N	\N	\N	2019-05-09
17	Cesium iodide	\N	100 g	\N	$8.25/gram	\N	2019-05-09
18	Bismuth iodide	\N	100 g	\N	\N	\N	2019-05-09
\N	Lead Bromide	\N	80 g	211141-100G	\N	\N	2019-05-09
19	MeNH3Br	\N	150 g	MS301000-100	\N	\N	2019-05-09
\N	EtNH3Br	\N	80 g	900868-25G	\N	\N	2019-05-09
20	4-Methoxy-Phenylammonium iodide	\N	69 g	MS100610-100	\N	\N	2019-05-09
21	iso-Pentylammonium iodide	\N	90 g	MS100710-100	\N	\N	2019-05-09
22	n-Propylammonium iodide	\N	27 g	MS103000-100	\N	\N	2019-05-09
23	4-Fluoro-Phenylammonium iodide	\N	140 g	MS100620-100	\N	\N	2019-05-09
24	tert-Octylammonium iodide	\N	74 g	MS100830-100	\N	\N	2019-05-09
25	Cyclohexylammonium iodide	\N	66 g	MS100840-100	\N	\N	2019-05-09
26	4-Fluoro- Benzylammonium iodide	\N	76.5 g	MS100730-100	\N	\N	2019-05-09
27	n-Hexylammonium iodide	\N	185 g	MS100860-100	\N	\N	2019-05-09
28	4-Trifluoromethyl-Benzylammonium iodide	\N	64 g	MS100780-100	\N	\N	2019-05-09
29	4-Trifluoromethyl-Phenylammonium iodide	\N	60 g	MS100790-100	\N	\N	2019-05-09
30	Cyclohexylmethylammonium iodide	\N	78 g	MS101840-50	\N	\N	2019-05-09
31	4-Fluoro-Phenethylammonium iodide	\N	54 g	MS100720-100	\N	\N	2019-05-09
32	Propane-1,3-diammonium iodide	\N	100 g	MS103003-100	\N	\N	2019-05-09
33	2-Pyrrolidin-1-ium-1-ylethylammonium iodide	\N	200 g	MS122972-100	\N	\N	2019-05-09
34	5-Azaspiro[4.4]nonan-5-ium iodide	\N	200 g	MS199700-100	\N	\N	2019-05-09
35	1,4-Benzene diammonium iodide	\N	186.5 g	MS108005-100	\N	\N	2019-05-09
36	Butane-1,4-diammonium iodide	\N	200 g	MS104040-100	\N	\N	2019-05-09
37	t-Butylammonium iodide	\N	163 g	MS106000-100	\N	\N	2019-05-09
39	1,4-Diazabicyclo[2,2,2]octane-1,4-diium iodide	\N	200 g	MS129400-100	\N	\N	2019-05-09
40	Diethylammonium iodide	\N	179 g	MS112200-100	\N	\N	2019-05-09
41	N,N-Dimethylethane- 1,2-diammonium iodide	\N	200 g	MS122112-100	\N	\N	2019-05-09
42	N,N-dimethylpropane- 1,3-diammonium iodide	\N	200 g	MS123113-100	\N	\N	2019-05-09
44	N,N-Diethylpropane-1,3-diammonium iodide	\N	185.5 g	MS123223-100	\N	\N	2019-05-09
45	n-Octylammonium Iodide	\N	173 g	MS105500-100	\N	\N	2019-05-09
46	Phenylammonium iodide	\N	860 g 	MS108000-25	\N	\N	2019-05-09
47	Piperidinium iodide	\N	180 g	MS119800-100	\N	\N	\N
48	Pyridinium iodide	\N	175 g	MS129810-100	\N	\N	\N
49	Alanine Hydroiodide	\N	\N	need to find a cheaper source	\N	\N	\N
50	Piperazine-1,4-diium iodide	\N	200 g	MS119500-100	\N	\N	\N
51	Pralidoxime iodide	\N	\N	need to find a source 	\N	\N	\N
52	Quinuclidin-1-ium iodide	\N	20 g	\N	\N	\N	\N
53	Morpholinium Iodide	\N	159.5 g	MS110640-100	\N	\N	\N
54	4-Methoxy-Phenaethylammonium Iodide	\N	50 g	\N	\N	\N	\N
55	Di-isopropylammonium Iodide	\N	50 g	\N	\N	\N	\N
\N	Proposed Bromides	\N	\N	\N	\N	\N	\N
1	2-Pyrrolidin-1-ium-1-ylethylammonium bromide	\N	\N	\N	\N	\N	\N
2	Acetamidinium bromide	\N	100 g	\N	\N	\N	\N
3	5-Azaspiro[4.4]nonan-5-ium bromide	\N	\N	\N	\N	\N	\N
4	1,4-Benzenediammonium bromide	\N	\N	\N	\N	\N	\N
5	Benzylammonium bromide	\N	100 g	\N	\N	\N	\N
6	Butane-1,4-diammonium bromide	\N	\N	\N	\N	\N	\N
7	iso-Butylammonium bromide	\N	\N	\N	\N	\N	\N
8	n-Butylammonium bromide	\N	100 g	\N	\N	\N	\N
9	t-Butylammonium bromide	\N	\N	\N	\N	\N	\N
10	Cyclohexylammonium bromide	\N	\N	\N	\N	\N	\N
11	Cyclohexylmethylammonium bromide	\N	\N	\N	\N	\N	\N
12	1,4-Diazabicyclo[2,2,2]octane-1,4-diium bromide	\N	\N	\N	\N	\N	\N
13	Diethylammonium bromide	\N	\N	\N	\N	\N	\N
14	Dimethylammonium bromide	\N	\N	\N	\N	\N	\N
15	N,N-Dimethylethane- 1,2-diammonium bromide	\N	\N	\N	\N	\N	\N
16	N,N-dimethylpropane-1,3-diammonium bromide	\N	\N	\N	\N	\N	\N
17	n-Dodecylammonium bromide	\N	\N	\N	\N	\N	\N
18	Ethane-1,2-diammonium bromide	\N	\N	\N	\N	\N	\N
19	Ethylammonium bromide	\N	\N	\N	\N	\N	\N
20	4-Fluoro-Phenylammonium bromide	\N	\N	\N	\N	\N	\N
21	4-Fluoro- Benzylammonium bromide	\N	\N	\N	\N	\N	\N
22	4-Fluoro- Phenethylammonium bromide	\N	\N	\N	\N	\N	\N
23	Formamidinium bromide	\N	54 g	\N	\N	\N	\N
24	Guanidinium bromide	\N	100 g	\N	\N	\N	\N
25	n-Hexylammonium bromide	\N	\N	\N	\N	\N	\N
26	Imidazolium bromide	\N	100 g	\N	\N	\N	\N
27	4-Methoxy-Phenethylammonium bromide	\N	\N	\N	\N	\N	\N
28	4-Methoxy-Phenylammonium bromide	\N	\N	\N	\N	\N	\N
29	Methylammonium bromide	\N	\N	\N	\N	\N	\N
30	N,N-Diethylpropane-1,3-diammonium bromide	\N	\N	\N	\N	\N	\N
31	n-Octylammonium Bromide	\N	\N	\N	\N	\N	\N
32	tert-Octylammonium bromide	\N	\N	\N	\N	\N	\N
33	n-Pentylammonium Bromide	\N	\N	\N	\N	\N	\N
34	i-Pentylammonium bromide	\N	\N	\N	\N	\N	\N
35	neo-Pentylammonium bromide	\N	\N	\N	\N	\N	\N
36	Phenethylammonium bromide	\N	100 g	\N	\N	\N	\N
37	Phenylammonium bromide	\N	\N	\N	\N	\N	\N
38	Piperazine-1,4-diium bromide	\N	\N	\N	\N	\N	\N
39	Piperidinium bromide	\N	\N	\N	\N	\N	\N
40	Propane-1,3-diammonium bromide	\N	\N	\N	\N	\N	\N
41	iso-Propylammonium bromide	\N	\N	\N	\N	\N	\N
42	n-Propylammonium bromide	\N	\N	\N	\N	\N	\N
43	Pyrrolidinium bromide	\N	\N	\N	\N	\N	\N
44	Quinuclidin-1-ium bromide	\N	\N	\N	\N	\N	\N
45	4-Trifluoromethyl-Benzylammonium bromide	\N	\N	\N	\N	\N	\N
46	4-Trifluoromethyl-Phenylammonium bromide	\N	\N	\N	\N	\N	\N
1	MeNH3I	20 g	406 g	806390-25G (MS101000-100)	\N	\N	2019-05-09
2	EtNH3I	30 g	112.5 g	805823-25G	5.64	\N	2019-05-09
3	n-BuNH3I	30 g	225 g	805874-25G	8.83	\N	2019-05-09
4	PhenEtNH3I	27 g	395 g	805904-25G	\N	\N	2019-05-09
\N	PbI2	40 g	326 g	211168-50G	0.66	\N	2019-05-09
\N	GBL	50 mL	>3000 mL	B1198-3KG	\N	\N	2019-05-09
\N	Formic Acid	8 mL	>100mL	\N	\N	\N	2019-05-09
5	Formamidinium Iodide	\N	200 g	MS-150000-100	\N	\N	2019-05-09
6	Guanidinium Iodide	\N	5 g	806056-25G	\N	\N	2019-05-09
7	Imidazolium Iodide	\N	50 g	MS-170000-100	\N	\N	2019-05-09
8	Acetamidinium Iodide	\N	35 g	805971-25G	\N	50 g	2019-05-09
9	Benzylammonium Iodide	\N	45 g	806196-25G	\N	\N	2019-05-09
10	neo-Pentylammonium iodide	\N	18 g	MS100740-100	\N	\N	2019-05-09
11	iso-Propylammonium iodide	\N	40 g	MS104000-100	\N	\N	2019-05-09
12	iso-Butylammonium iodide	\N	480 g	MS107000-100	\N	\N	2019-05-09
13	Dimethylammonium iodide	`	54.2 g	MS111100-100 (805831-25G)	\N	50 g	2019-05-09
14	n-Dodecylammonium iodide	\N	75 g	MS100880-100	\N	\N	2019-05-09
15	Pyrrolidinium Iodide	\N	517 g	MS119700-100	\N	\N	2019-05-09
16	Ethane-1,2-diammonium iodide	\N	200 g	\N	\N	\N	2019-05-09
17	Cesium iodide	\N	100 g	\N	$8.25/gram	\N	2019-05-09
18	Bismuth iodide	\N	100 g	\N	\N	\N	2019-05-09
\N	Lead Bromide	\N	80 g	211141-100G	\N	\N	2019-05-09
19	MeNH3Br	\N	150 g	MS301000-100	\N	\N	2019-05-09
\N	EtNH3Br	\N	80 g	900868-25G	\N	\N	2019-05-09
20	4-Methoxy-Phenylammonium iodide	\N	69 g	MS100610-100	\N	\N	2019-05-09
21	iso-Pentylammonium iodide	\N	90 g	MS100710-100	\N	\N	2019-05-09
22	n-Propylammonium iodide	\N	27 g	MS103000-100	\N	\N	2019-05-09
23	4-Fluoro-Phenylammonium iodide	\N	140 g	MS100620-100	\N	\N	2019-05-09
24	tert-Octylammonium iodide	\N	74 g	MS100830-100	\N	\N	2019-05-09
25	Cyclohexylammonium iodide	\N	66 g	MS100840-100	\N	\N	2019-05-09
26	4-Fluoro- Benzylammonium iodide	\N	76.5 g	MS100730-100	\N	\N	2019-05-09
27	n-Hexylammonium iodide	\N	185 g	MS100860-100	\N	\N	2019-05-09
28	4-Trifluoromethyl-Benzylammonium iodide	\N	64 g	MS100780-100	\N	\N	2019-05-09
29	4-Trifluoromethyl-Phenylammonium iodide	\N	60 g	MS100790-100	\N	\N	2019-05-09
30	Cyclohexylmethylammonium iodide	\N	78 g	MS101840-50	\N	\N	2019-05-09
31	4-Fluoro-Phenethylammonium iodide	\N	54 g	MS100720-100	\N	\N	2019-05-09
32	Propane-1,3-diammonium iodide	\N	100 g	MS103003-100	\N	\N	2019-05-09
33	2-Pyrrolidin-1-ium-1-ylethylammonium iodide	\N	200 g	MS122972-100	\N	\N	2019-05-09
34	5-Azaspiro[4.4]nonan-5-ium iodide	\N	200 g	MS199700-100	\N	\N	2019-05-09
35	1,4-Benzene diammonium iodide	\N	186.5 g	MS108005-100	\N	\N	2019-05-09
36	Butane-1,4-diammonium iodide	\N	200 g	MS104040-100	\N	\N	2019-05-09
37	t-Butylammonium iodide	\N	163 g	MS106000-100	\N	\N	2019-05-09
39	1,4-Diazabicyclo[2,2,2]octane-1,4-diium iodide	\N	200 g	MS129400-100	\N	\N	2019-05-09
40	Diethylammonium iodide	\N	179 g	MS112200-100	\N	\N	2019-05-09
41	N,N-Dimethylethane- 1,2-diammonium iodide	\N	200 g	MS122112-100	\N	\N	2019-05-09
42	N,N-dimethylpropane- 1,3-diammonium iodide	\N	200 g	MS123113-100	\N	\N	2019-05-09
44	N,N-Diethylpropane-1,3-diammonium iodide	\N	185.5 g	MS123223-100	\N	\N	2019-05-09
45	n-Octylammonium Iodide	\N	173 g	MS105500-100	\N	\N	2019-05-09
46	Phenylammonium iodide	\N	860 g 	MS108000-25	\N	\N	2019-05-09
47	Piperidinium iodide	\N	180 g	MS119800-100	\N	\N	\N
48	Pyridinium iodide	\N	175 g	MS129810-100	\N	\N	\N
49	Alanine Hydroiodide	\N	\N	need to find a cheaper source	\N	\N	\N
50	Piperazine-1,4-diium iodide	\N	200 g	MS119500-100	\N	\N	\N
51	Pralidoxime iodide	\N	\N	need to find a source 	\N	\N	\N
52	Quinuclidin-1-ium iodide	\N	20 g	\N	\N	\N	\N
53	Morpholinium Iodide	\N	159.5 g	MS110640-100	\N	\N	\N
54	4-Methoxy-Phenaethylammonium Iodide	\N	50 g	\N	\N	\N	\N
55	Di-isopropylammonium Iodide	\N	50 g	\N	\N	\N	\N
\N	Proposed Bromides	\N	\N	\N	\N	\N	\N
1	2-Pyrrolidin-1-ium-1-ylethylammonium bromide	\N	\N	\N	\N	\N	\N
2	Acetamidinium bromide	\N	100 g	\N	\N	\N	\N
3	5-Azaspiro[4.4]nonan-5-ium bromide	\N	\N	\N	\N	\N	\N
4	1,4-Benzenediammonium bromide	\N	\N	\N	\N	\N	\N
5	Benzylammonium bromide	\N	100 g	\N	\N	\N	\N
6	Butane-1,4-diammonium bromide	\N	\N	\N	\N	\N	\N
7	iso-Butylammonium bromide	\N	\N	\N	\N	\N	\N
8	n-Butylammonium bromide	\N	100 g	\N	\N	\N	\N
9	t-Butylammonium bromide	\N	\N	\N	\N	\N	\N
10	Cyclohexylammonium bromide	\N	\N	\N	\N	\N	\N
11	Cyclohexylmethylammonium bromide	\N	\N	\N	\N	\N	\N
12	1,4-Diazabicyclo[2,2,2]octane-1,4-diium bromide	\N	\N	\N	\N	\N	\N
13	Diethylammonium bromide	\N	\N	\N	\N	\N	\N
14	Dimethylammonium bromide	\N	\N	\N	\N	\N	\N
15	N,N-Dimethylethane- 1,2-diammonium bromide	\N	\N	\N	\N	\N	\N
16	N,N-dimethylpropane-1,3-diammonium bromide	\N	\N	\N	\N	\N	\N
17	n-Dodecylammonium bromide	\N	\N	\N	\N	\N	\N
18	Ethane-1,2-diammonium bromide	\N	\N	\N	\N	\N	\N
19	Ethylammonium bromide	\N	\N	\N	\N	\N	\N
20	4-Fluoro-Phenylammonium bromide	\N	\N	\N	\N	\N	\N
21	4-Fluoro- Benzylammonium bromide	\N	\N	\N	\N	\N	\N
22	4-Fluoro- Phenethylammonium bromide	\N	\N	\N	\N	\N	\N
23	Formamidinium bromide	\N	54 g	\N	\N	\N	\N
24	Guanidinium bromide	\N	100 g	\N	\N	\N	\N
25	n-Hexylammonium bromide	\N	\N	\N	\N	\N	\N
26	Imidazolium bromide	\N	100 g	\N	\N	\N	\N
27	4-Methoxy-Phenethylammonium bromide	\N	\N	\N	\N	\N	\N
28	4-Methoxy-Phenylammonium bromide	\N	\N	\N	\N	\N	\N
29	Methylammonium bromide	\N	\N	\N	\N	\N	\N
30	N,N-Diethylpropane-1,3-diammonium bromide	\N	\N	\N	\N	\N	\N
31	n-Octylammonium Bromide	\N	\N	\N	\N	\N	\N
32	tert-Octylammonium bromide	\N	\N	\N	\N	\N	\N
33	n-Pentylammonium Bromide	\N	\N	\N	\N	\N	\N
34	i-Pentylammonium bromide	\N	\N	\N	\N	\N	\N
35	neo-Pentylammonium bromide	\N	\N	\N	\N	\N	\N
36	Phenethylammonium bromide	\N	100 g	\N	\N	\N	\N
37	Phenylammonium bromide	\N	\N	\N	\N	\N	\N
38	Piperazine-1,4-diium bromide	\N	\N	\N	\N	\N	\N
39	Piperidinium bromide	\N	\N	\N	\N	\N	\N
40	Propane-1,3-diammonium bromide	\N	\N	\N	\N	\N	\N
41	iso-Propylammonium bromide	\N	\N	\N	\N	\N	\N
42	n-Propylammonium bromide	\N	\N	\N	\N	\N	\N
43	Pyrrolidinium bromide	\N	\N	\N	\N	\N	\N
44	Quinuclidin-1-ium bromide	\N	\N	\N	\N	\N	\N
45	4-Trifluoromethyl-Benzylammonium bromide	\N	\N	\N	\N	\N	\N
46	4-Trifluoromethyl-Phenylammonium bromide	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3500 (class 0 OID 24978)
-- Dependencies: 229
-- Data for Name: load_perov_desc; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.load_perov_desc (_raw_inchikey, _raw_smiles, _raw_molweight, _raw_smiles_standard, _raw_standard_molweight, "_prototype_ECPF4_256_6", "_feat_AtomCount_C", "_feat_AtomCount_N", "_feat_AvgPol", "_feat_MolPol", "_feat_Refractivity", "_feat_AliphaticRingCount", "_feat_AromaticRingCount", "_feat_Aliphatic AtomCount", "_feat_AromaticAtomCount", "_feat_BondCount", "_feat_CarboaliphaticRingCount", "_feat_CarboaromaticRingCount", "_feat_CarboRingCount", "_feat_ChainAtomCount", "_feat_ChiralCenterCount", "_feat_RingAtomCount", "_feat_SmallestRingSize", "_feat_LargestRingSize", "_feat_HeteroaliphaticRingCount", "_feat_HeteroaromaticRing Count", "_feat_RotatableBondCount", "_feat_BalabanIndex", "_feat_CyclomaticNumber", "_feat_HyperWienerIndex", "_feat_WienerIndex", "_feat_WienerPolarity", "_feat_MinimalProjectionArea", "_feat_MaximalProjectionArea", "_feat_MinimalProjectionRadius", "_feat_MaximalProjectionRadius", "_feat_LengthPerpendicularToTheMinArea", "_feat_LengthPerpendicularToTheMaxArea", "_feat_VanderWaalsVolume", "_feat_VanderWaalsSurfaceArea", "_feat_ASA", "_feat_ASA+", "_feat_ASA-", "_feat_ASA_H", "_feat_ASA_P", "_feat_PolarSurfaceArea", _feat_acceptorcount, "_feat_Accsitecount", _feat_donorcount, _feat_donsitecount, "_feat_fr_NH2", "_feat_fr_NH1", "_feat_fr_NH0", "_feat_fr_quatN", "_feat_fr_ArN", "_feat_fr_Ar_NH", "_feat_fr_Imine", _feat_fr_amidine, _feat_fr_dihydropyridine, _feat_fr_guanido, _feat_fr_piperdine, _feat_fr_piperzine, _feat_fr_pyridine, _feat_maximalprojectionsize, _feat_minimalprojectionsize, "_feat_molsurfaceareaVDWp", "_feat_msareaVDWp", "_feat_molsurfaceareaASAp", "_feat_msareaASAp", "_feat_ProtPolarSurfaceArea", "_feat_Protpsa", "_feat_Hacceptorcount", "_feat_Hdonorcount") FROM stdin;
YEJRWHAVMIAJKC-UHFFFAOYSA-N	C1CC(=O)OC1	86	O=C1CCCO1	86	0100000000000000000000000000000000010000000000000100001000000000000000000000010000000000000010000010000000000000000000000000010010000000001000000000100000000000000000000000000000001000000000000000000000000000000000001000100000000000000000010000000000000000	4	0	8	8	20	1	0	6	0	12	0	0	0	1	0	5	5	5	1	0	0	2	1	39	26	2	20	29	3	4	7	5	79	140	241	164	77	179	62	26	1	2	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	7	140	140	164	164	26	26	1	0
IAZDPXIOMUYVGZ-UHFFFAOYSA-N	CS(=O)C	78	CS(C)=O	78	0000010000000000000000000000000000000000000000000100000000000000000000000000000000000000000000001001000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000	2	0	8	8	21	0	0	4	0	9	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	21	28	3	4	7	5	73	134	258	144	114	216	42	17	1	2	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	7	134	134	144	144	17	17	1	0
BDAGIHXWWSANSR-UHFFFAOYSA-N	C(=O)O	46	OC=O	46	0000000000000000000000000000000000100000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000010001000000000000000000000000000000000000000000000000000000000000000000000000000000100001000000000000000000000000000000000	1	0	3	3	8	0	0	3	0	4	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	11	18	2	3	5	3	39	65	175	80	96	34	142	37	2	4	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	3	5	65	65	80	80	37	37	2	1
RQQRAHKHDFPBMC-UHFFFAOYSA-L	I[Pb]I	461	I[Pb]I	461	0000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000100000000000000010000000000000	0	0	13	20	27	0	0	3	0	2	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	15	34	2	5	10	4	92	125	288	81	208	0	288	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	4	10	125	125	81	81	0	0	0	0
XFYICZOIWSBQSK-UHFFFAOYSA-N	CC[NH3+].[I-]	173	CC[NH3+]	46	0000110000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000010000000	2	1	6	6	26	0	0	3	0	10	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	17	23	3	3	7	5	59	112	216	154	62	165	51	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	7	112	112	154	154	28	28	0	1
LLWRXQXPJMPHLR-UHFFFAOYSA-N	C[NH3+].[I-]	159	C[NH3+]	32	0000010000000000000000000000000000000000000000000000000010000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	1	1	4	4	21	0	0	2	0	7	0	0	0	2	0	0	0	0	0	0	0	1	0	1	1	0	14	17	2	3	5	5	43	81	191	137	55	130	62	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	5	81	81	137	137	28	28	0	1
UPHCENSIMPJEIS-UHFFFAOYSA-N	C1=CC=C(C=C1)CC[NH3+].[I-]	249	[NH3+]CCC1=CC=CC=C1	122	0001000000000000000000100100010000110000000000000000000110000000000100000000000000000000000010000000000000000000000010010000000000000001001000000000000000100000010000000000000000000000000010000000001000000000000000000000010000000000000000000000100010000000	8	1	15	15	51	0	1	3	6	21	0	1	1	3	0	6	6	6	0	0	2	2	1	203	94	8	25	47	3	5	10	6	130	218	305	218	86	256	48	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	10	218	218	218	218	28	28	0	1
GGYGJCFIYJVWIP-UHFFFAOYSA-N	CC(=[NH2+])N.[I-]	186	CC(N)=[NH2+]	59	0000010010000000000000000000000000000000000000000000000001000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000001000000010000001000000000000000000000000000000000000000000000000000	2	2	7	7	28	0	0	4	0	10	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	17	26	3	3	6	4	63	111	212	173	39	140	73	52	1	1	2	4	2	0	0	0	0	0	0	1	0	0	0	0	0	4	6	111	111	173	173	52	52	1	2
CALQKRVFTWDYDG-UHFFFAOYSA-N	CCCC[NH3+].[I-]	201	CCCC[NH3+]	74	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000100000000100000000000000000000000010000000	4	1	10	10	35	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	2	2	0	35	20	2	19	34	3	5	9	5	93	173	274	203	71	225	49	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	9	173	173	203	203	28	28	0	1
UUDRLGYROXTISK-UHFFFAOYSA-N	C(=[NH2+])(N)N.[I-]	187	NC(N)=[NH2+]	60	0000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000010000001000000000000000000000000000000000000000000000000000	1	3	6	6	27	0	0	4	0	9	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	16	26	3	3	6	4	57	96	185	121	64	70	116	78	2	2	3	6	3	0	0	0	0	0	0	0	0	1	0	0	0	4	6	96	96	121	121	78	78	2	3
YMWUJEATGCHHMB-UHFFFAOYSA-N	C(Cl)Cl	85	ClCCl	85	0000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000100000001000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	1	0	7	6	16	0	0	3	0	4	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	15	22	3	3	6	5	56	92	232	111	121	232	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	6	92	92	111	111	0	0	0	0
JMXLWMIFDJCGBV-UHFFFAOYSA-N	C[NH2+]C.[I-]	173	C[NH2+]C	46	0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000100000000000000000000000	2	1	6	6	26	0	0	3	0	10	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	17	23	3	3	7	5	60	116	229	159	70	198	31	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	5	7	116	116	159	159	17	17	0	1
KFQARYBEAKAXIC-UHFFFAOYSA-N	C1=CC=C(C=C1)[NH3+].[I-]	221	[NH3+]C1=CC=CC=C1	94	0101000000000000000100000000000000000000000000000000000010000000000100000000000000000000000010000000001000010000000000000001000000000001001000000000000000100000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000	6	1	11	12	41	0	1	1	6	15	0	1	1	1	0	6	6	6	0	0	0	2	1	71	42	5	20	39	3	4	8	4	96	156	249	179	70	198	52	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	4	8	156	156	179	179	28	28	0	1
NLJDBTZLVTWXRG-UHFFFAOYSA-N	CC(C)(C)[NH3+].[I-]	201	CC(C)(C)[NH3+]	74	0000010000000000000000000000000000000000000000000000000010000000000001000000000000000000000000100000000000000000000000000000000000010000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	4	1	10	10	35	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	0	3	0	22	16	0	26	29	3	3	6	6	94	177	242	175	67	207	34	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	6	177	177	175	175	28	28	0	1
GIAPQOZCVIEHNY-UHFFFAOYSA-N	[I-].[NH3+]CCC	187	CCC[NH3+]	60	0000110000000000000000000000000000010000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000100000000000000000000000010000000	3	1	8	8	30	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	1	2	0	15	10	1	18	29	3	4	8	5	77	143	243	178	66	194	49	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	143	143	178	178	28	28	0	1
QHJPGANWSLEMTI-UHFFFAOYSA-N	C(=N)[NH3+].[I-]	172	[NH3+]C=N	45	0000000000000000000000000100000000000000000000100000000010000000000000000000000000000000000000000000000000000000000000000000010000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000	1	2	5	5	34	0	0	3	0	7	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	14	20	2	3	6	4	47	78	176	147	29	33	143	51	1	1	2	4	0	1	0	1	0	0	0	0	0	0	0	0	0	4	6	78	78	124	124	52	52	1	2
WXTNTIQDYHIFEG-UHFFFAOYSA-N	C1C[NH+]2CC[NH+]1CC2.[I-].[I-]	368	C1C[NH+]2CC[NH+]1CC2	114	0000000000000000000000000000000000000000000000000000001000000000000100000000000000010000000000000000000000000000000001000000000000000000000000000000000000000000010000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000	6	2	13	13	56	2	0	8	0	23	0	0	0	0	0	8	6	6	2	0	0	2	2	87	54	7	30	35	3	4	7	7	123	214	223	223	0	205	18	9	0	0	2	2	0	2	0	2	0	0	0	0	0	0	0	3	0	7	7	214	214	223	223	9	9	0	2
LCTUISCIGMWMAT-UHFFFAOYSA-N	C1(=CC=C(C=C1)F)C[NH3+].[I-]	253	[NH3+]CC1=CC=C(F)C=C1	126	0000000100000000000000010000000010000000000000000000000110000010000100000000000000000000000010000000000000000000000000011000000001000001000100000000000000000010000000000000000000100000000000000100000000000000000000100100000000000000000000000000000010000000	7	1	13	13	46	0	1	3	6	18	0	1	1	3	0	6	6	6	0	0	1	2	1	187	90	9	24	44	3	5	10	5	118	194	280	186	94	201	78	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	10	194	194	186	186	28	28	0	1
NOHLSFNWSBZSBW-UHFFFAOYSA-N	C1(=CC=C(C=C1)F)CC[NH3+].[I-]	267	[NH3+]CCC1=CC=C(F)C=C1	140	0000000100000000000000010100000000110000000000000000000110000010000101000000000000000000000010000000000000000000000010010000000001000001000100000000000000000010000000000000000000010000000000000000001000000000000000100000000000000000000000000000100010000000	8	1	15	15	51	0	1	4	6	21	0	1	1	4	0	6	6	6	0	0	2	2	1	296	127	10	25	49	3	5	11	5	135	225	311	207	104	230	81	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	11	225	225	207	207	28	28	0	1
FJFIJIDZQADKEE-UHFFFAOYSA-N	C1(=CC=C(C=C1)F)[NH3+].[I-]	239	[NH3+]C1=CC=C(F)C=C1	112	0000000000000000000100010000000000000001000000000000000010000010000100000000000000000000000010000000001000010000000000000000000001000001000100000000000000000010000000000000000000000000000000000000000000100000000000100000000000000000000000000010000000000000	6	1	11	11	41	0	1	2	6	15	0	1	1	2	0	6	6	6	0	0	0	2	1	115	62	7	20	40	3	4	9	4	101	163	256	224	33	172	84	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	4	9	163	163	224	224	28	28	0	1
QRFXELVDJSDWHX-UHFFFAOYSA-N	C1(=CC=C(C=C1)OC)[NH3+].[I-]	251	COC1=CC=C([NH3+])C=C1	124	0010010000000000000100000000000001000001000100000000000010000000000100000000000000000000000010000000001000010000000000000000000001000001000000000000000101000000000000001000000000010100000000000000000000000000000000000000000001000000000000000010000000000000	7	1	14	14	47	0	1	3	6	19	0	1	1	3	0	6	6	6	0	0	1	2	1	187	90	9	24	46	3	5	10	6	122	204	313	245	68	242	71	37	1	2	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	10	204	204	245	245	37	37	1	1
SQXJHWOXNLTOOO-UHFFFAOYSA-N	C1(=CC=C(C=C1)C(F)(F)F)C[NH3+].[I-]	303	[NH3+]CC1=CC=C(C=C1)C(F)(F)F	176	0000010100000000000000000000000010000000000000000000000110000000001101000000000000000000000010000000000000000000000000111000000000000001000010100000000010000010001000000100000000100000000000000100000000000000000000010000000000000000000000000000000010000000	8	1	15	15	52	0	1	6	6	21	0	1	1	6	0	6	6	6	0	0	2	2	1	496	201	15	27	51	4	5	11	5	145	237	327	178	149	178	149	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	11	237	237	178	178	28	28	0	1
KOAGKPNEVYEZDU-UHFFFAOYSA-N	C1(=CC=C(C=C1)C(F)(F)F)[NH3+].[I-]	289	[NH3+]C1=CC=C(C=C1)C(F)(F)F	162	0000010000000000000100000000000000000001000000000000000010000000000101000000000000000000000010000000001000010000000000100000000100000001000000100000000010000010001000000100000000000000000000000000000000000000000000010000000000000000001000000010000000000000	7	1	13	13	47	0	1	5	6	18	0	1	1	5	0	6	6	6	0	0	1	2	1	340	152	13	24	47	3	5	10	5	128	206	302	190	112	146	156	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	10	206	206	190	190	28	28	0	1
MVPPADPHJFYWMZ-UHFFFAOYSA-N	C1=CC=C(C=C1)Cl	113	ClC1=CC=CC=C1	113	0001000000000000000000000000000000000000010000000000000000000000000100000000000000000000000010000000000000000000000000000001100000000001001000000000000000100000000000000000000000000000000000000000000000000000001000000000010001000000000000001000000000000000	6	0	11	12	31	0	1	1	6	12	0	1	1	1	0	6	6	6	0	0	0	2	1	71	42	5	20	39	4	4	8	3	96	152	265	120	146	265	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	3	8	152	152	120	120	0	0	0	0
CWJKVUQGXKYWTR-UHFFFAOYSA-N	CC(=[NH2+])N.[Br-]	139	CC(N)=[NH2+]	59	0000010010000000000000000000000000000000000000000000000001000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000001000000010000001000000000000000000000000000000000000000000000000000	2	2	7	7	28	0	0	4	0	10	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	17	26	3	3	6	4	63	111	212	173	39	140	73	52	1	1	2	4	2	0	0	0	0	0	0	1	0	0	0	0	0	4	6	111	111	173	173	52	52	1	2
QJFMCHRSDOLMHA-UHFFFAOYSA-N	C1=CC=C(C=C1)C[NH3+].[Br-]	188	[NH3+]CC1=CC=CC=C1	108	0001000000000000000000100000010000000000000000000000000110000000000100000000000000000000000010000000000000000000000000011000000000000001001000000000000000100000000000000000000000100000000000000100000000000000000000000000010000000000000000000000000010000000	7	1	13	14	46	0	1	2	6	18	0	1	1	2	0	6	6	6	0	0	1	2	1	122	64	7	25	42	4	5	9	5	113	187	273	197	76	227	46	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	9	187	187	197	197	28	28	0	1
PPCHYMCMRUGLHR-UHFFFAOYSA-N	C1=CC=C(C=C1)C[NH3+].[I-]	235	[NH3+]CC1=CC=CC=C1	108	0001000000000000000000100000010000000000000000000000000110000000000100000000000000000000000010000000000000000000000000011000000000000001001000000000000000100000000000000000000000100000000000000100000000000000000000000000010000000000000000000000000010000000	7	1	13	14	46	0	1	2	6	18	0	1	1	2	0	6	6	6	0	0	1	2	1	122	64	7	25	42	4	5	9	5	113	187	273	197	76	227	46	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	9	187	187	197	197	28	28	0	1
XAKAQFUGWUAPJN-UHFFFAOYSA-N	[I-].[NH3+]CCC(O)=O	217	[NH3+]CCC(O)=O	90	0000000000000001000000000000000000011000000000000000000110000000000000000000001000000000000100000000000000000000000000000000000000000000001000000000000000001000100000000000000000000000000000000000000000000000000001000100000000000100000000000000000010000000	3	1	9	8	32	0	0	6	0	13	0	0	0	6	0	0	0	0	0	0	2	3	0	58	32	3	20	33	3	4	8	5	87	149	243	162	82	109	134	65	2	4	2	4	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	149	149	162	162	65	65	2	2
KOECRLKKXSXCPB-UHFFFAOYSA-K	I[Bi](I)I	590	I[Bi](I)I	590	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000001000000000000000000000000000000000000000000000000000000000001000000010000000000000000000000000000000000000000000000	0	0	18	26	40	0	0	4	0	3	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	29	45	4	4	9	5	120	163	350	59	290	0	350	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	9	163	163	59	59	0	0	0	0
XQPRBTXUXXVTKB-UHFFFAOYSA-M	[I-].[Cs+]	260	[I-]	127	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	0	0	5	5	14	0	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	12	12	-1	-1	-1	-1	33	49	144	0	144	0	144	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	-1	49	49	0	0	0	0	0	0
ZMXDDKWLCZADIW-UHFFFAOYSA-N	CN(C)C=O	73	CN(C)C=O	73	0000010000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000001000000010001000000000100000000000000000000000000000000000000000000000000000000100000000000000001001000000000000000000000000000000	3	1	8	7	20	0	0	5	0	11	0	0	0	5	0	0	0	0	0	0	0	3	0	28	18	2	20	30	3	4	7	5	77	137	238	132	106	196	42	20	1	2	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	5	7	137	137	132	132	20	20	1	0
BCQZYUOYVLJOPE-UHFFFAOYSA-N	C(C[NH3+])[NH3+].[Br-].[Br-]	222	[NH3+]CC[NH3+]	62	0000000000000000000000000000000000010000000000000000000110000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000	2	2	8	7	40	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	1	2	0	15	10	1	18	28	3	4	8	5	74	131	209	191	18	112	97	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	5	8	131	131	191	191	55	55	0	2
IWNWLPUNKAYUAW-UHFFFAOYSA-N	C(C[NH3+])[NH3+].[I-].[I-]	316	[NH3+]CC[NH3+]	62	0000000000000000000000000000000000010000000000000000000110000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000	2	2	8	7	40	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	1	2	0	15	10	1	18	28	3	4	8	5	74	131	209	191	18	112	97	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	5	8	131	131	191	191	55	55	0	2
PNZDZRMOBIIQTC-UHFFFAOYSA-N	CC[NH3+].[Br-]	126	CC[NH3+]	46	0000110000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000010000000	2	1	6	6	26	0	0	3	0	10	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	17	23	3	3	7	5	59	112	216	154	62	165	51	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	7	112	112	154	154	28	28	0	1
QWANGZFTSGZRPZ-UHFFFAOYSA-N	C(=[NH2+])N.[Br-]	125	NC=[NH2+]	45	0000000010000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000010000000000000000100000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000	1	2	5	5	23	0	0	3	0	7	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	13	21	3	3	6	4	46	78	176	124	53	64	113	52	1	1	2	4	2	0	0	0	0	0	0	0	0	0	0	0	0	4	6	78	78	124	124	52	52	1	2
VQNVZLDDLJBKNS-UHFFFAOYSA-N	C(=[NH2+])(N)N.[Br-]	140	NC(N)=[NH2+]	60	0000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000010000001000000000000000000000000000000000000000000000000000	1	3	6	6	27	0	0	4	0	9	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	16	26	3	3	6	4	57	96	185	121	64	70	116	78	2	2	3	6	3	0	0	0	0	0	0	0	0	1	0	0	0	4	6	96	96	121	121	78	78	2	3
VMLAEGAAHIIWJX-UHFFFAOYSA-N	CC(C)[NH3+].[I-]	187	CC(C)[NH3+]	60	0000010000001000000000000000000000000000000000000000000010001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000	3	1	8	8	30	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	22	28	3	3	7	5	77	142	227	168	59	185	42	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	7	142	142	168	168	28	28	0	1
JBOIAZWJIACNJF-UHFFFAOYSA-N	C1=CN=C[NH2+]1.[I-]	196	[NH2+]1C=CN=C1	69	0000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000010000000000010000000000000000101000000000001000000100100000000000000000000001000000011000000000000000000000000000000000000000000000000000010010000000000	3	2	7	7	31	1	0	5	0	10	0	0	0	0	0	5	5	5	1	0	0	2	1	20	15	0	17	26	3	3	6	4	63	90	164	145	19	62	102	29	1	1	1	2	1	0	1	1	0	0	1	0	0	0	0	0	0	4	6	91	91	172	172	26	26	1	2
RFYSBVUZWGEPBE-UHFFFAOYSA-N	CC(C)C[NH3+].[Br-]	154	CC(C)C[NH3+]	74	0000010000000000100000000000000000000000000000000000000110000000000000000000000000000000000000000000000010000000000000000000000000000001000000000000000000000100000000000010000000000000000000000000000000000000000000000000000000000000000000000000000010000000	4	1	10	10	35	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	1	3	0	28	18	2	22	34	3	4	8	5	94	172	248	190	58	206	43	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	172	172	190	190	28	28	0	1
FCTHQYIDLRRROX-UHFFFAOYSA-N	[I-].CC(C)C[NH3+]	201	CC(C)C[NH3+]	74	0000010000000000100000000000000000000000000000000000000110000000000000000000000000000000000000000000000010000000000000000000000000000001000000000000000000000100000000000010000000000000000000000000000000000000000000000000000000000000000000000000000010000000	4	1	10	10	35	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	1	3	0	28	18	2	22	34	3	4	8	5	94	172	248	190	58	206	43	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	172	172	190	190	28	28	0	1
UZHWWTHDRVLCJU-UHFFFAOYSA-N	CC(CC[NH3+])C.[I-]	215	CC(C)CC[NH3+]	88	0000010000000000100000000000000000010000000000000000000110000000000000000000000000000000000000000000000010100000000000000000000000000001000000000000000000000000000000000010000000000000000000000000000000000000010000000000000000000000000000001000000010000000	5	1	12	11	40	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	2	3	0	58	32	3	23	40	3	5	9	5	111	203	283	215	68	234	48	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	9	203	203	215	215	28	28	0	1
MCEUZMYFCCOOQO-UHFFFAOYSA-L	CC(=O)O[Pb]OC(=O)C.O.O.O	379	CC(=O)O[Pb]OC(C)=O	325	0010010000000000000000000000000001001000000000000000000011000000000000000000000000000000001110001010000000000000000000000000000000000000001000000000000000000000000100000000000000000000000000000000000001000000000000000000000000000000000000000010000000000000	4	0	12	18	23	0	0	9	0	14	0	0	0	9	0	0	0	0	0	0	4	3	0	265	108	6	24	48	3	6	12	5	133	212	410	268	142	222	188	53	2	4	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	12	212	212	268	268	53	53	2	0
ZASWJUOMEGBQCQ-UHFFFAOYSA-L	Br[Pb]Br	367	Br[Pb]Br	367	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000010000000100000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000	0	0	9	15	17	0	0	3	0	2	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	15	31	2	5	9	4	80	112	268	78	189	0	268	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	4	9	112	112	78	78	0	0	0	0
ISWNAMNOYHCTSB-UHFFFAOYSA-N	C[NH3+].[Br-]	112	C[NH3+]	32	0000010000000000000000000000000000000000000000000000000010000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	1	1	4	4	21	0	0	2	0	7	0	0	0	2	0	0	0	0	0	0	0	1	0	1	1	0	14	17	2	3	5	5	43	81	191	137	55	130	62	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	5	81	81	137	137	28	28	0	1
VAWHFUNJDMQUSB-UHFFFAOYSA-N	C1COCC[NH2+]1.[I-]	215	C1COCC[NH2+]1	88	1100000000000000000000000000000000000000100001000000001000000000000000000000000000000000000000000000000000000000000000000000010000000100000000000000100000000000000000000000000010000100000000000000001000000000010000000000000000000000000000000000000000000000	4	1	10	10	35	1	0	6	0	16	0	0	0	0	0	6	6	6	1	0	0	2	1	42	27	3	23	33	3	4	7	6	92	164	230	215	15	192	39	26	1	2	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	7	164	164	215	215	26	26	1	1
VZXFEELLBDNLAL-UHFFFAOYSA-N	CCCCCCCCCCCC[NH3+].[Br-]	266	CCCCCCCCCCCC[NH3+]	186	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000010000010000000000000000001000000000010000000000000000000000000000000000000000000000000001000000000000000001000001000000000000000100000000100001000000000000000000010000000	12	1	27	24	72	0	0	13	0	40	0	0	0	13	0	0	0	0	0	0	10	3	0	1365	364	10	33	81	4	10	19	7	229	418	525	399	126	482	43	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	7	19	418	418	399	399	28	28	0	1
PXWSKGXEHZHFJA-UHFFFAOYSA-N	[I-].CCCCCCCCCCCC[NH3+]	313	CCCCCCCCCCCC[NH3+]	186	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000010000010000000000000000001000000000010000000000000000000000000000000000000000000000000001000000000000000001000001000000000000000100000000100001000000000000000000010000000	12	1	27	24	72	0	0	13	0	40	0	0	0	13	0	0	0	0	0	0	10	3	0	1365	364	10	33	81	4	10	19	7	229	418	525	399	126	482	43	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	7	19	418	418	399	399	28	28	0	1
VNAAUNTYIONOHR-UHFFFAOYSA-N	CCCCCC[NH3+].[I-]	229	CCCCCC[NH3+]	102	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000000000010000000000000000001000000000010000000000000000000000000000000000000000000000000001000001000000000001000000000000000000000100000000100000000000000000000000010000000	6	1	14	13	44	0	0	7	0	22	0	0	0	7	0	0	0	0	0	0	4	2	0	126	56	4	21	46	3	6	12	6	127	234	328	246	82	286	42	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	12	234	234	246	246	28	28	0	1
HBZSVMFYMAOGRS-UHFFFAOYSA-N	CCCCCCCC[NH3+].[I-]	257	CCCCCCCC[NH3+]	130	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000010000010000000000000000001000000000010000000000000000000000000000000000000000000000000001000000000000000001000001000000000000000100000000100001000000000000000000010000000	8	1	18	17	53	0	0	9	0	28	0	0	0	9	0	0	0	0	0	0	6	3	0	330	120	6	24	58	3	7	14	5	161	296	394	297	97	352	42	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	14	296	296	297	297	28	28	0	1
FEUPHURYMJEUIH-UHFFFAOYSA-N	CC(C)(C)C[NH3+].[Br-]	168	CC(C)(C)C[NH3+]	88	0000010000000000000000000000000000000000000001000000000110000000000001000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000010000000000000000000000010000000000000000000000000000000000000000000000000000010000000	5	1	12	11	39	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	1	3	0	44	28	3	27	34	3	4	8	6	111	207	255	195	60	218	37	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	8	207	207	195	195	28	28	0	1
CQWGDVVCKBJLNX-UHFFFAOYSA-N	[I-].CC(C)(C)C[NH3+]	215	CC(C)(C)C[NH3+]	88	0000010000000000000000000000000000000000000001000000000110000000000001000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000010000000000000000000000010000000000000000000000000000000000000000000000000000010000000	5	1	12	11	39	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	1	3	0	44	28	3	27	34	3	4	8	6	111	207	255	195	60	218	37	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	8	207	207	195	195	28	28	0	1
IRAGENYJMTVCCV-UHFFFAOYSA-N	c1ccc(cc1)CC[NH3+].[Br-]	202	[NH3+]CCc1ccccc1	122	0001000000000000000000100100010000110000000000000000000110000000000100000000000000000000000010000000000000000000000010010000000000000001001000000000000000100000010000000000000000000000000010000000001000000000000000000000010000000000000000000000100010000000	8	1	15	15	51	0	1	3	6	21	0	1	1	3	0	6	6	6	0	0	2	2	1	203	94	8	25	47	3	5	10	6	130	218	305	218	86	256	48	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	10	218	218	218	218	28	28	0	1
UXWKNNJFYZFNDI-UHFFFAOYSA-N	C1C[NH2+]CC[NH2+]1.[Br-].[Br-]	248	C1C[NH2+]CC[NH2+]1	88	1000000000000000000000000000000000000000000000000000001000000000000000001000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000001000000000000001000000000010000000000000000000000000000000000000000000000	4	2	11	10	48	1	0	6	0	18	0	0	0	0	0	6	6	6	1	0	0	2	1	42	27	3	26	34	3	4	7	6	98	171	211	211	0	167	44	33	0	0	2	4	2	0	0	2	0	0	0	0	0	0	0	1	0	6	7	171	171	211	211	33	33	0	2
QZCGFUVVXNFSLE-UHFFFAOYSA-N	[I-].[I-].C1C[NH2+]CC[NH2+]1	342	C1C[NH2+]CC[NH2+]1	88	1000000000000000000000000000000000000000000000000000001000000000000000001000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000001000000000000001000000000010000000000000000000000000000000000000000000000	4	2	11	10	48	1	0	6	0	18	0	0	0	0	0	6	6	6	1	0	0	2	1	42	27	3	26	34	3	4	7	6	98	171	211	211	0	167	44	33	0	0	2	4	2	0	0	2	0	0	0	0	0	0	0	1	0	6	7	171	171	211	211	33	33	0	2
HBPSMMXRESDUSG-UHFFFAOYSA-N	C1CC[NH2+]CC1.[I-]	213	C1CC[NH2+]CC1	86	1000000000000000000000000000000000000000000000000000001000000000000000000010010000000000000000100000000000000000000000000100000000000110000000000000000000000000000000000000000000000000000000000000001000000000010000000000000000000000000000000000000000000000	5	1	11	11	38	1	0	6	0	18	0	0	0	0	0	6	6	6	1	0	0	2	1	42	27	3	27	35	4	4	7	5	100	178	228	173	56	206	22	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	1	0	0	5	7	178	178	173	173	17	17	0	1
IMROMDMJAWUWLK-UHFFFAOYSA-N	C{-}(OC(=O)C)C{n+}	92000	C	16	0000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	1	0	3	3	6	0	0	1	0	4	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	9	12	2	2	4	4	28	58	185	129	56	185	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	4	4	58	58	129	129	0	0	0	0
QNBVYCDYFJUNLO-UHDJGPCESA-N	CN1C=CC=CC1=C[NH+]=O.[I-]	264	CN1C=CC=CC1=C[NH+]=O	137	0010010000000010100000100000000000000000000100100010000000010100000000000100000100000000000011000000000000000010000000000000000000000011001000000000100000000000000000000000000000101000010000100000000000000000000010000000000010000000000000011000100000100000	7	2	14	15	53	1	0	10	0	19	0	0	0	4	0	6	6	6	1	0	1	2	1	263	121	11	26	49	4	5	10	4	125	180	267	220	47	207	60	34	2	3	1	1	0	1	1	0	0	0	0	0	0	0	0	0	0	4	10	183	183	179	179	34	34	1	1
UMDDLGMCNFAZDX-UHFFFAOYSA-O	[NH3+]CCC[NH3+].[I-].[I-]	330	[NH3+]CCC[NH3+]	76	1000000000000000000000000000000000010000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000001000000010000000	3	2	10	9	45	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	2	2	0	35	20	2	20	34	3	5	9	5	91	162	241	198	43	143	98	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	5	9	162	162	198	198	55	55	0	2
VFDOIPKMSSDMCV-UHFFFAOYSA-N	C1CC[NH2+]C1.[Br-]	152	C1CC[NH2+]C1	72	1001000000000000000000000000000000000000000000000000001000000000000000000010010000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000001000000000010000000000000000000000000000000000000000000000	4	1	9	9	34	1	0	5	0	15	0	0	0	0	0	5	5	5	1	0	0	2	1	20	15	0	23	28	3	3	6	6	82	150	219	187	33	194	26	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	6	150	150	187	187	17	17	0	1
DMFMZFFIQRMJQZ-UHFFFAOYSA-N	C1CC[NH2+]C1.[I-]	199	C1CC[NH2+]C1	72	1001000000000000000000000000000000000000000000000000001000000000000000000010010000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000001000000000010000000000000000000000000000000000000000000000	4	1	9	9	34	1	0	5	0	15	0	0	0	0	0	5	5	5	1	0	0	2	1	20	15	0	23	28	3	3	6	6	82	150	219	187	33	194	26	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	6	150	150	187	187	17	17	0	1
DYEHDACATJUKSZ-UHFFFAOYSA-N	C1C[NH+]2CCC1CC2.[Br-]	192	C1C[NH+]2CCC1CC2	112	0000000000000000000000000000000000000000000000000000001000000000000100000000000000010000000000100000000000000010000000000000000000000000000000000000000000000000000000010100100000000000101000000000000000000000000000000000000000100000000000000000000000000000	7	1	14	14	46	2	0	8	0	23	0	0	0	0	0	8	6	6	2	0	0	2	2	87	54	7	30	35	3	4	7	7	124	214	228	183	45	219	9	4	0	0	1	1	0	1	0	1	0	0	0	0	0	0	3	0	0	7	7	214	214	183	183	4	4	0	1
LYHPZBKXSHVBDW-UHFFFAOYSA-N	C1C[NH+]2CCC1CC2.[I-]	239	C1C[NH+]2CCC1CC2	112	0000000000000000000000000000000000000000000000000000001000000000000100000000000000010000000000100000000000000010000000000000000000000000000000000000000000000000000000010100100000000000101000000000000000000000000000000000000000100000000000000000000000000000	7	1	14	14	46	2	0	8	0	23	0	0	0	0	0	8	6	6	2	0	0	2	2	87	54	7	30	35	3	4	7	7	124	214	228	183	45	219	9	4	0	0	1	1	0	1	0	1	0	0	0	0	0	0	3	0	0	7	7	214	214	183	183	4	4	0	1
UXYJHTKQEFCXBJ-UHFFFAOYSA-N	C(CC(C)(C)[NH3+])(C)(C)C.[I-]	257	CC(C)(C)CC(C)(C)[NH3+]	130	0000010000000000000100000000000000000000000000000000000110000000000001000100000000000000000000000000000000000000010000000000000000011000000011000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000	8	1	17	17	53	0	0	9	0	28	0	0	0	9	0	0	0	0	0	0	2	4	0	173	88	6	31	46	3	5	9	6	162	301	304	239	65	283	21	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	9	301	301	239	239	28	28	0	1
BJDYCCHRZIFCGN-UHFFFAOYSA-N	C1=CC=[NH+]C=C1.[I-]	207	C1=CC=[NH+]C=C1	80	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000001001000000000000000100010000000000000000000000001000000000100000000100000000000000000100000000000000000000000010000000000	5	1	9	10	25	0	1	0	6	12	0	0	0	0	0	6	6	6	0	1	0	2	1	42	27	3	19	34	3	4	7	3	80	133	240	222	17	185	55	14	0	0	1	1	0	1	0	0	0	1	0	0	0	0	0	0	1	3	7	133	133	222	222	14	14	0	1
ZEVRFFCPALTVDN-UHFFFAOYSA-N	C1CCC(CC1)C[NH3+].[I-]	241	[NH3+]CC1CCCCC1	114	0000000000000000000000100000000000000000000100000001001110000000000010000000010000000000000000010000000010000001000000000100000000000000000000010000000000000000000000000100000000000000000000000000000000000000000000000000000000100000001000000000000010000000	7	1	15	14	47	1	0	8	0	24	1	0	1	2	0	6	6	6	0	0	1	2	1	122	64	7	28	46	4	5	9	6	133	234	266	214	52	225	41	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	9	234	234	214	214	28	28	0	1
WGYRINYTHSORGH-UHFFFAOYSA-N	C1CCC(CC1)[NH3+].[I-]	227	[NH3+]C1CCCCC1	100	0000000000000000000000000000001000000000000100000000001010000100000000000000010000000000000000000000000000000000000000000100000000000000000000010000000000000000001000000100000000000000000001000000000000000000000000010000000000100000000000000000000000000000	6	1	13	13	42	1	0	7	0	21	1	0	1	1	0	6	6	6	0	0	0	2	1	71	42	5	27	40	4	4	8	5	116	203	240	190	50	200	40	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	203	203	190	190	28	28	0	1
XZUCBFLUEBDNSJ-UHFFFAOYSA-N	C(CC[NH3+])C[NH3+].[I-].[I-]	344	[NH3+]CCCC[NH3+]	90	1000000000000000000000000000000000010000000000000000000110000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000100000000000000000000000000000000010000000	4	2	12	11	50	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	3	2	0	70	35	3	20	39	3	5	10	5	108	193	273	230	43	175	98	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	5	10	193	193	230	230	55	55	0	2
RYYSZNVPBLKLRS-UHFFFAOYSA-N	C1=CC(=CC=C1[NH3+])[NH3+].[I-].[I-]	364	[NH3+]C1=CC=C([NH3+])C=C1	110	0000000000000000000100000000000000000001000000000000000010000000000100000000000000000000000010000000001000010000000000000000000000000001000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000010000000000000	6	2	13	13	56	0	1	2	6	18	0	1	1	2	0	6	6	6	0	0	0	2	1	115	62	7	22	43	4	4	9	4	110	176	257	257	0	153	104	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	4	9	176	176	257	257	55	55	0	2
DWOWCUCDJIERQX-UHFFFAOYSA-M	C1CC[N+]2(C1)CCCC2.[I-]	253	C1CC[N+]2(C1)CCCC2	126	0000000000000000010000000000000001000000000000000000001000000000000100000000010000000000000000100000000000000000001000010000000000001000000100001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	8	1	16	15	51	2	0	9	0	26	0	0	0	0	0	9	5	5	2	0	0	2	2	140	78	8	30	42	3	4	9	6	141	252	264	241	23	264	0	0	0	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	6	9	252	252	241	241	0	0	0	0
YYMLRIWBISZOMT-UHFFFAOYSA-N	CC[NH2+]CC.[I-]	201	CC[NH2+]CC	74	0000110000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000010000000000010000000000000001000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000	4	1	10	10	36	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	2	2	0	35	20	2	19	34	3	5	9	6	94	178	287	207	81	268	20	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	9	178	178	207	207	17	17	0	1
UVLZLKCGKYLKOR-UHFFFAOYSA-N	C1CC[NH+](C1)CC[NH3+].[I-].[I-]	370	[NH3+]CC[NH+]1CCCC1	116	0000000000000000000000010000000000010000000000000001001110000000000100000000010000010000000000000000000000000000000000000000010000000100000000000000000000001000000000000000010000000000001000000000000000000000000010000000000000000000001010000000000010000000	6	2	15	14	58	1	0	8	0	24	0	0	0	3	0	5	5	5	1	0	2	2	1	135	67	5	26	44	3	5	10	6	131	235	281	258	23	227	55	32	0	0	2	4	0	1	0	2	0	0	0	0	0	0	0	0	0	6	10	235	235	258	258	32	32	0	2
BAMDIFIROXTEEM-UHFFFAOYSA-N	C[NH+](C)CC[NH3+].[I-].[I-]	344	C[NH+](C)CC[NH3+]	90	0000010000000000000000100000000000010000000000000000000110000000001000000000000000001000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000000000000000000010010000000	4	2	12	11	50	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	2	3	0	58	32	3	23	39	3	5	9	5	109	202	275	229	46	219	56	32	0	0	2	4	0	1	0	2	0	0	0	0	0	0	0	0	0	5	9	202	202	229	229	32	32	0	2
JERSPYRKVMAEJY-UHFFFAOYSA-N	C[NH+](C)CCC[NH3+].[I-].[I-]	358	C[NH+](C)CCC[NH3+]	104	1000010000000000000000000000000010010000000000000000000110000000001000000000000000001000000000000000000000000000000000000000010000000000000000000110000000000000000000000000000000000000000000000000000000000000011000100000000000000000000000000000000010000000	5	2	14	13	55	0	0	7	0	22	0	0	0	7	0	0	0	0	0	0	3	3	0	108	52	4	25	45	3	5	10	6	126	233	309	244	65	251	57	32	0	0	2	4	0	1	0	2	0	0	0	0	0	0	0	0	0	6	10	233	233	244	244	32	32	0	2
NXRUEVJQMBGVAT-UHFFFAOYSA-N	CC[NH+](CC)CCC[NH3+].[I-].[I-]	386	CC[NH+](CC)CCC[NH3+]	132	1000110000000000000000000000000000010000100000000000000110000000001000000000000000001000000000000000000000000000000000000000000000100000000000000100001000000000000000000000000000000000000000000001000000000001000000100001000100000010000000000000000010000000	7	2	18	17	65	0	0	9	0	28	0	0	0	9	0	0	0	0	0	0	5	3	0	242	104	8	34	56	4	5	11	6	160	294	359	286	74	305	55	32	0	0	2	4	0	1	0	2	0	0	0	0	0	0	0	0	0	6	11	294	294	286	286	32	32	0	2
PBGZCCFVBVEIAS-UHFFFAOYSA-N	CC(C)[NH2+]C(C)C.[I-]	229	CC(C)[NH2+]C(C)C	102	0000010000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000010000000000000000000000000000010000000000000001000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000100000000000000	6	1	14	13	44	0	0	7	0	22	0	0	0	7	0	0	0	0	0	0	2	3	0	91	48	4	29	41	3	4	8	6	128	237	302	231	71	289	14	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	8	237	237	231	231	17	17	0	1
QNNYEDWTOZODAS-UHFFFAOYSA-N	[I-].[NH3+](CCC1=CC=C(C=C1)OC)	279	COC1=CC=C(CC[NH3+])C=C1	152	0010010100000000000000000100000001110000100100000000000110000000000101000000000000000000000010000000000000000000000010010010000001000001000000000000000100000000000000001000000000010000000000000000001000000000000000000000000001000000000000000000100010000000	9	1	18	18	57	0	1	5	6	25	0	1	1	5	0	6	6	6	0	0	3	2	1	432	170	12	28	54	3	6	12	6	156	266	371	294	77	304	67	37	1	2	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	12	266	266	294	294	37	37	1	1
WGWKNMLSVLOQJB-UHFFFAOYSA-N	CC(C)[NH3+].[Br-]	140	CC(C)[NH3+]	60	0000010000001000000000000000000000000000000000000000000010001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000	3	1	8	8	30	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	22	28	3	3	7	5	77	142	227	168	59	185	42	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	7	142	142	168	168	28	28	0	1
YEJRWHAVMIAJKC-UHFFFAOYSA-N	C1CC(=O)OC1	86	O=C1CCCO1	86	0100000000000000000000000000000000010000000000000100001000000000000000000000010000000000000010000010000000000000000000000000010010000000001000000000100000000000000000000000000000001000000000000000000000000000000000001000100000000000000000010000000000000000	4	0	8	8	20	1	0	6	0	12	0	0	0	1	0	5	5	5	1	0	0	2	1	39	26	2	20	29	3	4	7	5	79	140	241	164	77	179	62	26	1	2	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	7	140	140	164	164	26	26	1	0
IAZDPXIOMUYVGZ-UHFFFAOYSA-N	CS(=O)C	78	CS(C)=O	78	0000010000000000000000000000000000000000000000000100000000000000000000000000000000000000000000001001000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000	2	0	8	8	21	0	0	4	0	9	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	21	28	3	4	7	5	73	134	258	144	114	216	42	17	1	2	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	7	134	134	144	144	17	17	1	0
BDAGIHXWWSANSR-UHFFFAOYSA-N	C(=O)O	46	OC=O	46	0000000000000000000000000000000000100000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000010001000000000000000000000000000000000000000000000000000000000000000000000000000000100001000000000000000000000000000000000	1	0	3	3	8	0	0	3	0	4	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	11	18	2	3	5	3	39	65	175	80	96	34	142	37	2	4	1	1	0	0	0	0	0	0	0	0	0	0	0	0	0	3	5	65	65	80	80	37	37	2	1
RQQRAHKHDFPBMC-UHFFFAOYSA-L	I[Pb]I	461	I[Pb]I	461	0000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000100000000000000010000000000000	0	0	13	20	27	0	0	3	0	2	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	15	34	2	5	10	4	92	125	288	81	208	0	288	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	4	10	125	125	81	81	0	0	0	0
XFYICZOIWSBQSK-UHFFFAOYSA-N	CC[NH3+].[I-]	173	CC[NH3+]	46	0000110000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000010000000	2	1	6	6	26	0	0	3	0	10	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	17	23	3	3	7	5	59	112	216	154	62	165	51	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	7	112	112	154	154	28	28	0	1
LLWRXQXPJMPHLR-UHFFFAOYSA-N	C[NH3+].[I-]	159	C[NH3+]	32	0000010000000000000000000000000000000000000000000000000010000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	1	1	4	4	21	0	0	2	0	7	0	0	0	2	0	0	0	0	0	0	0	1	0	1	1	0	14	17	2	3	5	5	43	81	191	137	55	130	62	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	5	81	81	137	137	28	28	0	1
UPHCENSIMPJEIS-UHFFFAOYSA-N	C1=CC=C(C=C1)CC[NH3+].[I-]	249	[NH3+]CCC1=CC=CC=C1	122	0001000000000000000000100100010000110000000000000000000110000000000100000000000000000000000010000000000000000000000010010000000000000001001000000000000000100000010000000000000000000000000010000000001000000000000000000000010000000000000000000000100010000000	8	1	15	15	51	0	1	3	6	21	0	1	1	3	0	6	6	6	0	0	2	2	1	203	94	8	25	47	3	5	10	6	130	218	305	218	86	256	48	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	10	218	218	218	218	28	28	0	1
GGYGJCFIYJVWIP-UHFFFAOYSA-N	CC(=[NH2+])N.[I-]	186	CC(N)=[NH2+]	59	0000010010000000000000000000000000000000000000000000000001000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000001000000010000001000000000000000000000000000000000000000000000000000	2	2	7	7	28	0	0	4	0	10	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	17	26	3	3	6	4	63	111	212	173	39	140	73	52	1	1	2	4	2	0	0	0	0	0	0	1	0	0	0	0	0	4	6	111	111	173	173	52	52	1	2
CALQKRVFTWDYDG-UHFFFAOYSA-N	CCCC[NH3+].[I-]	201	CCCC[NH3+]	74	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000100000000100000000000000000000000010000000	4	1	10	10	35	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	2	2	0	35	20	2	19	34	3	5	9	5	93	173	274	203	71	225	49	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	9	173	173	203	203	28	28	0	1
UUDRLGYROXTISK-UHFFFAOYSA-N	C(=[NH2+])(N)N.[I-]	187	NC(N)=[NH2+]	60	0000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000010000001000000000000000000000000000000000000000000000000000	1	3	6	6	27	0	0	4	0	9	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	16	26	3	3	6	4	57	96	185	121	64	70	116	78	2	2	3	6	3	0	0	0	0	0	0	0	0	1	0	0	0	4	6	96	96	121	121	78	78	2	3
YMWUJEATGCHHMB-UHFFFAOYSA-N	C(Cl)Cl	85	ClCCl	85	0000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000100000001000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	1	0	7	6	16	0	0	3	0	4	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	15	22	3	3	6	5	56	92	232	111	121	232	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	6	92	92	111	111	0	0	0	0
JMXLWMIFDJCGBV-UHFFFAOYSA-N	C[NH2+]C.[I-]	173	C[NH2+]C	46	0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000100000000000000000000000	2	1	6	6	26	0	0	3	0	10	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	17	23	3	3	7	5	60	116	229	159	70	198	31	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	5	7	116	116	159	159	17	17	0	1
KFQARYBEAKAXIC-UHFFFAOYSA-N	C1=CC=C(C=C1)[NH3+].[I-]	221	[NH3+]C1=CC=CC=C1	94	0101000000000000000100000000000000000000000000000000000010000000000100000000000000000000000010000000001000010000000000000001000000000001001000000000000000100000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000	6	1	11	12	41	0	1	1	6	15	0	1	1	1	0	6	6	6	0	0	0	2	1	71	42	5	20	39	3	4	8	4	96	156	249	179	70	198	52	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	4	8	156	156	179	179	28	28	0	1
NLJDBTZLVTWXRG-UHFFFAOYSA-N	CC(C)(C)[NH3+].[I-]	201	CC(C)(C)[NH3+]	74	0000010000000000000000000000000000000000000000000000000010000000000001000000000000000000000000100000000000000000000000000000000000010000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	4	1	10	10	35	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	0	3	0	22	16	0	26	29	3	3	6	6	94	177	242	175	67	207	34	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	6	177	177	175	175	28	28	0	1
GIAPQOZCVIEHNY-UHFFFAOYSA-N	[I-].[NH3+]CCC	187	CCC[NH3+]	60	0000110000000000000000000000000000010000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000100000000000000000000000010000000	3	1	8	8	30	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	1	2	0	15	10	1	18	29	3	4	8	5	77	143	243	178	66	194	49	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	143	143	178	178	28	28	0	1
QHJPGANWSLEMTI-UHFFFAOYSA-N	C(=N)[NH3+].[I-]	172	[NH3+]C=N	45	0000000000000000000000000100000000000000000000100000000010000000000000000000000000000000000000000000000000000000000000000000010000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000	1	2	5	5	34	0	0	3	0	7	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	14	20	2	3	6	4	47	78	176	147	29	33	143	51	1	1	2	4	0	1	0	1	0	0	0	0	0	0	0	0	0	4	6	78	78	124	124	52	52	1	2
WXTNTIQDYHIFEG-UHFFFAOYSA-N	C1C[NH+]2CC[NH+]1CC2.[I-].[I-]	368	C1C[NH+]2CC[NH+]1CC2	114	0000000000000000000000000000000000000000000000000000001000000000000100000000000000010000000000000000000000000000000001000000000000000000000000000000000000000000010000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000	6	2	13	13	56	2	0	8	0	23	0	0	0	0	0	8	6	6	2	0	0	2	2	87	54	7	30	35	3	4	7	7	123	214	223	223	0	205	18	9	0	0	2	2	0	2	0	2	0	0	0	0	0	0	0	3	0	7	7	214	214	223	223	9	9	0	2
LCTUISCIGMWMAT-UHFFFAOYSA-N	C1(=CC=C(C=C1)F)C[NH3+].[I-]	253	[NH3+]CC1=CC=C(F)C=C1	126	0000000100000000000000010000000010000000000000000000000110000010000100000000000000000000000010000000000000000000000000011000000001000001000100000000000000000010000000000000000000100000000000000100000000000000000000100100000000000000000000000000000010000000	7	1	13	13	46	0	1	3	6	18	0	1	1	3	0	6	6	6	0	0	1	2	1	187	90	9	24	44	3	5	10	5	118	194	280	186	94	201	78	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	10	194	194	186	186	28	28	0	1
NOHLSFNWSBZSBW-UHFFFAOYSA-N	C1(=CC=C(C=C1)F)CC[NH3+].[I-]	267	[NH3+]CCC1=CC=C(F)C=C1	140	0000000100000000000000010100000000110000000000000000000110000010000101000000000000000000000010000000000000000000000010010000000001000001000100000000000000000010000000000000000000010000000000000000001000000000000000100000000000000000000000000000100010000000	8	1	15	15	51	0	1	4	6	21	0	1	1	4	0	6	6	6	0	0	2	2	1	296	127	10	25	49	3	5	11	5	135	225	311	207	104	230	81	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	11	225	225	207	207	28	28	0	1
FJFIJIDZQADKEE-UHFFFAOYSA-N	C1(=CC=C(C=C1)F)[NH3+].[I-]	239	[NH3+]C1=CC=C(F)C=C1	112	0000000000000000000100010000000000000001000000000000000010000010000100000000000000000000000010000000001000010000000000000000000001000001000100000000000000000010000000000000000000000000000000000000000000100000000000100000000000000000000000000010000000000000	6	1	11	11	41	0	1	2	6	15	0	1	1	2	0	6	6	6	0	0	0	2	1	115	62	7	20	40	3	4	9	4	101	163	256	224	33	172	84	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	4	9	163	163	224	224	28	28	0	1
QRFXELVDJSDWHX-UHFFFAOYSA-N	C1(=CC=C(C=C1)OC)[NH3+].[I-]	251	COC1=CC=C([NH3+])C=C1	124	0010010000000000000100000000000001000001000100000000000010000000000100000000000000000000000010000000001000010000000000000000000001000001000000000000000101000000000000001000000000010100000000000000000000000000000000000000000001000000000000000010000000000000	7	1	14	14	47	0	1	3	6	19	0	1	1	3	0	6	6	6	0	0	1	2	1	187	90	9	24	46	3	5	10	6	122	204	313	245	68	242	71	37	1	2	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	10	204	204	245	245	37	37	1	1
SQXJHWOXNLTOOO-UHFFFAOYSA-N	C1(=CC=C(C=C1)C(F)(F)F)C[NH3+].[I-]	303	[NH3+]CC1=CC=C(C=C1)C(F)(F)F	176	0000010100000000000000000000000010000000000000000000000110000000001101000000000000000000000010000000000000000000000000111000000000000001000010100000000010000010001000000100000000100000000000000100000000000000000000010000000000000000000000000000000010000000	8	1	15	15	52	0	1	6	6	21	0	1	1	6	0	6	6	6	0	0	2	2	1	496	201	15	27	51	4	5	11	5	145	237	327	178	149	178	149	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	11	237	237	178	178	28	28	0	1
KOAGKPNEVYEZDU-UHFFFAOYSA-N	C1(=CC=C(C=C1)C(F)(F)F)[NH3+].[I-]	289	[NH3+]C1=CC=C(C=C1)C(F)(F)F	162	0000010000000000000100000000000000000001000000000000000010000000000101000000000000000000000010000000001000010000000000100000000100000001000000100000000010000010001000000100000000000000000000000000000000000000000000010000000000000000001000000010000000000000	7	1	13	13	47	0	1	5	6	18	0	1	1	5	0	6	6	6	0	0	1	2	1	340	152	13	24	47	3	5	10	5	128	206	302	190	112	146	156	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	10	206	206	190	190	28	28	0	1
MVPPADPHJFYWMZ-UHFFFAOYSA-N	C1=CC=C(C=C1)Cl	113	ClC1=CC=CC=C1	113	0001000000000000000000000000000000000000010000000000000000000000000100000000000000000000000010000000000000000000000000000001100000000001001000000000000000100000000000000000000000000000000000000000000000000000001000000000010001000000000000001000000000000000	6	0	11	12	31	0	1	1	6	12	0	1	1	1	0	6	6	6	0	0	0	2	1	71	42	5	20	39	4	4	8	3	96	152	265	120	146	265	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	3	8	152	152	120	120	0	0	0	0
CWJKVUQGXKYWTR-UHFFFAOYSA-N	CC(=[NH2+])N.[Br-]	139	CC(N)=[NH2+]	59	0000010010000000000000000000000000000000000000000000000001000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000001000000010000001000000000000000000000000000000000000000000000000000	2	2	7	7	28	0	0	4	0	10	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	17	26	3	3	6	4	63	111	212	173	39	140	73	52	1	1	2	4	2	0	0	0	0	0	0	1	0	0	0	0	0	4	6	111	111	173	173	52	52	1	2
QJFMCHRSDOLMHA-UHFFFAOYSA-N	C1=CC=C(C=C1)C[NH3+].[Br-]	188	[NH3+]CC1=CC=CC=C1	108	0001000000000000000000100000010000000000000000000000000110000000000100000000000000000000000010000000000000000000000000011000000000000001001000000000000000100000000000000000000000100000000000000100000000000000000000000000010000000000000000000000000010000000	7	1	13	14	46	0	1	2	6	18	0	1	1	2	0	6	6	6	0	0	1	2	1	122	64	7	25	42	4	5	9	5	113	187	273	197	76	227	46	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	9	187	187	197	197	28	28	0	1
PPCHYMCMRUGLHR-UHFFFAOYSA-N	C1=CC=C(C=C1)C[NH3+].[I-]	235	[NH3+]CC1=CC=CC=C1	108	0001000000000000000000100000010000000000000000000000000110000000000100000000000000000000000010000000000000000000000000011000000000000001001000000000000000100000000000000000000000100000000000000100000000000000000000000000010000000000000000000000000010000000	7	1	13	14	46	0	1	2	6	18	0	1	1	2	0	6	6	6	0	0	1	2	1	122	64	7	25	42	4	5	9	5	113	187	273	197	76	227	46	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	9	187	187	197	197	28	28	0	1
XAKAQFUGWUAPJN-UHFFFAOYSA-N	[I-].[NH3+]CCC(O)=O	217	[NH3+]CCC(O)=O	90	0000000000000001000000000000000000011000000000000000000110000000000000000000001000000000000100000000000000000000000000000000000000000000001000000000000000001000100000000000000000000000000000000000000000000000000001000100000000000100000000000000000010000000	3	1	9	8	32	0	0	6	0	13	0	0	0	6	0	0	0	0	0	0	2	3	0	58	32	3	20	33	3	4	8	5	87	149	243	162	82	109	134	65	2	4	2	4	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	149	149	162	162	65	65	2	2
KOECRLKKXSXCPB-UHFFFAOYSA-K	I[Bi](I)I	590	I[Bi](I)I	590	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000001000000000000000000000000000000000000000000000000000000000001000000010000000000000000000000000000000000000000000000	0	0	18	26	40	0	0	4	0	3	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	29	45	4	4	9	5	120	163	350	59	290	0	350	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	9	163	163	59	59	0	0	0	0
XQPRBTXUXXVTKB-UHFFFAOYSA-M	[I-].[Cs+]	260	[I-]	127	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	0	0	5	5	14	0	0	1	0	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	12	12	-1	-1	-1	-1	33	49	144	0	144	0	144	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	-1	-1	49	49	0	0	0	0	0	0
ZMXDDKWLCZADIW-UHFFFAOYSA-N	CN(C)C=O	73	CN(C)C=O	73	0000010000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000001000000010001000000000100000000000000000000000000000000000000000000000000000000100000000000000001001000000000000000000000000000000	3	1	8	7	20	0	0	5	0	11	0	0	0	5	0	0	0	0	0	0	0	3	0	28	18	2	20	30	3	4	7	5	77	137	238	132	106	196	42	20	1	2	0	0	0	0	1	0	0	0	0	0	0	0	0	0	0	5	7	137	137	132	132	20	20	1	0
BCQZYUOYVLJOPE-UHFFFAOYSA-N	C(C[NH3+])[NH3+].[Br-].[Br-]	222	[NH3+]CC[NH3+]	62	0000000000000000000000000000000000010000000000000000000110000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000	2	2	8	7	40	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	1	2	0	15	10	1	18	28	3	4	8	5	74	131	209	191	18	112	97	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	5	8	131	131	191	191	55	55	0	2
IWNWLPUNKAYUAW-UHFFFAOYSA-N	C(C[NH3+])[NH3+].[I-].[I-]	316	[NH3+]CC[NH3+]	62	0000000000000000000000000000000000010000000000000000000110000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000	2	2	8	7	40	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	1	2	0	15	10	1	18	28	3	4	8	5	74	131	209	191	18	112	97	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	5	8	131	131	191	191	55	55	0	2
PNZDZRMOBIIQTC-UHFFFAOYSA-N	CC[NH3+].[Br-]	126	CC[NH3+]	46	0000110000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000010000000	2	1	6	6	26	0	0	3	0	10	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	17	23	3	3	7	5	59	112	216	154	62	165	51	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	7	112	112	154	154	28	28	0	1
QWANGZFTSGZRPZ-UHFFFAOYSA-N	C(=[NH2+])N.[Br-]	125	NC=[NH2+]	45	0000000010000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000010000000000010000000000000000100000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000	1	2	5	5	23	0	0	3	0	7	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	13	21	3	3	6	4	46	78	176	124	53	64	113	52	1	1	2	4	2	0	0	0	0	0	0	0	0	0	0	0	0	4	6	78	78	124	124	52	52	1	2
VQNVZLDDLJBKNS-UHFFFAOYSA-N	C(=[NH2+])(N)N.[Br-]	140	NC(N)=[NH2+]	60	0000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000100000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000010000001000000000000000000000000000000000000000000000000000	1	3	6	6	27	0	0	4	0	9	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	16	26	3	3	6	4	57	96	185	121	64	70	116	78	2	2	3	6	3	0	0	0	0	0	0	0	0	1	0	0	0	4	6	96	96	121	121	78	78	2	3
VMLAEGAAHIIWJX-UHFFFAOYSA-N	CC(C)[NH3+].[I-]	187	CC(C)[NH3+]	60	0000010000001000000000000000000000000000000000000000000010001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000	3	1	8	8	30	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	22	28	3	3	7	5	77	142	227	168	59	185	42	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	7	142	142	168	168	28	28	0	1
JBOIAZWJIACNJF-UHFFFAOYSA-N	C1=CN=C[NH2+]1.[I-]	196	[NH2+]1C=CN=C1	69	0000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000010000000000010000000000000000101000000000001000000100100000000000000000000001000000011000000000000000000000000000000000000000000000000000010010000000000	3	2	7	7	31	1	0	5	0	10	0	0	0	0	0	5	5	5	1	0	0	2	1	20	15	0	17	26	3	3	6	4	63	90	164	145	19	62	102	29	1	1	1	2	1	0	1	1	0	0	1	0	0	0	0	0	0	4	6	91	91	172	172	26	26	1	2
RFYSBVUZWGEPBE-UHFFFAOYSA-N	CC(C)C[NH3+].[Br-]	154	CC(C)C[NH3+]	74	0000010000000000100000000000000000000000000000000000000110000000000000000000000000000000000000000000000010000000000000000000000000000001000000000000000000000100000000000010000000000000000000000000000000000000000000000000000000000000000000000000000010000000	4	1	10	10	35	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	1	3	0	28	18	2	22	34	3	4	8	5	94	172	248	190	58	206	43	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	172	172	190	190	28	28	0	1
FCTHQYIDLRRROX-UHFFFAOYSA-N	[I-].CC(C)C[NH3+]	201	CC(C)C[NH3+]	74	0000010000000000100000000000000000000000000000000000000110000000000000000000000000000000000000000000000010000000000000000000000000000001000000000000000000000100000000000010000000000000000000000000000000000000000000000000000000000000000000000000000010000000	4	1	10	10	35	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	1	3	0	28	18	2	22	34	3	4	8	5	94	172	248	190	58	206	43	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	172	172	190	190	28	28	0	1
UZHWWTHDRVLCJU-UHFFFAOYSA-N	CC(CC[NH3+])C.[I-]	215	CC(C)CC[NH3+]	88	0000010000000000100000000000000000010000000000000000000110000000000000000000000000000000000000000000000010100000000000000000000000000001000000000000000000000000000000000010000000000000000000000000000000000000010000000000000000000000000000001000000010000000	5	1	12	11	40	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	2	3	0	58	32	3	23	40	3	5	9	5	111	203	283	215	68	234	48	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	9	203	203	215	215	28	28	0	1
MCEUZMYFCCOOQO-UHFFFAOYSA-L	CC(=O)O[Pb]OC(=O)C.O.O.O	379	CC(=O)O[Pb]OC(C)=O	325	0010010000000000000000000000000001001000000000000000000011000000000000000000000000000000001110001010000000000000000000000000000000000000001000000000000000000000000100000000000000000000000000000000000001000000000000000000000000000000000000000010000000000000	4	0	12	18	23	0	0	9	0	14	0	0	0	9	0	0	0	0	0	0	4	3	0	265	108	6	24	48	3	6	12	5	133	212	410	268	142	222	188	53	2	4	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	5	12	212	212	268	268	53	53	2	0
ZASWJUOMEGBQCQ-UHFFFAOYSA-L	Br[Pb]Br	367	Br[Pb]Br	367	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000010000000100000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000	0	0	9	15	17	0	0	3	0	2	0	0	0	3	0	0	0	0	0	0	0	2	0	5	4	0	15	31	2	5	9	4	80	112	268	78	189	0	268	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	4	9	112	112	78	78	0	0	0	0
ISWNAMNOYHCTSB-UHFFFAOYSA-N	C[NH3+].[Br-]	112	C[NH3+]	32	0000010000000000000000000000000000000000000000000000000010000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	1	1	4	4	21	0	0	2	0	7	0	0	0	2	0	0	0	0	0	0	0	1	0	1	1	0	14	17	2	3	5	5	43	81	191	137	55	130	62	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	5	81	81	137	137	28	28	0	1
VAWHFUNJDMQUSB-UHFFFAOYSA-N	C1COCC[NH2+]1.[I-]	215	C1COCC[NH2+]1	88	1100000000000000000000000000000000000000100001000000001000000000000000000000000000000000000000000000000000000000000000000000010000000100000000000000100000000000000000000000000010000100000000000000001000000000010000000000000000000000000000000000000000000000	4	1	10	10	35	1	0	6	0	16	0	0	0	0	0	6	6	6	1	0	0	2	1	42	27	3	23	33	3	4	7	6	92	164	230	215	15	192	39	26	1	2	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	7	164	164	215	215	26	26	1	1
VZXFEELLBDNLAL-UHFFFAOYSA-N	CCCCCCCCCCCC[NH3+].[Br-]	266	CCCCCCCCCCCC[NH3+]	186	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000010000010000000000000000001000000000010000000000000000000000000000000000000000000000000001000000000000000001000001000000000000000100000000100001000000000000000000010000000	12	1	27	24	72	0	0	13	0	40	0	0	0	13	0	0	0	0	0	0	10	3	0	1365	364	10	33	81	4	10	19	7	229	418	525	399	126	482	43	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	7	19	418	418	399	399	28	28	0	1
PXWSKGXEHZHFJA-UHFFFAOYSA-N	[I-].CCCCCCCCCCCC[NH3+]	313	CCCCCCCCCCCC[NH3+]	186	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000010000010000000000000000001000000000010000000000000000000000000000000000000000000000000001000000000000000001000001000000000000000100000000100001000000000000000000010000000	12	1	27	24	72	0	0	13	0	40	0	0	0	13	0	0	0	0	0	0	10	3	0	1365	364	10	33	81	4	10	19	7	229	418	525	399	126	482	43	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	7	19	418	418	399	399	28	28	0	1
VNAAUNTYIONOHR-UHFFFAOYSA-N	CCCCCC[NH3+].[I-]	229	CCCCCC[NH3+]	102	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000000000010000000000000000001000000000010000000000000000000000000000000000000000000000000001000001000000000001000000000000000000000100000000100000000000000000000000010000000	6	1	14	13	44	0	0	7	0	22	0	0	0	7	0	0	0	0	0	0	4	2	0	126	56	4	21	46	3	6	12	6	127	234	328	246	82	286	42	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	12	234	234	246	246	28	28	0	1
HBZSVMFYMAOGRS-UHFFFAOYSA-N	CCCCCCCC[NH3+].[I-]	257	CCCCCCCC[NH3+]	130	1000110000000000000000000000000000010001000000000000000110000000000000000000000000000010000010000000000000000001000000000010000000000000000000000000000000000000000000000000001000000000000000001000001000000000000000100000000100001000000000000000000010000000	8	1	18	17	53	0	0	9	0	28	0	0	0	9	0	0	0	0	0	0	6	3	0	330	120	6	24	58	3	7	14	5	161	296	394	297	97	352	42	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	14	296	296	297	297	28	28	0	1
FEUPHURYMJEUIH-UHFFFAOYSA-N	CC(C)(C)C[NH3+].[Br-]	168	CC(C)(C)C[NH3+]	88	0000010000000000000000000000000000000000000001000000000110000000000001000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000010000000000000000000000010000000000000000000000000000000000000000000000000000010000000	5	1	12	11	39	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	1	3	0	44	28	3	27	34	3	4	8	6	111	207	255	195	60	218	37	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	8	207	207	195	195	28	28	0	1
CQWGDVVCKBJLNX-UHFFFAOYSA-N	[I-].CC(C)(C)C[NH3+]	215	CC(C)(C)C[NH3+]	88	0000010000000000000000000000000000000000000001000000000110000000000001000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000010000000000000000000000010000000000000000000000000000000000000000000000000000010000000	5	1	12	11	39	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	1	3	0	44	28	3	27	34	3	4	8	6	111	207	255	195	60	218	37	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	8	207	207	195	195	28	28	0	1
IRAGENYJMTVCCV-UHFFFAOYSA-N	c1ccc(cc1)CC[NH3+].[Br-]	202	[NH3+]CCc1ccccc1	122	0001000000000000000000100100010000110000000000000000000110000000000100000000000000000000000010000000000000000000000010010000000000000001001000000000000000100000010000000000000000000000000010000000001000000000000000000000010000000000000000000000100010000000	8	1	15	15	51	0	1	3	6	21	0	1	1	3	0	6	6	6	0	0	2	2	1	203	94	8	25	47	3	5	10	6	130	218	305	218	86	256	48	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	10	218	218	218	218	28	28	0	1
UXWKNNJFYZFNDI-UHFFFAOYSA-N	C1C[NH2+]CC[NH2+]1.[Br-].[Br-]	248	C1C[NH2+]CC[NH2+]1	88	1000000000000000000000000000000000000000000000000000001000000000000000001000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000001000000000000001000000000010000000000000000000000000000000000000000000000	4	2	11	10	48	1	0	6	0	18	0	0	0	0	0	6	6	6	1	0	0	2	1	42	27	3	26	34	3	4	7	6	98	171	211	211	0	167	44	33	0	0	2	4	2	0	0	2	0	0	0	0	0	0	0	1	0	6	7	171	171	211	211	33	33	0	2
QZCGFUVVXNFSLE-UHFFFAOYSA-N	[I-].[I-].C1C[NH2+]CC[NH2+]1	342	C1C[NH2+]CC[NH2+]1	88	1000000000000000000000000000000000000000000000000000001000000000000000001000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000001000000000000001000000000010000000000000000000000000000000000000000000000	4	2	11	10	48	1	0	6	0	18	0	0	0	0	0	6	6	6	1	0	0	2	1	42	27	3	26	34	3	4	7	6	98	171	211	211	0	167	44	33	0	0	2	4	2	0	0	2	0	0	0	0	0	0	0	1	0	6	7	171	171	211	211	33	33	0	2
HBPSMMXRESDUSG-UHFFFAOYSA-N	C1CC[NH2+]CC1.[I-]	213	C1CC[NH2+]CC1	86	1000000000000000000000000000000000000000000000000000001000000000000000000010010000000000000000100000000000000000000000000100000000000110000000000000000000000000000000000000000000000000000000000000001000000000010000000000000000000000000000000000000000000000	5	1	11	11	38	1	0	6	0	18	0	0	0	0	0	6	6	6	1	0	0	2	1	42	27	3	27	35	4	4	7	5	100	178	228	173	56	206	22	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	1	0	0	5	7	178	178	173	173	17	17	0	1
IMROMDMJAWUWLK-UHFFFAOYSA-N	C{-}(OC(=O)C)C{n+}	92000	C	16	0000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	1	0	3	3	6	0	0	1	0	4	0	0	0	1	0	0	0	0	0	0	0	0	0	0	0	0	9	12	2	2	4	4	28	58	185	129	56	185	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	0	4	4	58	58	129	129	0	0	0	0
QNBVYCDYFJUNLO-UHDJGPCESA-N	CN1C=CC=CC1=C[NH+]=O.[I-]	264	CN1C=CC=CC1=C[NH+]=O	137	0010010000000010100000100000000000000000000100100010000000010100000000000100000100000000000011000000000000000010000000000000000000000011001000000000100000000000000000000000000000101000010000100000000000000000000010000000000010000000000000011000100000100000	7	2	14	15	53	1	0	10	0	19	0	0	0	4	0	6	6	6	1	0	1	2	1	263	121	11	26	49	4	5	10	4	125	180	267	220	47	207	60	34	2	3	1	1	0	1	1	0	0	0	0	0	0	0	0	0	0	4	10	183	183	179	179	34	34	1	1
UMDDLGMCNFAZDX-UHFFFAOYSA-O	[NH3+]CCC[NH3+].[I-].[I-]	330	[NH3+]CCC[NH3+]	76	1000000000000000000000000000000000010000000000000000000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000100000000000000000000000001000000010000000	3	2	10	9	45	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	2	2	0	35	20	2	20	34	3	5	9	5	91	162	241	198	43	143	98	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	5	9	162	162	198	198	55	55	0	2
VFDOIPKMSSDMCV-UHFFFAOYSA-N	C1CC[NH2+]C1.[Br-]	152	C1CC[NH2+]C1	72	1001000000000000000000000000000000000000000000000000001000000000000000000010010000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000001000000000010000000000000000000000000000000000000000000000	4	1	9	9	34	1	0	5	0	15	0	0	0	0	0	5	5	5	1	0	0	2	1	20	15	0	23	28	3	3	6	6	82	150	219	187	33	194	26	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	6	150	150	187	187	17	17	0	1
DMFMZFFIQRMJQZ-UHFFFAOYSA-N	C1CC[NH2+]C1.[I-]	199	C1CC[NH2+]C1	72	1001000000000000000000000000000000000000000000000000001000000000000000000010010000000000000000000000000000000000000000000000000000000110000000000000000000000000000000000000000000000000000000000000001000000000010000000000000000000000000000000000000000000000	4	1	9	9	34	1	0	5	0	15	0	0	0	0	0	5	5	5	1	0	0	2	1	20	15	0	23	28	3	3	6	6	82	150	219	187	33	194	26	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	6	150	150	187	187	17	17	0	1
DYEHDACATJUKSZ-UHFFFAOYSA-N	C1C[NH+]2CCC1CC2.[Br-]	192	C1C[NH+]2CCC1CC2	112	0000000000000000000000000000000000000000000000000000001000000000000100000000000000010000000000100000000000000010000000000000000000000000000000000000000000000000000000010100100000000000101000000000000000000000000000000000000000100000000000000000000000000000	7	1	14	14	46	2	0	8	0	23	0	0	0	0	0	8	6	6	2	0	0	2	2	87	54	7	30	35	3	4	7	7	124	214	228	183	45	219	9	4	0	0	1	1	0	1	0	1	0	0	0	0	0	0	3	0	0	7	7	214	214	183	183	4	4	0	1
LYHPZBKXSHVBDW-UHFFFAOYSA-N	C1C[NH+]2CCC1CC2.[I-]	239	C1C[NH+]2CCC1CC2	112	0000000000000000000000000000000000000000000000000000001000000000000100000000000000010000000000100000000000000010000000000000000000000000000000000000000000000000000000010100100000000000101000000000000000000000000000000000000000100000000000000000000000000000	7	1	14	14	46	2	0	8	0	23	0	0	0	0	0	8	6	6	2	0	0	2	2	87	54	7	30	35	3	4	7	7	124	214	228	183	45	219	9	4	0	0	1	1	0	1	0	1	0	0	0	0	0	0	3	0	0	7	7	214	214	183	183	4	4	0	1
UXYJHTKQEFCXBJ-UHFFFAOYSA-N	C(CC(C)(C)[NH3+])(C)(C)C.[I-]	257	CC(C)(C)CC(C)(C)[NH3+]	130	0000010000000000000100000000000000000000000000000000000110000000000001000100000000000000000000000000000000000000010000000000000000011000000011000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000	8	1	17	17	53	0	0	9	0	28	0	0	0	9	0	0	0	0	0	0	2	4	0	173	88	6	31	46	3	5	9	6	162	301	304	239	65	283	21	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	9	301	301	239	239	28	28	0	1
BJDYCCHRZIFCGN-UHFFFAOYSA-N	C1=CC=[NH+]C=C1.[I-]	207	C1=CC=[NH+]C=C1	80	0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000001001000000000000000100010000000000000000000000001000000000100000000100000000000000000100000000000000000000000010000000000	5	1	9	10	25	0	1	0	6	12	0	0	0	0	0	6	6	6	0	1	0	2	1	42	27	3	19	34	3	4	7	3	80	133	240	222	17	185	55	14	0	0	1	1	0	1	0	0	0	1	0	0	0	0	0	0	1	3	7	133	133	222	222	14	14	0	1
ZEVRFFCPALTVDN-UHFFFAOYSA-N	C1CCC(CC1)C[NH3+].[I-]	241	[NH3+]CC1CCCCC1	114	0000000000000000000000100000000000000000000100000001001110000000000010000000010000000000000000010000000010000001000000000100000000000000000000010000000000000000000000000100000000000000000000000000000000000000000000000000000000100000001000000000000010000000	7	1	15	14	47	1	0	8	0	24	1	0	1	2	0	6	6	6	0	0	1	2	1	122	64	7	28	46	4	5	9	6	133	234	266	214	52	225	41	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	9	234	234	214	214	28	28	0	1
WGYRINYTHSORGH-UHFFFAOYSA-N	C1CCC(CC1)[NH3+].[I-]	227	[NH3+]C1CCCCC1	100	0000000000000000000000000000001000000000000100000000001010000100000000000000010000000000000000000000000000000000000000000100000000000000000000010000000000000000001000000100000000000000000001000000000000000000000000010000000000100000000000000000000000000000	6	1	13	13	42	1	0	7	0	21	1	0	1	1	0	6	6	6	0	0	0	2	1	71	42	5	27	40	4	4	8	5	116	203	240	190	50	200	40	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	8	203	203	190	190	28	28	0	1
XZUCBFLUEBDNSJ-UHFFFAOYSA-N	C(CC[NH3+])C[NH3+].[I-].[I-]	344	[NH3+]CCCC[NH3+]	90	1000000000000000000000000000000000010000000000000000000110000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000100000000000000000000000000000000010000000	4	2	12	11	50	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	3	2	0	70	35	3	20	39	3	5	10	5	108	193	273	230	43	175	98	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	5	10	193	193	230	230	55	55	0	2
RYYSZNVPBLKLRS-UHFFFAOYSA-N	C1=CC(=CC=C1[NH3+])[NH3+].[I-].[I-]	364	[NH3+]C1=CC=C([NH3+])C=C1	110	0000000000000000000100000000000000000001000000000000000010000000000100000000000000000000000010000000001000010000000000000000000000000001000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000010000000000000	6	2	13	13	56	0	1	2	6	18	0	1	1	2	0	6	6	6	0	0	0	2	1	115	62	7	22	43	4	4	9	4	110	176	257	257	0	153	104	55	0	0	2	6	0	0	0	2	0	0	0	0	0	0	0	0	0	4	9	176	176	257	257	55	55	0	2
DWOWCUCDJIERQX-UHFFFAOYSA-M	C1CC[N+]2(C1)CCCC2.[I-]	253	C1CC[N+]2(C1)CCCC2	126	0000000000000000010000000000000001000000000000000000001000000000000100000000010000000000000000100000000000000000001000010000000000001000000100001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000	8	1	16	15	51	2	0	9	0	26	0	0	0	0	0	9	5	5	2	0	0	2	2	140	78	8	30	42	3	4	9	6	141	252	264	241	23	264	0	0	0	0	0	0	0	0	1	1	0	0	0	0	0	0	0	0	0	6	9	252	252	241	241	0	0	0	0
YYMLRIWBISZOMT-UHFFFAOYSA-N	CC[NH2+]CC.[I-]	201	CC[NH2+]CC	74	0000110000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000010000000000010000000000000001000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000	4	1	10	10	36	0	0	5	0	16	0	0	0	5	0	0	0	0	0	0	2	2	0	35	20	2	19	34	3	5	9	6	94	178	287	207	81	268	20	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	9	178	178	207	207	17	17	0	1
UVLZLKCGKYLKOR-UHFFFAOYSA-N	C1CC[NH+](C1)CC[NH3+].[I-].[I-]	370	[NH3+]CC[NH+]1CCCC1	116	0000000000000000000000010000000000010000000000000001001110000000000100000000010000010000000000000000000000000000000000000000010000000100000000000000000000001000000000000000010000000000001000000000000000000000000010000000000000000000001010000000000010000000	6	2	15	14	58	1	0	8	0	24	0	0	0	3	0	5	5	5	1	0	2	2	1	135	67	5	26	44	3	5	10	6	131	235	281	258	23	227	55	32	0	0	2	4	0	1	0	2	0	0	0	0	0	0	0	0	0	6	10	235	235	258	258	32	32	0	2
BAMDIFIROXTEEM-UHFFFAOYSA-N	C[NH+](C)CC[NH3+].[I-].[I-]	344	C[NH+](C)CC[NH3+]	90	0000010000000000000000100000000000010000000000000000000110000000001000000000000000001000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000011000000000000000000000000000000000010010000000	4	2	12	11	50	0	0	6	0	19	0	0	0	6	0	0	0	0	0	0	2	3	0	58	32	3	23	39	3	5	9	5	109	202	275	229	46	219	56	32	0	0	2	4	0	1	0	2	0	0	0	0	0	0	0	0	0	5	9	202	202	229	229	32	32	0	2
JERSPYRKVMAEJY-UHFFFAOYSA-N	C[NH+](C)CCC[NH3+].[I-].[I-]	358	C[NH+](C)CCC[NH3+]	104	1000010000000000000000000000000010010000000000000000000110000000001000000000000000001000000000000000000000000000000000000000010000000000000000000110000000000000000000000000000000000000000000000000000000000000011000100000000000000000000000000000000010000000	5	2	14	13	55	0	0	7	0	22	0	0	0	7	0	0	0	0	0	0	3	3	0	108	52	4	25	45	3	5	10	6	126	233	309	244	65	251	57	32	0	0	2	4	0	1	0	2	0	0	0	0	0	0	0	0	0	6	10	233	233	244	244	32	32	0	2
NXRUEVJQMBGVAT-UHFFFAOYSA-N	CC[NH+](CC)CCC[NH3+].[I-].[I-]	386	CC[NH+](CC)CCC[NH3+]	132	1000110000000000000000000000000000010000100000000000000110000000001000000000000000001000000000000000000000000000000000000000000000100000000000000100001000000000000000000000000000000000000000000001000000000001000000100001000100000010000000000000000010000000	7	2	18	17	65	0	0	9	0	28	0	0	0	9	0	0	0	0	0	0	5	3	0	242	104	8	34	56	4	5	11	6	160	294	359	286	74	305	55	32	0	0	2	4	0	1	0	2	0	0	0	0	0	0	0	0	0	6	11	294	294	286	286	32	32	0	2
PBGZCCFVBVEIAS-UHFFFAOYSA-N	CC(C)[NH2+]C(C)C.[I-]	229	CC(C)[NH2+]C(C)C	102	0000010000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000010000000000000000000000000000010000000000000001000000000000000000010000000000000100000000000000000000000000000000000000000000000000000000100000000000000	6	1	14	13	44	0	0	7	0	22	0	0	0	7	0	0	0	0	0	0	2	3	0	91	48	4	29	41	3	4	8	6	128	237	302	231	71	289	14	17	0	0	1	2	1	0	0	1	0	0	0	0	0	0	0	0	0	6	8	237	237	231	231	17	17	0	1
QNNYEDWTOZODAS-UHFFFAOYSA-N	[I-].[NH3+](CCC1=CC=C(C=C1)OC)	279	COC1=CC=C(CC[NH3+])C=C1	152	0010010100000000000000000100000001110000100100000000000110000000000101000000000000000000000010000000000000000000000010010010000001000001000000000000000100000000000000001000000000010000000000000000001000000000000000000000000001000000000000000000100010000000	9	1	18	18	57	0	1	5	6	25	0	1	1	5	0	6	6	6	0	0	3	2	1	432	170	12	28	54	3	6	12	6	156	266	371	294	77	304	67	37	1	2	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	6	12	266	266	294	294	37	37	1	1
WGWKNMLSVLOQJB-UHFFFAOYSA-N	CC(C)[NH3+].[Br-]	140	CC(C)[NH3+]	60	0000010000001000000000000000000000000000000000000000000010001000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000	3	1	8	8	30	0	0	4	0	13	0	0	0	4	0	0	0	0	0	0	0	2	0	12	9	0	22	28	3	3	7	5	77	142	227	168	59	185	42	28	0	0	1	3	0	0	0	1	0	0	0	0	0	0	0	0	0	5	7	142	142	168	168	28	28	0	1
\.


--
-- TOC entry 3522 (class 0 OID 27861)
-- Dependencies: 331
-- Data for Name: m_descriptor; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.m_descriptor (m_descriptor_id, m_descriptor_uuid, description, material_id, m_descriptor_class_id, m_descriptor_value_id, actor_id, status_id, ver, note_id, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3524 (class 0 OID 27873)
-- Dependencies: 333
-- Data for Name: m_descriptor_class; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.m_descriptor_class (m_descriptor_class_id, m_descriptor_class_uuid, description, note_id, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3526 (class 0 OID 27882)
-- Dependencies: 335
-- Data for Name: m_descriptor_value; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.m_descriptor_value (m_descriptor_value_id, m_descriptor_value_uuid, num_value, blob_value, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3514 (class 0 OID 27822)
-- Dependencies: 323
-- Data for Name: material; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.material (material_id, material_uuid, description, parent_material_id, actor_id, note_id, add_date, mod_date) FROM stdin;
1	6fbd676b-32d2-410f-a322-43438cdb072c	Gamma-Butyrolactone	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
2	250806fc-c727-4951-9596-2ad5a14bb452	Dimethyl sulfoxide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
3	261627f3-92b5-4e22-861f-7632c867a4ee	Formic Acid	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
4	c9a2ad5f-0f4e-43cc-9889-913e2c44db95	Lead Diiodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
5	f9166e34-d04e-4b45-b0cd-78a7014f7336	Ethylammonium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
6	1f0e6236-310a-4ed5-8f6c-b18a2fc9bf46	Methylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
7	ba1527cb-64fd-48a5-bd1e-41fcdd2e04a7	Phenethylammonium iodide 	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
8	65074da7-ca56-4803-900a-1ea26dbbd431	Acetamidinium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
9	a1f3e176-2d1f-4c7f-bae6-c94d81e86aa7	n-Butylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
10	5490c5d6-fa88-48bd-81b6-d7f63eecc822	Guanidinium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
11	31d0b5b0-ec9a-4624-99fc-509f33eda637	Dichloromethane	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
12	1fa69dab-bc8c-4ccd-81c1-e61ee995a7a1	Dimethylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
13	eafa9047-6c41-45e7-bad2-b345ffa3f702	Phenylammonium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
14	0b567dc7-d4e4-44dd-8ef7-f72bea4adb89	t-Butylammonium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
15	8b092bdc-1fe6-41aa-9394-c0b131909240	N-propylammonium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
16	e96766d3-c2cc-40f6-b8bc-440ba3b73083	Formamidinium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
17	c355abfd-4630-47b0-9f6a-cb43134a29f4	1,4-Diazabicyclo[2,2,2]octane-1,4-diium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
18	36c81867-48bf-4439-8c14-8eb6fb50bb6a	4-Fluoro-Benzylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
19	7fb78aab-c408-42de-abe5-8396b39b391b	4-Fluoro-Phenethylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
20	2010388b-c449-4c75-be17-3996b8556045	4-Fluoro-Phenylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
21	f94e8506-6225-4805-ab4d-c573a7944c9a	4-Methoxy-Phenylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
22	c118f351-b239-411c-9796-51c25482367e	4-Trifluoromethyl-Benzylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
23	54eb1c45-9a33-4766-8151-305328a83e41	4-Trifluoromethyl-Phenylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
24	d672bd54-9b46-40ce-bfe3-bd18a94b91f9	chlorobenzene	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
25	e5b97930-04d8-41e3-bef7-b3acb501d080	Acetamidinium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
26	80ce68f1-de67-4d4d-9297-64809e8313f2	Benzylammonium Bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
27	58240d52-6c4b-4b8f-97d6-bad86a1d1d6e	Benzylammonium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
28	902ac077-84a7-436a-a7cb-e5473bfb1b9a	Beta Alanine Hydroiodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
29	61107c2e-f341-439b-982f-69fab2f48076	Bismuth iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
30	de328437-b453-4a24-a06e-dea88257964e	Cesium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
31	52755019-7054-479c-9744-7cdcf4b325c9	Dimethylformamide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
32	e743e550-4f5b-495d-acf7-2340af7c1354	Ethane-1,2-diammonium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
33	ff082f47-fb25-46d0-aefa-17a0579fe56a	Ethane-1,2-diammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
34	416494f1-b297-4251-8400-1691926365d8	Ethylammonium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
35	2491ea4e-fc49-4979-92fd-03ab418a0ce4	Formamidinium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
36	7e311cc7-c841-4821-820d-d91a54c89b1b	Guanidinium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
37	fe65dbff-d06e-41ae-8d7c-c9f41ab5ec0c	i-Propylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
38	caf3e3ae-cf91-4d44-92bc-40b7cd4cde74	Imidazolium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
39	ec0b0e6a-116c-4e26-8729-263f62649395	iso-Butylammonium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
40	7278445d-ee39-4611-82ce-dc35ff080243	iso-Butylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
41	c81df1a7-a8f5-48d0-b253-8702b3131043	iso-Pentylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
42	080e8b41-9875-4823-8e42-a0b7dbd6ded2	Lead(II) acetate trihydrate	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
43	1e2a9cf6-6e02-4129-921e-39b2d8ca4a8a	Lead(II) bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
44	eab42ec5-d050-4526-8b32-6698bacd4180	Methylammonium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
45	c4055af8-58dc-440a-820f-9853194ed48b	Morpholinium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
46	7ecc7068-c734-424e-93ac-12f884bd718c	n-Dodecylammonium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
47	5b0a61c3-8f8a-4648-bfc2-6774291fa95a	n-Dodecylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
48	cc0a95fa-32ef-4620-93d1-213551fbf550	n-Hexylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
49	9ef32ad6-162a-4904-b8b5-d5875ba9c4a2	n-Octylammonium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
50	73561380-18fd-448d-8a3b-1ca5e3de4e68	neo-Pentylammonium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
51	68134e55-9b27-4b03-9ecd-6ae846d45f7e	neo-Pentylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
52	db4cdd19-9aca-4ab3-8b9f-5491b5038e68	Phenethylammonium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
53	843fe3c0-7533-4fbd-914b-17efd8727f97	piperazine dihydrobromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
54	ed2d8ae6-65f3-46dc-8077-40d32be1d751	Piperazine-1,4-diium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
55	95aba68a-46ac-4f3a-8ab2-d299dd64d622	Piperidinium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
56	f433dda9-6698-436a-b163-5b7e872680e1	Poly(vinyl alcohol), Mw89000-98000, >99% hydrolyzed)	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
57	b8efc3e1-6c1b-4b84-ba4e-f7d839e65cd4	Pralidoxime iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
58	ccfb0afe-0333-436f-938e-9e33c7e861b2	Propane-1,3-diammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
59	1dde8f8d-d522-4a57-bc94-6dde5e85cef8	Pyrrolidinium Bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
60	cdc386d3-9b7a-403d-985a-916a2bf593aa	Pyrrolidinium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
61	3f26b368-36f1-465c-aadd-b952f7028c16	Quinuclidin-1-ium bromide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
62	2af87c04-f2de-492c-b3cf-b5f00c29f893	Quinuclidin-1-ium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
63	8b0ae689-5464-4a59-95bd-b1c04c6225dd	tert-Octylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
64	d94f694d-260e-4d1d-95fb-b7a01c7c6cdd	Pyridinium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
65	760cd8b3-c990-41a5-be7f-24497135261f	Cyclohexylmethylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
66	70c25345-a92c-4a84-a564-397e0738ab94	Cyclohexylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
67	47db7f3b-627d-453d-a63c-a918f8d73dfe	Butane-1,4-diammonium Iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
68	dd57fdff-2061-4f63-b02b-a2c3840a105e	1,4-Benzene diammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
69	abd98cab-b82c-40d4-9a36-7343494295fd	5-Azaspiro[4.4]nonan-5-ium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
70	f39294df-a56b-4129-addb-24bbd85b42e3	Diethylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
71	b8beee41-0c73-4ef1-9a87-ecce133d135a	2-Pyrrolidin-1-ium-1-ylethylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
72	1e6c543c-4898-414f-8a70-45deaf9a50e2	N,N-Dimethylethane- 1,2-diammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
73	7cb0c132-2c57-415d-b3d0-09739931a939	N,N-dimethylpropane- 1,3-diammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
74	fed200d8-79d8-4255-9fc8-20207bf4d04a	N,N-Diethylpropane-1,3-diammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
75	620e5df7-1e8b-401a-9a94-c0044c073aa3	Di-isopropylammonium iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
76	9920e581-33f6-4e7b-b33e-c0c667143caf	4-methoxy-phenethylammonium-iodide	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
77	7ece546b-7a92-45de-aedd-e8533d99e876	Iso-Propylammonium Bromide 	\N	1	\N	2019-12-06 18:35:16.697741+00	2019-12-06 18:35:16.697741+00
\.


--
-- TOC entry 3518 (class 0 OID 27840)
-- Dependencies: 327
-- Data for Name: material_ref; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.material_ref (material_ref_id, material_ref_uuid, material_id, material_type_id, add_date, mod_date) FROM stdin;
1	226cd366-e935-46bb-a9a0-50a0f87c2719	1	1	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
2	544ecd7b-f603-4f88-ba8e-a5732db7c25f	2	1	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
3	cec9833e-edec-4348-960b-c231d5cc1144	3	5	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
4	db345733-4d0b-4212-aee9-8e96b86cfb99	4	4	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
5	b321a938-cb39-4f8a-bd24-1858f29cce43	5	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
6	365dee16-b2df-4886-9195-d96ff6f58aa6	6	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
7	a1495256-eae8-4f7f-9edd-92e3942dd493	7	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
8	5e004185-0cbf-42fc-8938-616c05fd10ed	8	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
9	d6ce8d4a-ffd6-4d4d-9d36-e37d1e8baf7d	9	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
10	8b2529df-cd9b-44b0-94c0-56a3ee127dde	10	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
11	e0b20516-6567-48b0-8eb1-9f03db09c860	11	1	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
12	7da7f93b-a05f-4881-b5e1-5eaab4e7ac78	12	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
13	3919e91b-6138-4f6d-8158-3695bb994dcd	13	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
14	6a4593b2-996a-4787-97fb-9c877e479de1	14	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
15	25a20dfb-ce73-455c-a416-bcc9c9a60301	15	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
16	785cd060-bf8d-4a7e-a7b6-16126887175c	16	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
17	ca61efa3-0a6d-4d29-8a71-5bcbb2e8f551	17	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
18	ad26950f-5f6f-463a-85b9-cd33f8594ce6	18	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
19	0072f45d-23d5-4277-86a6-c4e4ee9ed9b2	19	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
20	74f6db50-3045-46a5-9dd8-68728e904e93	20	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
21	46b71da0-246d-439b-88eb-6755af4b2ba1	21	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
22	335a0c58-d8f9-42e0-9c72-3d217bfeefa6	22	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
23	8b35778d-5215-49a3-983b-df0e40bb71d5	23	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
24	dfef38fe-c565-4e03-9ac1-29098cb4d719	24	1	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
25	139bb369-5a2a-4207-bd26-8e7a89fd7ae8	25	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
26	ac8f8440-1644-4ac8-8a06-3ac5d68c3489	26	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
27	2b3be23d-39d6-4262-a6a7-73ebf1e19e54	27	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
28	cdaeaf56-4ad6-423c-9d8c-172017b68b6d	28	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
29	2471905a-d469-4894-a1ce-588ad8b0c33d	29	4	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
30	eb3d3ffc-8ee1-456b-a93f-eb2e43d5a3a7	30	4	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
31	020cf9ef-4076-4180-90c0-764b75c65b9b	31	1	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
32	82c4b67b-83c1-4cc0-b63e-42fa641b9f6c	32	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
33	4bbcf01d-c6c0-45ce-b127-b8be94c8458d	33	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
34	95defe63-1254-4225-a55a-300e75e14009	34	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
35	025b8b8c-7d6f-4f9c-90ff-37507b5a676e	35	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
36	2a437969-2cc1-44ad-bfd6-434189aeed54	36	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
37	41eb7709-655e-43c6-8cee-0066aa57c9a9	37	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
38	25a8ab31-f9e9-439c-b9db-c2689ebd9a1a	38	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
39	5950f244-00fb-4562-a257-35228f8ed366	39	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
40	842e6556-b69f-4771-bd3c-a5c94c9cb671	40	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
41	73ea4ccc-5cc2-422c-8e33-914414c68d43	41	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
42	855c2c1b-4c98-4c37-b167-943cd635ab0e	42	4	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
43	bf8a7b64-c2be-41b8-876c-119f20605e99	43	4	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
44	7b3fb792-4d34-4855-97ef-11ce90cb470e	44	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
45	df2b5b12-990d-4f01-aafa-46bba41f2d38	45	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
46	6c7085e0-f4c6-4797-bbc8-d8c828645445	46	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
47	5dc3d956-556c-42df-8e28-222e9e8ccdf5	47	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
48	923d0fff-900a-4f32-a486-3c6c060f876d	48	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
49	b045644b-f042-4828-bfb7-6e9dbceb34fe	49	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
50	f39cb1f4-0c28-4747-83e9-916e8a197b69	50	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
51	ed54dd55-324c-453e-83c3-b44abb74cb30	51	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
52	d99a59b1-bbcd-4b20-8516-7b29dbf3fad6	52	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
53	3a01e739-6a19-44cd-ad97-aee476b835bb	53	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
54	bb857772-fd9b-484c-919b-d40185b3c232	54	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
55	2fc4f8c7-7f35-4eac-b000-fdf06fb57c15	55	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
56	9fdffa07-d5a7-418b-add3-03e114550201	56	3	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
57	273f31f1-ded7-44d5-a355-4906799e13aa	57	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
58	4554c403-0d32-4b0c-84a9-4311d9094705	58	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
59	dc1bb15c-05ce-4090-84be-2750aaff2fcc	59	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
60	9adb7ce6-f2c8-4073-982d-ba8ca36b744c	60	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
61	22f6221e-622a-45a9-8491-c32c61614e84	61	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
62	7b3c576a-450a-4ec8-be60-75144788eed6	62	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
63	538ebcd1-5a38-486b-93f0-07f8b08cb32c	63	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
64	6f8d627d-e197-455a-901f-669aa8575f95	64	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
65	ee150ac0-8b81-48bc-a3a5-b921977a6cb4	65	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
66	65b47648-e46c-4500-b457-607c89e73689	66	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
67	4ec17a88-b0db-4a88-b5b3-ae6c676e38b3	67	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
68	808a1bc2-c6a0-47c4-bfbf-2fe39ef34810	68	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
69	868bafdf-9b3d-4193-b74f-a8ecefcda697	69	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
70	d337ab3a-7712-46e4-85f9-505f1bf19a98	70	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
71	ff0156d0-4031-4be1-8d9d-8357fc061df7	71	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
72	497700f5-d2a5-4e06-ab02-f4f66d81d25d	72	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
73	a2cb4976-91ae-4c9b-8777-0602862a8610	73	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
74	81e41a4f-b3bc-414d-9b5d-2932a21e139b	74	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
75	f9c34063-b734-4f3d-b7b7-ae43b625f2cc	75	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
76	80754947-c1b5-4f00-a32c-001f68448ea0	76	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
77	04cc2294-f40d-460b-b52f-16980bd93df8	77	2	2019-12-06 18:35:16.701289+00	2019-12-06 18:35:16.701289+00
\.


--
-- TOC entry 3516 (class 0 OID 27831)
-- Dependencies: 325
-- Data for Name: material_type; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.material_type (material_type_id, material_type_uuid, description, note_id, add_date, mod_date) FROM stdin;
1	c4f67d1a-9771-42f6-92e6-6db26979a5c9	solvent	\N	2019-12-06 18:35:16.689281+00	2019-12-06 18:35:16.689281+00
2	a7c51cf7-b708-49e3-a87c-2d3c2437259f	organic	\N	2019-12-06 18:35:16.689281+00	2019-12-06 18:35:16.689281+00
3	95ef7be2-cc59-4f29-8ed1-029304f77bf6	polymer	\N	2019-12-06 18:35:16.689281+00	2019-12-06 18:35:16.689281+00
4	bb520d92-29ee-47f3-9bef-f0b979432522	inorganic	\N	2019-12-06 18:35:16.689281+00	2019-12-06 18:35:16.689281+00
5	467dda88-2018-4e5c-90f7-b513a4588b61	acid	\N	2019-12-06 18:35:16.689281+00	2019-12-06 18:35:16.689281+00
\.


--
-- TOC entry 3530 (class 0 OID 27903)
-- Dependencies: 339
-- Data for Name: measure; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.measure (measure_id, measure_uuid, measure_type_id, amount, unit, blob_amount, document_id, note_id, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3532 (class 0 OID 27915)
-- Dependencies: 341
-- Data for Name: measure_type; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.measure_type (measure_type_id, measure_type_uuid, description, note_id, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3534 (class 0 OID 27924)
-- Dependencies: 343
-- Data for Name: note; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.note (note_id, note_uuid, notetext, edocument_id, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3504 (class 0 OID 27768)
-- Dependencies: 313
-- Data for Name: organization; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.organization (organization_id, organization_uuid, description, full_name, short_name, address1, address2, city, state_province, zip, country, website_url, phone, note_id, add_date, mod_date) FROM stdin;
1	034ad259-902d-4d1d-9a14-e7608d9818ef	College	Haverford College	HC	370 Lancaster Ave.	\N	Haverford	PA 	19041	\N	http://www.haverford.edu	\N	\N	2019-12-06 18:34:56.294647+00	2019-12-06 18:34:56.294647+00
2	e557b12b-64a6-4cf6-876d-8f34b0b41cf9	Laboratory	Lawrence Berkeley National Laboratory	LBL	1 Cyclotron Rd.	\N	Berkeley	CA 	94720	\N	https://www.lbl.gov	\N	\N	2019-12-06 18:34:56.294647+00	2019-12-06 18:34:56.294647+00
3	41080a15-9c7b-4abd-8e9f-af3fce01fc80	Chemical vendor	Sigma-Aldrich	Sigma-Aldrich	3050 Spruce St.	\N	St Louis	MO 	63103	\N	http://www.sigmaaldrich.com	\N	\N	2019-12-06 18:34:56.294647+00	2019-12-06 18:34:56.294647+00
4	2b702fb9-8639-4754-a4e6-a7f536787606	Chemical vendor	Greatcell	Greatcell	\N	\N	Elanora	QLD	4221	\N	http://www.greatcellsolar.com/shop/	\N	\N	2019-12-06 18:34:56.294647+00	2019-12-06 18:34:56.294647+00
5	1abaf0e2-5c0f-43b4-af17-7e7aa2fcd241	Cheminfomatics software	ChemAxon	ChemAxon	\N	\N	\N	\N	\N	\N	https://chemaxon.com	\N	\N	2019-12-06 18:34:56.294647+00	2019-12-06 18:34:56.294647+00
6	8ecedd28-3aaa-469b-a349-aa74911f3805	Cheminfomatics software	RDKit open source software	RDKit	\N	\N	\N	\N	\N	\N	https://www.rdkit.org	\N	\N	2019-12-06 18:34:56.294647+00	2019-12-06 18:34:56.294647+00
\.


--
-- TOC entry 3506 (class 0 OID 27780)
-- Dependencies: 315
-- Data for Name: person; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.person (person_id, person_uuid, firstname, lastname, middlename, address1, address2, city, stateprovince, phone, email, title, suffix, organization_id, note_id, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3542 (class 0 OID 27963)
-- Dependencies: 351
-- Data for Name: status; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.status (status_id, description, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3508 (class 0 OID 27792)
-- Dependencies: 317
-- Data for Name: systemtool; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.systemtool (systemtool_id, systemtool_uuid, systemtool_name, description, systemtool_type_id, vendor, model, serial, ver, organization_id, note_id, add_date, mod_date) FROM stdin;
1	4274d702-44cf-4f9f-baba-c7b5e7256601	standardize	Chemical standardizer	1	ChemAxon	\N	\N	19.24.0	5	\N	2019-12-06 18:34:56.307185+00	2019-12-06 18:34:56.307185+00
2	17e537bf-60b7-49e4-ac34-7f5c4977ef8c	cxcalc	Chemical descriptor calculator	1	ChemAxon	\N	\N	19.24.0	5	\N	2019-12-06 18:34:56.307185+00	2019-12-06 18:34:56.307185+00
3	ff8872fb-3948-4552-b4d8-179381ef35cb	generatemd	Chemical fingerprint calculator	1	ChemAxon	\N	\N	19.6.0	5	\N	2019-12-06 18:34:56.307185+00	2019-12-06 18:34:56.307185+00
4	03249ab3-ca1d-468e-93e5-f3de0643a623	RDKit	Cheminformatics toolkit for Python	3	Open Source: RDKit	\N	\N	19.03.4	6	\N	2019-12-06 18:34:56.307185+00	2019-12-06 18:34:56.307185+00
\.


--
-- TOC entry 3510 (class 0 OID 27804)
-- Dependencies: 319
-- Data for Name: systemtool_type; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.systemtool_type (systemtool_type_id, systemtool_type_uuid, description, note_id, add_date, mod_date) FROM stdin;
1	ff863b92-a40b-41a4-a376-f2bdb8daf34e	Command-line tool	\N	2019-12-06 18:34:56.304362+00	2019-12-06 18:34:56.304362+00
2	eed0dea6-6fb5-454d-a908-e2aa93d21340	API	\N	2019-12-06 18:34:56.304362+00	2019-12-06 18:34:56.304362+00
3	f4742888-021b-42ac-a93b-f30c38453a84	Python toolkit	\N	2019-12-06 18:34:56.304362+00	2019-12-06 18:34:56.304362+00
\.


--
-- TOC entry 3538 (class 0 OID 27945)
-- Dependencies: 347
-- Data for Name: tag; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.tag (tag_id, tag_uuid, tag_type_id, description, note_id, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3540 (class 0 OID 27954)
-- Dependencies: 349
-- Data for Name: tag_type; Type: TABLE DATA; Schema: dev; Owner: escalate
--

COPY dev.tag_type (tag_type_id, tag_type_uuid, short_desscription, description, add_date, mod_date) FROM stdin;
\.


--
-- TOC entry 3568 (class 0 OID 0)
-- Dependencies: 209
-- Name: DOCUMENT_documentID_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev."DOCUMENT_documentID_seq"', 1, false);


--
-- TOC entry 3569 (class 0 OID 0)
-- Dependencies: 210
-- Name: NOTE_noteID_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev."NOTE_noteID_seq"', 1, false);


--
-- TOC entry 3570 (class 0 OID 0)
-- Dependencies: 211
-- Name: actor_actor_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.actor_actor_id_seq', 1, false);


--
-- TOC entry 3571 (class 0 OID 0)
-- Dependencies: 320
-- Name: actor_actor_id_seq1; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.actor_actor_id_seq1', 10, true);


--
-- TOC entry 3572 (class 0 OID 0)
-- Dependencies: 212
-- Name: alt_material_name_alt_material_name_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.alt_material_name_alt_material_name_id_seq', 1, false);


--
-- TOC entry 3573 (class 0 OID 0)
-- Dependencies: 328
-- Name: alt_material_name_alt_material_name_id_seq1; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.alt_material_name_alt_material_name_id_seq1', 385, true);


--
-- TOC entry 3574 (class 0 OID 0)
-- Dependencies: 344
-- Name: edocument_edocument_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.edocument_edocument_id_seq', 1, false);


--
-- TOC entry 3575 (class 0 OID 0)
-- Dependencies: 336
-- Name: inventory_inventory_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.inventory_inventory_id_seq', 1, false);


--
-- TOC entry 3576 (class 0 OID 0)
-- Dependencies: 213
-- Name: load_allamines_tier3_2_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.load_allamines_tier3_2_id_seq', 1, false);


--
-- TOC entry 3577 (class 0 OID 0)
-- Dependencies: 214
-- Name: load_allamines_tier3_2_standardized_k_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.load_allamines_tier3_2_standardized_k_id_seq', 1, false);


--
-- TOC entry 3578 (class 0 OID 0)
-- Dependencies: 215
-- Name: load_emole_smiid_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.load_emole_smiid_seq', 1, false);


--
-- TOC entry 3579 (class 0 OID 0)
-- Dependencies: 216
-- Name: load_emole_standardized_smiID_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev."load_emole_standardized_smiID_seq"', 1, false);


--
-- TOC entry 3580 (class 0 OID 0)
-- Dependencies: 332
-- Name: m_descriptor_class_m_descriptor_class_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.m_descriptor_class_m_descriptor_class_id_seq', 1, false);


--
-- TOC entry 3581 (class 0 OID 0)
-- Dependencies: 330
-- Name: m_descriptor_m_descriptor_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.m_descriptor_m_descriptor_id_seq', 1, false);


--
-- TOC entry 3582 (class 0 OID 0)
-- Dependencies: 334
-- Name: m_descriptor_value_m_descriptor_value_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.m_descriptor_value_m_descriptor_value_id_seq', 1, false);


--
-- TOC entry 3583 (class 0 OID 0)
-- Dependencies: 217
-- Name: material_material_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.material_material_id_seq', 1, false);


--
-- TOC entry 3584 (class 0 OID 0)
-- Dependencies: 322
-- Name: material_material_id_seq1; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.material_material_id_seq1', 1, false);


--
-- TOC entry 3585 (class 0 OID 0)
-- Dependencies: 218
-- Name: material_ref_material_ref_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.material_ref_material_ref_id_seq', 1, false);


--
-- TOC entry 3586 (class 0 OID 0)
-- Dependencies: 326
-- Name: material_ref_material_ref_id_seq1; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.material_ref_material_ref_id_seq1', 77, true);


--
-- TOC entry 3587 (class 0 OID 0)
-- Dependencies: 219
-- Name: material_type_material_type_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.material_type_material_type_id_seq', 1, false);


--
-- TOC entry 3588 (class 0 OID 0)
-- Dependencies: 324
-- Name: material_type_material_type_id_seq1; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.material_type_material_type_id_seq1', 5, true);


--
-- TOC entry 3589 (class 0 OID 0)
-- Dependencies: 338
-- Name: measure_measure_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.measure_measure_id_seq', 1, false);


--
-- TOC entry 3590 (class 0 OID 0)
-- Dependencies: 340
-- Name: measure_type_measure_type_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.measure_type_measure_type_id_seq', 1, false);


--
-- TOC entry 3591 (class 0 OID 0)
-- Dependencies: 342
-- Name: note_note_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.note_note_id_seq', 1, false);


--
-- TOC entry 3592 (class 0 OID 0)
-- Dependencies: 220
-- Name: organization_organization_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.organization_organization_id_seq', 1, false);


--
-- TOC entry 3593 (class 0 OID 0)
-- Dependencies: 312
-- Name: organization_organization_id_seq1; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.organization_organization_id_seq1', 6, true);


--
-- TOC entry 3594 (class 0 OID 0)
-- Dependencies: 221
-- Name: person_person_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.person_person_id_seq', 1, false);


--
-- TOC entry 3595 (class 0 OID 0)
-- Dependencies: 314
-- Name: person_person_id_seq1; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.person_person_id_seq1', 1, false);


--
-- TOC entry 3596 (class 0 OID 0)
-- Dependencies: 350
-- Name: status_status_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.status_status_id_seq', 1, false);


--
-- TOC entry 3597 (class 0 OID 0)
-- Dependencies: 222
-- Name: system_system_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.system_system_id_seq', 1, false);


--
-- TOC entry 3598 (class 0 OID 0)
-- Dependencies: 316
-- Name: systemtool_systemtool_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.systemtool_systemtool_id_seq', 4, true);


--
-- TOC entry 3599 (class 0 OID 0)
-- Dependencies: 318
-- Name: systemtool_type_systemtool_type_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.systemtool_type_systemtool_type_id_seq', 3, true);


--
-- TOC entry 3600 (class 0 OID 0)
-- Dependencies: 223
-- Name: systemtype_systemtype_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.systemtype_systemtype_id_seq', 1, false);


--
-- TOC entry 3601 (class 0 OID 0)
-- Dependencies: 346
-- Name: tag_tag_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.tag_tag_id_seq', 1, false);


--
-- TOC entry 3602 (class 0 OID 0)
-- Dependencies: 348
-- Name: tag_type_tag_type_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.tag_type_tag_type_id_seq', 1, false);


--
-- TOC entry 3603 (class 0 OID 0)
-- Dependencies: 224
-- Name: trigger_test_tt_id_seq; Type: SEQUENCE SET; Schema: dev; Owner: escalate
--

SELECT pg_catalog.setval('dev.trigger_test_tt_id_seq', 1, false);


--
-- TOC entry 3290 (class 2606 OID 28005)
-- Name: actor idx_actor; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT idx_actor UNIQUE (person_id, organization_id, systemtool_id);


--
-- TOC entry 3292 (class 2606 OID 28003)
-- Name: actor pk_actor_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT pk_actor_id PRIMARY KEY (actor_id);

ALTER TABLE dev.actor CLUSTER ON pk_actor_id;


--
-- TOC entry 3300 (class 2606 OID 28030)
-- Name: alt_material_name pk_alt_material_name_alt_material_name_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.alt_material_name
    ADD CONSTRAINT pk_alt_material_name_alt_material_name_id PRIMARY KEY (alt_material_name_id);

ALTER TABLE dev.alt_material_name CLUSTER ON pk_alt_material_name_alt_material_name_id;


--
-- TOC entry 3316 (class 2606 OID 28090)
-- Name: edocument pk_edocument_edocument_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.edocument
    ADD CONSTRAINT pk_edocument_edocument_id PRIMARY KEY (edocument_id);

ALTER TABLE dev.edocument CLUSTER ON pk_edocument_edocument_id;


--
-- TOC entry 3308 (class 2606 OID 28063)
-- Name: inventory pk_inventory_inventory_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT pk_inventory_inventory_id PRIMARY KEY (inventory_id);

ALTER TABLE dev.inventory CLUSTER ON pk_inventory_inventory_id;


--
-- TOC entry 3304 (class 2606 OID 28048)
-- Name: m_descriptor_class pk_m_descriptor_class_m_descriptor_class_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor_class
    ADD CONSTRAINT pk_m_descriptor_class_m_descriptor_class_id PRIMARY KEY (m_descriptor_class_id);

ALTER TABLE dev.m_descriptor_class CLUSTER ON pk_m_descriptor_class_m_descriptor_class_id;


--
-- TOC entry 3302 (class 2606 OID 28039)
-- Name: m_descriptor pk_m_descriptor_m_descriptor_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT pk_m_descriptor_m_descriptor_id PRIMARY KEY (m_descriptor_id);

ALTER TABLE dev.m_descriptor CLUSTER ON pk_m_descriptor_m_descriptor_id;


--
-- TOC entry 3306 (class 2606 OID 28054)
-- Name: m_descriptor_value pk_m_descriptor_value_m_descriptor_value_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor_value
    ADD CONSTRAINT pk_m_descriptor_value_m_descriptor_value_id PRIMARY KEY (m_descriptor_value_id);

ALTER TABLE dev.m_descriptor_value CLUSTER ON pk_m_descriptor_value_m_descriptor_value_id;


--
-- TOC entry 3294 (class 2606 OID 28012)
-- Name: material pk_material_material_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material
    ADD CONSTRAINT pk_material_material_id PRIMARY KEY (material_id);

ALTER TABLE dev.material CLUSTER ON pk_material_material_id;


--
-- TOC entry 3298 (class 2606 OID 28024)
-- Name: material_ref pk_material_ref_material_ref_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material_ref
    ADD CONSTRAINT pk_material_ref_material_ref_id PRIMARY KEY (material_ref_id);

ALTER TABLE dev.material_ref CLUSTER ON pk_material_ref_material_ref_id;


--
-- TOC entry 3296 (class 2606 OID 28018)
-- Name: material_type pk_material_type_material_type_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material_type
    ADD CONSTRAINT pk_material_type_material_type_id PRIMARY KEY (material_type_id);

ALTER TABLE dev.material_type CLUSTER ON pk_material_type_material_type_id;


--
-- TOC entry 3310 (class 2606 OID 28069)
-- Name: measure pk_measure_measure_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.measure
    ADD CONSTRAINT pk_measure_measure_id PRIMARY KEY (measure_id);

ALTER TABLE dev.measure CLUSTER ON pk_measure_measure_id;


--
-- TOC entry 3312 (class 2606 OID 28078)
-- Name: measure_type pk_measure_type_measure_type_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.measure_type
    ADD CONSTRAINT pk_measure_type_measure_type_id PRIMARY KEY (measure_type_id);

ALTER TABLE dev.measure_type CLUSTER ON pk_measure_type_measure_type_id;


--
-- TOC entry 3314 (class 2606 OID 28084)
-- Name: note pk_note_note_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.note
    ADD CONSTRAINT pk_note_note_id PRIMARY KEY (note_id);

ALTER TABLE dev.note CLUSTER ON pk_note_note_id;


--
-- TOC entry 3282 (class 2606 OID 27970)
-- Name: organization pk_organization_organization_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.organization
    ADD CONSTRAINT pk_organization_organization_id PRIMARY KEY (organization_id);

ALTER TABLE dev.organization CLUSTER ON pk_organization_organization_id;


--
-- TOC entry 3284 (class 2606 OID 27979)
-- Name: person pk_person_person_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.person
    ADD CONSTRAINT pk_person_person_id PRIMARY KEY (person_id);

ALTER TABLE dev.person CLUSTER ON pk_person_person_id;


--
-- TOC entry 3322 (class 2606 OID 28111)
-- Name: status pk_status_status_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.status
    ADD CONSTRAINT pk_status_status_id PRIMARY KEY (status_id);

ALTER TABLE dev.status CLUSTER ON pk_status_status_id;


--
-- TOC entry 3286 (class 2606 OID 27988)
-- Name: systemtool pk_systemtool_systemtool_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.systemtool
    ADD CONSTRAINT pk_systemtool_systemtool_id PRIMARY KEY (systemtool_id);

ALTER TABLE dev.systemtool CLUSTER ON pk_systemtool_systemtool_id;


--
-- TOC entry 3288 (class 2606 OID 27997)
-- Name: systemtool_type pk_systemtool_systemtool_type_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.systemtool_type
    ADD CONSTRAINT pk_systemtool_systemtool_type_id PRIMARY KEY (systemtool_type_id);

ALTER TABLE dev.systemtool_type CLUSTER ON pk_systemtool_systemtool_type_id;


--
-- TOC entry 3318 (class 2606 OID 28099)
-- Name: tag pk_tag_tag_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.tag
    ADD CONSTRAINT pk_tag_tag_id PRIMARY KEY (tag_id);

ALTER TABLE dev.tag CLUSTER ON pk_tag_tag_id;


--
-- TOC entry 3320 (class 2606 OID 28105)
-- Name: tag_type pk_tag_tag_type_id; Type: CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.tag_type
    ADD CONSTRAINT pk_tag_tag_type_id PRIMARY KEY (tag_type_id);

ALTER TABLE dev.tag_type CLUSTER ON pk_tag_tag_type_id;


--
-- TOC entry 3333 (class 2606 OID 28166)
-- Name: actor fk_actor_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT fk_actor_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3331 (class 2606 OID 28156)
-- Name: actor fk_actor_organization_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT fk_actor_organization_1 FOREIGN KEY (organization_id) REFERENCES dev.organization(organization_id);


--
-- TOC entry 3330 (class 2606 OID 28151)
-- Name: actor fk_actor_person_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT fk_actor_person_1 FOREIGN KEY (person_id) REFERENCES dev.person(person_id);


--
-- TOC entry 3332 (class 2606 OID 28161)
-- Name: actor fk_actor_systemtool_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.actor
    ADD CONSTRAINT fk_actor_systemtool_1 FOREIGN KEY (systemtool_id) REFERENCES dev.systemtool(systemtool_id);


--
-- TOC entry 3340 (class 2606 OID 28201)
-- Name: alt_material_name fk_alt_material_name_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.alt_material_name
    ADD CONSTRAINT fk_alt_material_name_material_1 FOREIGN KEY (material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3341 (class 2606 OID 28206)
-- Name: alt_material_name fk_alt_material_name_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.alt_material_name
    ADD CONSTRAINT fk_alt_material_name_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3350 (class 2606 OID 28251)
-- Name: inventory fk_inventory_actor_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT fk_inventory_actor_1 FOREIGN KEY (actor_id) REFERENCES dev.actor(actor_id);


--
-- TOC entry 3349 (class 2606 OID 28246)
-- Name: inventory fk_inventory_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT fk_inventory_material_1 FOREIGN KEY (material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3351 (class 2606 OID 28256)
-- Name: inventory fk_inventory_measure_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT fk_inventory_measure_1 FOREIGN KEY (measure_id) REFERENCES dev.measure(measure_id);


--
-- TOC entry 3352 (class 2606 OID 28261)
-- Name: inventory fk_inventory_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.inventory
    ADD CONSTRAINT fk_inventory_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3343 (class 2606 OID 28216)
-- Name: m_descriptor fk_m_descriptor_actor_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_actor_1 FOREIGN KEY (actor_id) REFERENCES dev.actor(actor_id);


--
-- TOC entry 3348 (class 2606 OID 28241)
-- Name: m_descriptor_class fk_m_descriptor_class_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor_class
    ADD CONSTRAINT fk_m_descriptor_class_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3344 (class 2606 OID 28221)
-- Name: m_descriptor fk_m_descriptor_m_descriptor_class_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_m_descriptor_class_1 FOREIGN KEY (m_descriptor_class_id) REFERENCES dev.m_descriptor_class(m_descriptor_class_id);


--
-- TOC entry 3345 (class 2606 OID 28226)
-- Name: m_descriptor fk_m_descriptor_m_descriptor_value_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_m_descriptor_value_1 FOREIGN KEY (m_descriptor_value_id) REFERENCES dev.m_descriptor_value(m_descriptor_value_id);


--
-- TOC entry 3342 (class 2606 OID 28211)
-- Name: m_descriptor fk_m_descriptor_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_material_1 FOREIGN KEY (material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3347 (class 2606 OID 28236)
-- Name: m_descriptor fk_m_descriptor_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3346 (class 2606 OID 28231)
-- Name: m_descriptor fk_m_descriptor_status_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.m_descriptor
    ADD CONSTRAINT fk_m_descriptor_status_1 FOREIGN KEY (status_id) REFERENCES dev.status(status_id);


--
-- TOC entry 3334 (class 2606 OID 28171)
-- Name: material fk_material_actor_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material
    ADD CONSTRAINT fk_material_actor_1 FOREIGN KEY (actor_id) REFERENCES dev.actor(actor_id);


--
-- TOC entry 3335 (class 2606 OID 28176)
-- Name: material fk_material_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material
    ADD CONSTRAINT fk_material_material_1 FOREIGN KEY (parent_material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3336 (class 2606 OID 28181)
-- Name: material fk_material_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material
    ADD CONSTRAINT fk_material_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3338 (class 2606 OID 28191)
-- Name: material_ref fk_material_ref_material_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material_ref
    ADD CONSTRAINT fk_material_ref_material_1 FOREIGN KEY (material_id) REFERENCES dev.material(material_id);


--
-- TOC entry 3339 (class 2606 OID 28196)
-- Name: material_ref fk_material_ref_material_type_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material_ref
    ADD CONSTRAINT fk_material_ref_material_type_1 FOREIGN KEY (material_type_id) REFERENCES dev.material_type(material_type_id);


--
-- TOC entry 3337 (class 2606 OID 28186)
-- Name: material_type fk_material_type_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.material_type
    ADD CONSTRAINT fk_material_type_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3353 (class 2606 OID 28266)
-- Name: measure_type fk_measure_type_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.measure_type
    ADD CONSTRAINT fk_measure_type_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3354 (class 2606 OID 28271)
-- Name: note fk_note_edocument_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.note
    ADD CONSTRAINT fk_note_edocument_1 FOREIGN KEY (edocument_id) REFERENCES dev.edocument(edocument_id);


--
-- TOC entry 3323 (class 2606 OID 28116)
-- Name: organization fk_organization_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.organization
    ADD CONSTRAINT fk_organization_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3325 (class 2606 OID 28126)
-- Name: person fk_person_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.person
    ADD CONSTRAINT fk_person_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3324 (class 2606 OID 28121)
-- Name: person fk_person_organization_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.person
    ADD CONSTRAINT fk_person_organization_1 FOREIGN KEY (organization_id) REFERENCES dev.organization(organization_id);


--
-- TOC entry 3328 (class 2606 OID 28141)
-- Name: systemtool fk_systemtool_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.systemtool
    ADD CONSTRAINT fk_systemtool_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3327 (class 2606 OID 28136)
-- Name: systemtool fk_systemtool_organization_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.systemtool
    ADD CONSTRAINT fk_systemtool_organization_1 FOREIGN KEY (organization_id) REFERENCES dev.organization(organization_id);


--
-- TOC entry 3326 (class 2606 OID 28131)
-- Name: systemtool fk_systemtool_systemtool_type_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.systemtool
    ADD CONSTRAINT fk_systemtool_systemtool_type_1 FOREIGN KEY (systemtool_type_id) REFERENCES dev.systemtool_type(systemtool_type_id);


--
-- TOC entry 3329 (class 2606 OID 28146)
-- Name: systemtool_type fk_systemtool_type_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.systemtool_type
    ADD CONSTRAINT fk_systemtool_type_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3356 (class 2606 OID 28281)
-- Name: tag fk_tag_note_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.tag
    ADD CONSTRAINT fk_tag_note_1 FOREIGN KEY (note_id) REFERENCES dev.note(note_id);


--
-- TOC entry 3355 (class 2606 OID 28276)
-- Name: tag fk_tag_tag_type_1; Type: FK CONSTRAINT; Schema: dev; Owner: escalate
--

ALTER TABLE ONLY dev.tag
    ADD CONSTRAINT fk_tag_tag_type_1 FOREIGN KEY (tag_type_id) REFERENCES dev.tag_type(tag_type_id);


-- Completed on 2019-12-06 14:08:39 EST

--
-- PostgreSQL database dump complete
--

