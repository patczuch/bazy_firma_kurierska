import React, {useState, useEffect, Component} from "react";

export function Tracking() {
    const [parcelpoints, setParcelpoints] = useState('inital text');

    const host = "localhost";
    const port = "5000";

    const getParcelpoints = () => {
        const requestOptions = {
        method: 'GET',
        header: { 'Content-Type': 'application/json'}
        };
        var res = ""
        fetch('http://' + host + ':' + port + '/get_parcelpoints', requestOptions)
        .then(response => response.json())
        .then(result => {
            for (var i = 0; i < result.length; i++)
            res += result[i][0] + " " + result[i][1] + " " + result[i][2] + " " + result[i][3] + " " + result[i][4] + "\n"
            setParcelpoints(res)
        });
    };

    useEffect(() => {
        getParcelpoints();
    }, []);

    return <h1>Tracking test</h1>;
}