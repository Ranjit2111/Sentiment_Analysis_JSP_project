# Global Communication Network - Comprehensive Project Guide

## Project Overview

Global Communication Network is a sophisticated web-based communication platform built with Java Server Pages (JSP) and PostgreSQL. The application provides a secure and feature-rich environment for users to connect and communicate with each other through direct messaging and group conversations. One of the standout features is the implementation of sentiment analysis for messages, providing real-time feedback on the emotional tone of conversations.

## Table of Contents

- [Features and Services](#features-and-services)
- [Technical Architecture](#technical-architecture)
  - [Frontend Components](#frontend-components)
  - [Backend Components](#backend-components)
  - [Database Schema](#database-schema)
- [User Journey](#user-journey)
- [Feature Deep Dive](#feature-deep-dive)
  - [User Authentication](#user-authentication)
  - [Direct Messaging](#direct-messaging)
  - [Group Management](#group-management)
  - [Group Chat](#group-chat)
  - [Sentiment Analysis](#sentiment-analysis)
  - [Profile Customization](#profile-customization)
- [Component Connections](#component-connections)
- [Database Operations](#database-operations)
- [Project Structure](#project-structure)
- [Setup and Deployment](#setup-and-deployment)

## Features and Services

### Core Features

1. **User Authentication and Management**

   - Secure registration and sign-in system
   - Session management
   - Password protection
2. **Messaging System**

   - Direct user-to-user messaging
   - Real-time message exchange
   - Message history preservation
3. **Group Communication**

   - Creation and management of group conversations
   - Member management (add/remove)
   - Group-specific settings
4. **Sentiment Analysis**

   - Real-time analysis of message emotional tone
   - Visual indicators for message sentiment
   - Sentiment analytics dashboard
   - Historical sentiment data tracking
5. **Profile Customization**

   - User profile editing
   - Personal information management
   - Communication preferences
6. **User Search**

   - Find other users on the platform
   - Initiate conversations with new contacts

### Additional Services

1. **Analytics Dashboard**

   - Comprehensive sentiment analysis reports
   - Conversation trend visualization
   - Group interaction statistics
2. **Secure Communications**

   - Protected user data
   - Private messaging channels
   - Access controls for group conversations

## Technical Architecture

### Frontend Components

The frontend of the Global Communication Network is built using JSP (JavaServer Pages), HTML, CSS, and JavaScript, providing a responsive and interactive user interface.

#### Key Frontend Files:

1. **User Authentication**

   - `register.jsp`: User registration form
   - `signin.jsp`: User login form
   - `registered.jsp`: Registration confirmation
2. **Dashboard and Navigation**

   - `dashboard.jsp`: Main user dashboard after login
   - `index.html`: Entry point redirect
3. **Communication Interfaces**

   - `chat.jsp`: Direct messaging interface
   - `group_chat.jsp`: Group chat interface
   - `search_user.jsp`: User search functionality
4. **User Settings**

   - `profile_customization.jsp`: Profile editing interface
5. **Group Management**

   - `group_management.jsp`: Create and manage groups
6. **Sentiment Analysis**

   - `sentiment_analytics.jsp`: Sentiment visualization dashboard
   - `update_sentiment.jsp`: Processes sentiment updates
7. **Session Management**

   - `logout.jsp`: User logout functionality
8. **Assets**

   - CSS styles and images for the UI

### Backend Components

The backend is implemented using Java, with JSP handling the server-side logic and database interactions.

#### Key Backend Components:

1. **Sentiment Analysis Engine**

   - `SentimentAnalyzer.java`: Performs text analysis to determine sentiment
   - Contains dictionaries of positive and negative words with weights
   - Processes negation in language
   - Returns sentiment scores and categories (Positive, Neutral, Negative)
2. **Database Connectivity**

   - JDBC connections to PostgreSQL database
   - Connection pooling for performance
   - Prepared statements for secure queries
3. **Business Logic**

   - User authentication and verification
   - Message processing and delivery
   - Group management logic
   - Sentiment analysis integration

### Database Schema

The application uses PostgreSQL for data storage, with a well-structured schema designed for efficient communication data management.

#### Core Tables:

1. **users**

   - `username` (Primary Key): User's unique identifier
   - `password`: Securely stored user password
   - `email`: User's email address
   - `phone`: Optional phone number
   - `gender`: User's gender information
   - `registration_date`: Account creation timestamp
2. **messages**

   - `message_id` (Primary Key): Unique message identifier
   - `sender`: Username of message sender (FK to users)
   - `receiver`: Username of message recipient (FK to users)
   - `message`: Text content of the message
   - `timestamp`: When the message was sent
3. **groups**

   - `group_id` (Primary Key): Unique group identifier
   - `group_name`: Name of the group
   - `created_by`: Username of group creator (FK to users)
   - `created_at`: Group creation timestamp
4. **group_members**

   - `id` (Primary Key): Membership record identifier
   - `group_id`: Group identifier (FK to groups)
   - `username`: Member username (FK to users)
   - `joined_at`: When user joined the group
   - Unique constraint on (group_id, username) pairs
5. **group_messages**

   - `message_id` (Primary Key): Unique message identifier
   - `group_id`: Target group (FK to groups)
   - `sender`: Username of sender (FK to users)
   - `message`: Text content of the message
   - `timestamp`: When the message was sent
   - `sentiment`: Analysis result (POSITIVE, NEUTRAL, NEGATIVE)
   - `sentiment_score`: Numerical sentiment score
6. **sentiment_stats**

   - `id` (Primary Key): Record identifier
   - `group_id`: Group identifier (FK to groups)
   - `day_date`: Date of sentiment statistics
   - `positive_count`: Count of positive messages
   - `neutral_count`: Count of neutral messages
   - `negative_count`: Count of negative messages
   - Unique constraint on (group_id, day_date) pairs

## User Journey

### New User Experience

1. **Registration**

   - User navigates to the registration page
   - Provides username, password, email, and optional details
   - System creates a new user account
   - Redirects to registration confirmation
2. **First Login**

   - User signs in with credentials
   - Lands on the dashboard
   - Views available communication modules
3. **Finding Connections**

   - Uses search functionality to find other users
   - Initiates direct conversations
   - Joins existing groups or creates new ones

### Regular User Experience

1. **Dashboard Navigation**

   - Views recent activity and stats
   - Selects desired communication module
2. **Communication**

   - Exchanges direct messages with other users
   - Participates in group conversations
   - Views sentiment indicators for messages
3. **Group Interaction**

   - Creates new groups for team communication
   - Manages group membership
   - Reviews sentiment analytics for group conversations
4. **Profile Management**

   - Updates personal information
   - Adjusts communication preferences

## Feature Deep Dive

### User Authentication

The authentication system provides secure access control with these components:

- **Registration Process**:

  - Form validation ensures data integrity
  - Password requirements enforced
  - Duplicate username prevention
- **Login Process**:

  - Credentials verified against database
  - Session established upon successful authentication
  - Failed login handling with appropriate feedback
- **Session Management**:

  - Session tracking for authenticated users
  - Timeout handling for security
  - Proper logout cleanup

Implementation: The authentication system is primarily implemented in `register.jsp`, `signin.jsp`, and through session attributes in JSP pages.

### Direct Messaging

Direct messaging enables one-to-one communication:

- **Message Composition**:

  - Text input with formatting
  - Real-time feedback
  - Character limits and validation
- **Message Delivery**:

  - Immediate storage in database
  - Retrieval for recipient
  - Timestamp recording
- **Message History**:

  - Chronological display of conversation
  - Conversation context preservation
  - Pagination for long conversations

Implementation: Direct messaging is handled through `chat.jsp` with database operations storing and retrieving messages from the `messages` table.

### Group Management

Group management provides multi-user conversation organization:

- **Group Creation**:

  - Name and description setup
  - Creator automatically added as member
  - Initial settings configuration
- **Member Management**:

  - Add users to groups
  - Remove members when needed
  - View current membership
- **Group Settings**:

  - Modify group information
  - Control access permissions

Implementation: Group functionality is managed through `group_management.jsp` with operations on the `groups` and `group_members` tables.

### Group Chat

Group chat enables multi-user conversations:

- **Message Broadcasting**:

  - Messages sent to all group members
  - Sender identification
  - Timestamp recording
- **Real-time Updates**:

  - Message polling or refresh
  - New message indicators
  - Unread message tracking
- **Conversation Context**:

  - Message history display
  - Member activity indicators
  - Sentiment overview

Implementation: Group chat is implemented in `group_chat.jsp` with storage in the `group_messages` table and sentiment analysis integration.

### Sentiment Analysis

Sentiment analysis provides emotional context for communications:

- **Real-time Analysis**:

  - Text processing as messages are sent
  - Positive/neutral/negative classification
  - Score calculation based on word values
- **Visual Indicators**:

  - Sentiment emoji display with messages
  - Color-coded sentiment badges
  - Overall conversation tone indicator
- **Analytics Dashboard**:

  - Sentiment distribution charts
  - Trend analysis over time
  - Individual and group sentiment patterns

Implementation: Sentiment analysis is powered by `SentimentAnalyzer.java` with results stored in the `group_messages.sentiment` column and aggregated in `sentiment_stats`. The analytics are visualized in `sentiment_analytics.jsp`.

### Profile Customization

Profile customization allows users to personalize their experience:

- **Personal Information**:

  - Update contact details
  - Modify profile data
  - Change password functionality
- **Preferences Management**:

  - Communication settings
  - Privacy controls
  - Notification preferences

Implementation: Profile functionality is handled through `profile_customization.jsp` with updates to the `users` table.

## Component Connections

### Frontend-Backend Integration

1. **JSP-Java Integration**:

   - JSP pages include Java code for backend operations
   - Java classes provide service functionality
   - Session attributes share data between components
2. **Form Submission Flow**:

   - User submits form on JSP page
   - Data sent to processing JSP with request parameters
   - Backend processes data and updates database
   - Response generated and returned to user
3. **Data Display Process**:

   - JSP requests data from database via JDBC
   - Results processed and formatted
   - HTML generated dynamically with data
   - Presented to user with appropriate styling

### Frontend-Database Connection

1. **Read Operations**:

   - JSP pages connect to database for:
     - User verification
     - Message retrieval
     - Group information
     - Sentiment statistics
2. **Write Operations**:

   - JSP processes handle database updates for:
     - New user registration
     - Message sending
     - Group creation/modification
     - Sentiment data recording
3. **Transaction Management**:

   - Critical operations handled with proper transactions
   - Error handling and rollback capabilities
   - Connection management for resource efficiency

## Database Operations

### Key Database Interactions

1. **User Management**:

   ```sql
   -- User registration
   INSERT INTO users (username, password, email, phone, gender) 
   VALUES (?, ?, ?, ?, ?);

   -- User authentication
   SELECT * FROM users WHERE username = ? AND password = ?;

   -- Profile update
   UPDATE users SET email = ?, phone = ?, gender = ? WHERE username = ?;
   ```
2. **Messaging**:

   ```sql
   -- Send message
   INSERT INTO messages (sender, receiver, message) 
   VALUES (?, ?, ?);

   -- Retrieve conversation
   SELECT * FROM messages 
   WHERE (sender = ? AND receiver = ?) OR (sender = ? AND receiver = ?) 
   ORDER BY timestamp;
   ```
3. **Group Operations**:

   ```sql
   -- Create group
   INSERT INTO groups (group_name, created_by) 
   VALUES (?, ?);

   -- Add member
   INSERT INTO group_members (group_id, username) 
   VALUES (?, ?);

   -- Send group message with sentiment
   INSERT INTO group_messages (group_id, sender, message, sentiment, sentiment_score) 
   VALUES (?, ?, ?, ?, ?);
   ```

### Sentiment Analysis Integration

1. **Message Processing**:

   - When a message is sent to a group, it's analyzed by `SentimentAnalyzer`
   - The message is stored with its sentiment category and score
   - A trigger (`trigger_update_sentiment_stats`) automatically updates the daily sentiment statistics
2. **Sentiment Aggregation**:

   - Daily statistics are stored in the `sentiment_stats` table
   - The `group_sentiment_view` provides an easy way to query overall sentiment
   - The `get_group_sentiment_trend` function returns time-based trend data
3. **Real-time Updates**:

   - `update_sentiment.jsp` handles asynchronous sentiment updates
   - Sentiment data is retrieved for display in chat and analytics pages

## Project Structure

```
GlobalCommunication/
│
├── src/
│   ├── java/
│   │   └── com/
│   │       └── globalcommunication/
│   │           └── utils/
│   │               └── SentimentAnalyzer.java
│   │
│   ├── db/
│   │   ├── create_tables.sql
│   │   └── add_sentiment_analysis.sql
│   │
│   └── conf/
│       └── ... (configuration files)
│
├── web/
│   ├── assets/
│   │   ├── css/
│   │   │   └── global.css
│   │   └── images/
│   │       └── ... (image files)
│   │
│   ├── WEB-INF/
│   │   └── ... (web configuration)
│   │
│   ├── index.html
│   ├── register.jsp
│   ├── signin.jsp
│   ├── registered.jsp
│   ├── dashboard.jsp
│   ├── chat.jsp
│   ├── group_chat.jsp
│   ├── group_management.jsp
│   ├── search_user.jsp
│   ├── profile_customization.jsp
│   ├── sentiment_analytics.jsp
│   ├── update_sentiment.jsp
│   └── logout.jsp
│
├── lib/
│   └── postgresql-42.7.3.jar (PostgreSQL JDBC driver)
│
└── build.xml (Ant build script)
```

## Setup and Deployment

### Prerequisites

- JDK 8 or higher
- Apache Tomcat 9.x
- PostgreSQL 12.x or higher
- NetBeans IDE (recommended for development)

### Database Setup

1. Create PostgreSQL database named `global`
2. Execute `src/db/create_tables.sql` to create the base schema
3. Execute `src/db/add_sentiment_analysis.sql` to add sentiment analysis capabilities

### Application Deployment

1. Build the project using Apache Ant (run `ant build`)
2. Deploy the resulting WAR file to Tomcat
3. Access the application at `http://localhost:8080/GlobalCommunication/`

### Configuration

Database connection parameters can be adjusted in each JSP file where database operations occur:

```java
Connection conn = DriverManager.getConnection("jdbc:postgresql://localhost:5432/global", "postgres", "say my name");
```

For production deployment, consider:

- Using connection pooling
- Externalized configuration
- HTTPS for secure communication

---

This guide provides a comprehensive overview of the Global Communication Network project. For updates, enhancements, or bug reports, please contact the development team.
