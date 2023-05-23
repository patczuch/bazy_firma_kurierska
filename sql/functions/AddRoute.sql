create  or replace function addRoute(_time timestamp, _sourceID integer, _destinationID integer,
    _vehicleID integer, _courierID integer, _packcagesID integer[])
    returns integer
    language plpgsql
    -- dodaje nową trase przewozu, przyjmuje czas rozpoczęcia, id startowego oraz końcowego punktu paczkowego, id samochodu oraz kuriera oraz
    -- tablice id paczek do przewiezienia, zwraca id nowej trasy
as
$$
declare
    waga integer := 0;
    _routeID integer := (select COALESCE(max(id),0) from routes) + 1;
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

alter function addRoute(timestamp, integer, integer, integer,  integer,  integer[]) owner to postgres;

