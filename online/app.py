from flask import Flask
import json
import threading
import update

app = Flask(__name__)


@app.route('/map')
def get_map():
    """
    Grabs the map data.
    """
    with open('data/timeseries.json', 'r') as json_file:
        return json.load(json_file)

@app.route('/map/update')
def update():
    """
    Forces an update of the server's data.
    """
    update.update()

if __name__ == '__main__':
    update_thread = threading.Thread(target=update.watch_for_updates, args=())
    update_thread.start()
    app.run()
