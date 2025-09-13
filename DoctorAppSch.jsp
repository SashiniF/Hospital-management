<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
// Database configuration
final String DB_URL = "jdbc:mysql://localhost:3306/hospital";
final String DB_USER = "root";
final String DB_PASSWORD = "@Sashini123";

// Handle form submissions
if ("POST".equalsIgnoreCase(request.getMethod())) {
    // Save/Update logic
    String scheduleId = request.getParameter("scheduleId");
    String doctorId = request.getParameter("doctorId");
    String timeIn = request.getParameter("timeIn");
    String timeOut = request.getParameter("timeOut");
    String[] availableDays = request.getParameterValues("availableDays");
    String scheduleNotes = request.getParameter("scheduleNotes");

    if (availableDays == null || availableDays.length == 0) {
        request.setAttribute("error", "Please select at least one available day");
    } else {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // First save to ServiceSchedules
            String sql = "INSERT INTO ServiceSchedules (schedule_id, service_id, start_time, end_time, available_days) " +
                         "VALUES (?, 'DOCTOR', ?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE " +
                         "start_time = VALUES(start_time), " +
                         "end_time = VALUES(end_time), " +
                         "available_days = VALUES(available_days)";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, scheduleId);
            pstmt.setString(2, timeIn);
            pstmt.setString(3, timeOut);
            pstmt.setString(4, String.join(", ", availableDays));
            pstmt.executeUpdate();
            pstmt.close();

            // Then save to DoctorSchedules
            sql = "INSERT INTO DoctorSchedules (doctor_schedule_id, doctor_id, schedule_id, schedule_notes) " +
                  "VALUES (?, ?, ?, ?) " +
                  "ON DUPLICATE KEY UPDATE " +
                  "doctor_id = VALUES(doctor_id), " +
                  "schedule_notes = VALUES(schedule_notes)";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, scheduleId);
            pstmt.setString(2, doctorId);
            pstmt.setString(3, scheduleId);
            pstmt.setString(4, scheduleNotes);
            pstmt.executeUpdate();

            request.setAttribute("success", "Schedule saved successfully!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1452) {
                request.setAttribute("error", "Invalid Doctor ID - Doctor does not exist");
            } else {
                request.setAttribute("error", "Database error: " + e.getMessage());
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}

// Handle delete actions
if (request.getParameter("action") != null && request.getParameter("action").equals("delete")) {
    String scheduleId = request.getParameter("scheduleId");

    if (scheduleId == null || scheduleId.isEmpty()) {
        request.setAttribute("error", "Invalid Schedule ID");
    } else {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Delete from DoctorSchedules first
            String sql = "DELETE FROM DoctorSchedules WHERE doctor_schedule_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, scheduleId);
            pstmt.executeUpdate();
            pstmt.close();

            // Then delete from ServiceSchedules
            sql = "DELETE FROM ServiceSchedules WHERE schedule_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, scheduleId);
            int affectedRows = pstmt.executeUpdate();

            if (affectedRows == 0) {
                request.setAttribute("error", "Schedule not found");
            } else {
                request.setAttribute("success", "Schedule deleted successfully!");
            }

        } catch (Exception e) {
            request.setAttribute("error", "Delete error: " + e.getMessage());
        } finally {
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
            try { if (conn != null) conn.close(); } catch (SQLException e) {}
        }
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Appointment Scheduling</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-image: url('img/dapps.png'); /* Change this to your background image path */
            background-size: cover; /* Ensure the image covers the entire area */
            background-position: center; /* Center the image */
            background-repeat: no-repeat; /* Prevent repeating */
            height: 100vh; /* Full viewport height */
            margin: 0; /* Remove default margin */
            padding: 20px;
            line-height: 1.6;
            color: #34495e;
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 120px;
            height: auto;
            z-index: 100;
        }
        .home-button {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 40px;
            height: 40px;
            cursor: pointer;
            transition: transform 0.2s;
            z-index: 100;
        }
        .home-button:hover {
            transform: scale(1.1);
        }
        .doctor-schedule {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 1000px;
            margin: 80px auto 0;
        }
        .doctor-schedule h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 2rem;
            font-weight: 600;
        }
        .doctor-schedule h2 {
            color: #3498db;
            margin-top: 2rem;
            margin-bottom: 1.5rem;
            font-size: 1.4rem;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 0.5rem;
        }
        .doctor-schedule label {
            display: block;
            margin-bottom: 0.8rem;
            font-weight: 500;
        }
        .doctor-schedule input[type="text"],
        .doctor-schedule input[type="time"],
        .doctor-schedule select,
        .doctor-schedule textarea {
            width: 100%;
            padding: 0.8rem 1rem;
            margin-bottom: 1.2rem;
            border: 2px solid #bdc3c7;
            border-radius: 6px;
            transition: border-color 0.3s ease;
        }
        .doctor-schedule textarea {
            resize: vertical;
            min-height: 80px;
        }
        .doctor-schedule select {
            appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 1rem center;
            background-size: 1em;
        }
        .doctor-schedule input:focus,
        .doctor-schedule select:focus,
        .doctor-schedule textarea:focus {
            border-color: #3498db;
            outline: none;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }
        .doctor-schedule button {
            border: none;
            padding: 0.8rem 1.5rem;
            border-radius: 6px;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }
        button.save-btn {
            background-color: #27ae60;
            color: white;
            width: 100%;
            justify-content: center;
            font-weight: 500;
        }
        button.save-btn:hover {
            background-color: #219a52;
        }
        .action-buttons {
            display: flex;
            gap: 0.75rem;
            margin-top: 1.5rem;
        }
        .action-buttons button {
            padding: 0.8rem;
            font-weight: 500;
            color: white;
        }
        .action-buttons button:nth-child(1) { background-color: #2980b9; } /* Add New */
        .action-buttons button:nth-child(2) { background-color: #4CAF50; } /* Edit */
        .action-buttons button:nth-child(3) { background-color: #e74c3c; } /* Delete */
        .action-buttons button:nth-child(4) { background-color: #95a5a6; } /* Refresh */
        .action-buttons button:nth-child(5) { background-color: #7f8c8d; } /* Close */
        .action-buttons button:hover {
            filter: brightness(0.9);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1.5rem;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
        }
        th, td {
            padding: 0.75rem 1rem;
            text-align: left;
            border-bottom: 1px solid #ecf0f1;
        }
        th {
            background-color: #3498db;
            color: white;
            font-weight: 600;
        }
        tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        tr:hover {
            background-color: #f1f5f9;
        }
        .checkbox-group {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
            gap: 0.75rem;
            margin-bottom: 1.5rem;
        }
        .checkbox-group label {
            display: flex;
            align-items: center;
            margin: 0;
            padding: 0.5rem;
            background: #f8f9fa;
            border-radius: 4px;
            border: 1px solid #ecf0f1;
            transition: all 0.2s ease;
        }
        .checkbox-group label:hover {
            background: #f1f5f9;
            border-color: #3498db;
        }
        .checkbox-group input[type="checkbox"] {
            margin-right: 0.5rem;
            accent-color: #3498db;
        }
        .error-message {
            color: #e74c3c;
            background: #fdeded;
            padding: 1rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
            border: 1px solid #f5c6cb;
        }
        .success-message {
            color: #2ecc71;
            background: #e9f9e9;
            padding: 1rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
            border: 1px solid #a8e0a8;
        }
        .selected-row {
            background-color: #d3d3d3 !important;
        }
        .doctor-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        .doctor-name {
            font-weight: bold;
        }
        .specialization {
            color: #666;
            font-size: 0.9em;
        }
        @media (max-width: 768px) {
            .doctor-schedule {
                padding: 1.5rem;
                margin-top: 60px;
            }
            .logo {
                width: 100px;
                top: 15px;
                left: 15px;
            }
            .action-buttons {
                flex-direction: column;
            }
            .checkbox-group {
                grid-template-columns: 1fr 1fr;
            }
        }
    </style>
</head>
<body>
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="window.location.href='Home.jsp'">

    <div class="doctor-schedule">
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="success-message"><%= request.getAttribute("success") %></div>
        <% } %>

        <h1>DOCTOR APPOINTMENT SCHEDULING</h1>

        <form id="scheduleForm" method="post">
            <h2>Schedule Information</h2>
            <label for="scheduleId">Schedule ID:</label>
            <input type="text" id="scheduleId" name="scheduleId" required>

            <label for="doctorId">Doctor:</label>
            <select id="doctorId" name="doctorId" required>
                <option value="">-- Select Doctor --</option>
                <%
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                    stmt = conn.createStatement();
                    String sql = "SELECT id, firstName, lastName, specialization FROM Doctors ORDER BY lastName";
                    rs = stmt.executeQuery(sql);

                    while (rs.next()) {
                        String fullName = rs.getString("firstName") + " " + rs.getString("lastName") +
                                          " (" + rs.getString("specialization") + ")";
                %>
                        <option value="<%= rs.getString("id") %>"><%= fullName %></option>
                <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try { if (rs != null) rs.close(); } catch (SQLException e) {}
                    try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
                    try { if (conn != null) conn.close(); } catch (SQLException e) {}
                }
                %>
            </select>

            <label for="timeIn">Time In:</label>
            <input type="time" id="timeIn" name="timeIn" required>

            <label for="timeOut">Time Out:</label>
            <input type="time" id="timeOut" name="timeOut" required>

            <label>Available Days:</label>
            <div class="checkbox-group">
                <label><input type="checkbox" name="availableDays" value="Sun"> Sunday</label>
                <label><input type="checkbox" name="availableDays" value="Mon"> Monday</label>
                <label><input type="checkbox" name="availableDays" value="Tue"> Tuesday</label>
                <label><input type="checkbox" name="availableDays" value="Wed"> Wednesday</label>
                <label><input type="checkbox" name="availableDays" value="Thu"> Thursday</label>
                <label><input type="checkbox" name="availableDays" value="Fri"> Friday</label>
                <label><input type="checkbox" name="availableDays" value="Sat"> Saturday</label>
            </div>

            <label for="scheduleNotes">Schedule Notes:</label>
            <textarea id="scheduleNotes" name="scheduleNotes" placeholder="Enter any notes"></textarea>

            <button type="submit" class="save-btn">Save Schedule</button>
        </form>

        <h2>Current Schedules</h2>
        <table id="schedulesTable">
            <thead>
                <tr>
                    <th>Select</th>
                    <th>Schedule ID</th>
                    <th>Doctor</th>
                    <th>Time In</th>
                    <th>Time Out</th>
                    <th>Available Days</th>
                    <th>Notes</th>
                </tr>
            </thead>
            <tbody>
                <%
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

                    String sql = "SELECT ds.doctor_schedule_id, ds.doctor_id, " +
                               "d.firstName, d.lastName, d.specialization, " +
                               "DATE_FORMAT(ss.start_time, '%H:%i') AS start_time, " +
                               "DATE_FORMAT(ss.end_time, '%H:%i') AS end_time, " +
                               "ss.available_days, " +
                               "ds.schedule_notes " +
                               "FROM DoctorSchedules ds " +
                               "JOIN Doctors d ON ds.doctor_id = d.id " +
                               "JOIN ServiceSchedules ss ON ds.schedule_id = ss.schedule_id " +
                               "ORDER BY d.lastName, ss.start_time";

                    stmt = conn.createStatement();
                    rs = stmt.executeQuery(sql);

                    while (rs.next()) {
                        String doctorInfo = rs.getString("firstName") + " " + rs.getString("lastName") +
                                         " (" + rs.getString("specialization") + ")";
                %>
                <tr data-id="<%= rs.getString("doctor_schedule_id") %>" onclick="selectRow(this)">
                    <td><input type="radio" name="scheduleSelect" value="<%= rs.getString("doctor_schedule_id") %>" onclick="event.stopPropagation()"></td>
                    <td><%= rs.getString("doctor_schedule_id") %></td>
                    <td>
                        <div class="doctor-info">
                            <div>
                                <span class="doctor-name"><%= rs.getString("firstName") %> <%= rs.getString("lastName") %></span>
                                <div class="specialization"><%= rs.getString("specialization") %></div>
                            </div>
                        </div>
                    </td>
                    <td><%= rs.getString("start_time") %></td>
                    <td><%= rs.getString("end_time") %></td>
                    <td><%= rs.getString("available_days") %></td>
                    <td><%= rs.getString("schedule_notes") != null ? rs.getString("schedule_notes") : "" %></td>
                </tr>
                <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try { if (rs != null) rs.close(); } catch (SQLException e) {}
                    try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
                    try { if (conn != null) conn.close(); } catch (SQLException e) {}
                }
                %>
            </tbody>
        </table>

        <div class="action-buttons">
            <button onclick="addNewSchedule()">Add New</button>
            <button onclick="editSchedule()">Edit</button>
            <button onclick="deleteSelectedRow()">Delete</button>
            <button onclick="location.reload()">Refresh</button>
            <button onclick="window.location.href='Home.jsp'">Close</button>
        </div>
    </div>

    <form id="deleteForm" method="post" style="display: none;">
        <input type="hidden" id="selectedId" name="scheduleId">
        <input type="hidden" name="action" value="delete">
    </form>

    <script>
        function selectRow(row) {
            var rows = document.querySelectorAll("#schedulesTable tr");
            rows.forEach(function(r) {
                r.classList.remove("selected-row");
            });
            row.classList.add("selected-row");

            const radio = row.querySelector('input[type="radio"]');
            if (radio) {
                radio.checked = true;
                document.getElementById("selectedId").value = radio.value;
            }
        }

        function deleteSelectedRow() {
            var selectedId = document.getElementById("selectedId").value;
            if (!selectedId) {
                const selectedRadio = document.querySelector('input[name="scheduleSelect"]:checked');
                if (selectedRadio) {
                    selectedId = selectedRadio.value;
                }
            }

            if (selectedId) {
                if (confirm("Are you sure you want to delete this schedule?")) {
                    document.getElementById("selectedId").value = selectedId;
                    document.getElementById("deleteForm").submit();
                }
            } else {
                alert("Please select a schedule to delete.");
            }
        }

        function editSchedule() {
            const selectedRadio = document.querySelector('input[name="scheduleSelect"]:checked');
            if (selectedRadio) {
                const row = selectedRadio.closest('tr');
                document.getElementById('scheduleId').value = row.cells[1].textContent;

                const doctorName = row.querySelector('.doctor-name').textContent;
                const specialization = row.querySelector('.specialization').textContent;
                const doctorText = doctorName + " (" + specialization + ")";

                const doctorSelect = document.getElementById('doctorId');
                for (let i = 0; i < doctorSelect.options.length; i++) {
                    if (doctorSelect.options[i].text === doctorText) {
                        doctorSelect.selectedIndex = i;
                        break;
                    }
                }

                document.getElementById('timeIn').value = row.cells[3].textContent;
                document.getElementById('timeOut').value = row.cells[4].textContent;

                document.querySelectorAll('input[name="availableDays"]').forEach(checkbox => {
                    checkbox.checked = false;
                });

                const days = row.cells[5].textContent.split(', ');
                days.forEach(day => {
                    const checkbox = document.querySelector(`input[name="availableDays"][value="${day.trim()}"]`);
                    if (checkbox) checkbox.checked = true;
                });

                document.getElementById('scheduleNotes').value = row.cells[6].textContent;

                document.getElementById("selectedId").value = selectedRadio.value;
            } else {
                alert('Please select a schedule to edit.');
            }
        }

        function addNewSchedule() {
            document.getElementById('scheduleForm').reset();
            document.getElementById('scheduleId').focus();

            var rows = document.querySelectorAll("#schedulesTable tr");
            rows.forEach(function(r) {
                r.classList.remove("selected-row");
            });

            const radios = document.querySelectorAll('input[name="scheduleSelect"]');
            radios.forEach(radio => {
                radio.checked = false;
            });

            document.getElementById("selectedId").value = "";
        }

        document.getElementById('scheduleForm').addEventListener('submit', function(e) {
            const checkedDays = document.querySelectorAll('input[name="availableDays"]:checked');
            if (checkedDays.length === 0) {
                e.preventDefault();
                alert('Please select at least one available day.');
            }
        });

        setTimeout(() => {
            const messages = document.querySelectorAll('.error-message, .success-message');
            messages.forEach(msg => msg.style.display = 'none');
        }, 5000);

        document.querySelectorAll('input[name="scheduleSelect"]').forEach(radio => {
            radio.addEventListener('click', function() {
                document.getElementById("selectedId").value = this.value;
                selectRow(this.closest('tr'));
            });
        });
    </script>
</body>
</html>9