<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>In Patients Hospital Services</title>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #e6e6fa;
            margin: 0;
            padding: 20px;
        }
        .container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            max-width: 800px;
            margin: auto;
        }
        h1 {
            text-align: center;
            color: #4a4a4a;
        }
        .form-row {
            display: flex;
            margin-bottom: 15px;
            justify-content: space-between;
        }
        .form-group {
            flex: 1;
            display: flex;
            flex-direction: column;
            margin-right: 10px;
        }
        .form-group:last-child {
            margin-right: 0;
        }
        .form-group label {
            margin-bottom: 5px;
            font-weight: bold;
            color: #4a4a4a;
        }
        .form-group select,
        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group input[type="time"] {
            padding: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
            font-size: 14px;
        }
        .button-section {
            display: flex;
            justify-content: center;
            margin-top: 20px;
        }
        .button-section button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            background-color: #6c63ff;
            color: white;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .button-section button:hover {
            background-color: #554bcc;
        }
        .button-close {
            background-color: #d9534f;
        }
        .button-close:hover {
            background-color: #c9302c;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>In Patients Hospital Services</h1>
        <form id="hospitalServicesForm" method="post">
            <div class="form-row">
                <div class="form-group">
                    <label for="billNo">Bill No:</label>
                    <input type="text" id="billNo" name="billNo" required readonly>
                </div>
                <div class="form-group">
                    <label for="billDate">Bill Date:</label>
                    <input type="text" id="billDate" name="billDate" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="patientCode">Patient Code:</label>
                    <select id="patientCode" name="patientCode" required onchange="fetchPatientName()">
                        <option value="">Select Patient Code</option>
                        <%
                            String DB_URL = "jdbc:mysql://localhost:3306/hospital";
                            String DB_USER = "root";
                            String DB_PASSWORD = "@Sashini123";
                            Connection conn = null;
                            Statement stmt = null;
                            ResultSet rs = null;

                            try {
                                Class.forName("com.mysql.cj.jdbc.Driver");
                                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery("SELECT patient_id FROM InPatients");

                                while (rs.next()) {
                                    String patientId = rs.getString("patient_id");
                                    out.println("<option value='" + patientId + "'>" + patientId + "</option>");
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                                if (conn != null) try { conn.close(); } catch (SQLException e) {}
                            }
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="patientName">Name of Patient:</label>
                    <input type="text" id="patientName" name="patientName" required readonly>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="admissionId">Admission ID:</label>
                    <select id="admissionId" name="admissionId" required>
                        <option value="">Select Admission ID</option>
                        <%
                            try {
                                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery("SELECT admission_id FROM AdmissionDetails");

                                while (rs.next()) {
                                    String admissionId = rs.getString("admission_id");
                                    out.println("<option value='" + admissionId + "'>" + admissionId + "</option>");
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                                if (conn != null) try { conn.close(); } catch (SQLException e) {}
                            }
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="treatmentDate">Treatment Date:</label>
                    <input type="date" id="treatmentDate" name="treatmentDate" required>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="treatmentTime">Treatment Time:</label>
                    <input type="time" id="treatmentTime" name="treatmentTime" required>
                </div>
                <div class="form-group">
                    <label for="serviceId">Service ID:</label>
                    <select id="serviceId" name="serviceId" required onchange="fetchServiceCharge()">
                        <option value="">Select Service ID</option>
                        <%
                            try {
                                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                stmt = conn.createStatement();
                                rs = stmt.executeQuery("SELECT Channel_Service_ID FROM MedicalServices");

                                while (rs.next()) {
                                    String serviceId = rs.getString("Channel_Service_ID");
                                    out.println("<option value='" + serviceId + "'>" + serviceId + "</option>");
                                }
                            } catch (Exception e) {
                                e.printStackTrace();
                            } finally {
                                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                                if (stmt != null) try { stmt.close(); } catch (SQLException e) {}
                                if (conn != null) try { conn.close(); } catch (SQLException e) {}
                            }
                        %>
                    </select>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="serviceCharge">Service Charge:</label>
                    <input type="text" id="serviceCharge" name="serviceCharge" required readonly>
                </div>
                <div class="form-group">
                    <label for="description">Description:</label>
                    <input type="text" id="description" name="description">
                </div>
            </div>

            <div class="button-section">
                <button type="submit">Save</button>
                <button type="button" class="button-close" onclick="window.close();">Close</button>
            </div>
        </form>
    </div>

    <script>
        $(function() {
            $("#billDate").datepicker({
                dateFormat: 'yy-mm-dd'
            }).datepicker("setDate", new Date());

            function generateBillNo() {
                var billNo = 'BILL' + String(Math.floor(Math.random() * 1000)).padStart(3, '0');
                $('#billNo').val(billNo);
            }

            generateBillNo();
        });

        function fetchPatientName() {
            var patientCode = $('#patientCode').val();
            if (patientCode) {
                $.ajax({
                    url: 'fetchPatientName.jsp',
                    method: 'GET',
                    data: { patientId: patientCode },
                    success: function(data) {
                        $('#patientName').val(data);
                    }
                });
            } else {
                $('#patientName').val('');
            }
        }

        function fetchServiceCharge() {
            var serviceId = $('#serviceId').val();
            if (serviceId) {
                $.ajax({
                    url: 'fetchServiceCharge.jsp',
                    method: 'GET',
                    data: { serviceId: serviceId },
                    success: function(data) {
                        $('#serviceCharge').val(data);
                    }
                });
            } else {
                $('#serviceCharge').val('');
            }
        }
    </script>
</body>
</html>