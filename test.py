import pyodbc

server = r'DESKTOP-A8Q3LJ3\SQLEXPRESS'
database = 'HospitalDB'

try:
    conn = pyodbc.connect(
        f'DRIVER={{ODBC Driver 17 for SQL Server}};'
        f'SERVER={server};'
        f'DATABASE={database};'
        f'Trusted_Connection=yes;'
    )
    print("✅ Connected successfully!")
    conn.close()
except Exception as e:
    print(f"❌ Error: {e}")