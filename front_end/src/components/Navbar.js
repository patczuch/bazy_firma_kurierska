import React, { useState } from "react";
import { NavLink } from "react-router-dom";
import APIService from "./APIService"; 

export const Navbar = (props) => {
  const [isOpen, setOpen] = useState(false);

  const logout=(event)=>{ 
    event.preventDefault()
    APIService.logout(props)
  }

  return (
    <nav
      className="navbar is-primary"
      role="navigation"
      aria-label="main navigation"
    >
      <div className="container">
        <div className="navbar-brand">
          <a
            role="button"
            className={`navbar-burger burger ${isOpen && "is-active"}`}
            aria-label="menu"
            aria-expanded="false"
            onClick={() => setOpen(!isOpen)}
          >
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
          </a>
        </div>

        <div className={`navbar-menu ${isOpen && "is-active"}`}>
          <div className="navbar-start">
            <NavLink className="navbar-item" to="/">
              Strona główna
            </NavLink>

            <NavLink
              className="navbar-item"
              to="/tracking"
            >
              Śledzenie przesyłki
            </NavLink>

            <NavLink
              className="navbar-item"
              to="/new_package"
            >
              Nowa przesyłka
            </NavLink>

            <NavLink
              className="navbar-item"
              to="/register_pickup"
            >
              Zarejestruj odbiór
            </NavLink>

            <NavLink
              className="navbar-item"
              to="/new_route"
            >
              Nowa trasa
            </NavLink>

            <NavLink
              className="navbar-item"
              to="/finish_route"
            >
              Zakończ trasę
            </NavLink>
          </div>

          {!props.token && props.token!=="" &&props.token!== undefined ? 
          <div className="navbar-end">
            <div className="navbar-item">
            <div className="buttons">
                  <NavLink
                    className="button is-white"
                    to="/register"
                  >
                  Rejestracja
                  </NavLink>
              </div>
            </div>
            <div className="navbar-item">
              <div className="buttons">
                  <NavLink
                    className="button is-white"
                    to="/login"
                  >
                  Logowanie
                  </NavLink>
              </div>
            </div>
          </div> : 
          <div className="navbar-end">
            <div className="navbar-item">
              {props.email}
              </div>
          <div className="navbar-item">
            <div className="buttons">
              <a className="button is-white" onClick={logout}>
                  Wyloguj
              </a>
            </div>
          </div>
          </div>
          }
        </div>
      </div>
    </nav>
  );
};