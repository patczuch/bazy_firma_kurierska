
export default class APIService{ 
    static host = "localhost";
    static port = "5000";

    static get_package_history(body){
        return fetch('http://' + this.host + ':' + this.port + '/tracking',{
            'method':'POST',
            headers : {'Content-Type':'application/json'},
            body:JSON.stringify(body)
    })
    .then(response => response.json())
    .catch(error => console.log(error))
    }

    static register_package(body, token){
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

    static login(email, password, props, navigate){
        return fetch('http://' + this.host + ':' + this.port + '/login',{
            'method':'POST',
            headers : {'Content-Type':'application/json'},
            body:JSON.stringify({email, password})
          })
          .then(response => response.json())
          .then(data => {
            const { access_token, user } = data;
            if (access_token != undefined)
            {
                props.setToken(access_token)
                props.setUser_id(user.id)
                props.setEmail(user.email)
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
            if (data['error'] == undefined)
            {
                alert("Pomyślnie zarejestrowano!")
                navigate('/login', { replace: true })
            }
            else
                alert("Wystąpił błąd! Nie zarejestrowano")
          })
          .catch(error => console.log(error))
        }
        

    static logout(props){
        /* return fetch('http://' + this.host + ':' + this.port + '/logout',{
            'method':'POST'
        })
            .then(response => {
            props.removeToken()
        })
            .catch(error => console.log(error))
        }    */
        props.removeToken()
        props.removeUser_id()
        props.removeEmail()
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