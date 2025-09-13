<%@ page import="java.sql.*" %>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Medicine Categories</title>
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
        .medicine-container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
            max-width: 600px;
            margin: 50px auto;
            height: calc(100vh - 100px);
            overflow-y: auto;
            backdrop-filter: blur(3px);
        }
        .medicine-container h1 {
            text-align: center;
            color: #4a4a4a;
            margin-bottom: 25px;
        }
        .medicine-container h2 {
            color: #4a4a4a;
            border-bottom: 1px solid #6c63ff;
            padding-bottom: 5px;
            margin-top: 20px;
        }
        .medicine-container label {
            display: block;
            margin-bottom: 8px;
            font-weight: bold;
            color: #4a4a4a;
        }
        .medicine-container input[type="text"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid rgba(0, 0, 0, 0.2);
            border-radius: 5px;
            font-size: 14px;
        }
        .medicine-container button {
            background-color: #6c63ff;
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 5px;
            font-size: 14px;
            cursor: pointer;
            width: 100%;
            transition: background-color 0.3s;
        }
        .medicine-container button:hover {
            background-color: #7a7a7a;
        }
        .record-navigation {
            display: flex;
            justify-content: space-between;
            margin-top: 15px;
        }
        .record-navigation button {
            background-color: #5cb85c;
            padding: 8px;
            font-size: 12px;
            margin-right: 5px;
            flex: 1;
        }
        .record-navigation button:last-child {
            margin-right: 0;
        }
        .success-message {
            color: #5cb85c;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
        }
        .error-message {
            color: #d9534f;
            text-align: center;
            margin: 10px 0;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <img src="img/category.png" alt="Hospital Background" class="background-image">
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">

    <div class="medicine-container">
        <h1>Medicine Categories</h1>

        <%
            // Initialize variables
            String categoryId = "CM001"; // Default ID
            String categoryDescription = "";
            String actionMessage = "";

            // Generate next Category ID
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                String url = "jdbc:mysql://localhost:3306/hospital";
                String user = "root";
                String password = "@Sashini123";

                try (Connection conn = DriverManager.getConnection(url, user, password)) {
                    Statement stmt = conn.createStatement();
                    ResultSet rs = stmt.executeQuery("SELECT MAX(category_id) FROM MedicineCategories");
                    
                    if (rs.next()) {
                        String maxId = rs.getString(1);
                        if (maxId != null) {
                            // Increment and format the ID to CMXXX
                            int num = Integer.parseInt(maxId.substring(2)) + 1;
                            categoryId = "CM" + String.format("%03d", num);
                        }
                    }
                }
            } catch (Exception e) {
                // Handle exceptions if needed
            }

            if ("POST".equalsIgnoreCase(request.getMethod())) {
                String action = request.getParameter("action");

                if ("save".equals(action)) {
                    // Handle save action
                    categoryDescription = request.getParameter("categoryDescription");

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        String url = "jdbc:mysql://localhost:3306/hospital";
                        String user = "root";
                        String password = "@Sashini123";

                        try (Connection conn = DriverManager.getConnection(url, user, password)) {
                            String sql = "INSERT INTO MedicineCategories (category_id, category_description) VALUES (?, ?)";
                            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                                pstmt.setString(1, categoryId);
                                pstmt.setString(2, categoryDescription);

                                int rowsInserted = pstmt.executeUpdate();
                                actionMessage = rowsInserted > 0 ? "Category saved successfully!" : "Error saving category.";
                            }
                        }
                    } catch (SQLException e) {
                        actionMessage = "Error: " + e.getMessage();
                    } catch (Exception e) {
                        actionMessage = "Error: " + e.getMessage();
                    }
                }
            }
        %>

        <form method="post">
            <input type="hidden" name="action" value="save">
            
            <h2>Category Details</h2>
            <label for="categoryId">Category ID:</label>
            <input type="text" id="categoryId" name="categoryId" value="<%= categoryId %>" readonly>
            
            <label for="categoryDescription">Category Description:</label>
            <input type="text" id="categoryDescription" name="categoryDescription" value="<%= categoryDescription %>" required>
            
            <button type="submit">Save Category</button>
        </form>

        <div class="record-navigation">
         
            <button onclick="searchCategory()">Search</button>
            <button onclick="viewCategory()">View</button>
            <button onclick="refreshPage()">Refresh</button>
        </div>

        <%
            if (!actionMessage.isEmpty()) {
                out.println("<p class='success-message'>" + actionMessage + "</p>");
            }
        %>

    </div>

    <script>
        function refreshPage() {
            window.location.reload();
        }

        function searchCategory() {
            // Logic to navigate to search category
            window.location.href = 'searchCategory.jsp';
        }

        function viewCategory() {
            // Redirect to view category page
            window.location.href = 'viewCategory.jsp';
        }

        function deleteCategory() {
            // Logic to delete a category (implement as needed)
            alert('Delete functionality not implemented yet.');
        }
    </script>
</body>
</html>