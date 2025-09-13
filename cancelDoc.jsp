<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cancel Doctor Appointment</title>
    <!-- Bootstrap Icons CDN -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            background-color: #f0f8ff;
        }
        .background-image {
            position: fixed;
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
        .appointment-details {
            background-color: rgba(255, 255, 255, 0.7);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            max-width: 800px;
            margin: 50px auto;
            overflow: auto; /* Changed overflow-y: auto to overflow: auto */
            max-height: 80vh; /* Added a maximum height */
            backdrop-filter: blur(3px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .appointment-details h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7);
        }
        .appointment-details label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
        }
        .appointment-details input[type="text"],
        .appointment-details input[type="date"],
        .appointment-details input[type="time"],
        .appointment-details select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            background-color: rgba(255, 255, 255, 0.8);
        }
        .appointment-details button {
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
        .appointment-details button:hover {
            background-color: #3498db;
        }
        .appointment-table {
            margin-top: 30px;
            width: 100%;
            border-collapse: collapse;
        }
        .appointment-table th, .appointment-table td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: center;
        }
        .appointment-table th {
            background-color: #2980b9;
            color: white;
        }
        .appointment-table tr:nth-child(even) {
            background-color: rgba(255, 255, 255, 0.5);
        }
        .appointment-table tr:nth-child(odd) {
            background-color: rgba(255, 255, 255, 0.8);
        }
        .success-message {
            color: green;
            font-weight: bold;
            text-align: center;
            margin: 10px 0;
        }
        .error-message {
            color: red;
            font-weight: bold;
            text-align: center;
            margin: 10px 0;
        }
        .action-buttons {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }
        .action-buttons button {
            width: 48%;
        }
        .delete-btn {
            background-color: #e74c3c !important;
        }
        .delete-btn:hover {
            background-color: #c0392b !important;
        }
        .selected-row {
            background-color: #f0dbff !important; /* Highlight color */
        }
    </style>
</head>
<body>
    <img src="img/hospital-bg.jpg" alt="Background" class="background-image">
    <img src="img/h.jpg" alt="Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="window.location.href='home.jsp'">

    <div class="appointment-details">
        <h1>Cancel Doctor Appointment</h1>

        <%
            // Database connection parameters
            String url = "jdbc:mysql://localhost:3306/hospital";
            String user = "root";
            String password = "@Sashini123";

            // Initialize variables
            String appointmentId = "";
            String patientId = "";
            String doctorId = "";
            String appointmentDate = "";
            String appointmentTime = "";
            String status = "";
            String errorMessage = null; // To store error messages
            String successMessage = null; // To store success messages

            // Handle form submission
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                appointmentId = request.getParameter("selectedAppointmentId"); // Get from hidden field

                if (appointmentId == null || appointmentId.isEmpty()) {
                    errorMessage = "Please select an appointment to cancel.";
                } else {
                    try (Connection conn = DriverManager.getConnection(url, user, password)) {
                        // Update appointment status to 'Cancelled'
                        String sql = "UPDATE Appointments SET status = 'Cancelled' WHERE appointment_id = ?";
                        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                            pstmt.setString(1, appointmentId);
                            int rowsAffected = pstmt.executeUpdate();

                            if (rowsAffected > 0) {
                                successMessage = "Appointment successfully cancelled!";
                            } else {
                                errorMessage = "Failed to cancel appointment. Appointment ID not found.";
                            }
                        }
                    } catch (SQLException e) {
                        errorMessage = "Database error: " + e.getMessage();
                    }
                }
            }
        %>

        <form method="post" id="cancelForm">
            <input type="hidden" id="selectedAppointmentId" name="selectedAppointmentId" value="">

            <label for="patientId">Patient ID:</label>
            <input type="text" id="patientId" name="patientId" value="<%= patientId %>" readonly>

            <label for="doctorId">Doctor ID:</label>
            <input type="text" id="doctorId" name="doctorId" value="<%= doctorId %>" readonly>

            <label for="appointmentDate">Appointment Date:</label>
            <input type="text" id="appointmentDate" name="appointmentDate" value="<%= appointmentDate %>" readonly>

            <label for="appointmentTime">Appointment Time:</label>
            <input type="text" id="appointmentTime" name="appointmentTime" value="<%= appointmentTime %>" readonly>

            <div class="action-buttons">
                <button type="submit" class="delete-btn" onclick="return validateSelection()"><i class="bi bi-trash-fill"></i> Cancel Appointment</button>
                <button type="button" onclick="window.location.href='searchAppointment.jsp'"><i class="bi bi-search"></i> Search</button>
            </div>
        </form>

        <% if (errorMessage != null) { %>
            <p class='error-message'><%= errorMessage %></p>
        <% } %>

        <% if (successMessage != null) { %>
            <p class='success-message'><%= successMessage %></p>
        <% } %>

        <h2>Scheduled Appointments</h2>
        <table class="appointment-table">
            <thead>
                <tr>
                    <th>Select</th>
                    <th>Appointment ID</th>
                    <th>Patient ID</th>
                    <th>Doctor ID</th>
                    <th>Date</th>
                    <th>Time</th>
                    <th>Status</th>
                </tr>
            </thead>
            <tbody>
                <%
                    try (Connection conn = DriverManager.getConnection(url, user, password)) {
                        String sql = "SELECT * FROM Appointments WHERE status = 'Scheduled' ORDER BY appointment_date, appointment_time";
                        try (Statement stmt = conn.createStatement();
                             ResultSet rs = stmt.executeQuery(sql)) {
                            while (rs.next()) {
                                String apptId = rs.getString("appointment_id");
                                String patId = rs.getString("patient_id");
                                String docId = rs.getString("doctor_id");
                                String date = rs.getString("appointment_date");
                                String time = rs.getString("appointment_time");
                                String stat = rs.getString("status");

                                out.println("<tr id='row-" + apptId + "'>");  // Add an ID to the row
                                out.println("<td><input type='radio' name='appointmentSelector' value='" + apptId + "' onclick=\"selectAppointment('" + apptId + "','" + patId + "','" + docId + "','" + date + "','" + time + "')\"></td>");
                                out.println("<td>" + apptId + "</td>");
                                out.println("<td>" + patId + "</td>");
                                out.println("<td>" + docId + "</td>");
                                out.println("<td>" + date + "</td>");
                                out.println("<td>" + time + "</td>");
                                out.println("<td>" + stat + "</td>");
                                out.println("</tr>");
                            }
                        }
                    } catch (SQLException e) {
                        out.println("<tr><td colspan='7' class='error-message'>Error loading appointments: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </div>

    <script>
        let lastSelectedRow = null; // Track the last selected row

        function selectAppointment(appointmentId, patientId, doctorId, appointmentDate, appointmentTime) {
            document.getElementById("selectedAppointmentId").value = appointmentId;
            document.getElementById("patientId").value = patientId;
            document.getElementById("doctorId").value = doctorId;
            document.getElementById("appointmentDate").value = appointmentDate;
            document.getElementById("appointmentTime").value = appointmentTime;

            // Remove highlight from the previously selected row
            if (lastSelectedRow) {
                lastSelectedRow.classList.remove("selected-row");
            }

            // Highlight the currently selected row
            let selectedRow = document.getElementById("row-" + appointmentId);
            if (selectedRow) {
                selectedRow.classList.add("selected-row");
                lastSelectedRow = selectedRow; // Update the last selected row
            }
        }

        function validateSelection() {
            if (document.getElementById("selectedAppointmentId").value === "") {
                alert("Please select an appointment to cancel.");
                return false; // Prevent form submission
            }
            return true; // Allow form submission
        }
    </script>
</body>
</html>