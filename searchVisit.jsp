<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Visit</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .visit-details {
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
        .edit-form input[type="text"], .edit-form input[type="datetime-local"], .edit-form textarea {
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
    <div class="visit-details">
        <h1>Search Visit</h1>
        <div class="search-bar">
            <form method="get" action="">
                <label for="visitId">Visit ID:</label>
                <input type="text" id="visitId" name="visitId" placeholder="Enter Visit ID (e.g. V001)" required>
                <input type="submit" value="Search">
            </form>
        </div>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
            String jdbcUsername = "root";
            String jdbcPassword = "@Sashini123";

            String visitIdInput = request.getParameter("visitId");
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
                        String visitDate = request.getParameter("visitDate");
                        String doctorId = request.getParameter("doctorId");
                        String admissionId = request.getParameter("admissionId");
                        String patientId = request.getParameter("patientId");
                        String description = request.getParameter("description");

                        String updateSql = "UPDATE VisitDetails SET visit_date=?, doctor_id=?, admission_id=?, patient_id=?, description=? WHERE visit_id=?";
                        preparedStatement = connection.prepareStatement(updateSql);
                        preparedStatement.setString(1, visitDate);
                        preparedStatement.setString(2, doctorId);
                        preparedStatement.setString(3, admissionId);
                        preparedStatement.setString(4, patientId);
                        preparedStatement.setString(5, description);
                        preparedStatement.setString(6, editId);
                        preparedStatement.executeUpdate();
                        out.println("<p class='success'>Visit details updated successfully!</p>");
                    } else {
                        // Fetch the visit's current details
                        String selectSql = "SELECT * FROM VisitDetails WHERE visit_id = ?";
                        preparedStatement = connection.prepareStatement(selectSql);
                        preparedStatement.setString(1, editId);
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
        %>
                            <div class="edit-form">
                                <h3>Edit Visit Details</h3>
                                <form method="post">
                                    <input type="hidden" name="editId" value="<%= resultSet.getString("visit_id") %>">
                                    
                                    <label for="visitDate">Visit Date:</label>
                                    <input type="datetime-local" id="visitDate" name="visitDate" value="<%= resultSet.getString("visit_date").replace(" ", "T") %>" required>

                                    <label for="doctorId">Doctor ID:</label>
                                    <input type="text" id="doctorId" name="doctorId" value="<%= resultSet.getString("doctor_id") %>" required>

                                    <label for="admissionId">Admission ID:</label>
                                    <input type="text" id="admissionId" name="admissionId" value="<%= resultSet.getString("admission_id") %>" required>

                                    <label for="patientId">Patient ID:</label>
                                    <input type="text" id="patientId" name="patientId" value="<%= resultSet.getString("patient_id") %>" required>

                                    <label for="description">Description:</label>
                                    <textarea id="description" name="description" required><%= resultSet.getString("description") %></textarea>

                                    <input type="submit" value="Save Changes">
                                </form>
                            </div>
        <%
                        } else {
                            out.println("<p class='error'>Visit not found.</p>");
                        }
                    }
                } else if (visitIdInput != null && !visitIdInput.isEmpty()) {
                    // Validate the input format (must be V followed by 3 digits)
                    if (!visitIdInput.matches("^V\\d{3}$")) {
                        throw new Exception("Invalid Visit ID format. Please use V followed by 3 digits (e.g. V001).");
                    }
                    
                    // Search for the visit
                    String sql = "SELECT * FROM VisitDetails WHERE visit_id = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setString(1, visitIdInput);

                    resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String visitDate = resultSet.getString("visit_date");
                        String doctorId = resultSet.getString("doctor_id");
                        String admissionId = resultSet.getString("admission_id");
                        String patientId = resultSet.getString("patient_id");
                        String description = resultSet.getString("description");
        %>
                        <div class="result">
                            <h2>Visit Details</h2>
                            <p><strong>ID:</strong> <%= visitIdInput.toUpperCase() %></p>
                            <p><strong>Visit Date:</strong> <%= visitDate %></p>
                            <p><strong>Doctor ID:</strong> <%= doctorId %></p>
                            <p><strong>Admission ID:</strong> <%= admissionId %></p>
                            <p><strong>Patient ID:</strong> <%= patientId %></p>
                            <p><strong>Description:</strong> <%= description != null ? description : "-" %></p>
                            <a href="?editId=<%= visitIdInput %>" class="edit-btn">Edit Visit</a>
                        </div>
        <%
                    } else {
        %>
                        <p class="error">No visit found with ID: <%= visitIdInput.toUpperCase() %></p>
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