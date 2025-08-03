--
-- PostgreSQL database dump
--

-- Dumped from database version 16.9 (Ubuntu 16.9-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 17.4

-- Started on 2025-08-03 15:33:45

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
-- TOC entry 3498 (class 0 OID 0)
-- Dependencies: 215
-- Name: app_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nook_prod_user
--

ALTER SEQUENCE public.app_user_id_seq OWNED BY public.app_user.id;


--
-- TOC entry 222 (class 1259 OID 19687)
-- Name: category_menu_items; Type: TABLE; Schema: public; Owner: nook_prod_user
--

CREATE TABLE public.category_menu_items (
    id integer NOT NULL,
    category_id integer NOT NULL,
    menu_item_id integer NOT NULL,
    is_default_included boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.category_menu_items OWNER TO nook_prod_user;

--
-- TOC entry 221 (class 1259 OID 19686)
-- Name: category_menu_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nook_prod_user
--

CREATE SEQUENCE public.category_menu_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.category_menu_items_id_seq OWNER TO nook_prod_user;

--
-- TOC entry 3499 (class 0 OID 0)
-- Dependencies: 221
-- Name: category_menu_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nook_prod_user
--

ALTER SEQUENCE public.category_menu_items_id_seq OWNED BY public.category_menu_items.id;


--
-- TOC entry 220 (class 1259 OID 19675)
-- Name: menu_items; Type: TABLE; Schema: public; Owner: nook_prod_user
--

CREATE TABLE public.menu_items (
    id integer NOT NULL,
    name character varying(200) NOT NULL,
    description text,
    item_type character varying(50),
    is_vegetarian boolean DEFAULT false,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.menu_items OWNER TO nook_prod_user;

--
-- TOC entry 219 (class 1259 OID 19674)
-- Name: menu_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nook_prod_user
--

CREATE SEQUENCE public.menu_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.menu_items_id_seq OWNER TO nook_prod_user;

--
-- TOC entry 3500 (class 0 OID 0)
-- Dependencies: 219
-- Name: menu_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nook_prod_user
--

ALTER SEQUENCE public.menu_items_id_seq OWNED BY public.menu_items.id;


--
-- TOC entry 226 (class 1259 OID 19709)
-- Name: order_categories; Type: TABLE; Schema: public; Owner: nook_prod_user
--

CREATE TABLE public.order_categories (
    id integer NOT NULL,
    order_id integer NOT NULL,
    category_id integer NOT NULL,
    quantity integer DEFAULT 1 NOT NULL,
    unit_price numeric(10,2) NOT NULL,
    total_price numeric(10,2) NOT NULL,
    notes text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    department_label text
);


ALTER TABLE public.order_categories OWNER TO nook_prod_user;

--
-- TOC entry 225 (class 1259 OID 19708)
-- Name: order_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: nook_prod_user
--

CREATE SEQUENCE public.order_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_categories_id_seq OWNER TO nook_prod_user;

--
-- TOC entry 3501 (class 0 OID 0)
-- Dependencies: 225
-- Name: order_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nook_prod_user
--

ALTER SEQUENCE public.order_categories_id_seq OWNED BY public.order_categories.id;


--
-- TOC entry 228 (class 1259 OID 19720)
-- Name: order_items; Type: TABLE; Schema: public; Owner: nook_prod_user
--

CREATE TABLE public.order_items (
    id integer NOT NULL,
    order_id integer NOT NULL,
    order_category_id integer NOT NULL,
    menu_item_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.order_items OWNER TO nook_prod_user;

--
-- TOC entry 227 (class 1259 OID 19719)
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: nook_prod_user
--

CREATE SEQUENCE public.order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO nook_prod_user;

--
-- TOC entry 3502 (class 0 OID 0)
-- Dependencies: 227
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nook_prod_user
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- TOC entry 224 (class 1259 OID 19696)
-- Name: orders; Type: TABLE; Schema: public; Owner: nook_prod_user
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    app_user_id integer,
    guest_email character varying(255),
    total_amount numeric(10,2) NOT NULL,
    order_status character varying(50) DEFAULT 'pending'::character varying,
    delivery_type character varying(20) NOT NULL,
    requested_date date NOT NULL,
    requested_time timestamp with time zone NOT NULL,
    delivery_address text,
    delivery_notes text,
    special_instructions text,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    confirmed_at timestamp with time zone,
    completed_at timestamp with time zone,
    guest_phone character varying(20),
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.orders OWNER TO nook_prod_user;

--
-- TOC entry 223 (class 1259 OID 19695)
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: nook_prod_user
--

CREATE SEQUENCE public.orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO nook_prod_user;

--
-- TOC entry 3503 (class 0 OID 0)
-- Dependencies: 223
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nook_prod_user
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- TOC entry 218 (class 1259 OID 19663)
-- Name: product_categories; Type: TABLE; Schema: public; Owner: nook_prod_user
--

CREATE TABLE public.product_categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    price_per_head numeric(10,2),
    minimum_quantity integer DEFAULT 1,
    is_active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.product_categories OWNER TO nook_prod_user;

--
-- TOC entry 217 (class 1259 OID 19662)
-- Name: product_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: nook_prod_user
--

CREATE SEQUENCE public.product_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_categories_id_seq OWNER TO nook_prod_user;

--
-- TOC entry 3504 (class 0 OID 0)
-- Dependencies: 217
-- Name: product_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nook_prod_user
--

ALTER SEQUENCE public.product_categories_id_seq OWNED BY public.product_categories.id;


--
-- TOC entry 230 (class 1259 OID 19738)
-- Name: system_settings; Type: TABLE; Schema: public; Owner: nook_prod_user
--

CREATE TABLE public.system_settings (
    id integer NOT NULL,
    setting_key character varying(100) NOT NULL,
    setting_value text,
    description text,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.system_settings OWNER TO nook_prod_user;

--
-- TOC entry 229 (class 1259 OID 19737)
-- Name: system_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: nook_prod_user
--

CREATE SEQUENCE public.system_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_settings_id_seq OWNER TO nook_prod_user;

--
-- TOC entry 3505 (class 0 OID 0)
-- Dependencies: 229
-- Name: system_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nook_prod_user
--

ALTER SEQUENCE public.system_settings_id_seq OWNED BY public.system_settings.id;


--
-- TOC entry 3286 (class 2604 OID 19643)
-- Name: app_user id; Type: DEFAULT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.app_user ALTER COLUMN id SET DEFAULT nextval('public.app_user_id_seq'::regclass);


--
-- TOC entry 3300 (class 2604 OID 19690)
-- Name: category_menu_items id; Type: DEFAULT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.category_menu_items ALTER COLUMN id SET DEFAULT nextval('public.category_menu_items_id_seq'::regclass);


--
-- TOC entry 3296 (class 2604 OID 19678)
-- Name: menu_items id; Type: DEFAULT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.menu_items ALTER COLUMN id SET DEFAULT nextval('public.menu_items_id_seq'::regclass);


--
-- TOC entry 3307 (class 2604 OID 19712)
-- Name: order_categories id; Type: DEFAULT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.order_categories ALTER COLUMN id SET DEFAULT nextval('public.order_categories_id_seq'::regclass);


--
-- TOC entry 3310 (class 2604 OID 19723)
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- TOC entry 3303 (class 2604 OID 19699)
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- TOC entry 3292 (class 2604 OID 19666)
-- Name: product_categories id; Type: DEFAULT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.product_categories ALTER COLUMN id SET DEFAULT nextval('public.product_categories_id_seq'::regclass);


--
-- TOC entry 3312 (class 2604 OID 19741)
-- Name: system_settings id; Type: DEFAULT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.system_settings ALTER COLUMN id SET DEFAULT nextval('public.system_settings_id_seq'::regclass);


--
-- TOC entry 3315 (class 2606 OID 19652)
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (id);


--
-- TOC entry 3326 (class 2606 OID 19694)
-- Name: category_menu_items category_menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.category_menu_items
    ADD CONSTRAINT category_menu_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3324 (class 2606 OID 19685)
-- Name: menu_items menu_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.menu_items
    ADD CONSTRAINT menu_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3340 (class 2606 OID 19718)
-- Name: order_categories order_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.order_categories
    ADD CONSTRAINT order_categories_pkey PRIMARY KEY (id);


--
-- TOC entry 3345 (class 2606 OID 19726)
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- TOC entry 3336 (class 2606 OID 19705)
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- TOC entry 3319 (class 2606 OID 19673)
-- Name: product_categories product_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.product_categories
    ADD CONSTRAINT product_categories_pkey PRIMARY KEY (id);


--
-- TOC entry 3347 (class 2606 OID 19746)
-- Name: system_settings system_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 3349 (class 2606 OID 19748)
-- Name: system_settings system_settings_setting_key_key; Type: CONSTRAINT; Schema: public; Owner: nook_prod_user
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_setting_key_key UNIQUE (setting_key);


--
-- TOC entry 3316 (class 1259 OID 19653)
-- Name: idx_app_user_display_name; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_app_user_display_name ON public.app_user USING btree (display_name);


--
-- TOC entry 3317 (class 1259 OID 19654)
-- Name: idx_app_user_email; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_app_user_email ON public.app_user USING btree (email);


--
-- TOC entry 3327 (class 1259 OID 19761)
-- Name: idx_category_menu_items_category_id; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_category_menu_items_category_id ON public.category_menu_items USING btree (category_id);


--
-- TOC entry 3328 (class 1259 OID 19762)
-- Name: idx_category_menu_items_menu_item_id; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_category_menu_items_menu_item_id ON public.category_menu_items USING btree (menu_item_id);


--
-- TOC entry 3320 (class 1259 OID 19767)
-- Name: idx_menu_items_active; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_menu_items_active ON public.menu_items USING btree (is_active);


--
-- TOC entry 3321 (class 1259 OID 19765)
-- Name: idx_menu_items_type; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_menu_items_type ON public.menu_items USING btree (item_type);


--
-- TOC entry 3322 (class 1259 OID 19766)
-- Name: idx_menu_items_vegetarian; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_menu_items_vegetarian ON public.menu_items USING btree (is_vegetarian);


--
-- TOC entry 3337 (class 1259 OID 19757)
-- Name: idx_order_categories_category_id; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_order_categories_category_id ON public.order_categories USING btree (category_id);


--
-- TOC entry 3338 (class 1259 OID 19756)
-- Name: idx_order_categories_order_id; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_order_categories_order_id ON public.order_categories USING btree (order_id);


--
-- TOC entry 3341 (class 1259 OID 19760)
-- Name: idx_order_items_menu_item_id; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_order_items_menu_item_id ON public.order_items USING btree (menu_item_id);


--
-- TOC entry 3342 (class 1259 OID 19759)
-- Name: idx_order_items_order_category_id; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_order_items_order_category_id ON public.order_items USING btree (order_category_id);


--
-- TOC entry 3343 (class 1259 OID 19758)
-- Name: idx_order_items_order_id; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);


--
-- TOC entry 3329 (class 1259 OID 19749)
-- Name: idx_orders_app_user_id; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_orders_app_user_id ON public.orders USING btree (app_user_id);


--
-- TOC entry 3330 (class 1259 OID 19780)
-- Name: idx_orders_created_at; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_orders_created_at ON public.orders USING btree (created_at);


--
-- TOC entry 3331 (class 1259 OID 19753)
-- Name: idx_orders_date; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_orders_date ON public.orders USING btree (requested_date);


--
-- TOC entry 3332 (class 1259 OID 19750)
-- Name: idx_orders_guest_email; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_orders_guest_email ON public.orders USING btree (guest_email);


--
-- TOC entry 3333 (class 1259 OID 19752)
-- Name: idx_orders_status; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_orders_status ON public.orders USING btree (order_status);


--
-- TOC entry 3334 (class 1259 OID 19779)
-- Name: idx_orders_time; Type: INDEX; Schema: public; Owner: nook_prod_user
--

CREATE INDEX idx_orders_time ON public.orders USING btree (requested_time);


--
-- TOC entry 2074 (class 826 OID 19638)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO nook_prod_user;


--
-- TOC entry 2073 (class 826 OID 19637)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT,INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,UPDATE ON TABLES TO nook_prod_user;


-- Completed on 2025-08-03 15:33:46

--
-- PostgreSQL database dump complete
--

