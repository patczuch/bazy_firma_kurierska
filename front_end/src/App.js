import React, {useState, useEffect, Component} from "react";
import {Tracking} from "./components/Tracking"
import {NewPackage} from "./components/NewPackage"
import {Error404} from "./components/Error404"
import {FinishRoute} from "./components/FinishRoute"
import Login from "./components/Login"
import Home from "./components/Home"
import {Navbar} from "./components/Navbar"
import {Routes, BrowserRouter, Route} from "react-router-dom";
import './App.css'
import 'bulma/css/bulma.min.css';
import { RegisterPickup } from "./components/RegisterPickup";
import { NewRoute } from "./components/NewRoute";
import useToken from './components/UseToken'

function App() {
  const { token, removeToken, setToken } = useToken();

  return (
    <div>
      <BrowserRouter>
        <Navbar token={token} removeToken={removeToken}/>
        <Routes>
            <Route exact path="/" element={<Home />}></Route>
            <Route exact path="/tracking" element={<Tracking />}></Route>
            <Route exact path="/new_package" element={<NewPackage />}></Route>
            <Route exact path="/register_pickup" element={<RegisterPickup />}></Route>
            <Route exact path="/new_route" element={<NewRoute />}></Route>
            <Route exact path="/finish_route" element={<FinishRoute />}></Route>
            <Route exact path="/login" element={<Login setToken={setToken} token={token}/>}></Route>
            <Route exact path="*" element={<Error404 />}></Route>
        </Routes>
      </BrowserRouter>
    </div>
  )
}

export default App