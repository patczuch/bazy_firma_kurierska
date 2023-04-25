import React, {useState, useEffect, Component} from "react";
import { Navigate } from 'react-router-dom';

export function FinishRoute(props) {
    if (!props.user_courier_id) {
        return <Navigate to="/" replace />;
      }

    return <div>
        zakończ trasę
        </div>;
}