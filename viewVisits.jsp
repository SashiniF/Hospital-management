<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Visit Details</title>
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
        .add-visit-link {
            display: block;
            text-align: center;
            margin-top: 20px;
        }
    </style>
    <script>
        function goToHome() {
            window.location.href = "Home.jsp";
        }

        function confirmDelete() {
            const selectedId = getSelectedVisitId();
            if (selectedId) {
                if (confirm("Are you sure you want to delete the selected visit record?")) {
                    window.location.href = "viewVisits.jsp?deleteId=" + selectedId;
                }
            } else {
                alert("Please select a visit to delete.");
            }
        }

        function getSelectedVisitId() {
            const selectedRow = document.querySelector('input[name="visitCheckbox"]:checked');
            return selectedRow ? selectedRow.value : null;
        }

        function highlightRow(checkbox) {
            // Clear previous selections
            const rows = document.querySelectorAll('tr');
            rows.forEach(row => row.classList.remove('selected'));
            
            // Highlight the selected row
            const row = checkbox.closest('tr');
            if (checkbox.checked) {
                row.classList.add('selected');
            }
        }
    </script>
</head>
<body>
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <h1>Visit Records</h1>

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
                String deleteSql = "DELETE FROM VisitDetails WHERE visit_id = ?";
                pstmt = conn.prepareStatement(deleteSql);
                pstmt.setString(1, deleteId);
                int rowsDeleted = pstmt.executeUpdate();
                if (rowsDeleted > 0) {
                    out.println("<script>alert('Visit record deleted successfully!'); window.location.href='viewVisits.jsp';</script>");
                } else {
                    out.println("<script>alert('Failed to delete visit record.'); window.location.href='viewVisits.jsp';</script>");
                }
                return; // Stop further execution after delete
            }

            // Create a statement to execute the query
            stmt = conn.createStatement();

            // SQL query to fetch all visits
            String sql = "SELECT * FROM VisitDetails ORDER BY visit_id";
            rs = stmt.executeQuery(sql);
            
            if (!rs.isBeforeFirst()) {
                out.println("<p class='no-records'>No visit records found.</p>");
                out.println("<a href='addVisit.jsp' class='add-visit-link'>Add a new visit</a>");
            } else {
    %>

    <table>
        <thead>
            <tr>
                <th>Select</th>
                <th>Visit ID</th>
                <th>Visit Date</th>
                <th>Doctor ID</th>
                <th>Admission ID</th>
                <th>Patient ID</th>
                <th>Description</th>
            </tr>
        </thead>
        <tbody>
            <%
                while (rs.next()) {
                    String visitId = rs.getString("visit_id");
                    String visitDate = rs.getString("visit_date");
                    String doctorId = rs.getString("doctor_id");
                    String admissionId = rs.getString("admission_id");
                    String patientId = rs.getString("patient_id");
                    String description = rs.getString("description");
            %>
            <tr>
                <td>
                    <input type="radio" name="visitCheckbox" value="<%= visitId %>" onclick="highlightRow(this)">
                </td>
                <td><%= visitId %></td>
                <td><%= visitDate %></td>
                <td><%= doctorId %></td>
                <td><%= admissionId %></td>
                <td><%= patientId %></td>
                <td><%= description != null ? description : "-" %></td>
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
            out.println("<script>alert('An error occurred: " + e.getMessage() + "');</script>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
    %>
</body>
</html>