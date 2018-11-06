--
-- PostgreSQL database dump
--

-- Dumped from database version 10.5 (Ubuntu 10.5-0ubuntu0.18.04)
-- Dumped by pg_dump version 10.5 (Ubuntu 10.5-0ubuntu0.18.04)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log (
    log character varying,
    result_xml xml,
    repo_id integer,
    id bigint NOT NULL
);


--
-- Name: log_id_seq1; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_id_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_id_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_id_seq1 OWNED BY public.log.id;


--
-- Name: repositories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repositories (
    id integer NOT NULL,
    name character varying NOT NULL,
    "timestamp" timestamp with time zone NOT NULL,
    test_session_id bigint
);


--
-- Name: repostitories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.repostitories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: repostitories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.repostitories_id_seq OWNED BY public.repositories.id;


--
-- Name: test_session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.test_session (
    id bigint NOT NULL,
    start timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: test_session_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.test_session_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: test_session_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.test_session_id_seq OWNED BY public.test_session.id;


--
-- Name: log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log ALTER COLUMN id SET DEFAULT nextval('public.log_id_seq1'::regclass);


--
-- Name: repositories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories ALTER COLUMN id SET DEFAULT nextval('public.repostitories_id_seq'::regclass);


--
-- Name: test_session id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_session ALTER COLUMN id SET DEFAULT nextval('public.test_session_id_seq'::regclass);


--
-- Name: repositories pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT pk PRIMARY KEY (id);


--
-- Name: test_session test_session_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_session
    ADD CONSTRAINT test_session_id_key UNIQUE (id);


--
-- Name: test_session test_session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.test_session
    ADD CONSTRAINT test_session_pkey PRIMARY KEY (start);


--
-- Name: fki_repository; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_repository ON public.log USING btree (repo_id);


--
-- Name: fki_test_session_id_fk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_test_session_id_fk ON public.repositories USING btree (test_session_id);


--
-- Name: log repository; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log
    ADD CONSTRAINT repository FOREIGN KEY (repo_id) REFERENCES public.repositories(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: repositories test_session_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repositories
    ADD CONSTRAINT test_session_id_fk FOREIGN KEY (test_session_id) REFERENCES public.test_session(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

