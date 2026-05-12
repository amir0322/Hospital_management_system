import streamlit as st
import pyodbc
import pandas as pd
from datetime import datetime

# PAGE CONFIG & DB CONNECTION
st.set_page_config(page_title="Pro HMS Dashboard", page_icon="🏥", layout="wide")

@st.cache_resource
def get_connection():
    server = r'DESKTOP-A8Q3LJ3\SQLEXPRESS' 
    database = 'HospitalDB'
    conn_str = f'DRIVER={{ODBC Driver 17 for SQL Server}};SERVER={server};DATABASE={database};Trusted_Connection=yes;'
    return pyodbc.connect(conn_str)

try:
    conn = get_connection()
    cursor = conn.cursor()
except Exception as e:
    st.error(f"Database Connection Error: {e}")
    st.stop()

def get_next_id(table_name, column_name):
    cursor.execute(f"SELECT ISNULL(MAX({column_name}), 0) + 1 FROM {table_name}")
    return cursor.fetchone()[0]


#SIDEBAR NAVIGATION

st.sidebar.title("🏥 HMS Modules")
menu = st.sidebar.radio("Go to:", [
    "📊 Analytics Dashboard",
    "🛌 Patient Desk",
    "👨‍⚕️ Doctor Roster",
    "📅 Reception & Appointments",
    "🧪 Laboratory (Tests)",
    "🏢 Hospital Directory",
    "👥 Staff Management",
    "🔗 Doctor-Patient Links",
    "📞 Patient Contacts",
    "📜 System Audit & Logs"
])

# ==========================================
# MODULE 1: ANALYTICS DASHBOARD
# ==========================================
if menu == "📊 Analytics Dashboard":
    st.title("Hospital Analytics Overview")
    
    # Key Metrics
    col1, col2, col3, col4 = st.columns(4)
    total_patients = pd.read_sql("SELECT COUNT(*) FROM Patients", conn).iloc[0,0]
    total_doctors = pd.read_sql("SELECT COUNT(*) FROM Doctors", conn).iloc[0,0]
    total_tests = pd.read_sql("SELECT COUNT(*) FROM Medical_Tests", conn).iloc[0,0]
    total_hospitals = pd.read_sql("SELECT COUNT(*) FROM Hospital", conn).iloc[0,0]
    
    col1.metric("👥 Total Patients", total_patients)
    col2.metric("👨‍⚕️ Available Doctors", total_doctors)
    col3.metric("🧪 Medical Tests", total_tests)
    col4.metric("🏢 Hospitals", total_hospitals)

    st.markdown("---")
    
    # Detailed Analytics
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("👥 Patients by City")
        df_city = pd.read_sql("SELECT City, COUNT(P_ID) AS Total_Patients FROM Patients GROUP BY City ORDER BY Total_Patients DESC", conn)
        st.bar_chart(df_city.set_index("City"))
        
    with col2:
        st.subheader("👨‍⚕️ Doctor Types Distribution")
        df_dtype = pd.read_sql("SELECT D_Type, COUNT(Doc_ID) AS Doctor_Count FROM Doctors GROUP BY D_Type", conn)
        st.bar_chart(df_dtype.set_index("D_Type")['Doctor_Count'])

    st.markdown("---")
    
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("🏥 Doctors per Hospital")
        df_hosp_doc = pd.read_sql("""
            SELECT TOP 10 h.Hos_Name, COUNT(d.Doc_ID) as Doctor_Count 
            FROM Hospital h
            LEFT JOIN Doctors d ON h.Hos_ID = d.Hos_ID
            GROUP BY h.Hos_Name
            ORDER BY Doctor_Count DESC
        """, conn)
        st.bar_chart(df_hosp_doc.set_index("Hos_Name"))
    
    with col2:
        st.subheader("👤 Gender Distribution")
        df_gender = pd.read_sql("SELECT Gender, COUNT(P_ID) as Patient_Count FROM Patients GROUP BY Gender", conn)
        st.bar_chart(df_gender.set_index("Gender")['Patient_Count'])

# ==========================================
# MODULE 2: PATIENT DESK
# ==========================================
elif menu == "🛌 Patient Desk":
    st.title("Patient Management")
    
    tab1, tab2, tab3, tab4, tab5 = st.tabs(["📋 View Patients", "➕ Add New Patient", "📞 Add Contact Info", "🔍 Patient History", "✏️ Update Patient"])
    
    with tab1:
        st.write("Using UDF: `dbo.GetPatientAge`")
        search_name = st.text_input("🔍 Search by Patient Name")
        
        if search_name:
            query = f"SELECT P_ID, P_Name, dbo.GetPatientAge(D_O_B) as Age, Gender, City FROM Patients WHERE P_Name LIKE '%{search_name}%' ORDER BY P_ID DESC"
        else:
            query = "SELECT P_ID, P_Name, dbo.GetPatientAge(D_O_B) as Age, Gender, City FROM Patients ORDER BY P_ID DESC"
        
        df_pat = pd.read_sql(query, conn)
        st.dataframe(df_pat, use_container_width=True)
        
        # View patient details
        if len(df_pat) > 0:
            st.subheader("📌 Patient Details")
            selected_pid = st.selectbox("Select Patient to View Full Details", df_pat['P_ID'].tolist())
            
            df_detail = pd.read_sql(f"""
                SELECT p.P_ID, p.P_Name, p.D_O_B, dbo.GetPatientAge(p.D_O_B) as Age, 
                       p.Gender, p.Colony, p.City, p.Zip,
                       STRING_AGG(pp.Phone_No, ', ') as Phone_Numbers
                FROM Patients p
                LEFT JOIN Patient_Phones pp ON p.P_ID = pp.P_ID
                WHERE p.P_ID = {selected_pid}
                GROUP BY p.P_ID, p.P_Name, p.D_O_B, p.Gender, p.Colony, p.City, p.Zip
            """, conn)
            
            if len(df_detail) > 0:
                col1, col2 = st.columns(2)
                patient_data = df_detail.iloc[0]
                col1.write(f"**Name:** {patient_data['P_Name']}")
                col2.write(f"**Age:** {patient_data['Age']} years")
                col1.write(f"**Gender:** {patient_data['Gender']}")
                col2.write(f"**City:** {patient_data['City']}")
                col1.write(f"**Contact:** {patient_data['Phone_Numbers'] if patient_data['Phone_Numbers'] else 'Not provided'}")
                col2.write(f"**Zip:** {patient_data['Zip']}")
        
    with tab2:
        with st.form("add_patient_form"):
            st.subheader("Register New Patient")
            col1, col2 = st.columns(2)
            p_name = col1.text_input("Patient Name")
            dob = col2.date_input("Date of Birth")
            gender = col1.selectbox("Gender", ["Male", "Female", "Other"])
            phone = col2.text_input("Primary Phone Number")
            city = col1.text_input("City")
            colony = col2.text_input("Colony")
            zip_code = st.text_input("Zip Code")
            
            if st.form_submit_button("✅ Register Patient"):
                new_pid = get_next_id("Patients", "P_ID")
                try:
                    cursor.execute("INSERT INTO Patients (P_ID, P_Name, D_O_B, Gender, Colony, City, Zip) VALUES (?, ?, ?, ?, ?, ?, ?)",
                                   (new_pid, p_name, dob, gender, colony, city, zip_code))
                    if phone:
                        cursor.execute("INSERT INTO Patient_Phones (P_ID, Phone_No) VALUES (?, ?)", (new_pid, phone))
                    conn.commit()
                    st.success(f"✅ Patient '{p_name}' successfully registered with ID {new_pid}!")
                except Exception as e:
                    st.error(f"❌ Error: {e}")

    with tab3:
        st.subheader("📞 Add Additional Phone Number")
        with st.form("add_phone"):
            pat_id = st.number_input("Patient ID", min_value=1)
            extra_phone = st.text_input("Phone Number")
            if st.form_submit_button("➕ Add Phone"):
                try:
                    cursor.execute("INSERT INTO Patient_Phones (P_ID, Phone_No) VALUES (?, ?)", (pat_id, extra_phone))
                    conn.commit()
                    st.success("✅ Contact info added!")
                except Exception as e:
                    st.error("❌ Error: Make sure Patient ID exists or phone is not duplicate.")

    with tab4:
        search_id = st.number_input("Enter Patient ID for Medical History", min_value=1)
        if st.button("🔍 Fetch History (Stored Procedure)"):
            cursor.execute("EXEC GetPatientHistory ?", (search_id,))
            rows = cursor.fetchall()
            if rows:
                cols = [column[0] for column in cursor.description]
                st.table(pd.DataFrame.from_records(rows, columns=cols))
            else:
                st.warning("❌ No records found.")
    
    with tab5:
        st.subheader("✏️ Update Patient Information")
        update_pid = st.number_input("Enter Patient ID to Update", min_value=1)
        
        # Get current patient data
        df_current = pd.read_sql(f"SELECT * FROM Patients WHERE P_ID = {update_pid}", conn)
        
        if len(df_current) > 0:
            current = df_current.iloc[0]
            with st.form("update_patient"):
                p_name = st.text_input("Patient Name", value=current['P_Name'])
                gender = st.selectbox("Gender", ["Male", "Female", "Other"], index=["Male", "Female", "Other"].index(current['Gender']) if current['Gender'] in ["Male", "Female", "Other"] else 0)
                city = st.text_input("City", value=current['City'])
                colony = st.text_input("Colony", value=current['Colony'])
                zip_code = st.text_input("Zip Code", value=current['Zip'])
                
                if st.form_submit_button("💾 Update Patient"):
                    try:
                        cursor.execute("UPDATE Patients SET P_Name=?, Gender=?, City=?, Colony=?, Zip=? WHERE P_ID=?",
                                      (p_name, gender, city, colony, zip_code, update_pid))
                        conn.commit()
                        st.success("✅ Patient information updated!")
                    except Exception as e:
                        st.error(f"❌ Error: {e}")
        else:
            st.warning("❌ Patient ID not found.")

# ==========================================
# MODULE 3: DOCTOR ROSTER
# ==========================================
elif menu == "👨‍⚕️ Doctor Roster":
    st.title("Doctor Management")
    
    tab1, tab2, tab3, tab4 = st.tabs(["👨‍⚕️ View/Add Doctors", "🔄 Update Status", "🔗 Assign to Patient", "📊 Doctor Details"])
    
    with tab1:
        search_doc = st.text_input("🔍 Search Doctor by Name")
        
        if search_doc:
            query = f"SELECT Doc_ID, D_Name, D_Type, D_Phone FROM Doctors WHERE D_Name LIKE '%{search_doc}%' ORDER BY Doc_ID DESC"
        else:
            query = "SELECT Doc_ID, D_Name, D_Type, D_Phone FROM Doctors ORDER BY Doc_ID DESC"
        
        df_docs = pd.read_sql(query, conn)
        st.dataframe(df_docs, use_container_width=True)
        
        st.markdown("---")
        with st.expander("➕ Hire New Doctor (Fires Audit Trigger)"):
            with st.form("add_doc_form"):
                d_name = st.text_input("Doctor Name")
                d_phone = st.text_input("Phone Number")
                d_type = st.selectbox("Doctor Type", ["Trainee", "Visiting", "Permanent"])
                hos_id = st.number_input("Hospital ID", min_value=1, max_value=50, value=1)
                
                if st.form_submit_button("✅ Add Doctor"):
                    new_doc_id = get_next_id("Doctors", "Doc_ID")
                    try:
                        cursor.execute("INSERT INTO Doctors (Doc_ID, D_Name, D_Phone, D_Type, Hos_ID) VALUES (?, ?, ?, ?, ?)",
                                       (new_doc_id, d_name, d_phone, d_type, hos_id))
                        conn.commit()
                        st.success("✅ Doctor Added! Audit Log Updated Automatically.")
                    except Exception as e:
                        st.error(f"❌ {e}")

    with tab2:
        st.subheader("🔄 Promote / Update Doctor Status")
        with st.form("update_doc"):
            doc_id = st.number_input("Doctor ID", min_value=101)
            new_status = st.selectbox("New Status", ["Trainee", "Visiting", "Permanent"])
            if st.form_submit_button("💾 Update Status"):
                try:
                    cursor.execute("EXEC UpdateDoctorStatus ?, ?", (doc_id, new_status))
                    conn.commit()
                    st.success("✅ Status Updated Successfully!")
                except Exception as e:
                    st.error(f"❌ {e}")
                    
    with tab3:
        st.subheader("🔗 Assign Doctor to Patient (Many-to-Many)")
        with st.form("assign_doc"):
            col1, col2 = st.columns(2)
            a_doc_id = col1.number_input("Doctor ID", min_value=1)
            a_pat_id = col2.number_input("Patient ID", min_value=1)
            if st.form_submit_button("✅ Assign"):
                try:
                    cursor.execute("INSERT INTO Doctor_Patient (Doc_ID, P_ID) VALUES (?, ?)", (a_doc_id, a_pat_id))
                    conn.commit()
                    st.success("✅ Doctor successfully assigned to Patient!")
                except Exception as e:
                    st.error("❌ Assignment Failed. Ensure both IDs exist and are not already assigned.")
    
    with tab4:
        st.subheader("📊 Doctor Workload & Statistics")
        
        col1, col2 = st.columns(2)
        
        with col1:
            st.write("**Patients Assigned to Each Doctor**")
            df_workload = pd.read_sql("""
                SELECT d.Doc_ID, d.D_Name, COUNT(dp.P_ID) as Patient_Count
                FROM Doctors d
                LEFT JOIN Doctor_Patient dp ON d.Doc_ID = dp.Doc_ID
                GROUP BY d.Doc_ID, d.D_Name
                ORDER BY Patient_Count DESC
            """, conn)
            st.dataframe(df_workload)
        
        with col2:
            st.write("**Doctor Status Distribution**")
            df_status = pd.read_sql("SELECT D_Type, COUNT(Doc_ID) as Count FROM Doctors GROUP BY D_Type", conn)
            st.bar_chart(df_status.set_index("D_Type")['Count'])

# ==========================================
# MODULE 4: RECEPTION & APPOINTMENTS
# ==========================================
elif menu == "📅 Reception & Appointments":
    st.title("Receptionist Desk - Appointment Management")
    
    tab1, tab2, tab3 = st.tabs(["📅 Book Appointment", "📋 View Appointments", "🔍 Search Appointments"])
    
    with tab1:
        st.subheader("🗓️ Book New Appointment")
        with st.form("book_appointment"):
            col1, col2 = st.columns(2)
            rec_id = col1.number_input("Receptionist ID", min_value=201, max_value=250, value=201)
            p_id = col2.number_input("Patient ID", min_value=1)
            app_date = col1.date_input("Appointment Date", min_value=datetime.today())
            app_time = col2.time_input("Appointment Time")
            desc = st.text_area("Reason / Description")
            
            if st.form_submit_button("✅ Book Appointment"):
                new_rec_no = get_next_id("Records", "Record_NO")
                dt_string = f"{app_date} {app_time}"
                try:
                    cursor.execute("INSERT INTO Records (Record_NO, Appointment, Description, P_ID, Rec_ID) VALUES (?, ?, ?, ?, ?)",
                                   (new_rec_no, dt_string, desc, p_id, rec_id))
                    conn.commit()
                    st.success(f"✅ Appointment Confirmed! Record NO: {new_rec_no}")
                except Exception as e:
                    st.error(f"❌ {e}")
    
    with tab2:
        st.subheader("📋 All Upcoming Appointments")
        query = """
        SELECT r.Record_NO, p.P_Name as Patient, rec.R_Name as Receptionist, r.Appointment, r.Description 
        FROM Records r
        JOIN Patients p ON r.P_ID = p.P_ID
        JOIN Receptionist rec ON r.Rec_ID = rec.Rec_ID
        ORDER BY r.Record_NO DESC
        """
        df_app = pd.read_sql(query, conn)
        st.dataframe(df_app, use_container_width=True)
        st.metric("Total Appointments", len(df_app))
    
    with tab3:
        st.subheader("🔍 Search Appointments")
        search_type = st.radio("Search By:", ["Patient ID", "Record NO", "Receptionist ID"])
        
        if search_type == "Patient ID":
            pat_search = st.number_input("Enter Patient ID", min_value=1)
            query = f"""
            SELECT r.Record_NO, p.P_Name as Patient, rec.R_Name as Receptionist, r.Appointment, r.Description 
            FROM Records r
            JOIN Patients p ON r.P_ID = p.P_ID
            JOIN Receptionist rec ON r.Rec_ID = rec.Rec_ID
            WHERE r.P_ID = {pat_search}
            ORDER BY r.Appointment DESC
            """
        elif search_type == "Record NO":
            rec_search = st.number_input("Enter Record NO", min_value=1)
            query = f"""
            SELECT r.Record_NO, p.P_Name as Patient, rec.R_Name as Receptionist, r.Appointment, r.Description 
            FROM Records r
            JOIN Patients p ON r.P_ID = p.P_ID
            JOIN Receptionist rec ON r.Rec_ID = rec.Rec_ID
            WHERE r.Record_NO = {rec_search}
            """
        else:
            rec_id_search = st.number_input("Enter Receptionist ID", min_value=201)
            query = f"""
            SELECT r.Record_NO, p.P_Name as Patient, rec.R_Name as Receptionist, r.Appointment, r.Description 
            FROM Records r
            JOIN Patients p ON r.P_ID = p.P_ID
            JOIN Receptionist rec ON r.Rec_ID = rec.Rec_ID
            WHERE r.Rec_ID = {rec_id_search}
            ORDER BY r.Appointment DESC
            """
        
        df_search = pd.read_sql(query, conn)
        if len(df_search) > 0:
            st.dataframe(df_search, use_container_width=True)
        else:
            st.warning("❌ No appointments found.")

# ==========================================
# MODULE 5: LABORATORY
# ==========================================
elif menu == "🧪 Laboratory (Tests)":
    st.title("Laboratory & Test Results Management")
    
    tab1, tab2, tab3 = st.tabs(["➕ Record Test", "📊 View Test Results", "🔍 Search Tests"])
    
    with tab1:
        with st.form("lab_form"):
            st.subheader("🧪 Record New Medical Test")
            col1, col2 = st.columns(2)
            p_id = col1.number_input("Patient ID", min_value=1)
            blood_grp = col2.selectbox("Blood Group", ["A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"])
            test_details = st.text_area("Test Name / Details (e.g., CBC Report, ECG, X-Ray)")
            diagnosis = st.text_area("Diagnosis / Results")
            
            if st.form_submit_button("✅ Record Test Result"):
                try:
                    sql = "INSERT INTO Medical_Tests (P_ID, Blood_Test, Test_Details, Diagnosis, Test_Date) VALUES (?, ?, ?, ?, GETDATE())"
                    cursor.execute(sql, (p_id, blood_grp, test_details, diagnosis))
                    conn.commit()
                    st.success("✅ Test Recorded! Associated Trigger Executed Successfully.")
                except Exception as e:
                    st.error(f"❌ {e}")
    
    with tab2:
        st.subheader("📊 All Medical Tests")
        df_tests = pd.read_sql("""
            SELECT mt.Test_ID, mt.P_ID, p.P_Name as Patient, mt.Blood_Test, mt.Test_Details, 
                   mt.Diagnosis, mt.Test_Date
            FROM Medical_Tests mt
            JOIN Patients p ON mt.P_ID = p.P_ID
            ORDER BY mt.Test_ID DESC
        """, conn)
        
        if len(df_tests) > 0:
            st.dataframe(df_tests, use_container_width=True)
            st.metric("Total Tests Recorded", len(df_tests))
        else:
            st.warning("❌ No tests recorded yet.")
    
    with tab3:
        st.subheader("🔍 Search Test Results")
        search_patient_id = st.number_input("Enter Patient ID", min_value=1)
        
        df_patient_tests = pd.read_sql(f"""
            SELECT mt.Test_ID, mt.P_ID, p.P_Name, mt.Blood_Test, mt.Test_Details, mt.Diagnosis, mt.Test_Date
            FROM Medical_Tests mt
            JOIN Patients p ON mt.P_ID = p.P_ID
            WHERE mt.P_ID = {search_patient_id}
            ORDER BY mt.Test_Date DESC
        """, conn)
        
        if len(df_patient_tests) > 0:
            st.dataframe(df_patient_tests, use_container_width=True)
        else:
            st.warning("❌ No tests found for this patient.")

# ==========================================
# MODULE 6: HOSPITAL DIRECTORY
# ==========================================
elif menu == "🏢 Hospital Directory":
    st.title("Hospital Information")
    
    col1, col2 = st.columns([2, 1])
    with col1:
        search = col2.text_input("🔍 Search Hospital by Name")
        
        if search:
            query = f"SELECT * FROM Hospital WHERE Hos_Name LIKE '%{search}%' ORDER BY Hos_ID"
        else:
            query = "SELECT * FROM Hospital ORDER BY Hos_ID"
        
        df_hosp = pd.read_sql(query, conn)
        st.dataframe(df_hosp, use_container_width=True)
        
        st.subheader("📊 Hospitals by City")
        df_city_hosp = pd.read_sql("SELECT City, COUNT(Hos_ID) as Hospital_Count FROM Hospital GROUP BY City ORDER BY Hospital_Count DESC", conn)
        st.bar_chart(df_city_hosp.set_index("City"))

# ==========================================
# MODULE 7: STAFF MANAGEMENT (Receptionists)
# ==========================================
elif menu == "👥 Staff Management":
    st.title("Staff & Receptionist Management")
    
    tab1, tab2 = st.tabs(["👤 View Staff", "➕ Add Receptionist"])
    
    with tab1:
        df_staff = pd.read_sql("""
            SELECT r.Rec_ID, r.R_Name, h.Hos_Name as Hospital, h.City, h.Contact 
            FROM Receptionist r
            LEFT JOIN Hospital h ON r.Hos_ID = h.Hos_ID
            ORDER BY r.Rec_ID
        """, conn)
        st.dataframe(df_staff, use_container_width=True)
        st.info(f"📌 Total Staff Members: {len(df_staff)}")
    
    with tab2:
        with st.form("add_staff"):
            st.subheader("Register New Receptionist")
            rec_id = st.number_input("Receptionist ID", min_value=200, value=get_next_id("Receptionist", "Rec_ID"))
            r_name = st.text_input("Receptionist Name")
            hos_id = st.number_input("Assign to Hospital ID", min_value=1, max_value=50, value=1)
            
            if st.form_submit_button("Add Receptionist"):
                try:
                    cursor.execute("INSERT INTO Receptionist (Rec_ID, R_Name, Hos_ID) VALUES (?, ?, ?)",
                                   (rec_id, r_name, hos_id))
                    conn.commit()
                    st.success(f"✅ Receptionist '{r_name}' added successfully!")
                except Exception as e:
                    st.error(f"Error: {e}")

# ==========================================
# MODULE 8: DOCTOR-PATIENT RELATIONSHIPS
# ==========================================
elif menu == "🔗 Doctor-Patient Links":
    st.title("Doctor-Patient Assignment Management")
    
    tab1, tab2 = st.tabs(["👨‍⚕️➡️👤 View Assignments", "🔗 New Assignment"])
    
    with tab1:
        st.subheader("All Doctor-Patient Relationships")
        df_dp = pd.read_sql("""
            SELECT dp.Doc_ID, d.D_Name as Doctor, d.D_Type, dp.P_ID, p.P_Name as Patient, p.City
            FROM Doctor_Patient dp
            JOIN Doctors d ON dp.Doc_ID = d.Doc_ID
            JOIN Patients p ON dp.P_ID = p.P_ID
            ORDER BY dp.Doc_ID
        """, conn)
        
        if len(df_dp) > 0:
            st.dataframe(df_dp, use_container_width=True)
            
            col1, col2 = st.columns(2)
            with col1:
                st.metric("Total Assignments", len(df_dp))
            with col2:
                unique_docs = df_dp['Doc_ID'].nunique()
                st.metric("Active Doctors", unique_docs)
        else:
            st.warning("No assignments yet.")
    
    with tab2:
        with st.form("assign_new"):
            st.subheader("Create New Doctor-Patient Assignment")
            
            # Get available doctors
            df_docs_list = pd.read_sql("SELECT Doc_ID, D_Name FROM Doctors ORDER BY D_Name", conn)
            doc_options = {row['D_Name']: row['Doc_ID'] for _, row in df_docs_list.iterrows()}
            
            # Get available patients
            df_pat_list = pd.read_sql("SELECT P_ID, P_Name FROM Patients ORDER BY P_Name", conn)
            pat_options = {row['P_Name']: row['P_ID'] for _, row in df_pat_list.iterrows()}
            
            selected_doc = st.selectbox("Select Doctor", list(doc_options.keys()))
            selected_pat = st.selectbox("Select Patient", list(pat_options.keys()))
            
            if st.form_submit_button("Create Assignment"):
                doc_id = doc_options[selected_doc]
                pat_id = pat_options[selected_pat]
                try:
                    cursor.execute("INSERT INTO Doctor_Patient (Doc_ID, P_ID) VALUES (?, ?)", (doc_id, pat_id))
                    conn.commit()
                    st.success(f"✅ {selected_doc} assigned to {selected_pat}!")
                except Exception as e:
                    st.error("Assignment already exists or error occurred.")

# ==========================================
# MODULE 9: PATIENT PHONE DIRECTORY
# ==========================================
elif menu == "📞 Patient Contacts":
    st.title("Patient Contact Directory")
    
    search_pat = st.text_input("🔍 Search Patient by Name")
    
    if search_pat:
        query = f"""
            SELECT p.P_ID, p.P_Name, p.City, STRING_AGG(pp.Phone_No, ', ') as Phones
            FROM Patients p
            LEFT JOIN Patient_Phones pp ON p.P_ID = pp.P_ID
            WHERE p.P_Name LIKE '%{search_pat}%'
            GROUP BY p.P_ID, p.P_Name, p.City
            ORDER BY p.P_Name
        """
    else:
        query = """
            SELECT p.P_ID, p.P_Name, p.City, STRING_AGG(pp.Phone_No, ', ') as Phones
            FROM Patients p
            LEFT JOIN Patient_Phones pp ON p.P_ID = pp.P_ID
            GROUP BY p.P_ID, p.P_Name, p.City
            ORDER BY p.P_ID DESC
        """
    
    try:
        df_contacts = pd.read_sql(query, conn)
        st.dataframe(df_contacts, use_container_width=True)
    except:
        st.info("Use the search box to find patients")

# ==========================================
# MODULE 10: SYSTEM AUDIT & LOGS
# ==========================================
elif menu == "📜 System Audit & Logs":
    st.title("Database Logs")
    st.write("Yeh logs SQL Triggers se automatically generate ho rahe hain.")
    
    try:
        df_audit = pd.read_sql("SELECT * FROM Hospital_Audit_Log ORDER BY Log_ID DESC", conn)
        st.dataframe(df_audit, use_container_width=True)
    except:
        st.warning("No logs found yet. Try adding a new doctor to fire the audit trigger.")