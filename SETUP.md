# Setup Guide - Hospital Management System

Detailed setup instructions for getting HMS running on your local machine.

## System Requirements

- **OS**: Windows 10 or later (SQL Server requirement)
- **Python**: 3.8 or higher
- **SQL Server**: 2016+ or SQL Server Express (free)
- **RAM**: Minimum 2GB (recommended 4GB+)
- **Disk Space**: 500MB minimum

## Step-by-Step Setup

### Step 1: Install Python

1. Download Python from [python.org](https://www.python.org/downloads/)
2. Run the installer and **check "Add Python to PATH"**
3. Verify installation:
   ```bash
   python --version
   ```

### Step 2: Install SQL Server

#### Option A: SQL Server Express (Free)
1. Download from [Microsoft SQL Server Express](https://www.microsoft.com/en-us/sql-server/sql-server-express)
2. Run installer with default settings
3. Choose **Mixed Mode** authentication (SQL Server & Windows)
4. Take note of the instance name (e.g., `DESKTOP-XXXXXX\SQLEXPRESS`)

#### Option B: SQL Server Developer (Free)
- More features than Express
- Download from [SQL Server Developer](https://www.microsoft.com/en-us/sql-server/sql-server-2022/editions-compare)

#### Option C: Existing SQL Server
- If already installed, note your server instance name

### Step 3: Install SQL Server Management Studio (SSMS)

1. Download [SQL Server Management Studio](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
2. Install and launch SSMS
3. Connect to your SQL Server instance

### Step 4: Install ODBC Driver 17

1. Download [ODBC Driver 17 for SQL Server](https://learn.microsoft.com/en-us/sql/connect/odbc/download-odbc-driver-for-sql-server)
2. Run installer with default settings
3. Restart your computer

**Verify Installation:**
```bash
odbcconf /a {REGSVR "C:\Program Files\Microsoft ODBC Driver 17 for SQL Server\msodbcsql17.dll"}
```

### Step 5: Clone the Repository

```bash
git clone https://github.com/yourusername/hospital-management-system.git
cd hospital-management-system
```

### Step 6: Create Virtual Environment (Recommended)

```bash
# Create virtual environment
python -m venv venv

# Activate it
# On Windows:
venv\Scripts\activate

# On macOS/Linux:
source venv/bin/activate
```

### Step 7: Install Python Dependencies

```bash
pip install -r requirements.txt
```

### Step 8: Create Database

**Option A: Using SSMS (GUI)**
1. Open SQL Server Management Studio
2. Connect to your SQL Server
3. Open File → Open → `HospitalDB_SQLServer.sql`
4. Click Execute (or press F5)
5. Wait for completion

**Option B: Using Command Line**
```bash
sqlcmd -S YOUR_SERVER_NAME\SQLEXPRESS -i HospitalDB_SQLServer.sql
```

Replace `YOUR_SERVER_NAME` with your computer name or server instance name.

**Option C: Using Python**
```bash
python
>>> import pyodbc
>>> conn = pyodbc.connect(r'Driver={ODBC Driver 17 for SQL Server};Server=YOUR_SERVER_NAME\SQLEXPRESS;Trusted_Connection=yes;')
>>> with open('HospitalDB_SQLServer.sql', 'r') as f:
>>>     conn.executescript(f.read())
>>> conn.commit()
```

### Step 9: Update app.py with Your Server

Edit `app.py` line ~12:

```python
server = r'YOUR_COMPUTER_NAME\SQLEXPRESS'  # Replace with your actual server
```

**To find your server name:**
- Windows: Open Command Prompt and run `hostname`
- SSMS: Check the server name in Object Explorer

### Step 10: Run the Application

```bash
streamlit run app.py
```

The app will open at `http://localhost:8501`

## Troubleshooting

### Issue: "Connection refused" or Database not found

**Solution:**
1. Verify SQL Server is running:
   - Windows: Services → SQL Server (SQLEXPRESS)
2. Check server name in `app.py`
3. Ensure database was created successfully

### Issue: ODBC Driver not found

**Solution:**
```bash
# Check installed drivers
odbcconf /a {REGSVR "C:\Program Files\Microsoft ODBC Driver 17 for SQL Server\msodbcsql17.dll"}

# Restart Streamlit
```

### Issue: Authentication Failed

**Solution:**
1. Ensure Mixed Mode is enabled in SQL Server
2. Use Windows Authentication (Trusted_Connection=yes)
3. Check your Windows account has access

### Issue: Streamlit not responding

**Solution:**
```bash
# Clear cache and restart
streamlit cache clear
streamlit run app.py
```

### Issue: ModuleNotFoundError

**Solution:**
```bash
# Ensure virtual environment is activated
# Then reinstall dependencies
pip install --upgrade -r requirements.txt
```

## Verification Checklist

- [ ] Python 3.8+ installed
- [ ] SQL Server installed and running
- [ ] SSMS installed
- [ ] ODBC Driver 17 installed
- [ ] Virtual environment created and activated
- [ ] Dependencies installed (pip install -r requirements.txt)
- [ ] Database created (HospitalDB)
- [ ] app.py updated with correct server name
- [ ] Streamlit runs without errors

## Next Steps

Once setup is complete:
1. Explore the Analytics Dashboard
2. Add sample patients and doctors
3. Create medical tests
4. Review generated records
5. Check audit logs

## Support

- **SQL Server Connection Issues**: Check [Microsoft SQL Server Connection Troubleshooting](https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/troubleshoot-connecting-to-the-sql-server-database-engine)
- **Streamlit Issues**: Visit [Streamlit Docs](https://docs.streamlit.io/)
- **pyodbc Issues**: Check [pyodbc GitHub](https://github.com/mkleehammer/pyodbc)

## Additional Resources

- [SQL Server Installation Guide](https://learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server)
- [Streamlit Getting Started](https://docs.streamlit.io/library/get-started)
- [Python Virtual Environments](https://docs.python.org/3/tutorial/venv.html)

---

**Still having issues?** Open an issue on GitHub or contact the maintainers.
