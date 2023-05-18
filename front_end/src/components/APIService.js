
export default class APIService{ 
    static host = "localhost";
    static port = "5000";

    static finish_route(body, token) {

    }

    static get_routes(token){
        return fetch('http://' + this.host + ':' + this.port + '/routes',{
            'method':'POST',
            headers : {'Content-Type':'application/json', 
            "Authorization": `Bearer ${token}`}
    })
    .then(response => response.json())
    .catch(error => console.log(error))
    }

    static get_package_dimensions(){
        return fetch('http://' + this.host + ':' + this.port + '/package_dimensions',{
            'method':'GET',
            headers : {'Content-Type':'application/json'}
    })
    .then(response => response.json())
    .catch(error => console.log(error))
    }

    static get_parcelpoints(){
        return fetch('http://' + this.host + ':' + this.port + '/parcelpoints',{
            'method':'GET',
            headers : {'Content-Type':'application/json'}
    })
    .then(response => response.json())
    .catch(error => console.log(error))
    }

    static get_package_history(body){
        return fetch('http://' + this.host + ':' + this.port + '/tracking',{
            'method':'POST',
            headers : {'Content-Type':'application/json'},
            body:JSON.stringify(body)
    })
    .then(response => response.json())
    .catch(error => console.log(error))
    }

    static pickup_package(body, token){
        return fetch('http://' + this.host + ':' + this.port + '/pickup_package',{
            'method':'POST',
            headers : {'Content-Type':'application/json', 
            "Authorization": `Bearer ${token}`},
            body:JSON.stringify(body)
    })
    .then(response => response.json())
    .catch(error => console.log(error))
    }

    static register_package(body, token){
        //console.log(JSON.stringify(body))
        return fetch('http://' + this.host + ':' + this.port + '/new_package',{
            'method':'POST',
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body:JSON.stringify(body)
    })
    .then(response => response.json())
    .catch(error => console.log(error))
    }

    static get_parcelpoint_packages(body, token){
        return fetch('http://' + this.host + ':' + this.port + '/parcelpoint_packages',{
            'method':'POST',
            headers: {
                "Content-Type": "application/json",
                "Authorization": `Bearer ${token}`
            },
            body:JSON.stringify({"parcelpoint_id": body})
    })
    .then(response => response.json())
    .catch(error => console.log(error))
    }

    static login(email, password, props, navigate){
        return fetch('http://' + this.host + ':' + this.port + '/login',{
            'method':'POST',
            headers : {'Content-Type':'application/json'},
            body:JSON.stringify({email, password})
          })
          .then(response => response.json())
          .then(data => {
            const { access_token, user } = data;
            if (access_token !== undefined)
            {
                props.setToken(access_token)
                props.setUser(user.id,user.email,user.courier_id,user.parcelpoint_id)
                //console.log(user.id, user.email, user.courier_id, user.parcelpoint_id)
                navigate('/', { replace: true })
            }
            else
                alert("Błędne dane logowania!")
          })
          .catch(error => console.log(error))
        }

    static register(email, password, props, navigate){
        return fetch('http://' + this.host + ':' + this.port + '/register',{
            'method':'POST',
            headers : {'Content-Type':'application/json'},
            body:JSON.stringify({email, password})
          })
          .then(response => response.json())
          .then(data => {
            if (data['error'] === undefined)
            {
                alert("Pomyślnie zarejestrowano!")
                navigate('/login', { replace: true })
            }
            else
                alert("Wystąpił błąd! Nie zarejestrowano")
          })
          .catch(error => console.log(error))
        }
        

    static logout(props, navigate){
        /* return fetch('http://' + this.host + ':' + this.port + '/logout',{
            'method':'POST'
        })
            .then(response => {
            props.removeToken()
        })
            .catch(error => console.log(error))
        }    */
        props.removeToken()
        props.removeUser()
        navigate('/', { replace: true })
}
}

    /*const [parcelpoints, setParcelpoints] = useState('inital text');

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
    };*/