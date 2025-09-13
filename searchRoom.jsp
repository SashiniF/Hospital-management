<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Room</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .room-details {
            max-width: 600px;
            margin: auto;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }
        .result {
            margin-top: 20px;
            padding: 10px;
            border: 1px solid #007BFF;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .search-bar {
            margin-bottom: 20px;
        }
        .error {
            color: red;
            margin-top: 10px;
        }
        .success {
            color: green;
        }
        .edit-form {
            max-width: 600px;
            margin: 20px auto;
            padding: 20px;
            border: 1px solid #ccc;
            border-radius: 5px;
            background-color: #f9f9f9;
        }
        .edit-form label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }
        .edit-form input[type="text"], 
        .edit-form input[type="number"], 
        .edit-form textarea,
        .edit-form select {
            width: 100%;
            padding: 8px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .edit-form input[type="submit"] {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .edit-form input[type="submit"]:hover {
            background-color: #45a049;
        }
        .edit-btn {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-top: 10px;
            text-decoration: none;
            display: inline-block;
        }
        .edit-btn:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="room-details">
        <h1>Search Room</h1>
        <div class="search-bar">
            <form method="get" action="">
                <label for="roomId">Room ID:</label>
                <input type="text" id="roomId" name="roomId" placeholder="Enter Room ID (e.g. R001)" required>
                <input type="submit" value="Search">
            </form>
        </div>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
            String jdbcUsername = "root";
            String jdbcPassword = "@Sashini123";

            String roomIdInput = request.getParameter("roomId");
            String editId = request.getParameter("editId");

            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;

            if (editId != null) {
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("editId") != null) {
                        // Handle the update request
                        String roomId = request.getParameter("roomId");
                        String roomType = request.getParameter("roomType");
                        double rate = Double.parseDouble(request.getParameter("rate"));
                        String description = request.getParameter("description");
                        String notes = request.getParameter("notes");

                        String updateSql = "UPDATE RoomDetails SET room_type=?, rate=?, room_description=?, notes=? WHERE room_id=?";
                        preparedStatement = connection.prepareStatement(updateSql);
                        preparedStatement.setString(1, roomType);
                        preparedStatement.setDouble(2, rate);
                        preparedStatement.setString(3, description);
                        preparedStatement.setString(4, notes);
                        preparedStatement.setString(5, roomId);
                        preparedStatement.executeUpdate();
                        out.println("<p class='success'>Room details updated successfully!</p>");
                    } else {
                        // Fetch the room's current details
                        String selectSql = "SELECT * FROM RoomDetails WHERE room_id = ?";
                        preparedStatement = connection.prepareStatement(selectSql);
                        preparedStatement.setString(1, editId);
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
        %>
                            <div class="edit-form">
                                <h3>Edit Room Details</h3>
                                <form method="post">
                                    <input type="hidden" name="editId" value="<%= resultSet.getString("room_id") %>">
                                    
                                    <label for="roomId">Room ID:</label>
                                    <input type="text" id="roomId" name="roomId" value="<%= resultSet.getString("room_id") %>" readonly>
                                    
                                    <label for="roomType">Room Type:</label>
                                    <select id="roomType" name="roomType" required>
                                        <option value="General Ward" <%= resultSet.getString("room_type").equals("General Ward") ? "selected" : "" %>>General Ward</option>
                                        <option value="Private Room" <%= resultSet.getString("room_type").equals("Private Room") ? "selected" : "" %>>Private Room</option>
                                        <option value="ICU" <%= resultSet.getString("room_type").equals("ICU") ? "selected" : "" %>>ICU</option>
                                        <option value="Semi-Private" <%= resultSet.getString("room_type").equals("Semi-Private") ? "selected" : "" %>>Semi-Private</option>
                                        <option value="Pediatric Ward" <%= resultSet.getString("room_type").equals("Pediatric Ward") ? "selected" : "" %>>Pediatric Ward</option>
                                        <option value="Maternity Ward" <%= resultSet.getString("room_type").equals("Maternity Ward") ? "selected" : "" %>>Maternity Ward</option>
                                        <option value="Isolation Room" <%= resultSet.getString("room_type").equals("Isolation Room") ? "selected" : "" %>>Isolation Room</option>
                                    </select>
                                    
                                    <label for="rate">Daily Rate (LKR):</label>
                                    <input type="number" id="rate" name="rate" value="<%= resultSet.getDouble("rate") %>" step="0.01" min="0" required>
                                    
                                    <label for="description">Room Description:</label>
                                    <textarea id="description" name="description"><%= resultSet.getString("room_description") %></textarea>
                                    
                                    <label for="notes">Notes:</label>
                                    <textarea id="notes" name="notes"><%= resultSet.getString("notes") %></textarea>
                                    
                                    <input type="submit" value="Save Changes">
                                </form>
                            </div>
        <%
                        } else {
                            out.println("<p class='error'>Room not found.</p>");
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    out.println("<p class='error'>An error occurred: " + e.getMessage() + "</p>");
                } finally {
                    if (resultSet != null) resultSet.close();
                    if (preparedStatement != null) preparedStatement.close();
                    if (connection != null) connection.close();
                }
            } else if (roomIdInput != null && !roomIdInput.isEmpty()) {
                try {
                    // Validate the input format (must be R followed by 3 digits)
                    if (!roomIdInput.matches("^R\\d{3}$")) {
                        throw new Exception("Invalid Room ID format. Please use R followed by 3 digits (e.g. R001).");
                    }
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                    String sql = "SELECT * FROM RoomDetails WHERE room_id = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setString(1, roomIdInput.toUpperCase());

                    resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String roomId = resultSet.getString("room_id");
                        String roomType = resultSet.getString("room_type");
                        double rate = resultSet.getDouble("rate");
                        String description = resultSet.getString("room_description");
                        String notes = resultSet.getString("notes");
        %>
                        <div class="result">
                            <h2>Room Details</h2>
                            <p><strong>Room ID:</strong> <%= roomId %></p>
                            <p><strong>Room Type:</strong> <%= roomType %></p>
                            <p><strong>Daily Rate:</strong> LKR <%= String.format("%,.2f", rate) %></p>
                            <p><strong>Description:</strong> <%= description != null && !description.isEmpty() ? description : "N/A" %></p>
                            <p><strong>Notes:</strong> <%= notes != null && !notes.isEmpty() ? notes : "N/A" %></p>
                            <a href="?editId=<%= roomId %>" class="edit-btn">Edit Room</a>
                        </div>
        <%
                    } else {
        %>
                        <p class="error">No room found with ID: <%= roomIdInput.toUpperCase() %></p>
        <%
                    }
                } catch (Exception e) {
        %>
                    <p class="error"><%= e.getMessage() %></p>
        <%
                    e.printStackTrace();
                } finally {
                    if (resultSet != null) try { resultSet.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (preparedStatement != null) try { preparedStatement.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (connection != null) try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
            }
        %>
    </div>
</body>
</html>