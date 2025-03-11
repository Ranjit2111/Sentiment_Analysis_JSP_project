<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.globalcommunication.sentiment.SentimentAnalyzer" %>
<%@ page import="com.globalcommunication.util.DatabaseUtil" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%
    // Sentiment analysis statistics
    int positiveCount = 0;
    int neutralCount = 0;
    int negativeCount = 0;
    
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn = DatabaseUtil.getConnection();

        String chatQuery = "SELECT sender, message, timestamp, sentiment FROM group_messages WHERE group_id = ? ORDER BY timestamp";
        pstmt = conn.prepareStatement(chatQuery);
        pstmt.setInt(1, Integer.parseInt(request.getParameter("group_id")));
        rs = pstmt.executeQuery();
        
        // Display sentiment summary at the top
%>
        <div class="sentiment-summary">
            <h3 style="margin: 0;">Conversation Sentiment Analysis</h3>
            <div id="sentimentSummary">Analyzing messages...</div>
        </div>
<%
        while (rs.next()) {
            String sender = rs.getString("sender");
            String message = rs.getString("message");
            Timestamp timestamp = rs.getTimestamp("timestamp");
            String sentimentCategory = rs.getString("sentiment").toLowerCase();
            
            // Update sentiment counts
            if ("positive".equals(sentimentCategory)) {
                positiveCount++;
            } else if ("negative".equals(sentimentCategory)) {
                negativeCount++;
            } else {
                neutralCount++;
            }
            
            // Get sentiment emoji
            String sentimentEmoji = SentimentAnalyzer.getSentimentEmoji(sentimentCategory);
            
            // Determine badge class based on sentiment
            String badgeClass = "sentiment-" + sentimentCategory;
%>
            <div class="message">
                <div class="message-header">
                    <span class="message-sender">
                        <i class="fas fa-user-circle"></i> <%= sender %>
                        <span class="sentiment-badge <%= badgeClass %>">
                            <%= sentimentEmoji %> <%= sentimentCategory %>
                        </span>
                    </span>
                    <span class="message-time">
                        <i class="fas fa-clock"></i> <%= timestamp %>
                    </span>
                </div>
                <div class="message-content"><%= message %></div>
            </div>
<%
        }
        
        // Add hidden fields for sentiment counts
%>
        <input type="hidden" id="positive-count" value="<%= positiveCount %>">
        <input type="hidden" id="neutral-count" value="<%= neutralCount %>">
        <input type="hidden" id="negative-count" value="<%= negativeCount %>">
<%
    } catch (Exception e) {
        out.println("<p class='error-message'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignore */ }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignore */ }
        if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignore */ }
    }
%> 