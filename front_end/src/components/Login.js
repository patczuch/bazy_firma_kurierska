import { useState } from 'react';
import APIService from './APIService';
import { useNavigate } from "react-router-dom";

function Login(props) {

    const [loginForm, setloginForm] = useState({
      email: "",
      password: ""
    })

    const navigate = useNavigate()

    function logMeIn(event) {
      event.preventDefault()
      APIService.login(loginForm.email, loginForm.password, props, navigate)
      //console.log(props.token)
    }

    function handleChange(event) { 
      const {value, name} = event.target
      setloginForm(prevNote => ({
          ...prevNote, [name]: value})
      )}

    return ( 
      <div style = {{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
    <form onSubmit= {logMeIn} style = {{display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center'}} className="login">
      <label>
        <input onChange={handleChange} style = {{margin:'0.5em'}}
                  type="email"
                  text={loginForm.email} 
                  name="email" 
                  placeholder="Email" 
                  value={loginForm.email} />
      </label>
      <label>
        <input onChange={handleChange} style = {{margin:'0.5em'}}
                  type="password"
                  text={loginForm.password} 
                  name="password" 
                  placeholder="Hasło" 
                  value={loginForm.password} />
      </label>
      <button style={{margin: '1em'}} className="button **is-large is-success is-rounded**" type="submit">Zaloguj</button>
      {props.token}
    </form>
    </div>
    );
}

export default Login;