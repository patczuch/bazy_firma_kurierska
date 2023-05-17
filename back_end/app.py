from flask import Flask, request, jsonify, session
from flask_cors import CORS
import os
import psycopg2
from flask_jwt_extended import create_access_token,get_jwt,get_jwt_identity, \
                               unset_jwt_cookies, jwt_required, JWTManager
from datetime import timedelta
from functools import wraps
from flask_bcrypt import Bcrypt
import datetime
import json
import sys

app = Flask(__name__)
CORS(app)
bcrypt = Bcrypt(app)

app.config["DEBUG"] = True

app.config["JWT_SECRET_KEY"] = "haslo123haslo"
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(days=1)
app.config["JWT_REFRESH_TOKEN_EXPIRES"] = timedelta(days=30)
jwt = JWTManager(app)

pg_conn = psycopg2.connect(host="localhost", dbname="postgres", port="5432", user="postgres", password="123456789")
pg_cur = pg_conn.cursor()

if __name__ == '__main__':
    app.run(host=os.getenv("app_host"), port="5000")#, ssl_context='adhoc')

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    
    pg_cur.execute("SELECT id,email,password_hash,courier_id,parcelpoint_id FROM users WHERE email=%s", (data['email'], ))
    user = pg_cur.fetchone()
    pg_conn.commit()
    if not user:
        return jsonify({"error": "Invalid email"}), 401

    # Check if the user exists
    if not bcrypt.check_password_hash(user[2], data['password']):
        return jsonify({"error": "Invalid password"}), 401

    # Generate an access token and return it along with the user data
    access_token = create_access_token(identity=user[0])
    user_data = {
        "id": user[0],
        "email": user[1],
        "courier_id": user[3],
        "parcelpoint_id": user[4]
    }
    return jsonify({"access_token": access_token, "user": user_data}), 200

@app.route('/register', methods=['POST'])
def register():
    data = request.json

    # Check if the user already exists
    pg_cur.execute("SELECT * FROM users WHERE email=%s", (data['email'],))
    existing_user = pg_cur.fetchone()
    pg_conn.commit()
    if existing_user:
        return jsonify({"error": "User already exists"}), 400

    password_hash = bcrypt.generate_password_hash(data['password']).decode('utf-8')
    # Insert the new user into the database
    pg_cur.execute("INSERT INTO users (email, password_hash) VALUES (%s, %s)", (data['email'], password_hash))
    pg_conn.commit()

    return jsonify({"success": "User registered successfully"}), 201

@app.route('/tracking', methods=['POST'], strict_slashes=False)
def get_package_history():
    sql = "select * from packagetrackinghistory(%s)"
    try:
        pg_cur.execute(sql, (request.json['package_id'],))
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)})
    data = pg_cur.fetchall()
    return jsonify(data)

@app.route('/new_package', methods=['POST'], strict_slashes=False)
@jwt_required()
def new_package():
    user_id = get_jwt_identity()
    print(authenticate(user_id))
    if not authenticate(user_id) or not authenticate(user_id)["parcelpoint_id"] or authenticate(user_id)["parcelpoint_id"] != int(request.json['source_packagepoint_id']):
        return jsonify({'error': 'Authentication error!'})
    sql = "select registerpackage(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);"
    try:
        pg_cur.execute(sql, (request.json['weight'], request.json['dimensions_id'], request.json['recipient_name'], request.json['recipient_phone_number'], request.json['sender_name'],
                            request.json['sender_phone_number'], request.json['destination_packagepoint_id'], request.json['source_packagepoint_id'], request.json['recipient_email'],
                            request.json['sender_email'],))
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)})
    data = pg_cur.fetchall()
    return jsonify(data)

def authenticate(id):
    sql = "select id, courier_id, parcelpoint_id, email, admin from users where id = %s"
    try:
        pg_cur.execute(sql, (id,))
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return None
    user = pg_cur.fetchone()
    res = {
        "id": user[0],
        "courier_id": user[1],
        "parcelpoint_id": user[2],
        "email": user[3],
        "admin": user[4]
    }
    return res