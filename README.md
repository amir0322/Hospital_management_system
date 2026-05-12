# Hospital Management System (HMS)

A comprehensive **Hospital Management System** built with Streamlit and SQL Server, designed to manage patients, doctors, medical tests, appointments, and hospital operations.

## 🎯 Features

- **📊 Analytics Dashboard** - Real-time hospital statistics and metrics
- **🛌 Patient Management** - Patient registration, profiles, and medical history
- **👨‍⚕️ Doctor Roster** - Doctor management with specialization and hospital assignment
- **📅 Reception & Appointments** - Appointment scheduling and management
- **🧪 Laboratory Management** - Medical test recording and result tracking
- **🏢 Hospital Directory** - Hospital information and contact details
- **👥 Staff Management** - Receptionist and staff management
- **🔗 Doctor-Patient Links** - Many-to-many relationships between doctors and patients
- **📞 Patient Contacts** - Patient phone number management
- **📜 System Audit & Logs** - Track all system activities and changes

## 🛠️ Technology Stack

- **Frontend**: [Streamlit](https://streamlit.io/) - Python web app framework
- **Database**: Microsoft SQL Server with T-SQL
- **Backend**: Python 3.8+
- **Libraries**: pandas, pyodbc

## 📋 Prerequisites

- Python 3.8 or higher
- Microsoft SQL Server 2016+ or SQL Server Express
- ODBC Driver 17 for SQL Server
- pip (Python package manager)

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/hospital-management-system.git
cd hospital-management-system
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Setup SQL Server Database

1. Open **SQL Server Management Studio (SSMS)**
2. Run the SQL script to create the database:

```bash
sqlcmd -S YOUR_SERVER_NAME -i HospitalDB_SQLServer.sql
```

Or manually execute the script in SSMS:
- Open `HospitalDB_SQLServer.sql`
- Execute the entire script

### 4. Update Database Connection

Edit `app.py` and update the server name:

```python
server = r'YOUR_SERVER_NAME\SQLEXPRESS'  # Replace with your SQL Server instance
database = 'HospitalDB'
```

## ▶️ Running the Application

```bash
streamlit run app.py
```

The application will open in your default browser at `http://localhost:8501`

## 📁 Project Structure

```
hospital-management-system/
├── app.py                              # Main Streamlit application
├── HospitalDB_SQLServer.sql            # Database schema and data
├── test.py                             # Testing utilities
├── requirements.txt                    # Python dependencies
├── .gitignore                          # Git ignore rules
├── README.md                           # This file
└── docs/                               # Documentation (optional)
    └── ERD_Hospital_Management.docx    # Entity-Relationship Diagram
```

## 📊 Database Schema

The system uses the following main tables:

- **Hospital** - Hospital information and locations
- **Doctors** - Doctor records with type (Trainee, Visiting, Permanent)
- **Patients** - Patient demographics and contact info
- **Patient_Phones** - Multivalued patient phone numbers
- **Receptionist** - Receptionist staff records
- **Records** - Appointment and medical records
- **Medical_Tests** - Lab test results and diagnosis
- **Doctor_Patient** - Many-to-many relationship
- **Hospital_Audit_Log** - System audit trail

## 🔐 Key Features Implemented

### User-Defined Functions
- `GetPatientAge()` - Calculate patient age from date of birth

### Stored Procedures
- `GetPatientHistory` - Retrieve complete patient medical history
- `UpdateDoctorStatus` - Update doctor employment status

### Views
- `PatientMedicalSummary` - Patient and test summary view
- `StaffDirectory` - Combined doctor and receptionist directory

### Triggers
- `Before_Patient_Insert` - Validate patient DOB (prevent future dates)
- `After_MedicalTest_Insert` - Auto-create records when tests are added
- `Validate_Doctor_Type` - Enforce doctor type constraints and audit logging

## 📝 Usage Examples

### View Patient History
```
Navigate to: 📊 Analytics Dashboard → Select Patient
```

### Add New Medical Test
```
Navigate to: 🧪 Laboratory (Tests) → Record Test → Fill Form → Submit
Auto-trigger creates record in Records table
```

### Check Hospital Staff
```
Navigate to: 🏢 Hospital Directory → View All Hospitals
```

## 🐛 Troubleshooting

### Database Connection Error
- Ensure SQL Server is running
- Verify server name in `app.py` is correct
- Check ODBC Driver 17 is installed: `odbcconf /a {REGSVR "C:\Program Files\Microsoft ODBC Driver 17 for SQL Server\msodbcsql17.dll"}`

### Import Errors
```bash
pip install --upgrade -r requirements.txt
```

### Streamlit Cache Issues
```bash
streamlit cache clear
```

## 📚 Additional Resources

- [Streamlit Documentation](https://docs.streamlit.io/)
- [SQL Server T-SQL Reference](https://learn.microsoft.com/en-us/sql/t-sql/language-reference)
- [pyodbc Documentation](https://github.com/mkleehammer/pyodbc/wiki)

## 👥 Contributors

- **Amir Zaman** - Project Lead

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📧 Support

For support, email: [your-email@example.com](mailto:your-email@example.com)

---

**Last Updated**: May 12, 2026  
**Version**: 1.0.0
