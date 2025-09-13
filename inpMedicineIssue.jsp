<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>In Patients Medicine Issue</title>
    <link rel="stylesheet" href="https://code.jquery.com/ui/1.12.1/themes/base/jquery-ui.css">
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://code.jquery.com/ui/1.12.1/jquery-ui.js"></script>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            overflow: hidden; /* Prevent body scroll if background is fixed */
            background-color: #e6e6fa; /* Light purple-blue */
        }
        .background-image {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
            opacity: 0.5;
            object-fit: cover;
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 150px;
            height: auto;
            z-index: 1;
        }
        .home-button {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 60px;
            height: 60px;
            cursor: pointer;
            transition: transform 0.2s;
            z-index: 1;
        }
        .home-button:hover {
            transform: scale(1.1);
        }
        .container {
            background-color: rgba(255, 255, 255, 0.9); /* Semi-transparent white */
            padding: 30px; /* Increased padding */
            border-radius: 15px; /* More rounded corners */
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3); /* Stronger shadow */
            max-width: 1000px; /* Wider container for the form */
            margin: 50px auto; /* Centered with vertical margin */
            height: calc(100vh - 100px); /* Adjust height to prevent scroll issues */
            overflow-y: auto; /* Enable scrolling for content within container */
            backdrop-filter: blur(3px); /* Add a subtle blur effect */
            border: 1px solid rgba(255, 255, 255, 0.3); /* Soft border */
        }
        h1 {
            text-align: center;
            color: #4a4a4a; /* Darker text */
            margin-bottom: 25px;
            font-size: 28px; /* Larger heading */
            text-shadow: 1px 1px 2px rgba(0,0,0,0.1); /* Subtle text shadow */
        }
        .form-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 15px;
            gap: 20px; /* Space between form groups */
        }
        .form-group {
            flex: 1;
            display: flex;
            flex-direction: column;
            position: relative;
        }
        .form-group label {
            margin-bottom: 8px; /* Increased margin */
            font-weight: bold;
            color: #4a4a4a;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5); /* Matching text shadow */
        }
        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group select {
            width: 100%;
            padding: 10px; /* Increased padding */
            border: 1px solid rgba(0, 0, 0, 0.2); /* Softer border */
            border-radius: 5px; /* More rounded corners */
            font-size: 14px;
            background-color: rgba(255, 255, 255, 0.8); /* Slightly transparent background */
            box-sizing: border-box; /* Include padding in width */
        }
        .form-group input[readonly] {
            background-color: #e9ecef; /* Light gray for readonly */
            color: #555; /* Slightly darker text for readonly */
        }
        /* Style for select dropdown arrow */
        .form-group select {
            appearance: none;
            -webkit-appearance: none;
            -moz-appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 10px center;
            background-size: 1em;
        }

        .section-separator {
            border-top: 1px solid #b0b0b0; /* Slightly darker separator */
            margin: 30px 0; /* More vertical space */
        }
        .add-to-list-section {
            display: flex;
            justify-content: flex-end;
            margin-top: 20px;
        }
        .add-to-list-section button {
            background-color: #5cb85c; /* Green add button, consistent with navigation */
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px; /* Increased gap */
            transition: background-color 0.3s;
        }
        .add-to-list-section button:hover {
            background-color: #4cae4c;
        }
        .add-icon {
            font-size: 22px; /* Larger plus icon */
            line-height: 1;
        }
        h2 {
            text-align: left;
            color: #4a4a4a;
            margin-top: 30px;
            margin-bottom: 15px;
            font-size: 22px;
            text-shadow: 1px 1px 1px rgba(255,255,255,0.5);
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 10px;
            background-color: rgba(255, 255, 255, 0.9); /* Semi-transparent white */
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
            border-radius: 8px; /* Rounded table corners */
            overflow: hidden; /* Ensures rounded corners apply to content */
        }
        table th, table td {
            border: 1px solid #e0e0e0; /* Lighter border */
            padding: 12px; /* Increased padding */
            text-align: left;
            font-size: 14px;
        }
        table th {
            background-color: #b0c4de; /* Header background */
            color: #333;
            font-weight: bold;
        }
        table tr:nth-child(even) {
            background-color: rgba(240, 248, 255, 0.5); /* Light stripe effect */
        }
        table td button {
            background-color: #d9534f; /* Red for remove button */
            color: white;
            border: none;
            padding: 6px 10px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 12px;
            transition: background-color 0.3s;
        }
        table td button:hover {
            background-color: #c9302c;
        }
        .total-summary {
            display: flex;
            justify-content: flex-end;
            gap: 20px; /* Space between totals */
            margin-top: 25px;
            font-size: 18px; /* Larger font */
            font-weight: bold;
            color: #2c3e50;
        }
        .total-summary div {
            padding: 10px 15px; /* Increased padding */
            background-color: rgba(248, 249, 250, 0.9); /* Lighter background */
            border-radius: 5px;
            border: 1px solid #dee2e6;
            box-shadow: 0 1px 3px rgba(0,0,0,0.08); /* Subtle shadow */
        }
        .buttons-bottom {
            display: flex;
            justify-content: center;
            gap: 20px; /* Space between buttons */
            margin-top: 35px; /* More space above buttons */
        }
        .buttons-bottom button {
            background-color: #6c63ff; /* Primary action button color */
            color: white;
            padding: 12px 25px; /* Larger buttons */
            border: none;
            border-radius: 5px;
            font-size: 16px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        .buttons-bottom button:hover {
            background-color: #554bcc; /* Darker shade on hover */
        }
        /* Specific styles for other buttons in bottom group */
        .buttons-bottom button:nth-child(2) { /* Clear All */
            background-color: #ffc107; /* Warning yellow */
            color: #333;
        }
        .buttons-bottom button:nth-child(2):hover {
            background-color: #e0a800;
        }
        .buttons-bottom button:nth-child(3), /* Search Bills */
        .buttons-bottom button:nth-child(4) { /* View All Bills */
             background-color: #17a2b8; /* Info blue */
        }
        .buttons-bottom button:nth-child(3):hover,
        .buttons-bottom button:nth-child(4):hover {
            background-color: #138496;
        }

        .success-message {
            color: #27ae60; /* Darker green for success */
            text-align: center;
            margin: 15px 0; /* More margin */
            font-weight: bold;
            padding: 10px;
            background-color: #d4edda;
            border: 1px solid #c3e6cb;
            border-radius: 5px;
        }
        .error-message {
            color: #e74c3c; /* Darker red for error */
            text-align: center;
            margin: 15px 0; /* More margin */
            font-weight: bold;
            padding: 10px;
            background-color: #f8d7da;
            border: 1px solid #f5c6cb;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <img src="img/bg2.png" alt="Background" class="background-image">
    <img src="img/h.jpg" alt="Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="container">
        <h1>IN PATIENTS MEDICINE ISSUE</h1>

        <%
            // Database Connection Parameters
            final String DB_URL = "jdbc:mysql://localhost:3306/hospital";
            final String DB_USER = "root";
            final String DB_PASSWORD = "@Sashini123"; // Make sure this is correct for your MySQL

            Connection conn = null;
            Statement stmt = null;
            ResultSet rs = null;

            String billNo = "";
            String unitsInStock = "";
            String ratePerUnit = "";
            String actionMessage = "";
            String errorMessage = "";

            List<Map<String, String>> medicineItems = new ArrayList<>();
            @SuppressWarnings("unchecked")
            List<Map<String, String>> sessionItems = (List<Map<String, String>>) session.getAttribute("medicineIssueItems");
            if (sessionItems != null) {
                medicineItems = sessionItems;
            }

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                stmt = conn.createStatement();

                // --- Auto-generate Bill No ---
                rs = stmt.executeQuery("SELECT MAX(CAST(SUBSTRING(bill_no, 5) AS UNSIGNED)) FROM MedicineIssueHeaders WHERE bill_no LIKE 'BILL%'");
                if (rs.next()) {
                    int maxNum = rs.getInt(1);
                    billNo = "BILL" + String.format("%03d", maxNum + 1); // Format to BILL001, BILL002, etc.
                } else {
                    billNo = "BILL001"; // Starting bill number if no records exist
                }
                rs.close();

                // Handle POST requests for adding items or saving the bill
                if ("POST".equalsIgnoreCase(request.getMethod())) {
                    String formAction = request.getParameter("formAction");

                    if ("addItem".equals(formAction)) {
                        // Logic to add a single medicine item to the session list
                        Map<String, String> item = new HashMap<>();
                        item.put("orderId", "TEMP_" + System.currentTimeMillis());
                        item.put("medicineCode", request.getParameter("medicineIdField")); 
                        item.put("medicineName", request.getParameter("medicineNameSelected")); 
                        item.put("dateOfIssue", request.getParameter("issueDate"));
                        item.put("quantity", request.getParameter("quantity"));
                        item.put("unitPrice", request.getParameter("ratePerUnit"));
                        item.put("discount", request.getParameter("discountGivenSingle"));
                        item.put("totalAmountItem", request.getParameter("totalAmountDisplay")); 

                        if (item.get("medicineCode") == null || item.get("medicineCode").isEmpty() ||
                            item.get("quantity") == null || item.get("quantity").isEmpty() ||
                            Integer.parseInt(item.get("quantity")) <= 0) {
                            errorMessage = "Please select a medicine and enter a valid quantity.";
                        } else {
                            if (sessionItems == null) {
                                sessionItems = new ArrayList<>();
                            }
                            sessionItems.add(item);
                            session.setAttribute("medicineIssueItems", sessionItems);
                            medicineItems = sessionItems; 
                            actionMessage = "Medicine item added to the list!";
                        }

                    } else if ("saveBill".equals(formAction)) {
                        // Logic to save the entire bill (header + details) to the database
                        String billNoToSave = request.getParameter("billNo");
                        String billDate = request.getParameter("billDate");
                        String issueDate = request.getParameter("issueDate"); 
                        String admissionCode = request.getParameter("admissionCode");
                        String patientNameEntered = request.getParameter("nameOfPatient");
                        String totalBillAmount = request.getParameter("totalBillAmount"); 
                        String totalDiscountGiven = request.getParameter("totalDiscountGiven"); 

                        if (sessionItems == null || sessionItems.isEmpty()) {
                            errorMessage = "Cannot save bill: No medicine items added to the list.";
                        } else {
                            conn.setAutoCommit(false); 

                            PreparedStatement pstmtHeader = null;
                            PreparedStatement pstmtDetail = null;
                            PreparedStatement pstmtUpdateStock = null;

                            try {
                                DatabaseMetaData dbm = conn.getMetaData();

                                ResultSet tables = dbm.getTables(null, null, "MedicineIssueHeaders", null);
                                if (!tables.next()) {
                                    String createHeaderTableSQL = "CREATE TABLE MedicineIssueHeaders (" +
                                        "bill_no VARCHAR(50) PRIMARY KEY," +
                                        "bill_date DATE NOT NULL," +
                                        "issue_date DATE NOT NULL," +
                                        "admission_code VARCHAR(10) NOT NULL," +
                                        "patient_name VARCHAR(255) NOT NULL," +
                                        "total_amount DECIMAL(10, 2) NOT NULL," +
                                        "total_discount_given DECIMAL(10, 2) NOT NULL," +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                                        "FOREIGN KEY (admission_code) REFERENCES AdmissionDetails(admission_id)" +
                                        ")";
                                    stmt.executeUpdate(createHeaderTableSQL);
                                    actionMessage += " MedicineIssueHeaders table created. ";
                                }
                                tables.close();

                                tables = dbm.getTables(null, null, "MedicineIssueDetails", null);
                                if (!tables.next()) {
                                    String createDetailTableSQL = "CREATE TABLE MedicineIssueDetails (" +
                                        "order_id VARCHAR(50) PRIMARY KEY," +
                                        "bill_no VARCHAR(50) NOT NULL," +
                                        "medicine_code VARCHAR(10) NOT NULL," +
                                        "medicine_name VARCHAR(255) NOT NULL," +
                                        "date_of_issue DATE NOT NULL," + 
                                        "quantity INT NOT NULL," +
                                        "unit_price DECIMAL(10, 2) NOT NULL," +
                                        "discount_per_item DECIMAL(10, 2) NOT NULL," +
                                        "total_amount_per_item DECIMAL(10, 2) NOT NULL," +
                                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                                        "FOREIGN KEY (bill_no) REFERENCES MedicineIssueHeaders(bill_no)," +
                                        "FOREIGN KEY (medicine_code) REFERENCES Products(product_id)" +
                                        ")";
                                    stmt.executeUpdate(createDetailTableSQL);
                                    actionMessage += " MedicineIssueDetails table created. ";
                                }
                                tables.close();

                                String headerSql = "INSERT INTO MedicineIssueHeaders (bill_no, bill_date, issue_date, admission_code, patient_name, total_amount, total_discount_given) VALUES (?, ?, ?, ?, ?, ?, ?)";
                                pstmtHeader = conn.prepareStatement(headerSql);
                                pstmtHeader.setString(1, billNoToSave);
                                pstmtHeader.setString(2, billDate);
                                pstmtHeader.setString(3, issueDate);
                                pstmtHeader.setString(4, admissionCode);
                                pstmtHeader.setString(5, patientNameEntered);
                                pstmtHeader.setDouble(6, Double.parseDouble(totalBillAmount));
                                pstmtHeader.setDouble(7, Double.parseDouble(totalDiscountGiven));
                                pstmtHeader.executeUpdate();

                                String detailSql = "INSERT INTO MedicineIssueDetails (order_id, bill_no, medicine_code, medicine_name, date_of_issue, quantity, unit_price, discount_per_item, total_amount_per_item) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                                String updateStockSql = "UPDATE Products SET units_in_stock = units_in_stock - ? WHERE product_id = ?";

                                pstmtDetail = conn.prepareStatement(detailSql);
                                pstmtUpdateStock = conn.prepareStatement(updateStockSql);

                                int itemOrderCounter = 1;
                                for (Map<String, String> item : sessionItems) {
                                    String itemOrderId = billNoToSave +"_ITEM" + String.format("%02d", itemOrderCounter++);

                                    pstmtDetail.setString(1, itemOrderId);
                                    pstmtDetail.setString(2, billNoToSave);
                                    pstmtDetail.setString(3, item.get("medicineCode"));
                                    pstmtDetail.setString(4, item.get("medicineName"));
                                    pstmtDetail.setString(5, item.get("dateOfIssue"));
                                    pstmtDetail.setInt(6, Integer.parseInt(item.get("quantity")));
                                    pstmtDetail.setDouble(7, Double.parseDouble(item.get("unitPrice")));
                                    pstmtDetail.setDouble(8, Double.parseDouble(item.get("discount")));
                                    pstmtDetail.setDouble(9, Double.parseDouble(item.get("totalAmountItem")));
                                    pstmtDetail.addBatch(); // Add to batch for efficiency

                                    pstmtUpdateStock.setInt(1, Integer.parseInt(item.get("quantity")));
                                    pstmtUpdateStock.setString(2, item.get("medicineCode"));
                                    pstmtUpdateStock.addBatch(); // Add to batch for efficiency
                                }

                                pstmtDetail.executeBatch(); // Execute all detail inserts
                                pstmtUpdateStock.executeBatch(); // Execute all stock updates

                                conn.commit(); // Commit the transaction
                                actionMessage = "Bill " + billNoToSave + " and all medicine items saved successfully!";
                                session.removeAttribute("medicineIssueItems"); // Clear session after successful save
                                response.sendRedirect(request.getRequestURI()); // Redirect to clear form
                                return; // Stop further execution after redirect

                            } catch (SQLException e) {
                                conn.rollback(); // Rollback on error
                                if (e.getErrorCode() == 1062) { // Duplicate entry for PRIMARY KEY
                                    errorMessage = "Save failed: Bill No. " + billNoToSave + " already exists. Please refresh to get a new bill number.";
                                } else if (e.getErrorCode() == 1452) { // Foreign Key constraint fails
                                    errorMessage = "Save failed: Invalid Admission Code or Medicine ID in the list. Please check data.";
                                } else {
                                    errorMessage = "Database error during save: " + e.getMessage();
                                }
                                e.printStackTrace();
                            } catch (NumberFormatException e) {
                                conn.rollback();
                                errorMessage = "Data format error: Please ensure quantity, rate, discount, and amounts are valid numbers. " + e.getMessage();
                                e.printStackTrace();
                            } catch (Exception e) {
                                conn.rollback();
                                errorMessage = "An unexpected error occurred during save: " + e.getMessage();
                                e.printStackTrace();
                            } finally {
                                // Close prepared statements and reset auto-commit
                                if (pstmtHeader != null) try { pstmtHeader.close(); } catch (SQLException e) { /* log error */ }
                                if (pstmtDetail != null) try { pstmtDetail.close(); } catch (SQLException e) { /* log error */ }
                                if (pstmtUpdateStock != null) try { pstmtUpdateStock.close(); } catch (SQLException e) { /* log error */ }
                                if (conn != null) try { conn.setAutoCommit(true); } catch (SQLException e) { /* log error */ }
                            }
                        }
                    } else if ("removeItem".equals(formAction)) {
                        // Logic to remove an item from the session list
                        String itemToRemoveOrderId = request.getParameter("itemOrderId");
                        if (sessionItems != null) {
                            sessionItems.removeIf(item -> item.get("orderId") != null && item.get("orderId").equals(itemToRemoveOrderId));
                            session.setAttribute("medicineIssueItems", sessionItems);
                            medicineItems = sessionItems; // Update the list for display
                            actionMessage = "Item removed successfully.";
                        }
                    } else if ("clearAllItems".equals(formAction)) {
                        // Logic to clear all items from the session list
                        session.removeAttribute("medicineIssueItems");
                        medicineItems = new ArrayList<>(); // Clear the list for display
                        actionMessage = "All items cleared.";
                    }
                }
            } catch (Exception e) {
                errorMessage = "Critical error initializing page: " + e.getMessage();
                e.printStackTrace();
            } finally {
                // Close resources in the finally block
                if (rs != null) { try { rs.close(); } catch (SQLException e) { /* log error */ } }
                if (stmt != null) { try { stmt.close(); } catch (SQLException e) { /* log error */ } }
                if (conn != null) { try { conn.close(); } catch (SQLException e) { /* log error */ } }
            }
        %>

        <% if (!errorMessage.isEmpty()) { %>
            <div class="error-message"><%= errorMessage %></div>
        <% } %>

        <% if (!actionMessage.isEmpty()) { %>
            <div class="success-message"><%= actionMessage %></div>
        <% } %>

        <form id="medicineIssueForm" method="post" onsubmit="return validateForm()">
            <input type="hidden" id="formAction" name="formAction" value="saveBill">
            <input type="hidden" id="totalBillAmount" name="totalBillAmount" value="0.00">
            <input type="hidden" id="totalDiscountGiven" name="totalDiscountGiven" value="0.00">
            <input type="hidden" id="currentOrderId" name="currentOrderId">

            <div class="form-row">
                <div class="form-group">
                    <label for="nameOfPatient">Name of Patient:</label>
                    <input type="text" id="nameOfPatient" name="nameOfPatient"
                            value="<%= (request.getParameter("nameOfPatient") != null) ? request.getParameter("nameOfPatient") : "" %>" required>
                </div>
                <div class="form-group">
                    <label for="billNo">Bill No:</label>
                    <input type="text" id="billNo" name="billNo" value="<%= billNo %>" readonly>
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="admissionCode">Admission Code:</label>
                    <select id="admissionCode" name="admissionCode" required>
                        <option value="">Select Admission Code</option>
                        <%
                            // Re-open connection for this dropdown as the main one might be closed by finally block
                            try (Connection tempConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                 Statement tempStmt = tempConn.createStatement();
                                 ResultSet tempRs = tempStmt.executeQuery("SELECT DISTINCT admission_id FROM AdmissionDetails ORDER BY admission_id")) {
                                while(tempRs.next()) {
                                    String admId = tempRs.getString("admission_id");
                                    String selected = "";
                                    // Retain selected value after form submission
                                    if (request.getParameter("admissionCode") != null && request.getParameter("admissionCode").equals(admId)) {
                                        selected = "selected";
                                    }
                                    out.println("<option value='" + admId + "' " + selected + ">" + admId + "</option>");
                                }
                            } catch (SQLException e) {
                                out.println("<option value=''>Error loading Admission Codes</option>");
                                e.printStackTrace(); // Log the error for debugging
                            }
                        %>
                    </select>
                </div>
                <div class="form-group">
                    <label for="billDate">Bill Date:</label>
                    <input type="text" id="billDate" name="billDate" required>
                </div>
            </div>

            <div class="section-separator"></div>

            <div class="form-row">
                <div class="form-group">
                    <label for="medicineSelectionDropdown">Medicine ID & Name:</label>
                    <select id="medicineSelectionDropdown" name="medicineSelectionDropdown" required>
                        <option value="">Select Medicine ID & Name</option>
                        <%
                            // Re-open connection for this dropdown
                            try (Connection tempConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                 Statement tempStmt = tempConn.createStatement();
                                 ResultSet tempRs = tempStmt.executeQuery("SELECT p.product_id, p.product_name FROM Products p ORDER BY p.product_name")) {
                                while (tempRs.next()) {
                                    String productId = tempRs.getString("product_id");
                                    String productName = tempRs.getString("product_name");
                                    out.println("<option value='" + productId + "'>" + productId + " - " + productName + "</option>");
                                }
                            } catch (SQLException e) {
                                out.println("<option value=''>Error loading Medicines</option>");
                                e.printStackTrace(); // Log the error for debugging
                            }
                        %>
                    </select>
                    <input type="hidden" id="medicineIdField" name="medicineIdField">
                    <input type="hidden" id="medicineNameSelected" name="medicineNameSelected">
                </div>
                <div class="form-group">
                    <label for="unitsInStock">Units in Stock:</label>
                    <input type="text" id="unitsInStock" name="unitsInStock" readonly value="<%= unitsInStock %>">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="ratePerUnit">Rate Per Unit:</label>
                    <input type="text" id="ratePerUnit" name="ratePerUnit" readonly value="<%= ratePerUnit %>">
                </div>
                <div class="form-group">
                    <label for="issueDate">Issue Date:</label>
                    <input type="text" id="issueDate" name="issueDate" required value="<%= (request.getParameter("issueDate") != null) ? request.getParameter("issueDate") : "" %>">
                </div>
            </div>

            <div class="form-row">
                <div class="form-group">
                    <label for="quantity">Quantity:</label>
                    <input type="text" id="quantity" name="quantity" required pattern="[0-9]*" value="<%= (request.getParameter("quantity") != null) ? request.getParameter("quantity") : "1" %>">
                </div>
                <div class="form-group">
                    <label for="discountGivenSingle">Discount (%):</label>
                    <input type="text" id="discountGivenSingle" name="discountGivenSingle" value="<%= (request.getParameter("discountGivenSingle") != null) ? request.getParameter("discountGivenSingle") : "0.00" %>">
                </div>
                <div class="form-group">
                    <label for="totalAmountDisplay">Total Amount (Item):</label>
                    <input type="text" id="totalAmountDisplay" name="totalAmountDisplay" readonly value="0.00">
                </div>
            </div>

            <div class="add-to-list-section">
                <button type="button" onclick="addItemToList()">
                    <span class="add-icon">+</span> Add to List
                </button>
            </div>

            <div class="section-separator"></div>

            <h2>Issued Medicine Items</h2>
            <table id="medicineItemsTable">
                <thead>
                    <tr>
                        <th>Medicine ID</th>
                        <th>Medicine Name</th>
                        <th>Issue Date</th>
                        <th>Quantity</th>
                        <th>Unit Price</th>
                        <th>Discount</th>
                        <th>Total Amount</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% // Display items currently in session
                        if (medicineItems != null && !medicineItems.isEmpty()) {
                            for (Map<String, String> item : medicineItems) {
                    %>
                                <tr>
                                    <td><%= item.get("medicineCode") %></td>
                                    <td><%= item.get("medicineName") %></td>
                                    <td><%= item.get("dateOfIssue") %></td>
                                    <td><%= item.get("quantity") %></td>
                                    <td><%= item.get("unitPrice") %></td>
                                    <td><%= item.get("discount") %></td>
                                    <td><%= item.get("totalAmountItem") %></td>
                                    <td>
                                        <button type="button" onclick="removeItem('<%= item.get("orderId") %>')">Remove</button>
                                    </td>
                                </tr>
                    <%
                            }
                        } else {
                    %>
                            <tr><td colspan="8" style="text-align: center;">No medicine items added yet.</td></tr>
                    <%
                        }
                    %>
                </tbody>
            </table>

            <div class="total-summary">
                <div>Total Bill Amount: <span id="displayTotalBillAmount">0.00</span></div>
                <div>Total Discount Given: <span id="displayTotalDiscountGiven">0.00</span></div>
            </div>

            <div class="buttons-bottom">
                <button type="submit" onclick="setFormAction('saveBill')">Save Bill</button>
                <button type="button" onclick="setFormAction('clearAllItems'); document.getElementById('medicineIssueForm').submit();">Clear All</button>
                <button type="button" onclick="window.location.href='searchBills.jsp'">Search Bills</button>
                <button type="button" onclick="window.location.href='viewAllBills.jsp'">View All Bills</button>
            </div>
        </form>
    </div>

    <script>
        $(function() {
            // Initialize date pickers
            $("#billDate").datepicker({
                dateFormat: 'yy-mm-dd' // MySQL friendly date format
            }).datepicker("setDate", new Date()); // Set today's date by default

            $("#issueDate").datepicker({
                dateFormat: 'yy-mm-dd'
            }).datepicker("setDate", new Date()); // Set today's date by default

            $('#medicineSelectionDropdown').on('change', function() {
                var selectedOption = $(this).find('option:selected');
                var medicineId = selectedOption.val();
                $('#medicineIdField').val(medicineId);
                $('#medicineNameSelected').val(selectedOption.text().split(' - ')[1]); // Get the name part
            });

            // Event listeners for quantity, rate, and discount changes
            $('#quantity, #ratePerUnit, #discountGivenSingle').on('input', calculateItemTotal);

            // Initial calculation on page load for any pre-filled values
            calculateItemTotal();
        });

        function calculateItemTotal() {
            var quantity = parseFloat($('#quantity').val()) || 0;
            var rate = parseFloat($('#ratePerUnit').val()) || 0;
            var discountPercent = parseFloat($('#discountGivenSingle').val()) || 0;

            var subtotal = quantity * rate;
            var discountAmount = (subtotal * discountPercent) / 100;
            var totalAmount = subtotal - discountAmount;

            $('#totalAmountDisplay').val(totalAmount.toFixed(2)); // Display with 2 decimal places
        }

        function setFormAction(action) {
            $('#formAction').val(action);
        }

        function addItemToList() {
            var medicineId = $('#medicineIdField').val();
            var quantity = parseFloat($('#quantity').val());
            var unitsInStock = parseFloat($('#unitsInStock').val());

            if (!medicineId) {
                alert("Please select a medicine.");
                return;
            }
            if (isNaN(quantity) || quantity <= 0) {
                alert("Please enter a valid quantity greater than zero.");
                return;
            }
            if (quantity > unitsInStock) {
                alert("Quantity exceeds units in stock (" + unitsInStock + ").");
                return;
            }

            setFormAction('addItem');
            $('#medicineIssueForm').submit();
        }

        function removeItem(orderId) {
            if (confirm("Are you sure you want to remove this item?")) {
                setFormAction('removeItem');
                $('#currentOrderId').val(orderId);
                $('#medicineIssueForm').submit();
            }
        }

        function validateForm() {
            if ($('#formAction').val() === 'saveBill') {
                var patientName = $('#nameOfPatient').val().trim();
                var admissionCode = $('#admissionCode').val();
                var billDate = $('#billDate').val();
                var issueDate = $('#issueDate').val();

                if (patientName === "") {
                    alert("Patient Name is required.");
                    return false;
                }
                if (admissionCode === "") {
                    alert("Admission Code is required.");
                    return false;
                }
                if (billDate === "") {
                    alert("Bill Date is required.");
                    return false;
                }
                if (issueDate === "") {
                    alert("Issue Date is required.");
                    return false;
                }
                if ($('#medicineItemsTable tbody tr').length === 0 || $('#medicineItemsTable tbody tr').text().includes('No medicine items added yet.')) {
                    alert("Please add at least one medicine item before saving the bill.");
                    return false;
                }
            }
            return true; // Allow submission for addItem, removeItem, clearAllItems
        }

        $(document).ready(function() {
            updateTotals();
        });

        function goToHome() {
            window.location.href = 'index.jsp';
        }
    </script>
</body>
</html>