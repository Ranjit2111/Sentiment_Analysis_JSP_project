<%@ page import="java.sql.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Global Communication Network Registration</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" />
    <link rel="stylesheet" href="assets/css/global.css">
</head>
<body>
    <div class="page-container">
        <h1 class="main-title">Global Communication Network</h1>
        
        <div class="form-container">
            <div class="form-card">
                <h2 class="form-title">Registration Form</h2>
                <form action="register.jsp" method="post">
                    <div class="input-group">
                        <label class="input-label" for="username">Username:</label>
                        <input type="text" id="username" name="username" required class="input-field" />
                    </div>
                    
                    <div class="input-group">
                        <label class="input-label" for="email">Email:</label>
                        <input type="email" id="email" name="email" required class="input-field" />
                    </div>
                    
                    <div class="input-group">
                        <label class="input-label" for="phone">Phone:</label>
                        <input type="text" id="phone" name="phone" required class="input-field" />
                    </div>
                    
                    <div class="input-group">
                        <label class="input-label" for="password">Password:</label>
                        <input type="password" id="password" name="password" required class="input-field" />
                    </div>
                    
                    <div class="input-group">
                        <label class="input-label">Gender:</label>
                        <div class="radio-group">
                            <label class="radio-label">
                                <input type="radio" id="male" name="gender" value="Male" required />
                                <span>Male</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" id="female" name="gender" value="Female" />
                                <span>Female</span>
                            </label>
                            <label class="radio-label">
                                <input type="radio" id="other" name="gender" value="Other" />
                                <span>Other</span>
                            </label>
                        </div>
                    </div>
                    
                    <div class="input-group">
                        <label class="input-label" for="dob">Date of Birth:</label>
                        <input type="date" id="dob" name="dob" required class="input-field" />
                    </div>
                    
                    <button type="submit" class="primary-button">Register</button>
                </form>

                <%
                if (request.getMethod().equalsIgnoreCase("POST")) {
                    String username = request.getParameter("username");
                    String email = request.getParameter("email");
                    String phone = request.getParameter("phone");
                    String password = request.getParameter("password");
                    String gender = request.getParameter("gender");
                    String dob = request.getParameter("dob");

                    try {
                        Class.forName("org.postgresql.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                        String query = "INSERT INTO users (username, email, phone, password, gender, dob) VALUES (?, ?, ?, ?, ?, ?)";
                        PreparedStatement stmt = conn.prepareStatement(query);

                        stmt.setString(1, username);
                        stmt.setString(2, email);
                        stmt.setString(3, phone);
                        stmt.setString(4, password);
                        stmt.setString(5, gender);
                        stmt.setDate(6, Date.valueOf(dob));

                        int rowsInserted = stmt.executeUpdate();
                        if (rowsInserted > 0) {
                            response.sendRedirect("registered.jsp");
                        }
                        conn.close();
                    } catch (SQLException e) {
                        if (e.getSQLState().equals("23505")) {
                            out.println("<p class='error-message'>Username already exists. Please choose a different username.</p>");
                        } else {
                            out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                        }
                    } catch (Exception e) {
                        out.println("<p class='error-message'>Error: " + e.getMessage() + "</p>");
                    }
                }
                %>

                <div class="social-section">
                    <h3 class="social-title">Sign up with:</h3>
                    <div class="social-icons">
                        <a href="#" class="social-icon">
                            <i class="fab fa-google fa-2x"></i>
                        </a>
                        <a href="#" class="social-icon">
                            <i class="fab fa-discord fa-2x"></i>
                        </a>
                        <a href="#" class="social-icon">
                            <i class="fab fa-facebook-f fa-2x"></i>
                        </a>
                    </div>
                </div>

                <div class="social-section">
                    <p>Already a user? <a href="signin.jsp" class="text-link">Login now</a></p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>