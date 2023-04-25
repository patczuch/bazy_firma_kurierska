import { useState } from 'react';

function useEmail() {

    function getEmail() {
      const email = localStorage.getItem('email');
      return email && email
    }
  
    const [email, setEmail] = useState(getEmail());
  
    function saveEmail(email) {
      localStorage.setItem('email', email);
      setEmail(email);
    };
  
    function removeEmail() {
      localStorage.removeItem("email");
      setEmail(null);
    }
  
    return {
      setEmail: saveEmail,
      email,
      removeEmail
    }
  
  }
  
  export default useEmail;