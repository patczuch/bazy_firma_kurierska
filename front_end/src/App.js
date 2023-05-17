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
import useUser from './components/UseUser'

function App() {
  const { token, removeToken, setToken } = useToken();
  const { setUserId, user_id, removeUserId, setUserEmail, user_email, removeUserEmail, setUserCourierId, user_courier_id,
    removeUserCourierId, setUserParcelpointId, user_parcelpoint_id, removeUserPacelpontId, setUser, removeUser } = useUser();

  return (
    <div>
      <BrowserRouter>
        <Navbar token={token} removeToken={removeToken} user_email={user_email} user_parcelpoint_id={user_parcelpoint_id} user_courier_id={user_courier_id} removeUser={removeUser}/>
        <Routes>
            <Route exact path="/" element={<Home />}></Route>
            <Route exact path="/tracking" element={<Tracking />}></Route>
            <Route exact path="/new_package" element={<NewPackage user_parcelpoint_id={user_parcelpoint_id} token={token}/>}></Route>
            <Route exact path="/register_pickup" element={<RegisterPickup user_parcelpoint_id={user_parcelpoint_id} token={token}/>}></Route>
            <Route exact path="/new_route" element={<NewRoute user_parcelpoint_id={user_parcelpoint_id}/>}></Route>
            <Route exact path="/finish_route" element={<FinishRoute user_courier_id={user_courier_id}/>}></Route>
            <Route exact path="/login" element={<Login setUser={setUser} setToken={setToken} token={token}/>}></Route>
            <Route exact path="/register" element={<Register setToken={setToken} token={token}/>}></Route>
            <Route exact path="*" element={<Error404 />}></Route>
        </Routes>
      </BrowserRouter>
    </div>
  )
}

export default App