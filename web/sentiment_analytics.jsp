<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="com.globalcommunication.utils.SentimentAnalyzer" %>
<%@ page import="com.globalcommunication.utils.SentimentAnalyzer.SentimentResult" %>
<%@ page session="true" %>
<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Sentiment Analytics | Group Chat</title>
    <link rel="stylesheet" href="assets/css/global.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .analytics-container {
            max-width: 1000px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        .stat-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }
        
        .stat-card {
            background: white;
            border-radius: 0.5rem;
            padding: 1.5rem;
            display: flex;
            flex-direction: column;
            align-items: center;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: bold;
            margin: 0.5rem 0;
        }
        
        .stat-label {
            color: #6b7280;
            text-align: center;
        }
        
        .sentiment-positive {
            color: #10B981;
        }
        
        .sentiment-neutral {
            color: #6B7280;
        }
        
        .sentiment-negative {
            color: #EF4444;
        }
        
        .chart-container {
            background: white;
            border-radius: 0.5rem;
            padding: 1rem;
            margin-bottom: 2rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .chart-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 1rem;
        }
        
        .chart-title {
            font-size: 1.25rem;
            font-weight: 600;
            color: #1f2937;
        }
        
        .table-container {
            background: white;
            border-radius: 0.5rem;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        
        .data-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .data-table th {
            background: #f3f4f6;
            padding: 0.75rem 1rem;
            text-align: left;
            font-weight: 600;
            color: #374151;
        }
        
        .data-table td {
            padding: 0.75rem 1rem;
            border-top: 1px solid #e5e7eb;
        }
        
        .data-table tr:hover {
            background: #f9fafb;
        }
        
        .sentiment-badge {
            display: inline-flex;
            align-items: center;
            padding: 0.25rem 0.5rem;
            border-radius: 9999px;
            font-size: 0.75rem;
            font-weight: 500;
        }
        
        .sentiment-positive {
            background-color: #d1fae5;
            color: #065f46;
        }
        
        .sentiment-neutral {
            background-color: #e5e7eb;
            color: #374151;
        }
        
        .sentiment-negative {
            background-color: #fee2e2;
            color: #991b1b;
        }
        
        .progress-container {
            width: 100%;
            background-color: #e5e7eb;
            border-radius: 9999px;
            margin: 1rem 0;
            overflow: hidden;
        }
        
        .progress-bar {
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 0.75rem;
            font-weight: 600;
        }
        
        .progress-positive {
            background-color: #10B981;
        }
        
        .progress-neutral {
            background-color: #6B7280;
        }
        
        .progress-negative {
            background-color: #EF4444;
        }
        
        .trend-table {
            width: 100%;
        }
        
        .trend-table th, .trend-table td {
            padding: 0.75rem;
            text-align: center;
        }
        
        .trend-table th {
            background-color: #f3f4f6;
            font-weight: 600;
        }
        
        .trend-table td {
            border-top: 1px solid #e5e7eb;
        }
    </style>
</head>
<body>
    <%
        // Get the current user from session
        String currentUser = (String) session.getAttribute("username");
        if (currentUser == null) {
            response.sendRedirect("signin.jsp");
            return;
        }
        
        // Get group_id parameter
        String groupId = request.getParameter("group_id");
        if (groupId == null || groupId.isEmpty()) {
            response.sendRedirect("group_chat.jsp");
            return;
        }
        
        // Variables for storing results
        String groupName = "";
        int totalMessages = 0;
        int positiveCount = 0;
        int neutralCount = 0;
        int negativeCount = 0;
        String overallSentiment = "";
        
        // Variables for trend data
        List<String> trendDates = new ArrayList<>();
        List<Integer> trendPositive = new ArrayList<>();
        List<Integer> trendNeutral = new ArrayList<>();
        List<Integer> trendNegative = new ArrayList<>();
    %>
    
    <div class="page-container">
        <form action="chat.jsp" method="post" style="padding: 1rem;">
            <input type="hidden" name="group_id" value="<%= groupId %>">
            <button type="submit" class="primary-button" style="max-width: 200px;">
                <i class="fas fa-arrow-left"></i> Back to Chat
            </button>
        </form>

        <h1 class="main-title">Sentiment Analytics</h1>
        
        <div class="analytics-container">
            <%
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
                        groupName = groupRs.getString("group_name");
                        positiveCount = groupRs.getInt("positive_count");
                        neutralCount = groupRs.getInt("neutral_count");
                        negativeCount = groupRs.getInt("negative_count");
                        totalMessages = groupRs.getInt("total_messages");
                        
                        // Determine overall sentiment
                        if (positiveCount > negativeCount && positiveCount > neutralCount) {
                            overallSentiment = "POSITIVE";
                        } else if (negativeCount > positiveCount && negativeCount > neutralCount) {
                            overallSentiment = "NEGATIVE";
                        } else {
                            overallSentiment = "NEUTRAL";
                        }
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
                    
                    while (trendRs.next()) {
                        trendDates.add(trendRs.getDate("day_date").toString());
                        trendPositive.add(trendRs.getInt("positive_count"));
                        trendNeutral.add(trendRs.getInt("neutral_count"));
                        trendNegative.add(trendRs.getInt("negative_count"));
                    }
                    trendStmt.close();
                    
                    conn.close();
                } catch (Exception e) {
                    out.println("<p class='error-message'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
                }
            %>
            
            <div class="chart-header" style="margin-bottom: 2rem;">
                <h2 class="chart-title"><%= groupName %> - Sentiment Analysis</h2>
                <div class="auto-update-indicator" style="font-size: 0.875rem; color: #059669;">
                    <i class="fas fa-sync-alt fa-spin"></i> Auto-updating every 10 seconds
                </div>
            </div>
            
            <div class="stat-cards">
                <div class="stat-card">
                    <div class="stat-label">Total Messages</div>
                    <div class="stat-value"><%= totalMessages %></div>
                    <div class="stat-label">
                        <i class="fas fa-comments"></i> Messages analyzed
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-label">Positive Sentiment</div>
                    <div class="stat-value sentiment-positive">
                        <%= positiveCount %>
                        <% if (totalMessages > 0) { %>
                        <small>(<%= Math.round((positiveCount / (double)totalMessages) * 100) %>%)</small>
                        <% } %>
                    </div>
                    <div class="stat-label">
                        <i class="fas fa-smile"></i> <%= SentimentAnalyzer.getSentimentEmoji("POSITIVE") %>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-label">Neutral Sentiment</div>
                    <div class="stat-value sentiment-neutral">
                        <%= neutralCount %>
                        <% if (totalMessages > 0) { %>
                        <small>(<%= Math.round((neutralCount / (double)totalMessages) * 100) %>%)</small>
                        <% } %>
                    </div>
                    <div class="stat-label">
                        <i class="fas fa-meh"></i> <%= SentimentAnalyzer.getSentimentEmoji("NEUTRAL") %>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-label">Negative Sentiment</div>
                    <div class="stat-value sentiment-negative">
                        <%= negativeCount %>
                        <% if (totalMessages > 0) { %>
                        <small>(<%= Math.round((negativeCount / (double)totalMessages) * 100) %>%)</small>
                        <% } %>
                    </div>
                    <div class="stat-label">
                        <i class="fas fa-frown"></i> <%= SentimentAnalyzer.getSentimentEmoji("NEGATIVE") %>
                    </div>
                </div>
            </div>
            
            <div class="chart-container">
                <div class="chart-header">
                    <h2 class="chart-title">Overall Sentiment Distribution</h2>
                </div>
                
                <% if (totalMessages > 0) { %>
                    <div class="progress-container">
                        <% 
                            int positivePercent = Math.round((positiveCount / (float)totalMessages) * 100);
                            int neutralPercent = Math.round((neutralCount / (float)totalMessages) * 100);
                            int negativePercent = Math.round((negativeCount / (float)totalMessages) * 100);
                        %>
                        <div style="display: flex; width: 100%;">
                            <% if (positivePercent > 0) { %>
                                <div class="progress-bar progress-positive" style="width: <%= positivePercent %>%;">
                                    <%= positivePercent %>%
                                </div>
                            <% } %>
                            
                            <% if (neutralPercent > 0) { %>
                                <div class="progress-bar progress-neutral" style="width: <%= neutralPercent %>%;">
                                    <%= neutralPercent %>%
                                </div>
                            <% } %>
                            
                            <% if (negativePercent > 0) { %>
                                <div class="progress-bar progress-negative" style="width: <%= negativePercent %>%;">
                                    <%= negativePercent %>%
                                </div>
                            <% } %>
                        </div>
                    </div>
                    
                    <div style="display: flex; justify-content: space-between; margin-top: 0.5rem;">
                        <div>
                            <span class="sentiment-badge sentiment-positive"><%= SentimentAnalyzer.getSentimentEmoji("POSITIVE") %> Positive</span>
                        </div>
                        <div>
                            <span class="sentiment-badge sentiment-neutral"><%= SentimentAnalyzer.getSentimentEmoji("NEUTRAL") %> Neutral</span>
                        </div>
                        <div>
                            <span class="sentiment-badge sentiment-negative"><%= SentimentAnalyzer.getSentimentEmoji("NEGATIVE") %> Negative</span>
                        </div>
                </div>
                <% } else { %>
                    <p class="text-center" style="padding: 2rem; color: #6b7280;">No messages to analyze</p>
                <% } %>
            </div>
            
            <div class="chart-container">
                <div class="chart-header">
                    <h2 class="chart-title">Sentiment Trends (Last 7 Days)</h2>
                </div>
                
                <% if (!trendDates.isEmpty()) { %>
                    <div class="table-responsive">
                        <table class="trend-table">
                            <thead>
                                <tr>
                                    <th>Date</th>
                                    <th>Positive</th>
                                    <th>Neutral</th>
                                    <th>Negative</th>
                                    <th>Overall</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (int i = 0; i < trendDates.size(); i++) { %>
                                    <tr>
                                        <td><%= trendDates.get(i) %></td>
                                        <td class="sentiment-positive"><%= trendPositive.get(i) %></td>
                                        <td class="sentiment-neutral"><%= trendNeutral.get(i) %></td>
                                        <td class="sentiment-negative"><%= trendNegative.get(i) %></td>
                                        <td>
                                            <% 
                                                int pos = trendPositive.get(i);
                                                int neu = trendNeutral.get(i);
                                                int neg = trendNegative.get(i);
                                                String dailySentiment;
                                                String sentimentClass;
                                                String emoji;
                                                
                                                if (pos > neg && pos > neu) {
                                                    dailySentiment = "Positive";
                                                    sentimentClass = "sentiment-positive";
                                                    emoji = SentimentAnalyzer.getSentimentEmoji("POSITIVE");
                                                } else if (neg > pos && neg > neu) {
                                                    dailySentiment = "Negative";
                                                    sentimentClass = "sentiment-negative";
                                                    emoji = SentimentAnalyzer.getSentimentEmoji("NEGATIVE");
                                                } else {
                                                    dailySentiment = "Neutral";
                                                    sentimentClass = "sentiment-neutral";
                                                    emoji = SentimentAnalyzer.getSentimentEmoji("NEUTRAL");
                                                }
                                            %>
                                            <span class="sentiment-badge <%= sentimentClass %>">
                                                <%= emoji %> <%= dailySentiment %>
                                            </span>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                </div>
                <% } else { %>
                    <p class="text-center" style="padding: 2rem; color: #6b7280;">No trend data available</p>
                <% } %>
            </div>
            
            <div class="table-container">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th>Category</th>
                            <th>Count</th>
                            <th>Percentage</th>
                            <th>Sentiment</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Positive Messages</td>
                            <td><%= positiveCount %></td>
                            <td><%= totalMessages > 0 ? Math.round((positiveCount / (double)totalMessages) * 100) : 0 %>%</td>
                            <td><span class="sentiment-badge sentiment-positive"><%= SentimentAnalyzer.getSentimentEmoji("POSITIVE") %> Positive</span></td>
                        </tr>
                        <tr>
                            <td>Neutral Messages</td>
                            <td><%= neutralCount %></td>
                            <td><%= totalMessages > 0 ? Math.round((neutralCount / (double)totalMessages) * 100) : 0 %>%</td>
                            <td><span class="sentiment-badge sentiment-neutral"><%= SentimentAnalyzer.getSentimentEmoji("NEUTRAL") %> Neutral</span></td>
                        </tr>
                        <tr>
                            <td>Negative Messages</td>
                            <td><%= negativeCount %></td>
                            <td><%= totalMessages > 0 ? Math.round((negativeCount / (double)totalMessages) * 100) : 0 %>%</td>
                            <td><span class="sentiment-badge sentiment-negative"><%= SentimentAnalyzer.getSentimentEmoji("NEGATIVE") %> Negative</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <script>
        // Get the group ID from the URL parameter
        const groupIdParam = '<%= request.getParameter("group_id") %>';
        
        // Function to refresh sentiment data
        function refreshSentimentData() {
            const xhr = new XMLHttpRequest();
            xhr.open('GET', 'sentiment_data.jsp?group_id=' + groupIdParam, true);
            xhr.onload = function() {
                if (xhr.status === 200) {
                    try {
                        const data = JSON.parse(xhr.responseText);
                        updateSentimentStats(data.stats);
                        updateSentimentTrend(data.trend);
                        updateOverallSentiment(data.overall_sentiment);
                    } catch (e) {
                        console.error('Error parsing JSON:', e);
                    }
                }
            };
            xhr.send();
        }
        
        // Start auto-refresh when the page loads
        document.addEventListener('DOMContentLoaded', function() {
            // Initial refresh
            refreshSentimentData();
            
            // Set up auto-refresh every 10 seconds
            setInterval(refreshSentimentData, 10000);
        });
        
        function updateSentimentStats(stats) {
            // Update counts and percentages in stat cards
            updateStatCard('positive', stats.positive, stats.total);
            updateStatCard('neutral', stats.neutral, stats.total);
            updateStatCard('negative', stats.negative, stats.total);
            
            // Update progress bars
            updateProgressBars(stats.positive, stats.neutral, stats.negative, stats.total);
            
            // Update data table
            updateDataTable(stats.positive, stats.neutral, stats.negative, stats.total);
        }
        
        function updateSentimentTrend(trend) {
            const tbody = document.querySelector('.trend-table tbody');
            if (tbody && trend && trend.length > 0) {
                let html = '';
                
                trend.forEach(day => {
                    html += `
                        <tr>
                            <td>${day.date}</td>
                            <td class="sentiment-positive">${day.positive}</td>
                            <td class="sentiment-neutral">${day.neutral}</td>
                            <td class="sentiment-negative">${day.negative}</td>
                            <td>
                                <span class="sentiment-badge ${day.sentiment_class}">
                                    ${day.emoji} ${day.sentiment}
                                </span>
                            </td>
                        </tr>
                    `;
                });
                
                tbody.innerHTML = html;
            }
        }
        
        function updateOverallSentiment(overallSentiment) {
            const overallSentimentElement = document.querySelector('.overall-sentiment');
            if (overallSentimentElement && overallSentiment) {
                overallSentimentElement.innerHTML = `
                    <span class="sentiment-badge ${overallSentiment.sentiment_class}">
                        ${overallSentiment.emoji} ${overallSentiment.sentiment}
                    </span>
                `;
            }
        }
        
        function updateStatCard(type, count, total) {
            const statValue = document.querySelector(`.stat-card .stat-value.sentiment-${type}`);
            if (statValue) {
                let percentage = 0;
                if (total > 0) {
                    percentage = Math.round((count / total) * 100);
                }
                statValue.innerHTML = `${count} <small>(${percentage}%)</small>`;
            }
        }
        
        function updateProgressBars(positive, neutral, negative, total) {
            if (total > 0) {
                const positivePercent = Math.round((positive / total) * 100);
                const neutralPercent = Math.round((neutral / total) * 100);
                const negativePercent = Math.round((negative / total) * 100);
                
                const container = document.querySelector('.progress-container');
                if (container) {
                    let html = '<div style="display: flex; width: 100%;">';
                    
                    if (positivePercent > 0) {
                        html += `<div class="progress-bar progress-positive" style="width: ${positivePercent}%;">${positivePercent}%</div>`;
                    }
                    
                    if (neutralPercent > 0) {
                        html += `<div class="progress-bar progress-neutral" style="width: ${neutralPercent}%;">${neutralPercent}%</div>`;
                    }
                    
                    if (negativePercent > 0) {
                        html += `<div class="progress-bar progress-negative" style="width: ${negativePercent}%;">${negativePercent}%</div>`;
                    }
                    
                    html += '</div>';
                    container.innerHTML = html;
                }
            }
        }
        
        function updateDataTable(positive, neutral, negative, total) {
            const rows = document.querySelectorAll('.data-table tbody tr');
            if (rows.length >= 3) {
                // Update positive row
                updateDataTableRow(rows[0], positive, total);
                
                // Update neutral row
                updateDataTableRow(rows[1], neutral, total);
                
                // Update negative row
                updateDataTableRow(rows[2], negative, total);
            }
        }
        
        function updateDataTableRow(row, count, total) {
            const cells = row.querySelectorAll('td');
            if (cells.length >= 3) {
                cells[1].textContent = count;
                
                let percentage = 0;
                if (total > 0) {
                    percentage = Math.round((count / total) * 100);
                }
                cells[2].textContent = percentage + '%';
            }
        }
    </script>
</body>
</html> 