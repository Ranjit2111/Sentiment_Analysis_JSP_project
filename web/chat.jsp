<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Group Chat | Real-time Conversation</title>
    <link rel="stylesheet" href="assets/css/global.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        .chat-container {
            height: 70vh;
            background: white;
            border-radius: 0.5rem;
            display: flex;
            flex-direction: column;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }

        .chat-header {
            padding: 1rem;
            border-bottom: 1px solid #e5e7eb;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .chat-messages {
            flex-grow: 1;
            overflow-y: auto;
            padding: 1rem;
            background: #f9fafb;
        }

        .message {
            margin: 1rem 0;
            padding: 0.75rem;
            background: white;
            border-radius: 0.5rem;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
        }

        .message-header {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.5rem;
        }

        .message-sender {
            color: #8b5cf6;
            font-weight: 600;
        }

        .message-time {
            color: #6b7280;
            font-size: 0.875rem;
        }

        .message-content {
            color: #374151;
            line-height: 1.5;
        }

        .chat-input {
            padding: 1rem;
            border-top: 1px solid #e5e7eb;
            background: white;
        }

        .input-form {
            display: flex;
            gap: 1rem;
        }

        .message-textarea {
            flex-grow: 1;
            padding: 0.75rem;
            border: 1px solid #d1d5db;
            border-radius: 0.375rem;
            resize: none;
            height: 60px;
        }

        .online-indicator {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            color: #059669;
            font-size: 0.875rem;
        }

        .status-dot {
            height: 8px;
            width: 8px;
            background-color: #059669;
            border-radius: 50%;
        }
    </style>
</head>
<body>
    <div class="page-container">
        <form action="group_chat.jsp" method="get" style="padding: 1rem;">
            <button type="submit" class="primary-button" style="max-width: 200px;">
                <i class="fas fa-arrow-left"></i> Back to Groups
            </button>
        </form>

        <div class="form-container" style="margin-top: -2rem;">
            <div class="form-card" style="max-width: 800px;">
                <div class="chat-container">
                    <div class="chat-header">
                        <div>
                            <h2 class="form-title" style="margin-bottom: 0.5rem;">Group Chat #<%= request.getParameter("group_id") %></h2>
                            <div class="online-indicator">
                                <span class="status-dot"></span>
                                <span>Chat Active</span>
                            </div>
                        </div>
                        <div style="color: #6b7280;">
                            <i class="fas fa-users"></i> Active Members
                        </div>
                    </div>

                    <div class="chat-messages" id="chatMessages">
                        <%
                            try {
                                Class.forName("org.postgresql.Driver");
                                Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");

                                String chatQuery = "SELECT sender, message, timestamp FROM group_messages WHERE group_id = ? ORDER BY timestamp";
                                PreparedStatement chatStmt = conn.prepareStatement(chatQuery);
                                chatStmt.setInt(1, Integer.parseInt(request.getParameter("group_id")));
                                ResultSet chatRs = chatStmt.executeQuery();

                                while (chatRs.next()) {
                                    String sender = chatRs.getString("sender");
                                    String message = chatRs.getString("message");
                                    Timestamp timestamp = chatRs.getTimestamp("timestamp");
                        %>
                                    <div class="message">
                                        <div class="message-header">
                                            <span class="message-sender">
                                                <i class="fas fa-user-circle"></i> <%= sender %>
                                            </span>
                                            <span class="message-time">
                                                <i class="fas fa-clock"></i> <%= timestamp %>
                                            </span>
                                        </div>
                                        <div class="message-content"><%= message %></div>
                                    </div>
                        <%
                                }
                                chatStmt.close();
                                conn.close();
                            } catch (Exception e) {
                                out.println("<p class='error-message'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
                            }
                        %>
                    </div>

                    <div class="chat-input">
                        <form action="chat.jsp" method="post" class="input-form">
                            <input type="hidden" name="group_id" value="<%= request.getParameter("group_id") %>">
                            <textarea 
                                name="messageContent" 
                                class="message-textarea" 
                                placeholder="Type your message here..."
                                required
                            ></textarea>
                            <button type="submit" name="send_message" class="primary-button" style="width: auto; padding: 0 1.5rem;">
                                <i class="fas fa-paper-plane"></i>
                            </button>
                        </form>
                        <% 
                            String messageStatus = "";
                            if (request.getParameter("send_message") != null) {
                                String messageContent = request.getParameter("messageContent");
                                String currentUser = (String) session.getAttribute("username");
                                try {
                                    Class.forName("org.postgresql.Driver");
                                    Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");

                                    String insertMessageQuery = "INSERT INTO group_messages (group_id, sender, message) VALUES (?, ?, ?)";
                                    PreparedStatement insertStmt = conn.prepareStatement(insertMessageQuery);
                                    insertStmt.setInt(1, Integer.parseInt(request.getParameter("group_id")));
                                    insertStmt.setString(2, currentUser);
                                    insertStmt.setString(3, messageContent);

                                    int rowsInserted = insertStmt.executeUpdate();
                                    if (rowsInserted > 0) {
                                        messageStatus = "<div class='success-message' style='color: #10B981; text-align: center; margin-top: 0.5rem;'><i class='fas fa-check-circle'></i> Message sent!</div>";
                                    }
                                    insertStmt.close();
                                    conn.close();
                                } catch (Exception e) {
                                    messageStatus = "<div class='error-message'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</div>";
                                }
                            }
                        %>
                        <%= messageStatus %>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Auto-scroll to bottom of chat
        const chatMessages = document.getElementById('chatMessages');
        chatMessages.scrollTop = chatMessages.scrollHeight;
    </script>
</body>
</html>