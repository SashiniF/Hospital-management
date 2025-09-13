<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Save and Display Doctor Details</title>
    <style>
        table {
            width: 100%;
            border-collapse: collapse;
        }
        table, th, td {
            border: 1px solid black;
        }
        th, td {
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .delete-btn {
            color: white;
            border: none;
            padding: 10px 20px;
            cursor: pointer;
            position: fixed;
            top: 20px;
            background-color: #ff4d4d;
            right: 20px;
        }
        .delete-btn:hover {
            background-color: #cc0000;
        }
        .selected-row {
            background-color: #d3d3d3; /* Highlight selected row */
        }
    </style>
    <script>
        function selectRow(row) {
            var rows = document.querySelectorAll("tr");
            rows.forEach(function(r) {
                r.classList.remove("selected-row");
            });
            row.classList.add("selected-row");
            document.getElementById("selectedId").value = row.getAttribute("data-id");
        }

        function deleteSelectedRow() {
            var selectedId = document.getElementById("selectedId").value;
            if (selectedId) {
                if (confirm("Are you sure you want to delete this record?")) {
                    document.getElementById("deleteForm").submit();
                }
            } else {
                alert("Please select a row to delete.");
            }
        }
    </script>
</head>
<body>
    <h2>Save and Display Doctor Details</h2>

    <button class="delete-btn" onclick="deleteSelectedRow()">Delete</button>

    <form id="deleteForm" method="post" style="display: none;">
        <input type="hidden" id="selectedId" name="deleteId">
    </form>

    <%
        String url = "jdbc:mysql://localhost:3306/hospital"; // Database name
        String username = "root"; // Database username
        String password = "@Sashini123"; // Database password

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(url, username, password);

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                if (request.getParameter("deleteId") != null) {
                    String deleteId = request.getParameter("deleteId");
                    String deleteSql = "DELETE FROM Doctors WHERE id = ?";
                    pstmt = conn.prepareStatement(deleteSql);
                    pstmt.setInt(1, Integer.parseInt(deleteId));
                    pstmt.executeUpdate();
                    out.println("<p>Doctor with ID " + deleteId + " deleted successfully!</p>");
                } else {
                    // Insert new doctor details
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

                    // Get the next ID in sequence
                    String maxIdSql = "SELECT MAX(id) AS maxId FROM Doctors";
                    Statement stmt = conn.createStatement();
                    ResultSet maxIdRs = stmt.executeQuery(maxIdSql);
                    int nextId = 1;
                    if (maxIdRs.next()) {
                        nextId = maxIdRs.getInt("maxId") + 1;
                    }
                    maxIdRs.close();
                    stmt.close();

                    String insertSql = "INSERT INTO Doctors (id, firstName, lastName, sex, nicNo, mobilePhone, homePhone, address, qualifications, specialization, doctorType, visitingCharge, channelingCharge, baseSalary, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                    pstmt = conn.prepareStatement(insertSql);
                    pstmt.setInt(1, nextId);
                    pstmt.setString(2, firstName);
                    pstmt.setString(3, lastName);
                    pstmt.setString(4, sex);
                    pstmt.setString(5, nicNo);
                    pstmt.setString(6, mobilePhone);
                    pstmt.setString(7, homePhone);
                    pstmt.setString(8, address);
                    pstmt.setString(9, qualifications);
                    pstmt.setString(10, specialization);
                    pstmt.setString(11, doctorType);
                    pstmt.setDouble(12, visitingCharge);
                    pstmt.setDouble(13, channelingCharge);
                    pstmt.setDouble(14, baseSalary);
                    pstmt.setString(15, notes);
                    pstmt.executeUpdate();

                    out.println("<p>Doctor details saved successfully!</p>");
                }
            }

            String selectSql = "SELECT * FROM Doctors ORDER BY id";
            pstmt = conn.prepareStatement(selectSql);
            rs = pstmt.executeQuery();

            out.println("<h3>Doctor Details</h3>");
            out.println("<table>");
            out.println("<tr><th>ID</th><th>First Name</th><th>Last Name</th><th>Sex</th><th>NIC No</th><th>Mobile Phone</th><th>Home Phone</th><th>Address</th><th>Qualifications</th><th>Specialization</th><th>Doctor Type</th><th>Visiting Charge</th><th>Channeling Charge</th><th>Base Salary</th><th>Notes</th></tr>");

            while (rs.next()) {
                // Format the ID as D001, D002, etc.
                String formattedId = "D" + String.format("%03d", rs.getInt("id"));
                
                out.println("<tr data-id='" + rs.getInt("id") + "' onclick='selectRow(this)'>");
                out.println("<td>" + formattedId + "</td>");
                out.println("<td>" + rs.getString("firstName") + "</td>");
                out.println("<td>" + rs.getString("lastName") + "</td>");
                out.println("<td>" + rs.getString("sex") + "</td>");
                out.println("<td>" + rs.getString("nicNo") + "</td>");
                out.println("<td>" + rs.getString("mobilePhone") + "</td>");
                out.println("<td>" + rs.getString("homePhone") + "</td>");
                out.println("<td>" + rs.getString("address") + "</td>");
                out.println("<td>" + rs.getString("qualifications") + "</td>");
                out.println("<td>" + rs.getString("specialization") + "</td>");
                out.println("<td>" + rs.getString("doctorType") + "</td>");
                out.println("<td>" + rs.getDouble("visitingCharge") + "</td>");
                out.println("<td>" + rs.getDouble("channelingCharge") + "</td>");
                out.println("<td>" + rs.getDouble("baseSalary") + "</td>");
                out.println("<td>" + rs.getString("notes") + "</td>");
                out.println("</tr>");
            }
            out.println("</table>");

        } catch (Exception e) {
            e.printStackTrace();
            out.println("<p style='color:red;'>An error occurred: " + e.getMessage() + "</p>");
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    %>
</body>
</html>