import React, {useState, useEffect, Component} from "react";
import APIService from '../components/APIService'
import { Navigate } from 'react-router-dom';

export function RegisterPickup(props) {
    if (!props.user_parcelpoint_id) {
        return <Navigate to="/" replace />;
      }

    return <div>
        rejestracja odbioru
        </div>;
}