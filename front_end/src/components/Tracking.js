import React, {useState, useEffect, Component} from "react";
import APIService from '../components/APIService'

export function Tracking() {
    const [package_history, set_package_history] = useState([]);
    const [package_id, set_package_id] = useState('')
    const [package_searched, set_package_searched] = useState(false)

    const handle_submit=(event)=>{ 
        event.preventDefault()
        APIService.get_package_history({package_id})
        .then((response) => set_package_history(response))
        .catch(error => console.log('error',error))
        set_package_searched(true)
      }

    return <div>
        <p style={{margin: '0.5em', display: 'flex', alignItems: 'center', justifyContent: 'center'}}>Wpisz numer przesyłki</p>
        <form onSubmit={handle_submit} style = {{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
                    <input style={{margin: '0.5em'}} type="number" placeholder="Numer przesyłki" value={package_id} onChange={(e)=>set_package_id(e.target.value)} />
                    <br></br>
                    <input style={{margin: '0.5em'}} type='submit' className="button **is-large is-success is-rounded**" value='Szukaj'/>
        </form>
        <div style = {{padding: '1em', margin: '1em', border: package_searched ? '2px solid darkseagreen' : 'none', borderRadius: '2em'}}>
            {package_history.map((el,i) => 
            <div key = {"tracking_history_container_"+i} style = {{borderTop: i != 0 ? '1px solid lightgray': 'none'}} className="columns">
                <div className="column" style={{padding : '1em'}} key = {"tracking_history_"+i+"_"+0}> 
                    {el[0]} 
                </div>
                <div className="column"  style={{padding : '1em'}} key = {"tracking_history_"+i+"_"+1}> 
                    {el[1]} 
                </div>
            </div>
            )}
            {package_history.length == 0 && package_searched ? "Nie znaleziono przesyłki z takim numerem!" : ""}
        </div>
        </div>;
}