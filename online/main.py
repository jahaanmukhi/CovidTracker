from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///nash.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

import json
import threading
import updates

from model import User, Location, UserLocations

from passlib.hash import sha256_crypt

@app.route('/map')
def get_map():
    """
    Grabs the map data.
    """
    with open('data/timeseries.json', 'r') as json_file:
        return jsonify(json.load(json_file))

@app.route('/map/update')
def update():
    """
    Forces an update of the server's data.
    """
    updates.update()
    return ''

@app.route('/user/add')
def add_user():
    email = request.args.get('email')
    password_unhashed = request.args.get('password')
    curr_lat = request.args.get('current_lat')
    curr_long = request.args.get('curr_long')

    loc_id = db.session.query(Location).count() + 1
    uid = db.session.query(User).count() + 1
    pair_id = db.session.query(UserLocations).count() + 1

    #password_hashed = sha256_crypt.hash(password_unhashed)

    try:
        location = Location(
            loc_id = loc_id,
            lat_ = curr_lat,
            long_ = curr_long,
        )
        db.session.add(location)
        db.session.commit()
    except Exception as e:
	    db.session.rollback()

    try:
        #hash = sha256_crypt.hash("password")
        #sha256_crypt.verify("password", hash)
        user = User(
            uid = uid,
            email = email,
            password = password_unhashed,
            curr_loc=loc_id
        )
        db.session.add(user)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
    
    try: 
        userLocation = UserLocations(
            uid = uid, 
            loc_id = loc_id
        )
        db.session.add(userLocation)
        db.session.commit()
        return "User added. user id={}".format(user.uid)
    except Exception as e:
	    return(str("fuck") + str(e))

if __name__ == '__main__':
    update_thread = threading.Thread(target=updates.watch_for_updates, args=())
    update_thread.start()
    app.run()
