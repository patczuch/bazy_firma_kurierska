import React, {useState, useEffect, Component} from "react";
import APIService from './APIService'
import { Navigate } from 'react-router-dom';

export function NewRoute(props) {
    if (!props.user_parcelpoint_id) {
        return <Navigate to="/" replace />;
      }

    return <div>
        nowa trasa
        </div>;
}