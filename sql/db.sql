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
    _id integer := (select max(id) from couriers) + 1;

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
    _dimensionID integer := (select max(id) from packagedimensions) + 1;
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
    _id integer := (select max(id) from parcelpoints) + 1;

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
    objetosc integer := 0;
    waga integer := 0;
    _routeID integer := (select max(id) from routes) + 1;
    _pacID integer;
begin
    if (_time < now() ) then
        RAISE unique_violation USING MESSAGE = 'Cant create route in past !';
    end if;

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

    foreach _pacID in array _packcagesID loop
        if (NOT EXISTS (select * from packages where id = _pacID)) then
            RAISE unique_violation USING MESSAGE = 'Package with id ' || _pacID || ' doesnt exist!';
        end if;
        if (packagelocation(_pacID) != _sourceID) then
            RAISE unique_violation USING MESSAGE = 'Package with id ' || _pacID || ' isnt at source package point !';
        end if;
        objetosc := objetosc + (select pd.dimension_x * pd.dimension_y * pd.dimension_z from packagedimensions pd
            inner join packages p on pd.id = p.dimensions_id where p.id = _pacID);
        waga := waga + (select p.weight from packages p where  p.id = _pacID);
    end loop;

    if (objetosc > (select v.dimension_z * v.dimension_x * v.dimension_y from vehicles v where v.id = _vehicleID)) then
        RAISE unique_violation USING MESSAGE = 'Packages are to big for this vehicle ' || _vehicleID;
    end if;

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
-- Name: addvehicle(character varying, numeric, numeric, numeric, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.addvehicle(_registrationplate character varying, _dimx numeric, _dimy numeric, _dimz numeric, _maxweight numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $$
declare
    _vehicleID integer := (select max(id) from vehicles) + 1;
begin
    if (length(_registrationPlate) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Registration plate cant be empty !';
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

     if (_maxWeight <= 0) then
        RAISE unique_violation USING MESSAGE = 'Max weight must be positive !';
    end if;

    if(exists(select id from vehicles d where d.registration_plate = _registrationPlate)) then
        RAISE unique_violation USING MESSAGE = 'Vehicle with this registration plate exists !';
    end if;

    insert into vehicles (id, registration_plate, dimension_x, dimension_y, dimension_z, max_weight)
        values (_vehicleID, _registrationPlate, _dimX, _dimY, _dimZ, _maxWeight);

    return _vehicleID;
end;
$$;


ALTER FUNCTION public.addvehicle(_registrationplate character varying, _dimx numeric, _dimy numeric, _dimz numeric, _maxweight numeric) OWNER TO postgres;

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
        ) as T1
        inner join parcelpointpackages as PPP on T1.package_id = PPP.package_id
        where T1.last_update = PPP.time and PPP.parcelpoint_id = _parcelPointID;

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
    sender_id int := (select max(id) from personinfo)+1;
    recipient_id int := sender_id + 1;
    _package_id int := (select max(id) from packages)+1;
    parcelpointpackages_id int := (select max(id) from parcelpointpackages)+1;
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
    password_hash character varying(255) NOT NULL
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
    dimension_x numeric(10,5) NOT NULL,
    dimension_y numeric(10,5) NOT NULL,
    dimension_z numeric(10,5) NOT NULL,
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
1	Dawid	Dąbrowski	123789456
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
2	0.50000	1	3	4	1	\N
3	1.20000	2	5	6	2	\N
4	0.20000	2	7	8	1	\N
1	5.00000	2	1	2	2	2023-04-25 10:25:46.795572
\.


--
-- Data for Name: parcelpointpackages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parcelpointpackages (id, package_id, parcelpoint_id, "time") FROM stdin;
1	1	1	2023-04-21 23:33:19
3	2	2	2023-04-23 18:03:41.04
4	3	1	2023-04-23 18:33:55.79
5	4	2	2023-04-24 17:09:52.81
6	2	1	2023-04-25 09:57:35.609408
7	4	1	2023-04-25 09:57:35.609408
8	1	2	2023-04-25 10:25:43.317601
\.


--
-- Data for Name: parcelpoints; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parcelpoints (id, name, city, street, house_number, apartment_number) FROM stdin;
1	Punkt Krakowski	Kraków	Jasnogórska	22	\N
2	Punkt Warszawski	Warszawa	Złota	44	51
\.


--
-- Data for Name: personinfo; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personinfo (id, name, phone_number, email) FROM stdin;
1	Jan Kowalski	123456789	\N
2	Tomasz Nowak	987654321	\N
3	Olaf Kudłacz	123456789	
4	Radosław Cegła	321654876	
5	Tomasz Misztal	123456123	
6	Jan Nowak	568901233	
7			
8			
\.


--
-- Data for Name: routepackages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routepackages (route_id, package_id) FROM stdin;
1	1
2	2
2	4
3	2
3	4
\.


--
-- Data for Name: routes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.routes (id, "time", destination_parcelpoint_id, vehicle_id, courier_id, completed, source_parcelpoint_id) FROM stdin;
2	2023-04-24 10:40:19	1	1	1	t	2
3	2023-04-26 10:40:19	2	1	1	f	1
1	2023-04-21 23:40:19	2	1	1	t	1
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, courier_id, parcelpoint_id, email, password_hash) FROM stdin;
4	\N	\N	kurier2@gmail.com	$2b$12$ofAYapQ8.So0TefzFUkFy.h79zR9t/wPmv8zAt839/j7B9/jL7kCC
3	1	\N	kurier1@gmail.com	$2b$12$zN3YCuotJhhvDuVrNZvW/uX1nCiMCmKRnTJqD7tp/ih3vxQiXuQX2
7	\N	1	punktpaczkowy1@gmail.com	$2b$12$3mSwizx/ceLy/UzShzXoXuauI3Xb3330uL58gIxDH.myLgVepaX9u
6	1	2	wszystko@gmail.com	$2b$12$5gMtzSwfKmYnqoTz0.jnnuLqhb9.KFJqaIDkgBcY.jXK0ROTdx9wq
\.


--
-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.vehicles (id, registration_plate, dimension_x, dimension_y, dimension_z, max_weight) FROM stdin;
1	KRA 81TL	500.00000	228.00000	196.00000	10000.50000
2	K2 AK47	700.00000	150.00000	270.00000	17777.00000
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 1, false);


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

