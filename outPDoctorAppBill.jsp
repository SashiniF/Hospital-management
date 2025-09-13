<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>In Patient Bill Payments</title>
    <style>
        body {
            background-color: #f0f0f0;
            font-family: Arial, sans-serif;
        }
        .container {
            width: 80%;
            margin: auto;
            background-color: #fff;
            padding: 20px;
            border-radius: 5px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        }
        h2 {
            text-align: center;
            color: #0066cc;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #0066cc;
        }
        input[type="text"], 
        input[type="number"], 
        input[type="date"],
        select {
            width: 100%;
            padding: 8px;
            margin: 5px 0;
            box-sizing: border-box;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        input[readonly] {
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
            text-align: center;
            margin-top: 20px;
        }
        .submit-btn {
            padding: 10px 15px;
            background-color: #0066cc;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
        }
        .reset-btn {
            padding: 10px 15px;
            background-color: #666;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
        }
        .print-btn {
            padding: 10px 15px;
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin: 0 5px;
        }
        .submit-btn:hover, 
        .reset-btn:hover,
        .print-btn:hover {
            opacity: 0.9;
        }
        @media print {
            .button-group {
                display: none;
            }
            body {
                background-color: white;
            }
            .container {
                box-shadow: none;
                border: none;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <h2>IN PATIENT BILL PAYMENTS</h2>
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
                            
                            // Execute a query to get admission details with patient names
                            String sql = "SELECT a.admission_id, p.first_name, p.last_name, p.patient_id " +
                                         "FROM AdmissionDetails a " +
                                         "JOIN InPatients p ON a.patient_id = p.patient_id " +
                                         "ORDER BY a.admission_date DESC";
                            rs = stmt.executeQuery(sql);
                            
                            // Process the result set
                            while (rs.next()) {
                                String admissionId = rs.getString("admission_id");
                                String patientName = rs.getString("first_name") + " " + rs.getString("last_name");
                                String patientId = rs.getString("patient_id");
                    %>
                    <option value="<%= admissionId %>" data-patient-id="<%= patientId %>">
                        <%= admissionId %> - <%= patientName %> (Patient ID: <%= patientId %>)
                    </option>
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
                <label for="patientId">Patient ID:</label>
                <input type="text" id="patientId" name="patientId" readonly>
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
                        <td>5,000.00</td>
                        <td>01-11-2025</td>
                        <td>Cash</td>
                        <td>-</td>
                        <td>-</td>
                        <td>-</td>
                    </tr>
                </tbody>
            </table>

            <div class="form-group">
                <label for="totalAmount">Total Amount Paid:</label>
                <input type="text" id="totalAmount" name="totalAmount" value="2,000.00" readonly>
            </div>

            <div class="form-group">
                <label for="balanceAmount">Balance Amount:</label>
                <input type="text" id="balanceAmount" name="balanceAmount" value="300.00" readonly>
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
                <button type="button" class="print-btn" onclick="window.print();">Print Invoice</button>
            </div>
        </form>
    </div>

    <script>
        // Update patient ID when admission is selected
        document.getElementById('admissionNo').addEventListener('change', function() {
            var selectedOption = this.options[this.selectedIndex];
            var patientId = selectedOption.getAttribute('data-patient-id');
            document.getElementById('patientId').value = patientId;
            
            // Simulate loading bill details from server
            document.getElementById('billStatus').value = 'Loading...';
            
            setTimeout(function() {
                document.getElementById('billStatus').value = 'Pending';
                document.getElementById('totalAmount').value = '1,500.00';
                document.getElementById('balanceAmount').value = '750.00';
            }, 500);
        });
    </script>
</body>
</html>