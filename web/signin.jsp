<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign In - Global Communication Network</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" />
    <link rel="stylesheet" href="assets/css/global.css">
</head>
<body>
    <div class="page-container">
        <h1 class="main-title">Global Communication Network</h1>
        
        <div class="form-container">
            <div class="form-card">
                <h2 class="form-title">Sign In</h2>
                <form action="signin.jsp" method="post">
                    <div class="input-group">
                        <label class="input-label" for="username">Username:</label>
                        <input type="text" id="username" name="username" required class="input-field" />
                    </div>
                    
                    <div class="input-group">
                        <label class="input-label" for="password">Password:</label>
                        <input type="password" id="password" name="password" required class="input-field" />
                    </div>
                    
                    <button type="submit" class="primary-button">Sign In</button>
                </form>

                <% 
                if (request.getMethod().equalsIgnoreCase("POST")) {
                    String username = request.getParameter("username");
                    String password = request.getParameter("password");
                    try {
                        Class.forName("org.postgresql.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                        String query = "SELECT * FROM users WHERE username = ? AND password = ?";
                        PreparedStatement stmt = conn.prepareStatement(query);
                        stmt.setString(1, username);
                        stmt.setString(2, password);
                        ResultSet rs = stmt.executeQuery();
                        if (rs.next()) {
                            session.setAttribute("username", rs.getString("username"));
                            response.sendRedirect("dashboard.jsp");
                        } else {
                            out.println("<p class='error-message'>Invalid username or password.</p>");
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                    }
                }
                %>

                <div class="social-section">
                    <h3 class="social-title">Sign in with:</h3>
                    <div class="social-icons">
                        <a href="#" class="social-icon" title="Sign in with Google">
                            <i class="fab fa-google fa-2x"></i>
                        </a>
                        <a href="#" class="social-icon" title="Sign in with Discord">
                            <i class="fab fa-discord fa-2x"></i>
                        </a>
                        <a href="#" class="social-icon" title="Sign in with Facebook">
                            <i class="fab fa-facebook-f fa-2x"></i>
                        </a>
                    </div>
                </div>

                <div class="social-section">
                    <p>New user? <a href="register.jsp" class="text-link">Register here</a></p>
                </div>

                <!-- Optional: Add "Forgot Password" link -->
                <div class="social-section">
                    <a href="forgot-password.jsp" class="text-link">Forgot Password?</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>