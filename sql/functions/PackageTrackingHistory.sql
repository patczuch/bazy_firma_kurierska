create or replace function PackageTrackingHistory (
  _package_id int
)
	returns table (
		"time" timestamp,
		description varchar
	)
	language plpgsql
as $$
begin
	return query
		(
		select
			pps.time, ('Przyjęto w oddziale ' || pps.parcelpoint_id)::varchar
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
end;$$