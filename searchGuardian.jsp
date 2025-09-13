<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Guardians</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .guardian-details {
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
        .edit-form input[type="tel"],
        .edit-form textarea {
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
    <div class="guardian-details">
        <h1>Search Guardians</h1>
        <div class="search-bar">
            <form method="get" action="">
                <label for="guardianId">Guardian ID:</label>
                <input type="text" id="guardianId" name="guardianId" placeholder="Enter Guardian ID (e.g. G001)" required>
                <input type="submit" value="Search">
            </form>
        </div>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
            String jdbcUsername = "root";
            String jdbcPassword = "@Sashini123";

            String guardianIdInput = request.getParameter("guardianId");
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
                        String firstName = request.getParameter("firstName");
                        String lastName = request.getParameter("lastName");
                        String nicNumber = request.getParameter("nicNumber");
                        String address = request.getParameter("address");
                        String phoneNumber = request.getParameter("phoneNumber");
                        String occupation = request.getParameter("occupation");

                        String updateSql = "UPDATE GuardianDetails SET first_name=?, last_name=?, nic_number=?, address=?, phone_number=?, occupation=? WHERE guardian_id=?";
                        preparedStatement = connection.prepareStatement(updateSql);
                        preparedStatement.setString(1, firstName);
                        preparedStatement.setString(2, lastName);
                        preparedStatement.setString(3, nicNumber);
                        preparedStatement.setString(4, address);
                        preparedStatement.setString(5, phoneNumber);
                        preparedStatement.setString(6, occupation);
                        preparedStatement.setString(7, editId);
                        preparedStatement.executeUpdate();
                        out.println("<p class='success'>Guardian details updated successfully!</p>");
                    } else {
                        // Fetch the guardian's current details
                        String selectSql = "SELECT * FROM GuardianDetails WHERE guardian_id = ?";
                        preparedStatement = connection.prepareStatement(selectSql);
                        preparedStatement.setString(1, editId);
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
        %>
                            <div class="edit-form">
                                <h3>Edit Guardian Details</h3>
                                <form method="post">
                                    <input type="hidden" name="editId" value="<%= resultSet.getString("guardian_id") %>">
                                    
                                    <label for="guardianId">Guardian ID:</label>
                                    <input type="text" id="guardianId" name="guardianId" value="<%= resultSet.getString("guardian_id") %>" readonly>
                                    
                                    <label for="firstName">First Name:</label>
                                    <input type="text" id="firstName" name="firstName" value="<%= resultSet.getString("first_name") %>" required>
                                    
                                    <label for="lastName">Last Name:</label>
                                    <input type="text" id="lastName" name="lastName" value="<%= resultSet.getString("last_name") %>" required>
                                    
                                    <label for="nicNumber">NIC Number:</label>
                                    <input type="text" id="nicNumber" name="nicNumber" value="<%= resultSet.getString("nic_number") %>" required>
                                    
                                    <label for="address">Address:</label>
                                    <input type="text" id="address" name="address" value="<%= resultSet.getString("address") %>" required>
                                    
                                    <label for="phoneNumber">Phone Number:</label>
                                    <input type="tel" id="phoneNumber" name="phoneNumber" value="<%= resultSet.getString("phone_number") %>" required>
                                    
                                    <label for="occupation">Occupation:</label>
                                    <input type="text" id="occupation" name="occupation" value="<%= resultSet.getString("occupation") %>" required>
                                    
                                    <input type="submit" value="Save Changes">
                                </form>
                            </div>
        <%
                        } else {
                            out.println("<p class='error'>Guardian not found.</p>");
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
            } else if (guardianIdInput != null && !guardianIdInput.isEmpty()) {
                try {
                    // Validate the input format (must be G followed by 3 digits)
                    if (!guardianIdInput.matches("^G\\d{3}$")) {
                        throw new Exception("Invalid Guardian ID format. Please use G followed by 3 digits (e.g. G001).");
                    }
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                    String sql = "SELECT * FROM GuardianDetails WHERE guardian_id = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setString(1, guardianIdInput.toUpperCase());

                    resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String guardianId = resultSet.getString("guardian_id");
                        String firstName = resultSet.getString("first_name");
                        String lastName = resultSet.getString("last_name");
                        String nicNumber = resultSet.getString("nic_number");
                        String address = resultSet.getString("address");
                        String phoneNumber = resultSet.getString("phone_number");
                        String occupation = resultSet.getString("occupation");
                        Timestamp createdAt = resultSet.getTimestamp("created_at");
        %>
                        <div class="result">
                            <h2>Guardian Details</h2>
                            <p><strong>Guardian ID:</strong> <%= guardianId %></p>
                            <p><strong>First Name:</strong> <%= firstName %></p>
                            <p><strong>Last Name:</strong> <%= lastName %></p>
                            <p><strong>NIC Number:</strong> <%= nicNumber %></p>
                            <p><strong>Address:</strong> <%= address %></p>
                            <p><strong>Phone Number:</strong> <%= phoneNumber %></p>
                            <p><strong>Occupation:</strong> <%= occupation %></p>
                            <p><strong>Created At:</strong> <%= createdAt %></p>
                            <a href="?editId=<%= guardianId %>" class="edit-btn">Edit Guardian</a>
                        </div>
        <%
                    } else {
        %>
                        <p class="error">No guardian found with ID: <%= guardianIdInput.toUpperCase() %></p>
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