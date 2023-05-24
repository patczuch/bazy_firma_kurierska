create or replace function RegisterPackage(_weight numeric, _dimensions_id integer, _recipient_name character varying, _recipient_phone_number character varying, _sender_name character varying, _sender_phone_number character varying, _destination_packagepoint_id integer, _source_packagepoint_id integer, _recipient_email character varying DEFAULT NULL::character varying, _sender_email character varying DEFAULT NULL::character varying) returns integer
    language plpgsql
    -- funckja do rejestrowania nowej paczki, przyjmuje jej wage, id z tabeli rozmiarów, dane nadawcy oraz odbiorcy, id punktów paczkowych między 
    -- którymi będzie musiała się przemieścić, zwraca jej id
as
$$
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

alter function registerpackage(numeric, integer, varchar, varchar, varchar, varchar, integer, integer, varchar, varchar) owner to postgres;

