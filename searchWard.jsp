<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Ward</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .ward-details {
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
        .edit-form input[type="text"], .edit-form input[type="number"], .edit-form textarea {
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
        }
        .edit-btn:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <div class="ward-details">
        <h1>Search Ward</h1>
        <div class="search-bar">
            <form method="get" action="">
                <label for="wardId">Ward ID:</label>
                <input type="text" id="wardId" name="wardId" placeholder="Enter Ward ID (e.g. W001)" required>
                <input type="submit" value="Search">
            </form>
        </div>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
            String jdbcUsername = "root";
            String jdbcPassword = "@Sashini123";

            String wardIdInput = request.getParameter("wardId");
            String editId = request.getParameter("editId");

            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                if (editId != null) {
                    if ("POST".equalsIgnoreCase(request.getMethod())) {
                        // Handle the update request
                        int id = Integer.parseInt(request.getParameter("editId"));
                        String wardType = request.getParameter("wardType");
                        double rate = Double.parseDouble(request.getParameter("rate"));
                        String notes = request.getParameter("notes");

                        String updateSql = "UPDATE WardDetails SET ward_type=?, rate=?, notes=? WHERE ward_id=?";
                        preparedStatement = connection.prepareStatement(updateSql);
                        preparedStatement.setString(1, wardType);
                        preparedStatement.setDouble(2, rate);
                        preparedStatement.setString(3, notes);
                        preparedStatement.setString(4, editId);
                        preparedStatement.executeUpdate();
                        out.println("<p class='success'>Ward details updated successfully!</p>");
                    } else {
                        // Fetch the ward's current details
                        String selectSql = "SELECT * FROM WardDetails WHERE ward_id = ?";
                        preparedStatement = connection.prepareStatement(selectSql);
                        preparedStatement.setString(1, editId);
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
        %>
                            <div class="edit-form">
                                <h3>Edit Ward Details</h3>
                                <form method="post">
                                    <input type="hidden" name="editId" value="<%= resultSet.getString("ward_id") %>">
                                    <label for="wardType">Ward Type:</label>
                                    <input type="text" id="wardType" name="wardType" value="<%= resultSet.getString("ward_type") %>" required>

                                    <label for="rate">Daily Rate:</label>
                                    <input type="number" id="rate" name="rate" value="<%= resultSet.getDouble("rate") %>" required>

                                    <label for="notes">Notes:</label>
                                    <textarea id="notes" name="notes"><%= resultSet.getString("notes") %></textarea>

                                    <input type="submit" value="Save Changes">
                                </form>
                            </div>
        <%
                        } else {
                            out.println("<p class='error'>Ward not found.</p>");
                        }
                    }
                } else if (wardIdInput != null && !wardIdInput.isEmpty()) {
                    // Validate the input format (must be W followed by 3 digits)
                    if (!wardIdInput.matches("^W\\d{3}$")) {
                        throw new Exception("Invalid Ward ID format. Please use W followed by 3 digits (e.g. W001).");
                    }
                    
                    // Search for the ward
                    String sql = "SELECT * FROM WardDetails WHERE ward_id = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setString(1, wardIdInput);

                    resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String wardType = resultSet.getString("ward_type");
                        double rate = resultSet.getDouble("rate");
                        String notes = resultSet.getString("notes");
        %>
                        <div class="result">
                            <h2>Ward Details</h2>
                            <p><strong>ID:</strong> <%= wardIdInput.toUpperCase() %></p>
                            <p><strong>Ward Type:</strong> <%= wardType %></p>
                            <p><strong>Daily Rate:</strong> LKR <%= rate %></p>
                            <p><strong>Notes:</strong> <%= notes != null ? notes : "-" %></p>
                            <a href="?editId=<%= wardIdInput %>" class="edit-btn">Edit Ward</a>
                        </div>
        <%
                    } else {
        %>
                        <p class="error">No ward found with ID: <%= wardIdInput.toUpperCase() %></p>
        <%
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
                out.println("<p class='error'>An error occurred: " + e.getMessage() + "</p>");
            } finally {
                if (resultSet != null) try { resultSet.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (preparedStatement != null) try { preparedStatement.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (connection != null) try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        %>
    </div>
</body>
</html>