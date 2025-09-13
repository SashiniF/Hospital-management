<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admission Details</title>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/timepicker/1.3.5/jquery.timepicker.min.css">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/timepicker/1.3.5/jquery.timepicker.min.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            overflow: hidden;
            background-color: #f0f8ff;
        }
        .background-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            opacity: 0.7;
            object-fit: cover;
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 150px;
            height: auto;
            z-index: 1;
        }
        .home-button {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 60px;
            height: 60px;
            cursor: pointer;
            transition: transform 0.2s;
            z-index: 1;
        }
        .home-button:hover {
            transform: scale(1.1);
        }
        .admission-details {
            background-color: rgba(255, 255, 255, 0.7);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            margin: 50px auto;
            height: calc(100vh - 100px);
            overflow-y: auto;
            backdrop-filter: blur(3px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .admission-details h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7);
        }
        .admission-details label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .admission-details input[type="text"],
        .admission-details select,
        .admission-details textarea {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8);
        }
        /* Style for select dropdown arrow */
        .admission-details select {
            appearance: none; /* Remove default arrow */
            -webkit-appearance: none;
            -moz-appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 1em;
        }
        .admission-details button {
            background-color: #2980b9;
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.3s;
            margin-top: 10px;
        }
        .admission-details button:hover {
            background-color: #3498db;
        }
        .record-controls {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
        }
        .record-controls button {
            background-color: #27ae60;
            padding: 8px;
            font-size: 12px;
            margin-right: 5px;
            flex: 1;
        }
        .record-controls button:last-child {
            margin-right: 0;
        }
        .success-message {
            color: #27ae60;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .error-message {
            color: #e74c3c;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        /* Styles for jQuery UI Datepicker and Timepicker */
        .ui-datepicker {
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
        .ui-timepicker-wrapper {
            width: 160px;
            background: #fff;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 10px;
            overflow-y: auto;
            max-height: 150px;
            box-shadow: 0 2px 5px rgba(0,0,0,0.2);
        }
    </style>
</head>
<body>
    <img src="img/bg1.png" alt="Admission Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="admission-details">
        <h1>ADMISSION DETAILS</h1>

        <%
            String admissionId = "A001"; // Default ID for auto-generation
            StringBuilder patientOptions = new StringBuilder();
            StringBuilder guardianOptions = new StringBuilder();
            StringBuilder roomWardOptions = new StringBuilder(); // Renamed for clarity
            StringBuilder bedOptions = new StringBuilder();

            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            // --- Database Connection Parameters ---
            final String DB_URL = "jdbc:mysql://localhost:3306/hospital";
            final String DB_USER = "root";
            final String DB_PASSWORD = "@Sashini123";

            // --- START: Handle Form Submission (POST Request) ---
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                // Get the generated admissionId from the form (it's read-only, so it will be the current one)
                admissionId = request.getParameter("admissionId");

                String patientId = request.getParameter("patientId");
                String guardianId = request.getParameter("guardianId");
                String roomWardId = request.getParameter("roomWardId");
                String admissionDate = request.getParameter("admissionDate");
                String emergency = request.getParameter("emergency");
                String admissionTime = request.getParameter("admissionTime");
                String referredDoctor = request.getParameter("referredDoctor"); // This is now a text input
                String bedId = request.getParameter("bedId");

                Connection insertConn = null;
                PreparedStatement pstmt = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    insertConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

                    // Insert admission details into the database
                    String sql = "INSERT INTO AdmissionDetails (admission_id, patient_id, guardian_id, room_ward_id, admission_date, emergency, admission_time, referred_doctor, bed_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    pstmt = insertConn.prepareStatement(sql);
                    pstmt.setString(1, admissionId); // Use the existing generated ID
                    pstmt.setString(2, patientId);
                    pstmt.setString(3, guardianId);
                    pstmt.setString(4, roomWardId);
                    pstmt.setString(5, admissionDate); // Now in YYYY-MM-DD format
                    pstmt.setString(6, emergency);
                    pstmt.setString(7, admissionTime); // Now in HH:MM format
                    pstmt.setString(8, referredDoctor); // This is free text
                    pstmt.setString(9, bedId);

                    int rowsInserted = pstmt.executeUpdate();
                    if (rowsInserted > 0) {
                        out.println("<p class='success-message'>Admission details saved successfully!</p>");
                        // Optionally, you might want to redirect to clear the form and get a new ID for the next entry
                        // response.sendRedirect("admission_details.jsp");
                    } else {
                        out.println("<p class='error-message'>Failed to save admission details. No rows affected.</p>");
                    }
                } catch (SQLException e) {
                    // Specific error handling for foreign key constraint violation
                    if (e.getErrorCode() == 1452) { // MySQL error code for foreign key constraint fail
                         out.println("<p class='error-message'>Database error: Invalid Patient, Guardian, Room/Ward, or Bed ID provided. Please ensure they exist in their respective tables.</p>");
                    } else if (e.getErrorCode() == 1062) { // Duplicate entry for primary key
                         out.println("<p class='error-message'>Database error: Admission ID '" + admissionId + "' already exists. Please refresh to get a new ID or verify existing records.</p>");
                    } else {
                        out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                    }
                    e.printStackTrace(); // Log the full stack trace for debugging
                } catch (Exception e) {
                    out.println("<p class='error-message'>Error during save operation: " + e.getMessage() + "</p>");
                    e.printStackTrace(); // Log the full stack trace for debugging
                } finally {
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                    if (insertConn != null) try { insertConn.close(); } catch (SQLException e) {}
                }
            }
            // --- END: Handle Form Submission ---

            // --- START: Fetching data for dropdowns and generate Admission ID ---
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                stmt = conn.createStatement();

                // Fetch Patient IDs for InPatients
                rs = stmt.executeQuery("SELECT patient_id FROM InPatients ORDER BY patient_id");
                patientOptions.append("<option value=''>Select Patient ID</option>");
                while (rs.next()) {
                    String id = rs.getString("patient_id");
                    patientOptions.append("<option value='").append(id).append("'>").append(id).append("</option>");
                }
                rs.close(); // Close previous ResultSet before new query

                // Fetch Guardian IDs
                rs = stmt.executeQuery("SELECT guardian_id FROM GuardianDetails ORDER BY guardian_id");
                guardianOptions.append("<option value=''>Select Guardian ID</option>");
                while (rs.next()) {
                    String id = rs.getString("guardian_id");
                    guardianOptions.append("<option value='").append(id).append("'>").append(id).append("</option>");
                }
                rs.close();

                // Fetch Room IDs
                rs = stmt.executeQuery("SELECT room_id FROM RoomDetails ORDER BY room_id");
                roomWardOptions.append("<option value=''>Select Room/Ward ID</option>");
                while (rs.next()) {
                    String id = rs.getString("room_id");
                    roomWardOptions.append("<option value='").append(id).append("'>Room ").append(id).append("</option>");
                }
                rs.close();

                // Fetch Ward IDs (append to roomWardOptions)
                rs = stmt.executeQuery("SELECT ward_id FROM WardDetails ORDER BY ward_id");
                while (rs.next()) {
                    String id = rs.getString("ward_id");
                    roomWardOptions.append("<option value='").append(id).append("'>Ward ").append(id).append("</option>");
                }
                rs.close();

                // Fetch Bed IDs
                rs = stmt.executeQuery("SELECT bed_id FROM BedDetails ORDER BY bed_id");
                bedOptions.append("<option value=''>Select Bed ID</option>");
                while (rs.next()) {
                    String id = rs.getString("bed_id");
                    bedOptions.append("<option value='").append(id).append("'>").append(id).append("</option>");
                }
                rs.close();

                // Generate Admission ID
                // Note: The MAX function needs to be robust for different formats
                // This query assumes IDs are 'A' followed by numbers, e.g., A001, A002
                rs = stmt.executeQuery("SELECT MAX(CAST(SUBSTRING(admission_id, 2) AS UNSIGNED)) FROM AdmissionDetails WHERE admission_id LIKE 'A%'");

                if (rs.next()) {
                    int maxNum = rs.getInt(1); // Will be 0 if no matching IDs or null
                    admissionId = "A" + String.format("%03d", maxNum + 1); // Format to A001, A002 etc.
                } else {
                    admissionId = "A001"; // Default if no records or unexpected format
                }
                rs.close();

            } catch (Exception e) {
                out.println("<p class='error-message'>Error fetching dropdown data or generating Admission ID: " + e.getMessage() + "</p>");
                e.printStackTrace(); // Log the full stack trace for debugging
                admissionId = "A_ERROR"; // Fallback for ID in case of generation error
            } finally {
                // Ensure all resources are closed
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
            // --- END: Fetching data for dropdowns ---
        %>

        <form id="admissionForm" method="post" onsubmit="return validateForm()">
            <label for="admissionId">Admission ID:</label>
            <input type="text" id="admissionId" name="admissionId" value="<%= admissionId %>" readonly>

            <label for="patientId">Patient ID:</label>
            <select id="patientId" name="patientId" required>
                <%= patientOptions.toString() %>
            </select>

            <label for="guardianId">Guardian ID:</label>
            <select id="guardianId" name="guardianId" required>
                <%= guardianOptions.toString() %>
            </select>

            <label for="roomWardId">Room/Ward ID:</label>
            <select id="roomWardId" name="roomWardId" required>
                <%= roomWardOptions.toString() %>
            </select>

            <label for="admissionDate">Admission Date:</label>
            <input type="text" id="admissionDate" name="admissionDate" placeholder="YYYY-MM-DD" required>

            <label for="emergency">Emergency:</label>
            <select id="emergency" name="emergency">
                <option value="No">No</option>
                <option value="Yes">Yes</option>
            </select>

            <label for="admissionTime">Admission Time:</label>
            <input type="text" id="admissionTime" name="admissionTime" placeholder="HH:MM" required>

            <label for="referredDoctor">Referred Doctor:</label>
            <input type="text" id="referredDoctor" name="referredDoctor" placeholder="Enter referred doctor name" required>

            <label for="bedId">Bed ID:</label>
            <select id="bedId" name="bedId" required>
                <%= bedOptions.toString() %>
            </select>

            <button type="submit">Save Admission Details</button>
        </form>

        <div class="record-controls">
            <button type="button" onclick="searchRecord()">Search</button>
            <button type="button" onclick="addNewRecord()">Add New</button>
            <button type="button" onclick="viewAllRecords()">View All</button>
            <button type="button" onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        $(function() {
            // Set date format to YYYY-MM-DD for MySQL compatibility
            $("#admissionDate").datepicker({
                dateFormat: 'yy-mm-dd',
                changeMonth: true,
                changeYear: true,
                yearRange: "-100:+10", // Allow selection from 100 years ago to 10 years in the future
            });
            
            // Set time format to HH:MM (24-hour) for MySQL compatibility
            $("#admissionTime").timepicker({
                timeFormat: 'HH:mm', // Changed to 24-hour format
                interval: 15, // Time options in 15-minute intervals
                minTime: '00:00', // Start of day
                maxTime: '23:45', // End of day
                defaultTime: 'now', // Default to current time
                scrollDefault: 'now', // Scroll dropdown to current time
                dynamic: false,
                dropdown: true,
                scrollbar: true
            });

            // Set default date to today's date if the field is empty on load
            if (!$("#admissionDate").val()) {
                const today = new Date();
                const year = today.getFullYear();
                const month = String(today.getMonth() + 1).padStart(2, '0');
                const day = String(today.getDate()).padStart(2, '0');
                $("#admissionDate").val(`${year}-${month}-${day}`);
            }

            // Set default time to current time if the field is empty on load
            if (!$("#admissionTime").val()) {
                const now = new Date();
                const hours = String(now.getHours()).padStart(2, '0');
                const minutes = String(now.getMinutes()).padStart(2, '0');
                $("#admissionTime").val(`${hours}:${minutes}`);
            }
        });

        function refreshPage() {
            window.location.reload();
        }

        function addNewRecord() {
            // Reload the page to get a new auto-generated Admission ID and clear the form
            window.location.reload(); 
        }

        function searchRecord() {
            window.location.href = 'searchAdmission.jsp';
        }

        function viewAllRecords() {
            window.location.href = 'viewAdmission.jsp';
        }

        function validateForm() {
            const patientId = document.getElementById('patientId').value;
            const guardianId = document.getElementById('guardianId').value;
            const roomWardId = document.getElementById('roomWardId').value;
            const admissionDate = document.getElementById('admissionDate').value;
            const admissionTime = document.getElementById('admissionTime').value;
            const referredDoctor = document.getElementById('referredDoctor').value; // Now a text input
            const bedId = document.getElementById('bedId').value;

            // Check if all required fields are filled (dropdowns must have a selected value, text inputs must not be empty)
            if (patientId.trim() === '' || guardianId.trim() === '' || roomWardId.trim() === '' || admissionDate.trim() === '' || 
                admissionTime.trim() === '' || referredDoctor.trim() === '' || bedId.trim() === '') {
                alert('Please fill in all required fields (Patient, Guardian, Room/Ward, Date, Time, Doctor Name, Bed).');
                return false;
            }

            // No need for strong date/time regex validation as jQuery UI handles format
            // but you can add it if you want to be extra strict on manual edits or for robustness

            return true;
        }

        window.onload = function() {
            // Set initial focus to the first data entry field
            document.getElementById('patientId').focus();
        };
    </script>
</body>
</html>