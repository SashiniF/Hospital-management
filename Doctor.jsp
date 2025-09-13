<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doctor Details</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background: url('img/Doctors.png') no-repeat center center fixed; /* Add your background image */
            background-size: cover; /* Cover the entire viewport */
            padding: 20px;
            margin: 0;
            overflow-x: hidden; /* Hide horizontal scroll */
        }
        .logo {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 150px;
            height: auto;
        }
        .home-button {
            position: absolute;
            top: 20px;
            right: 20px;
            width: 60px; /* Increased width for better usability */
            height: 60px; /* Increased height for better usability */
            cursor: pointer;
            transition: transform 0.2s;
        }
        .home-button:hover {
            transform: scale(1.1);
        }
        .doctor-details {
            background-color: rgba(255, 255, 255, 0.9); /* Slightly transparent white */
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 100%; /* Set width to 100% */
            max-width: 600px; /* Optional: Maintain a max width */
            margin: 80px auto 0; 
            height: calc(100vh - 140px);
            overflow-y: auto; /* Allow internal scrolling if necessary */
        }
        .doctor-details h1 {
            text-align: center;
            color: #333;
            margin-bottom: 20px;
        }
        .doctor-details h2 {
            color: #007bff;
            margin-top: 20px;
            margin-bottom: 10px;
        }
        .doctor-details label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #555;
        }
        .doctor-details input[type="text"],
        .doctor-details input[type="number"],
        .doctor-details select,
        .doctor-details textarea {
            width: 100%;
            padding: 8px; /* Reduced padding */
            margin-bottom: 10px; /* Reduced space */
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px; /* Smaller font size */
        }
        .doctor-details input[readonly] {
            background-color: #f0f0f0;
            color: #666;
        }
        .doctor-details textarea {
            resize: vertical;
            height: 60px; /* Adjusted height for compactness */
        }
        .doctor-details button {
            background-color: #007bff;
            color: #fff;
            border: none;
            padding: 10px;
            border-radius: 4px;
            font-size: 16px;
            cursor: pointer;
            width: 100%;
            margin-top: 10px;
        }
        .doctor-details button:hover {
            background-color: #0056b3;
        }
        .record-controls {
            display: flex;
            justify-content: space-between;
            margin-top: 10px; /* Reduced space */
            align-items: center;
        }
        .record-controls button {
            background-color: #28a745;
            color: #fff;
            border: none;
            padding: 8px 16px;
            border-radius: 4px;
            font-size: 14px;
            cursor: pointer;
            margin-right: 5px; /* Reduced space */
        }
        .record-controls button:last-child {
            margin-right: 0;
        }
        .record-controls button:hover {
            background-color: #218838;
        }
    </style>
</head>
<body>
    <img src="img/h.jpg" alt="Hospital Logo" class="logo">
    <img src="img/home.png" alt="Home" class="home-button" onclick="goToHome()">

    <div class="doctor-details">
        <h1>Doctor Details</h1>

        <h2>Personal Details</h2>
        <form id="doctorForm" action="viewDoctor.jsp" method="post">
            <label for="firstName">First Name:</label>
            <input type="text" id="firstName" name="firstName" placeholder="Enter First Name" required>

            <label for="lastName">Last Name:</label>
            <input type="text" id="lastName" name="lastName" placeholder="Enter Last Name" required>

            <label for="sex">Sex:</label>
            <select id="sex" name="sex" required>
                <option value="" disabled selected>Select Sex</option>
                <option value="Male">Male</option>
                <option value="Female">Female</option>
            </select>

            <label for="nicNo">NIC No:</label>
            <input type="text" id="nicNo" name="nicNo" placeholder="Enter NIC No" required>

            <label for="mobilePhone">Mobile Phone:</label>
            <input type="text" id="mobilePhone" name="mobilePhone" placeholder="Enter Mobile Phone" required>

            <label for="homePhone">Home Phone:</label>
            <input type="text" id="homePhone" name="homePhone" placeholder="Enter Home Phone">

            <label for="address">Address:</label>
            <input type="text" id="address" name="address" placeholder="Enter Address" required>

            <label for="qualifications">Qualifications:</label>
            <input type="text" id="qualifications" name="qualifications" placeholder="Enter Qualifications" required>

            <label for="specialization">Specialization:</label>
            <input type="text" id="specialization" name="specialization" placeholder="Enter Specialization" required>

            <h2>Employee Details</h2>
            <label for="doctorType">Doctor Type:</label>
            <select id="doctorType" name="doctorType" required>
                <option value="" disabled selected>Select Doctor Type</option>
                <option value="Consultant">Consultant</option>
                <option value="Senior">Senior</option>
                <option value="Junior">Junior</option>
            </select>

            <label for="visitingCharge">Visiting Charge:</label>
            <input type="number" id="visitingCharge" name="visitingCharge" placeholder="Enter Visiting Charge">

            <label for="channelingCharge">Channeling Charge:</label>
            <input type="number" id="channelingCharge" name="channelingCharge" placeholder="Enter Channeling Charge">

            <label for="baseSalary">Base Salary:</label>
            <input type="number" id="baseSalary" name="baseSalary" placeholder="Enter Base Salary">

            <label for="notes">Notes:</label>
            <textarea id="notes" name="notes" placeholder="Enter Notes"></textarea>

            <button type="submit">Save Details</button>
        </form>

        <!-- Record Controls -->
        <div class="record-controls">
            <button onclick="searchRecord()">Search</button>
            <button onclick="addNewRecord()">Add New</button>
            <button onclick="viewRecord()">View All</button>
            <button onclick="refreshRecords()">Refresh</button>
        </div>
    </div>

    <script>
        function searchRecord() {
            const doctorId = document.getElementById('searchInput') ? document.getElementById('searchInput').value : '';
            window.location.href = `searchDoctor.jsp?doctorId=${doctorId}`;
        }

        function addNewRecord() {
            document.getElementById('doctorForm').reset();
            document.getElementById('firstName').focus();
        }

        function viewRecord() {
            window.location.href = 'viewDoctor.jsp';
        }

        function refreshRecords() {
            window.location.reload();
        }

        function goToHome() {
            window.location.href = 'Home.jsp'; // Redirects to home.jsp
        }

        // Auto-fill charges and salary based on doctor type (optional)
        document.getElementById('doctorType').addEventListener('change', function() {
            const doctorType = this.value;
            if (doctorType === "Consultant") {
                document.getElementById('visitingCharge').value = 5000;
                document.getElementById('channelingCharge').value = 3000;
                document.getElementById('baseSalary').value = 150000;
            } else if (doctorType === "Senior") {
                document.getElementById('visitingCharge').value = 3000;
                document.getElementById('channelingCharge').value = 2000;
                document.getElementById('baseSalary').value = 100000;
            } else if (doctorType === "Junior") {
                document.getElementById('visitingCharge').value = 2000;
                document.getElementById('channelingCharge').value = 1500;
                document.getElementById('baseSalary').value = 75000;
            }
        });
    </script>
</body>
</html>