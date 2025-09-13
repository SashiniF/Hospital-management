<%@ page import="java.sql.*, java.time.LocalDate" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Doctor Appointments</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 10px;
            background-color: #f5f5f5;
            position: relative;
        }
        .logo {
            position: absolute;
            top: 10px;
            left: 10px;
            width: 100px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            background-color: white;
            padding: 10px;
            box-shadow: 0 0 5px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
            font-size: 1.5em;
            margin-bottom: 10px;
        }
        .filter-section {
            display: flex;
            flex-wrap: wrap;
            gap: 5px;
            margin-bottom: 10px;
            align-items: center;
            padding: 5px;
            background-color: #f0f0f0;
            border-radius: 3px;
        }
        .filter-section label {
            font-size: 0.8em;
            font-weight: bold;
        }
        .filter-section input, .filter-section select {
            padding: 3px;
            border: 1px solid #ddd;
            border-radius: 3px;
            font-size: 0.8em;
        }
        .filter-section button {
            padding: 3px 8px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 0.8em;
        }
        .appointments-list {
            margin-top: 10px;
        }
        .appointment-card {
            border: 1px solid #ddd;
            padding: 8px;
            margin-bottom: 8px;
            border-radius: 3px;
            background-color: white;
        }
        .appointment-card h3 {
            margin-top: 0;
            color: #2c3e50;
            font-size: 1em;
            border-bottom: 1px solid #eee;
            padding-bottom: 3px;
        }
        .appointment-card ul {
            list-style-type: none;
            padding-left: 0;
        }
        .appointment-card li {
            margin-bottom: 3px;
            font-size: 0.8em;
        }
        .calendar-container {
            display: flex;
            margin-top: 15px;
            gap: 10px;
        }
        .calendar {
            flex: 1;
            max-width: 200px;
        }
        .calendar h2 {
            color: #333;
            border-bottom: 1px solid #333;
            padding-bottom: 3px;
            font-size: 0.9em;
        }
        .calendar-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.7em;
        }
        .calendar-table th, .calendar-table td {
            border: 1px solid #ddd;
            padding: 3px;
            text-align: center;
        }
        .calendar-table th {
            background-color: #f2f2f2;
            font-size: 0.7em;
        }
        .search-section {
            flex: 2;
            padding: 8px;
            background-color: #f0f0f0;
            border-radius: 3px;
        }
        .search-section h2 {
            margin-top: 0;
            font-size: 0.9em;
        }
        .search-section input[type="text"] {
            width: 70%;
            padding: 3px;
            font-size: 0.8em;
        }
        .action-buttons {
            margin-top: 10px;
            display: flex;
            gap: 5px;
        }
        .action-buttons button {
            padding: 5px 10px;
            border: none;
            border-radius: 3px;
            cursor: pointer;
            font-size: 0.8em;
        }
        .refresh-btn {
            background-color: #2196F3;
            color: white;
        }
        .refresh-btn:hover {
            background-color: #0b7dda;
        }
        .close-btn {
            background-color: #f44336;
            color: white;
        }
        .close-btn:hover {
            background-color: #da190b;
        }
        .highlighted {
            background-color: yellow;
        }
    </style>
    <script>
        function refreshAppointments() {
            window.location.reload();
        }

        function searchAppointments() {
            var searchType = document.querySelector('input[name="searchType"]:checked').value;
            var searchQuery = document.querySelector('input[name="searchQuery"]').value.trim();

            var tableRows = document.querySelectorAll('.appointments-list tbody tr');
            tableRows.forEach(function(row) {
                row.classList.remove('highlighted');
            });

            if (searchQuery !== '') {
                tableRows.forEach(function(row) {
                    var appointmentId = row.cells[0].textContent.trim();

                    if (searchType === 'appointment_id' && appointmentId === searchQuery) {
                        row.classList.add('highlighted');
                    }
                });
            }
        }
    </script>
</head>
<body>
    <img src="img/h.jpg" alt="Logo" class="logo">
    <div class="container">
        <h1>VIEW DOCOTOR APPOINTMENTS</h1>
        
        <div class="filter-section">
            <label>From:</label>
            <input type="date" name="fromDate">
            
            <label>To:</label>
            <input type="date" name="toDate">
            
            <label>Doctor ID:</label>
            <select name="doctorId">
                <%
                    String url = "jdbc:mysql://localhost:3306/hospital";
                    String user = "root";
                    String password = "@Sashini123";

                    try (Connection conn = DriverManager.getConnection(url, user, password)) {
                        String sql = "SELECT DISTINCT doctor_id FROM Appointments";
                        try (Statement stmt = conn.createStatement();
                             ResultSet rs = stmt.executeQuery(sql)) {
                            while (rs.next()) {
                                String docId = rs.getString("doctor_id");
                                out.println("<option value='" + docId + "'>" + docId + "</option>");
                            }
                        }
                    } catch (SQLException e) {
                        out.println("<option value=''>Error</option>");
                    }
                %>
            </select>
            
            <button type="button">Display</button>
        </div>
        
        <div class="appointments-list">
            <table style="width: 100%; border-collapse: collapse; margin-top: 10px;">
                <thead>
                    <tr style="background-color: #f2f2f2;">
                        <th style="padding: 8px; border: 1px solid #ddd; text-align: left;">Appointment ID</th>
                        <th style="padding: 8px; border: 1px solid #ddd; text-align: left;">Patient ID</th>
                        <th style="padding: 8px; border: 1px solid #ddd; text-align: left;">Doctor ID</th>
                        <th style="padding: 8px; border: 1px solid #ddd; text-align: left;">Date</th>
                        <th style="padding: 8px; border: 1px solid #ddd; text-align: left;">Time</th>
                        <th style="padding: 8px; border: 1px solid #ddd; text-align: left;">Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        try (Connection conn = DriverManager.getConnection(url, user, password)) {
                            String sql = "SELECT * FROM Appointments ORDER BY appointment_date, appointment_time";
                            try (Statement stmt = conn.createStatement();
                                 ResultSet rs = stmt.executeQuery(sql)) {
                                while (rs.next()) {
                                    out.println("<tr>");
                                    out.println("<td style='padding: 8px; border: 1px solid #ddd;'>" + rs.getString("appointment_id") + "</td>");
                                    out.println("<td style='padding: 8px; border: 1px solid #ddd;'>" + rs.getString("patient_id") + "</td>");
                                    out.println("<td style='padding: 8px; border: 1px solid #ddd;'>" + rs.getString("doctor_id") + "</td>");
                                    out.println("<td style='padding: 8px; border: 1px solid #ddd;'>" + rs.getString("appointment_date") + "</td>");
                                    out.println("<td style='padding: 8px; border: 1px solid #ddd;'>" + rs.getString("appointment_time") + "</td>");
                                    out.println("<td style='padding: 8px; border: 1px solid #ddd;'>" + rs.getString("status") + "</td>");
                                    out.println("</tr>");
                                }
                            }
                        } catch (SQLException e) {
                            out.println("<tr><td colspan='6'>Error: " + e.getMessage() + "</td></tr>");
                        }
                    %>
                </tbody>
            </table>
        </div>
        
        <div class="calendar-container">
            <div class="calendar">
                <%
                    LocalDate today = LocalDate.now();
                    int currentMonth = today.getMonthValue();
                    int currentYear = today.getYear();
                    String[] monthNames = {
                        "January", "February", "March", "April", "May", "June",
                        "July", "August", "September", "October", "November", "December"
                    };

                    LocalDate firstOfMonth = LocalDate.of(currentYear, currentMonth, 1);
                    int daysInMonth = firstOfMonth.lengthOfMonth();
                    int firstDayOfWeek = firstOfMonth.getDayOfWeek().getValue();
                %>

                <h2><%= monthNames[currentMonth - 1] + " " + currentYear %></h2>
                <table class="calendar-table">
                    <thead>
                        <tr>
                            <th>S</th><th>M</th><th>T</th><th>W</th><th>T</th><th>F</th><th>S</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            int day = 1;
                            for (int i = 0; i < 6; i++) {
                                out.print("<tr>");
                                for (int j = 1; j <= 7; j++) {
                                    if (i == 0 && j < firstDayOfWeek) {
                                        out.print("<td></td>");
                                    } else if (day > daysInMonth) {
                                        out.print("<td></td>");
                                    } else {
                                        out.print("<td>" + day + "</td>");
                                        day++;
                                    }
                                }
                                out.print("</tr>");
                            }
                        %>
                    </tbody>
                </table>
            </div>
            
            <div class="search-section">
                <h2>Search</h2>
                <div>
                    <input type="radio" id="searchAppointmentId" name="searchType" value="appointment_id" checked>
                    <label for="searchAppointmentId">Appointment_ID</label>
                    
                    <input type="radio" id="searchText" name="searchType" value="text">
                    <label for="searchText">Text</label>
                    
                    <input type="text" name="searchQuery" placeholder="Search..." style="margin-left: 5px;">
                    <button type="button" onclick="searchAppointments()">Search</button>
                </div>
            </div>
        </div>
        
        <div class="action-buttons">
            <button class="refresh-btn" onclick="refreshAppointments()">Refresh</button>
            <button class="close-btn" onclick="window.close()">Close</button>
        </div>
    </div>
</body>
</html>