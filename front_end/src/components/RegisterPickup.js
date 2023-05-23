import React, {useState, useEffect, Component, cloneElement} from "react";
import APIService from '../components/APIService'
import { useNavigate, Navigate } from 'react-router-dom';

export function RegisterPickup(props) {
  useEffect(() => load_packages(), [])
  const [packages, set_packages] = useState([]);

      let navigate = useNavigate(); 
      const routeChange = () =>{ 
        navigate("/tracking");
      }

      const load_packages=()=>{ 
        APIService.get_parcelpoint_packages(props.user_parcelpoint_id, props.token)
        .then((response) => set_packages(response))
        .catch(error => console.log('error',error))
      }

      const confirm_pickup = (id)=>{
        APIService.pickup_package(id, props.token)
        .then((response) => {
          if (response["success"])
            alert(response["success"]); 
          else
            alert(response["error"])
          window.location.reload(false); 
          console.log(response)
        })
        .catch(error => console.log('error',error))
      }

    if (!props.user_parcelpoint_id) {
      return <Navigate to="/" replace />;
    }
    return <div>
    <div style = {{padding: '1em', margin: '1em', border: '2px solid darkseagreen', borderRadius: '2em'}}>
        {(!packages || !packages.map) ? "" : packages.map((el,i) => 
        <div key = {"packages_container_"+i} style = {{borderTop: i != 0 ? '1px solid lightgray': 'none'}}>
            <div style={{padding : '1em', display: 'table-row'}} key = {"packages_container_"+i+"_"+0}> 
                <div style= {{display: 'table-cell', width: '5em'}}> Id: {el["id"]} </div> 
                <div style= {{display: 'table-cell', width: '10em'}}> Waga: {Math.round(el["weight"]*100)/100}kg </div> 
                <div style= {{display: 'table-cell', width: '10em'}}> Rozmiar: {el["dimensions_id"]} </div> 
                <div style= {{display: 'table-cell', width: '10em'}}> Punkt docelowy: {el["destination_packagepoint_id"]} </div> 
                <div style= {{display: 'table-cell', width: '25em'}}>
                  <div style={{display: 'flex', flexDirection: 'column'}}> 
                    <div>Dane nadawcy:</div> 
                    <div>Imię i nazwisko:{el["sender_name"]}</div> 
                    <div>Nr. tel:{el["sender_phone_number"]}</div> 
                    <div>Email:{el["sender_email"]}</div> 
                  </div> 
                </div>
                <div style= {{display: 'table-cell', width: '25em'}}>
                  <div style={{display: 'flex', flexDirection: 'column'}}> 
                    <div>Dane odbiorcy:</div> 
                    <div>Imię i nazwisko:{el["recipient_name"]}</div> 
                    <div>Nr. tel:{el["recipient_phone_number"]}</div> 
                    <div>Email:{el["recipient_email"]}</div> 
                  </div> 
                </div>
                <div style= {{display: 'table-cell'}}>
                  {el["destination_packagepoint_id"] == props.user_parcelpoint_id ? 
                    <input style={{margin: '0.5em'}} type='button' className="button **is-large is-success is-rounded**" value='Potwierdź odbiór' onClick={() => confirm_pickup({"package_id": el["id"]})}/> 
                  : ""} 
                 {/*<input style={{margin: '0.5em'}} type='button' onClick={routeChange} className="button **is-large is-success is-rounded**" value='Wyświetl historię'/>*/}
                </div>
            </div>
        </div>
        )}
        {(!packages || !packages.map) ? "Brak przesyłek!" : ""}
    </div>
    </div>;
}