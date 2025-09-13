<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inpatient Management</title>
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
        .inpatient-container {
            background-color: rgba(255, 255, 255, 0.7);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            margin: 50px auto;
            height: calc(100vh - 100px);
            overflow-y: auto;
            backdrop-filter: blur(3px);
            border: 1px solid rgba(255, 255, 255, 0.3);
        }
        .inpatient-container h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7);
        }
        .inpatient-container label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .inpatient-container input[type="text"],
        .inpatient-container input[type="number"],
        .inpatient-container input[type="date"],
        .inpatient-container select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8);
        }
        .inpatient-container button {
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
        .inpatient-container button:hover {
            background-color: #3498db;
        }
        .record-navigation {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
        }
        .record-navigation button {
            background-color: #27ae60;
            padding: 8px;
            font-size: 12px;
            margin-right: 5px;
            flex: 1;
        }
        .record-navigation button:last-child {
            margin-right: 0;
        }
        .success-message {
            color: #27ae60;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .error-message {
            color: #e74c3c;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
    </style>
</head>
<body>
    <img src="img/hospital.png" alt="Hospital Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="inpatient-container">
        <h1>IN PATIENT DETAILS</h1>

        <%
            // Initialize variables
            String patientId = "";
            String firstName = "";
            String lastName = "";
            String dob = "";
            String gender = "Male";
            String address = "";
            String contact = "";
            String notes = "";
            String weight = "";
            String height = "";  
            String bloodGroup = "";
            String nidNumber = "";
            boolean isSearchResult = false;

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String action = request.getParameter("action");
                
                if ("save".equals(action)) {
                    // Handle save action
                    patientId = request.getParameter("patientId");
                    firstName = request.getParameter("firstName");
                    lastName = request.getParameter("lastName");
                    dob = request.getParameter("dob");
                    gender = request.getParameter("gender");
                    address = request.getParameter("address");
                    contact = request.getParameter("contact");
                    notes = request.getParameter("notes");
                    weight = request.getParameter("weight");
                    height = request.getParameter("height");  
                    bloodGroup = request.getParameter("bloodGroup");
                    nidNumber = request.getParameter("nidNumber");

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        String url = "jdbc:mysql://localhost:3306/hospital";
                        String user = "root";
                        String password = "@Sashini123";

                        try (Connection conn = DriverManager.getConnection(url, user, password)) {
                            String sql = "INSERT INTO InPatients (patient_id, first_name, last_name, dob, gender, address, contact, notes, weight, height, blood_group, nid_number) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                                pstmt.setString(1, patientId);
                                pstmt.setString(2, firstName);
                                pstmt.setString(3, lastName);
                                pstmt.setString(4, dob);
                                pstmt.setString(5, gender);
                                pstmt.setString(6, address);
                                pstmt.setString(7, contact);
                                pstmt.setString(8, notes);
                                pstmt.setString(9, weight);
                                pstmt.setString(10, height);
                                pstmt.setString(11, bloodGroup);
                                pstmt.setString(12, nidNumber);

                                int rowsInserted = pstmt.executeUpdate();
                                if (rowsInserted > 0) {
                                    out.println("<p class='success-message'>Patient details saved successfully!</p>");
                                }
                            }
                        }
                    } catch (SQLException e) {
                        out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                    } catch (Exception e) {
                        out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                    }
                } else if ("search".equals(action)) {
                    // Handle search action
                    String searchId = request.getParameter("searchId");
                    
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        String url = "jdbc:mysql://localhost:3306/hospital";
                        String user = "root";
                        String password = "@Sashini123";

                        try (Connection conn = DriverManager.getConnection(url, user, password)) {
                            String sql = "SELECT * FROM InPatients WHERE patient_id = ?";
                            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                                pstmt.setString(1, searchId);
                                try (ResultSet rs = pstmt.executeQuery()) {
                                    if (rs.next()) {
                                        patientId = rs.getString("patient_id");
                                        firstName = rs.getString("first_name");
                                        lastName = rs.getString("last_name");
                                        dob = rs.getString("dob");
                                        gender = rs.getString("gender");
                                        address = rs.getString("address");
                                        contact = rs.getString("contact");
                                        notes = rs.getString("notes");
                                        weight = rs.getString("weight");
                                        height = rs.getString("height");  
                                        bloodGroup = rs.getString("blood_group");
                                        nidNumber = rs.getString("nid_number");
                                        isSearchResult = true;
                                        out.println("<p class='success-message'>Patient found!</p>");
                                    } else {
                                        out.println("<p class='error-message'>Patient not found with ID: " + searchId + "</p>");
                                    }
                                }
                            }
                        }
                    } catch (Exception e) {
                        out.println("<p class='error-message'>Search error: " + e.getMessage() + "</p>");
                    }
                }
            }

            // Generate new patient ID in the format IP001
            if (!isSearchResult && (patientId == null || patientId.isEmpty())) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    String url = "jdbc:mysql://localhost:3306/hospital";
                    String user = "root";
                    String password = "@Sashini123";

                    try (Connection conn = DriverManager.getConnection(url, user, password);
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT MAX(patient_id) FROM InPatients")) {
                        
                        if (rs.next()) {
                            String maxId = rs.getString(1);
                            if (maxId != null && maxId.startsWith("IP")) {
                                try {
                                    int num = Integer.parseInt(maxId.substring(2)) + 1;
                                    patientId = "IP" + String.format("%03d", num);
                                } catch (NumberFormatException e) {
                                    patientId = "IP001";
                                }
                            } else {
                                patientId = "IP001";
                            }
                        } else {
                            patientId = "IP001";
                        }
                    }
                } catch (Exception e) {
                    patientId = "IP001";
                }
            }
        %>

        <div style="margin-bottom: 20px;">
            <input type="text" id="searchId" placeholder="Enter Patient ID" style="width: 70%; padding: 8px;">
            <button onclick="searchPatient()" style="width: 25%; padding: 8px; margin-left: 5%;">Search</button>
        </div>

        <form id="patientForm" method="post">
            <input type="hidden" name="action" value="save">
            
            <label for="patientId">Patient ID:</label>
            <input type="text" id="patientId" name="patientId" value="<%= patientId %>" readonly>

            <label for="firstName">First Name:</label>
            <input type="text" id="firstName" name="firstName" value="<%= firstName %>" required>

            <label for="lastName">Last Name:</label>
            <input type="text" id="lastName" name="lastName" value="<%= lastName %>" required>

            <label for="dob">Date of Birth:</label>
            <input type="date" id="dob" name="dob" value="<%= dob %>" required>

            <label for="gender">Gender:</label>
            <select id="gender" name="gender" required>
                <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
            </select>

            <label for="weight">Weight (kg):</label>
            <input type="number" id="weight" name="weight" value="<%= weight %>" required>

            <label for="height">Height (cm):</label>
            <input type="number" id="height" name="height" value="<%= height %>" required>

            <label for="bloodGroup">Blood Group:</label>
            <input type="text" id="bloodGroup" name="bloodGroup" value="<%= bloodGroup %>" required>

            <label for="nidNumber">NID Number:</label>
            <input type="text" id="nidNumber" name="nidNumber" value="<%= nidNumber %>" required>

            <label for="address">Address:</label>
            <input type="text" id="address" name="address" value="<%= address %>" required>

            <label for="contact">Mobile Phone:</label>
            <input type="text" id="contact" name="contact" value="<%= contact %>" required>

            <label for="notes">Notes:</label>
            <input type="text" id="notes" name="notes" value="<%= notes %>">
            
            <button type="submit">Save Patient Details</button>
        </form>

        <div class="record-navigation">
            <button onclick="addNewPatient()">Add Patient</button>
            <button onclick="window.location.href='viewInpatients.jsp'">View All</button>
            <button onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        function searchPatient() {
            const searchId = document.getElementById('searchId').value.trim();
            if (searchId === '') {
                alert('Please enter a Patient ID to search');
                return;
            }

            const form = document.createElement('form');
            form.method = 'post';
            form.action = '';

            const inputAction = document.createElement('input');
            inputAction.type = 'hidden';
            inputAction.name = 'action';
            inputAction.value = 'search';
            form.appendChild(inputAction);

            const inputSearchId = document.createElement('input');
            inputSearchId.type = 'hidden';
            inputSearchId.name = 'searchId';
            inputSearchId.value = searchId;
            form.appendChild(inputSearchId);

            document.body.appendChild(form);
            form.submit();
        }

        function goToHome() {
            window.location.href = 'Home.jsp';
        }

        function refreshPage() {
            window.location.reload();
        }

        function addNewPatient() {
            window.location.href = window.location.href.split('?')[0];
        }

        window.onload = function() {
            document.getElementById('firstName').focus();
        };
    </script>
</body>
</html>