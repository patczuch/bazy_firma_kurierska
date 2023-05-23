create or replace function addCourier (_firstname varchar, _lastname varchar, _phoneNumber varchar) returns integer
    language plpgsql
    -- dodaje nowego kuriera, zwraca jego id
as
$$
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

alter function addCourier(varchar, varchar, varchar) owner to postgres;
