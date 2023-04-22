--
-- PostgreSQL database dump
--

-- Dumped from database version 15.2
-- Dumped by pg_dump version 15.2

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
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- Name: packagetrackinghistory(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.packagetrackinghistory(_package_id integer) RETURNS TABLE("time" timestamp without time zone, description character varying)
    LANGUAGE plpgsql
    AS $$
begin
	return query
		(
		select
			pps.time, ('Przyjęto w oddziale ' || pps.parcelpoint_id)::varchar
		from
			parcelpointpackages pps
		where
			_package_id = pps.package_id
	    union
        select
            r.time, ('Wysłano do oddziału ' || r.destination_parcelpoint_id)::varchar
		from
			routes r
		inner join routepackages rp on r.id = rp.route_id
		where
			_package_id = rp.package_id
        union
        select p.pickedup_time, 'Odebrano'::varchar
        from packages p
        where
            _package_id = p.id
        and
            p.pickedup_time is not null
		)
	    order by time;
end;$$;


ALTER FUNCTION public.packagetrackinghistory(_package_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: couriers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.couriers (
    id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    phone_number character varying(20) NOT NULL,
    email character varying(320) NOT NULL
);


ALTER TABLE public.couriers OWNER TO postgres;

--
-- Name: packagedimensions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.packagedimensions (
    id integer NOT NULL,
    name character varying(20) NOT NULL,
    dimension_x numeric(10,5) NOT NULL,
    dimension_y numeric(10,5) NOT NULL,
    dimension_z numeric(10,5) NOT NULL
);


ALTER TABLE public.packagedimensions OWNER TO postgres;

--
-- Name: packages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.packages (
    id integer NOT NULL,
    weight numeric(10,5) NOT NULL,
    dimensions_id integer NOT NULL,
    sender_info_id integer NOT NULL,
    recipient_info_id integer NOT NULL,
    destination_packagepoint_id integer NOT NULL,
    pickedup_time timestamp without time zone
);


ALTER TABLE public.packages OWNER TO postgres;

--
-- Name: parcelpointpackages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parcelpointpackages (
    id integer NOT NULL,
    package_id integer NOT NULL,
    parcelpoint_id integer NOT NULL,
    "time" timestamp without time zone NOT NULL
);


ALTER TABLE public.parcelpointpackages OWNER TO postgres;

--
-- Name: parcelpoints; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.parcelpoints (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    city character varying(100) NOT NULL,
    street character varying(100) NOT NULL,
    house_number character varying(10) NOT NULL,
    apartment_humber character varying(10)
);


ALTER TABLE public.parcelpoints OWNER TO postgres;

--
-- Name: personinfo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personinfo (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    phone_number character varying(20) NOT NULL,
    email character varying(320)
);


ALTER TABLE public.personinfo OWNER TO postgres;

--
-- Name: routepackages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routepackages (
    route_id integer NOT NULL,
    package_id integer NOT NULL
);


ALTER TABLE public.routepackages OWNER TO postgres;

--
-- Name: routes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.routes (
    id integer NOT NULL,
    "time" timestamp without time zone NOT NULL,
    destination_parcelpoint_id integer NOT NULL,
    vehicle_id integer NOT NULL,
    courier_id integer NOT NULL,
    completed boolean DEFAULT false NOT NULL
);


ALTER TABLE public.routes OWNER TO postgres;

--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicles (
    id integer NOT NULL,
    registration_plate character varying(10) NOT NULL,
    dimension_x numeric(10,5) NOT NULL,
    dimension_y numeric(10,5) NOT NULL,
    dimension_z numeric(10,5) NOT NULL,
    max_weight numeric(10,5) NOT NULL
);


ALTER TABLE public.vehicles OWNER TO postgres;

--
-- Data for Name: couriers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.couriers (id, first_name, last_name, phone_number, email) FROM stdin;
1	Dawid	Dąbrowski	123789456	ddabrowski@gmail.com
\.


--
-- Data for Name: packagedimensions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.packagedimensions (id, name, dimension_x, dimension_y, dimension_z) FROM stdin;
1	Paczka S	8.00000	38.00000	64.00000
2	Paczka M	19.00000	46.00000	80.00000
3	Paczka L	41.00000	58.00000	100.00000
\.


--
-- Data for Name: packages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.packages (id, weight, dimensions_id, sender_info_id, recipient_info_id, destination_packagepoint_id, pickedup_time) FROM stdin;
1	5.00000	2	1	2	2	2023-04-22 15:54:11
\.


--
-- Data for Name: parcelpointpackages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parcelpointpackages (id, package_id, parcelpoint_id, "time") FROM stdin;
1	1	1	2023-04-21 23:33:19
2	1	2	2023-04-22 12:53:58
\.


--
-- Data for Name: parcelpoints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parcelpoints (id, name, city, street, house_number, apartment_humber) FROM stdin;
1	Punkt Krakowski	Kraków	Jasnogórska	22	\N
2	Punkt Warszawski	Warszawa	Złota	44	51
\.


--
-- Data for Name: personinfo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personinfo (id, name, phone_number, email) FROM stdin;
1	Jan Kowalski	123456789	\N
2	Tomasz Nowak	987654321	\N
\.


--
-- Data for Name: routepackages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routepackages (route_id, package_id) FROM stdin;
1	1
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routes (id, "time", destination_parcelpoint_id, vehicle_id, courier_id, completed) FROM stdin;
1	2023-04-21 23:40:19	2	1	1	t
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicles (id, registration_plate, dimension_x, dimension_y, dimension_z, max_weight) FROM stdin;
1	KRA81TL	500.00000	228.00000	196.00000	1000.00000
\.


--
-- Name: couriers couriers_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.couriers
    ADD CONSTRAINT couriers_pk PRIMARY KEY (id);


--
-- Name: packagedimensions packagedimensions_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packagedimensions
    ADD CONSTRAINT packagedimensions_pk PRIMARY KEY (id);


--
-- Name: packages packages_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT packages_pk PRIMARY KEY (id);


--
-- Name: parcelpointpackages parcelpointpackages_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parcelpointpackages
    ADD CONSTRAINT parcelpointpackages_pk PRIMARY KEY (id);


--
-- Name: parcelpoints parcelpoints_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parcelpoints
    ADD CONSTRAINT parcelpoints_pk PRIMARY KEY (id);


--
-- Name: personinfo personinfo_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personinfo
    ADD CONSTRAINT personinfo_pk PRIMARY KEY (id);


--
-- Name: routepackages routepackages_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routepackages
    ADD CONSTRAINT routepackages_pk PRIMARY KEY (route_id, package_id);


--
-- Name: routes routes_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_pk PRIMARY KEY (id);


--
-- Name: vehicles vehicles_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.vehicles
    ADD CONSTRAINT vehicles_pk PRIMARY KEY (id);


--
-- Name: packages packages_customerinfo1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT packages_customerinfo1 FOREIGN KEY (recipient_info_id) REFERENCES public.personinfo(id);


--
-- Name: packages packages_customerinfo2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT packages_customerinfo2 FOREIGN KEY (sender_info_id) REFERENCES public.personinfo(id);


--
-- Name: packages packages_packagedimensions; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT packages_packagedimensions FOREIGN KEY (dimensions_id) REFERENCES public.packagedimensions(id);


--
-- Name: packages packages_packagepoints; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.packages
    ADD CONSTRAINT packages_packagepoints FOREIGN KEY (destination_packagepoint_id) REFERENCES public.parcelpoints(id);


--
-- Name: parcelpointpackages parcelpointpackages_packages; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parcelpointpackages
    ADD CONSTRAINT parcelpointpackages_packages FOREIGN KEY (package_id) REFERENCES public.packages(id);


--
-- Name: parcelpointpackages parcelpointpackages_parcelpoints; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parcelpointpackages
    ADD CONSTRAINT parcelpointpackages_parcelpoints FOREIGN KEY (parcelpoint_id) REFERENCES public.parcelpoints(id);


--
-- Name: routepackages routepackages_packages; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routepackages
    ADD CONSTRAINT routepackages_packages FOREIGN KEY (package_id) REFERENCES public.packages(id);


--
-- Name: routepackages routepackages_routes; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routepackages
    ADD CONSTRAINT routepackages_routes FOREIGN KEY (route_id) REFERENCES public.routes(id);


--
-- Name: routes routes_courier; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_courier FOREIGN KEY (courier_id) REFERENCES public.couriers(id);


--
-- Name: routes routes_packagepoints; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_packagepoints FOREIGN KEY (destination_parcelpoint_id) REFERENCES public.parcelpoints(id);


--
-- Name: routes routes_vehicles; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_vehicles FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


--
-- PostgreSQL database dump complete
--

