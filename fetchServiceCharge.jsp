<%@ page import="java.sql.*" %>
<%
String serviceId = request.getParameter("serviceId");
String DB_URL = "jdbc:mysql://localhost:3306/hospital";
String DB_USER = "root";
String DB_PASSWORD = "@Sashini123";
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    Class.forName("com.mysql.cj.jdbc.Driver");
    conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
    String query = "SELECT charge FROM MedicalServices WHERE Channel_Service_ID = ?";
    pstmt = conn.prepareStatement(query);
    pstmt.setString(1, serviceId);
    rs = pstmt.executeQuery();

    if (rs.next()) {
        out.print(rs.getString("charge")); // Return the service charge
    } else {
        out.print("0"); // Return 0 if not found
    }
} catch (Exception e) {
    e.printStackTrace();
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) {}
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) {}
    if (conn != null) try { conn.close(); } catch (SQLException e) {}
}
%>