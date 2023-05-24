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
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- Name: adminpack; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS adminpack WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION adminpack; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION adminpack IS 'administrative functions for PostgreSQL';


--
-- Name: addcourier(character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addcourier(_firstname character varying, _lastname character varying, _phonenumber character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    _id integer := (select COALESCE(max(id),0) from couriers) + 1;

begin

    if (length(_firstname) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Couriers firstname cant be empty!';
    end if;

    if (length(_lastname) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Couriers lastname cant be empty!';
    end if;

    if (length(_phoneNumber) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Couriers phone number cant be empty!';
    end if;


    if (exists(select * from couriers where phone_number = _phoneNumber)) then
        RAISE unique_violation USING MESSAGE = 'Courier with this phone number already exists!';
    end if;


    insert into couriers(id, first_name, last_name, phone_number)
        values (_id, _firstname, _lastname, _phoneNumber);

    return _id;

end;

$$;


ALTER FUNCTION public.addcourier(_firstname character varying, _lastname character varying, _phonenumber character varying) OWNER TO postgres;

--
-- Name: addpackagedimension(character varying, numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addpackagedimension(_name character varying, _dimx numeric, _dimy numeric, _dimz numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    _dimensionID integer := (select COALESCE(max(id),0) from packagedimensions) + 1;
begin
    if (length(_name) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Name cant be empty !';
    end if;

    if (_dimX <= 0) then
        RAISE unique_violation USING MESSAGE = 'X dimension must be positive !';
    end if;

    if (_dimY <= 0) then
        RAISE unique_violation USING MESSAGE = 'Y dimension must be positive !';
    end if;

    if (_dimZ <= 0) then
        RAISE unique_violation USING MESSAGE = 'Z dimension must be positive !';
    end if;

    if(exists(select id from packagedimensions d where dimension_y = _dimY and dimension_x = _dimX and dimension_z = _dimZ)) then
        RAISE unique_violation USING MESSAGE = 'Package dimension with those dimensions exists !';
    end if;

    if(exists(select id from packagedimensions d where d.name = _name)) then
        RAISE unique_violation USING MESSAGE = 'Package dimension with this name exists !';
    end if;

    insert into packagedimensions(id, name, dimension_x, dimension_y, dimension_z)
        values (_dimensionID, _name, _dimX, _dimY, _dimZ);

    return _dimensionID;
end;
$$;


ALTER FUNCTION public.addpackagedimension(_name character varying, _dimx numeric, _dimy numeric, _dimz numeric) OWNER TO postgres;

--
-- Name: addparcelpoint(character varying, character varying, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addparcelpoint(_name character varying, _city character varying, _street character varying, _housenumber character varying, _apartmentnumber character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    _id integer := (select COALESCE(max(id),0) from parcelpoints) + 1;

begin

    if (length(_name) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Parcel point name cant be empty!';
    end if;

    if (length(_city) <= 0) then
        RAISE unique_violation USING MESSAGE = 'City name cant be empty!';
    end if;

    if (length(_street) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Street name cant be empty!';
    end if;

    if (length(_houseNumber) <= 0) then
        RAISE unique_violation USING MESSAGE = 'House number cant be empty!';
    end if;


    if (exists(select * from parcelpoints where name = _name)) then
        RAISE unique_violation USING MESSAGE = 'Parcel point with this name already exists!';
    end if;

    -- czy w tym miejscu nie ma innego punktu
    if (exists(select * from parcelpoints where city = _city AND street = _street AND
                                                house_number = _houseNumber AND
                                                apartment_number = _apartmentNumber)) then

        RAISE unique_violation USING MESSAGE = 'Parcel point at this address already exists!';
    end if;


    insert into parcelpoints(id, name, city, street, house_number, apartment_number)
        values (_id, _name, _city, _street, _houseNumber, _apartmentNumber);

    return _id;

end;

$$;


ALTER FUNCTION public.addparcelpoint(_name character varying, _city character varying, _street character varying, _housenumber character varying, _apartmentnumber character varying) OWNER TO postgres;

--
-- Name: addroute(timestamp without time zone, integer, integer, integer, integer, integer[]); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addroute(_time timestamp without time zone, _sourceid integer, _destinationid integer, _vehicleid integer, _courierid integer, _packcagesid integer[]) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    waga integer := 0;
    _routeID integer := (select COALESCE(max(id),0) from routes) + 1;
    _pacID integer;
begin
    --if (_time < now() ) then
    --    RAISE unique_violation USING MESSAGE = 'Cant create route in past !';
    --end if;

    if (NOT EXISTS (select * from parcelpoints where id = _sourceID)) then
        RAISE unique_violation USING MESSAGE = 'Package point with id ' || _sourceID || ' doesnt exist!';
    end if;

    if (NOT EXISTS (select * from parcelpoints where id = _destinationID)) then
        RAISE unique_violation USING MESSAGE = 'Package point with id ' || _destinationID || ' doesnt exist!';
    end if;

    if (NOT EXISTS (select * from vehicles where id = _vehicleID)) then
        RAISE unique_violation USING MESSAGE = 'Vehicle with id ' || _vehicleID || ' doesnt exist!';
    end if;

    if (NOT EXISTS (select * from couriers where id = _courierID)) then
        RAISE unique_violation USING MESSAGE = 'Courier with id ' || _courierID || ' doesnt exist!';
    end if;

    if (EXISTS (select * from routes r where r.courier_id = _courierID and date(r.time) = date(_time) and r.completed = false)) then
        RAISE unique_violation USING MESSAGE = 'Courier with id ' || _courierID || ' has planned route on this time!';
    end if;

    if (EXISTS (select * from routes r where r.vehicle_id = _vehicleID and date(r.time) = date(_time) and r.completed = false)) then
        RAISE unique_violation USING MESSAGE = 'Vehicle with id ' || _vehicleID || ' has planned route on this time!';
    end if;

    -- obliczanie wspólnej wagi
    foreach _pacID in array _packcagesID loop
        if (NOT EXISTS (select * from packages where id = _pacID)) then
            RAISE unique_violation USING MESSAGE = 'Package with id ' || _pacID || ' doesnt exist!';
        end if;
        if (packagelocation(_pacID) != _sourceID) then
            RAISE unique_violation USING MESSAGE = 'Package with id ' || _pacID || ' isnt at source package point !';
        end if;
        waga := waga + (select p.weight from packages p where  p.id = _pacID);
    end loop;

    if (waga > (select v.max_weight from vehicles v where v.id = _vehicleID)) then
        RAISE unique_violation USING MESSAGE = 'Packages weight too much for this vehicle ' || _vehicleID;
    end if;

    insert into routes (id ,time, destination_parcelpoint_id, source_parcelpoint_id, vehicle_id, courier_id, completed)
        values(_routeID ,_time, _destinationID, _sourceID, _vehicleID, _courierID, false);

    foreach _pacID in array _packcagesID loop
       insert into routepackages(route_id, package_id)
            values(_routeID, _pacID);
    end loop;

    return _routeID;
end;
$$;


ALTER FUNCTION public.addroute(_time timestamp without time zone, _sourceid integer, _destinationid integer, _vehicleid integer, _courierid integer, _packcagesid integer[]) OWNER TO postgres;

--
-- Name: addvehicle(character varying, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addvehicle(_registrationplate character varying, _maxweight numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    _vehicleID integer := (select COALESCE(max(id),0) from vehicles) + 1;
begin
    if (length(_registrationPlate) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Registration plate cant be empty !';
    end if;

     if (_maxWeight <= 0) then
        RAISE unique_violation USING MESSAGE = 'Max weight must be positive !';
    end if;

    if(exists(select id from vehicles d where d.registration_plate = _registrationPlate)) then
        RAISE unique_violation USING MESSAGE = 'Vehicle with this registration plate exists !';
    end if;

    insert into vehicles (id, registration_plate, max_weight)
        values (_vehicleID, _registrationPlate, _maxWeight);

    return _vehicleID;
end;
$$;


ALTER FUNCTION public.addvehicle(_registrationplate character varying, _maxweight numeric) OWNER TO postgres;

--
-- Name: completeroute(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.completeroute(_routeid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    _pacID integer;
    _destinationID integer;
    _pppID integer := (select max(id) from parcelpointpackages) + 1;
begin
    if (NOT EXISTS (select * from routes where id = _routeID)) then
        RAISE unique_violation USING MESSAGE = 'Route with id ' || _routeID || ' doesnt exist!';
    end if;

    if (EXISTS (select * from routes where id = _routeID and completed = true)) then
        RAISE unique_violation USING MESSAGE = 'Route with id ' || _routeID || ' is already completed !';
    end if;

    if(select r.time from routes r where r.id = _routeID) > now() then
        RAISE unique_violation USING MESSAGE = 'Route with id ' || _routeID || ' hanst started!';
    end if;

    _destinationID := (select r.destination_parcelpoint_id from routes r where r.id = _routeID);

    update routes set completed = true where id = _routeID;

    for _pacID in (select rp.package_id from routepackages rp where rp.route_id = _routeID) loop
        insert into parcelpointpackages(id, package_id, parcelpoint_id, time)
        values (_pppID ,_pacID, _destinationID, now());
        _pppID := _pppID + 1;
    end loop;

    return _routeID;
end;
$$;


ALTER FUNCTION public.completeroute(_routeid integer) OWNER TO postgres;

--
-- Name: getcontentsofparcelpoint(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.getcontentsofparcelpoint(_parcelpointid integer) RETURNS TABLE(waiting_package_id integer)
    LANGUAGE plpgsql
    AS $$
begin

    if (not exists(select * from parcelpoints where id = _parcelPointID)) then
        RAISE unique_violation USING MESSAGE = 'Parcel point with this ID dont exists!';
    end if;

    return query
        select T1.package_id
        from (
            select package_id, max(time) as last_update
            from parcelpointpackages
            group by package_id
        ) as T1     -- wszystkie paczki z czasem przybycia do ich ostatniego punktu paczkowego

        inner join (
            select P.id as package_id
            from packages P
            EXCEPT
            select P.id as package_id
            from packages P
            inner join routepackages RP on P.id = RP.package_id
            inner join routes R on RP.route_id = R.id
            where R.completed = false
        ) as T2 on T1.package_id = T2.package_id    -- paczki które NIE są aktualnie w trasie

        inner join parcelpointpackages as PPP on T1.package_id = PPP.package_id
        inner join packages P on PPP.package_id = P.id
        where PPP.time = T1.last_update and PPP.parcelpoint_id = _parcelPointID and P.pickedup_time IS NULL;

end;
$$;


ALTER FUNCTION public.getcontentsofparcelpoint(_parcelpointid integer) OWNER TO postgres;

--
-- Name: packagelocation(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.packagelocation(_package_id integer) RETURNS TABLE(parcelpointid integer)
    LANGUAGE plpgsql
    AS $$
begin
    if (NOT EXISTS (select * from packages where id = _package_id)) then
        RAISE unique_violation USING MESSAGE = 'Package with id ' || _package_id || ' doesnt exist!';
    end if;
	return query
		(
		select
		    case when (select count(p.pickedup_time) from packages p where _package_id = p.id
		               and p.pickedup_time is not null) > 0 then null
		    else (select t.parcelpoint_id from
		         ((select ppp.parcelpoint_id, ppp.time from parcelpointpackages ppp where ppp.package_id = _package_id
		          union
		          select -1::integer, r.time from routes r inner join routepackages rp on r.id = rp.route_id
		                where rp.package_id = _package_id
		          ) order by time desc limit 1) t)
		    end
		);
end;
$$;


ALTER FUNCTION public.packagelocation(_package_id integer) OWNER TO postgres;

--
-- Name: packagetrackinghistory(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.packagetrackinghistory(_package_id integer) RETURNS TABLE("time" timestamp without time zone, description character varying)
    LANGUAGE plpgsql
    AS $$
begin
    if (NOT EXISTS (select * from packages where id = _package_id)) then
        RAISE unique_violation USING MESSAGE = 'Package with id ' || _package_id || ' doesnt exist!';
    end if;
	return query
		(
		select
			pps.time,
			CASE WHEN pps.parcelpoint_id = (select destination_packagepoint_id from packages where id = _package_id) THEN
			    ('Gotowa do odbioru w oddziale ' || pps.parcelpoint_id)::varchar
                ELSE ('Przyjęto w oddziale ' || pps.parcelpoint_id)::varchar
		    END
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
end;
$$;


ALTER FUNCTION public.packagetrackinghistory(_package_id integer) OWNER TO postgres;

--
-- Name: pickuppackage(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.pickuppackage(_packageid integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
begin
    if (NOT EXISTS (select * from packages where id = _packageId)) then
        RAISE unique_violation USING MESSAGE = 'Package with id ' || _packageId || ' doesnt exist!';
    end if;

    if( select p.destination_packagepoint_id from packages p where id = _packageId) != packagelocation(_packageId) then
        RAISE unique_violation USING MESSAGE = 'Package cant be picked up, beacuse it hasnt arrived to destination package point !';
    end if;

    update packages set pickedup_time = now() where id = _packageId;

    return _packageId;
end;
$$;


ALTER FUNCTION public.pickuppackage(_packageid integer) OWNER TO postgres;

--
-- Name: registerpackage(numeric, integer, character varying, character varying, character varying, character varying, integer, integer, character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.registerpackage(_weight numeric, _dimensions_id integer, _recipient_name character varying, _recipient_phone_number character varying, _sender_name character varying, _sender_phone_number character varying, _destination_packagepoint_id integer, _source_packagepoint_id integer, _recipient_email character varying DEFAULT NULL::character varying, _sender_email character varying DEFAULT NULL::character varying) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    sender_id int := (select COALESCE(max(id),0) from personinfo)+1;
    recipient_id int := sender_id + 1;
    _package_id int := (select COALESCE(max(id),0) from packages)+1;
    parcelpointpackages_id int := (select COALESCE(max(id),0) from parcelpointpackages)+1;
begin
    if (NOT EXISTS (select * from parcelpoints where id = _destination_packagepoint_id)) then
        RAISE unique_violation USING MESSAGE = 'Package point with id ' || _destination_packagepoint_id || ' doesnt exist!';
    end if;

    if (NOT EXISTS (select * from parcelpoints where id = _source_packagepoint_id)) then
        RAISE unique_violation USING MESSAGE = 'Package point with id ' || _source_packagepoint_id || ' doesnt exist!';
    end if;

    if (_source_packagepoint_id = _destination_packagepoint_id) then
        RAISE unique_violation USING MESSAGE = 'Source and destination package points cant be equal!';
    end if;

    if (NOT EXISTS (select * from packagedimensions where id = _dimensions_id)) then
        RAISE unique_violation USING MESSAGE = 'Package dimensions with id ' || _dimensions_id || ' dont exist!';
    end if;

    if (_weight > 50) then
        RAISE unique_violation USING MESSAGE = 'Max package weight is 50!';
    end if;

    if (_weight < 0.1) then
        RAISE unique_violation USING MESSAGE = 'Min package weight is 0.1!';
    end if;

    insert into personinfo (id, name, phone_number, email)
        values(sender_id, _sender_name, _sender_phone_number, _sender_email);
    insert into personinfo (id, name, phone_number, email)
        values(recipient_id, _recipient_name, _recipient_phone_number, _recipient_email);

    insert into packages (id, weight, dimensions_id, sender_info_id, recipient_info_id, destination_packagepoint_id)
        values (_package_id, _weight, _dimensions_id, sender_id, recipient_id, _destination_packagepoint_id);

    insert into parcelpointpackages (id, package_id, parcelpoint_id, "time")
        values (parcelpointpackages_id, _package_id, _source_packagepoint_id, CURRENT_TIMESTAMP(2));

    return _package_id;
end;$$;


ALTER FUNCTION public.registerpackage(_weight numeric, _dimensions_id integer, _recipient_name character varying, _recipient_phone_number character varying, _sender_name character varying, _sender_phone_number character varying, _destination_packagepoint_id integer, _source_packagepoint_id integer, _recipient_email character varying, _sender_email character varying) OWNER TO postgres;

--
-- Name: updateuserprivileges(integer, integer, integer, boolean); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.updateuserprivileges(_id integer, _courier_id integer, _parcelpoint_id integer, _admin boolean) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    begin

        if (NOT EXISTS (select * from users where id = _id)) then
            RAISE unique_violation USING MESSAGE = 'User with this ID does not exist!';
        end if;

        if (_courier_id IS NOT NULL AND _parcelpoint_id IS NOT NULL) then
            RAISE unique_violation USING MESSAGE = 'User cannot be courier and parcelpoint at the same time!';
        end if;

        update users set courier_id = _courier_id, parcelpoint_id = _parcelpoint_id, admin = _admin
            where id = _id;

        return _id;
    end;
$$;


ALTER FUNCTION public.updateuserprivileges(_id integer, _courier_id integer, _parcelpoint_id integer, _admin boolean) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: couriers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.couriers (
    id integer NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL,
    phone_number character varying(20) NOT NULL
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
    apartment_number character varying(10)
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
    completed boolean DEFAULT false NOT NULL,
    source_parcelpoint_id integer
);


ALTER TABLE public.routes OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    courier_id integer,
    parcelpoint_id integer,
    email character varying(320) NOT NULL,
    password_hash character varying(255) NOT NULL,
    admin boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vehicles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.vehicles (
    id integer NOT NULL,
    registration_plate character varying(10) NOT NULL,
    max_weight numeric(10,5) NOT NULL
);


ALTER TABLE public.vehicles OWNER TO postgres;

--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: couriers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.couriers (id, first_name, last_name, phone_number) FROM stdin;
1	John	Smith	123-456-7890
2	Emily	Johnson	987-654-3210
3	Michael	Williams	555-123-4567
4	Emma	Brown	444-555-6666
5	Daniel	Jones	777-888-9999
6	Olivia	Davis	111-222-3333
7	Matthew	Miller	999-888-7777
8	Sophia	Wilson	666-555-4444
9	James	Taylor	333-222-1111
10	Ava	Anderson	222-333-4444
\.


--
-- Data for Name: packagedimensions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.packagedimensions (id, name, dimension_x, dimension_y, dimension_z) FROM stdin;
1	Paczka S	8.00000	38.00000	64.00000
2	Paczka M	19.00000	46.00000	80.00000
3	Paczka L	41.00000	58.00000	100.00000
4	Paczka XL	67.00000	77.00000	127.00000
\.


--
-- Data for Name: packages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.packages (id, weight, dimensions_id, sender_info_id, recipient_info_id, destination_packagepoint_id, pickedup_time) FROM stdin;
2	2.10000	3	3	4	1	\N
3	4.80000	2	5	6	4	\N
4	1.90000	4	7	8	3	\N
5	6.20000	1	9	10	2	\N
6	3.90000	3	11	12	3	\N
7	2.30000	2	13	14	4	\N
8	5.70000	4	15	16	1	\N
9	1.50000	1	17	18	2	\N
10	4.20000	3	19	20	3	\N
11	2.80000	2	21	22	1	\N
12	3.20000	3	23	24	1	\N
13	5.10000	1	25	26	4	\N
14	1.70000	4	27	28	3	\N
15	4.90000	3	29	30	4	\N
16	2.50000	2	31	32	2	\N
17	6.30000	1	33	34	4	\N
18	1.30000	4	35	36	1	\N
19	3.70000	3	37	38	2	\N
20	4.40000	2	39	40	3	\N
1	3.50000	1	1	2	2	2023-05-23 13:40:04.818529
21	7.00000	2	41	42	2	2023-05-24 11:32:45.126903
22	1.30000	2	43	44	2	\N
23	1.30000	2	45	46	2	\N
24	7.80000	2	47	48	10	\N
25	49.70000	4	49	50	4	\N
26	20.70000	3	51	52	3	\N
27	17.00000	2	53	54	4	2023-05-24 18:35:41.982539
28	16.70000	2	55	56	3	\N
29	13.30000	1	57	58	3	\N
30	9.70000	4	59	60	1	\N
31	18.90000	2	61	62	3	\N
32	13.20000	1	63	64	4	\N
\.


--
-- Data for Name: parcelpointpackages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parcelpointpackages (id, package_id, parcelpoint_id, "time") FROM stdin;
1	1	1	2023-01-05 10:30:00
2	2	2	2023-01-10 14:45:00
3	3	3	2023-01-15 09:20:00
4	4	4	2023-01-20 16:55:00
5	5	1	2023-01-25 11:40:00
6	6	2	2023-01-30 13:15:00
7	7	3	2023-02-04 08:50:00
8	8	4	2023-02-09 17:25:00
9	9	1	2023-02-14 12:10:00
10	10	2	2023-02-19 15:35:00
11	11	3	2023-02-24 10:00:00
12	12	4	2023-03-01 18:25:00
13	13	1	2023-03-06 13:10:00
14	14	2	2023-03-11 16:35:00
15	15	3	2023-03-16 11:00:00
16	16	4	2023-03-21 19:25:00
17	17	1	2023-03-26 14:10:00
18	18	2	2023-03-31 17:35:00
19	19	3	2023-04-05 12:00:00
20	20	4	2023-04-10 20:25:00
21	1	2	2023-05-23 13:39:16.557545
22	9	2	2023-05-23 13:39:16.557545
23	5	2	2023-05-23 13:39:16.557545
25	21	2	2023-05-24 11:32:24.870334
26	16	2	2023-05-24 11:32:24.870334
24	21	4	2023-05-24 11:30:33.23
27	22	1	2023-05-24 11:52:05.69
28	23	1	2023-05-24 11:54:16.94
29	24	1	2023-05-24 18:19:31.48
30	25	1	2023-05-24 18:23:09.34
31	26	1	2023-05-24 18:26:22.59
32	27	1	2023-05-24 18:29:22.2
33	27	4	2023-05-24 18:33:21.097767
34	17	4	2023-05-24 18:33:21.097767
35	13	4	2023-05-24 18:33:21.097767
36	28	2	2023-05-24 18:46:07.43
37	29	2	2023-05-24 18:47:49.81
38	30	2	2023-05-24 18:51:25.04
39	31	2	2023-05-24 18:53:26.49
40	32	1	2023-05-24 19:02:34.29
\.


--
-- Data for Name: parcelpoints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parcelpoints (id, name, city, street, house_number, apartment_number) FROM stdin;
1	Punkt Krakowski	Kraków	Jasnogórska	22	\N
2	Punkt Warszawski	Warszawa	Złota	44	51
3	Punkt Gdański	Gdańsk	Długa	10	\N
4	Punkt Poznański	Poznań	Wielka	5	3
5	Punkt Wrocławski	Wrocław	Rynek	15	\N
6	Punkt Łódzki	Łódź	Piotrkowska	30	\N
7	Punkt Szczeciński	Szczecin	Wojska Polskiego	8	12
8	Punkt Lubelski	Lublin	Krakowskie Przedmieście	50	\N
9	Punkt Białostocki	Białystok	Lipowa	7	\N
10	Punkt Katowicki	Katowice	Mariacka	11	2
\.


--
-- Data for Name: personinfo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personinfo (id, name, phone_number, email) FROM stdin;
1	John Smith	1234567890	john@example.com
2	Jane Doe	0987654321	jane@example.com
3	Michael Johnson	5551234567	michael@example.com
4	Emily Williams	9876543210	emily@example.com
5	David Brown	1112223333	david@example.com
6	Jessica Davis	4445556666	jessica@example.com
7	Andrew Wilson	7778889999	andrew@example.com
8	Olivia Taylor	2223334444	olivia@example.com
9	Christopher Martin	6667778888	christopher@example.com
10	Sophia Anderson	9990001111	sophia@example.com
11	Jennifer Wilson	1112223333	jennifer@example.com
12	Matthew Thompson	4445556666	matthew@example.com
13	Emma Davis	7778889999	emma@example.com
14	Daniel Martinez	2223334444	daniel@example.com
15	Ava Anderson	6667778888	ava@example.com
16	Alexander White	9990001111	alexander@example.com
17	Sophie Clark	1234567890	sophie@example.com
18	Josephine Turner	0987654321	josephine@example.com
19	William Walker	5551234567	william@example.com
20	Grace Mitchell	9876543210	grace@example.com
21	Liam Turner	1112223333	liam@example.com
22	Abigail Scott	4445556666	abigail@example.com
23	Benjamin Lee	7778889999	benjamin@example.com
24	Harper Thompson	2223334444	harper@example.com
25	Elijah Davis	6667778888	elijah@example.com
26	Mia White	9990001111	mia@example.com
27	James Clark	1234567890	james@example.com
28	Nora Turner	0987654321	nora@example.com
29	Lucas Adams	5551234567	lucas@example.com
30	Scarlett Mitchell	9876543210	scarlett@example.com
31	Henry Baker	1112223333	henry@example.com
32	Lily Evans	4445556666	lily@example.com
33	Samuel Parker	7778889999	samuel@example.com
34	Chloe Collins	2223334444	chloe@example.com
35	Daniel Wood	6667778888	daniel@example.com
36	Elizabeth Reed	9990001111	elizabeth@example.com
37	Aiden Stewart	1234567890	aiden@example.com
38	Victoria Turner	0987654321	victoria@example.com
39	Jackson Morris	5551234567	jackson@example.com
40	Penelope Wright	9876543210	penelope@example.com
41	test1	123	test1@gmail.com
42	test2	345	test2@gmail.com
43	Jan Kowalski	987654321	jan@gmail.com
44	Zenon Nowak	123456789	zenon@gmail.com
45	Jan Kowalski	987654321	jan@gmail.com
46	Zenon Nowak	123456789	zenon@gmail.com
47	Olaf Kudłacz	758 395 294	olafkudlacz7@gmail.com
48	Michał Fidziński	571 591 591	mfidzi@o2.gov.pl
49	Michał Worek	675 500 511	worek8@wp.pl
50	Jan Nowak	528 259 205	jnwk767676@gmail.com
51	Dariusz Jabeł	666 666 666	djabeł@protonmail.com
52	Grzegorz Horner	735 560 800	ghoor@vp.pl
53	Jacek Placek	123 456 798	placekjacek@gmail.com
54	Jacek Stalon	7	staljacek@mail.ru
55	Jan Kudlacz	689 494 494	kudlaczjan@o5.pl
56	Mateusz Czeski	232 323 232	czeskim@poczta.oficialna.gov.pl
57	Piotr Dolewas	107 595 555	piotrdolewas@gmai.com
58	Jan Łabędzki	777 888 990	labedzkijan@mail.ru
59	Jack Longflield	902 210 101	jl@gmaix.com
60	Łukasz Niebołaz	545 483 242	ŁukaszNie@mail.io
61	Roman Klonowy	104 139 303	klonowyr@hmm.ru
62	Piotr Kendra	381 102 190	kendrap@gm.fr
63	Jerema Klimek	104 040 103	pieshead@o3.pl
64	Stanisław Tarański	491 212 214	staranski@p.gov.ok
\.


--
-- Data for Name: routepackages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routepackages (route_id, package_id) FROM stdin;
1	1
1	9
1	5
2	21
2	16
3	27
3	17
3	13
4	10
4	31
4	28
5	2
5	30
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routes (id, "time", destination_parcelpoint_id, vehicle_id, courier_id, completed, source_parcelpoint_id) FROM stdin;
1	2023-05-03 13:20:00	2	1	1	t	1
2	2023-05-24 11:31:00	2	10	3	t	4
3	2023-05-24 18:32:00	4	4	7	t	1
4	2023-05-24 18:56:00	3	5	1	f	2
5	2023-05-24 19:00:00	1	3	2	f	2
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, courier_id, parcelpoint_id, email, password_hash, admin) FROM stdin;
9	\N	5	punktpaczkowy5@gmail.com	$2b$12$y9U1Lb8wVWy9boN7uAkcTOchBW/4lVwzgfbXru5vGbozG9Noe2Qem	f
22	8	\N	kurier8@gmail.com	$2b$12$PEf9ztpi3qTS0JbNBiUceOuw4twsRth1nNm0m6bZoaD/uJ09cXiH.	f
20	6	\N	kurier6@gmail.com	$2b$12$5RAV75EvhUOazt2q7mKtMujZY19eRNgMDOoIsaZQAtevHuH2uo1pm	f
18	4	\N	kurier4@gmail.com	$2b$12$AscGGgblRJRrmqxTPaHDNepSh2TM5p9bFAoRhKwLtjn6g605hPJ/K	f
6	\N	2	punktpaczkowy2@gmail.com	$2b$12$b88HYidiT8p7KvYT6KyfGuihPxi26fEUDIhP6DGYmMbOiGVtrqIam	f
5	\N	1	punktpaczkowy1@gmail.com	$2b$12$A0HyKdggdMGfl3ZIfQg8OOP9sen2WO6SQJsj6igWTwqnPDh3fA58.	f
16	2	\N	kurier2@gmail.com	$2b$12$3TbPAOyO43G8xplT4aO3J.6mavmlrE0GWpULkrDG0EmxDlNz6SEG6	f
11	\N	7	punktpaczkowy7@gmail.com	$2b$12$5U32NbpZooS/3p8ILuRDse55eVeWjBg.jTvg62wb/64KE7FBj4KBC	f
25	\N	\N	admin@gmail.com	$2b$12$qktzrHyaKrIFowpboTh9r.z39QSDiF5E46DEaAGYuVe1oPbDlRO82	t
23	9	\N	kurier9@gmail.com	$2b$12$Z87cHHflWxLudt6xbjDASe1qBxcrukhSCrLY4N1lEr6czGNRR6l/S	f
21	7	\N	kurier7@gmail.com	$2b$12$dB96A6fuXj2VF5vAgJVQmel4IYGhrI0dFz08zai.OfoFXfuzm6mhS	f
19	5	\N	kurier5@gmail.com	$2b$12$McnGk0nlsp5Eajrw.rCNQuTllgSdxCx2CAnS2HHqtop4sw0S6Xyty	f
13	\N	9	punktpaczkowy9@gmail.com	$2b$12$c4Ecog2Om9VA7THKRLR5oOYHopLHZ2BBLBwcVD2saKNX.HRP0dgV2	f
8	\N	4	punktpaczkowy4@gmail.com	$2b$12$RWehN9ew7eNi.Eotkce.P.MR/LcxWr.y/nndvM5LZq8K86GOkuECe	f
17	3	\N	kurier3@gmail.com	$2b$12$WRVdEeuVCaJRnUvFFu.yLuc9rx.LJDJsA40ZzripBsVnyTTsYXKGW	f
12	\N	8	punktpaczkowy8@gmail.com	$2b$12$pRazwitV7piVZ8jsiGvxv.l2VN.N90Haay2cxUSidI./YA56E0Qbi	f
14	\N	10	punktpaczkowy10@gmail.com	$2b$12$OhXGjYc7VAeAzYx6x1kEO.PHcENNC/q1nqOGw9.tGMZ0RVmBCIVTG	f
7	\N	3	punktpaczkowy3@gmail.com	$2b$12$fL/zp7xU7c5u5X57oJbl7u8oZ6gxFpjVe7XYKmXArWulFAwEloqfG	f
15	1	\N	kurier1@gmail.com	$2b$12$8uDI7vTJUU4.zotbnjN5xO.FF3RUTeGIJ.HOsXBUobckOBr4Q5eGO	f
24	10	\N	kurier10@gmail.com	$2b$12$iCwiygJdSI5ryAsNvKbV/OmNJl473YjHAbZtQOO4nxXzIWQB.s5KO	f
26	\N	6	punktpaczkowy6@gmail.com6	$2b$12$dJXEEiP62rP5jSoOGZUxKOcNPhq5iOW2N42WDkJA2IUUOrUa9RnwK	f
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicles (id, registration_plate, max_weight) FROM stdin;
2	DEF456	2000.00000
1	ABC123	1500.00000
3	GHI789	1800.50000
4	JKL012	2200.75000
5	MNO345	1900.25000
6	PQR678	1700.50000
7	STU901	2100.75000
8	VWX234	1600.25000
10	BCD890	10.75000
9	YZA567	5.50000
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 26, true);


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
-- Name: users users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users users_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pk PRIMARY KEY (id);


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
-- Name: routes routes_parcelpoints_1; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_parcelpoints_1 FOREIGN KEY (destination_parcelpoint_id) REFERENCES public.parcelpoints(id);


--
-- Name: routes routes_parcelpoints_2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_parcelpoints_2 FOREIGN KEY (source_parcelpoint_id) REFERENCES public.parcelpoints(id);


--
-- Name: routes routes_vehicles; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.routes
    ADD CONSTRAINT routes_vehicles FOREIGN KEY (vehicle_id) REFERENCES public.vehicles(id);


--
-- Name: users users_couriers; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_couriers FOREIGN KEY (courier_id) REFERENCES public.couriers(id);


--
-- Name: users users_parcelpoints; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_parcelpoints FOREIGN KEY (parcelpoint_id) REFERENCES public.parcelpoints(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;


--
-- PostgreSQL database dump complete
--

