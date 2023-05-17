import React, {useState, useEffect, Component} from "react";
import APIService from '../components/APIService'
import { Navigate } from 'react-router-dom';

export function NewPackage(props) {
    useEffect(() => { load_package_dimensions();load_parcelpoints()}, [])
    const [weight, set_weight] = useState('')
    const [dimensions_id, set_dimensions_id] = useState('')
    const [recipient_name, set_recipient_name] = useState('')
    const [recipient_phone_number, set_recipient_phone_number] = useState('')
    const [sender_name, set_sender_name] = useState('')
    const [sender_phone_number, set_sender_phone_number] = useState('')
    const [destination_packagepoint_id, set_destination_packagepoint_id] = useState('')
    const [source_packagepoint_id, set_source_packagepoint_id] = useState(props.user_parcelpoint_id)
    const [recipient_email, set_recipient_email] = useState('')
    const [sender_email, set_sender_email] = useState('')

    const [package_dimensions, set_package_dimensions] = useState([]);
    const [parcelpoints, set_parcelpoints] = useState([]);

    const handle_submit=(event)=>{ 
        event.preventDefault()
        APIService.register_package({weight, dimensions_id, recipient_name, recipient_phone_number, sender_name, sender_phone_number, 
            destination_packagepoint_id, source_packagepoint_id, recipient_email, sender_email},props.token)
        .then((response) => {
            if (!response || response["error"])
                alert("Wystąpił błąd. Paczka nie została zarejestrowana.\n" + response["error"])
            else
                alert("Paczka zarejestrowana. ID: " + response)
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
            if (response && response[0])
                set_dimensions_id(response[0][0])
            else
                load_package_dimensions()  
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
                    response.filter((el) => el[0] != props.user_parcelpoint_id))[0][0])
            else
                load_parcelpoints()   
        })
        .catch(error => console.log('error',error))
      }

    return <div style = {{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
       <form onSubmit={handle_submit} style = {{display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center'}}>
            <input style={{margin: '0.5em', width: '20em'}} type="number" step="0.1" placeholder="Waga" value={weight} onChange={(e)=>set_weight(e.target.value)} />
            {/*<input style={{margin: '0.5em', width: '20em'}} type="number" placeholder="Rozmiar" value={dimensions_id} onChange={(e)=>set_dimensions_id(e.target.value)} />*/}
            <label htmlFor="dimensions">Rozmiar</label>
            <select name="dimensions" id="dimensions" style={{margin: '0.5em', width: '20em'}} value={dimensions_id} onChange={(e)=>set_dimensions_id(e.target.value)}>
            {(!package_dimensions || !package_dimensions.map) ? "" : package_dimensions.map((el,i) => 
            <option value={el[0]} key={"package_dimensions_option_"+i}>
                {el[1]+ " " + Math.round(el[2])+"x"+Math.round(el[3])+"x"+Math.round(el[4])+"cm"}
            </option>
            )}
            </select>
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Imię i nazwisko nadawcy" value={sender_name} onChange={(e)=>set_sender_name(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Numer telefonu nadawcy" value={sender_phone_number} onChange={(e)=>set_sender_phone_number(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Email nadawcy" value={sender_email} onChange={(e)=>set_sender_email(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Imię i nazwisko odbiorcy" value={recipient_name} onChange={(e)=>set_recipient_name(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Numer telefonu odbiorcy" value={recipient_phone_number} onChange={(e)=>set_recipient_phone_number(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Email odbiorcy" value={recipient_email} onChange={(e)=>set_recipient_email(e.target.value)} />
            {/*<input style={{margin: '0.5em', width: '20em'}} readonly="readonly" type="number" placeholder="Punkt paczkowy nadawczy" value={source_packagepoint_id} onChange={(e)=>set_source_packagepoint_id(e.target.value)} />*/}
            {/*<input style={{margin: '0.5em', width: '20em'}} type="number" placeholder="Punkt paczkowy odbiorczy" value={destination_packagepoint_id} onChange={(e)=>set_destination_packagepoint_id(e.target.value)} />*/}
            <label htmlFor="source_parcelpoint">Punkt nadawczy</label>
            <select name="source_parcelpoint" id="source_parcelpoint" style={{margin: '0.5em', width: '20em'}} value={source_packagepoint_id} onChange={(e)=>set_source_packagepoint_id(e.target.value)}>
            {(!parcelpoints || !parcelpoints.map) ? "" : parcelpoints.map((el,i) => 
                el[0] != props.user_parcelpoint_id ? "" : <option value={parseInt(el[0])} key={"source_parcelpoint_option_"+i}>
                    {el[0] + ". " + el[1]+ " " + el[2] + " " + el[3] + " " + el[4] + (el[5] ? "/" + el[5] : "")}
                </option>)}
            </select>
            <label htmlFor="destination_parcelpoint">Punkt odbiorczy</label>
            <select name="destination_parcelpoint" id="destination_parcelpoint" style={{margin: '0.5em', width: '20em'}} value={destination_packagepoint_id} onChange={(e)=>set_destination_packagepoint_id(e.target.value)}>
            {(!parcelpoints || !parcelpoints.map) ? "" : parcelpoints.map((el,i) => 
            el[0] == props.user_parcelpoint_id ? "" : <option value={parseInt(el[0])} key={"destination_parcelpoint_option_"+i}>
                {el[0] + ". " + el[1]+ " " + el[2] + " " + el[3] + " " + el[4] + (el[5] ? "/" + el[5] : "")}
            </option>
            )}
            </select>
            <input style={{margin: '0.5em'}} type='submit' className="button **is-large is-success is-rounded**" value='Zarejestruj przesyłkę'/>
        </form>
        </div>;
}