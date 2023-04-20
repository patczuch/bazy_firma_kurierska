from flask import Flask
from flask_cors import CORS
import os
import psycopg2

import flask
from flask import jsonify

app = flask.Flask(__name__)
app.config["DEBUG"] = True
CORS(app)

pg_conn = psycopg2.connect(host="localhost", dbname="postgres", port="5432", user="postgres", password="123456789")
pg_cur = pg_conn.cursor()

if __name__ == '__main__':
    app.run(host=os.getenv("app_host"), port="5000")

@app.route('/get_parcelpoints', methods=['GET'])
def get_parcelpoints():
    sql = "select * from parcelpoints"
    pg_cur.execute(sql)
    data = pg_cur.fetchall()
    return jsonify(data)


@app.route('/insert_example', methods=['POST'])
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