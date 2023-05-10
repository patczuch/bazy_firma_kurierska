create  or replace function addVehicle(_registrationPlate varchar(10), _dimX decimal(10, 5) , _dimY decimal(10, 5) ,
    _dimZ decimal(10, 5), _maxWeight decimal(10, 5))
    returns integer
    language plpgsql
    -- dodaje nowy pojazd, przyjmuje unikalny numer rejestarcyjny, wymiary oraz maksymalny udźwig, zwraca id 
as
$$
declare
    _vehicleID integer := (select max(id) from vehicles) + 1;
begin
    if (length(_registrationPlate) <= 0) then
        RAISE unique_violation USING MESSAGE = 'Registration plate cant be empty !';
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

     if (_maxWeight <= 0) then
        RAISE unique_violation USING MESSAGE = 'Max weight must be positive !';
    end if;

    if(exists(select id from vehicles d where d.registration_plate = _registrationPlate)) then
        RAISE unique_violation USING MESSAGE = 'Vehicle with this registration plate exists !';
    end if;

    insert into vehicles (id, registration_plate, dimension_x, dimension_y, dimension_z, max_weight)
        values (_vehicleID, _registrationPlate, _dimX, _dimY, _dimZ, _maxWeight);

    return _vehicleID;
end;
$$;

alter function addVehicle(varchar(10), decimal(10, 5) , decimal(10, 5) , decimal(10, 5), decimal(10, 5)) owner to postgres;


