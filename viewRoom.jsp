<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Details</title>
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
            width: 100px; /* Smaller logo size */
            height: auto;
        }
    </style>
    <script>
        function goToHome() {
            window.location.href = "Home.jsp";
        }

        function confirmDelete() {
            const selectedId = getSelectedRoomId();
            if (selectedId) {
                if (confirm("Are you sure you want to delete the selected room?")) {
                    window.location.href = "?deleteId=" + selectedId;
                }
            } else {
                alert("Please select a room to delete.");
            }
        }

        function getSelectedRoomId() {
            const selectedRow = document.querySelector('input[name="roomCheckbox"]:checked');
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
    <h1>Room Details</h1>

    <div class="action-buttons">
        <img src="img/home.png" alt="Home" class="home-btn" onclick="goToHome()">
        <button class="delete-btn" onclick="confirmDelete()">Delete</button>
    </div>

    <%
        String url = "jdbc:mysql://localhost:3306/hospital";
        String user = "root";
        String password = "@Sashini123";

        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, user, password);

            // Handle delete request
            String deleteId = request.getParameter("deleteId");
            if (deleteId != null) {
                String deleteSql = "DELETE FROM RoomDetails WHERE room_id = ?";
                PreparedStatement pstmt = conn.prepareStatement(deleteSql);
                pstmt.setString(1, deleteId);
                pstmt.executeUpdate();
                out.println("<p style='color:green; text-align:center;'>Room deleted successfully!</p>");
            }

            // Create a statement to execute the query
            stmt = conn.createStatement();

            // SQL query to fetch all rooms
            String sql = "SELECT * FROM RoomDetails ORDER BY room_id";
            rs = stmt.executeQuery(sql);
    %>

    <table>
        <thead>
            <tr>
                <th>Select</th>
                <th>Room ID</th>
                <th>Room Type</th>
                <th>Daily Rate (LKR)</th>
                <th>Description</th>
                <th>Notes</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (rs.next()) {
                    String roomId = rs.getString("room_id");
                    String roomType = rs.getString("room_type");
                    double rate = rs.getDouble("rate");
                    String description = rs.getString("room_description");
                    String notes = rs.getString("notes");
            %>
            <tr>
                <td>
                    <input type="radio" name="roomCheckbox" value="<%= roomId %>" onclick="highlightRow(this)">
                </td>
                <td><%= roomId %></td>
                <td><%= roomType %></td>
                <td><%= String.format("%,.2f", rate) %></td>
                <td><%= (description != null && !description.isEmpty()) ? description : "-" %></td>
                <td><%= (notes != null && !notes.isEmpty()) ? notes : "-" %></td>
            </tr>
            <%
                }
            %>
        </tbody>
    </table>

    <%
        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red; text-align:center;'>An error occurred: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
            if (conn != null) conn.close();
        }
    %>
</body>
</html>