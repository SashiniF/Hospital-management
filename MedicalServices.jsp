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
            background-image: url('img/medicalservice.jpg');
            background-size: cover;
            background-position: center;
            padding: 20px;
            position: relative;
            color: #fff;
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 150px;
            height: auto;
        }
        .home-button {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 40px;
            height: 40px;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .home-button:hover {
            transform: scale(1.1);
        }
        .service-details {
            background-color: rgba(255, 255, 255, 0.8);
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            margin: 0 auto;
            margin-top: 80px;
        }
        .service-details h1 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
        }
        .service-details label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .service-details input[type="text"],
        .service-details input[type="number"],
        .service-details textarea {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 16px;
        }
        .service-details textarea {
            resize: vertical;
            height: 100px;
        }
        .service-details button {
            background-color: #007bff;
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
        }
        .service-details button:hover {
            background-color: #0056b3;
        }
        .record-controls {
            display: flex;
            justify-content: space-between;
            margin-top: 20px;
        }
        .record-controls button {
            background-color: #28a745;
            color: #fff;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            margin-right: 10px;
            flex: 1;
        }
        .record-controls button:last-child {
            margin-right: 0;
        }
        .record-controls button:hover {
            background-color: #218838;
        }
        .success-message {
            color: green;
            text-align: center;
            margin-bottom: 15px;
        }
        .error-message {
            color: red;
            text-align: center;
            margin-bottom: 15px;
        }
        .input-group {
            display: flex;
            align-items: center;
        }
        .input-group input {
            flex: 1;
        }
        .input-group span {
            margin-left: 10px;
            color: #555;
        }
        .service-id-display {
            background-color: #f0f0f0;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 15px;
            font-weight: bold;
            color: #333;
            text-align: center;
        }
    </style>
</head>
<body>
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="service-details">
        <h1>Medical Services</h1>

        <%
            // Database connection details
            String url = "jdbc:mysql://localhost:3306/hospital";
            String user = "root";
            String password = "@Sashini123";
            
            // Generate a new service ID in SVCXXX format
            String newServiceId = "SVC001"; // Default value
            
            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;
            
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, user, password);
                
                // Get the highest existing service ID
                stmt = conn.createStatement();
                rs = stmt.executeQuery("SELECT MAX(Channel_Service_ID) FROM MedicalServices");
                
                if (rs.next()) {
                    String maxId = rs.getString(1);
                    if (maxId != null && maxId.startsWith("SVC")) {
                        try {
                            int num = Integer.parseInt(maxId.substring(3));
                            num++; // Increment the number
                            newServiceId = String.format("SVC%03d", num); // Format as SVCXXX
                        } catch (NumberFormatException e) {
                            // If parsing fails, use the default
                        }
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<p class='error-message'>Error generating service ID: " + e.getMessage() + "</p>");
            } finally {
                if (rs != null) rs.close();
                if (stmt != null) stmt.close();
                if (conn != null) conn.close();
            }
            
            // Handle form submission
            if ("POST".equalsIgnoreCase(request.getMethod())) {
                // Retrieve form data
                String serviceId = request.getParameter("serviceId");
                String serviceName = request.getParameter("serviceName");
                String amountRateStr = request.getParameter("amountRate");
                String durationStr = request.getParameter("duration");
                String additionalNotes = request.getParameter("additionalNotes");
                
                // Validate numeric fields
                try {
                    double amountRate = Double.parseDouble(amountRateStr);
                    int duration = Integer.parseInt(durationStr);
                    
                    // Validate positive values
                    if (amountRate <= 0) {
                        throw new NumberFormatException("Amount must be greater than 0");
                    }
                    if (duration <= 0) {
                        throw new NumberFormatException("Duration must be positive value");
                    }

                    // Reconnect to database for insertion
                    conn = null;
                    PreparedStatement pstmt = null;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(url, user, password);

                        String sql = "INSERT INTO MedicalServices (Channel_Service_ID, Channel_Service, Duration_Of_Service, Charge_For_Service, Service_Notes) VALUES (?, ?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(sql);

                        pstmt.setString(1, serviceId);
                        pstmt.setString(2, serviceName);
                        pstmt.setInt(3, duration);
                        pstmt.setDouble(4, amountRate);
                        pstmt.setString(5, additionalNotes);

                        int rowsInserted = pstmt.executeUpdate();

                        if (rowsInserted > 0) {
                            out.println("<p class='success-message'>Medical service saved successfully!</p>");
                            // Generate next ID for new entry
                            try {
                                int num = Integer.parseInt(serviceId.substring(3));
                                num++;
                                newServiceId = String.format("SVC%03d", num);
                            } catch (NumberFormatException e) {
                                // If parsing fails, use the default
                            }
                        } else {
                            out.println("<p class='error-message'>Failed to save medical service.</p>");
                        }

                    } catch (SQLException e) {
                        if (e.getErrorCode() == 1062) { // Duplicate entry error
                            out.println("<p class='error-message'>Service ID already exists. A new ID has been generated.</p>");
                            // Generate next ID
                            try {
                                int num = Integer.parseInt(serviceId.substring(3));
                                num++;
                                newServiceId = String.format("SVC%03d", num);
                            } catch (NumberFormatException ex) {
                                // If parsing fails, use the default
                            }
                        } else {
                            out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                        }
                    } finally {
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                } catch (NumberFormatException e) {
                    out.println("<p class='error-message'>" + e.getMessage() + "</p>");
                }
            }
        %>

        <!-- Form to submit medical service details -->
        <form id="serviceForm" method="post" onsubmit="return validateForm()">
            <label for="serviceId">Service ID:</label>
            <div class="service-id-display">
                <%= newServiceId %>
                <input type="hidden" id="serviceId" name="serviceId" value="<%= newServiceId %>">
            </div>

            <label for="serviceName">Service Name:</label>
            <input type="text" id="serviceName" name="serviceName" placeholder="Enter Service Name" required>

            <label for="amountRate">Amount / Rate (LKR):</label>
            <div class="input-group">
                <input type="number" id="amountRate" name="amountRate" 
                       placeholder="50.00" 
                       value="50.00"
                       required 
                       step="0.01" 
                       min="0.01">
                <span>LKR</span>
            </div>

            <label for="duration">Duration:</label>
            <div class="input-group">
                <input type="number" id="duration" name="duration" placeholder="Enter Duration" required min="1">
                <span>minutes</span>
            </div>

            <label for="additionalNotes">Additional Notes:</label>
            <textarea id="additionalNotes" name="additionalNotes" placeholder="Enter Additional Notes"></textarea>

            <button type="submit">Save Service Details</button>
        </form>

        <!-- Record Controls -->
        <div class="record-controls">
            <button onclick="window.location.href='searchMedicalServices.jsp'">Search Services</button>
            <button onclick="addNewService()">Add New Service</button>
            <button onclick="window.location.href='viewMedicalServices.jsp'">View All Services</button>
            <button onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        function refreshPage() {
            window.location.reload();
        }

        function addNewService() {
            // Clear the form except for the auto-generated ID
            document.getElementById('serviceName').value = '';
            document.getElementById('amountRate').value = '50.00';
            document.getElementById('duration').value = '';
            document.getElementById('additionalNotes').value = '';
            // Focus on the service name field
            document.getElementById('serviceName').focus();
        }
        
        function goToHome() {
            window.location.href = 'Home.jsp';
        }
        
        function validateForm() {
            const serviceName = document.getElementById('serviceName').value;
            const amountRate = document.getElementById('amountRate').value;
            const duration = document.getElementById('duration').value;
            
            if (serviceName.trim() === '') {
                alert('Please enter a Service Name');
                return false;
            }
            
            if (parseFloat(amountRate) <= 0) {
                alert('Please enter an amount greater than 0 LKR');
                return false;
            }
            
            if (parseInt(duration) <= 0) {
                alert('Please enter a valid duration (greater than 0 minutes)');
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>