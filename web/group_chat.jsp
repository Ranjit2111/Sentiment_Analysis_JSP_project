<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Group Chat | Your Communities</title>
    <link rel="stylesheet" href="assets/css/global.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .group-card {
            background: white;
            border-radius: 0.5rem;
            padding: 1.5rem;
            margin-bottom: 1rem;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .group-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .group-header {
            display: flex;
            align-items: center;
            margin-bottom: 1rem;
        }

        .group-icon {
            width: 48px;
            height: 48px;
            background: #8b5cf6;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin-right: 1rem;
            color: white;
            font-size: 1.5rem;
        }

        .group-info {
            flex-grow: 1;
        }

        .group-name {
            font-size: 1.25rem;
            font-weight: 600;
            color: #1f2937;
            margin-bottom: 0.25rem;
        }

        .group-meta {
            color: #6b7280;
            font-size: 0.875rem;
        }

        .action-buttons {
            display: flex;
            gap: 0.5rem;
        }

        .status-indicator {
            width: 8px;
            height: 8px;
            background-color: #10B981;
            border-radius: 50%;
            display: inline-block;
            margin-right: 0.5rem;
        }

        .groups-container {
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
        }

        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
        }

        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: white;
            padding: 1rem;
            border-radius: 0.5rem;
            text-align: center;
        }

        .stat-value {
            font-size: 1.5rem;
            font-weight: bold;
            color: #8b5cf6;
        }

        .stat-label {
            color: #6b7280;
            font-size: 0.875rem;
        }
    </style>
</head>
<body>
    <%
        // Get the current user from session at the start
        String currentUser = (String) session.getAttribute("username");
        if (currentUser == null) {
            response.sendRedirect("login.jsp");
            return;
        }
    %>
    <div class="page-container">
        <form action="dashboard.jsp" method="get" style="padding: 1rem;">
            <button type="submit" class="primary-button" style="max-width: 200px;">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </button>
        </form>

        <h1 class="main-title">Your Group Chats</h1>

        <div class="groups-container">
            <div class="section-header">
                <div>
                    <p style="color: #6b7280; margin-bottom: 1rem;">
                        Connect and collaborate with your communities in real-time
                    </p>
                </div>
            </div>

            <div class="stats-container">
                <%
                    try {
                        Class.forName("org.postgresql.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                        
                        // Count total groups
                        String countQuery = "SELECT COUNT(*) FROM group_members WHERE username = ?";
                        PreparedStatement countStmt = conn.prepareStatement(countQuery);
                        countStmt.setString(1, currentUser);
                        ResultSet countRs = countStmt.executeQuery();
                        int totalGroups = 0;
                        if (countRs.next()) {
                            totalGroups = countRs.getInt(1);
                        }
                %>
                <div class="stat-card">
                    <div class="stat-value"><%= totalGroups %></div>
                    <div class="stat-label">Active Groups</div>
                </div>
                <%
                        countStmt.close();
                        conn.close();
                    } catch (Exception e) {
                        out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                    }
                %>
            </div>

            <div class="groups-list">
                <%
                    try {
                        Class.forName("org.postgresql.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                        
                        String query = "SELECT gm.group_id, g.group_name FROM group_members gm JOIN groups g ON gm.group_id = g.group_id WHERE gm.username = ?";
                        PreparedStatement stmt = conn.prepareStatement(query);
                        stmt.setString(1, currentUser);
                        ResultSet rs = stmt.executeQuery();

                        while (rs.next()) {
                            int groupId = rs.getInt("group_id");
                            String groupName = rs.getString("group_name");
                %>
                            <div class="group-card">
                                <div class="group-header">
                                    <div class="group-icon">
                                        <i class="fas fa-users"></i>
                                    </div>
                                    <div class="group-info">
                                        <div class="group-name">
                                            <span class="status-indicator"></span>
                                            <%= groupName %>
                                        </div>
                                        <div class="group-meta">
                                            <i class="fas fa-circle" style="font-size: 0.5rem; vertical-align: middle;"></i>
                                            Active now
                                        </div>
                                    </div>
                                    <div class="action-buttons">
                                        <form action="chat.jsp" method="post">
                                            <input type="hidden" name="group_id" value="<%= groupId %>">
                                            <button type="submit" class="primary-button">
                                                <i class="fas fa-comments"></i> Open Chat
                                            </button>
                                        </form>
                                    </div>
                                </div>
                            </div>
                <%
                        }
                        stmt.close();
                        conn.close();
                    } catch (Exception e) {
                        out.println("<div class='error-message'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</div>");
                    }
                %>
            </div>

            <% if (request.getAttribute("error") != null) { %>
                <div class="error-message">
                    <i class="fas fa-exclamation-circle"></i>
                    <%= request.getAttribute("error") %>
                </div>
            <% } %>

            <div style="margin-top: 2rem; text-align: center; color: #6b7280; padding: 2rem;">
                <i class="fas fa-shield-alt"></i>
                <p style="margin-top: 0.5rem; font-size: 0.875rem;">
                    All messages are end-to-end encrypted and securely stored
                </p>
            </div>
        </div>
    </div>
</body>
</html>