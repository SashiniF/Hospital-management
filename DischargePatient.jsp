<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%
// Database configuration
final String DB_URL = "jdbc:mysql://localhost:3306/hospital";
final String DB_USER = "root";
final String DB_PASSWORD = "@Sashini123";

// Variable to hold the generated discharge ID
String generatedDischargeId = "DIS001"; // Default value

// Get current date for date restrictions
LocalDateTime now = LocalDateTime.now();
String today = now.format(DateTimeFormatter.ISO_LOCAL_DATE);

try {
    // Connect to database
    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    
    // Query to get the maximum discharge ID
    String sql = "SELECT MAX(discharge_id) FROM Discharges";
    Statement stmt = conn.createStatement();
    ResultSet rs = stmt.executeQuery(sql);
    
    if (rs.next()) {
        String lastId = rs.getString(1);
        if (lastId != null && lastId.startsWith("DIS")) {
            // Extract the numeric part and increment
            String numStr = lastId.substring(3);
            try {
                int num = Integer.parseInt(numStr) + 1;
                generatedDischargeId = "DIS" + String.format("%03d", num);
            } catch (NumberFormatException e) {
                // If format is wrong, just use default
                generatedDischargeId = "DIS001";
            }
        }
    }
    
    rs.close();
    stmt.close();
    
} catch (Exception e) {
    e.printStackTrace();
    // On error, just use the default ID
    generatedDischargeId = "DIS001";
}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Discharge Details</title>
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
        .discharge-container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 2rem;
            border-radius: 12px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 800px;
            margin: 80px auto 0;
        }
        .discharge-container h2 {
            text-align: center;
            color: #2c3e50;
            margin-bottom: 2rem;
            font-weight: 600;
            border-bottom: 2px solid #ecf0f1;
            padding-bottom: 0.5rem;
        }
        .discharge-container label {
            display: block;
            margin-bottom: 0.8rem;
            font-weight: 500;
        }
        .discharge-container input[type="text"],
        .discharge-container input[type="date"],
        .discharge-container input[type="time"],
        .discharge-container select {
            width: 100%;
            padding: 0.8rem 1rem;
            margin-bottom: 1.2rem;
            border: 2px solid #bdc3c7;
            border-radius: 6px;
            transition: border-color 0.3s ease;
        }
        .discharge-container select {
            appearance: none;
            background-image: url("data:image/svg+xml;charset=UTF-8,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24' fill='none' stroke='currentColor' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3e%3cpolyline points='6 9 12 15 18 9'%3e%3c/polyline%3e%3c/svg%3e");
            background-repeat: no-repeat;
            background-position: right 1rem center;
            background-size: 1em;
        }
        .discharge-container input:focus,
        .discharge-container select:focus {
            border-color: #3498db;
            outline: none;
            box-shadow: 0 0 0 3px rgba(52, 152, 219, 0.1);
        }
        .disabled-input {
            background-color: #f8f9fa;
            cursor: not-allowed;
            border-color: #ecf0f1;
        }
        .action-buttons {
            display: flex;
            gap: 0.75rem;
            margin-top: 1.5rem;
            justify-content: center;
        }
        .action-buttons button {
            border: none;
            padding: 0.8rem 1.5rem;
            border-radius: 6px;
            font-size: 0.95rem;
            cursor: pointer;
            transition: all 0.2s ease;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: white;
            font-weight: 500;
        }
        .action-buttons button:nth-child(1) { background-color: #2980b9; } /* View */
        .action-buttons button:nth-child(2) { background-color: #27ae60; } /* Add */
        .action-buttons button:nth-child(3) { background-color: #95a5a6; } /* Refresh */
        .action-buttons button:nth-child(4) { background-color: #7f8c8d; } /* Close */
        .action-buttons button:hover {
            filter: brightness(0.9);
        }
        .record-navigation {
            text-align: center;
            margin-top: 1.5rem;
            color: #7f8c8d;
            font-size: 0.9rem;
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
            .discharge-container {
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
            .action-buttons button {
                width: 100%;
                justify-content: center;
            }
        }
    </style>
</head>
<body>
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="window.location.href='Home.jsp'">

    <div class="discharge-container">
        <% if (request.getAttribute("error") != null) { %>
            <div class="error-message"><%= request.getAttribute("error") %></div>
        <% } %>
        <% if (request.getAttribute("success") != null) { %>
            <div class="success-message"><%= request.getAttribute("success") %></div>
        <% } %>

        <h2>DISCHARGE DETAILS</h2>
        <form action="submitDischargeDetails.jsp" method="post">
            <label for="dischargeId">Discharge ID:</label>
            <input type="text" id="dischargeId" name="dischargeId" class="disabled-input" value="<%= generatedDischargeId %>" readonly required>

            <label for="admissionId">Admission ID:</label>
            <select id="admissionId" name="admissionId" required>
                <option value="">-- Select Admission ID --</option>
                <%
                try {
                    Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                    Statement stmt = conn.createStatement();
                    // Query to get active admissions (assuming they're in a table called Admissions)
                    String sql = "SELECT admission_id FROM Admissions WHERE discharge_date IS NULL ORDER BY admission_id";
                    ResultSet rs = stmt.executeQuery(sql);
                    
                    while (rs.next()) {
                        String admissionId = rs.getString("admission_id");
                %>
                        <option value="<%= admissionId %>"><%= admissionId %></option>
                <%
                    }
                    rs.close();
                    stmt.close();
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                    // If error occurs, just show some sample options
                    for (int i = 1; i <= 7; i++) {
                        String admissionId = "A" + String.format("%03d", i);
                %>
                        <option value="<%= admissionId %>"><%= admissionId %></option>
                <%
                    }
                }
                %>
            </select>

            <label for="dischargeDate">Discharge Date:</label>
            <input type="date" id="dischargeDate" name="dischargeDate" min="<%= today %>" required>

            <label for="dischargeTime">Discharge Time:</label>
            <input type="time" id="dischargeTime" name="dischargeTime" required>

            <div class="action-buttons">
                <button type="submit">View</button>
                <button type="button" onclick="addDetails()">Add</button>
                <button type="button" onclick="location.reload()">Refresh</button>
                <button type="button" onclick="window.close()">Close</button>
            </div>
        </form>

        <div class="record-navigation">
            <p>Record Navigation: Record: 1</p>
        </div>
    </div>

    <script>
        // Set current date and time on page load
        window.onload = function() {
            const now = new Date();
            
            // Set current date as default for discharge date
            const today = now.toISOString().substr(0, 10);
            document.getElementById('dischargeDate').value = today;
            
            // Set current time as default for discharge time
            const currentTime = now.toTimeString().substr(0, 5);
            document.getElementById('dischargeTime').value = currentTime;
        };

        function addDetails() {
            // Add your logic for adding details here
            alert('Add details functionality not implemented yet.');
        }

        setTimeout(() => {
            const messages = document.querySelectorAll('.error-message, .success-message');
            messages.forEach(msg => msg.style.display = 'none');
        }, 5000);
    </script>
</body>
</html>