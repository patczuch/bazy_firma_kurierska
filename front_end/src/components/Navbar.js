import React, { useState } from "react";
import { NavLink } from "react-router-dom";

export const Navbar = () => {
  const [isOpen, setOpen] = useState(false);
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
            <NavLink className="navbar-item" activeClassName="is-active" to="/">
              Strona główna
            </NavLink>

            <NavLink
              className="navbar-item"
              activeClassName="is-active"
              to="/tracking"
            >
              Śledzenie przesyłki
            </NavLink>

            <NavLink
              className="navbar-item"
              activeClassName="is-active"
              to="/"
            >
              coś
            </NavLink>
          </div>

          <div className="navbar-end">
            <div className="navbar-item">
              <div className="buttons">
                <a className="button is-white">Logowanie</a>
              </div>
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
};