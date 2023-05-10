create  or replace function completeRoute(_routeID integer)
    returns integer
    language plpgsql
    -- funkcja której używa kurier aby zaznaczyć trasę jako zakończoną, przyjmuje i zwraca jej id, przenosi ona rówież w bazie
    -- paczki z trasy do docelowego punktu paczkowego
as
$$
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

alter function completeRoute(integer) owner to postgres;


