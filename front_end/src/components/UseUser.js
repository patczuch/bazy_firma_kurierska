import { useState } from 'react';

function useUserData() {

    function getUserId() {
      const user_id = localStorage.getItem('user_id');
      return user_id && user_id
    }

    function saveUserId(user_id) {
      localStorage.setItem('user_id', user_id);
      setUserId(user_id);
    }

    function removeUserId() {
      localStorage.removeItem('user_id');
      setUserId(null);
    }

    function getUserEmail() {
      const user_email = localStorage.getItem('user_email');
      return user_email && user_email
    }

    function removeUserEmail() {
      localStorage.removeItem('user_email');
      setUserEmail(null);
    }

    function saveUserEmail(user_email) {
      localStorage.setItem('user_email', user_email);
      setUserEmail(user_email);
    }

    function getUserCourierId() {
      const user_courier_id = localStorage.getItem('user_courier_id');
      return user_courier_id && user_courier_id
    }

    function saveUserCourierId(courier_id) {
      localStorage.setItem('courier_id', courier_id);
      setUserCourierId(courier_id);
    }

    function removeUserCourierId() {
      localStorage.removeItem('user_courier_id');
      setUserCourierId(null);
    }

    function getUserParcelpointId() {
      const user_parcelpoint_id = localStorage.getItem('user_parcelpoint_id');
      return user_parcelpoint_id && user_parcelpoint_id
    }

    function removeUserPacelpontId () {
      localStorage.removeItem('user_parcelpoint_id');
      setUserParcelpointId(null);
    }

    function saveUserParcelPointId(user_parcelpoint_id) {
      localStorage.setItem('user_parcelpoint_id', user_parcelpoint_id);
      setUserParcelpointId(user_parcelpoint_id);
    }

    const [user_id, setUserId] = useState(getUserId());
    const [user_email, setUserEmail] = useState(getUserEmail());
    const [user_courier_id, setUserCourierId] = useState(getUserCourierId());
    const [user_parcelpoint_id, setUserParcelpointId] = useState(getUserParcelpointId());
  
    function saveUser(user_id, user_email, user_courier_id, user_parcelpoint_id) {
      localStorage.setItem('user_id', user_id);
      setUserId(user_id);
      localStorage.setItem('user_email', user_email);
      setUserEmail(user_email);
      localStorage.setItem('user_courier_id', user_courier_id);
      setUserCourierId(user_courier_id);
      localStorage.setItem('user_parcelpoint_id', user_parcelpoint_id);
      setUserParcelpointId(user_parcelpoint_id);
    };
  
    function removeUser() {
      localStorage.removeItem('user_id');
      setUserId(null);
      localStorage.removeItem('user_email');
      setUserEmail(null);
      localStorage.removeItem('user_courier_id');
      setUserCourierId(null);
      localStorage.removeItem('user_parcelpoint_id');
      setUserParcelpointId(null);
    }
  
    return {
      setUserId: saveUserId,
      user_id,
      removeUserId,
      setUserEmail: saveUserEmail,
      user_email,
      removeUserEmail,
      setUserCourierId: saveUserCourierId,
      user_courier_id,
      removeUserCourierId,
      setUserParcelpointId: saveUserParcelPointId,
      user_parcelpoint_id,
      removeUserPacelpontId,
      setUser: saveUser,
      removeUser
    }
  
  }
  
  export default useUserData;