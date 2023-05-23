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
        ) as T1     -- wszystkie paczki z czasem przybycia do ich ostatniego punktu paczkowego

        inner join (
            select P.id as package_id
            from packages P
            EXCEPT
            select P.id as package_id
            from packages P
            inner join routepackages RP on P.id = RP.package_id
            inner join routes R on RP.route_id = R.id
            where R.completed = false
        ) as T2 on T1.package_id = T2.package_id    -- paczki które NIE są aktualnie w trasie

        inner join parcelpointpackages as PPP on T1.package_id = PPP.package_id
        inner join packages P on PPP.package_id = P.id
        where PPP.time = T1.last_update and PPP.parcelpoint_id = _parcelPointID and P.pickedup_time IS NULL;

end;
$$;

alter function getContentsOfParcelPoint(integer) owner to postgres;
