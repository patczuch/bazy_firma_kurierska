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
    
    try:
        pg_cur.execute("SELECT id,email,password_hash,courier_id,parcelpoint_id FROM users WHERE email=%s", (data['email'], ))
        user = pg_cur.fetchone()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    if not user:
        return jsonify({"error": "Invalid email"}), 401

    if not bcrypt.check_password_hash(user[2], data['password']):
        return jsonify({"error": "Invalid password"}), 401

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

    try:
        pg_cur.execute("SELECT * FROM users WHERE email=%s", (data['email'],))
        existing_user = pg_cur.fetchone()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    
    if existing_user:
        return jsonify({"error": "User already exists"}), 400

    password_hash = bcrypt.generate_password_hash(data['password']).decode('utf-8')
    try:
        pg_cur.execute("INSERT INTO users (email, password_hash) VALUES (%s, %s)", (data['email'], password_hash))
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400

    return jsonify({"success": "User registered successfully"}), 201

@app.route('/tracking', methods=['POST'], strict_slashes=False)
def get_package_history():
    #print("test", file=sys.stdout)
    sql = "select * from packagetrackinghistory(%s)"
    try:
        pg_cur.execute(sql, (request.json['package_id'],))
        pg_conn.commit()
        data = pg_cur.fetchall()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    return jsonify(data), 200

@app.route('/pickup_package', methods=['POST'], strict_slashes=False)
@jwt_required()
def pickup_package():
    sql = "select parcelpointid from packagelocation(%s)"
    print(request.json['package_id'])
    try:
        pg_cur.execute(sql, (request.json['package_id'],))
        pg_conn.commit()
        data = pg_cur.fetchone()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    
    
    user_id = get_jwt_identity()
    if not authenticate(user_id) or not authenticate(user_id)["parcelpoint_id"] or authenticate(user_id)["parcelpoint_id"] != int(data[0]) or data[0] == -1:
        return jsonify({'error': 'Authentication error!'}), 401
    
    sql2 = "select pickuppackage(%s)"
    try:
        pg_cur.execute(sql2, (request.json['package_id'],))
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    
    return jsonify({'success':'Succesfuly registered pickup'}), 200

@app.route('/parcelpoint_packages', methods=['POST'], strict_slashes=False)
@jwt_required()
def get_parcelpoint_packages():
    #print("test", file=sys.stdout)
    user_id = get_jwt_identity()
    if not authenticate(user_id) or not authenticate(user_id)["parcelpoint_id"] or authenticate(user_id)["parcelpoint_id"] != int(request.json['parcelpoint_id']):
        return jsonify({'error': 'Authentication error!'}), 401
    sql = "select getcontentsofparcelpoint(%s)"
    try:
        pg_cur.execute(sql, (request.json['parcelpoint_id'],))
        pg_conn.commit()
        data = pg_cur.fetchall()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    res = []
    for id in data:
        package_info = get_package_info(id)
        if package_info is not None:
            res.append(package_info)
    return jsonify(res), 200

@app.route('/package_dimensions', methods=['GET'], strict_slashes=False)
def get_package_dimensions():
    try:
        pg_cur.execute("select id, name, dimension_x, dimension_y, dimension_z from packagedimensions")
        pg_conn.commit()
        res = pg_cur.fetchall()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    return res, 200

@app.route('/parcelpoints', methods=['GET'], strict_slashes=False)
def get_parcelpoints():
    try:
        pg_cur.execute("select id, name, city, street, house_number, apartment_number from parcelpoints")
        pg_conn.commit()
        res = pg_cur.fetchall()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    return res, 200

def get_package_info(id):
    sql = "select weight, dimensions_id, sender_info_id, recipient_info_id, destination_packagepoint_id from packages where id = %s"
    try:
        pg_cur.execute(sql, (id,))
        pg_conn.commit()
        package_info = pg_cur.fetchone()
    except Exception as e:
        pg_conn.rollback()
        return None
    
    sql2 = "select name, phone_number, email from personinfo where id = %s"
    try:
        pg_cur.execute(sql2, (package_info[2],))
        pg_conn.commit()
        sender_info = pg_cur.fetchone()
    except Exception as e:
        pg_conn.rollback()
        return None

    try:
        pg_cur.execute(sql2, (package_info[3],))
        pg_conn.commit()
        recipient_info = pg_cur.fetchone()
    except Exception as e:
        pg_conn.rollback()
        return None
    
    return {
        "id": id,
        "weight": package_info[0],
        "dimensions_id": package_info[1],
        "sender_name": sender_info[0],
        "sender_phone_number": sender_info[1],
        "sender_email": sender_info[2],
        "recipient_name": recipient_info[0],
        "recipient_phone_number": recipient_info[1],
        "recipient_email": recipient_info[2],
        "destination_packagepoint_id": package_info[4]
    }

@app.route('/new_package', methods=['POST'], strict_slashes=False)
@jwt_required()
def new_package():
    user_id = get_jwt_identity()
    #print(authenticate(user_id))
    if not authenticate(user_id) or not authenticate(user_id)["parcelpoint_id"] or authenticate(user_id)["parcelpoint_id"] != int(request.json['source_packagepoint_id']):
        return jsonify({'error': 'Authentication error!'}), 401
    sql = "select registerpackage(%s, %s, %s, %s, %s, %s, %s, %s, %s, %s);"
    try:
        pg_cur.execute(sql, (request.json['weight'], request.json['dimensions_id'], request.json['recipient_name'], request.json['recipient_phone_number'], request.json['sender_name'],
                            request.json['sender_phone_number'], request.json['destination_packagepoint_id'], request.json['source_packagepoint_id'], request.json['recipient_email'],
                            request.json['sender_email'],))
        pg_conn.commit()
        data = pg_cur.fetchall()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    return jsonify(data), 200

def authenticate(id):
    sql = "select id, courier_id, parcelpoint_id, email, admin from users where id = %s"
    try:
        pg_cur.execute(sql, (id,))
        pg_conn.commit()
        user = pg_cur.fetchone()
    except Exception as e:
        pg_conn.rollback()
        return None
    res = {
        "id": user[0],
        "courier_id": user[1],
        "parcelpoint_id": user[2],
        "email": user[3],
        "admin": user[4]
    }
    return res