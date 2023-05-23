import React, {useState, useEffect, Component} from "react";
import APIService from '../components/APIService'
import { Navigate } from 'react-router-dom';
import Select from 'react-select'

export function NewRoute(props) {
    useEffect(() => { load_parcelpoints();load_packages(); load_vehicles(); load_couriers()}, [])
    const [destination_packagepoint_id, set_destination_packagepoint_id] = useState('')
    const [route_time, set_route_time] = useState('')
    const [source_packagepoint_id, set_source_packagepoint_id] = useState(props.user_parcelpoint_id)
    const [courier, set_courier] = useState()
    const [vehicle, set_vehicle] = useState()
    const [parcelpoints, set_parcelpoints] = useState([]);
    const [packages, set_packages] = useState([]);
    const [vehicles, set_vehicles] = useState([]);
    const [couriers, set_couriers] = useState([]);
    const [_selected_packages, set_selected_packages] = useState([]);

    const handle_submit=(event)=>{ 
        event.preventDefault()
        var selected_packages = _selected_packages.map((el)=>el.value)
        APIService.create_route({route_time, source_packagepoint_id, destination_packagepoint_id, vehicle, courier, selected_packages},props.token)
        .then((response) => {
            if (!response || response["error"])
                alert("Wystąpił błąd. Trasa nie została stworzona.\n" + response["error"])
            else
                alert(response["success"])
            window.location.reload(false); 
        })
        .catch(error => console.log('error',error))
      }

      if (!props.user_parcelpoint_id) {
        return <Navigate to="/" replace />;
      }

      const formatOptionLabel = ({ p }, { context }) => {
        if (context === 'menu') {
          return "Id: " + p["id"] + ", Punkt docelowy: " + p["destination_packagepoint_id"] + ", Waga: " +  Math.round(p["weight"]*100)/100 + "kg, Rozmiar: " + p["dimensions_id"];
        }
        return "Id: " + p["id"];
      };
      
      const load_vehicles=()=>{ 
        APIService.get_vehicles(props.token)
        .then((response) => {
            set_vehicles(response); 
            set_vehicle(response[0]["id"])
        })
        .catch(error => console.log('error',error))
      }

      const load_couriers=()=>{ 
        APIService.get_couriers(props.token)
        .then((response) => {
            set_couriers(response); 
            set_courier(response[0]["id"])
        })
        .catch(error => console.log('error',error))
      }

      const load_packages=()=>{ 
        APIService.get_parcelpoint_packages(props.user_parcelpoint_id, props.token)
        .then((response) => {
          set_packages(response && response.map ? response.filter((p) => p["destination_packagepoint_id"] != props.user_parcelpoint_id).map((p) => {
            return {p: p, value: p["id"]}
          }) : [])
        })
        .catch(error => console.log('error',error))
      }

      const load_parcelpoints=()=>{ 
        APIService.get_parcelpoints()
        .then((response) => {
            set_parcelpoints(response); 
            //console.log(response.filter((el) => el[0] != props.user_parcelpoint_id)[0][0])
            if (response && response.filter && response[0])
                set_destination_packagepoint_id((
                    response.filter((el) => el["id"] != props.user_parcelpoint_id))[0]["id"])
            else
                load_parcelpoints()   
        })
        .catch(error => console.log('error',error))
      }

    return <div style = {{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
       <form onSubmit={handle_submit} style = {{display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center'}}>
       <label htmlFor="route_time_pick">Data i godzina</label>
       <input id="route_time_pick" name="route_time_pick" type="datetime-local" value={route_time} onChange={(e)=>set_route_time(e.target.value)}></input>
            <label htmlFor="source_parcelpoint">Punkt początkowy</label>
            <select name="source_parcelpoint" id="source_parcelpoint" style={{margin: '0.5em', width: '20em'}} value={source_packagepoint_id} onChange={(e)=>set_source_packagepoint_id(e.target.value)}>
            {(!parcelpoints || !parcelpoints.map) ? "" : parcelpoints.map((el,i) => 
                el["id"] != props.user_parcelpoint_id ? "" : <option value={parseInt(el["id"])} key={"source_parcelpoint_option_"+i}>
                    {el["id"] + ". " + el["name"]+ " " + el["city"] + " " + el["street"] + " " + el["house_number"] + (el["apartment_number"] ? "/" + el["apartment_number"] : "")}
                </option>)}
            </select>
            <label htmlFor="destination_parcelpoint">Punkt końcowy</label>
            <select name="destination_parcelpoint" id="destination_parcelpoint" style={{margin: '0.5em', width: '20em'}} value={destination_packagepoint_id} onChange={(e)=>set_destination_packagepoint_id(e.target.value)}>
            {(!parcelpoints || !parcelpoints.map) ? "" : parcelpoints.map((el,i) => 
            el["id"] == props.user_parcelpoint_id ? "" : <option value={parseInt(el["id"])} key={"destination_parcelpoint_option_"+i}>
                {el["id"] + ". " + el["name"]+ " " + el["city"] + " " + el["street"] + " " + el["house_number"] + (el["apartment_number"] ? "/" + el["apartment_number"] : "")}
            </option>
            )}
            </select>
            <label htmlFor="vehicle">Samochód</label>
            <select name="vehicle" id="vehicle" style={{margin: '0.5em', width: '20em'}} value={vehicle} onChange={(e)=>set_vehicle(e.target.value)}>
            {(!vehicles || !vehicles.map) ? "" : vehicles.map((el,i) => 
            <option value={parseInt(el["id"])} key={"vehicle_option_"+i}>
                {el["id"] + ". " + el["registration_plate"] + ", Maks. waga: " + Math.round(el["max_weight"]*100)/100+"kg"}
            </option>
            )}
            </select>
            <label htmlFor="courier">Kurier</label>
            <select name="courier" id="courier" style={{margin: '0.5em', width: '20em'}} value={courier} onChange={(e)=>set_courier(e.target.value)}>
            {(!couriers || !couriers.map) ? "" : couriers.map((el,i) => 
            <option value={parseInt(el["id"])} key={"courier_option_"+i}>
                {el["id"] + ". " + el["first_name"] + " " + el["last_name"] + ", Tel: " + el["phone_number"]}
            </option>
            )}
            </select>
            <div style = {{width: '30em'}}>
              <Select
                options={packages}
                placeholder="Wybierz paczki"
                value={_selected_packages}
                onChange={(e)=>set_selected_packages(e)}
                isSearchable={true}
                isMulti
                formatOptionLabel={formatOptionLabel}
              />
            </div>
            <input style={{margin: '0.5em'}} type='submit' className="button **is-large is-success is-rounded**" value='Stwórz trasę'/>
        </form>
        </div>;
}