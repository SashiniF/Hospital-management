<%@ page import="java.sql.*, java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
final String DB_URL = "jdbc:mysql://localhost:3306/hospital";
final String DB_USER = "root";
final String DB_PASSWORD = "@Sashini123";

// List to hold services
List<Map<String, String>> servicesList = new ArrayList<>();
String newScheduleId = "SCH001"; // Default value

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

    // Fetch existing services
    String sqlServices = "SELECT Channel_Service_ID, Channel_Service FROM MedicalServices";
    pstmt = conn.prepareStatement(sqlServices);
    ResultSet rsServices = pstmt.executeQuery();

    while (rsServices.next()) {
        Map<String, String> service = new HashMap<>();
        service.put("id", rsServices.getString("Channel_Service_ID"));
        service.put("name", rsServices.getString("Channel_Service"));
        servicesList.add(service);
    }

    // Fetch the maximum existing schedule ID
    String sqlSchedules = "SELECT MAX(schedule_id) AS max_id FROM ServiceSchedules";
    pstmt = conn.prepareStatement(sqlSchedules);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        String maxId = rs.getString("max_id");
        if (maxId != null) {
            // Increment the ID (assuming IDs follow a pattern like SCH001, SCH002, ...)
            int nextId = Integer.parseInt(maxId.replace("SCH", "")) + 1;
            newScheduleId = "SCH" + String.format("%03d", nextId);
        }
    }
} catch (SQLException e) {
    e.printStackTrace();
} finally {
    try { if (rs != null) rs.close(); } catch (SQLException e) {}
    try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
    try { if (conn != null) conn.close(); } catch (SQLException e) {}
}

// Handle form submissions
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String scheduleId = newScheduleId; // Using the generated ID
    String serviceId = request.getParameter("serviceId");
    String startTime = request.getParameter("serviceStarts");
    String endTime = request.getParameter("serviceEnds");
    String[] availableDays = request.getParameterValues("availableDays");
    
    if (availableDays == null || availableDays.length == 0) {
        request.setAttribute("error", "Please select at least one available day");
    } else {
        Connection conn2 = null;
        PreparedStatement pstmt2 = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn2 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String sql = "INSERT INTO ServiceSchedules (schedule_id, service_id, start_time, end_time, available_days) " +
                         "VALUES (?, ?, ?, ?, ?) " +
                         "ON DUPLICATE KEY UPDATE " +
                         "service_id = VALUES(service_id), " +
                         "start_time = VALUES(start_time), " +
                         "end_time = VALUES(end_time), " +
                         "available_days = VALUES(available_days)";

            pstmt2 = conn2.prepareStatement(sql);
            pstmt2.setString(1, scheduleId);
            pstmt2.setString(2, serviceId);
            pstmt2.setString(3, startTime);
            pstmt2.setString(4, endTime);
            pstmt2.setString(5, String.join(", ", availableDays));
            pstmt2.executeUpdate();

            request.setAttribute("success", "Schedule saved successfully!");

        } catch (SQLException e) {
            if (e.getErrorCode() == 1452) {
                request.setAttribute("error", "Invalid Service ID - Service does not exist");
            } else {
                request.setAttribute("error", "Database error: " + e.getMessage());
            }
        } catch (Exception e) {
            request.setAttribute("error", "Error: " + e.getMessage());
        } finally {
            try { if (pstmt2 != null) pstmt2.close(); } catch (SQLException e) {}
            try { if (conn2 != null) conn2.close(); } catch (SQLException e) {}
        }
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Services Schedule Management</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-image: url('img/hospital.png');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            padding: 20px;
            position: relative;
            line-height: 1.6;
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
        .services-details {
            background-color: rgba(255, 255, 255, 0.8);
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.05);
            max-width: 1000px;
            margin: 80px auto 0;
        }
        /* Additional styles omitted for brevity */
    </style>
</head>
<body>
    <div class="services-details">
        <h1>Hospital Services Details</h1>
        
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="success-message"><%= request.getAttribute("success") %></div>
        <% } %>
        
        <form id="serviceForm" method="post">
            <h2>Schedule Information</h2>
            <label for="scheduleId">Schedule ID:</label>
            <input type="text" id="scheduleId" name="scheduleId" value="<%= newScheduleId %>" readonly>

            <label for="serviceId">Service:</label>
            <select id="serviceId" name="serviceId" required>
                <option value="">Select a Service</option>
                <% for (Map<String, String> service : servicesList) { %>
                    <option value="<%= service.get("id") %>"><%= service.get("id") + " - " + service.get("name") %></option>
                <% } %>
            </select>

            <label for="serviceStarts">Start Time:</label>
            <input type="time" id="serviceStarts" name="serviceStarts" required>

            <label for="serviceEnds">End Time:</label>
            <input type="time" id="serviceEnds" name="serviceEnds" required>

            <label>Available Days:</label>
            <div class="checkbox-group">
                <label><input type="checkbox" name="availableDays" value="Monday"> Monday</label>
                <label><input type="checkbox" name="availableDays" value="Tuesday"> Tuesday</label>
                <label><input type="checkbox" name="availableDays" value="Wednesday"> Wednesday</label>
                <label><input type="checkbox" name="availableDays" value="Thursday"> Thursday</label>
                <label><input type="checkbox" name="availableDays" value="Friday"> Friday</label>
                <label><input type="checkbox" name="availableDays" value="Saturday"> Saturday</label>
                <label><input type="checkbox" name="availableDays" value="Sunday"> Sunday</label>
            </div>
            
            <button type="submit" class="save-btn">Save Schedule</button>
        </form>

        <h2>Existing Schedules</h2>
        <table id="servicesTable">
            <thead>
                <tr>
                    <th>Select</th>
                    <th>Schedule ID</th>
                    <th>Service ID</th>
                    <th>Start Time</th>
                    <th>End Time</th>
                    <th>Available Days</th>
                </tr>
            </thead>
            <tbody>
                <%
                Connection conn4 = null;
                Statement stmt = null;
                ResultSet rs2 = null;

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn4 = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                    stmt = conn4.createStatement();
                    String sql = "SELECT schedule_id, service_id, " +
                                 "DATE_FORMAT(start_time, '%H:%i') AS start_time, " +
                                 "DATE_FORMAT(end_time, '%H:%i') AS end_time, " +
                                 "available_days " +
                                 "FROM ServiceSchedules " +
                                 "ORDER BY start_time";
                    rs2 = stmt.executeQuery(sql);
                    
                    while (rs2.next()) {
                %>
                <tr data-id="<%= rs2.getString("schedule_id") %>" onclick="selectRow(this)">
                    <td><input type="radio" name="serviceSelect" value="<%= rs2.getString("schedule_id") %>" onclick="event.stopPropagation()"></td>
                    <td><%= rs2.getString("schedule_id") %></td>
                    <td><%= rs2.getString("service_id") %></td>
                    <td><%= rs2.getString("start_time") %></td>
                    <td><%= rs2.getString("end_time") %></td>
                    <td><%= rs2.getString("available_days") %></td>
                </tr>
                <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                } finally {
                    try { if (rs2 != null) rs2.close(); } catch (SQLException e) {}
                    try { if (stmt != null) stmt.close(); } catch (SQLException e) {}
                    try { if (conn4 != null) conn4.close(); } catch (SQLException e) {}
                }
                %>
            </tbody>
        </table>
        
        <div class="action-buttons">
            <button onclick="addNewService()">Add New</button>
            <button onclick="editService()">Edit</button>
            <button onclick="deleteSelectedRow()">Delete</button>
            <button onclick="location.reload()">Refresh</button>
            <button onclick="window.location.href='Home.jsp'">Close</button>
        </div>

        <form id="deleteForm" method="post" style="display: none;">
            <input type="hidden" id="selectedId" name="scheduleId">
            <input type="hidden" name="action" value="delete">
        </form>
    </div>

    <script>
        function selectRow(row) {
            var rows = document.querySelectorAll("#servicesTable tr");
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
                const selectedRadio = document.querySelector('input[name="serviceSelect"]:checked');
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

        function editService() {
            const selectedRadio = document.querySelector('input[name="serviceSelect"]:checked');
            if (selectedRadio) {
                const row = selectedRadio.closest('tr');
                document.getElementById('scheduleId').value = row.cells[1].textContent;
                document.getElementById('serviceId').value = row.cells[2].textContent;
                document.getElementById('serviceStarts').value = row.cells[3].textContent;
                document.getElementById('serviceEnds').value = row.cells[4].textContent;

                document.querySelectorAll('input[name="availableDays"]').forEach(checkbox => {
                    checkbox.checked = false;
                });

                const days = row.cells[5].textContent.split(', ');
                days.forEach(day => {
                    const checkbox = document.querySelector(`input[name="availableDays"][value="${day.trim()}"]`);
                    if (checkbox) checkbox.checked = true;
                });

                document.getElementById("selectedId").value = selectedRadio.value;
            } else {
                alert('Please select a schedule to edit.');
            }
        }

        function addNewService() {
            document.getElementById('serviceForm').reset();
            document.getElementById('scheduleId').value = "<%= newScheduleId %>"; // Reset to new ID
            document.getElementById('scheduleId').focus();

            var rows = document.querySelectorAll("#servicesTable tr");
            rows.forEach(function(r) {
                r.classList.remove("selected-row");
            });

            const radios = document.querySelectorAll('input[name="serviceSelect"]');
            radios.forEach(radio => {
                radio.checked = false;
            });

            document.getElementById("selectedId").value = "";
        }

        document.getElementById('serviceForm').addEventListener('submit', function(e) {
            const checkedDays = document.querySelectorAll('input[name="availableDays"]:checked');
            if (checkedDays.length === 0) {
                e.preventDefault();
                alert('Please select at least one available day.');
            }
        });
    </script>
</body>
</html>