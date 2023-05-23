create or replace function addParcelPoint (_name varchar, _city varchar, _street varchar,
                                _houseNumber varchar, _apartmentNumber varchar) returns integer
language plpgsql
-- dodaje nowy punkt paczkowy, przyjmuje nazwe oraz kolejne częći adresu, zwraca nowe id

as
$$
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

alter function addParcelPoint(varchar, varchar, varchar, varchar, varchar) owner to postgres;
