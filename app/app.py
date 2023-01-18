from flask import Flask
import os
import sys
import logging
import mysql.connector

# set up logging
logging.basicConfig(level=logging.DEBUG)  # global change for all potential loggers
log = logging.getLogger(__name__)  # a logger to console


# populate the db_settings dict from environment variables: DB_HOSTNAME, DB_NAME, DB_USERNAME, DB_PASSWORD
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
        log.error("Could not get database details from environment var '{}'".format(setting_name))
        sys.exit(1)

    # check that variable is populated
    if setting_value == "":
        log.error("Environment var '{}' was blank".format(setting_name))
        sys.exit(1)

    # env var tests passed, add value to settings dictionary
    db_settings[setting_name] = setting_value
log.debug(db_settings)

# connect to the DB and fail with an error if we couldn't reach it
try:
    db = mysql.connector.connect(
        host=db_settings['DB_HOSTNAME'],
        user=db_settings['DB_USERNAME'],
        password=db_settings['DB_PASSWORD'],
        database=db_settings['DB_NAME']
    )
except:
    log.error("Could not contact database!")
    sys.exit(1)

def get_word(db: mysql.connector.connection_cext.CMySQLConnection) -> str:
    """get the first word from the 'words' table in the database"""
    query = db.cursor()
    query.execute('SELECT word FROM words WHERE id=1;')
    results = query.fetchone()

    word = results[0]
    log.debug('word from DB: "{}"'.format(word))
    return word


# start the webserver
app = Flask(__name__)
@app.route('/')
def index():
    word = get_word(db)
    return '<h1>Hello, {}</h2>'.format(word)
