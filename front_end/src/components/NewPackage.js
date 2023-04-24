import React, {useState, useEffect, Component} from "react";
import APIService from '../components/APIService'

export function NewPackage() {
    const [weight, set_weight] = useState('')
    const [dimensions_id, set_dimensions_id] = useState('')
    const [recipient_name, set_recipient_name] = useState('')
    const [recipient_phone_number, set_recipient_phone_number] = useState('')
    const [sender_name, set_sender_name] = useState('')
    const [sender_phone_number, set_sender_phone_number] = useState('')
    const [destination_packagepoint_id, set_destination_packagepoint_id] = useState('')
    const [source_packagepoint_id, set_source_packagepoint_id] = useState('')
    const [recipient_email, set_recipient_email] = useState('')
    const [sender_email, set_sender_email] = useState('')

    const handle_submit=(event)=>{ 
        event.preventDefault()
        APIService.register_package({weight, dimensions_id, recipient_name, recipient_phone_number, sender_name, sender_phone_number, 
            destination_packagepoint_id, source_packagepoint_id, recipient_email, sender_email})
        .then((response) => {
            if (response != "error")
                alert("Paczka zarejestrowana. ID: " + response)
            else
                alert("Wystąpił błąd. Paczka nie została zarejestrowana.")
        })
        .catch(error => console.log('error',error))
      }

    return <div style = {{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
       <form onSubmit={handle_submit} style = {{display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center'}}>
            <input style={{margin: '0.5em', width: '20em'}} type="number" step="0.1" placeholder="Waga" value={weight} onChange={(e)=>set_weight(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="number" placeholder="Rozmiar" value={dimensions_id} onChange={(e)=>set_dimensions_id(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Imię i nazwisko nadawcy" value={sender_name} onChange={(e)=>set_sender_name(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Numer telefonu nadawcy" value={sender_phone_number} onChange={(e)=>set_sender_phone_number(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Email nadawcy" value={sender_email} onChange={(e)=>set_sender_email(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Imię i nazwisko odbiorcy" value={recipient_name} onChange={(e)=>set_recipient_name(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Numer telefonu odbiorcy" value={recipient_phone_number} onChange={(e)=>set_recipient_phone_number(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="text" placeholder="Email odbiorcy" value={recipient_email} onChange={(e)=>set_recipient_email(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="number" placeholder="Punkt paczkowy nadawczy" value={source_packagepoint_id} onChange={(e)=>set_source_packagepoint_id(e.target.value)} />
            <input style={{margin: '0.5em', width: '20em'}} type="number" placeholder="Punkt paczkowy odbiorczy" value={destination_packagepoint_id} onChange={(e)=>set_destination_packagepoint_id(e.target.value)} />
            <input style={{margin: '0.5em'}} type='submit' className="button **is-large is-success is-rounded**" value='Zarejestruj przesyłkę'/>
        </form>
        </div>;
}