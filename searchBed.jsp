<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Beds</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .bed-details {
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
    <div class="bed-details">
        <h1>Search Beds</h1>
        <div class="search-bar">
            <form method="get" action="">
                <label for="bedId">Bed ID:</label>
                <input type="text" id="bedId" name="bedId" placeholder="Enter Bed ID (e.g. B001)" required>
                <input type="submit" value="Search">
            </form>
        </div>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
            String jdbcUsername = "root";
            String jdbcPassword = "@Sashini123";

            String bedIdInput = request.getParameter("bedId");
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
                        String bedId = request.getParameter("bedId");
                        String roomId = request.getParameter("roomId");
                        String wardId = request.getParameter("wardId");
                        String description = request.getParameter("description");

                        String updateSql = "UPDATE BedDetails SET room_id=?, ward_id=?, bed_description=? WHERE bed_id=?";
                        preparedStatement = connection.prepareStatement(updateSql);
                        preparedStatement.setString(1, roomId.isEmpty() ? null : roomId);
                        preparedStatement.setString(2, wardId.isEmpty() ? null : wardId);
                        preparedStatement.setString(3, description);
                        preparedStatement.setString(4, bedId);
                        preparedStatement.executeUpdate();
                        out.println("<p class='success'>Bed details updated successfully!</p>");
                    } else {
                        // Fetch the bed's current details
                        String selectSql = "SELECT * FROM BedDetails WHERE bed_id = ?";
                        preparedStatement = connection.prepareStatement(selectSql);
                        preparedStatement.setString(1, editId);
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
        %>
                            <div class="edit-form">
                                <h3>Edit Bed Details</h3>
                                <form method="post">
                                    <input type="hidden" name="editId" value="<%= resultSet.getString("bed_id") %>">
                                    
                                    <label for="bedId">Bed ID:</label>
                                    <input type="text" id="bedId" name="bedId" value="<%= resultSet.getString("bed_id") %>" readonly>
                                    
                                    <label for="roomId">Room ID:</label>
                                    <input type="text" id="roomId" name="roomId" value="<%= resultSet.getString("room_id") != null ? resultSet.getString("room_id") : "" %>" placeholder="Leave empty if not assigned">
                                    
                                    <label for="wardId">Ward ID:</label>
                                    <input type="text" id="wardId" name="wardId" value="<%= resultSet.getString("ward_id") != null ? resultSet.getString("ward_id") : "" %>" placeholder="Leave empty if not assigned">
                                    
                                    <label for="description">Bed Description:</label>
                                    <textarea id="description" name="description"><%= resultSet.getString("bed_description") %></textarea>
                                    
                                    <input type="submit" value="Save Changes">
                                </form>
                            </div>
        <%
                        } else {
                            out.println("<p class='error'>Bed not found.</p>");
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
            } else if (bedIdInput != null && !bedIdInput.isEmpty()) {
                try {
                    // Validate the input format (must be B followed by 3 digits)
                    if (!bedIdInput.matches("^B\\d{3}$")) {
                        throw new Exception("Invalid Bed ID format. Please use B followed by 3 digits (e.g. B001).");
                    }
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                    String sql = "SELECT * FROM BedDetails WHERE bed_id = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setString(1, bedIdInput.toUpperCase());

                    resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String bedId = resultSet.getString("bed_id");
                        String roomId = resultSet.getString("room_id");
                        String wardId = resultSet.getString("ward_id");
                        String description = resultSet.getString("bed_description");
                        Timestamp createdAt = resultSet.getTimestamp("created_at");
        %>
                        <div class="result">
                            <h2>Bed Details</h2>
                            <p><strong>Bed ID:</strong> <%= bedId %></p>
                            <p><strong>Room ID:</strong> <%= roomId != null ? roomId : "Not assigned" %></p>
                            <p><strong>Ward ID:</strong> <%= wardId != null ? wardId : "Not assigned" %></p>
                            <p><strong>Description:</strong> <%= description != null && !description.isEmpty() ? description : "N/A" %></p>
                            <p><strong>Created At:</strong> <%= createdAt %></p>
                            <a href="?editId=<%= bedId %>" class="edit-btn">Edit Bed</a>
                        </div>
        <%
                    } else {
        %>
                        <p class="error">No bed found with ID: <%= bedIdInput.toUpperCase() %></p>
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