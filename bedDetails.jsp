<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bed Details</title>
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
        .bed-details {
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
        .bed-details h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 25px;
            font-size: 24px;
            text-shadow: 1px 1px 2px rgba(255,255,255,0.7);
        }
        .bed-details label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #2c3e50;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        .bed-details input[type="text"],
        .bed-details textarea,
        .bed-details select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8);
        }
        .bed-details textarea {
            resize: none;
            height: 80px;
        }
        .bed-details button {
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
        .bed-details button:hover {
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
        .location-selector {
            display: flex;
            gap: 10px;
        }
        .location-selector select {
            flex: 1;
        }
        @media (max-width: 768px) {
            .bed-details {
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
            .location-selector {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <img src="img/bed.png" alt="Bed Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="bed-details">
        <h1>Bed Details</h1>

        <%
            // Function to generate the next bed ID
            String nextBedId = "B001"; // Default if no beds exist
            
            // Lists to hold room and ward IDs
            java.util.List<String> roomIds = new java.util.ArrayList<>();
            java.util.List<String> wardIds = new java.util.ArrayList<>();
            
            try {
                String url = "jdbc:mysql://localhost:3306/hospital";
                String user = "root";
                String password = "@Sashini123";
                
                Connection conn = DriverManager.getConnection(url, user, password);
                
                // Get next bed ID
                Statement stmt = conn.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT MAX(bed_id) FROM BedDetails");
                
                if (rs.next()) {
                    String maxId = rs.getString(1);
                    if (maxId != null) {
                        int num = Integer.parseInt(maxId.substring(1)) + 1;
                        nextBedId = "B" + String.format("%03d", num);
                    }
                }
                rs.close();
                
                // Get all room IDs
                rs = stmt.executeQuery("SELECT room_id FROM RoomDetails ORDER BY room_id");
                while (rs.next()) {
                    roomIds.add(rs.getString("room_id"));
                }
                rs.close();
                
                // Get all ward IDs
                rs = stmt.executeQuery("SELECT ward_id FROM WardDetails ORDER BY ward_id");
                while (rs.next()) {
                    wardIds.add(rs.getString("ward_id"));
                }
                rs.close();
                
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<p class='error-message'>Error loading room/ward data: " + e.getMessage() + "</p>");
            }

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String bedId = request.getParameter("bedId");
                String roomId = request.getParameter("roomId");
                String wardId = request.getParameter("wardId");
                String bedDescription = request.getParameter("bedDescription");
                
                try {
                    // Validate that either room or ward is selected (but not both)
                    if ((roomId == null || roomId.isEmpty()) && (wardId == null || wardId.isEmpty())) {
                        throw new Exception("Please select either a Room or a Ward");
                    }
                    
                    if (!(roomId.isEmpty()) && !(wardId.isEmpty())) {
                        throw new Exception("Please select either a Room or a Ward, not both");
                    }

                    String url = "jdbc:mysql://localhost:3306/hospital";
                    String user = "root";
                    String password = "@Sashini123";

                    Connection conn = null;
                    PreparedStatement pstmt = null;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(url, user, password);

                        String sql = "INSERT INTO BedDetails (bed_id, room_id, ward_id, bed_description) VALUES (?, ?, ?, ?)";
                        pstmt = conn.prepareStatement(sql);

                        pstmt.setString(1, bedId);
                        pstmt.setString(2, roomId.isEmpty() ? null : roomId);
                        pstmt.setString(3, wardId.isEmpty() ? null : wardId);
                        pstmt.setString(4, bedDescription);

                        int rowsInserted = pstmt.executeUpdate();

                        if (rowsInserted > 0) {
                            out.println("<p class='success-message'>Bed details saved successfully! <a href='viewBeds.jsp' style='color:#2980b9;'>View all beds</a></p>");
                        } else {
                            out.println("<p class='error-message'>Failed to save bed details.</p>");
                        }

                    } catch (SQLException e) {
                        if (e.getErrorCode() == 1062) {
                            out.println("<p class='error-message'>Error: Bed ID already exists.</p>");
                        } else {
                            out.println("<p class='error-message'>Database error: " + e.getMessage() + "</p>");
                        }
                    } catch (Exception e) {
                        out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                    } finally {
                        if (pstmt != null) pstmt.close();
                        if (conn != null) conn.close();
                    }
                } catch (Exception e) {
                    out.println("<p class='error-message'>" + e.getMessage() + "</p>");
                }
            }
        %>

        <form id="bedForm" method="post" onsubmit="return validateForm()">
            <label for="bedId">Bed ID:</label>
            <input type="text" id="bedId" name="bedId" value="<%= nextBedId %>" readonly>

            <label>Location:</label>
            <div class="location-selector">
                <select id="roomId" name="roomId" onchange="clearWardSelection()">
                    <option value="">Select Room</option>
                    <% for (String roomId : roomIds) { %>
                        <option value="<%= roomId %>"><%= roomId %></option>
                    <% } %>
                </select>
                
                <select id="wardId" name="wardId" onchange="clearRoomSelection()">
                    <option value="">Select Ward</option>
                    <% for (String wardId : wardIds) { %>
                        <option value="<%= wardId %>"><%= wardId %></option>
                    <% } %>
                </select>
            </div>

            <label for="bedDescription">Bed Description:</label>
            <textarea id="bedDescription" name="bedDescription" 
                     placeholder="Enter detailed bed description (type, features, location, etc.)" required></textarea>

            <button type="submit">Save Bed Details</button>
        </form>

        <div class="record-controls">
            <button onclick="window.location.href='searchBed.jsp'">Search Beds</button>
            <button onclick="addNewBed()">Add New Bed</button>
            <button onclick="window.location.href='viewBed.jsp'">View All Beds</button>
            <button onclick="refreshPage()">Refresh</button>
        </div>
    </div>

    <script>
        function refreshPage() {
            window.location.reload();
        }

        function addNewBed() {
            // Don't reset the form as we want to keep the auto-generated bed ID
            document.getElementById('roomId').selectedIndex = 0;
            document.getElementById('wardId').selectedIndex = 0;
            document.getElementById('bedDescription').value = '';
            document.getElementById('roomId').focus();
        }

        function goToHome() {
            window.location.href = 'Home.jsp';
        }

        function clearWardSelection() {
            if (document.getElementById('roomId').value !== '') {
                document.getElementById('wardId').selectedIndex = 0;
            }
        }

        function clearRoomSelection() {
            if (document.getElementById('wardId').value !== '') {
                document.getElementById('roomId').selectedIndex = 0;
            }
        }

        function validateForm() {
            const roomId = document.getElementById('roomId').value;
            const wardId = document.getElementById('wardId').value;
            const bedDescription = document.getElementById('bedDescription').value;

            if (roomId === '' && wardId === '') {
                alert('Please select either a Room or a Ward');
                return false;
            }

            if (roomId !== '' && wardId !== '') {
                alert('Please select either a Room or a Ward, not both');
                return false;
            }

            if (bedDescription.trim() === '') {
                alert('Please enter a Bed Description');
                return false;
            }

            return true;
        }

        window.onload = function() {
            document.getElementById('roomId').focus();
        };
    </script>
</body>
</html>