<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Doctor Appointment</title>
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
        .appointment-details {
            background-color: rgba(255, 255, 255, 0.7);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            max-width: 800px;
            margin: 50px auto;
            overflow-y: auto;
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
    </style>
</head>
<body>
    <img src="img/hospital-bg.jpg" alt="Background" class="background-image">
    <img src="img/h.jpg" alt="Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="window.location.href='home.jsp'">

    <div class="appointment-details">
        <h1>Add Doctor Appointment</h1>

        <%
            String url = "jdbc:mysql://localhost:3306/hospital";
            String user = "root";
            String password = "@Sashini123";

            String patientId = "";
            String doctorId = ""; // To store the selected Doctor ID
            String appointmentDate = "";
            String appointmentTime = "";

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                patientId = request.getParameter("patientId");
                doctorId = request.getParameter("doctorId"); // Get Doctor ID directly from the select

                appointmentDate = request.getParameter("appointmentDate");
                appointmentTime = request.getParameter("appointmentTime");

                try (Connection conn = DriverManager.getConnection(url, user, password)) {
                    // Now, insert the appointment using the Doctor ID
                    String sql = "INSERT INTO Appointments (patient_id, doctor_id, appointment_date, appointment_time) VALUES (?, ?, ?, ?)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                        pstmt.setString(1, patientId);
                        pstmt.setString(2, doctorId);
                        pstmt.setString(3, appointmentDate);
                        pstmt.setString(4, appointmentTime);

                        int rowsInserted = pstmt.executeUpdate();
                        if (rowsInserted > 0) {
                            out.println("<p class='success-message'>Appointment successfully added!</p>");
                        } else {
                            out.println("<p class='error-message'>Failed to add appointment.</p>");
                        }
                    }
                } catch (SQLException e) {
                    out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                }
            }
        %>

        <form method="post">
            <label for="patientId">Patient ID:</label>
            <select id="patientId" name="patientId" required>
                <option value="">Select Patient</option>
                <%
                    try (Connection conn = DriverManager.getConnection(url, user, password)) {
                        String sql = "SELECT patient_id FROM OutPatients";
                         System.out.println("SQL Query: " + sql);
                        try (Statement stmt = conn.createStatement();
                             ResultSet rs = stmt.executeQuery(sql)) {
                            while (rs.next()) {
                                String patient_id = rs.getString("patient_id");
                                out.println("<option value='" + patient_id + "'>" + patient_id + "</option>");
                            }
                        }
                    } catch (SQLException e) {
                        out.println("<option value=''>Error loading patients: " + e.getMessage() + "</option>");
                         e.printStackTrace();
                    }
                %>
            </select>

            <!-- Doctor ID Input Field -->
            <label for="doctorId">Doctor ID (D00x):</label>
            <input type="text" id="doctorId" name="doctorId" pattern="D00\d" title="Please enter Doctor ID in D00x format (e.g., D001)" required>


            <label for="appointmentDate">Appointment Date:</label>
            <input type="date" id="appointmentDate" name="appointmentDate" required>

            <label for="appointmentTime">Appointment Time:</label>
            <input type="time" id="appointmentTime" name="appointmentTime" required>

            <button type="submit">Save Appointment</button>
        </form>

        <h2>All Appointments</h2>
        <table class="appointment-table">
            <thead>
                <tr>
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
                    url = "jdbc:mysql://localhost:3306/hospital";
                    user = "root";
                    password = "@Sashini123";

                    try (Connection conn = DriverManager.getConnection(url, user, password)) {
                        String sql = "SELECT * FROM Appointments ORDER BY appointment_date DESC, appointment_time DESC";
                        try (Statement stmt = conn.createStatement();
                             ResultSet rs = stmt.executeQuery(sql)) {

                            while (rs.next()) {
                                out.println("<tr>");
                                out.println("<td>" + rs.getString("appointment_id") + "</td>");
                                out.println("<td>" + rs.getString("patient_id") + "</td>");
                                out.println("<td>" + rs.getString("doctor_id") + "</td>");
                                out.println("<td>" + rs.getString("appointment_date") + "</td>");
                                out.println("<td>" + rs.getString("appointment_time") + "</td>");
                                out.println("<td>" + (rs.getString("status") != null ? rs.getString("status") : "Scheduled") + "</td>");
                                out.println("</tr>");
                            }
                        }
                    } catch (SQLException e) {
                        out.println("<tr><td colspan='6' class='error-message'>Error loading appointments: " + e.getMessage() + "</td></tr>");
                    }
                %>
            </tbody>
        </table>
    </div>
</body>
</html>