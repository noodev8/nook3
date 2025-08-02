--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 17.4

-- Started on 2025-08-01 21:39:36

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: nook_prod_user
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO nook_prod_user;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 216 (class 1259 OID 19640)
-- Name: app_user; Type: TABLE; Schema: public; Owner: nook_prod_user
--

CREATE TABLE public.app_user (
    id integer NOT NULL,
    email character varying(255),
    phone character varying(20),
    display_name character varying(100),
    password_hash character varying(255),
    is_anonymous boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    last_active_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    email_verified boolean DEFAULT false,
    auth_token character varying(255),
    auth_token_expires timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.app_user OWNER TO nook_prod_user;

--
-- TOC entry 215 (class 1259 OID 19639)
-- Name: app_user_id_seq; Type: SEQUENCE; Schema: public; Owner: nook_prod_user
--

CREATE SEQUENCE public.app_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.app_user_id_seq OWNER TO nook_prod_user;

--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 215
-- Name: app_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nook_prod_user
--

ALTER SEQUENCE public.app_user_id_seq OWNED BY public.app_user.id;


--
-- TOC entry 3251 (class 2604 OID 19643)
-- Name: app_user id; Type: DEFAULT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.app_user ALTER COLUMN id SET DEFAULT nextval('public.app_user_id_seq'::regclass);


--
-- TOC entry 3258 (class 2606 OID 19652)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3259 (class 1259 OID 19653)
-- Name: idx_app_user_display_name; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_app_user_display_name ON public.app_user USING btree (display_name);


--
-- TOC entry 3260 (class 1259 OID 19654)
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- TOC entry 2039 (class 826 OID 19638)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO nook_prod_user;


--
-- TOC entry 2038 (class 826 OID 19637)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO nook_prod_user;


-- Completed on 2025-08-01 21:39:37

--
-- PostgreSQL database dump complete
--

