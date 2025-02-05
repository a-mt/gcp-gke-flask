import datetime
import os

from flask import Flask, render_template

app = Flask(__name__)

#+-------------------------------------
#| VIEWS
#+-------------------------------------

@app.route("/")
def root():
    return render_template("index.html", dt=datetime.datetime.now(tz=datetime.timezone.utc))

#+-------------------------------------
#| ENTRYPOINT
#+-------------------------------------

if __name__ == "__main__":
    # This is used when running locally only. When deploying to Google App
    # Engine, a webserver process such as Gunicorn will serve the app. This
    # can be configured by adding an `entrypoint` to app.yaml.
    # Flask's development server will automatically serve static files in
    # the "static" directory. See:
    # http://flask.pocoo.org/docs/1.0/quickstart/#static-files. Once deployed,
    # App Engine itself will serve those files as configured in app.yaml.
    HOST = os.environ.get('HOST', '127.0.0.1')
    PORT = int(os.environ.get('PORT', '8080'))

    app.run(host=HOST, port=PORT, debug=True)
