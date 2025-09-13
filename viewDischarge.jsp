<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Discharge Details</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
            position: relative;
        }
        h1 {
            text-align: center;
            color: #333;
            margin-top: 60px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #007bff;
            color: white;
        }
        tr:hover {
            background-color: #f1f1f1;
        }
        .action-buttons {
            position: absolute;
            top: 20px;
            right: 20px;
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .home-btn {
            width: 40px;
            height: 40px;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .home-btn:hover {
            transform: scale(1.1);
        }
        .delete-btn {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            color: white;
            font-size: 14px;
            background-color: #f44336;
        }
        .delete-btn:hover {
            background-color: #e53935;
        }
        .selected {
            background-color: #d1e7ff;
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 100px;
            height: auto;
        }
        .no-records {
            text-align: center;
            padding: 20px;
            font-style: italic;
            color: #666;
        }
    </style>
    <script>
        function goToHome() {
            window.location.href = "Home.jsp";
        }

        function confirmDelete() {
            const selectedId = getSelectedDischargeId();
            if (selectedId) {
                if (confirm("Are you sure you want to delete the selected discharge?")) {
                    window.location.href = "viewDischarge.jsp?deleteId=" + selectedId;
                }
            } else {
                alert("Please select a discharge to delete.");
            }
        }

        function getSelectedDischargeId() {
            const selectedRow = document.querySelector('input[name="dischargeCheckbox"]:checked');
            return selectedRow ? selectedRow.value : null;
        }

        function highlightRow(checkbox) {
            const row = checkbox.closest('tr');
            if (checkbox.checked) {
                row.classList.add('selected');
            } else {
                row.classList.remove('selected');
            }
        }
    </script>
</head>
<body>
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <h1>Discharge Details</h1>

    <div class="action-buttons">
        <img src="img/home.png" alt="Home" class="home-btn" onclick="goToHome()">
        <button class="delete-btn" onclick="confirmDelete()">Delete</button>
    </div>

    <%
        String url = "jdbc:mysql://localhost:3306/hospital";
        String user = "root";
        String password = "@Sashini123";

        Connection conn = null;
        PreparedStatement pstmt = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, password);

            // Handle delete request
            String deleteId = request.getParameter("deleteId");
            if (deleteId != null && !deleteId.isEmpty()) {
                String deleteSql = "DELETE FROM Discharges WHERE discharge_id = ?";
                pstmt = conn.prepareStatement(deleteSql);
                pstmt.setString(1, deleteId);
                int rowsDeleted = pstmt.executeUpdate();
                if (rowsDeleted > 0) {
                    out.println("<p style='color:green; text-align:center;'>Discharge deleted successfully!</p>");
                } else {
                    out.println("<p style='color:red; text-align:center;'>Failed to delete discharge.</p>");
                }
            }

            // Create a statement to execute the query
            stmt = conn.createStatement();

            // SQL query to fetch all discharges
            String sql = "SELECT discharge_id, admission_id, discharge_date, discharge_time, status, notes, created_at " +
                         "FROM Discharges " +
                         "ORDER BY discharge_id";
            rs = stmt.executeQuery(sql);
            
            if (!rs.isBeforeFirst()) {
                out.println("<p class='no-records'>No discharge records found. <a href='AddDischarge.jsp'>Add a new discharge</a></p>");
            } else {
    %>

    <table>
        <thead>
            <tr>
                <th>Select</th>
                <th>Discharge ID</th>
                <th>Admission ID</th>
                <th>Discharge Date</th>
                <th>Discharge Time</th>
                <th>Status</th>
                <th>Notes</th>
                <th>Created At</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (rs.next()) {
                    String dischargeId = rs.getString("discharge_id");
                    String admissionId = rs.getString("admission_id");
                    Date dischargeDate = rs.getDate("discharge_date");
                    Time dischargeTime = rs.getTime("discharge_time");
                    String status = rs.getString("status");
                    String notes = rs.getString("notes");
                    Timestamp createdAt = rs.getTimestamp("created_at");
            %>
            <tr>
                <td>
                    <input type="radio" name="dischargeCheckbox" value="<%= dischargeId %>" onclick="highlightRow(this)">
                </td>
                <td><%= dischargeId %></td>
                <td><%= admissionId %></td>
                <td><%= dischargeDate %></td>
                <td><%= dischargeTime %></td>
                <td><%= status %></td>
                <td><%= (notes != null && !notes.isEmpty()) ? notes : "-" %></td>
                <td><%= createdAt %></td>
            </tr>
            <%
                }
            %>
        </tbody>
    </table>

    <%
            }
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red; text-align:center;'>An error occurred: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    %>
</body>
</html>