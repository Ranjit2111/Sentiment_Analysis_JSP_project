<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.globalcommunication.util.DatabaseUtil" %>
<%@ page import="com.globalcommunication.sentiment.SentimentAnalyzer" %>

<%
// Get the group ID from the request parameter
String groupId = request.getParameter("group_id");
if (groupId == null || groupId.isEmpty()) {
    response.setStatus(400);
    out.println("{\"error\": \"Missing group_id parameter\"}");
    return;
}

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;
StringBuilder jsonResponse = new StringBuilder();

try {
    conn = DatabaseUtil.getConnection();
    
    // Get sentiment counts for the group
    String sql = "SELECT " +
                 "SUM(CASE WHEN sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_count, " +
                 "SUM(CASE WHEN sentiment = 'neutral' THEN 1 ELSE 0 END) AS neutral_count, " +
                 "SUM(CASE WHEN sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_count, " +
                 "COUNT(*) AS total_messages " +
                 "FROM group_messages " +
                 "WHERE group_id = ?";
    
    pstmt = conn.prepareStatement(sql);
    pstmt.setInt(1, Integer.parseInt(groupId));
    rs = pstmt.executeQuery();
    
    int positiveCount = 0;
    int neutralCount = 0;
    int negativeCount = 0;
    int totalMessages = 0;
    
    if (rs.next()) {
        positiveCount = rs.getInt("positive_count");
        neutralCount = rs.getInt("neutral_count");
        negativeCount = rs.getInt("negative_count");
        totalMessages = rs.getInt("total_messages");
    }
    
    // Determine overall sentiment
    String overallSentiment;
    String sentimentClass;
    String emoji;
    
    if (positiveCount > negativeCount && positiveCount > neutralCount) {
        overallSentiment = "Positive";
        sentimentClass = "sentiment-positive";
        emoji = SentimentAnalyzer.getSentimentEmoji("positive");
    } else if (negativeCount > positiveCount && negativeCount > neutralCount) {
        overallSentiment = "Negative";
        sentimentClass = "sentiment-negative";
        emoji = SentimentAnalyzer.getSentimentEmoji("negative");
    } else {
        overallSentiment = "Neutral";
        sentimentClass = "sentiment-neutral";
        emoji = SentimentAnalyzer.getSentimentEmoji("neutral");
    }
    
    // Get trend data for the last 7 days
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
    Calendar cal = Calendar.getInstance();
    cal.add(Calendar.DAY_OF_MONTH, -6); // Start from 6 days ago
    
    List<Map<String, Object>> trendData = new ArrayList<>();
    
    for (int i = 0; i < 7; i++) {
        String date = dateFormat.format(cal.getTime());
        
        // Get sentiment counts for this day
        sql = "SELECT " +
              "SUM(CASE WHEN sentiment = 'positive' THEN 1 ELSE 0 END) AS positive_count, " +
              "SUM(CASE WHEN sentiment = 'neutral' THEN 1 ELSE 0 END) AS neutral_count, " +
              "SUM(CASE WHEN sentiment = 'negative' THEN 1 ELSE 0 END) AS negative_count " +
              "FROM group_messages " +
              "WHERE group_id = ? AND DATE(timestamp) = ?";
        
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, Integer.parseInt(groupId));
        pstmt.setString(2, date);
        rs = pstmt.executeQuery();
        
        int dayPositive = 0;
        int dayNeutral = 0;
        int dayNegative = 0;
        
        if (rs.next()) {
            dayPositive = rs.getInt("positive_count");
            dayNeutral = rs.getInt("neutral_count");
            dayNegative = rs.getInt("negative_count");
        }
        
        // Determine day's sentiment
        String daySentiment;
        String daySentimentClass;
        String dayEmoji;
        
        if (dayPositive > dayNegative && dayPositive > dayNeutral) {
            daySentiment = "Positive";
            daySentimentClass = "sentiment-positive";
            dayEmoji = SentimentAnalyzer.getSentimentEmoji("positive");
        } else if (dayNegative > dayPositive && dayNegative > dayNeutral) {
            daySentiment = "Negative";
            daySentimentClass = "sentiment-negative";
            dayEmoji = SentimentAnalyzer.getSentimentEmoji("negative");
        } else {
            daySentiment = "Neutral";
            daySentimentClass = "sentiment-neutral";
            dayEmoji = SentimentAnalyzer.getSentimentEmoji("neutral");
        }
        
        Map<String, Object> dayData = new HashMap<>();
        dayData.put("date", date);
        dayData.put("positive", dayPositive);
        dayData.put("neutral", dayNeutral);
        dayData.put("negative", dayNegative);
        dayData.put("sentiment", daySentiment);
        dayData.put("sentiment_class", daySentimentClass);
        dayData.put("emoji", dayEmoji);
        
        trendData.add(dayData);
        
        cal.add(Calendar.DAY_OF_MONTH, 1);
    }
    
    // Build the JSON response
    jsonResponse.append("{");
    
    // Add stats object
    jsonResponse.append("\"stats\": {");
    jsonResponse.append("\"positive\": ").append(positiveCount).append(",");
    jsonResponse.append("\"neutral\": ").append(neutralCount).append(",");
    jsonResponse.append("\"negative\": ").append(negativeCount).append(",");
    jsonResponse.append("\"total\": ").append(totalMessages);
    jsonResponse.append("},");
    
    // Add overall sentiment object
    jsonResponse.append("\"overall_sentiment\": {");
    jsonResponse.append("\"sentiment\": \"").append(escapeJson(overallSentiment)).append("\",");
    jsonResponse.append("\"sentiment_class\": \"").append(escapeJson(sentimentClass)).append("\",");
    jsonResponse.append("\"emoji\": \"").append(escapeJson(emoji)).append("\"");
    jsonResponse.append("},");
    
    // Add trend data array
    jsonResponse.append("\"trend\": [");
    for (int i = 0; i < trendData.size(); i++) {
        Map<String, Object> day = trendData.get(i);
        
        if (i > 0) {
            jsonResponse.append(",");
        }
        
        jsonResponse.append("{");
        jsonResponse.append("\"date\": \"").append(escapeJson((String) day.get("date"))).append("\",");
        jsonResponse.append("\"positive\": ").append(day.get("positive")).append(",");
        jsonResponse.append("\"neutral\": ").append(day.get("neutral")).append(",");
        jsonResponse.append("\"negative\": ").append(day.get("negative")).append(",");
        jsonResponse.append("\"sentiment\": \"").append(escapeJson((String) day.get("sentiment"))).append("\",");
        jsonResponse.append("\"sentiment_class\": \"").append(escapeJson((String) day.get("sentiment_class"))).append("\",");
        jsonResponse.append("\"emoji\": \"").append(escapeJson((String) day.get("emoji"))).append("\"");
        jsonResponse.append("}");
    }
    jsonResponse.append("]");
    
    jsonResponse.append("}");
    
} catch (Exception e) {
    response.setStatus(500);
    jsonResponse = new StringBuilder();
    jsonResponse.append("{\"error\": \"").append(escapeJson(e.getMessage())).append("\"}");
} finally {
    if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignore */ }
    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignore */ }
    if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignore */ }
}

out.println(jsonResponse.toString());
%>

<%!
// Helper method to escape JSON strings
private String escapeJson(String input) {
    if (input == null) {
        return "";
    }
    
    StringBuilder sb = new StringBuilder();
    for (int i = 0; i < input.length(); i++) {
        char ch = input.charAt(i);
        switch (ch) {
            case '"':
                sb.append("\\\"");
                break;
            case '\\':
                sb.append("\\\\");
                break;
            case '\b':
                sb.append("\\b");
                break;
            case '\f':
                sb.append("\\f");
                break;
            case '\n':
                sb.append("\\n");
                break;
            case '\r':
                sb.append("\\r");
                break;
            case '\t':
                sb.append("\\t");
                break;
            default:
                sb.append(ch);
        }
    }
    return sb.toString();
}
%> 