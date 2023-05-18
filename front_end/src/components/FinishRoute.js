import React, {useState, useEffect, Component, cloneElement} from "react";
import APIService from '../components/APIService'
import { useNavigate, Navigate } from 'react-router-dom';

export function FinishRoute(props) {
  useEffect(() => { load_routes();load_parcelpoints()}, [])
  const [routes, set_routes] = useState([]);
  const [parcelpoints, set_parcelpoints] = useState([]);

      const load_routes=()=>{ 
        APIService.get_routes(props.token)
        .then((response) => set_routes(response))
        .catch(error => console.log('error',error))
      }

      const load_parcelpoints=()=>{ 
        APIService.get_parcelpoints()
        .then((response) => {
            set_parcelpoints(response);  
        })
        .catch(error => console.log('error',error))
      }

      const confirm_finished = (id)=>{
        APIService.finish_route(id, props.token)
        .then((response) => {
          if (response["success"])
            alert(response["success"]); 
          else
            alert(response["error"])
          window.location.reload(false); 
        })
        .catch(error => console.log('error',error))
      }

    if (!props.user_courier_id) {
      return <Navigate to="/" replace />;
    }
    return <div>
    <div style = {{padding: '1em', margin: '1em', border: '2px solid darkseagreen', borderRadius: '2em'}}>
        {(!routes || !routes.map) ? "" : routes.map((el,i) => 
        <div key = {"routes_container_"+i} style = {{borderTop: i != 0 ? '1px solid lightgray': 'none'}}>
            <div style={{padding : '1em', display: 'table-row'}} key = {"routes_container_"+i+"_"+0}> 
                <div style= {{display: 'table-cell', width: '5em'}}> ID: {el["id"]} </div> 
                <div style= {{display: 'table-cell', width: '20em'}}> Data: {el["time"]} </div> 
                <div style= {{display: 'table-cell', width: '10em'}}> Pojazd: {el["vehicle_reg_plate"]} </div> 
                {(!parcelpoints || !parcelpoints.map) ? "" : parcelpoints.filter((el2) => el2["id"] == el["source_parcelpoint_id"]).map((el3,i) => 
                <div key = {"routes_container_"+i+"_"+0+"_1"} style= {{display: 'table-cell', width: '30em'}}>
                    Punkt poczatkowy:<br></br> {el3["id"] + ". " + el3["name"]+ " " + el3["city"] + " " + el3["street"] + " " + el3["house_number"] + (el3["apartment_number"] ? "/" + el3["apartment_number"] : "")}
                </div>)}
                {(!parcelpoints || !parcelpoints.map) ? "" : parcelpoints.filter((el2) => el2["id"] == el["destination_parcelpoint_id"]).map((el3,i) => 
                <div key = {"routes_container_"+i+"_"+0+"_2"}style= {{display: 'table-cell', width: '30em'}}>
                    Punkt docelowy:<br></br> {el3["id"] + ". " + el3["name"]+ " " + el3["city"] + " " + el3["street"] + " " + el3["house_number"] + (el3["apartment_number"] ? "/" + el3["apartment_number"] : "")}
                </div>)}
                <input style={{margin: '0.5em'}} type='button' className="button **is-large is-success is-rounded**" value='Potwierdź odbycie trasy' onClick={() => confirm_finished({"route_id": el["id"]})}/> 
            </div>
        </div>
        )}
        {(!routes || !routes.map) ? "Brak tras!" : ""}
    </div>
    </div>;
}