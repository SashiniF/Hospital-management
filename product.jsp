<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Product Details</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            overflow: hidden;
            background-color: #e6e6fa;
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
        .product-container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            max-height: 80vh; /* Limit height */
            margin: 50px auto;
            overflow-y: auto; /* Enable vertical scrolling */
            backdrop-filter: blur(3px);
        }
        h1, h2 {
            text-align: center;
            color: #4a4a4a;
        }
        label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #4a4a4a;
        }
        input[type="text"], input[type="number"], select {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
            background-color: white;
        }
        button {
            background-color: #6c63ff;
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 5px;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.3s;
            margin-bottom: 10px;
        }
        button:hover {
            background-color: #7a7a7a;
        }
        .message {
            text-align: center;
            font-weight: bold;
            margin: 10px 0;
        }
        .success { color: #5cb85c; }
        .error { color: #d9534f; }
    </style>
</head>
<body>
    <img src="img/category.png" alt="Hospital Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">

    <div class="product-container">
        <h1>Product Details</h1>

        <%
            String productId = "PR001"; // Default ID
            String supplierId = "SUP001"; // Default ID
            String categoryId = "";
            String unitPrice = "100"; // Default to 100
            String unitsInStock = "100"; // Default to 100
            String reorderLevel = "20"; // Default reorder level
            String actionMessage = "";

            // Database connection
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String url = "jdbc:mysql://localhost:3306/hospital";
                String user = "root";
                String password = "@Sashini123";

                try (Connection conn = DriverManager.getConnection(url, user, password)) {
                    // Generate new Product ID
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT MAX(product_id) FROM Products");
                    if (rs.next()) {
                        String maxProductId = rs.getString(1);
                        if (maxProductId != null) {
                            int num = Integer.parseInt(maxProductId.substring(2)) + 1; // Assuming format "PR001"
                            productId = "PR" + String.format("%03d", num);
                        }
                    }

                    if ("POST".equalsIgnoreCase(request.getMethod())) {
                        String action = request.getParameter("action");
                        if ("save".equals(action)) {
                            categoryId = request.getParameter("categoryId");
                            unitPrice = request.getParameter("unitPrice");
                            unitsInStock = request.getParameter("unitsInStock");
                            reorderLevel = request.getParameter("reorderLevel");

                            // Validate inputs
                            try {
                                int price = Integer.parseInt(unitPrice);
                                int stock = Integer.parseInt(unitsInStock);
                                int reorder = Integer.parseInt(reorderLevel);
                                
                                if (price <= 0 || stock < 0 || reorder < 0) {
                                    throw new NumberFormatException("Values must be positive");
                                }

                                // Insert logic
                                String sql = "INSERT INTO Products (product_id, supplier_id, category_id, unit_price, units_in_stock, reorder_level) VALUES (?, ?, ?, ?, ?, ?)";
                                try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                                    pstmt.setString(1, productId);
                                    pstmt.setString(2, supplierId);
                                    pstmt.setString(3, categoryId);
                                    pstmt.setDouble(4, price);
                                    pstmt.setInt(5, stock);
                                    pstmt.setInt(6, reorder);
                                    int rowsInserted = pstmt.executeUpdate();
                                    actionMessage = rowsInserted > 0 ? "Product saved successfully!" : "Error saving product.";
                                }
                            } catch (NumberFormatException e) {
                                actionMessage = "Error: All numeric fields must be whole numbers (e.g., 100, 200)";
                            }
                        } else if ("search".equals(action)) {
                            productId = request.getParameter("searchProductId");
                            String sql = "SELECT * FROM Products WHERE product_id = ?";
                            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                                pstmt.setString(1, productId);
                                ResultSet rsProduct = pstmt.executeQuery();
                                if (rsProduct.next()) {
                                    categoryId = rsProduct.getString("category_id");
                                    unitPrice = String.valueOf(rsProduct.getDouble("unit_price"));
                                    unitsInStock = String.valueOf(rsProduct.getInt("units_in_stock"));
                                    reorderLevel = String.valueOf(rsProduct.getInt("reorder_level"));
                                    actionMessage = "Product details retrieved successfully!";
                                } else {
                                    actionMessage = "No product found with ID: " + productId;
                                }
                            }
                        }
                    }
                }
            } catch (Exception e) {
                actionMessage = "Error: " + e.getMessage();
            }
        %>

        <form method="post" action="">
            <input type="hidden" name="action" value="save">
            <label for="productId">Product ID:</label>
            <input type="text" id="productId" name="productId" value="<%= productId %>" readonly>

            <label for="supplierId">Supplier ID:</label>
            <input type="text" id="supplierId" name="supplierId" value="<%= supplierId %>" readonly>

            <label for="categoryId">Category:</label>
            <select id="categoryId" name="categoryId" required>
                <option value="">-- Select Category --</option>
                <%
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        String url = "jdbc:mysql://localhost:3306/hospital";
                        String user = "root";
                        String password = "@Sashini123";

                        try (Connection conn = DriverManager.getConnection(url, user, password)) {
                            String sql = "SELECT category_id, category_description FROM MedicineCategories ORDER BY category_description";
                            Statement stmt = conn.createStatement();
                            ResultSet rs = stmt.executeQuery(sql);
                            
                            while (rs.next()) {
                                String catId = rs.getString("category_id");
                                String catDesc = rs.getString("category_description");
                                String selected = catId.equals(categoryId) ? "selected" : "";
                                out.println("<option value='" + catId + "' " + selected + ">" + catDesc + " (" + catId + ")</option>");
                            }
                        }
                    } catch (Exception e) {
                        out.println("<option value=''>Error loading categories</option>");
                    }
                %>
            </select>

            <label for="unitPrice">Unit Price (Rs.):</label>
            <input type="number" id="unitPrice" name="unitPrice" value="<%= unitPrice %>" min="1" step="1" required>

            <label for="unitsInStock">Units In Stock:</label>
            <input type="number" id="unitsInStock" name="unitsInStock" value="<%= unitsInStock %>" min="0" step="1" required>

            <label for="reorderLevel">Reorder Level:</label>
            <input type="number" id="reorderLevel" name="reorderLevel" value="<%= reorderLevel %>" min="0" step="1" required>

            <button type="submit">Save Product</button>
            <button type="button" onclick="document.getElementById('searchForm').style.display='block';">Search Product</button>
            <button type="button" onclick="window.location.href='viewProduct.jsp';">View All</button>
            <button type="button" onclick="resetForm()">Refresh</button>
        </form>

        <form id="searchForm" method="post" style="display:none;">
            <input type="hidden" name="action" value="search">
            <label for="searchProductId">Search Product ID:</label>
            <input type="text" id="searchProductId" name="searchProductId" required>
            <button type="submit">Search</button>
            <button type="button" onclick="document.getElementById('searchForm').style.display='none';">Cancel</button>
        </form>

        <%
            if (!actionMessage.isEmpty()) {
                String messageClass = actionMessage.contains("successfully") ? "success" : "error";
                out.println("<p class='message " + messageClass + "'>" + actionMessage + "</p>");
            }
        %>
    </div>

    <script>
        function resetForm() {
            // Reload the page without maintaining form data
            window.location.href = window.location.href.split('?')[0];
        }
    </script>
</body>
</html>