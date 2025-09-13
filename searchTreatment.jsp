<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Treatment</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .treatment-details {
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
    <div class="treatment-details">
        <h1>Search Treatment</h1>
        <div class="search-bar">
            <form method="get" action="">
                <label for="treatmentId">Treatment ID:</label>
                <input type="text" id="treatmentId" name="treatmentId" placeholder="Enter Treatment ID (e.g. T001)" required>
                <input type="submit" value="Search">
            </form>
        </div>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
            String jdbcUsername = "root";
            String jdbcPassword = "@Sashini123";
            String treatmentIdInput = request.getParameter("treatmentId");
            String editId = request.getParameter("editId");

            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                if (editId != null) {
                    // Handle the edit request
                    if ("POST".equalsIgnoreCase(request.getMethod())) {
                        String patientId = request.getParameter("patientId");
                        String doctorId = request.getParameter("doctorId");
                        String date = request.getParameter("date");
                        String time = request.getParameter("time");
                        String description = request.getParameter("description");
                        String prescriptions = request.getParameter("prescriptions");

                        String updateSql = "UPDATE TreatmentDetails SET patient_id=?, doctor_id=?, appointment_date=?, appointment_time=?, description=?, prescriptions=? WHERE treatment_id=?";
                        preparedStatement = connection.prepareStatement(updateSql);
                        preparedStatement.setString(1, patientId);
                        preparedStatement.setString(2, doctorId);
                        preparedStatement.setString(3, date);
                        preparedStatement.setString(4, time);
                        preparedStatement.setString(5, description);
                        preparedStatement.setString(6, prescriptions);
                        preparedStatement.setString(7, editId);
                        preparedStatement.executeUpdate();
                        out.println("<p class='success'>Treatment details updated successfully!</p>");
                    } else {
                        // Fetch treatment details for editing
                        String selectSql = "SELECT * FROM TreatmentDetails WHERE treatment_id = ?";
                        preparedStatement = connection.prepareStatement(selectSql);
                        preparedStatement.setString(1, editId);
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
        %>
                            <div class="edit-form">
                                <h3>Edit Treatment Details</h3>
                                <form method="post">
                                    <input type="hidden" name="editId" value="<%= resultSet.getString("treatment_id") %>">
                                    
                                    <label for="patientId">Patient ID:</label>
                                    <input type="text" id="patientId" name="patientId" value="<%= resultSet.getString("patient_id") %>" required>
                                    
                                    <label for="doctorId">Doctor ID:</label>
                                    <input type="text" id="doctorId" name="doctorId" value="<%= resultSet.getString("doctor_id") %>" required>
                                    
                                    <label for="date">Date:</label>
                                    <input type="text" id="date" name="date" value="<%= resultSet.getString("appointment_date") %>" required>
                                    
                                    <label for="time">Time:</label>
                                    <input type="text" id="time" name="time" value="<%= resultSet.getString("appointment_time") %>" required>
                                    
                                    <label for="description">Description:</label>
                                    <textarea id="description" name="description"><%= resultSet.getString("description") %></textarea>
                                    
                                    <label for="prescriptions">Prescriptions:</label>
                                    <textarea id="prescriptions" name="prescriptions"><%= resultSet.getString("prescriptions") %></textarea>
                                    
                                    <input type="submit" value="Save Changes">
                                </form>
                            </div>
        <%
                        } else {
                            out.println("<p class='error'>Treatment not found.</p>");
                        }
                    }
                } else if (treatmentIdInput != null && !treatmentIdInput.isEmpty()) {
                    // Validate the input format (must be T followed by 3 digits)
                    if (!treatmentIdInput.matches("^T\\d{3}$")) {
                        throw new Exception("Invalid Treatment ID format. Please use T followed by 3 digits (e.g. T001).");
                    }
                    
                    String sql = "SELECT * FROM TreatmentDetails WHERE treatment_id = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setString(1, treatmentIdInput.toUpperCase());

                    resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String treatmentId = resultSet.getString("treatment_id");
                        String patientId = resultSet.getString("patient_id");
                        String doctorId = resultSet.getString("doctor_id");
                        String date = resultSet.getString("appointment_date");
                        String time = resultSet.getString("appointment_time");
                        String description = resultSet.getString("description");
                        String prescriptions = resultSet.getString("prescriptions");
        %>
                        <div class="result">
                            <h2>Treatment Details</h2>
                            <p><strong>Treatment ID:</strong> <%= treatmentId %></p>
                            <p><strong>Patient ID:</strong> <%= patientId %></p>
                            <p><strong>Doctor ID:</strong> <%= doctorId %></p>
                            <p><strong>Date:</strong> <%= date %></p>
                            <p><strong>Time:</strong> <%= time %></p>
                            <p><strong>Description:</strong> <%= description != null && !description.isEmpty() ? description : "N/A" %></p>
                            <p><strong>Prescriptions:</strong> <%= prescriptions != null && !prescriptions.isEmpty() ? prescriptions : "N/A" %></p>
                            <a href="?editId=<%= treatmentId %>" class="edit-btn">Edit Treatment</a>
                        </div>
        <%
                    } else {
        %>
                        <p class="error">No treatment found with ID: <%= treatmentIdInput.toUpperCase() %></p>
        <%
                    }
                }
            } catch (Exception e) {
        %>
                <p class="error"><%= e.getMessage() %></p>
        <%
                } finally {
                    if (resultSet != null) try { resultSet.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (preparedStatement != null) try { preparedStatement.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (connection != null) try { connection.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
        %>
    </div>
</body>
</html>