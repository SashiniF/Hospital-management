<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Admissions</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .admission-details {
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
    <div class="admission-details">
        <h1>Search Admissions</h1>
        <div class="search-bar">
            <form method="get" action="">
                <label for="admissionId">Admission ID:</label>
                <input type="text" id="admissionId" name="admissionId" placeholder="Enter Admission ID (e.g. A001)" required>
                <input type="submit" value="Search">
            </form>
        </div>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
            String jdbcUsername = "root";
            String jdbcPassword = "@Sashini123";

            String admissionIdInput = request.getParameter("admissionId");
            String editId = request.getParameter("editId");

            Connection connection = null;
            PreparedStatement preparedStatement = null;
            ResultSet resultSet = null;

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                if (editId != null) {
                    if ("POST".equalsIgnoreCase(request.getMethod()) && request.getParameter("editId") != null) {
                        // Handle the update request
                        String patientId = request.getParameter("patientId");
                        String guardianId = request.getParameter("guardianId");
                        String roomWardId = request.getParameter("roomWardId");
                        String admissionDate = request.getParameter("admissionDate");
                        String emergency = request.getParameter("emergency");
                        String admissionTime = request.getParameter("admissionTime");
                        String referredDoctor = request.getParameter("referredDoctor");
                        String bedId = request.getParameter("bedId");

                        String updateSql = "UPDATE AdmissionDetails SET patient_id=?, guardian_id=?, room_ward_id=?, admission_date=?, emergency=?, admission_time=?, referred_doctor=?, bed_id=? WHERE admission_id=?";
                        preparedStatement = connection.prepareStatement(updateSql);
                        preparedStatement.setString(1, patientId);
                        preparedStatement.setString(2, guardianId);
                        preparedStatement.setString(3, roomWardId);
                        preparedStatement.setString(4, admissionDate);
                        preparedStatement.setString(5, emergency);
                        preparedStatement.setString(6, admissionTime);
                        preparedStatement.setString(7, referredDoctor);
                        preparedStatement.setString(8, bedId);
                        preparedStatement.setString(9, editId);
                        preparedStatement.executeUpdate();
                        out.println("<p class='success'>Admission details updated successfully!</p>");
                    } else {
                        // Fetch the admission's current details
                        String selectSql = "SELECT * FROM AdmissionDetails WHERE admission_id = ?";
                        preparedStatement = connection.prepareStatement(selectSql);
                        preparedStatement.setString(1, editId);
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
        %>
                            <div class="edit-form">
                                <h3>Edit Admission Details</h3>
                                <form method="post">
                                    <input type="hidden" name="editId" value="<%= resultSet.getString("admission_id") %>">
                                    
                                    <label for="admissionId">Admission ID:</label>
                                    <input type="text" id="admissionId" name="admissionId" value="<%= resultSet.getString("admission_id") %>" readonly>
                                    
                                    <label for="patientId">Patient ID:</label>
                                    <input type="text" id="patientId" name="patientId" value="<%= resultSet.getString("patient_id") %>" required>
                                    
                                    <label for="guardianId">Guardian ID:</label>
                                    <input type="text" id="guardianId" name="guardianId" value="<%= resultSet.getString("guardian_id") %>" required>
                                    
                                    <label for="roomWardId">Room/Ward ID:</label>
                                    <input type="text" id="roomWardId" name="roomWardId" value="<%= resultSet.getString("room_ward_id") %>" required>
                                    
                                    <label for="admissionDate">Admission Date:</label>
                                    <input type="text" id="admissionDate" name="admissionDate" value="<%= resultSet.getString("admission_date") %>" required>
                                    
                                    <label for="emergency">Emergency:</label>
                                    <input type="text" id="emergency" name="emergency" value="<%= resultSet.getString("emergency") %>" required>
                                    
                                    <label for="admissionTime">Admission Time:</label>
                                    <input type="text" id="admissionTime" name="admissionTime" value="<%= resultSet.getString("admission_time") %>" required>
                                    
                                    <label for="referredDoctor">Referred Doctor:</label>
                                    <input type="text" id="referredDoctor" name="referredDoctor" value="<%= resultSet.getString("referred_doctor") %>" required>
                                    
                                    <label for="bedId">Bed ID:</label>
                                    <input type="text" id="bedId" name="bedId" value="<%= resultSet.getString("bed_id") %>" required>
                                    
                                    <input type="submit" value="Save Changes">
                                </form>
                            </div>
        <%
                        } else {
                            out.println("<p class='error'>Admission not found.</p>");
                        }
                    }
                } else if (admissionIdInput != null && !admissionIdInput.isEmpty()) {
                    String sql = "SELECT * FROM AdmissionDetails WHERE admission_id = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setString(1, admissionIdInput.toUpperCase());

                    resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String admissionId = resultSet.getString("admission_id");
                        String patientId = resultSet.getString("patient_id");
                        String guardianId = resultSet.getString("guardian_id");
                        String roomWardId = resultSet.getString("room_ward_id");
                        String admissionDate = resultSet.getString("admission_date");
                        String emergency = resultSet.getString("emergency");
                        String admissionTime = resultSet.getString("admission_time");
                        String referredDoctor = resultSet.getString("referred_doctor");
                        String bedId = resultSet.getString("bed_id");
                        Timestamp createdAt = resultSet.getTimestamp("created_at");
        %>
                        <div class="result">
                            <h2>Admission Details</h2>
                            <p><strong>Admission ID:</strong> <%= admissionId %></p>
                            <p><strong>Patient ID:</strong> <%= patientId %></p>
                            <p><strong>Guardian ID:</strong> <%= guardianId %></p>
                            <p><strong>Room/Ward ID:</strong> <%= roomWardId %></p>
                            <p><strong>Admission Date:</strong> <%= admissionDate %></p>
                            <p><strong>Emergency:</strong> <%= emergency %></p>
                            <p><strong>Admission Time:</strong> <%= admissionTime %></p>
                            <p><strong>Referred Doctor:</strong> <%= referredDoctor %></p>
                            <p><strong>Bed ID:</strong> <%= bedId %></p>
                            <p><strong>Created At:</strong> <%= createdAt %></p>
                            <a href="?editId=<%= admissionId %>" class="edit-btn">Edit Admission</a>
                        </div>
        <%
                    } else {
                        out.println("<p class='error'>No admission found with ID: " + admissionIdInput.toUpperCase() + "</p>");
                    }
                }
            } catch (Exception e) {
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