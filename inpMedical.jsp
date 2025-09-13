<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
// Database configuration
final String DB_URL = "jdbc:mysql://localhost:3306/hospital";
final String DB_USER = "root";
final String DB_PASSWORD = "@Sashini123";

// Simulating a counter (in a real application, this should be fetched from the database)
int lastBillId = 0; // This would typically come from a database query

// Generate Patient Bill ID automatically
String patientBillId = "IPB" + String.format("%03d", lastBillId + 1); // Generates ID like IPB001
String patientId = "";
String admissionId = "";
String dischargeDate = "";
double doctorCharges = 0.00;
double medicineCharges = 0.00;
double serviceCharges = 0.00;
double roomCharges = 0.00;
double hospitalCharges = 0.00;
double discount = 0.00;
double netValue = 0.00;

// Handle form submissions for updates or deletions
if ("POST".equalsIgnoreCase(request.getMethod())) {
    // Your logic to handle form submissions goes here
}

// Handle delete actions
if (request.getParameter("action") != null && request.getParameter("action").equals("delete")) {
    // Your logic to handle deletions goes here
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>In Patient Bill Details</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-image: url('img/dapps.png');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
            height: 100vh;
            margin: 0;
            padding: 20px;
            line-height: 1.6;
            color: #34495e;
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 120px;
            height: auto;
            z-index: 100;
        }
        .home-button {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 40px;
            height: 40px;
            cursor: pointer;
            transition: transform 0.2s;
            z-index: 100;
        }
        .home-button:hover {
            transform: scale(1.1);
        }
        .bill-details {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 800px;
            margin: 80px auto 0;
        }
        .bill-details h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 2rem;
            font-weight: 600;
        }
        .bill-details h2 {
            color: #3498db;
            margin-top: 2rem;
            margin-bottom: 1.5rem;
            font-size: 1.4rem;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 0.5rem;
        }
        .bill-details label {
            display: block;
            margin-bottom: 0.8rem;
            font-weight: 500;
        }
        .bill-details input[type="text"],
        .bill-details input[type="number"],
        .bill-details input[type="date"],
        .bill-details textarea {
            width: 100%;
            padding: 0.8rem 1rem;
            margin-bottom: 1.2rem;
            border: 2px solid #bdc3c7;
            border-radius: 6px;
            transition: border-color 0.3s ease;
        }
        .bill-details textarea {
            resize: vertical;
            min-height: 80px;
        }
        .bill-details input:focus,
        .bill-details textarea:focus {
            border-color: #3498db;
            outline: none;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }
        .action-buttons {
            display: flex;
            gap: 0.75rem;
            margin-top: 1.5rem;
            justify-content: center;
        }
        .action-buttons button {
            padding: 0.8rem 1.5rem;
            border-radius: 6px;
            font-size: 0.95rem;
            cursor: pointer;
            color: white;
            font-weight: 500;
        }
        .action-buttons .add-btn { background-color: #2980b9; }
        .action-buttons .edit-btn { background-color: #4CAF50; }
        .action-buttons .delete-btn { background-color: #e74c3c; }
        .action-buttons .refresh-btn { background-color: #95a5a6; }
        .action-buttons .close-btn { background-color: #7f8c8d; }
        .action-buttons button:hover {
            filter: brightness(0.9);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 1.5rem;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.05);
        }
        th, td {
            padding: 0.75rem 1rem;
            text-align: left;
            border-bottom: 1px solid #ecf0f1;
        }
        th {
            background-color: #3498db;
            color: white;
            font-weight: 600;
        }
        tr:nth-child(even) {
            background-color: #f8f9fa;
        }
        .error-message {
            color: #e74c3c;
            background: #fdeded;
            padding: 1rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
            border: 1px solid #f5c6cb;
        }
        .success-message {
            color: #2ecc71;
            background: #e9f9e9;
            padding: 1rem;
            border-radius: 6px;
            margin-bottom: 1.5rem;
            border: 1px solid #a8e0a8;
        }
        @media (max-width: 768px) {
            .bill-details {
                padding: 1.5rem;
                margin-top: 60px;
            }
            .logo {
                width: 100px;
                top: 15px;
                left: 15px;
            }
            .action-buttons {
                flex-direction: column;
            }
        }
    </style>
</head>
<body>
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="window.location.href='Home.jsp'">

    <div class="bill-details">
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="success-message"><%= request.getAttribute("success") %></div>
        <% } %>

        <h1>IN PATIENT BILL DETAILS</h1>

        <form id="billForm" method="post">
            <h2>Bill Information</h2>
            <label for="patientBillId">Patient Bill ID:</label>
            <input type="text" id="patientBillId" name="patientBillId" value="<%= patientBillId %>" readonly>

            <label for="patientId">Patient ID:</label>
            <input type="text" id="patientId" name="patientId" value="<%= patientId %>">

            <label for="admissionId">Admission ID:</label>
            <input type="text" id="admissionId" name="admissionId" value="<%= admissionId %>">

            <label for="dischargeDate">Discharge Date:</label>
            <input type="date" id="dischargeDate" name="dischargeDate" value="<%= dischargeDate %>">

            <label for="doctorCharges">Doctor Charges:</label>
            <input type="number" id="doctorCharges" name="doctorCharges" value="<%= doctorCharges %>">

            <label for="medicineCharges">Medicine Charges:</label>
            <input type="number" id="medicineCharges" name="medicineCharges" value="<%= medicineCharges %>">

            <label for="serviceCharges">Service Charges:</label>
            <input type="number" id="serviceCharges" name="serviceCharges" value="<%= serviceCharges %>">

            <label for="roomCharges">Room Charges:</label>
            <input type="number" id="roomCharges" name="roomCharges" value="<%= roomCharges %>">

            <label for="hospitalCharges">Hospital Charges:</label>
            <input type="number" id="hospitalCharges" name="hospitalCharges" value="<%= hospitalCharges %>">

            <label for="discount">Discount:</label>
            <input type="number" id="discount" name="discount" value="<%= discount %>">

            <label for="netValue">Net Value:</label>
            <input type="number" id="netValue" name="netValue" value="<%= netValue %>">

            <label for="notes">Notes:</label>
            <textarea id="notes" name="notes" placeholder="Enter any notes"></textarea>

            <button type="submit" class="save-btn">Save Bill</button>
        </form>

        <h2>Current Bills</h2>
        <table id="billsTable">
            <thead>
                <tr>
                    <th>Select</th>
                    <th>Patient Bill ID</th>
                    <th>Patient ID</th>
                    <th>Admission ID</th>
                    <th>Net Value</th>
                    <th>Notes</th>
                </tr>
            </thead>
            <tbody>
                <% 
                // Code to retrieve and display current bills from the database goes here
                %>
            </tbody>
        </table>

        <div class="action-buttons">
            <button class="add-btn" onclick="addNewBill()">Add New</button>
            <button class="edit-btn" onclick="editBill()">Edit</button>
            <button class="delete-btn" onclick="deleteSelectedBill()">Delete</button>
            <button class="refresh-btn" onclick="location.reload()">Refresh</button>
            <button class="close-btn" onclick="window.location.href='Home.jsp'">Close</button>
        </div>
    </div>

    <script>
        function addNewBill() {
            document.getElementById('billForm').reset();
            document.getElementById('patientBillId').value = "IPB" + String("000" + (lastBillId + 1)).slice(-3); // Generate new ID
            document.getElementById('patientId').focus();
        }

        function editBill() {
            // Logic to edit the selected bill
        }

        function deleteSelectedBill() {
            // Logic to delete the selected bill
        }
        
        setTimeout(() => {
            const messages = document.querySelectorAll('.error-message, .success-message');
            messages.forEach(msg => msg.style.display = 'none');
        }, 5000);
    </script>
</body>
</html>