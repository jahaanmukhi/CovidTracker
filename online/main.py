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
from model import User

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
    username = request.args.get('username')
    password = request.args.get('password')
    dynamicSalt = 'a'

    try:
        user = User(
            username = username,
            passwordHash = password,
            dynamicSalt = dynamicSalt
        )
        db.session.add(user)
        db.session.commit()
        return "Book added. book id={}".format(user.id)
    except Exception as e:
	    return(str(e))


if __name__ == '__main__':
    update_thread = threading.Thread(target=updates.watch_for_updates, args=())
    update_thread.start()
    app.run()
