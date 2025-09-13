<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.util.*" %>

<%
    // Database connection parameters
    String dbURL = "jdbc:mysql://localhost:3306/your_database";
    String username = "your_username";
    String password = "your_password";
    
    String orderId = "ORD001"; // Default starting order ID
    List<String> patientIds = new ArrayList<>();

    try {
        // Connect to the database
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(dbURL, username, password);

        // Query to get the last order ID
        String orderQuery = "SELECT order_id FROM orders ORDER BY order_id DESC LIMIT 1";
        Statement stmt = conn.createStatement();
        ResultSet rs = stmt.executeQuery(orderQuery);

        // Check if we have any results for order ID
        if (rs.next()) {
            String lastOrderId = rs.getString("order_id");
            int idNumber = Integer.parseInt(lastOrderId.replace("ORD", "")); // Extract number
            idNumber++; // Increment the order number
            orderId = "ORD" + new DecimalFormat("000").format(idNumber); // Format to 3 digits
        }

        // Query to get patient IDs
        String patientQuery = "SELECT patient_id FROM patients"; // Adjust table and column names as necessary
        ResultSet patientRs = stmt.executeQuery(patientQuery);

        while (patientRs.next()) {
            patientIds.add(patientRs.getString("patient_id"));
        }

        // Clean up
        rs.close();
        patientRs.close();
        stmt.close();
        conn.close();
    } catch (Exception e) {
        e.printStackTrace(); // Handle exceptions
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>In Patient Medicine Order Details</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f8ff;
            padding: 20px;
            margin: 0;
            overflow-x: hidden;
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 150px;
            height: auto;
        }
        .order-details {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            max-width: 800px;
            margin: 80px auto 0;
            overflow-y: auto;
        }
        .order-details h1 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
        }
        .order-details label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .order-details input[type="text"],
        .order-details input[type="number"],
        .order-details select,
        .order-details textarea {
            width: 100%;
            padding: 8px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .order-details table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .order-details th, .order-details td {
            border: 1px solid #ccc;
            padding: 10px;
            text-align: left;
        }
        .order-details th {
            background-color: #007bff;
            color: white;
        }
        .record-controls {
            display: flex;
            justify-content: space-between;
            margin-top: 10px;
        }
        .record-controls button {
            background-color: #28a745;
            color: #fff;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            cursor: pointer;
        }
        .record-controls button:hover {
            background-color: #218838;
        }
    </style>
</head>
<body>
    <img src="img/hospital_logo.png" alt="Hospital Logo" class="logo">
    
    <div class="order-details">
        <h1>In Patient Medicine Order Details</h1>

        <form id="orderForm" action="viewOrder.jsp" method="post">
            <label for="orderId">Order ID:</label>
            <input type="text" id="orderId" name="orderId" value="<%= orderId %>" readonly>

            <label for="patientId">Patient ID:</label>
            <select id="patientId" name="patientId" required>
                <option value="" disabled selected>Select Patient ID</option>
                <%
                    for (String patientId : patientIds) {
                %>
                    <option value="<%= patientId %>"><%= patientId %></option>
                <%
                    }
                %>
            </select>

            <label for="admissionDate">Admission Date:</label>
            <input type="text" id="admissionDate" name="admissionDate" placeholder="Admission Date" required>

            <table>
                <thead>
                    <tr>
                        <th>Medicine ID</th>
                        <th>Quantity</th>
                        <th>Unit Price</th>
                        <th>Discount</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><input type="text" name="medicineId" placeholder="Medicine ID"></td>
                        <td><input type="number" name="quantity" placeholder="Quantity"></td>
                        <td><input type="number" name="unitPrice" placeholder="Unit Price"></td>
                        <td><input type="number" name="discount" placeholder="Discount"></td>
                    </tr>
                    <!-- Add more rows as needed -->
                </tbody>
            </table>

            <div class="record-controls">
                <button type="submit">Save Order</button>
                <button type="button" onclick="refreshPage()">Refresh</button>
            </div>
        </form>
    </div>

    <script>
        function refreshPage() {
            window.location.reload();
        }
    </script>
</body>
</html>