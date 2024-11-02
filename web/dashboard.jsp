<%@ page session="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Global Communication Network - Dashboard</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css" />
    <link rel="stylesheet" href="assets/css/global.css">
    <style>
        /* Additional dashboard-specific styles */
        .dashboard-stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-bottom: 2rem;
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.9);
            padding: 1rem;
            border-radius: 0.5rem;
            text-align: center;
        }

        .stat-card i {
            font-size: 1.5rem;
            color: #8b5cf6;
            margin-bottom: 0.5rem;
        }

        .module-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1.5rem;
            margin-top: 2rem;
        }

        .module-card {
            background: white;
            border-radius: 0.5rem;
            padding: 1.5rem;
            transition: transform 0.2s, box-shadow 0.2s;
        }

        .module-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }

        .module-title {
            font-size: 1.25rem;
            color: #1f2937;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .module-description {
            color: #6b7280;
            margin-bottom: 1rem;
            font-size: 0.9rem;
        }

        .module-link {
            display: inline-block;
            width: 100%;
            padding: 0.75rem 1rem;
            background-color: #8b5cf6;
            color: white;
            text-align: center;
            border-radius: 0.375rem;
            text-decoration: none;
            transition: background-color 0.2s;
        }

        .module-link:hover {
            background-color: #7c3aed;
        }

        .welcome-section {
            background: rgba(255, 255, 255, 0.9);
            padding: 2rem;
            border-radius: 0.5rem;
            margin-bottom: 2rem;
        }

        .last-activity {
            background: rgba(255, 255, 255, 0.9);
            padding: 1rem;
            border-radius: 0.5rem;
            margin-top: 2rem;
        }

        .activity-time {
            color: #6b7280;
            font-size: 0.875rem;
        }
        .logout-button {
        position: absolute;
        top: 20px;
        right: 20px;
        background-color: #e3342f;
        color: white;
        border: none;
        padding: 0.5rem 1rem;
        border-radius: 0.375rem;
        cursor: pointer;
        transition: background-color 0.2s;
        z-index: 1000; /* Ensure it is on top of other elements */
    }

    .logout-button:hover {
        background-color: #cc1f3f;
    }
    </style>
</head>
<body>
    <button class="logout-button" onclick="window.location.href='logout.jsp'">Logout</button>
    <div class="page-container">
        <div class="form-container" style="margin-top: 0;">
            <div class="form-card" style="max-width: 1200px;">
                <div class="welcome-section">
                    <h1 class="form-title" style="font-size: 2rem;">
                        Welcome back, <%= session.getAttribute("username") %>!
                    </h1>
                    <p style="color: #6b7280;">Access and manage your communication tools from your personalized dashboard.</p>
                </div>

                <div class="dashboard-stats">
                    <div class="stat-card">
                        <i class="fas fa-clock"></i>
                        <div>Last Login</div>
                        <div class="activity-time">
                            <%= new java.text.SimpleDateFormat("MMM d, yyyy h:mm a").format(new java.util.Date()) %>
                        </div>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-user-friends"></i>
                        <div>Account Status</div>
                        <div class="activity-time">Active</div>
                    </div>
                    <div class="stat-card">
                        <i class="fas fa-shield-alt"></i>
                        <div>Security Status</div>
                        <div class="activity-time">Protected</div>
                    </div>
                </div>

                <h2 class="form-title">Your Communication Hub</h2>
                
                <div class="module-grid">
                    <div class="module-card">
                        <div class="module-title">
                            <i class="fas fa-search"></i>
                            Search and Message
                        </div>
                        <p class="module-description">
                            Find and connect with other users on the network. Send direct messages and start conversations.
                        </p>
                        <a href="search_user.jsp" class="module-link">Access Search</a>
                    </div>

                    <div class="module-card">
                        <div class="module-title">
                            <i class="fas fa-user-edit"></i>
                            Profile Customization
                        </div>
                        <p class="module-description">
                            Personalize your profile, update information, and manage your account settings.
                        </p>
                        <a href="profile_customization.jsp" class="module-link">Customize Profile</a>
                    </div>

                    <div class="module-card">
                        <div class="module-title">
                            <i class="fas fa-users-cog"></i>
                            Group Management
                        </div>
                        <p class="module-description">
                            Create, join, and manage your groups. Control memberships and group settings.
                        </p>
                        <a href="group_management.jsp" class="module-link">Manage Groups</a>
                    </div>

                    <div class="module-card">
                        <div class="module-title">
                            <i class="fas fa-comments"></i>
                            Group Chat
                        </div>
                        <p class="module-description">
                            Participate in group discussions, share ideas, and collaborate with team members.
                        </p>
                        <a href="group_chat.jsp" class="module-link">Enter Chat</a>
                    </div>
                </div>

                <div class="last-activity">
                    <p style="color: #4b5563; text-align: center;">
                        <i class="fas fa-info-circle"></i>
                        All your activities are end-to-end encrypted and secure. For support, contact our help desk.
                    </p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>