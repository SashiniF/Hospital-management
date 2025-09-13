<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guardian Details</title>
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
            opacity: 0.5;
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
        .guardian-details {
            background-color: rgba(255, 255, 255, 0.7);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            margin: 50px auto;
            min-height: 400px;
            max-height: 80vh;
            overflow-y: auto;
            backdrop-filter: blur(3px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .guardian-details h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7);
        }
        .guardian-details label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
        }
        .guardian-details input[type="text"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8);
        }
        .guardian-details button {
            background-color: #2980b9;
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.3s;
            margin-top: 10px;
        }
        .guardian-details button:hover {
            background-color: #3498db;
        }
        .record-controls {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
        }
        .record-controls button {
            background-color: #27ae60;
            padding: 8px;
            font-size: 12px;
            margin-right: 5px;
            flex: 1;
        }
        .record-controls button:last-child {
            margin-right: 0;
        }
        .success-message {
            color: #27ae60;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
        }
        .error-message {
            color: #e74c3c;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
        }
        @media (max-width: 768px) {
            .guardian-details {
                padding: 15px;
                margin: 20px auto;
            }
            .record-controls {
                flex-direction: column;
            }
            .record-controls button {
                margin-bottom: 5px;
            }
        }
    </style>
</head>
<body>
    <img src="img/guar.png" alt="Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="guardian-details">
        <h1>Guardian Details</h1>

        <%
            String guardianId = "G001"; // Default if no guardians exist
            try {
                String url = "jdbc:mysql://localhost:3306/hospital";
                String user = "root";
                String password = "@Sashini123";

                Connection conn = DriverManager.getConnection(url, user, password);
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT MAX(guardian_id) FROM GuardianDetails");

                if (rs.next()) {
                    String maxId = rs.getString(1);
                    if (maxId != null) {
                        int num = Integer.parseInt(maxId.substring(1)) + 1;
                        guardianId = "G" + String.format("%03d", num);
                    }
                }

                rs.close();
                stmt.close();
                conn.close();
            } catch (Exception e) {
                // If there's an error, we'll just use the default G001
            }

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String firstName = request.getParameter("firstName");
                String lastName = request.getParameter("lastName");
                String nicNumber = request.getParameter("nicNumber");
                String address = request.getParameter("address");
                String phoneNumber = request.getParameter("phoneNumber");
                String occupation = request.getParameter("occupation");

                try {
                    String url = "jdbc:mysql://localhost:3306/hospital";
                    String user = "root";
                    String password = "@Sashini123";

                    Connection conn = DriverManager.getConnection(url, user, password);
                    String sql = "INSERT INTO GuardianDetails (guardian_id, first_name, last_name, nic_number, address, phone_number, occupation) VALUES (?, ?, ?, ?, ?, ?, ?)";
                    PreparedStatement pstmt = conn.prepareStatement(sql);

                    pstmt.setString(1, guardianId);
                    pstmt.setString(2, firstName);
                    pstmt.setString(3, lastName);
                    pstmt.setString(4, nicNumber);
                    pstmt.setString(5, address);
                    pstmt.setString(6, phoneNumber);
                    pstmt.setString(7, occupation);

                    int rowsInserted = pstmt.executeUpdate();

                    pstmt.close();
                    conn.close();

                    if (rowsInserted > 0) {
                        response.sendRedirect("viewGuardian.jsp"); // Redirect to viewGuardian.jsp after saving
                    } else {
                        out.println("<p class='error-message'>Failed to save guardian details.</p>");
                    }

                } catch (SQLException e) {
                    out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                } catch (Exception e) {
                    out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                }
            }
        %>

        <form id="guardianForm" method="post" onsubmit="return validateForm()">
            <label for="guardianId">Guardian ID:</label>
            <input type="text" id="guardianId" name="guardianId" value="<%= guardianId %>" readonly>

            <label for="firstName">First Name:</label>
            <input type="text" id="firstName" name="firstName" required>

            <label for="lastName">Last Name:</label>
            <input type="text" id="lastName" name="lastName" required>

            <label for="nicNumber">NIC Number:</label>
            <input type="text" id="nicNumber" name="nicNumber" required>

            <label for="address">Address:</label>
            <input type="text" id="address" name="address" required>

            <label for="phoneNumber">Phone Number:</label>
            <input type="text" id="phoneNumber" name="phoneNumber" required>

            <label for="occupation">Occupation:</label>
            <input type="text" id="occupation" name="occupation" required>

            <button type="submit">Register Guardian</button>
        </form>

        <div class="record-controls">
            <button onclick="window.location.href='searchGuardian.jsp'">Search Guardians</button>
            <button onclick="addNewGuardian()">Add New Guardian</button>
            <button onclick="window.location.href='viewGuardian.jsp'">View All Guardians</button>
            <button onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        function refreshPage() {
            window.location.reload();
        }

        function addNewGuardian() {
            document.getElementById('firstName').value = '';
            document.getElementById('lastName').value = '';
            document.getElementById('nicNumber').value = '';
            document.getElementById('address').value = '';
            document.getElementById('phoneNumber').value = '';
            document.getElementById('occupation').value = '';
            document.getElementById('firstName').focus();
        }

        function goToHome() {
            window.location.href = 'Home.jsp';
        }

        function validateForm() {
            const firstName = document.getElementById('firstName').value;
            const lastName = document.getElementById('lastName').value;

            if (firstName.trim() === '' || lastName.trim() === '') {
                alert('Please fill in all required fields.');
                return false;
            }

            return true;
        }

        window.onload = function() {
            document.getElementById('firstName').focus();
        };
    </script>
</body>
</html>