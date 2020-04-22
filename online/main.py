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

def get_json():
  with open(str(updates.get_temp_path()), 'r') as json_file:
    return jsonify(json.load(json_file))

@app.route('/map')
def get_map():
    """
    Grabs the map data.
    """
    updates.check_time()
    try:
      return get_json()
    except FileNotFoundError:
      updates.update()
      return get_json()

@app.route('/map/update')
def update():
    """
    Forces an update of the server's data.
    """
    updates.update()
    return ''

if __name__ == '__main__':
    update_thread = threading.Thread(target=updates.watch_for_updates, args=())
    update_thread.start()
    app.run()
