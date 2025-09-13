<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Doctor</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 20px;
        }
        .doctor-details {
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
    <div class="doctor-details">
        <h1>Search Doctor</h1>
        <div class="search-bar">
            <form method="get" action="">
                <label for="doctorId">Doctor ID:</label>
                <input type="text" id="doctorId" name="doctorId" placeholder="Enter Doctor ID (e.g. D00X)" required>
                <input type="submit" value="Search">
            </form>
        </div>

        <%
            String jdbcURL = "jdbc:mysql://localhost:3306/hospital";
            String jdbcUsername = "root";
            String jdbcPassword = "@Sashini123";

            String doctorIdInput = request.getParameter("doctorId");
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
                        int id = Integer.parseInt(request.getParameter("editId"));
                        String firstName = request.getParameter("firstName");
                        String lastName = request.getParameter("lastName");
                        String sex = request.getParameter("sex");
                        String nicNo = request.getParameter("nicNo");
                        String mobilePhone = request.getParameter("mobilePhone");
                        String homePhone = request.getParameter("homePhone");
                        String address = request.getParameter("address");
                        String qualifications = request.getParameter("qualifications");
                        String specialization = request.getParameter("specialization");
                        String doctorType = request.getParameter("doctorType");
                        double visitingCharge = Double.parseDouble(request.getParameter("visitingCharge"));
                        double channelingCharge = Double.parseDouble(request.getParameter("channelingCharge"));
                        double baseSalary = Double.parseDouble(request.getParameter("baseSalary"));
                        String notes = request.getParameter("notes");

                        String updateSql = "UPDATE Doctors SET firstName=?, lastName=?, sex=?, nicNo=?, mobilePhone=?, homePhone=?, address=?, qualifications=?, specialization=?, doctorType=?, visitingCharge=?, channelingCharge=?, baseSalary=?, notes=? WHERE id=?";
                        preparedStatement = connection.prepareStatement(updateSql);
                        preparedStatement.setString(1, firstName);
                        preparedStatement.setString(2, lastName);
                        preparedStatement.setString(3, sex);
                        preparedStatement.setString(4, nicNo);
                        preparedStatement.setString(5, mobilePhone);
                        preparedStatement.setString(6, homePhone);
                        preparedStatement.setString(7, address);
                        preparedStatement.setString(8, qualifications);
                        preparedStatement.setString(9, specialization);
                        preparedStatement.setString(10, doctorType);
                        preparedStatement.setDouble(11, visitingCharge);
                        preparedStatement.setDouble(12, channelingCharge);
                        preparedStatement.setDouble(13, baseSalary);
                        preparedStatement.setString(14, notes);
                        preparedStatement.setInt(15, id);
                        preparedStatement.executeUpdate();
                        out.println("<p class='success'>Doctor details updated successfully!</p>");
                    } else {
                        // Fetch the doctor's current details
                        String selectSql = "SELECT * FROM Doctors WHERE id = ?";
                        preparedStatement = connection.prepareStatement(selectSql);
                        preparedStatement.setInt(1, Integer.parseInt(editId));
                        resultSet = preparedStatement.executeQuery();

                        if (resultSet.next()) {
        %>
                            <div class="edit-form">
                                <h3>Edit Doctor Details</h3>
                                <form method="post">
                                    <input type="hidden" name="editId" value="<%= resultSet.getInt("id") %>">
                                    <label for="firstName">First Name:</label>
                                    <input type="text" id="firstName" name="firstName" value="<%= resultSet.getString("firstName") %>" required>

                                    <label for="lastName">Last Name:</label>
                                    <input type="text" id="lastName" name="lastName" value="<%= resultSet.getString("lastName") %>" required>

                                    <label for="sex">Sex:</label>
                                    <input type="text" id="sex" name="sex" value="<%= resultSet.getString("sex") %>" required>

                                    <label for="nicNo">NIC No:</label>
                                    <input type="text" id="nicNo" name="nicNo" value="<%= resultSet.getString("nicNo") %>" required>

                                    <label for="mobilePhone">Mobile Phone:</label>
                                    <input type="text" id="mobilePhone" name="mobilePhone" value="<%= resultSet.getString("mobilePhone") %>" required>

                                    <label for="homePhone">Home Phone:</label>
                                    <input type="text" id="homePhone" name="homePhone" value="<%= resultSet.getString("homePhone") %>" required>

                                    <label for="address">Address:</label>
                                    <input type="text" id="address" name="address" value="<%= resultSet.getString("address") %>" required>

                                    <label for="qualifications">Qualifications:</label>
                                    <input type="text" id="qualifications" name="qualifications" value="<%= resultSet.getString("qualifications") %>" required>

                                    <label for="specialization">Specialization:</label>
                                    <input type="text" id="specialization" name="specialization" value="<%= resultSet.getString("specialization") %>" required>

                                    <label for="doctorType">Doctor Type:</label>
                                    <input type="text" id="doctorType" name="doctorType" value="<%= resultSet.getString("doctorType") %>" required>

                                    <label for="visitingCharge">Visiting Charge:</label>
                                    <input type="number" id="visitingCharge" name="visitingCharge" value="<%= resultSet.getDouble("visitingCharge") %>" required>

                                    <label for="channelingCharge">Channeling Charge:</label>
                                    <input type="number" id="channelingCharge" name="channelingCharge" value="<%= resultSet.getDouble("channelingCharge") %>" required>

                                    <label for="baseSalary">Base Salary:</label>
                                    <input type="number" id="baseSalary" name="baseSalary" value="<%= resultSet.getDouble("baseSalary") %>" required>

                                    <label for="notes">Notes:</label>
                                    <textarea id="notes" name="notes"><%= resultSet.getString("notes") %></textarea>

                                    <input type="submit" value="Save Changes">
                                </form>
                            </div>
        <%
                        } else {
                            out.println("<p class='error'>Doctor not found.</p>");
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
            } else if (doctorIdInput != null && !doctorIdInput.isEmpty()) {
                try {
                    // Validate the input format (must be D followed by 3 digits)
                    if (!doctorIdInput.matches("^D\\d{3}$")) {
                        throw new Exception("Invalid Doctor ID format. Please use D followed by 3 digits (e.g. D001).");
                    }
                    
                    // Extract the numeric part (remove the 'D' and convert to int)
                    int doctorIdNum = Integer.parseInt(doctorIdInput.substring(1));
                    
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connection = DriverManager.getConnection(jdbcURL, jdbcUsername, jdbcPassword);

                    String sql = "SELECT * FROM Doctors WHERE id = ?";
                    preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setInt(1, doctorIdNum);

                    resultSet = preparedStatement.executeQuery();

                    if (resultSet.next()) {
                        String firstName = resultSet.getString("firstName");
                        String lastName = resultSet.getString("lastName");
                        String sex = resultSet.getString("sex");
                        String nicNo = resultSet.getString("nicNo");
                        String mobilePhone = resultSet.getString("mobilePhone");
                        String homePhone = resultSet.getString("homePhone");
                        String address = resultSet.getString("address");
                        String qualifications = resultSet.getString("qualifications");
                        String specialization = resultSet.getString("specialization");
                        String doctorType = resultSet.getString("doctorType");
                        double visitingCharge = resultSet.getDouble("visitingCharge");
                        double channelingCharge = resultSet.getDouble("channelingCharge");
                        double baseSalary = resultSet.getDouble("baseSalary");
                        String notes = resultSet.getString("notes");
        %>
                        <div class="result">
                            <h2>Doctor Details</h2>
                            <p><strong>ID:</strong> <%= doctorIdInput.toUpperCase() %></p>
                            <p><strong>First Name:</strong> <%= firstName %></p>
                            <p><strong>Last Name:</strong> <%= lastName %></p>
                            <p><strong>Sex:</strong> <%= sex %></p>
                            <p><strong>NIC No:</strong> <%= nicNo %></p>
                            <p><strong>Mobile Phone:</strong> <%= mobilePhone %></p>
                            <p><strong>Home Phone:</strong> <%= homePhone %></p>
                            <p><strong>Address:</strong> <%= address %></p>
                            <p><strong>Qualifications:</strong> <%= qualifications %></p>
                            <p><strong>Specialization:</strong> <%= specialization %></p>
                            <p><strong>Doctor Type:</strong> <%= doctorType %></p>
                            <p><strong>Visiting Charge:</strong> $<%= visitingCharge %></p>
                            <p><strong>Channeling Charge:</strong> $<%= channelingCharge %></p>
                            <p><strong>Base Salary:</strong> $<%= baseSalary %></p>
                            <p><strong>Notes:</strong> <%= notes %></p>
                            <a href="?editId=<%= doctorIdNum %>" class="edit-btn">Edit Doctor</a>
                        </div>
        <%
                    } else {
        %>
                        <p class="error">No doctor found with ID: <%= doctorIdInput.toUpperCase() %></p>
        <%
                    }
                } catch (NumberFormatException e) {
        %>
                    <p class="error">Invalid Doctor ID format. The numeric part must be 3 digits (e.g. D001).</p>
        <%
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