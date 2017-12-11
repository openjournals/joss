SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: editors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE editors (
    id integer NOT NULL,
    kind character varying DEFAULT 'topic'::character varying NOT NULL,
    title character varying,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    login character varying NOT NULL,
    email character varying,
    avatar_url character varying,
    categories character varying[] DEFAULT '{}'::character varying[],
    url character varying,
    description character varying DEFAULT ''::character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: editors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE editors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: editors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE editors_id_seq OWNED BY editors.id;


--
-- Name: papers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE papers (
    id integer NOT NULL,
    title character varying,
    state character varying,
    repository_url character varying,
    archive_doi character varying,
    sha character varying,
    body text,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    review_issue_id integer,
    software_version character varying,
    doi character varying,
    paper_body text,
    meta_review_issue_id integer,
    suggested_editor character varying,
    kind character varying,
    authors text,
    citation_string text,
    accepted_at timestamp without time zone,
    tsv tsvector
);


--
-- Name: papers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE papers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: papers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE papers_id_seq OWNED BY papers.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    provider character varying,
    uid character varying,
    name character varying,
    oauth_token character varying,
    oauth_expires_at character varying,
    email character varying,
    sha character varying,
    extra hstore,
    admin boolean DEFAULT false,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    github_username character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: editors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY editors ALTER COLUMN id SET DEFAULT nextval('editors_id_seq'::regclass);


--
-- Name: papers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY papers ALTER COLUMN id SET DEFAULT nextval('papers_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: editors editors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY editors
    ADD CONSTRAINT editors_pkey PRIMARY KEY (id);


--
-- Name: papers papers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY papers
    ADD CONSTRAINT papers_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_papers_on_sha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_papers_on_sha ON papers USING btree (sha);


--
-- Name: index_papers_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_papers_on_tsv ON papers USING gin (tsv);


--
-- Name: index_papers_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_papers_on_user_id ON papers USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON users USING btree (email);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_name ON users USING btree (name);


--
-- Name: index_users_on_sha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_sha ON users USING btree (sha);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: papers paper_search_update; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER paper_search_update BEFORE INSERT OR UPDATE ON papers FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('tsv', 'pg_catalog.english', 'title', 'body', 'authors', 'citation_string', 'repository_url', 'doi', 'archive_doi');


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160126012007'),
('20160126012626'),
('20160127035358'),
('20160127165129'),
('20160215235526'),
('20160228024951'),
('20160424042344'),
('20160511024114'),
('20160512023304'),
('20160918002623'),
('20170402113433'),
('20171104191755'),
('20171107021538'),
('20171202233444'),
('20171210220552');


