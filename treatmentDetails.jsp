<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Treatment Details</title>
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
        .treatment-details {
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
        .treatment-details h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7);
        }
        .treatment-details label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .treatment-details input[type="text"],
        .treatment-details select,
        .treatment-details textarea {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8);
        }
        /* Style for select dropdown arrow */
        .treatment-details select {
            appearance: none; /* Remove default arrow */
            -webkit-appearance: none;
            -moz-appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 1em;
        }
        .treatment-details button {
            background-color: #2980b9;
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.3s;
        }
        .treatment-details button:hover {
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
    </style>
</head>
<body>
    <img src="img/bg1.png" alt="Treatment Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="treatment-details">
        <h1>Treatment Details</h1>

        <%
            String treatmentId = "T001"; // Default ID for auto-generation
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                String url = "jdbc:mysql://localhost:3306/hospital";
                String user = "root";
                String password = "@Sashini123";
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, user, password);
                stmt = conn.createStatement();
                // Get the maximum treatment_id that starts with 'T'
                rs = stmt.executeQuery("SELECT MAX(treatment_id) FROM TreatmentDetails WHERE treatment_id LIKE 'T%'");

                if (rs.next()) {
                    String maxId = rs.getString(1);
                    if (maxId != null && maxId.startsWith("T") && maxId.length() > 1) {
                        try {
                            // Extract numeric part, increment, and format
                            int num = Integer.parseInt(maxId.substring(1)) + 1;
                            treatmentId = "T" + String.format("%03d", num); // Ensure 3 digits, e.g., T001, T010, T100
                        } catch (NumberFormatException e) {
                            // If parsing fails (e.g., maxId is "Tabc"), reset to T001
                            treatmentId = "T001";
                        }
                    }
                }
            } catch (Exception e) {
                out.println("<p class='error-message'>Error generating Treatment ID: " + e.getMessage() + "</p>");
                // Fallback for ID in case of generation error
                treatmentId = "T_ERROR"; 
            } finally {
                // Close resources for ID generation
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }

            // --- Handle Form Submission (POST Request) ---
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String patientId = request.getParameter("patientId");
                String doctorId = request.getParameter("doctorId"); // Now from dropdown
                String date = request.getParameter("date");
                String time = request.getParameter("time");
                String description = request.getParameter("description");
                String prescriptions = request.getParameter("prescriptions");
                
                // Re-establish connection for insert operation
                Connection insertConn = null;
                PreparedStatement pstmt = null;
                try {
                    String url = "jdbc:mysql://localhost:3306/hospital";
                    String user = "root";
                    String password = "@Sashini123";
                    Class.forName("com.mysql.cj.jdbc.Driver"); // Load driver only once
                    insertConn = DriverManager.getConnection(url, user, password);

                    String sql = "INSERT INTO TreatmentDetails (treatment_id, patient_id, doctor_id, appointment_date, appointment_time, description, prescriptions) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    pstmt = insertConn.prepareStatement(sql);

                    pstmt.setString(1, treatmentId); // Use the generated ID
                    pstmt.setString(2, patientId);
                    pstmt.setString(3, doctorId); // This is now a selected value from dropdown
                    pstmt.setString(4, date);
                    pstmt.setString(5, time);
                    pstmt.setString(6, description);
                    pstmt.setString(7, prescriptions);

                    int rowsInserted = pstmt.executeUpdate();

                    if (rowsInserted > 0) {
                        out.println("<p class='success-message'>Treatment details saved successfully!</p>");
                    } else {
                        out.println("<p class='error-message'>Failed to save treatment details.</p>");
                    }

                } catch (SQLException e) {
                    // Specific error handling for foreign key constraint violation
                    if (e.getErrorCode() == 1452) { // MySQL error code for foreign key constraint fail
                         out.println("<p class='error-message'>Database error: Invalid Patient ID or Doctor ID provided. Please ensure they exist in their respective tables.</p>");
                    } else {
                        out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                    }
                    e.printStackTrace(); // Log the full stack trace for debugging
                } catch (Exception e) {
                    out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                    e.printStackTrace(); // Log the full stack trace for debugging
                } finally {
                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
                    if (insertConn != null) try { insertConn.close(); } catch (SQLException e) {}
                }
            }
        %>

        <form id="treatmentForm" method="post" onsubmit="return validateForm()">
            <label for="treatmentId">Treatment ID:</label>
            <input type="text" id="treatmentId" name="treatmentId" value="<%= treatmentId %>" readonly>

            <label for="patientId">Patient ID:</label>
            <select id="patientId" name="patientId" required>
                <option value="">Select Patient ID</option>
                <%
                    Connection patientConn = null;
                    Statement patientStmt = null;
                    ResultSet patientRs = null;
                    try {
                        patientConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hospital", "root", "@Sashini123");
                        patientStmt = patientConn.createStatement();
                        patientRs = patientStmt.executeQuery("SELECT patient_id FROM OutPatients ORDER BY patient_id");
                        while (patientRs.next()) {
                            String pId = patientRs.getString("patient_id");
                %>
                    <option value="<%= pId %>"><%= pId %></option>
                <%
                        }
                    } catch (SQLException e) {
                        out.println("<option value=''>Error loading patients</option>");
                        e.printStackTrace();
                    } finally {
                        if (patientRs != null) try { patientRs.close(); } catch (SQLException e) {}
                        if (patientStmt != null) try { patientStmt.close(); } catch (SQLException e) {}
                        if (patientConn != null) try { patientConn.close(); } catch (SQLException e) {}
                    }
                %>
            </select>

            <label for="doctorId">Doctor ID:</label>
            <select id="doctorId" name="doctorId" required>
                <option value="">Select Doctor</option>
                <%
                    Connection doctorConn = null;
                    Statement doctorStmt = null;
                    ResultSet doctorRs = null;
                    try {
                        doctorConn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hospital", "root", "@Sashini123");
                        doctorStmt = doctorConn.createStatement();
                        // Fetch doctor IDs and names for the dropdown
                        doctorRs = doctorStmt.executeQuery("SELECT id, firstName, lastName, specialization FROM Doctors ORDER BY lastName, firstName");
                        while (doctorRs.next()) {
                            String docId = doctorRs.getString("id");
                            String docName = doctorRs.getString("firstName") + " " + doctorRs.getString("lastName");
                            String docSpecialization = doctorRs.getString("specialization");
                %>
                    <option value="<%= docId %>"><%= docName %> (<%= docSpecialization %>)</option>
                <%
                        }
                    } catch (SQLException e) {
                        out.println("<option value=''>Error loading doctors</option>");
                        e.printStackTrace();
                    } finally {
                        if (doctorRs != null) try { doctorRs.close(); } catch (SQLException e) {}
                        if (doctorStmt != null) try { doctorStmt.close(); } catch (SQLException e) {}
                        if (doctorConn != null) try { doctorConn.close(); } catch (SQLException e) {}
                    }
                %>
            </select>

            <label for="date">Date:</label>
            <input type="date" id="date" name="date" required> <label for="time">Time:</label>
            <input type="time" id="time" name="time" required> <label for="description">Description:</label>
            <textarea id="description" name="description" rows="4" placeholder="Enter treatment description"></textarea>

            <label for="prescriptions">Prescriptions:</label>
            <textarea id="prescriptions" name="prescriptions" rows="4" placeholder="Enter prescriptions"></textarea>

            <button type="submit">Save Treatment Details</button>
        </form>

        <div class="record-controls">
            <button onclick="window.location.href='searchTreatment.jsp'">Search Treatments</button>
            <button onclick="addNewTreatment()">Add New Treatment</button>
            <button onclick="window.location.href='viewTreatment.jsp'">View All Treatments</button>
            <button onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        function refreshPage() {
            window.location.reload();
        }

        function addNewTreatment() {
            // Clear the form fields but reload the page to get a fresh auto-generated Treatment ID
            window.location.reload(); 
            // Or if you only want to clear fields without new ID generation:
            // document.getElementById('treatmentForm').reset();
            // document.getElementById('patientId').focus();
        }

        function goToHome() {
            window.location.href = 'Home.jsp';
        }

        function validateForm() {
            const patientId = document.getElementById('patientId').value;
            const doctorId = document.getElementById('doctorId').value; // Get doctor ID from dropdown

            if (patientId.trim() === '') {
                alert('Please select a Patient ID');
                return false;
            }
            if (doctorId.trim() === '') { // Validate doctorId
                alert('Please select a Doctor');
                return false;
            }

            return true;
        }

        window.onload = function() {
            // Set today's date as default for the date input
            const today = new Date();
            const year = today.getFullYear();
            const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-indexed
            const day = String(today.getDate()).padStart(2, '0');
            document.getElementById('date').value = `${year}-${month}-${day}`;

            // Set current time as default for the time input
            const hours = String(today.getHours()).padStart(2, '0');
            const minutes = String(today.getMinutes()).padStart(2, '0');
            document.getElementById('time').value = `${hours}:${minutes}`;

            document.getElementById('patientId').focus();
        };
    </script>
</body>
</html>