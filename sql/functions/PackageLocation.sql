create  or replace function packagelocation(_package_id integer)
    returns TABLE(parcelpointid integer)
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
		    case when (select count(p.pickedup_time) from packages p where _package_id = p.id
		               and p.pickedup_time is not null) > 0 then null
		    else (select t.parcelpoint_id from
		         ((select ppp.parcelpoint_id, ppp.time from parcelpointpackages ppp where ppp.package_id = _package_id
		          union
		          select -1::integer, r.time from routes r inner join routepackages rp on r.id = rp.route_id
		                where rp.package_id = _package_id
		          ) order by time desc limit 1) t)
		    end
		);
end;
$$;

alter function packagelocation(integer) owner to postgres;