<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Outpatient Management</title>
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
        .outpatient-container {
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
        .outpatient-container h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7);
        }
        .outpatient-container h2 {
            color: #2c3e50;
            border-bottom: 1px solid #2980b9;
            padding-bottom: 5px;
            margin-top: 20px;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .outpatient-container label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .outpatient-container input[type="text"],
        .outpatient-container textarea,
        .outpatient-container select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8);
        }
        .outpatient-container textarea {
            resize: none;
            height: 80px;
        }
        .outpatient-container button {
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
        .outpatient-container button:hover {
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
        .patient-info {
            background-color: rgba(255, 255, 255, 0.5);
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            border: 1px solid rgba(0, 0, 0, 0.1);
        }
        @media (max-width: 768px) {
            .outpatient-container {
                padding: 15px;
                margin: 20px auto;
                height: auto;
                max-height: calc(100vh - 40px);
            }
            .record-navigation {
                flex-direction: column;
            }
            .record-navigation button {
                margin-right: 0;
                margin-bottom: 5px;
            }
            .record-navigation button:last-child {
                margin-bottom: 0;
            }
        }
    </style>
</head>
<body>
    <img src="img/patient.png" alt="Hospital Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="outpatient-container">
        <h1>OUT PATIENTS</h1>

        <%
            // Initialize variables
            String patientId = "";
            String firstName = "";
            String lastName = "";
            String gender = "Male";
            String telephone = "";
            String address = "";
            String status = "OK";
            String notes = "";
            boolean isSearchResult = false;

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String action = request.getParameter("action");
                
                if ("save".equals(action)) {
                    // Handle save action
                    patientId = request.getParameter("patientId");
                    firstName = request.getParameter("firstName");
                    lastName = request.getParameter("lastName");
                    gender = request.getParameter("gender");
                    telephone = request.getParameter("telephone");
                    address = request.getParameter("address");
                    status = request.getParameter("status");
                    notes = request.getParameter("notes");
                    
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        String url = "jdbc:mysql://localhost:3306/hospital";
                        String user = "root";
                        String password = "@Sashini123";

                        try (Connection conn = DriverManager.getConnection(url, user, password)) {
                            String sql = "INSERT INTO OutPatients (patient_id, first_name, last_name, gender, telephone, address, status, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
                            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                                pstmt.setString(1, patientId);
                                pstmt.setString(2, firstName);
                                pstmt.setString(3, lastName);
                                pstmt.setString(4, gender);
                                pstmt.setString(5, telephone);
                                pstmt.setString(6, address);
                                pstmt.setString(7, status);
                                pstmt.setString(8, notes);

                                int rowsInserted = pstmt.executeUpdate();

                                if (rowsInserted > 0) {
                                    out.println("<p class='success-message'>Patient details saved successfully!</p>");
                                    // Reset form after save
                                    patientId = "";
                                    firstName = "";
                                    lastName = "";
                                    gender = "Male";
                                    telephone = "";
                                    address = "";
                                    status = "OK";
                                    notes = "";
                                }
                            }
                        }
                    } catch (SQLException e) {
                        if (e.getErrorCode() == 1062) {
                            out.println("<p class='error-message'>Error: Patient ID already exists.</p>");
                        } else {
                            out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                        }
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
                            String sql = "SELECT * FROM OutPatients WHERE patient_id = ?";
                            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                                pstmt.setString(1, searchId);
                                try (ResultSet rs = pstmt.executeQuery()) {
                                    if (rs.next()) {
                                        patientId = rs.getString("patient_id");
                                        firstName = rs.getString("first_name");
                                        lastName = rs.getString("last_name");
                                        gender = rs.getString("gender");
                                        telephone = rs.getString("telephone");
                                        address = rs.getString("address");
                                        status = rs.getString("status");
                                        notes = rs.getString("notes");
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
            
            // Generate new patient ID if not from search result
            if (!isSearchResult && (patientId == null || patientId.isEmpty())) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    String url = "jdbc:mysql://localhost:3306/hospital";
                    String user = "root";
                    String password = "@Sashini123";

                    try (Connection conn = DriverManager.getConnection(url, user, password);
                         Statement stmt = conn.createStatement();
                         ResultSet rs = stmt.executeQuery("SELECT MAX(patient_id) FROM OutPatients")) {
                        
                        if (rs.next()) {
                            String maxId = rs.getString(1);
                            if (maxId != null && maxId.startsWith("P")) {
                                try {
                                    int num = Integer.parseInt(maxId.substring(1)) + 1;
                                    patientId = "P" + String.format("%03d", num);
                                } catch (NumberFormatException e) {
                                    patientId = "P001";
                                }
                            } else {
                                patientId = "P001";
                            }
                        } else {
                            patientId = "P001";
                        }
                    }
                } catch (Exception e) {
                    patientId = "P001";
                }
            }
        %>

        <div style="margin-bottom: 20px;">
            <input type="text" id="searchId" placeholder="Enter Patient ID" style="width: 70%; padding: 8px;">
            <button onclick="searchPatient()" style="width: 25%; padding: 8px; margin-left: 5%;">Search</button>
        </div>

        <form id="patientForm" method="post" onsubmit="return validateForm()">
            <input type="hidden" name="action" value="save">
            
            <div class="patient-info">
                <h2>Patient Details</h2>
                
                <label for="patientId">Patient ID:</label>
                <input type="text" id="patientId" name="patientId" value="<%= patientId %>" readonly>
                
                <label for="firstName">First Name:</label>
                <input type="text" id="firstName" name="firstName" value="<%= firstName %>" required>
                
                <label for="lastName">Last Name:</label>
                <input type="text" id="lastName" name="lastName" value="<%= lastName %>" required>
                
                <label for="gender">Gender:</label>
                <select id="gender" name="gender" required>
                    <option value="Male" <%= "Male".equals(gender) ? "selected" : "" %>>Male</option>
                    <option value="Female" <%= "Female".equals(gender) ? "selected" : "" %>>Female</option>
                    <option value="Other" <%= "Other".equals(gender) ? "selected" : "" %>>Other</option>
                </select>
                
                <label for="telephone">Telephone:</label>
                <input type="text" id="telephone" name="telephone" value="<%= telephone %>" required>
                
                <label for="address">Address:</label>
                <input type="text" id="address" name="address" value="<%= address %>" required>
                
                <label for="status">Status:</label>
                <select id="status" name="status" required>
                    <option value="OK" <%= "OK".equals(status) ? "selected" : "" %>>OK</option>
                    <option value="Critical" <%= "Critical".equals(status) ? "selected" : "" %>>Critical</option>
                    <option value="Recovering" <%= "Recovering".equals(status) ? "selected" : "" %>>Recovering</option>
                </select>
                
                <label for="notes">Notes:</label>
                <textarea id="notes" name="notes"><%= notes %></textarea>
            </div>

            <button type="submit">Save Patient Details</button>
        </form>

        <div class="record-navigation">
            <button onclick="addNewPatient()">Add Patient</button>
            <button onclick="window.location.href='viewPatients.jsp'">View All</button>
            <button onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        function refreshPage() {
            window.location.reload();
        }

        function addNewPatient() {
            window.location.href = window.location.href.split('?')[0];
        }

        function goToHome() {
            window.location.href = 'Home.jsp';
        }

        function validateForm() {
            const firstName = document.getElementById('firstName').value;
            const lastName = document.getElementById('lastName').value;
            const telephone = document.getElementById('telephone').value;
            const address = document.getElementById('address').value;

            if (firstName.trim() === '') {
                alert('Please enter First Name');
                return false;
            }

            if (lastName.trim() === '') {
                alert('Please enter Last Name');
                return false;
            }

            if (telephone.trim() === '') {
                alert('Please enter Telephone');
                return false;
            }

            if (address.trim() === '') {
                alert('Please enter Address');
                return false;
            }

            return true;
        }

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

        window.onload = function() {
            document.getElementById('firstName').focus();
        };
    </script>
</body>
</html>