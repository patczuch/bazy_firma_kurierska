
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

    static register_package(body){
        return fetch('http://' + this.host + ':' + this.port + '/new_package',{
            'method':'POST',
            headers : {'Content-Type':'application/json'},
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
            if (data['access_token'] != undefined)
            {
                props.setToken(data['access_token'])
                navigate('/', { replace: true })
            }
            else
                alert("Błędne dane logowania!")
          })
          .catch(error => console.log(error))
        }

    static logout(props){
         return fetch('http://' + this.host + ':' + this.port + '/logout',{
            'method':'POST'
        })
            .then(response => {
            props.removeToken()
        })
            .catch(error => console.log(error))
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