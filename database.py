import pyodbc

def get_db_connection():
    conn = pyodbc.connect(
        'DRIVER={ODBC Driver 17 for SQL Server};'
        'SERVER=dist-6-505.uopnet.plymouth.ac.uk;'
        'DATABASE=YourDatabaseName;'
        'UID=YourUsername;'
        'PWD=YourPassword;'
    )
    return conn
