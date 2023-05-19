import React, {useState, useEffect, Component} from "react";
import APIService from '../components/APIService'
import { Navigate } from 'react-router-dom';
import Select from 'react-select'

export function NewRoute(props) {
    useEffect(() => { load_package_dimensions();load_parcelpoints()}, [])
    const [destination_packagepoint_id, set_destination_packagepoint_id] = useState('')
    const [source_packagepoint_id, set_source_packagepoint_id] = useState(props.user_parcelpoint_id)

    const [package_dimensions, set_package_dimensions] = useState([]);
    const [parcelpoints, set_parcelpoints] = useState([]);
    const [selectedOptions, setSelectedOptions] = useState();

    const handle_submit=(event)=>{ 
        event.preventDefault()
        APIService.create_route({},props.token)
        .then((response) => {
            if (!response || response["error"])
                alert("Wystąpił błąd. Trasa nie została stworzona.\n" + response["error"])
            else
                alert(response["success"])
        })
        .catch(error => console.log('error',error))
      }

      if (!props.user_parcelpoint_id) {
        return <Navigate to="/" replace />;
      }

      const load_package_dimensions=()=>{ 
        APIService.get_package_dimensions()
        .then((response) => {
            set_package_dimensions(response); 
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


      // Array of all options
      const optionList = [
        { value: "red", label: "Red" },
        { value: "green", label: "Green" },
        { value: "yellow", label: "Yellow" },
        { value: "blue", label: "Blue" },
        { value: "white", label: "White" }
      ];

      // Function triggered on selection
      function handleSelect(data) {
        setSelectedOptions(data);
      }

    return <div style = {{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
       <form onSubmit={handle_submit} style = {{display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center'}}>
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
            <Select
              options={optionList}
              placeholder="Wybierz paczki"
              value={selectedOptions}
              onChange={handleSelect}
              isSearchable={true}
              isMulti
            />
            <input style={{margin: '0.5em'}} type='submit' className="button **is-large is-success is-rounded**" value='Stwórz trasę'/>
        </form>
        </div>;
}