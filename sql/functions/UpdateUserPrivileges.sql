create function updateUserPrivileges(_id integer, _courier_id integer, _parcelpoint_id integer, _admin boolean)
    returns integer
    language plpgsql
    -- zmienia ustawienia dostępności dla konta z podanym id;
    -- przyjmuje id konta, id kuriera, id punktu paczkowego oraz informację czy jest to admin
as
$$
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

alter function updateuserprivileges(integer, integer, integer, boolean) owner to postgres;