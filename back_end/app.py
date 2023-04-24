from flask import Flask, request, jsonify, make_response
from flask_cors import CORS
import os
import psycopg2
from flask_jwt_extended import create_access_token,get_jwt,get_jwt_identity, \
                               unset_jwt_cookies, jwt_required, JWTManager
from datetime import timedelta
import datetime
import json
import sys

app = Flask(__name__)
CORS(app)

app.config["DEBUG"] = True

app.config["JWT_SECRET_KEY"] = "haslo123haslo"
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(hours=1)
jwt = JWTManager(app)

pg_conn = psycopg2.connect(host="localhost", dbname="postgres", port="5432", user="postgres", password="123456789")
pg_cur = pg_conn.cursor()

if __name__ == '__main__':
    app.run(host=os.getenv("app_host"), port="5000")#, ssl_context='adhoc')

@app.route('/login', methods=["POST"])
def create_token():
    #print("test",file=sys.stdout)
    email = request.json['email']
    password = request.json['password']
    #print(email,password,file=sys.stdout)
    sql = "select * from users where email = %s and password_hash = %s"
    pg_cur.execute(sql, (email,password,))
    pg_conn.commit()
    if not pg_cur.fetchall():
        return {"msg": "Wrong email or password"}, 401
    access_token = create_access_token(identity=email)
    #print(access_token,file=sys.stdout)
    response = jsonify({"access_token":access_token})
    print(access_token,file=sys.stdout)
    return response

"""
@app.after_request
def refresh_expiring_jwts(response):
    try:
        exp_timestamp = get_jwt()["exp"]
        now = datetime.now(datetime.timezone.utc)
        target_timestamp = datetime.timestamp(now + timedelta(minutes=30))
        if target_timestamp > exp_timestamp:
            access_token = create_access_token(identity=get_jwt_identity())
            data = response.get_json()
            if type(data) is dict:
                data["access_token"] = access_token 
                response.data = json.dumps(data)
        return response
    except (RuntimeError, KeyError):
        return response
"""   
@app.route("/logout", methods=["POST"])
def logout():
    response = jsonify({"msg": "logout successful"})
    unset_jwt_cookies(response)
    return response

@app.route('/tracking', methods=['POST'], strict_slashes=False)
def get_package_history():
    sql = "select * from packagetrackinghistory(%s)"
    try:
        pg_cur.execute(sql, (request.json['package_id'],))
        pg_conn.commit()
    except BaseException:
        pg_conn.rollback()
        return jsonify("error")
    data = pg_cur.fetchall()
    return jsonify(data)

@app.route('/new_package', methods=['POST'], strict_slashes=False)
@jwt_required()
def new_package():
    sql = "select registerpackage(%s, %s, '%s', '%s', '%s', '%s', %s, %s, '%s', '%s');"
    try:
        pg_cur.execute(sql, (request.json['weight'], request.json['dimensions_id'], request.json['recipient_name'], request.json['recipient_phone_number'], request.json['sender_name'],
                            request.json['sender_phone_number'], request.json['destination_packagepoint_id'], request.json['source_packagepoint_id'], request.json['recipient_email'],
                            request.json['sender_email'],))
        pg_conn.commit()
    except BaseException:
        pg_conn.rollback()
        return jsonify("error")
    data = pg_cur.fetchall()
    return jsonify(data)
