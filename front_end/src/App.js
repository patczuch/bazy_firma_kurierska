import React, {useState, useEffect, Component} from "react";
import {Tracking} from "./components/Tracking"
import {NewPackage} from "./components/NewPackage"
import {Error404} from "./components/Error404"
import {FinishRoute} from "./components/FinishRoute"
import Login from "./components/Login"
import Register from "./components/Register"
import Home from "./components/Home"
import {Navbar} from "./components/Navbar"
import {Routes, BrowserRouter, Route} from "react-router-dom";
import './App.css'
import 'bulma/css/bulma.min.css';
import { RegisterPickup } from "./components/RegisterPickup";
import { NewRoute } from "./components/NewRoute";
import useToken from './components/UseToken'
import useUser_id from './components/UseUser_id'
import useEmail from './components/UseEmail'

function App() {
  const { token, removeToken, setToken } = useToken();
  const { user_id, removeUser_id, setUser_id } = useUser_id();
  const { email, removeEmail, setEmail } = useEmail();

  return (
    <div>
      <BrowserRouter>
        <Navbar token={token} removeToken={removeToken} removeUser_id={removeUser_id} removeEmail={removeEmail} email={email}/>
        <Routes>
            <Route exact path="/" element={<Home />}></Route>
            <Route exact path="/tracking" element={<Tracking />}></Route>
            <Route exact path="/new_package" element={<NewPackage token={token}/>}></Route>
            <Route exact path="/register_pickup" element={<RegisterPickup />}></Route>
            <Route exact path="/new_route" element={<NewRoute />}></Route>
            <Route exact path="/finish_route" element={<FinishRoute />}></Route>
            <Route exact path="/login" element={<Login setUser_id={setUser_id} setEmail={setEmail} setToken={setToken} token={token}/>}></Route>
            <Route exact path="/register" element={<Register setToken={setToken} token={token}/>}></Route>
            <Route exact path="*" element={<Error404 />}></Route>
        </Routes>
      </BrowserRouter>
    </div>
  )
}

export default App