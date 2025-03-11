<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.globalcommunication.utils.SentimentAnalyzer" %>
<%@ page import="com.globalcommunication.utils.SentimentAnalyzer.SentimentResult" %>
<%@ page session="true" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Update Sentiment Analysis</title>
    <link rel="stylesheet" href="assets/css/global.css">
</head>
<body>
    <div class="page-container">
        <h1 class="main-title">Updating Sentiment Analysis</h1>
        
        <div class="form-container">
            <div class="form-card">
                <%
                    // Check if user is logged in
                    String currentUser = (String) session.getAttribute("username");
                    if (currentUser == null) {
                        response.sendRedirect("signin.jsp");
                        return;
                    }
                    
                    int updatedCount = 0;
                    int totalMessages = 0;
                    
                    try {
                        Class.forName("org.postgresql.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                        
                        // First, get all messages
                        String selectQuery = "SELECT message_id, message FROM group_messages";
                        PreparedStatement selectStmt = conn.prepareStatement(selectQuery);
                        ResultSet rs = selectStmt.executeQuery();
                        
                        // Prepare update statement
                        String updateQuery = "UPDATE group_messages SET sentiment = ?, sentiment_score = ? WHERE message_id = ?";
                        PreparedStatement updateStmt = conn.prepareStatement(updateQuery);
                        
                        // Process each message
                        while (rs.next()) {
                            int messageId = rs.getInt("message_id");
                            String message = rs.getString("message");
                            totalMessages++;
                            
                            // Analyze sentiment with improved analyzer
                            SentimentResult sentiment = SentimentAnalyzer.analyzeSentiment(message);
                            String sentimentCategory = sentiment.getCategory();
                            double sentimentScore = sentiment.getScore();
                            
                            // Update the record
                            updateStmt.setString(1, sentimentCategory);
                            updateStmt.setDouble(2, sentimentScore);
                            updateStmt.setInt(3, messageId);
                            
                            int rowsUpdated = updateStmt.executeUpdate();
                            if (rowsUpdated > 0) {
                                updatedCount++;
                            }
                        }
                        
                        // Clear and rebuild sentiment_stats table
                        String clearStatsQuery = "DELETE FROM sentiment_stats";
                        PreparedStatement clearStatsStmt = conn.prepareStatement(clearStatsQuery);
                        clearStatsStmt.executeUpdate();
                        
                        // Rebuild sentiment stats
                        String rebuildStatsQuery = 
                            "INSERT INTO sentiment_stats (group_id, day_date, positive_count, neutral_count, negative_count) " +
                            "SELECT group_id, DATE(timestamp) as day_date, " +
                            "SUM(CASE WHEN sentiment = 'POSITIVE' THEN 1 ELSE 0 END) as positive_count, " +
                            "SUM(CASE WHEN sentiment = 'NEUTRAL' THEN 1 ELSE 0 END) as neutral_count, " +
                            "SUM(CASE WHEN sentiment = 'NEGATIVE' THEN 1 ELSE 0 END) as negative_count " +
                            "FROM group_messages " +
                            "GROUP BY group_id, DATE(timestamp)";
                        
                        PreparedStatement rebuildStatsStmt = conn.prepareStatement(rebuildStatsQuery);
                        int statsRowsInserted = rebuildStatsStmt.executeUpdate();
                        
                        // Close resources
                        rs.close();
                        selectStmt.close();
                        updateStmt.close();
                        clearStatsStmt.close();
                        rebuildStatsStmt.close();
                        conn.close();
                        
                    } catch (Exception e) {
                        out.println("<p class='error-message'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
                    }
                %>
                
                <div class="success-message" style="text-align: center; margin: 2rem 0;">
                    <h2><i class="fas fa-check-circle"></i> Sentiment Analysis Updated</h2>
                    <p>Successfully updated <%= updatedCount %> out of <%= totalMessages %> messages.</p>
                    <p>The sentiment statistics have been recalculated.</p>
                </div>
                
                <div style="display: flex; justify-content: center; gap: 1rem; margin-top: 2rem;">
                    <a href="group_chat.jsp" class="primary-button">
                        <i class="fas fa-users"></i> Go to Groups
                    </a>
                </div>
            </div>
        </div>
    </div>
</body>
</html> 