<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medical Services</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #333;
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
    </style>
    <script>
        function goToHome() {
            window.location.href = "Home.jsp";
        }

        function confirmDelete() {
            const selectedId = getSelectedServiceId();
            if (selectedId) {
                if (confirm("Are you sure you want to delete the selected service?")) {
                    window.location.href = "?deleteId=" + selectedId;
                }
            } else {
                alert("Please select a service to delete.");
            }
        }

        function getSelectedServiceId() {
            const selectedRow = document.querySelector('input[name="serviceCheckbox"]:checked');
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
    <h1>Medical Services</h1>

    <div class="action-buttons">
        <img src="img/home.png" alt="Home" class="home-btn" onclick="goToHome()">
        <button class="delete-btn" onclick="confirmDelete()">Delete</button>
    </div>

    <%
        String url = "jdbc:mysql://localhost:3306/hospital"; // Database URL
        String user = "root"; // Database username
        String password = "@Sashini123"; // Database password

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, password);

            // Handle delete request
            String deleteId = request.getParameter("deleteId");
            if (deleteId != null) {
                String deleteSql = "DELETE FROM MedicalServices WHERE Channel_Service_ID = ?";
                PreparedStatement pstmt = conn.prepareStatement(deleteSql);
                pstmt.setString(1, deleteId);
                pstmt.executeUpdate();
                out.println("<p style='color:green;'>Service deleted successfully!</p>");
            }

            // Create a statement to execute the query
            stmt = conn.createStatement();

            // SQL query to fetch all medical services
            String sql = "SELECT * FROM MedicalServices";
            rs = stmt.executeQuery(sql);
    %>

    <table>
        <thead>
            <tr>
                <th>Select</th>
                <th>Service ID</th>
                <th>Service Name</th>
                <th>Duration (min)</th>
                <th>Charge</th>
                <th>Notes</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (rs.next()) {
                    String serviceId = rs.getString("Channel_Service_ID");
                    String serviceName = rs.getString("Channel_Service");
                    int duration = rs.getInt("Duration_Of_Service");
                    double charge = rs.getDouble("Charge_For_Service");
                    String notes = rs.getString("Service_Notes");
            %>
            <tr>
                <td>
                    <input type="radio" name="serviceCheckbox" value="<%= serviceId %>" onclick="highlightRow(this)">
                </td>
                <td><%= serviceId %></td>
                <td><%= serviceName %></td>
                <td><%= duration %></td>
                <td>$<%= charge %></td>
                <td><%= notes %></td>
            </tr>
            <%
                }
            %>
        </tbody>
    </table>

    <%
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>An error occurred: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    %>
</body>
</html>