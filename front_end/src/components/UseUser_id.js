import { useState } from 'react';

function useUser_id() {

    function getUser_Id() {
      const user_id = localStorage.getItem('user_id');
      return user_id && user_id
    }
  
    const [user_id, setUser_id] = useState(getUser_Id());
  
    function saveUser_id(user_id) {
      localStorage.setItem('user_id', user_id);
      setUser_id(user_id);
    };
  
    function removeUser_id() {
      localStorage.removeItem("user_id");
      setUser_id(null);
    }
  
    return {
      setUser_id: saveUser_id,
      user_id,
      removeUser_id
    }
  
  }
  
  export default useUser_id;