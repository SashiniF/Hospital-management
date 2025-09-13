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
        .room-details {
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
        .room-details h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7);
        }
        .room-details label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .room-details input[type="text"],
        .room-details input[type="number"],
        .room-details textarea,
        .room-details select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8);
        }
        .room-details textarea {
            resize: none;
            height: 80px;
        }
        .room-details button {
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
        .room-details button:hover {
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
        .room-type-container {
            display: flex;
            gap: 10px;
        }
        .room-type-container select {
            flex: 1;
        }
        .room-type-container button {
            width: auto;
            padding: 10px 15px;
        }
        #newRoomTypeContainer {
            display: none;
            margin-top: 10px;
        }
        #newRoomTypeContainer input {
            margin-bottom: 10px;
        }
        @media (max-width: 768px) {
            .room-details {
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
            .room-type-container {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <img src="img/Room.png" alt="Room Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="room-details">
        <h1>Room Details Management</h1>

        <%
            // Generate new Room ID
            String newRoomId = "R001"; // Default value
            
            try {
                String url = "jdbc:mysql://localhost:3306/hospital";
                String user = "root";
                String password = "@Sashini123";
                
                Connection conn = null;
                Statement stmt = null;
                ResultSet rs = null;
                
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(url, user, password);
                    
                    // Get the maximum room_id from the database
                    stmt = conn.createStatement();
                    rs = stmt.executeQuery("SELECT MAX(room_id) AS max_id FROM RoomDetails");
                    
                    if (rs.next()) {
                        String maxId = rs.getString("max_id");
                        if (maxId != null) {
                            // Extract the numeric part and increment
                            String numericPart = maxId.substring(1);
                            try {
                                int num = Integer.parseInt(numericPart);
                                num++;
                                newRoomId = "R" + String.format("%03d", num);
                            } catch (NumberFormatException e) {
                                out.println("<p class='error-message'>Error generating Room ID: " + e.getMessage() + "</p>");
                            }
                        }
                    }
                } catch (SQLException e) {
                    out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                } finally {
                    if (rs != null) rs.close();
                    if (stmt != null) stmt.close();
                    if (conn != null) conn.close();
                }
            } catch (Exception e) {
                out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
            }

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String roomId = request.getParameter("roomId");
                String roomType = request.getParameter("roomType");
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

                    Connection conn = null;
                    PreparedStatement pstmt = null;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(url, user, password);

                        String sql = "INSERT INTO RoomDetails (room_id, room_type, rate, room_description, notes) VALUES (?, ?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(sql);

                        pstmt.setString(1, roomId);
                        pstmt.setString(2, roomType);
                        pstmt.setDouble(3, rate);
                        pstmt.setString(4, description);
                        pstmt.setString(5, notes);

                        int rowsInserted = pstmt.executeUpdate();

                        if (rowsInserted > 0) {
                            out.println("<p class='success-message'>Room details saved successfully! <a href='viewRoom.jsp' style='color:#2980b9;'>View all rooms</a></p>");
                        } else {
                            out.println("<p class='error-message'>Failed to save room details.</p>");
                        }

                    } catch (SQLException e) {
                        if (e.getErrorCode() == 1062) {
                            out.println("<p class='error-message'>Error: Room ID already exists.</p>");
                        } else {
                            out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                        }
                    } catch (Exception e) {
                        out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                    } finally {
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                } catch (NumberFormatException e) {
                    out.println("<p class='error-message'>" + e.getMessage() + "</p>");
                }
            }
        %>

        <form id="roomForm" method="post" onsubmit="return validateForm()">
            <label for="roomId">Room ID:</label>
            <input type="text" id="roomId" name="roomId" value="<%= newRoomId %>" readonly 
                   style="background-color: #e9ecef;">

            <label for="roomType">Room Type:</label>
            <div class="room-type-container">
                <select id="roomType" name="roomType" required onchange="updateRate()">
                    <option value="">Select Room Type</option>
                    <option value="General Ward">General Ward</option>
                    <option value="Private Room">Private Room</option>
                    <option value="ICU">Intensive Care Unit (ICU)</option>
                    <option value="Semi-Private">Semi-Private</option>
                    <option value="Pediatric Ward">Pediatric Ward</option>
                    <option value="Maternity Ward">Maternity Ward</option>
                    <option value="Isolation Room">Isolation Room</option>
                    <option value="Other">Other</option>
                </select>
                <button type="button" onclick="showNewRoomTypeField()">Add New</button>
            </div>
            
            <div id="newRoomTypeContainer">
                <input type="text" id="newRoomType" placeholder="Enter new room type">
                <input type="number" id="newRoomTypeRate" placeholder="Enter rate for new type" step="0.01" min="0">
                <button type="button" onclick="addNewRoomType()">Add</button>
                <button type="button" onclick="hideNewRoomTypeField()">Cancel</button>
            </div>

            <label for="rate">Daily Rate (LKR):</label>
            <input type="number" id="rate" name="rate" 
                   placeholder="5000.00" 
                   value="5000.00"
                   required 
                   step="0.01" 
                   min="0">

            <label for="description">Room Description:</label>
            <textarea id="description" name="description" 
                     placeholder="Enter detailed room description (facilities, equipment, capacity, etc.)"></textarea>

            <label for="notes">Additional Notes:</label>
            <textarea id="notes" name="notes" 
                     placeholder="Enter any additional notes (special requirements, visiting hours, etc.)"></textarea>

            <button type="submit">Save Room Details</button>
        </form>

        <div class="record-controls">
            <button onclick="window.location.href='searchRoom.jsp'">Search Rooms</button>
            <button onclick="addNewRoom()">Add New Room</button>
            <button onclick="window.location.href='viewRoom.jsp'">View All Rooms</button>
            <button onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        const roomRates = {
            "General Ward": 3000.00,
            "Private Room": 10000.00,
            "ICU": 25000.00,
            "Semi-Private": 6000.00,
            "Pediatric Ward": 5000.00,
            "Maternity Ward": 8000.00,
            "Isolation Room": 12000.00,
            "Other": 5000.00
        };

        function updateRate() {
            const roomType = document.getElementById('roomType').value;
            if (roomType && roomRates[roomType]) {
                document.getElementById('rate').value = roomRates[roomType].toFixed(2);
            } else if (roomType === "Other") {
                document.getElementById('rate').value = "5000.00";
            }
        }

        function showNewRoomTypeField() {
            document.getElementById('newRoomTypeContainer').style.display = 'block';
            document.getElementById('newRoomType').focus();
        }

        function hideNewRoomTypeField() {
            document.getElementById('newRoomTypeContainer').style.display = 'none';
            document.getElementById('newRoomType').value = '';
            document.getElementById('newRoomTypeRate').value = '';
        }

        function addNewRoomType() {
            const newType = document.getElementById('newRoomType').value.trim();
            const newRate = document.getElementById('newRoomTypeRate').value;
            
            if (!newType) {
                alert('Please enter a room type');
                return;
            }
            
            if (!newRate || parseFloat(newRate) <= 0) {
                alert('Please enter a valid rate');
                return;
            }
            
            // Add the new type to the dropdown
            const select = document.getElementById('roomType');
            const option = document.createElement('option');
            option.value = newType;
            option.textContent = newType;
            select.appendChild(option);
            
            // Select the new option
            select.value = newType;
            
            // Update the rate field
            document.getElementById('rate').value = parseFloat(newRate).toFixed(2);
            
            // Add to our rates object
            roomRates[newType] = parseFloat(newRate);
            
            // Hide the input fields
            hideNewRoomTypeField();
        }

        function refreshPage() {
            window.location.reload();
        }

        function addNewRoom() {
            document.getElementById('roomForm').reset();
            document.getElementById('rate').value = "3000.00";
            document.getElementById('roomType').selectedIndex = 0;
            // Room ID will be regenerated when page reloads
            window.location.reload();
        }

        function goToHome() {
            window.location.href = 'Home.jsp';
        }

        function validateForm() {
            const roomType = document.getElementById('roomType').value;
            const rate = document.getElementById('rate').value;

            if (roomType.trim() === '') {
                alert('Please select a Room Type');
                return false;
            }

            if (parseFloat(rate) <= 0) {
                alert('Please enter a positive rate value');
                return false;
            }

            return true;
        }

        window.onload = function() {
            document.getElementById('roomType').focus();
        };
    </script>
</body>
</html>