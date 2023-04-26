create or replace function getContentsOfParcelPoint (_parcelPointID integer)
returns table (
    waiting_package_id integer
)
language plpgsql
as
$$
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

alter function getContentsOfParcelPoint(integer) owner to postgres;