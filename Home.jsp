<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Management System</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            position: relative;
            background-image: url('img/bg.jpg');
            background-size: cover;
            background-position: center;
            background-repeat: no-repeat;
        }
        .main-container {
            display: flex;
            flex-direction: column;
            gap: 25px;
            background-color: white;
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            width: 600px;
            max-height: 80vh;
            overflow-y: auto;
        }
        .welcome-box {
            text-align: center;
            padding: 15px 0;
            border-bottom: 1px solid #e0e0e0;
            margin-bottom: 20px;
        }
        h1 {
            color: #333;
            margin: 0;
            font-size: 24px;
            font-weight: 600;
            line-height: 1.4;
        }
        .button-container {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }
        .button-container button {
            background-color: #007bff;
            color: #fff;
            border: none;
            padding: 14px;
            border-radius: 6px;
            font-size: 16px;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .button-container button:hover {
            background-color: #0056b3;
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.15);
        }
        .sub-buttons {
            display: none;
            grid-column: 1 / -1;
            grid-template-columns: repeat(2, 1fr);
            gap: 10px;
            padding: 10px;
            background-color: #f5f5f5;
            border-radius: 4px;
            margin-top: -10px;
        }
        .sub-buttons button {
            background-color: #6c757d;
            padding: 10px;
            font-size: 14px;
        }
        .sub-buttons button:hover {
            background-color: #5a6268;
        }
        .has-submenu {
            position: relative;
        }
        .has-submenu.active {
            background-color: #0056b3;
        }
        .has-submenu.active + .sub-buttons {
            display: grid;
        }
        .corner-image {
            position: absolute;
            top: 20px;
            left: 20px;
            width: 200px;
            height: auto;
        }
        .user-info {
            position: absolute;
            top: 20px;
            right: 20px;
            font-size: 15px;
            color: #333;
            background-color: white;
            padding: 8px 15px;
            border-radius: 4px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        
        @media (max-width: 650px) {
            .main-container {
                width: 90%;
                padding: 30px;
            }
            .button-container {
                grid-template-columns: 1fr;
            }
            .sub-buttons {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <img src="img/h.jpg" alt="Hospital Logo" class="corner-image">
    <div class="user-info">
        Logged in as: <strong><%= request.getParameter("username") %></strong>
    </div>

    <div class="main-container">
        <div class="welcome-box">
            <h1>Welcome to Hospital Management System</h1>
        </div>
        
        <div class="button-container">
            <button onclick="window.location.href='Doctor.jsp'">Doctor</button>
            <button onclick="window.location.href='MedicalServices.jsp'">Medical Services</button>
            <button onclick="window.location.href='DoctorAppSch.jsp'">Doctor Appointment</button>
            <button onclick="window.location.href='HospitalServicesDetails.jsp'">Hospital Services</button>
            <button onclick="window.location.href='RoomDetails.jsp'">Rooms</button>
            <button onclick="window.location.href='wardDetails.jsp'">Wards</button>
            <button onclick="window.location.href='bedDetails.jsp'">Beds</button>
            <button onclick="window.location.href='category.jsp'">Medicine Categories</button>
            <button onclick="window.location.href='product.jsp'">Medicine Product </button>
            
            <!-- Out Patient with sub-buttons -->
            <button class="has-submenu" id="outPatientBtn">Out Patient</button>
            <div class="sub-buttons">
                <button onclick="window.location.href='addDocAppo.jsp'">Add Doctor Appointment</button>
                <button onclick="window.location.href='addHosAppo.jsp'">Add Hospital Service Appointment</button>
                <button onclick="window.location.href='viewDocAppo.jsp'">View Doctor Appointment</button>
                <button onclick="window.location.href='viewServAppo'">View Hospital Service Appointment</button>
                <button onclick="window.location.href='cancelDoc.jsp'">Cancel Doctor Appointment</button>
                <button onclick="window.location.href='cancelServAppo.jsp'">Cancel Hospital Service Appointment</button>
                <button onclick="window.location.href='treatmentDetails.jsp'">Treatment Details</button>
            </div>
            
            <!-- In Patient with sub-buttons -->
            <button class="has-submenu" id="inPatientBtn">In Patient</button>
            <div class="sub-buttons">
                <button onclick="window.location.href='guardianDetails.jsp'">Guardian Details</button>
                <button onclick="window.location.href='admissionDetails.jsp'">Admission Details</button>
                <button onclick="window.location.href='inpHospitalService.jsp'">In patient Hospital Service</button>
                
            </div>
             
             <button onclick="window.location.href='inpVisit.jsp'">In Patient Doctor Visit </button>
           
        </div>
    </div>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            const outPatientBtn = document.getElementById('outPatientBtn');
            const inPatientBtn = document.getElementById('inPatientBtn');
            let outPatientClickCount = 0;
            let inPatientClickCount = 0;
            let outPatientClickTimer = null;
            let inPatientClickTimer = null;

            outPatientBtn.addEventListener('click', function() {
                outPatientClickCount++;
                
                if (outPatientClickCount === 1) {
                    outPatientClickTimer = setTimeout(function() {
                        // Single click action - navigate to outPatient.jsp
                        window.location.href = 'outPatient.jsp';
                        outPatientClickCount = 0;
                    }, 300);
                } else if (outPatientClickCount === 2) {
                    // Double click action - show sub-buttons
                    clearTimeout(outPatientClickTimer);
                    toggleSubButtons(outPatientBtn);
                    outPatientClickCount = 0;
                }
            });

            inPatientBtn.addEventListener('click', function() {
                inPatientClickCount++;
                
                if (inPatientClickCount === 1) {
                    inPatientClickTimer = setTimeout(function() {
                        // Single click action - navigate to inPatient.jsp
                        window.location.href = 'inPatient.jsp';
                        inPatientClickCount = 0;
                    }, 300);
                } else if (inPatientClickCount === 2) {
                    // Double click action - show sub-buttons
                    clearTimeout(inPatientClickTimer);
                    toggleSubButtons(inPatientBtn);
                    inPatientClickCount = 0;
                }
            });

            function toggleSubButtons(button) {
                // Toggle active class on the main button
                button.classList.toggle('active');
                
                // Find the next sibling with class sub-buttons
                const subButtons = button.nextElementSibling;
                
                // Close any other open submenus
                document.querySelectorAll('.sub-buttons').forEach(sub => {
                    if (sub !== subButtons) {
                        sub.style.display = 'none';
                        sub.previousElementSibling.classList.remove('active');
                    }
                });

                // Toggle display of the sub-buttons
                subButtons.style.display = subButtons.style.display === 'grid' ? 'none' : 'grid';
            }
        });
    </script>
</body>
</html>