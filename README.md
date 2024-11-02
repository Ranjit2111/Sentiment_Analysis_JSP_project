# User Management and Group Chat- JSP and PostgreSQL Project

## Overview
This project is a web-based communication platform built using Java Server Pages (JSP), JDBC for database connectivity, and PostgreSQL as the backend database. It allows users to sign in, manage their profiles, create and join groups, and participate in group chats. The application is designed to facilitate communication and enhance user engagement through an interactive dashboard.

## Features
- **User Authentication**: Secure sign-in page for user authentication.
- **User Dashboard**: An interactive dashboard where users can access features such as user search, profile customization, group management, and group chat.
- **Group Management**: Users can create, manage, and join groups, add members, and control group memberships.
- **Group Chat**: Real-time messaging feature that logs messages, timestamps, and user interactions.

## Technologies Used
- **Java Server Pages (JSP)**
- **JDBC (Java Database Connectivity)**
- **PostgreSQL** (for Backend)
- **HTML/CSS** for frontend styling

## Important Files
- **`register.jsp`**: The landing page of the application that provides access to the user registration page.
- **`registered.jsp`**: Used for registration confirmation.
- **`signin.jsp`**: Handles user authentication. It connects to the PostgreSQL database to validate user credentials.
- **`dashboard.jsp`**: The main interface after a successful login. Users can navigate to various features like user search and group management.
- **`search_user.jsp`**: Allows users to search for other users within the network.
- **`chat.jsp`**: Allows users to smessage the users previously searched up.
- **`profile_customization.jsp`**: Users can update their personal information and preferences.
- **`group_management.jsp`**: Enables users to create and manage groups. Users can view their groups, add members, and delete groups. Displays a list of groups the user is a member of and allows access to chat history.
- **`group_chat.jsp`**: Shows the message history for a selected group, allowing users to send new messages while viewing past conversations.
- **`logout.jsp`**: Used for logging out the current user from the dashboard.


## PostgreSQL code for table creation:
Set up a PostgreSQL database and import the necessary schemas and data. Feel free to use the code I give below 

**`CREATE TABLE users (
    username VARCHAR(50) PRIMARY KEY,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15) NOT NULL,
    password VARCHAR(50) NOT NULL,
    gender VARCHAR(10) NOT NULL,
    dob DATE NOT NULL
);`**

**`ALTER TABLE users
ADD COLUMN bio TEXT,
ADD COLUMN country VARCHAR(50);`**


**`CREATE TABLE messages (
    id SERIAL PRIMARY KEY,
    sender VARCHAR(50) REFERENCES users(username),
    receiver VARCHAR(50) REFERENCES users(username),
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);`**


**`CREATE TABLE groups (
    group_id SERIAL PRIMARY KEY,
    group_name VARCHAR(50) NOT NULL,
    created_by VARCHAR(50) REFERENCES users(username),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);`**


**`CREATE TABLE group_members (
    group_id INT REFERENCES groups(group_id),
    username VARCHAR(50) REFERENCES users(username),
    PRIMARY KEY (group_id, username)
);`**


**`CREATE TABLE group_messages (
    message_id SERIAL PRIMARY KEY,
    group_id INT REFERENCES groups(group_id),
    sender VARCHAR(50) REFERENCES users(username),
    message TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);`**

## Next steps:
- Configure the database connection settings in your JDBC setup.
- Deploy the JSP files on a Java servlet container such as Apache Tomcat.
- Access the application via your web browser.

## Contributing
Feel free to contribute to this project by forking the repository and submitting a pull request. Your feedback and suggestions are welcome!

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Installation
To run this project locally, follow these steps:
1. Clone the repository:
   ```bash
   git clone https://github.com/Ranjit2111/JSP_PostgreSQL_project.git
