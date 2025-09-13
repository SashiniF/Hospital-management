<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>In Patient Bill Payments</title>
    <style>
        @page {
            size: A4;
            margin: 10mm;
        }
        body {
            font-family: 'Arial', sans-serif;
            margin: 0;
            padding: 20px;
            color: #333;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: white;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            border-bottom: 2px solid #0066cc;
            padding-bottom: 20px;
        }
        .hospital-info {
            flex: 1;
        }
        .hospital-info h1 {
            color: #0066cc;
            margin-bottom: 5px;
        }
        .hospital-logo {
            max-width: 100px;
            height: auto;
        }
        .page-title {
            text-align: center;
            margin: 20px 0;
            color: #0066cc;
            font-size: 1.8em;
        }
        .form-container {
            margin-top: 30px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #0066cc;
        }
        .form-group input[type="text"],
        .form-group input[type="number"],
        .form-group select {
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 16px;
        }
        .form-group input[readonly] {
            background-color: #f9f9f9;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
        }
        table th {
            background-color: #0066cc;
            color: white;
            text-align: left;
            padding: 12px;
        }
        table td {
            padding: 10px;
            border-bottom: 1px solid #ddd;
        }
        table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .button-group {
            margin-top: 30px;
            text-align: center;
        }
        .button-group button {
            padding: 12px 25px;
            border: none;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            margin: 0 10px;
        }
        .submit-btn {
            background-color: #0066cc;
            color: white;
        }
        .reset-btn {
            background-color: #666;
            color: white;
        }
        .button-group button:hover {
            opacity: 0.9;
        }
        @media print {
            .button-group {
                display: none;
            }
            body {
                padding: 0;
                background-color: white;
            }
            .container {
                border: none;
                box-shadow: none;
            }
        }
    </style>
</head>
<body>

<div class="container">
    <div class="header">
        <div class="hospital-info">
            <h1>City General Hospital</h1>
            <p>123 Hospital Road, Colombo 10, Sri Lanka</p>
            <p>Tel: +94 11 2345678 | Email: info@cityhospital.lk</p>
        </div>
        <img src="${pageContext.request.contextPath}/img/h.jpg" alt="Hospital Logo" class="hospital-logo">
    </div>
    
    <h1 class="page-title">IN PATIENT BILL PAYMENTS</h1>
    
    <div class="form-container">
        <form action="processPayment.jsp" method="post">
            <div class="form-group">
                <label for="admissionNo">Admission No:</label>
                <select id="admissionNo" name="admissionNo" required>
                    <option value="">-- Select Admission No --</option>
                    <%
                        Connection conn = null;
                        Statement stmt = null;
                        ResultSet rs = null;
                        
                        try {
                            // Load the JDBC driver
                            Class.forName("com.mysql.jdbc.Driver");
                            
                            // Establish a connection
                            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hospital", "root", "@Sashini123");
                            
                            // Create a statement
                            stmt = conn.createStatement();
                            
                            // Execute a query to get admission details
                            String sql = "SELECT a.admission_id, p.first_name, p.last_name " +
                                         "FROM AdmissionDetails a " +
                                         "JOIN InPatients p ON a.patient_id = p.patient_id " +
                                         "ORDER BY a.admission_date DESC";
                            rs = stmt.executeQuery(sql);
                            
                            // Process the result set
                            while (rs.next()) {
                                String admissionId = rs.getString("admission_id");
                                String patientName = rs.getString("first_name") + " " + rs.getString("last_name");
                                %>
                                <option value="<%= admissionId %>"><%= admissionId %> - <%= patientName %></option>
                                <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        } finally {
                            // Close resources
                            if (rs != null) rs.close();
                            if (stmt != null) stmt.close();
                            if (conn != null) conn.close();
                        }
                    %>
                </select>
            </div>
            
            <div class="form-group">
                <label for="billStatus">Bill Status:</label>
                <input type="text" id="billStatus" name="billStatus" value="Pending" readonly>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Amount Paid</th>
                        <th>Paid Date</th>
                        <th>Pay Type</th>
                        <th>Credit Card No</th>
                        <th>Cheque Date</th>
                        <th>Bank</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>1,000.00</td>
                        <td>01-01-2023</td>
                        <td>Cash</td>
                        <td>-</td>
                        <td>-</td>
                        <td>-</td>
                    </tr>
                    <!-- Additional rows can be added here -->
                </tbody>
            </table>

            <div class="form-group">
                <label for="totalAmount">Total Amount Paid:</label>
                <input type="text" id="totalAmount" name="totalAmount" value="1,000.00" readonly>
            </div>

            <div class="form-group">
                <label for="balanceAmount">Balance Amount:</label>
                <input type="text" id="balanceAmount" name="balanceAmount" value="500.00" readonly>
            </div>

            <div class="form-group">
                <label for="paymentMethod">Payment Method:</label>
                <select id="paymentMethod" name="paymentMethod">
                    <option value="cash">Cash</option>
                    <option value="debitCard">Debit Card</option>
                    <option value="cheque">Cheque</option>
                </select>
            </div>

            <div class="form-group">
                <label for="paymentAmount">Payment Amount:</label>
                <input type="number" id="paymentAmount" name="paymentAmount" step="0.01" min="0" required>
            </div>

            <div class="button-group">
                <button type="submit" class="submit-btn">Submit Payment</button>
                <button type="reset" class="reset-btn">Reset</button>
            </div>
        </form>
    </div>
</div>

<script>
    // You can add JavaScript here to update bill details when admissionNo changes
    document.getElementById('admissionNo').addEventListener('change', function() {
        // Here you would typically make an AJAX call to get bill details for the selected admission
        // For now, we'll just update the status field as an example
        document.getElementById('billStatus').value = 'Loading...';
        
        // Simulate loading data from server
        setTimeout(function() {
            document.getElementById('billStatus').value = 'Pending';
            document.getElementById('totalAmount').value = '1,500.00';
            document.getElementById('balanceAmount').value = '750.00';
        }, 500);
    });
</script>

</body>
</html>