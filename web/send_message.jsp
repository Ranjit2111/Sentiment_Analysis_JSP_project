<%@ page import="java.sql.*" %>
<%@ page import="com.globalcommunication.util.DatabaseUtil" %>
<%@ page import="com.globalcommunication.sentiment.SentimentAnalyzer" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%
// Get form parameters
String groupId = request.getParameter("group_id");
String message = request.getParameter("message");
String sender = (String) session.getAttribute("username");

// Validate input
if (groupId == null || groupId.isEmpty() || message == null || message.isEmpty() || sender == null || sender.isEmpty()) {
    response.setStatus(400);
    out.println("Error: Missing required parameters");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;

try {
    // Analyze sentiment
    String sentiment = SentimentAnalyzer.analyzeSentiment(message).getCategory().toLowerCase();
    
    // Insert message into database
    conn = DatabaseUtil.getConnection();
    String sql = "INSERT INTO group_messages (group_id, sender, message, sentiment) VALUES (?, ?, ?, ?)";
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, Integer.parseInt(groupId));
    pstmt.setString(2, sender);
    pstmt.setString(3, message);
    pstmt.setString(4, sentiment);
    
    int rowsAffected = pstmt.executeUpdate();
    
    if (rowsAffected > 0) {
        out.println("Message sent successfully");
    } else {
        response.setStatus(500);
        out.println("Error: Failed to send message");
    }
} catch (Exception e) {
    response.setStatus(500);
    out.println("Error: " + e.getMessage());
} finally {
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignore */ }
    if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignore */ }
}
%> 