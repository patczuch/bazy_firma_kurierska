import { useState } from 'react';
import APIService from './APIService';
import { useNavigate } from "react-router-dom";

function Register(props) {
    const [registerForm, setregisterForm] = useState({
      email: "",
      password: ""
    })

    const navigate = useNavigate()

    function register(event) {
      event.preventDefault()
      APIService.register(registerForm.email, registerForm.password, props, navigate)
      //console.log(props.token)
    }

    function handleChange(event) { 
      const {value, name} = event.target
      setregisterForm(prevNote => ({
          ...prevNote, [name]: value})
      )}

    return ( 
      <div style = {{display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
    <form onSubmit= {register} style = {{display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center'}} className="register">
      <label>
        <input onChange={handleChange} style = {{margin:'0.5em'}}
                  type="email"
                  text={registerForm.email} 
                  name="email" 
                  placeholder="Email" 
                  value={registerForm.email} />
      </label>
      <label>
        <input onChange={handleChange} style = {{margin:'0.5em'}}
                  type="password"
                  text={registerForm.password} 
                  name="password" 
                  placeholder="Hasło" 
                  value={registerForm.password} />
      </label>
      <button style={{margin: '1em'}} className="button **is-large is-success is-rounded**" type="submit">Zarejestruj</button>
    </form>
    </div>
    );
}

export default Register;