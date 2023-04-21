import React, {useState, useEffect, Component} from "react";
import {Tracking} from "./components/Tracking"
import Home from "./components/Home"
import {Navbar} from "./components/Navbar"
import {Routes, BrowserRouter, Route} from "react-router-dom";
import './App.css'
import 'bulma/css/bulma.min.css';

function App() {
  return (
    <div>
      <BrowserRouter>
        <Navbar/>
        <Routes>
            <Route exact path="/" element={<Home />}></Route>
            <Route exact path="/tracking" element={<Tracking />}></Route>
        </Routes>
      </BrowserRouter>
    </div>
  )
}

export default App