<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Sentiment Analytics | Group Chat</title>
    <link rel="stylesheet" href="assets/css/global.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
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
        
        // Variables for chart data
        ArrayList<String> chartLabels = new ArrayList<>();
        ArrayList<Integer> positiveData = new ArrayList<>();
        ArrayList<Integer> neutralData = new ArrayList<>();
        ArrayList<Integer> negativeData = new ArrayList<>();
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
                        chartLabels.add("'" + trendRs.getDate("day_date") + "'");
                        positiveData.add(trendRs.getInt("positive_count"));
                        neutralData.add(trendRs.getInt("neutral_count"));
                        negativeData.add(trendRs.getInt("negative_count"));
                    }
                    trendStmt.close();
                    
                    conn.close();
                } catch (Exception e) {
                    out.println("<p class='error-message'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
                }
            %>
            
            <div class="chart-header" style="margin-bottom: 2rem;">
                <h2 class="chart-title"><%= groupName %> - Sentiment Analysis</h2>
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
                        <i class="fas fa-smile"></i> 😊
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
                        <i class="fas fa-meh"></i> 😐
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
                        <i class="fas fa-frown"></i> 😔
                    </div>
                </div>
            </div>
            
            <div class="chart-container">
                <div class="chart-header">
                    <h2 class="chart-title">Sentiment Trends (Last 7 Days)</h2>
                </div>
                <canvas id="sentimentChart"></canvas>
            </div>
            
            <div class="chart-container">
                <div class="chart-header">
                    <h2 class="chart-title">Overall Sentiment Distribution</h2>
                </div>
                <canvas id="sentimentPie"></canvas>
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
                            <td><span class="sentiment-badge sentiment-positive">😊 Positive</span></td>
                        </tr>
                        <tr>
                            <td>Neutral Messages</td>
                            <td><%= neutralCount %></td>
                            <td><%= totalMessages > 0 ? Math.round((neutralCount / (double)totalMessages) * 100) : 0 %>%</td>
                            <td><span class="sentiment-badge sentiment-neutral">😐 Neutral</span></td>
                        </tr>
                        <tr>
                            <td>Negative Messages</td>
                            <td><%= negativeCount %></td>
                            <td><%= totalMessages > 0 ? Math.round((negativeCount / (double)totalMessages) * 100) : 0 %>%</td>
                            <td><span class="sentiment-badge sentiment-negative">😔 Negative</span></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <script>
        // Sentiment trend chart
        const trendCtx = document.getElementById('sentimentChart').getContext('2d');
        const trendChart = new Chart(trendCtx, {
            type: 'line',
            data: {
                labels: [<%= String.join(",", chartLabels) %>],
                datasets: [
                    {
                        label: 'Positive',
                        data: [<%= positiveData.isEmpty() ? "" : String.join(",", positiveData.stream().map(Object::toString).toArray(String[]::new)) %>],
                        borderColor: '#10B981',
                        backgroundColor: 'rgba(16, 185, 129, 0.1)',
                        tension: 0.1
                    },
                    {
                        label: 'Neutral',
                        data: [<%= neutralData.isEmpty() ? "" : String.join(",", neutralData.stream().map(Object::toString).toArray(String[]::new)) %>],
                        borderColor: '#6B7280',
                        backgroundColor: 'rgba(107, 114, 128, 0.1)',
                        tension: 0.1
                    },
                    {
                        label: 'Negative',
                        data: [<%= negativeData.isEmpty() ? "" : String.join(",", negativeData.stream().map(Object::toString).toArray(String[]::new)) %>],
                        borderColor: '#EF4444',
                        backgroundColor: 'rgba(239, 68, 68, 0.1)',
                        tension: 0.1
                    }
                ]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    },
                    title: {
                        display: false
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        ticks: {
                            precision: 0
                        }
                    }
                }
            }
        });
        
        // Sentiment distribution pie chart
        const pieCtx = document.getElementById('sentimentPie').getContext('2d');
        const pieChart = new Chart(pieCtx, {
            type: 'doughnut',
            data: {
                labels: ['Positive', 'Neutral', 'Negative'],
                datasets: [{
                    data: [<%= positiveCount %>, <%= neutralCount %>, <%= negativeCount %>],
                    backgroundColor: [
                        '#10B981',
                        '#6B7280',
                        '#EF4444'
                    ],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                plugins: {
                    legend: {
                        position: 'top',
                    }
                }
            }
        });
    </script>
</body>
</html> 