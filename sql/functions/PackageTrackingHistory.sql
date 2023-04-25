create or replace function packagetrackinghistory(_package_id integer)
    returns TABLE("time" timestamp without time zone, description character varying)
    language plpgsql
as
$$
begin
    if (NOT EXISTS (select * from packages where id = _package_id)) then
        RAISE unique_violation USING MESSAGE = 'Package with id ' || _package_id || ' doesnt exist!';
    end if;
	return query
		(
		select
			pps.time,
			CASE WHEN pps.parcelpoint_id = (select destination_packagepoint_id from packages where id = _package_id) THEN
			    ('Gotowa do odbioru w oddziale ' || pps.parcelpoint_id)::varchar
                ELSE ('Przyjęto w oddziale ' || pps.parcelpoint_id)::varchar
		    END
		from
			parcelpointpackages pps
		where
			_package_id = pps.package_id
	    union
        select
            r.time, ('Wysłano do oddziału ' || r.destination_parcelpoint_id)::varchar
		from
			routes r
		inner join routepackages rp on r.id = rp.route_id
		where
			_package_id = rp.package_id
        union
        select p.pickedup_time, 'Odebrano'::varchar
        from packages p
        where
            _package_id = p.id
        and
            p.pickedup_time is not null
		)
	    order by time;
end;
$$;

alter function packagetrackinghistory(integer) owner to postgres;