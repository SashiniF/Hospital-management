<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Out Patient Medical Bill Payments</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f7fa;
            margin: 0;
            padding: 20px;
            color: #333;
        }
        .container {
            max-width: 900px;
            margin: 0 auto;
            background: white;
            padding: 25px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        h2 {
            color: #2c3e50;
            text-align: center;
            margin-bottom: 25px;
            font-weight: 600;
            border-bottom: 2px solid #3498db;
            padding-bottom: 10px;
        }
        .form-row {
            display: flex;
            flex-wrap: wrap;
            margin: 0 -10px 15px;
        }
        .form-group {
            flex: 1;
            min-width: 200px;
            margin: 0 10px 15px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
            color: #2c3e50;
        }
        input[type="text"], 
        input[type="number"], 
        input[type="date"],
        select {
            width: 100%;
            padding: 10px 12px;
            border: 1px solid #ddd;
            border-radius: 4px;
            font-size: 14px;
            transition: all 0.3s;
            box-sizing: border-box;
        }
        select {
            appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 1em;
        }
        input:focus, select:focus {
            border-color: #3498db;
            outline: none;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.2);
        }
        input[readonly] {
            background-color: #f8f9fa;
            color: #6c757d;
            cursor: not-allowed;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            font-size: 14px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        table th {
            background-color: #3498db;
            color: white;
            padding: 12px;
            text-align: left;
        }
        table td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        table tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        table tr:hover {
            background-color: #f1f1f1;
        }
        .button-group {
            display: flex;
            justify-content: center;
            gap: 15px;
            margin-top: 25px;
        }
        .btn {
            padding: 10px 24px;
            border: none;
            border-radius: 4px;
            font-size: 14px;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-primary {
            background-color: #3498db;
            color: white;
        }
        .btn-secondary {
            background-color: #6c757d;
            color: white;
        }
        .btn-success {
            background-color: #28a745;
            color: white;
        }
        .btn:hover {
            opacity: 0.9;
            transform: translateY(-2px);
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        }
        @media print {
            .button-group {
                display: none;
            }
            body {
                background: none;
                padding: 0;
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
        <h2>Out Patient Medical Bill Payments</h2>
        <form action="processPayment.jsp" method="post">
            <div class="form-row">
                <div class="form-group">
                    <label for="admissionNo">Admission No:</label>
                    <select id="admissionNo" name="admissionNo" required>
                        <option value="">-- Select Admission --</option>
                        <%
                            Connection conn = null;
                            Statement stmt = null;
                            ResultSet rs = null;
                            
                            try {
                                Class.forName("com.mysql.jdbc.Driver");
                                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/hospital", "root", "@Sashini123");
                                stmt = conn.createStatement();
                                
                                String sql = "SELECT a.admission_id, p.first_name, p.last_name, p.patient_id " +
                                             "FROM AdmissionDetails a " +
                                             "JOIN InPatients p ON a.patient_id = p.patient_id " +
                                             "ORDER BY a.admission_date DESC";
                                rs = stmt.executeQuery(sql);
                                
                                while (rs.next()) {
                                    String admissionId = rs.getString("admission_id");
                                    String patientName = rs.getString("first_name") + " " + rs.getString("last_name");
                                    String patientId = rs.getString("patient_id");
                        %>
                        <option value="<%= admissionId %>" data-patient-id="<%= patientId %>">
                            <%= admissionId %> - <%= patientName %> (ID: <%= patientId %>)
                        </option>
                        <%
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
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
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="billStatus">Bill Status:</label>
                    <input type="text" id="billStatus" name="billStatus" value="Pending" readonly>
                </div>
                
                <div class="form-group">
                    <label for="totalAmount">Total Paid (Rs.):</label>
                    <input type="text" id="totalAmount" name="totalAmount" value="0.00" readonly>
                </div>

                <div class="form-group">
                    <label for="balanceAmount">Balance Due (Rs.):</label>
                    <input type="text" id="balanceAmount" name="balanceAmount" value="0.00" readonly>
                </div>
            </div>

            <table>
                <thead>
                    <tr>
                        <th>Amount Paid (Rs.)</th>
                        <th>Paid Date</th>
                        <th>Payment Method</th>
                        <th>Reference</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td colspan="4" style="text-align: center;">No payments recorded yet</td>
                    </tr>
                </tbody>
            </table>

            <div class="form-row">
                <div class="form-group">
                    <label for="paymentMethod">Payment Method:</label>
                    <select id="paymentMethod" name="paymentMethod">
                        <option value="cash">Cash</option>
                        <option value="debitCard">Debit Card</option>
                        <option value="creditCard">Credit Card</option>
                        <option value="cheque">Cheque</option>
                        <option value="bankTransfer">Bank Transfer</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="paymentAmount">Payment Amount (Rs.):</label>
                    <input type="number" id="paymentAmount" name="paymentAmount" step="0.01" min="0" required>
                </div>
                
                <div class="form-group">
                    <label for="paymentDate">Payment Date:</label>
                    <input type="date" id="paymentDate" name="paymentDate" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="referenceNo">Reference No:</label>
                    <input type="text" id="referenceNo" name="referenceNo" placeholder="Cheque/Card/Transfer reference">
                </div>
            </div>

            <div class="button-group">
                <button type="submit" class="btn btn-primary">Submit Payment</button>
                <button type="reset" class="btn btn-secondary">Clear Form</button>
                <button type="button" class="btn btn-success" onclick="window.print();">Print Receipt</button>
            </div>
        </form>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Set default payment date to today
            document.getElementById('paymentDate').valueAsDate = new Date();
            
            // Handle admission selection
            document.getElementById('admissionNo').addEventListener('change', function() {
                const selectedOption = this.options[this.selectedIndex];
                const patientId = selectedOption.getAttribute('data-patient-id');
                
                document.getElementById('patientId').value = patientId;
                document.getElementById('billStatus').value = 'Loading details...';
                
                // Simulate loading bill details from server
                setTimeout(() => {
                    document.getElementById('billStatus').value = 'Pending';
                    document.getElementById('totalAmount').value = '1,500.00';
                    document.getElementById('balanceAmount').value = '3,250.00';
                }, 800);
            });
            
            // Format currency inputs
            document.getElementById('paymentAmount').addEventListener('blur', function() {
                if(this.value) {
                    this.value = parseFloat(this.value).toFixed(2);
                }
            });
        });
    </script>
</body>
</html>