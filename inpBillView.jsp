<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*" %>
<%
// Database configuration
final String DB_URL = "jdbc:mysql://localhost:3306/hospital";
final String DB_USER = "root";
final String DB_PASSWORD = "@Sashini123";

// Initialize variables
List<Map<String, String>> bills = new ArrayList<>();
String searchQuery = request.getParameter("search");
String error = null;
String success = null;

try {
    // Load the JDBC driver
    Class.forName("com.mysql.jdbc.Driver");
    
    // Establish connection to the database
    Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    
    // Build SQL query based on search
    String query = "SELECT b.*, p.first_name, p.last_name " +
                   "FROM InPatientBills b " +
                   "JOIN InPatients p ON b.patient_id = p.patient_id ";
    
    if (searchQuery != null && !searchQuery.isEmpty()) {
        query += "WHERE b.bill_id LIKE ? OR b.patient_id LIKE ? OR p.first_name LIKE ? OR p.last_name LIKE ? ";
    }
    query += "ORDER BY b.created_at DESC";
    
    PreparedStatement stmt = conn.prepareStatement(query);
    
    if (searchQuery != null && !searchQuery.isEmpty()) {
        String likeParam = "%" + searchQuery + "%";
        stmt.setString(1, likeParam);
        stmt.setString(2, likeParam);
        stmt.setString(3, likeParam);
        stmt.setString(4, likeParam);
    }
    
    ResultSet rs = stmt.executeQuery();
    
    // Process results
    while (rs.next()) {
        Map<String, String> bill = new HashMap<>();
        bill.put("bill_id", rs.getString("bill_id"));
        bill.put("patient_id", rs.getString("patient_id"));
        bill.put("patient_name", rs.getString("first_name") + " " + rs.getString("last_name"));
        bill.put("admission_id", rs.getString("admission_id"));
        bill.put("discharge_date", rs.getString("discharge_date"));
        bill.put("doctor_charges", String.format("%.2f", rs.getDouble("doctor_charges")));
        bill.put("medicine_charges", String.format("%.2f", rs.getDouble("medicine_charges")));
        bill.put("service_charges", String.format("%.2f", rs.getDouble("service_charges")));
        bill.put("room_charges", String.format("%.2f", rs.getDouble("room_charges")));
        bill.put("hospital_charges", String.format("%.2f", rs.getDouble("hospital_charges")));
        bill.put("discount", String.format("%.2f", rs.getDouble("discount")));
        bill.put("net_value", String.format("%.2f", rs.getDouble("net_value")));
        bill.put("notes", rs.getString("notes"));
        bill.put("created_at", rs.getString("created_at"));
        
        bills.add(bill);
    }
    
    // Close resources
    rs.close();
    stmt.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
    error = "Error loading bills: " + e.getMessage();
}

// Handle delete action
if ("delete".equals(request.getParameter("action"))) {
    String billId = request.getParameter("bill_id");
    if (billId != null && !billId.isEmpty()) {
        try {
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            PreparedStatement stmt = conn.prepareStatement("DELETE FROM InPatientBills WHERE bill_id = ?");
            stmt.setString(1, billId);
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                success = "Bill deleted successfully!";
            } else {
                error = "Bill not found or already deleted.";
            }
            
            stmt.close();
            conn.close();
            
            // Refresh the page to show updated list
            response.sendRedirect("InPatientBillView.jsp");
            return;
            
        } catch (Exception e) {
            e.printStackTrace();
            error = "Error deleting bill: " + e.getMessage();
        }
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>In Patient Bill View</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f5f5f5;
            margin: 0;
            padding: 20px;
            line-height: 1.6;
            color: #34495e;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .logo {
            width: 120px;
            height: auto;
        }
        .home-button {
            width: 40px;
            height: 40px;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .home-button:hover {
            transform: scale(1.1);
        }
        .container {
            background-color: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        h1 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 2rem;
        }
        .search-box {
            margin-bottom: 20px;
            display: flex;
            gap: 10px;
        }
        .search-box input {
            flex: 1;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .search-box button {
            padding: 10px 20px;
            background-color: #3498db;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .search-box button:hover {
            background-color: #2980b9;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background-color: #3498db;
            color: white;
        }
        tr:hover {
            background-color: #f5f5f5;
        }
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        .action-buttons button {
            padding: 5px 10px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            color: white;
        }
        .view-btn { background-color: #3498db; }
        .edit-btn { background-color: #2ecc71; }
        .delete-btn { background-color: #e74c3c; }
        .print-btn { background-color: #9b59b6; }
        .action-buttons button:hover {
            opacity: 0.8;
        }
        .error-message {
            color: #e74c3c;
            background-color: #fdeded;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            border: 1px solid #f5c6cb;
        }
        .success-message {
            color: #2ecc71;
            background-color: #e9f9e9;
            padding: 10px;
            border-radius: 4px;
            margin-bottom: 20px;
            border: 1px solid #a8e0a8;
        }
        .add-new {
            display: block;
            text-align: right;
            margin-bottom: 20px;
        }
        .add-new button {
            padding: 10px 20px;
            background-color: #2ecc71;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }
        .add-new button:hover {
            background-color: #27ae60;
        }
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            th, td {
                padding: 8px 10px;
            }
        }
    </style>
</head>
<body>
    <div class="header">
        <img src="img/h.jpg" alt="Hospital Logo" class="logo">
        <img src="img/home.png" alt="Home" class="home-button" onclick="window.location.href='Home.jsp'">
    </div>

    <div class="container">
        <h1>IN PATIENT BILLS</h1>
        
        <% if (error != null) { %>
            <div class="error-message"><%= error %></div>
        <% } %>
        
        <% if (success != null) { %>
            <div class="success-message"><%= success %></div>
        <% } %>
        
        <div class="add-new">
            <button onclick="window.location.href='InPatientBillDetails.jsp'">
                <i class="fas fa-plus"></i> Add New Bill
            </button>
        </div>
        
        <form method="get" action="InPatientBillView.jsp">
            <div class="search-box">
                <input type="text" name="search" placeholder="Search by Bill ID, Patient ID or Name..." 
                       value="<%= searchQuery != null ? searchQuery : "" %>">
                <button type="submit">Search</button>
                <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                    <button type="button" onclick="window.location.href='InPatientBillView.jsp'">Clear</button>
                <% } %>
            </div>
        </form>
        
        <table>
            <thead>
                <tr>
                    <th>Bill ID</th>
                    <th>Patient</th>
                    <th>Admission ID</th>
                    <th>Discharge Date</th>
                    <th>Net Value</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <% if (bills.isEmpty()) { %>
                    <tr>
                        <td colspan="6" style="text-align: center;">No bills found</td>
                    </tr>
                <% } else { 
                    for (Map<String, String> bill : bills) { %>
                    <tr>
                        <td><%= bill.get("bill_id") %></td>
                        <td><%= bill.get("patient_name") %> (<%= bill.get("patient_id") %>)</td>
                        <td><%= bill.get("admission_id") %></td>
                        <td><%= bill.get("discharge_date") %></td>
                        <td><%= bill.get("net_value") %></td>
                        <td class="action-buttons">
                            <button class="view-btn" onclick="viewBill('<%= bill.get("bill_id") %>')">View</button>
                            <button class="edit-btn" onclick="editBill('<%= bill.get("bill_id") %>')">Edit</button>
                            <button class="delete-btn" onclick="confirmDelete('<%= bill.get("bill_id") %>')">Delete</button>
                            <button class="print-btn" onclick="printBill('<%= bill.get("bill_id") %>')">Print</button>
                        </td>
                    </tr>
                <% } 
                } %>
            </tbody>
        </table>
    </div>

    <script>
        function viewBill(billId) {
            window.location.href = 'ViewBillDetails.jsp?bill_id=' + billId;
        }
        
        function editBill(billId) {
            window.location.href = 'InPatientBillDetails.jsp?bill_id=' + billId;
        }
        
        function confirmDelete(billId) {
            if (confirm('Are you sure you want to delete bill ' + billId + '?')) {
                window.location.href = 'InPatientBillView.jsp?action=delete&bill_id=' + billId;
            }
        }
        
        function printBill(billId) {
            window.open('PrintBill.jsp?bill_id=' + billId, '_blank');
        }
        
        // Auto-hide messages after 5 seconds
        setTimeout(() => {
            const messages = document.querySelectorAll('.error-message, .success-message');
            messages.forEach(msg => {
                if (msg) msg.style.display = 'none';
            });
        }, 5000);
    </script>
</body>
</html>