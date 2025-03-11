<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.globalcommunication.utils.SentimentAnalyzer" %>
<%@ page import="com.globalcommunication.utils.SentimentAnalyzer.SentimentResult" %>
<%@ page session="true" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>

<%
    // Sentiment analysis statistics
    int positiveCount = 0;
    int neutralCount = 0;
    int negativeCount = 0;
    
    try {
        Class.forName("org.postgresql.Driver");
        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");

        String chatQuery = "SELECT sender, message, timestamp FROM group_messages WHERE group_id = ? ORDER BY timestamp";
        PreparedStatement chatStmt = conn.prepareStatement(chatQuery);
        chatStmt.setInt(1, Integer.parseInt(request.getParameter("group_id")));
        ResultSet chatRs = chatStmt.executeQuery();
        
        // Display sentiment summary at the top
%>
        <div class="sentiment-summary">
            <h3 style="margin: 0;">Conversation Sentiment Analysis</h3>
            <div id="sentimentSummary">Analyzing messages...</div>
        </div>
<%
        while (chatRs.next()) {
            String sender = chatRs.getString("sender");
            String message = chatRs.getString("message");
            Timestamp timestamp = chatRs.getTimestamp("timestamp");
            
            // Analyze sentiment
            SentimentResult sentiment = SentimentAnalyzer.analyzeSentiment(message);
            String sentimentCategory = sentiment.getCategory();
            String sentimentEmoji = SentimentAnalyzer.getSentimentEmoji(sentimentCategory);
            
            // Update sentiment counts
            if ("POSITIVE".equals(sentimentCategory)) {
                positiveCount++;
            } else if ("NEGATIVE".equals(sentimentCategory)) {
                negativeCount++;
            } else {
                neutralCount++;
            }
            
            // Determine badge class based on sentiment
            String badgeClass = "";
            if ("POSITIVE".equals(sentimentCategory)) {
                badgeClass = "sentiment-positive";
            } else if ("NEGATIVE".equals(sentimentCategory)) {
                badgeClass = "sentiment-negative";
            } else {
                badgeClass = "sentiment-neutral";
            }
%>
            <div class="message">
                <div class="message-header">
                    <span class="message-sender">
                        <i class="fas fa-user-circle"></i> <%= sender %>
                        <span class="sentiment-badge <%= badgeClass %>">
                            <%= sentimentEmoji %> <%= sentimentCategory.toLowerCase() %>
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
        chatStmt.close();
        conn.close();
    } catch (Exception e) {
        out.println("<p class='error-message'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
    }
%> 