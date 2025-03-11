<%@ page import="java.sql.*, java.util.*, java.text.SimpleDateFormat" %>
<%@ page session="true" %>
<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>

<%
    // Get group_id parameter
    String groupId = request.getParameter("group_id");
    if (groupId == null || groupId.isEmpty()) {
        response.setStatus(400);
        out.print("{\"error\": \"Missing group_id parameter\"}");
        return;
    }
    
    // Create JSON response manually
    StringBuilder json = new StringBuilder();
    json.append("{");
    
    try {
        Class.forName("org.postgresql.Driver");
        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
        
        // Get group info and totals
        String groupQuery = "SELECT g.group_name, " +
            "SUM(CASE WHEN gm.sentiment = 'POSITIVE' THEN 1 ELSE 0 END) as positive_count, " +
            "SUM(CASE WHEN gm.sentiment = 'NEUTRAL' THEN 1 ELSE 0 END) as neutral_count, " +
            "SUM(CASE WHEN gm.sentiment = 'NEGATIVE' THEN 1 ELSE 0 END) as negative_count, " +
            "COUNT(*) as total_messages " +
            "FROM group_messages gm " +
            "JOIN groups g ON gm.group_id = g.group_id " +
            "WHERE gm.group_id = ? " +
            "GROUP BY g.group_name";
        
        PreparedStatement groupStmt = conn.prepareStatement(groupQuery);
        groupStmt.setInt(1, Integer.parseInt(groupId));
        ResultSet groupRs = groupStmt.executeQuery();
        
        if (groupRs.next()) {
            String groupName = groupRs.getString("group_name");
            int positiveCount = groupRs.getInt("positive_count");
            int neutralCount = groupRs.getInt("neutral_count");
            int negativeCount = groupRs.getInt("negative_count");
            int totalMessages = groupRs.getInt("total_messages");
            
            // Add basic stats to JSON response
            json.append("\"groupName\":\"").append(escapeJson(groupName)).append("\",");
            json.append("\"positiveCount\":").append(positiveCount).append(",");
            json.append("\"neutralCount\":").append(neutralCount).append(",");
            json.append("\"negativeCount\":").append(negativeCount).append(",");
            json.append("\"totalMessages\":").append(totalMessages).append(",");
            
            // Determine overall sentiment
            String overallSentiment;
            if (positiveCount > negativeCount && positiveCount > neutralCount) {
                overallSentiment = "POSITIVE";
            } else if (negativeCount > positiveCount && negativeCount > neutralCount) {
                overallSentiment = "NEGATIVE";
            } else {
                overallSentiment = "NEUTRAL";
            }
            json.append("\"overallSentiment\":\"").append(overallSentiment).append("\",");
        }
        groupStmt.close();
        
        // Get sentiment trend for the last 7 days
        String trendQuery = "SELECT day_date, positive_count, neutral_count, negative_count " +
            "FROM sentiment_stats " +
            "WHERE group_id = ? " +
            "AND day_date >= CURRENT_DATE - 7 " +
            "ORDER BY day_date";
        
        PreparedStatement trendStmt = conn.prepareStatement(trendQuery);
        trendStmt.setInt(1, Integer.parseInt(groupId));
        ResultSet trendRs = trendStmt.executeQuery();
        
        // Create JSON array for trend data
        json.append("\"trendData\":[");
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        boolean firstTrend = true;
        
        while (trendRs.next()) {
            if (!firstTrend) {
                json.append(",");
            }
            firstTrend = false;
            
            Date dayDate = trendRs.getDate("day_date");
            int positiveCount = trendRs.getInt("positive_count");
            int neutralCount = trendRs.getInt("neutral_count");
            int negativeCount = trendRs.getInt("negative_count");
            
            json.append("{");
            json.append("\"date\":\"").append(dateFormat.format(dayDate)).append("\",");
            json.append("\"positive\":").append(positiveCount).append(",");
            json.append("\"neutral\":").append(neutralCount).append(",");
            json.append("\"negative\":").append(negativeCount);
            json.append("}");
        }
        json.append("]");
        trendStmt.close();
        
        conn.close();
    } catch (Exception e) {
        json.append("\"error\":\"").append(escapeJson(e.getMessage())).append("\"");
    }
    
    // Output JSON response
    json.append("}");
    out.print(json.toString());
%>

<%!
    // Helper method to escape JSON strings
    private String escapeJson(String input) {
        if (input == null) {
            return "";
        }
        
        StringBuilder result = new StringBuilder();
        for (int i = 0; i < input.length(); i++) {
            char ch = input.charAt(i);
            switch (ch) {
                case '\"':
                    result.append("\\\"");
                    break;
                case '\\':
                    result.append("\\\\");
                    break;
                case '\b':
                    result.append("\\b");
                    break;
                case '\f':
                    result.append("\\f");
                    break;
                case '\n':
                    result.append("\\n");
                    break;
                case '\r':
                    result.append("\\r");
                    break;
                case '\t':
                    result.append("\\t");
                    break;
                default:
                    result.append(ch);
            }
        }
        return result.toString();
    }
%> 