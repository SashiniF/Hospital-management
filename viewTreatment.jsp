<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Treatment Details</title>
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
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 100px;
            height: auto;
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
            const selectedId = getSelectedTreatmentId();
            if (selectedId && confirm("Are you sure you want to delete the selected treatment?")) {
                window.location.href = "?deleteId=" + selectedId;
            } else {
                alert("Please select a treatment to delete.");
            }
        }

        function getSelectedTreatmentId() {
            const selectedRow = document.querySelector('input[name="treatmentCheckbox"]:checked');
            return selectedRow ? selectedRow.value : null;
        }

        function highlightRow(checkbox) {
            const row = checkbox.closest('tr');
            row.classList.toggle('selected', checkbox.checked);
        }
    </script>
</head>
<body>
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <h1>Treatment Details</h1>

    <div class="action-buttons">
        <img src="img/home.png" alt="Home" class="home-btn" onclick="goToHome()">
        <button class="delete-btn" onclick="confirmDelete()">Delete</button>
    </div>

    <table>
        <thead>
            <tr>
                <th>Select</th>
                <th>Treatment ID</th>
                <th>Patient ID</th>
                <th>Doctor ID</th>
                <th>Date</th>
                <th>Time</th>
                <th>Description</th>
                <th>Prescriptions</th>
            </tr>
        </thead>
        <tbody>
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
                String deleteId = request.getParameter("deleteId");
                if (deleteId != null) {
                    String deleteSql = "DELETE FROM TreatmentDetails WHERE treatment_id = ?";
                    PreparedStatement pstmt = conn.prepareStatement(deleteSql);
                    pstmt.setString(1, deleteId);
                    pstmt.executeUpdate();
                }

                stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT * FROM TreatmentDetails ORDER BY treatment_id");
                while (rs.next()) {
                    String treatmentId = rs.getString("treatment_id");
                    String patientId = rs.getString("patient_id");
                    String doctorId = rs.getString("doctor_id");
                    String appointmentDate = rs.getString("appointment_date");
                    String appointmentTime = rs.getString("appointment_time");
                    String description = rs.getString("description");
                    String prescriptions = rs.getString("prescriptions");
        %>
            <tr>
                <td><input type="radio" name="treatmentCheckbox" value="<%= treatmentId %>" onclick="highlightRow(this)"></td>
                <td><%= treatmentId %></td>
                <td><%= patientId %></td>
                <td><%= doctorId %></td>
                <td><%= appointmentDate %></td>
                <td><%= appointmentTime %></td>
                <td><%= description != null && !description.isEmpty() ? description : "-" %></td>
                <td><%= prescriptions != null && !prescriptions.isEmpty() ? prescriptions : "-" %></td>
            </tr>
        <%
                }
            } catch (Exception e) {
                out.println("<p style='color:red;'>An error occurred: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            }
        %>
        </tbody>
    </table>
</body>
</html>