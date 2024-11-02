<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search & Message Users - Global Communication Network</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" />
    <link rel="stylesheet" href="assets/css/global.css">
    <style>
        .search-container {
            text-align: center;
            max-width: 600px;
            margin: 0 auto;
        }
        
        .search-box {
            display: flex;
            gap: 0.5rem;
            margin-bottom: 2rem;
        }
        
        .message-box {
            width: 100%;
            min-height: 100px;
            resize: vertical;
        }
        
        .features-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.5rem;
            margin-top: 2rem;
        }
        
        .feature-card {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 1.5rem;
            border-radius: 0.5rem;
            text-align: left;
        }
        
        .back-button {
            position: absolute;
            top: 1rem;
            left: 1rem;
            padding: 0.5rem 1rem;
            background-color: white;
            border: 1px solid #8b5cf6;
            color: #8b5cf6;
            border-radius: 0.375rem;
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 0.5rem;
            transition: all 0.2s;
        }
        
        .back-button:hover {
            background-color: #8b5cf6;
            color: white;
        }
    </style>
</head>
<body>
    <div class="page-container">
        <form action="dashboard.jsp" method="get">
            <button type="submit" class="back-button">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </button>
        </form>

        <h1 class="main-title">Search & Connect</h1>
        
        <div class="form-container">
            <div class="form-card search-container">
                <div class="feature-card">
                    <h2 class="form-title">
                        <i class="fas fa-search"></i> Find Users
                    </h2>
                    <p class="mb-4">Search for other users in the Global Communication Network and send them messages instantly.</p>
                    
                    <form action="search_user.jsp" method="post" class="search-box">
                        <div class="input-group" style="flex-grow: 1; margin-bottom: 0;">
                            <input type="text" id="searchUsername" name="searchUsername" 
                                   required class="input-field" 
                                   placeholder="Enter username to search..."
                                   autocomplete="off">
                        </div>
                        <button type="submit" class="primary-button" style="width: auto;">
                            <i class="fas fa-search"></i> Search
                        </button>
                    </form>

                    <% 
                    String messageStatus = "";
                    if (request.getParameter("searchUsername") != null) {
                        String searchUsername = request.getParameter("searchUsername");
                        String currentUser = (String) session.getAttribute("username");

                        try {
                            Class.forName("org.postgresql.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                            String query = "SELECT username FROM users WHERE username = ?";
                            PreparedStatement stmt = conn.prepareStatement(query);
                            stmt.setString(1, searchUsername);
                            ResultSet rs = stmt.executeQuery();

                            if (rs.next()) {
                                %>
                                <div class="mt-4">
                                    <div class="feature-card" style="background-color: #f3f4f6;">
                                        <h3 class="text-lg font-medium mb-2">
                                            <i class="fas fa-user"></i> Found user: <%= searchUsername %>
                                        </h3>
                                        <form action="search_user.jsp" method="post">
                                            <input type="hidden" name="receiver" value="<%= searchUsername %>">
                                            <div class="input-group">
                                                <label for="messageContent" class="input-label">Write your message:</label>
                                                <textarea id="messageContent" name="messageContent" 
                                                        required class="input-field message-box"
                                                        placeholder="Type your message here..."></textarea>
                                            </div>
                                            <button type="submit" name="sendMessage" class="primary-button">
                                                <i class="fas fa-paper-plane"></i> Send Message
                                            </button>
                                        </form>
                                    </div>
                                </div>
                                <%
                            } else {
                                out.println("<p class='error-message mt-4'><i class='fas fa-exclamation-circle'></i> User not found.</p>");
                            }
                            conn.close();
                        } catch (Exception e) {
                            out.println("<p class='error-message mt-4'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>");
                        }
                    }

                    if (request.getParameter("sendMessage") != null) {
                        String receiver = request.getParameter("receiver");
                        String messageContent = request.getParameter("messageContent");
                        String sender = (String) session.getAttribute("username");

                        try {
                            Class.forName("org.postgresql.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                            
                            String insertQuery = "INSERT INTO messages (sender, receiver, message) VALUES (?, ?, ?)";
                            PreparedStatement insertStmt = conn.prepareStatement(insertQuery);
                            insertStmt.setString(1, sender);
                            insertStmt.setString(2, receiver);
                            insertStmt.setString(3, messageContent);

                            int rowsInserted = insertStmt.executeUpdate();
                            if (rowsInserted > 0) {
                                messageStatus = "<p class='success-message mt-4'><i class='fas fa-check-circle'></i> Message sent successfully to " + receiver + "!</p>";
                            } else {
                                messageStatus = "<p class='error-message mt-4'><i class='fas fa-times-circle'></i> Failed to send message.</p>";
                            }
                            insertStmt.close();
                            conn.close();
                        } catch (Exception e) {
                            messageStatus = "<p class='error-message mt-4'><i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage() + "</p>";
                        }
                        out.println(messageStatus);
                    }
                    %>
                </div>

                <div class="features-grid">
                    <div class="feature-card">
                        <h3 class="text-lg font-medium mb-2">
                            <i class="fas fa-bolt"></i> Quick Connect
                        </h3>
                        <p>Search for users instantly and start meaningful conversations with members of our global community.</p>
                    </div>
                    
                    <div class="feature-card">
                        <h3 class="text-lg font-medium mb-2">
                            <i class="fas fa-shield-alt"></i> Secure Messaging
                        </h3>
                        <p>Your messages are secure and private, ensuring confidential communication between users.</p>
                    </div>
                    
                    <div class="feature-card">
                        <h3 class="text-lg font-medium mb-2">
                            <i class="fas fa-globe"></i> Global Network
                        </h3>
                        <p>Connect with users from around the world and expand your professional network.</p>
                    </div>
                    
                    <div class="feature-card">
                        <h3 class="text-lg font-medium mb-2">
                            <i class="fas fa-comments"></i> Real-time Chat
                        </h3>
                        <p>Exchange messages instantly with other users in our growing community.</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>