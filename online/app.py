from flask import Flask
import json

app = Flask(__name__)


@app.route('/map')
def get_map():
    with open('data/timeseries.json', 'r') as json_file:
        return json.load(json_file)


if __name__ == '__main__':
    app.run()
