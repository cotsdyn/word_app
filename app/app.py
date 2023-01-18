from flask import Flask
import os
import sys
import logging

# set up logging
log = logging.getLogger(__name__)

# populate the db_settings dict with connection details from environment variables: DB_HOSTNAME, DB_NAME, DB_USERNAME, DB_PASSWORD

db_settings = {
    'DB_HOSTNAME':  None,
    'DB_NAME':      None,
    'DB_USERNAME':  None,
    'DB_PASSWORD':  None
}

# get each env var, and test if:
#   - the env var was unset
#   - the env var was blank
for setting_name in db_settings:
    try:
        setting_value = os.environ[setting_name]
    except KeyError:
        log.error("ERROR: Could not get database details from environment var '{}'".format(setting_name))
        sys.exit(1)

    # check that variable is populated
    if setting_value == "":
        log.error("ERROR: environment var '{}' was blank".format(setting_name))
        sys.exit(1)

    # env var tests passed, add value to settings dictionary
    db_settings[setting_name] = setting_value

# FIXME do a DB test before starting the webserver

app = Flask(__name__)

@app.route('/')
def index():
    return '<h1>Hello World</h2>'
