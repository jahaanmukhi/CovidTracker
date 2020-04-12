from flask import Flask, jsonify
import json
import threading
import updates

app = Flask(__name__)


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

if __name__ == '__main__':
    update_thread = threading.Thread(target=updates.watch_for_updates, args=())
    update_thread.start()
    app.run()
