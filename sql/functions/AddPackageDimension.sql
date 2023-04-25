create  or replace function addPackageDimension(_name varchar(20), _dimX decimal(10, 5) , _dimY decimal(10, 5) ,
    _dimZ decimal(10, 5))
    returns integer
    language plpgsql
as
$$
declare
    _dimensionID integer := (select max(id) from packagedimensions) + 1;
begin
    if (length(_name) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Name cant be empty !';
    end if;

    if (_dimX <= 0) then
        RAISE unique_violation USING MESSAGE = 'X dimension must be positive !';
    end if;

    if (_dimY <= 0) then
        RAISE unique_violation USING MESSAGE = 'Y dimension must be positive !';
    end if;

    if (_dimZ <= 0) then
        RAISE unique_violation USING MESSAGE = 'Z dimension must be positive !';
    end if;

    if(exists(select id from packagedimensions d where dimension_y = _dimY and dimension_x = _dimX and dimension_z = _dimZ)) then
        RAISE unique_violation USING MESSAGE = 'Package dimension with those dimensions exists !';
    end if;

    if(exists(select id from packagedimensions d where d.name = _name)) then
        RAISE unique_violation USING MESSAGE = 'Package dimension with this name exists !';
    end if;

    insert into packagedimensions(id, name, dimension_x, dimension_y, dimension_z)
        values (_dimensionID, _name, _dimX, _dimY, _dimZ);

    return _dimensionID;
end;
$$;

alter function addPackageDimension(varchar(20), decimal(10, 5) , decimal(10, 5) , decimal(10, 5)) owner to postgres;


