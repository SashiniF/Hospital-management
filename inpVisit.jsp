<%@ page import="java.sql.*, java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Visit Details</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            overflow: hidden;
            background-color: #e6e6fa; /* Light purple-blue */
        }
        .background-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            opacity: 0.5;
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
        /* Home button added for consistency */
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
        .visit-container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            margin: 50px auto;
            height: calc(100vh - 100px); /* Adjust height to prevent scroll issues */
            overflow-y: auto;
            backdrop-filter: blur(3px); /* Add a subtle blur effect */
            border: 1px solid rgba(255, 255, 255, 0.3); /* Soft border */
        }
        .visit-container h1 {
            text-align: center;
            color: #4a4a4a;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7); /* Subtle text shadow */
        }
        .visit-container label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #4a4a4a;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .visit-container input[type="text"], 
        .visit-container input[type="datetime-local"],
        .visit-container select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8); /* Slightly transparent background */
        }
        /* Style for select dropdown arrow */
        .visit-container select {
            appearance: none; /* Remove default arrow */
            -webkit-appearance: none;
            -moz-appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 1em;
        }
        .visit-container button[type="submit"] {
            background-color: #6c63ff; /* Main action button color */
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.3s;
            margin-top: 10px; /* Space above */
        }
        .visit-container button[type="submit"]:hover {
            background-color: #554bcc; /* Darker shade on hover */
        }
        .record-navigation {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
        }
        .record-navigation button {
            background-color: #5cb85c; /* Green for navigation buttons */
            color: white;
            padding: 8px;
            font-size: 12px;
            margin-right: 5px;
            flex: 1;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .record-navigation button:last-child {
            margin-right: 0; /* No margin on the last button */
        }
        .record-navigation button:hover {
            background-color: #4cae4c; /* Darker green on hover */
        }
        .success-message {
            color: #27ae60; /* Darker green for success */
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .error-message {
            color: #e74c3c; /* Darker red for error */
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
    </style>
</head>
<body>
    <img src="img/bg2.png" alt="Background" class="background-image">
    <img src="img/h.jpg" alt="Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="visit-container">
        <h1>Visit Details</h1>

        <%-- Initialize variables --%>
        <%
            String visitId = "";
            String visitDate = "";
            String doctorId = ""; // Will now store the selected Doctor ID
            String admissionId = "";
            String patientId = "";
            String description = "";
            String actionMessage = "";
            String errorMessage = "";

            // Database connection details
            final String DB_URL = "jdbc:mysql://localhost:3306/hospital";
            final String DB_USER = "root";
            final String DB_PASSWORD = "@Sashini123";

            // Lists to populate dropdowns
            List<String> inpatientIds = new ArrayList<>();
            List<String> admissionIds = new ArrayList<>();
            List<Map<String, String>> doctors = new ArrayList<>(); // To store doctor ID and display name

            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

                // --- Generate the next Visit ID ---
                String visitIdSql = "SELECT MAX(CAST(SUBSTRING(visit_id, 2) AS UNSIGNED)) AS max_id FROM VisitDetails WHERE visit_id LIKE 'V%'";
                stmt = conn.createStatement();
                rs = stmt.executeQuery(visitIdSql);
                
                if (rs.next()) {
                    int maxNum = rs.getInt("max_id"); 
                    visitId = String.format("V%03d", maxNum + 1); 
                } else {
                    visitId = "V001"; 
                }
                rs.close(); 
                stmt.close(); 

                // --- Fetch InPatient IDs for dropdown ---
                stmt = conn.createStatement();
                String patientSql = "SELECT patient_id FROM InPatients ORDER BY patient_id";
                rs = stmt.executeQuery(patientSql);
                while (rs.next()) {
                    inpatientIds.add(rs.getString("patient_id"));
                }
                rs.close();
                stmt.close();

                // --- Fetch Admission IDs for dropdown ---
                stmt = conn.createStatement();
                String admissionSql = "SELECT admission_id FROM AdmissionDetails ORDER BY admission_id";
                rs = stmt.executeQuery(admissionSql);
                while (rs.next()) {
                    admissionIds.add(rs.getString("admission_id"));
                }
                rs.close();
                stmt.close();

                // --- Fetch Doctors for dropdown ---
                stmt = conn.createStatement();
                String doctorSql = "SELECT id, firstName, lastName, specialization FROM Doctors ORDER BY lastName, firstName";
                rs = stmt.executeQuery(doctorSql);
                while (rs.next()) {
                    Map<String, String> doctor = new HashMap<>();
                    doctor.put("id", rs.getString("id"));
                    doctor.put("name", rs.getString("firstName") + " " + rs.getString("lastName") + " (" + rs.getString("specialization") + ")");
                    doctors.add(doctor);
                }
                rs.close();
                stmt.close();

            } catch (Exception e) {
                errorMessage = "Error loading initial data (dropdowns or ID generation): " + e.getMessage();
                e.printStackTrace(); 
                visitId = "V_ERROR"; 
            } finally {
                if (rs != null) { try { rs.close(); } catch (SQLException e) { /* log error */ } }
                if (stmt != null) { try { stmt.close(); } catch (SQLException e) { /* log error */ } }
                if (conn != null) { try { conn.close(); } catch (SQLException e) { /* log error */ } }
            }

            // --- Handle form submission (POST request) ---
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String action = request.getParameter("action");

                // Get the current visitId from the form (read-only field)
                visitId = request.getParameter("visitId"); 

                if ("save".equals(action)) {
                    visitDate = request.getParameter("visitDate");
                    doctorId = request.getParameter("doctorId"); // Get selected Doctor ID
                    admissionId = request.getParameter("admissionId");
                    patientId = request.getParameter("patientId");
                    description = request.getParameter("description");

                    // No need for regex validation on Doctor ID here, as it comes from a dropdown
                    // which ensures it's a valid ID from the Doctors table.
                    // However, a check for empty selection is still good.
                    if (doctorId == null || doctorId.isEmpty()) {
                        errorMessage = "Please select a Doctor.";
                    } else {
                        Connection insertConn = null;
                        PreparedStatement pstmt = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            insertConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

                            String sql = "INSERT INTO VisitDetails (visit_id, visit_date, doctor_id, admission_id, patient_id, description) " +
                                         "VALUES (?, ?, ?, ?, ?, ?)";
                            pstmt = insertConn.prepareStatement(sql);
                            
                            pstmt.setString(1, visitId);
                            pstmt.setString(2, visitDate);      
                            pstmt.setString(3, doctorId); // Insert the selected Doctor ID
                            pstmt.setString(4, admissionId);
                            pstmt.setString(5, patientId);
                            pstmt.setString(6, description);

                            int rowsInserted = pstmt.executeUpdate();
                            if (rowsInserted > 0) {
                                actionMessage = "Visit details saved successfully!";
                                // Optional: Redirect to prevent form re-submission on refresh
                                // response.sendRedirect("visit_details.jsp");
                            } else {
                                errorMessage = "Error saving visit details. No rows affected.";
                            }
                        } catch (SQLException e) {
                            if (e.getSQLState().startsWith("23")) { 
                                if (e.getErrorCode() == 1452) { 
                                    errorMessage = "Database error: Invalid Patient ID, Admission ID, or Doctor ID. Please ensure they exist.";
                                } else if (e.getErrorCode() == 1062) { 
                                    errorMessage = "Database error: Visit ID '" + visitId + "' already exists. Please refresh to get a new ID.";
                                } else {
                                    errorMessage = "Database integrity error: " + e.getMessage();
                                }
                            } else {
                                errorMessage = "Database error: " + e.getMessage();
                            }
                            e.printStackTrace(); 
                        } catch (Exception e) {
                            errorMessage = "An unexpected error occurred during save: " + e.getMessage();
                            e.printStackTrace(); 
                        } finally {
                            if (pstmt != null) { try { pstmt.close(); } catch (SQLException e) { /* log error */ } }
                            if (insertConn != null) { try { insertConn.close(); } catch (SQLException e) { /* log error */ } }
                        }
                    }
                }
            }
        %>

        <%-- Display messages --%>
        <% if (!errorMessage.isEmpty()) { %>
            <div class="error-message"><%= errorMessage %></div>
        <% } %>

        <% if (!actionMessage.isEmpty()) { %>
            <div class="success-message"><%= actionMessage %></div>
        <% } %>

        <form method="post" onsubmit="return validateForm()">
            <input type="hidden" name="action" value="save">
            
            <label for="visitId">Visit ID:</label>
            <input type="text" id="visitId" name="visitId" value="<%= visitId %>" readonly>
            
            <label for="visitDate">Visit Date & Time:</label>
            <input type="datetime-local" id="visitDate" name="visitDate" value="<%= visitDate %>" required>
            
            <label for="doctorId">Doctor:</label>
            <select id="doctorId" name="doctorId" required>
                <option value="">-- Select Doctor --</option>
                <%
                    if (!doctors.isEmpty()) {
                        for (Map<String, String> doctor : doctors) {
                            String id = doctor.get("id");
                            String name = doctor.get("name");
                            // Pre-select if value was maintained from a failed submission
                            String selected = (id.equals(doctorId) && "POST".equalsIgnoreCase(request.getMethod())) ? "selected" : "";
                %>
                    <option value="<%= id %>" <%= selected %>><%= name %></option>
                <%
                        }
                    } else {
                        out.println("<option value=''>No Doctors found</option>");
                    }
                %>
            </select>

            <label for="admissionId">Admission ID:</label>
            <select id="admissionId" name="admissionId" required>
                <option value="">-- Select Admission ID --</option>
                <%
                    if (!admissionIds.isEmpty()) { 
                        for (String id : admissionIds) {
                            String selected = (id.equals(admissionId) && "POST".equalsIgnoreCase(request.getMethod())) ? "selected" : "";
                %>
                    <option value="<%= id %>" <%= selected %>><%= id %></option>
                <%
                        }
                    } else {
                        out.println("<option value=''>No Admission IDs found</option>");
                    }
                %>
            </select>
            
            <label for="patientId">Patient ID:</label>
            <select id="patientId" name="patientId" required>
                <option value="">-- Select Patient ID --</option>
                <%
                    if (!inpatientIds.isEmpty()) { 
                        for (String id : inpatientIds) {
                            String selected = (id.equals(patientId) && "POST".equalsIgnoreCase(request.getMethod())) ? "selected" : "";
                %>
                    <option value="<%= id %>" <%= selected %>><%= id %></option>
                <%
                        }
                    } else {
                        out.println("<option value=''>No Patient IDs found</option>");
                    }
                %>
            </select>
            
            <label for="description">Description:</label>
            <input type="text" id="description" name="description" value="<%= description %>" required>

            <button type="submit">Save Visit Details</button>
        </form>

        <div class="record-navigation">
            <button type="button" onclick="searchVisit()">Search</button>
            <button type="button" onclick="viewVisit()">View All</button>
            <button type="button" onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        function refreshPage() {
            window.location.reload();
        }

        function goToHome() {
            window.location.href = 'Home.jsp'; // Adjust if your home page is named differently
        }

        function searchVisit() {
            window.location.href = 'searchVisit.jsp'; 
        }

        function viewVisit() {
            window.location.href = 'viewVisits.jsp'; 
        }

        function validateForm() {
            // Client-side validation for all required fields (including dropdowns)
            const visitDate = document.getElementById('visitDate').value;
            const doctorId = document.getElementById('doctorId').value; // Get selected value from dropdown
            const admissionId = document.getElementById('admissionId').value;
            const patientId = document.getElementById('patientId').value;
            const description = document.getElementById('description').value;

            if (visitDate.trim() === '' || doctorId.trim() === '' || admissionId.trim() === '' || patientId.trim() === '' || description.trim() === '') {
                alert('Please fill in all required fields.');
                return false;
            }

            // Since Doctor ID is now a dropdown, you're implicitly validating its existence
            // by populating it from the database. No regex validation is needed here for format,
            // just the check for empty selection.

            return true; // Allow form submission if all validations pass
        }

        // Set default visit date and time to current when page loads
        window.onload = function() {
            var now = new Date();
            now.setMinutes(now.getMinutes() - now.getTimezoneOffset()); 
            var formattedDateTime = now.toISOString().slice(0, 16); 
            document.getElementById('visitDate').value = formattedDateTime;
        };
    </script>
</body>
</html>