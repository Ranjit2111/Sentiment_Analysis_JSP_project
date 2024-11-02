<%@ page import="java.sql.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Profile Customization | Your Account</title>
    <link rel="stylesheet" href="assets/css/global.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <div class="page-container">
        <form action="dashboard.jsp" method="get" style="padding: 1rem;">
            <button type="submit" class="primary-button" style="max-width: 200px;">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </button>
        </form>

        <h1 class="main-title">Customize Your Profile</h1>

        <div class="form-container">
            <div class="form-card">
                <h2 class="form-title">Personal Information</h2>
                <p style="color: #6b7280; margin-bottom: 2rem;">
                    Keep your profile information up to date to help us serve you better and ensure secure communication.
                </p>

                <form action="profile_customization.jsp" method="post">
                    <div class="input-group">
                        <label for="phone" class="input-label">
                            <i class="fas fa-phone"></i> Phone Number
                        </label>
                        <input type="tel" id="phone" name="contact" class="input-field" required 
                               placeholder="Enter your phone number">
                        <small style="color: #6b7280;">We'll use this number for account security</small>
                    </div>

                    <div class="input-group">
                        <label for="email" class="input-label">
                            <i class="fas fa-envelope"></i> Email Address
                        </label>
                        <input type="email" id="email" name="email" class="input-field" required
                               placeholder="Enter your email address">
                        <small style="color: #6b7280;">Primary email for notifications and updates</small>
                    </div>

                    <div class="input-group">
                        <label for="bio" class="input-label">
                            <i class="fas fa-user"></i> About Me
                        </label>
                        <textarea id="bio" name="bio" rows="4" class="input-field" 
                                placeholder="Tell us a bit about yourself..."></textarea>
                        <small style="color: #6b7280;">Share a brief introduction about yourself</small>
                    </div>

                    <div class="input-group">
                        <label for="dob" class="input-label">
                            <i class="fas fa-calendar"></i> Date of Birth
                        </label>
                        <input type="date" id="dob" name="dob" class="input-field" required>
                        <small style="color: #6b7280;">Required for age verification</small>
                    </div>

                    <div class="input-group">
                        <label for="country" class="input-label">
                            <i class="fas fa-globe"></i> Country
                        </label>
                        <input type="text" id="country" name="country" class="input-field" required
                               placeholder="Enter your country">
                        <small style="color: #6b7280;">Your nationality</small>
                    </div>

                    <div style="margin-top: 2rem;">
                        <button type="submit" name="update_profile" class="primary-button">
                            <i class="fas fa-save"></i> Save Changes
                        </button>
                    </div>
                </form>

                <% 
                if (request.getParameter("update_profile") != null) {
                    String contact = request.getParameter("contact");
                    String email = request.getParameter("email");
                    String bio = request.getParameter("bio");
                    String dob = request.getParameter("dob");
                    String country = request.getParameter("country");
                    String currentUser = (String) session.getAttribute("username");
                    try {
                        Class.forName("org.postgresql.Driver");
                        Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                        String query = "UPDATE users SET phone = ?, email = ?, bio = ?, dob = ?, country = ? WHERE username = ?";
                        PreparedStatement stmt = conn.prepareStatement(query);
                        stmt.setString(1, contact);
                        stmt.setString(2, email);
                        stmt.setString(3, bio);
                        stmt.setDate(4, java.sql.Date.valueOf(dob));
                        stmt.setString(5, country);
                        stmt.setString(6, currentUser);
                        int rowsUpdated = stmt.executeUpdate();
                        if (rowsUpdated > 0) {
                            out.println("<div class='success-message' style='color: #10B981; text-align: center; margin-top: 1rem; padding: 1rem; background-color: #D1FAE5; border-radius: 0.375rem;'>");
                            out.println("<i class='fas fa-check-circle'></i> Profile updated successfully!");
                            out.println("</div>");
                        }
                        conn.close();
                    } catch (Exception e) {
                        out.println("<div class='error-message'>");
                        out.println("<i class='fas fa-exclamation-circle'></i> Error: " + e.getMessage());
                        out.println("</div>");
                    }
                }
                %>

                <div style="margin-top: 2rem; padding-top: 2rem; border-top: 1px solid #E5E7EB;">
                    <p style="color: #6b7280; text-align: center; font-size: 0.875rem;">
                        <i class="fas fa-shield-alt"></i> Your information is securely stored and protected
                    </p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>