<%@ page import="java.sql.*, java.util.*" %>
<%@ page session="true" %>
<!DOCTYPE html>
<html>
<head>
    <title>Group Management</title>
    <link rel="stylesheet" href="assets/css/global.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <% 
        String memberStatus = ""; // Variable to hold member addition status
        String deleteStatus = ""; // Variable to hold group deletion status

        // Handle group creation
        if (request.getParameter("create_group") != null) {
            String groupName = request.getParameter("groupName");
            String currentUser = (String) session.getAttribute("username");

            try {
                Class.forName("org.postgresql.Driver");
                Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                
                String query = "INSERT INTO groups (group_name, created_by) VALUES (?, ?)";
                PreparedStatement stmt = conn.prepareStatement(query);
                stmt.setString(1, groupName);
                stmt.setString(2, currentUser);

                int rowsInserted = stmt.executeUpdate();
                if (rowsInserted > 0) {
                    // Get the generated group ID
                    String groupIdQuery = "SELECT group_id FROM groups WHERE group_name = ? AND created_by = ?";
                    PreparedStatement groupIdStmt = conn.prepareStatement(groupIdQuery);
                    groupIdStmt.setString(1, groupName);
                    groupIdStmt.setString(2, currentUser);
                    ResultSet groupIdRs = groupIdStmt.executeQuery();

                    if (groupIdRs.next()) {
                        int groupId = groupIdRs.getInt("group_id");
                        // Add the creator as a member of the group
                        String addMemberQuery = "INSERT INTO group_members (group_id, username) VALUES (?, ?)";
                        PreparedStatement addMemberStmt = conn.prepareStatement(addMemberQuery);
                        addMemberStmt.setInt(1, groupId);
                        addMemberStmt.setString(2, currentUser);
                        addMemberStmt.executeUpdate();
                        addMemberStmt.close();
                    }
                    out.println("<p class='success'>Group '" + groupName + "' created successfully, and you are now a member.</p>");
                }
                stmt.close();
                conn.close();
            } catch (Exception e) {
                out.println("<p class='error'>Error creating group: " + e.getMessage() + "</p>");
            }
        }

        // Handle adding members to groups
        if (request.getParameter("add_member") != null) {
            int groupId = Integer.parseInt(request.getParameter("group_id"));
            String memberUsername = request.getParameter("memberUsername");

            try {
                Class.forName("org.postgresql.Driver");
                Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");

                // Check if the username exists in the users table before adding
                String userCheckQuery = "SELECT username FROM users WHERE username = ?";
                PreparedStatement userCheckStmt = conn.prepareStatement(userCheckQuery);
                userCheckStmt.setString(1, memberUsername);
                ResultSet userCheckRs = userCheckStmt.executeQuery();

                if (!userCheckRs.next()) {
                    memberStatus = "Error: User '" + memberUsername + "' does not exist.";
                } else {
                    String addMemberQuery = "INSERT INTO group_members (group_id, username) VALUES (?, ?)";
                    PreparedStatement addStmt = conn.prepareStatement(addMemberQuery);
                    addStmt.setInt(1, groupId);
                    addStmt.setString(2, memberUsername);

                    int memberAdded = addStmt.executeUpdate();
                    if (memberAdded > 0) {
                        memberStatus = "Member '" + memberUsername + "' added successfully to the group.";
                    } else {
                        memberStatus = "Failed to add member.";
                    }
                    addStmt.close();
                }
                userCheckStmt.close();
                conn.close();
            } catch (Exception e) {
                memberStatus = "Error adding member: " + e.getMessage();
            }
        }

        // Handle group deletion
        if (request.getParameter("delete_group") != null) {
            int groupId = Integer.parseInt(request.getParameter("group_id"));

            try {
                Class.forName("org.postgresql.Driver");
                Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");

                String deleteQuery = "DELETE FROM groups WHERE group_id = ?";
                PreparedStatement deleteStmt = conn.prepareStatement(deleteQuery);
                deleteStmt.setInt(1, groupId);

                int rowsDeleted = deleteStmt.executeUpdate();
                if (rowsDeleted > 0) {
                    deleteStatus = "Group deleted successfully.";
                } else {
                    deleteStatus = "Failed to delete group.";
                }
                deleteStmt.close();
                conn.close();
            } catch (Exception e) {
                deleteStatus = "Error deleting group: " + e.getMessage();
            }
        }
    %>

    <div class="page-container">
        <h1 class="main-title">Group Management</h1>
        
        <div class="form-container">
            <div class="form-card" style="max-width: 800px;">
                <!-- Dashboard Navigation -->
                <div style="margin-bottom: 2rem; text-align: right;">
                    <form action="dashboard.jsp" method="get" style="display: inline;">
                        <button type="submit" class="primary-button" style="width: auto;">
                            <i class="fas fa-arrow-left"></i> Back to Dashboard
                        </button>
                    </form>
                </div>

                <!-- Create Group Section -->
                <div class="input-group" style="background: rgba(139, 92, 246, 0.1); padding: 1.5rem; border-radius: 0.5rem; margin-bottom: 2rem;">
                    <h2 class="form-title" style="margin-bottom: 1rem;">Create New Group</h2>
                    <p style="color: #6b7280; margin-bottom: 1rem;">Create a new group to collaborate with other users. As the group creator, you'll automatically become a member.</p>
                    
                    <form action="group_management.jsp" method="post" style="display: flex; gap: 1rem;">
                        <div style="flex-grow: 1;">
                            <input type="text" id="groupName" name="groupName" required 
                                   class="input-field" placeholder="Enter group name">
                        </div>
                        <button type="submit" name="create_group" class="primary-button" style="width: auto;">
                            <i class="fas fa-plus"></i> Create Group
                        </button>
                    </form>
                </div>

                <!-- Status Messages -->
                <% if (!memberStatus.isEmpty() || !deleteStatus.isEmpty()) { %>
                    <div class="input-group" style="background: #f3f4f6; padding: 1rem; border-radius: 0.5rem; margin-bottom: 2rem;">
                        <% if (!memberStatus.isEmpty()) { %>
                            <p class="<%= memberStatus.contains("Error") ? "error-message" : "text-link" %>">
                                <i class="<%= memberStatus.contains("Error") ? "fas fa-exclamation-circle" : "fas fa-check-circle" %>"></i>
                                <%= memberStatus %>
                            </p>
                        <% } %>
                        <% if (!deleteStatus.isEmpty()) { %>
                            <p class="<%= deleteStatus.contains("Error") ? "error-message" : "text-link" %>">
                                <i class="<%= deleteStatus.contains("Error") ? "fas fa-exclamation-circle" : "fas fa-check-circle" %>"></i>
                                <%= deleteStatus %>
                            </p>
                        <% } %>
                    </div>
                <% } %>

                <!-- Groups List -->
                <div class="input-group">
                    <h2 class="form-title">Your Groups</h2>
                    <p style="color: #6b7280; margin-bottom: 1.5rem;">Manage your created groups and their members below.</p>

                    <div style="display: grid; gap: 1.5rem;">
                        <%
                        String currentUser = (String) session.getAttribute("username");
                        boolean hasGroups = false;

                        try {
                            Class.forName("org.postgresql.Driver");
                            Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
                            
                            String query = "SELECT group_id, group_name, created_by, created_at FROM groups WHERE created_by = ?";
                            PreparedStatement stmt = conn.prepareStatement(query);
                            stmt.setString(1, currentUser);
                            ResultSet rs = stmt.executeQuery();

                            while (rs.next()) {
                                hasGroups = true;
                                int groupId = rs.getInt("group_id");
                                String gName = rs.getString("group_name");
                                String createdBy = rs.getString("created_by");
                                Timestamp createdAt = rs.getTimestamp("created_at");
                        %>
                                <div style="background: white; border: 1px solid #e5e7eb; border-radius: 0.5rem; padding: 1.5rem; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);">
                                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
                                        <h3 style="font-size: 1.25rem; font-weight: bold; color: #1f2937;">
                                            <i class="fas fa-users"></i> <%= gName %>
                                        </h3>
                                        <span style="color: #6b7280; font-size: 0.875rem;">
                                            <i class="fas fa-calendar"></i> <%= createdAt %>
                                        </span>
                                    </div>

                                    <div style="color: #4b5563; margin-bottom: 1rem;">
                                        <p><i class="fas fa-user"></i> Created by: <%= createdBy %></p>
                                        
                                        <!-- Members List -->
                                        <div style="margin-top: 0.5rem;">
                                            <p><i class="fas fa-user-friends"></i> Members:</p>
                                            <%
                                            String memberQuery = "SELECT username FROM group_members WHERE group_id = ?";
                                            PreparedStatement memberStmt = conn.prepareStatement(memberQuery);
                                            memberStmt.setInt(1, groupId);
                                            ResultSet memberRs = memberStmt.executeQuery();

                                            List<String> members = new ArrayList<>();
                                            while (memberRs.next()) {
                                                members.add(memberRs.getString("username"));
                                            }
                                            %>
                                            <p style="color: #6b7280; margin-left: 1rem;">
                                                <%= members.isEmpty() ? "No members added." : String.join(", ", members) %>
                                            </p>
                                        </div>
                                    </div>

                                    <!-- Group Actions -->
                                    <div style="display: flex; gap: 1rem; flex-wrap: wrap;">
                                        <form action="group_management.jsp" method="post" style="flex-grow: 1;">
                                            <input type="hidden" name="group_id" value="<%= groupId %>">
                                            <div style="display: flex; gap: 0.5rem;">
                                                <input type="text" name="memberUsername" placeholder="Enter username to add" 
                                                       required class="input-field" style="flex-grow: 1;">
                                                <button type="submit" name="add_member" class="primary-button" style="width: auto;">
                                                    <i class="fas fa-user-plus"></i> Add
                                                </button>
                                            </div>
                                        </form>
                                        
                                        <form action="group_management.jsp" method="post">
                                            <input type="hidden" name="group_id" value="<%= groupId %>">
                                            <button type="submit" name="delete_group" 
                                                    onclick="return confirm('Are you sure you want to delete this group?');"
                                                    class="primary-button" style="background-color: #ef4444;">
                                                <i class="fas fa-trash"></i> Delete
                                            </button>
                                        </form>
                                    </div>
                                </div>
                        <%
                            }
                            stmt.close();
                            conn.close();
                            
                            if (!hasGroups) {
                        %>
                                <div style="text-align: center; padding: 3rem; background: #f3f4f6; border-radius: 0.5rem;">
                                    <i class="fas fa-users" style="font-size: 3rem; color: #6b7280; margin-bottom: 1rem;"></i>
                                    <h3 style="color: #374151; margin-bottom: 0.5rem;">No Groups Yet</h3>
                                    <p style="color: #6b7280;">Create your first group to start collaborating with others!</p>
                                </div>
                        <%
                            }
                        } catch (Exception e) {
                        %>
                            <p class="error-message">
                                <i class="fas fa-exclamation-circle"></i>
                                Error fetching groups: <%= e.getMessage() %>
                            </p>
                        <%
                        }
                        %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>