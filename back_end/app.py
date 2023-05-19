from flask import Flask, request, jsonify, session
from flask_cors import CORS
import os
import psycopg2
from flask_jwt_extended import create_access_token,get_jwt,get_jwt_identity, \
                               unset_jwt_cookies, jwt_required, JWTManager
from datetime import timedelta
from functools import wraps
from flask_bcrypt import Bcrypt
from psycopg2 import pool

app = Flask(__name__)
CORS(app)
bcrypt = Bcrypt(app)

app.config["DEBUG"] = True

app.config["JWT_SECRET_KEY"] = "haslo123haslo"
app.config["JWT_ACCESS_TOKEN_EXPIRES"] = timedelta(days=1)
app.config["JWT_REFRESH_TOKEN_EXPIRES"] = timedelta(days=30)
jwt = JWTManager(app)

#pg_conn = psycopg2.connect(host="localhost", dbname="postgres", port="5432", user="postgres", password="123456789")
#pg_cur = pg_conn.cursor()

db_pool = psycopg2.pool.SimpleConnectionPool(
    minconn=1,
    maxconn=20,
    host='localhost',
    port='5432',
    dbname='postgres',
    user='postgres',
    password='123456789'
)

if __name__ == '__main__':
    app.run(host=os.getenv("app_host"), port="5000")#, ssl_context='adhoc')

@app.route('/login', methods=['POST'])
def login():
    data = request.json
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute("SELECT id,email,password_hash,courier_id,parcelpoint_id FROM users WHERE email=%s", (data['email'], ))
        user = pg_cur.fetchone()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)

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
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute("SELECT * FROM users WHERE email=%s", (data['email'],))
        existing_user = pg_cur.fetchone()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
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
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute(sql, (request.json['package_id'],))
        data = pg_cur.fetchall()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
    return jsonify(data), 200

@app.route('/pickup_package', methods=['POST'], strict_slashes=False)
@jwt_required()
def pickup_package():
    sql = "select parcelpointid from packagelocation(%s)"
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute(sql, (request.json['package_id'],))
        data = pg_cur.fetchone()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
    
    user_id = get_jwt_identity()
    if not authenticate(user_id) or not authenticate(user_id)["parcelpoint_id"] or authenticate(user_id)["parcelpoint_id"] != int(data[0]) or data[0] == -1:
        return jsonify({'error': 'Authentication error!'}), 401
    
    sql2 = "select pickuppackage(%s)"
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute(sql2, (request.json['package_id'],))
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
    return jsonify({'success':'Succesfuly registered pickup'}), 200

@app.route('/parcelpoint_packages', methods=['POST'], strict_slashes=False)
@jwt_required()
def get_parcelpoint_packages():
    #print("test", file=sys.stdout)
    user_id = get_jwt_identity()
    if not authenticate(user_id) or not authenticate(user_id)["parcelpoint_id"]:
        return jsonify({'error': 'Authentication error!'}), 401
    sql = "select getcontentsofparcelpoint(%s)"
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute(sql, (authenticate(user_id)["parcelpoint_id"],))
        data = pg_cur.fetchall()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
    res = []
    for id in data:
        package_info = get_package_info(id[0])
        if package_info is not None:
            res.append(package_info)
    return jsonify(res), 200

@app.route('/routes', methods=['POST'], strict_slashes=False)
@jwt_required()
def get_routes():
    user_id = get_jwt_identity()
    if not authenticate(user_id) or not authenticate(user_id)["courier_id"]:
        return jsonify({'error': 'Authentication error!'}), 401
    sql = "select routes.id, time, registration_plate, source_parcelpoint_id, destination_parcelpoint_id from routes inner join vehicles on vehicles.id = vehicle_id where courier_id = %s and completed = false"
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute(sql, (authenticate(user_id)["courier_id"],))
        data = pg_cur.fetchall()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
    res = []
    for route in data:
        res.append({
            "id": route[0],
            "time": route[1],
            "vehicle_reg_plate": route[2],
            "source_parcelpoint_id": route[3],
            "destination_parcelpoint_id": route[4]
        })
    return jsonify(res), 200

@app.route('/vehicles', methods=['GET'], strict_slashes=False)
@jwt_required()
def get_vehicles():
    sql = "select id, registration_plate, max_weight from vehicles"

    user_id = get_jwt_identity()
    if not authenticate(user_id) or (not authenticate(user_id)["courier_id"] and not authenticate(user_id)["parcelpoint_id"] and not not authenticate(user_id)["admin"]):
        return jsonify({'error': 'Authentication error!'}), 401
    
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute(sql)
        data = pg_cur.fetchall()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
    res = []
    for veh in data:
        res.append({
            "id": veh[0],
            "registration_plate": veh[1],
            "max_weight": veh[2]
        })
    return res, 200

@app.route('/finish_route', methods=['POST'], strict_slashes=False)
@jwt_required()
def finish_route():
    sql = "select completeroute(%s)"
    sql2 = "select courier_id from routes where id = %s"

    user_id = get_jwt_identity()
    if not authenticate(user_id) or not authenticate(user_id)["courier_id"]:
        return jsonify({'error': 'Authentication error!'}), 401
    
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()

        pg_cur.execute(sql2, (request.json['route_id'],))
        data = pg_cur.fetchone()
        if data[0] != authenticate(user_id)["courier_id"]:
            return jsonify({'error': 'Authentication error!'}), 401

        pg_cur.execute(sql, (request.json['route_id'],))

        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
    return jsonify({'success':'Route succesfully finished'}), 200

@app.route('/package_dimensions', methods=['GET'], strict_slashes=False)
def get_package_dimensions():
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute("select id, name, dimension_x, dimension_y, dimension_z from packagedimensions")
        data = pg_cur.fetchall()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
    res = []
    for dim in data:
        res.append({
            "id": dim[0],
            "name": dim[1],
            "dimension_x": dim[2],
            "dimension_y": dim[3],
            "dimension_z": dim[4]
        })
    return res, 200

@app.route('/parcelpoints', methods=['GET'], strict_slashes=False)
def get_parcelpoints():
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute("select id, name, city, street, house_number, apartment_number from parcelpoints")
        data = pg_cur.fetchall()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
    res = []
    for parcelpoint in data:
        #print(parcelpoint)
        res.append({
            "id": parcelpoint[0],
            "name": parcelpoint[1],
            "city": parcelpoint[2],
            "street": parcelpoint[3],
            "house_number": parcelpoint[4],
            "apartment_number": parcelpoint[5]
        })
    return res, 200

def get_package_info(id):
    sql = "select weight, dimensions_id, sender_info_id, recipient_info_id, destination_packagepoint_id from packages where id = %s"
    sql2 = "select name, phone_number, email from personinfo where id = %s"

    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute(sql, (id,))
        package_info = pg_cur.fetchone()

        pg_cur.execute(sql2, (package_info[2],))
        sender_info = pg_cur.fetchone()

        pg_cur.execute(sql2, (package_info[3],))
        recipient_info = pg_cur.fetchone()

        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return None
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
        
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
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute(sql, (request.json['weight'], request.json['dimensions_id'], request.json['recipient_name'], request.json['recipient_phone_number'], request.json['sender_name'],
                            request.json['sender_phone_number'], request.json['destination_packagepoint_id'], request.json['source_packagepoint_id'], request.json['recipient_email'],
                            request.json['sender_email'],))
        id = pg_cur.fetchone()[0]
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return jsonify({'error': str(e)}), 400
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
    return jsonify({'success':'Succesfuly registered new package, ID: ' + str(id)}), 200

def authenticate(id):
    sql = "select id, courier_id, parcelpoint_id, email, admin from users where id = %s"
    pg_conn = db_pool.getconn()
    try:
        pg_cur = pg_conn.cursor()
        pg_cur.execute(sql, (id,))
        user = pg_cur.fetchone()
        pg_conn.commit()
    except Exception as e:
        pg_conn.rollback()
        return None
    finally:
        pg_cur.close()
        db_pool.putconn(pg_conn)
    res = {
        "id": user[0],
        "courier_id": user[1],
        "parcelpoint_id": user[2],
        "email": user[3],
        "admin": user[4]
    }
    return res