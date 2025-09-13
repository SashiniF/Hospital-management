<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Categories</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .category-details {
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
    <div class="category-details">
        <h1>Search Categories</h1>
        <div class="search-bar">
            <form method="get" action="">
                <label for="categoryId">Category ID:</label>
                <input type="text" id="categoryId" name="categoryId" placeholder="Enter Category ID (e.g. CM001)" required>
                <input type="submit" value="Search">
            </form>
        </div>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
            String jdbcUsername = "root";
            String jdbcPassword = "@Sashini123";

            String categoryIdInput = request.getParameter("categoryId");
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
                        String categoryId = request.getParameter("categoryId");
                        String description = request.getParameter("description");

                        String updateSql = "UPDATE MedicineCategories SET category_description=? WHERE category_id=?";
                        preparedStatement = connection.prepareStatement(updateSql);
                        preparedStatement.setString(1, description);
                        preparedStatement.setString(2, categoryId);
                        preparedStatement.executeUpdate();
                        out.println("<p class='success'>Category details updated successfully!</p>");
                    } else {
                        // Fetch the category's current details
                        String selectSql = "SELECT * FROM MedicineCategories WHERE category_id = ?";
                        preparedStatement = connection.prepareStatement(selectSql);
                        preparedStatement.setString(1, editId);
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
        %>
                            <div class="edit-form">
                                <h3>Edit Category Details</h3>
                                <form method="post">
                                    <input type="hidden" name="editId" value="<%= resultSet.getString("category_id") %>">
                                    
                                    <label for="categoryId">Category ID:</label>
                                    <input type="text" id="categoryId" name="categoryId" value="<%= resultSet.getString("category_id") %>" readonly>
                                    
                                    <label for="description">Category Description:</label>
                                    <textarea id="description" name="description"><%= resultSet.getString("category_description") %></textarea>
                                    
                                    <input type="submit" value="Save Changes">
                                </form>
                            </div>
        <%
                        } else {
                            out.println("<p class='error'>Category not found.</p>");
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
            } else if (categoryIdInput != null && !categoryIdInput.isEmpty()) {
                try {
                    // Validate the input format (must be CM followed by 3 digits)
                    if (!categoryIdInput.matches("^CM\\d{3}$")) {
                        throw new Exception("Invalid Category ID format. Please use CM followed by 3 digits (e.g. CM001).");
                    }
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                    String sql = "SELECT * FROM MedicineCategories WHERE category_id = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setString(1, categoryIdInput.toUpperCase());

                    resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String categoryId = resultSet.getString("category_id");
                        String description = resultSet.getString("category_description");
        %>
                        <div class="result">
                            <h2>Category Details</h2>
                            <p><strong>Category ID:</strong> <%= categoryId %></p>
                            <p><strong>Description:</strong> <%= description != null && !description.isEmpty() ? description : "N/A" %></p>
                            <a href="?editId=<%= categoryId %>" class="edit-btn">Edit Category</a>
                        </div>
        <%
                    } else {
        %>
                        <p class="error">No category found with ID: <%= categoryIdInput.toUpperCase() %></p>
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