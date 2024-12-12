import pyodbc

def get_db_connection():
    try:
        conn = pyodbc.connect(
            'DRIVER={ODBC Driver 17 for SQL Server};'
            'SERVER=DIST-6-505.uopnet.plymouth.ac.uk;'
            'DATABASE=COMP2001_SAIsubaie;'
            'UID=SAsubaie;'
            'PWD=Unwl393*;'
        )
        return conn
    except pyodbc.Error as e:
        print("Error connecting to database:", e)
        return None
