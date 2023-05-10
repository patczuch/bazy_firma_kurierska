create or replace function pickUpPackage(_packageId integer)
    returns integer
    language plpgsql
    -- funkcja służąca do potwierdzenia odbioru paczki z punktu docelowego, przyjmuje i zwraca jej id
as
$$
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

alter function pickUpPackage(integer) owner to postgres;
