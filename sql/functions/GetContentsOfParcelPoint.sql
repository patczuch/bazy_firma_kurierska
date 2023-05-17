create or replace function getContentsOfParcelPoint (_parcelPointID integer)
returns table (
    waiting_package_id integer
)
language plpgsql
-- zwraca tabele id paczek które w danym momencie są w punkcie paczkowym o id z argumentu
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
        inner join packages p on PPP.package_id = p.id
        where T1.last_update = PPP.time and PPP.parcelpoint_id = _parcelPointID and pickedup_time IS NULL;

end;
$$;

alter function getContentsOfParcelPoint(integer) owner to postgres;
