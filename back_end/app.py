from flask import Flask, request, jsonify
from flask_cors import CORS
import os
import psycopg2
import sys

app = Flask(__name__)
app.config["DEBUG"] = True
CORS(app)

pg_conn = psycopg2.connect(host="localhost", dbname="postgres", port="5432", user="postgres", password="123456789")
pg_cur = pg_conn.cursor()

if __name__ == '__main__':
    app.run(host=os.getenv("app_host"), port="5000")

@app.route('/tracking', methods=['POST'], strict_slashes=False)
def get_package_history():
    sql = "select * from packagetrackinghistory(" + request.json['package_id'] + ")"
    try:
        pg_cur.execute(sql)
        pg_conn.commit()
    except BaseException:
        pg_conn.rollback()
        return jsonify("error")
    data = pg_cur.fetchall()
    return jsonify(data)

@app.route('/new_package', methods=['POST'], strict_slashes=False)
def new_package():
    sql = "select registerpackage(" + request.json['weight'] + ", " + request.json['dimensions_id'] + ", '" + request.json['recipient_name'] + "', '" + \
        request.json['recipient_phone_number'] + "', '"+ request.json['sender_name'] + "', '" + request.json['sender_phone_number'] +"', " + \
        request.json['destination_packagepoint_id'] + ", "+ request.json['source_packagepoint_id'] + ", '" + request.json['recipient_email'] + "', '" + request.json['sender_email'] + "');"
    try:
        pg_cur.execute(sql)
        pg_conn.commit()
    except BaseException:
        pg_conn.rollback()
        return jsonify("error")
    data = pg_cur.fetchall()
    return jsonify(data)


#@app.route('/insert_example', methods=['POST'])
def insert_example(data):
    sql = """insert into users.perceptions
            select img_1, img_2, perception, choice, user_id, time
            from json_to_recordset(%s) x (img_1 varchar(60),
                                          img_2 varchar(60), 
                                          perception varchar(60),
                                          choice varchar(60), 
                                          user_id varchar(100),
                                          time varchar(100)
            )
        """
    pg_cur.execute(sql, (json.dumps([data]),))
    pg_conn.commit()