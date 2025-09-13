<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Search Medical Service</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            padding: 20px;
        }
        h1, h2 {
            color: #333;
        }
        .edit-form {
            max-width: 600px;
            margin: 20px auto;
            padding: 20px;
            background-color: #fff;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            display: none; /* Hidden by default */
        }
        .edit-form label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
        }
        .edit-form input[type="text"], 
        .edit-form input[type="number"],
        .edit-form textarea {
            width: 100%;
            padding: 10px;
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
        .service-details {
            background-color: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            margin: 20px 0;
        }
        .action-buttons {
            margin: 15px 0;
        }
        .edit-btn {
            background-color: #4CAF50;
            color: white;
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-right: 10px;
        }
        .edit-btn:hover {
            background-color: #45a049;
        }
    </style>
    <script>
        function showEditForm() {
            document.getElementById("editForm").style.display = 'block';
        }
    </script>
</head>
<body>
    <h1>Search Medical Service</h1>
    <form method="get" action="">
        <label for="serviceId">Service ID:</label>
        <input type="text" id="serviceId" name="serviceId">
        <input type="submit" value="Search">
    </form>

    <%
        // Database connection details
        String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
        String jdbcUsername = "root";
        String jdbcPassword = "@Sashini123";

        // Get the service ID from the request
        String serviceId = request.getParameter("serviceId");

        if (serviceId != null && !serviceId.isEmpty()) {
            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;

            try {
                // Load the JDBC driver
                Class.forName("com.mysql.cj.jdbc.Driver");

                // Establish the database connection
                connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                // Handle update request
                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    String editId = request.getParameter("editId");
                    String serviceName = request.getParameter("serviceName");
                    int duration = Integer.parseInt(request.getParameter("duration"));
                    double charge = Double.parseDouble(request.getParameter("charge"));
                    String notes = request.getParameter("notes");

                    String updateSql = "UPDATE MedicalServices SET Channel_Service=?, Duration_Of_Service=?, Charge_For_Service=?, Service_Notes=? WHERE Channel_Service_ID=?";
                    PreparedStatement updateStmt = connection.prepareStatement(updateSql);
                    updateStmt.setString(1, serviceName);
                    updateStmt.setInt(2, duration);
                    updateStmt.setDouble(3, charge);
                    updateStmt.setString(4, notes);
                    updateStmt.setString(5, editId);
                    updateStmt.executeUpdate();
    %>
                    <p style="color:green;">Service updated successfully!</p>
    <%
                }

                // Prepare the SQL query
                String sql = "SELECT * FROM MedicalServices WHERE Channel_Service_ID = ?";
                preparedStatement = connection.prepareStatement(sql);
                preparedStatement.setString(1, serviceId);

                // Execute the query
                resultSet = preparedStatement.executeQuery();

                // Display the results
                if (resultSet.next()) {
                    String channelService = resultSet.getString("Channel_Service");
                    int durationOfService = resultSet.getInt("Duration_Of_Service");
                    double chargeForService = resultSet.getDouble("Charge_For_Service");
                    String serviceNotes = resultSet.getString("Service_Notes");
    %>
                    <div class="service-details">
                        <h2>Service Details</h2>
                        <p><strong>Service ID:</strong> <%= serviceId %></p>
                        <p><strong>Service Name:</strong> <%= channelService %></p>
                        <p><strong>Duration:</strong> <%= durationOfService %> minutes</p>
                        <p><strong>Charge:</strong> $<%= chargeForService %></p>
                        <p><strong>Notes:</strong> <%= serviceNotes %></p>
                        
                        <div class="action-buttons">
                            <button class="edit-btn" onclick="showEditForm()">Edit Service</button>
                        </div>
                    </div>
                    
                    <!-- Edit Form -->
                    <div id="editForm" class="edit-form">
                        <h2>Edit Medical Service</h2>
                        <form method="post">
                            <input type="hidden" name="editId" value="<%= serviceId %>">
                            
                            <label for="serviceName">Service Name:</label>
                            <input type="text" id="serviceName" name="serviceName" value="<%= channelService %>" required>
                            
                            <label for="duration">Duration (min):</label>
                            <input type="number" id="duration" name="duration" value="<%= durationOfService %>" required>
                            
                            <label for="charge">Charge:</label>
                            <input type="number" id="charge" name="charge" value="<%= chargeForService %>" step="0.01" required>
                            
                            <label for="notes">Notes:</label>
                            <textarea id="notes" name="notes"><%= serviceNotes != null ? serviceNotes : "" %></textarea>
                            
                            <input type="submit" value="Save Changes">
                        </form>
                    </div>
    <%
                } else {
    %>
                    <p>No service found with ID: <%= serviceId %></p>
    <%
                }
            } catch (Exception e) {
                e.printStackTrace();
    %>
                <p style="color:red;">An error occurred: <%= e.getMessage() %></p>
    <%
            } finally {
                // Close the database resources
                try {
                    if (resultSet != null) resultSet.close();
                    if (preparedStatement != null) preparedStatement.close();
                    if (connection != null) connection.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    %>
</body>
</html>