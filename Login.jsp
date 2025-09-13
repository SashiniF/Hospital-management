<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Management System Login</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative; /* For positioning the logo */
            background-image: url('img/login.jpg'); /* Background image */
            background-size: cover; /* Ensures the image covers the entire background */
            background-position: center; /* Centers the background image */
            background-repeat: no-repeat; /* Prevents the image from repeating */
        }
        .login-container {
            background-color: rgba(255, 255, 255, 0.8); /* Semi-transparent white background */
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 300px;
            text-align: center;
        }
        .login-container h2 {
            margin-bottom: 20px;
            color: #333;
        }
        .login-container input[type="text"],
        .login-container input[type="password"] {
            width: 100%;
            padding: 10px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .login-container input[type="submit"] {
            width: 100%;
            padding: 10px;
            background-color: #007bff;
            border: none;
            border-radius: 4px;
            color: #fff;
            font-size: 16px;
            cursor: pointer;
        }
        .login-container input[type="submit"]:hover {
            background-color: #0056b3;
        }
        .error-message {
            color: red;
            margin-top: 10px;
            display: none; /* Hidden by default */
        }
        .corner-image {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 200px; /* Increased size for the logo */
            height: auto; /* Maintain aspect ratio */
        }
        .date-time {
            margin-top: 20px;
            font-size: 14px;
            color: #555;
        }
    </style>
</head>
<body>
    <!-- Image in the left corner -->
    <img src="img/h.jpg" alt="Hospital Logo" class="corner-image">

    <div class="login-container">
        <h2>Hospital Management System</h2>
        <form id="loginForm" method="post" action="login.jsp">
            <input type="text" id="username" name="username" placeholder="Username" required>
            <input type="password" id="password" name="password" placeholder="Password" required>
            <input type="submit" value="Sign In">
        </form>
        <div id="errorMessage" class="error-message">Invalid Username or Password. Please try again.</div>
        <!-- Display current date and time -->
        <div class="date-time">
            <span id="currentDate"></span><br>
            <span id="currentTime"></span>
        </div>
    </div>

    <script>
        document.getElementById('loginForm').addEventListener('submit', function(event) {
            event.preventDefault(); // Prevent form submission

            // Get input values
            const username = document.getElementById('username').value;
            const password = document.getElementById('password').value;

            // Check credentials
            if (username === 'admin1' && password === '123') {
                alert('Login successful! Redirecting to Dashboard...');
                window.location.href = 'Home.jsp?username=' + encodeURIComponent(username);
            } else if (username === 'admin2' && password === '456') {
                alert('Login successful! Redirecting to Dashboard...');
                window.location.href = 'Home.jsp?username=' + encodeURIComponent(username);
            } else {
                document.getElementById('errorMessage').style.display = 'block'; // Show error message
            }
        });

        // Function to update the current date and time
        function updateDateTime() {
            const now = new Date();
            const dateOptions = { year: 'numeric', month: 'long', day: 'numeric' };
            const timeOptions = { hour: '2-digit', minute: '2-digit', second: '2-digit' };

            document.getElementById('currentDate').textContent = now.toLocaleDateString(undefined, dateOptions);
            document.getElementById('currentTime').textContent = now.toLocaleTimeString(undefined, timeOptions);
        }

        // Update the date and time every second
        setInterval(updateDateTime, 1000);

        // Initial call to display the date and time immediately
        updateDateTime();
    </script>

    <%
        // Server-side validation (optional)
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username != null && password != null) {
            if (username.equals("a") && password.equals("1")) {
                response.sendRedirect("dashboard.jsp");
            } else if (username.equals("doctor") && password.equals("doctor123")) {
                response.sendRedirect("Doctor.jsp");
            } else {
                out.println("<script>document.getElementById('errorMessage').style.display = 'block';</script>");
            }
        }
    %>
</body>
</html>