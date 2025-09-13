<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Ward Details</title>
    <style>
        /* ... (Your existing CSS styles remain unchanged) ... */
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
        .ward-details {
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
        .ward-details h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7);
        }
        .ward-details label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .ward-details input[type="text"],
        .ward-details input[type="number"],
        .ward-details textarea,
        .ward-details select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8);
        }
        .ward-details button {
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
        .ward-details button:hover {
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
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .error-message {
            color: #e74c3c;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        /* New style for the custom type input container */
        .custom-ward-type-container {
            margin-top: -5px; /* Adjust spacing */
            margin-bottom: 15px;
            display: none; /* Hidden by default */
        }
        .custom-ward-type-container label {
            margin-top: 5px;
        }
        @media (max-width: 768px) {
            .ward-details {
                padding: 15px;
                margin: 20px auto;
                height: auto;
                max-height: calc(100vh - 40px);
            }
            .record-controls {
                flex-direction: column;
            }
            .record-controls button {
                margin-right: 0;
                margin-bottom: 5px;
            }
            .record-controls button:last-child {
                margin-bottom: 0;
            }
        }
    </style>
</head>
<body>
    <img src="img/ward.png" alt="Ward Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="ward-details">
        <h1>Ward Details Management</h1>

        <%
            String generatedWardId = "";
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                String url = "jdbc:mysql://localhost:3306/hospital";
                String user = "root";
                String password = "@Sashini123";
                
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(url, user, password);

                String getLastWardIdSql = "SELECT ward_id FROM WardDetails ORDER BY ward_id DESC LIMIT 1";
                pstmt = conn.prepareStatement(getLastWardIdSql);
                rs = pstmt.executeQuery();

                if (rs.next()) {
                    String lastWardId = rs.getString("ward_id");
                    int num = Integer.parseInt(lastWardId.substring(1)) + 1;
                    generatedWardId = String.format("W%03d", num);
                } else {
                    generatedWardId = "W001";
                }
            } catch (Exception e) {
                out.println("<p class='error-message'>Error generating Ward ID: " + e.getMessage() + "</p>");
                generatedWardId = "W_ERROR"; 
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignore */ }
                if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignore */ }
                if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignore */ }
            }

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String wardId = request.getParameter("wardId"); 
                // Determine wardType based on selection
                String wardType = request.getParameter("wardType");
                String customWardType = request.getParameter("customWardType"); // Get custom type
                
                if ("Other".equals(wardType) && customWardType != null && !customWardType.trim().isEmpty()) {
                    wardType = customWardType.trim(); // Use custom type if "Other" was selected and input provided
                } else if ("Other".equals(wardType) && (customWardType == null || customWardType.trim().isEmpty())) {
                    // Handle case where "Other" is selected but no custom name is given
                    out.println("<p class='error-message'>Error: Please enter a name for the custom ward type.</p>");
                    // You might want to re-display the form with an error and pre-fill other fields
                    // For simplicity, this example just prints an error and exits the POST block.
                    return; 
                }

                String rateStr = request.getParameter("rate");
                String description = request.getParameter("description");
                String notes = request.getParameter("notes");
                
                try {
                    double rate = Double.parseDouble(rateStr);
                    if (rate <= 0) {
                        throw new NumberFormatException("Rate must be a positive value");
                    }

                    String url = "jdbc:mysql://localhost:3306/hospital";
                    String user = "root";
                    String password = "@Sashini123";

                    Connection connInsert = null;
                    PreparedStatement pstmtInsert = null;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        connInsert = DriverManager.getConnection(url, user, password);

                        String sql = "INSERT INTO WardDetails (ward_id, ward_type, rate, description, notes) VALUES (?, ?, ?, ?, ?)";
                        pstmtInsert = connInsert.prepareStatement(sql);

                        pstmtInsert.setString(1, wardId); 
                        pstmtInsert.setString(2, wardType); // Use the determined wardType
                        pstmtInsert.setDouble(3, rate);
                        pstmtInsert.setString(4, description);
                        pstmtInsert.setString(5, notes);

                        int rowsInserted = pstmtInsert.executeUpdate();

                        if (rowsInserted > 0) {
                            out.println("<p class='success-message'>Ward details saved successfully! <a href='viewWard.jsp' style='color:#2980b9;'>View all wards</a></p>");
                            
                            if (pstmtInsert != null) pstmtInsert.close();
                            if (connInsert != null) connInsert.close();

                            try {
                                connInsert = DriverManager.getConnection(url, user, password);
                                String getLastWardIdSqlRe = "SELECT ward_id FROM WardDetails ORDER BY ward_id DESC LIMIT 1";
                                pstmtInsert = connInsert.prepareStatement(getLastWardIdSqlRe);
                                rs = pstmtInsert.executeQuery();
                                if (rs.next()) {
                                    String lastWardId = rs.getString("ward_id");
                                    int num = Integer.parseInt(lastWardId.substring(1)) + 1;
                                    generatedWardId = String.format("W%03d", num);
                                }
                            } catch (Exception e) {
                                // Ignore re-generation error
                            }

                        } else {
                            out.println("<p class='error-message'>Failed to save ward details.</p>");
                        }

                    } catch (SQLException e) {
                        if (e.getErrorCode() == 1062) {
                            out.println("<p class='error-message'>Error: Ward ID '" + wardId + "' or Ward Type '" + wardType + "' already exists. Please refresh or try a different name.</p>");
                        } else {
                            out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                        }
                    } catch (Exception e) {
                        out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                    } finally {
                        if (pstmtInsert != null) pstmtInsert.close();
                        if (connInsert != null) connInsert.close();
                    }
                } catch (NumberFormatException e) {
                    out.println("<p class='error-message'>" + e.getMessage() + "</p>");
                }
            }
        %>

        <form id="wardForm" method="post" onsubmit="return validateForm()">
            <label for="wardId">Ward ID:</label>
            <input type="text" id="wardId" name="wardId" value="<%= generatedWardId %>" readonly>

            <label for="wardType">Ward Type:</label>
            <select id="wardType" name="wardType" required onchange="handleWardTypeChange()">
                <option value="">Select Ward Type</option>
                <option value="General Ward">General Ward</option>
                <option value="Private Ward">Private Ward</option>
                <option value="ICU">Intensive Care Unit (ICU)</option>
                <option value="Pediatric Ward">Pediatric Ward</option>
                <option value="Maternity Ward">Maternity Ward</option>
                <option value="Isolation Ward">Isolation Ward</option>
                <option value="Surgical Ward">Surgical Ward</option>
                <option value="Psychiatric Ward">Psychiatric Ward</option>
                <option value="Rehabilitation Ward">Rehabilitation Ward</option> 
                <option value="Other">Other (Specify)</option> </select>

            <div id="customWardTypeContainer" class="custom-ward-type-container">
                <label for="customWardType">Specify Other Ward Type:</label>
                <input type="text" id="customWardType" name="customWardType" placeholder="e.g., Geriatric Ward">
            </div>

            <label for="rate">Daily Rate (LKR):</label>
            <input type="number" id="rate" name="rate" 
                   placeholder="5000.00" 
                   value="5000.00"
                   required 
                   step="0.01" 
                   min="0">

            <label for="description">Ward Description:</label>
            <textarea id="description" name="description" 
                     placeholder="Enter detailed ward description (facilities, equipment, capacity, etc.)"></textarea>

            <label for="notes">Additional Notes:</label>
            <textarea id="notes" name="notes" 
                     placeholder="Enter any additional notes (special requirements, visiting hours, etc.)"></textarea>

            <button type="submit">Save Ward Details</button>
        </form>

        <div class="record-controls">
            <button onclick="window.location.href='searchWard.jsp'">Search Wards</button>
            <button onclick="addNewWard()">Add New Ward</button>
            <button onclick="window.location.href='viewWard.jsp'">View All Wards</button>
            <button onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        const wardRates = {
            "General Ward": 3000.00,
            "Private Ward": 10000.00,
            "ICU": 25000.00,
            "Pediatric Ward": 5000.00,
            "Maternity Ward": 8000.00,
            "Isolation Ward": 12000.00,
            "Surgical Ward": 15000.00,
            "Psychiatric Ward": 7000.00,
            "Rehabilitation Ward": 9500.00, 
            "Other": 5000.00 // Default rate for 'Other' can be customized
        };

        function handleWardTypeChange() {
            const wardTypeSelect = document.getElementById('wardType');
            const customWardTypeContainer = document.getElementById('customWardTypeContainer');
            const customWardTypeInput = document.getElementById('customWardType');
            const rateInput = document.getElementById('rate');

            if (wardTypeSelect.value === "Other") {
                customWardTypeContainer.style.display = 'block'; // Show the custom input
                customWardTypeInput.setAttribute('required', 'required'); // Make it required
                customWardTypeInput.focus();
                rateInput.value = wardRates["Other"].toFixed(2); // Set default "Other" rate
            } else {
                customWardTypeContainer.style.display = 'none'; // Hide the custom input
                customWardTypeInput.removeAttribute('required'); // Remove required attribute
                customWardTypeInput.value = ''; // Clear custom input
                // Update rate for predefined types
                if (wardTypeSelect.value && wardRates[wardTypeSelect.value]) {
                    rateInput.value = wardRates[wardTypeSelect.value].toFixed(2);
                } else {
                    rateInput.value = "5000.00"; // Fallback for empty or unknown types
                }
            }
        }

        function refreshPage() {
            window.location.reload();
        }

        function addNewWard() {
            window.location.reload();
        }

        function goToHome() {
            window.location.href = 'Home.jsp';
        }

        function validateForm() {
            const wardType = document.getElementById('wardType').value;
            const customWardType = document.getElementById('customWardType').value;
            const rate = document.getElementById('rate').value;

            if (wardType.trim() === '') {
                alert('Please select a Ward Type');
                return false;
            }

            // If "Other" is selected, validate the custom input
            if (wardType === "Other" && customWardType.trim() === '') {
                alert('Please enter a name for the custom ward type.');
                document.getElementById('customWardType').focus();
                return false;
            }

            if (parseFloat(rate) <= 0) {
                alert('Please enter a positive rate value');
                return false;
            }

            return true;
        }

        window.onload = function() {
            document.getElementById('wardType').selectedIndex = 0;
            // Ensure the custom input is hidden on initial load
            document.getElementById('customWardTypeContainer').style.display = 'none';
        };
    </script>
</body>
</html>