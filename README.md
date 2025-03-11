# Global Communication Network

A web-based communication platform built with Java Server Pages (JSP) and PostgreSQL, featuring user authentication, messaging, group chats, and sentiment analysis.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Setup Instructions](#setup-instructions)
  - [Prerequisites](#prerequisites)
  - [1. Setting up Apache Tomcat](#1-setting-up-apache-tomcat)
  - [2. Setting up PostgreSQL](#2-setting-up-postgresql)
  - [3. Setting up the Project](#3-setting-up-the-project)
- [Running the Application](#running-the-application)
- [Sentiment Analysis Module](#sentiment-analysis-module)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Overview

Global Communication Network is a web application that enables users to connect and communicate with each other through direct messaging and group chats. The application includes features such as user authentication, profile customization, real-time messaging, and sentiment analysis for group conversations.

## Features

- **User Authentication**: Secure sign-in and registration system
- **Messaging**: Direct messaging between users
- **Group Chat**: Create and manage group conversations
- **Sentiment Analysis**: Real-time analysis of message sentiment with visual indicators
- **Analytics Dashboard**: Comprehensive sentiment analytics for group conversations

## Technology Stack

- **Frontend**: JSP, HTML, CSS, JavaScript
- **Backend**: Java, JSP
- **Database**: PostgreSQL
- **Server**: Apache Tomcat
- **Build Tool**: Apache Ant

## Project Structure

- `src/java/`: Java source files
  - `com/globalcommunication/utils/`: Utility classes including SentimentAnalyzer
- `web/`: Web content (JSP, CSS, JavaScript)
- `lib/`: External libraries
- `src/db/`: Database scripts

## Setup Instructions

### Prerequisites

Before you begin, ensure you have the following installed:
- JDK 8 or higher
- Apache Tomcat 9.x
- PostgreSQL 12.x or higher
- NetBeans IDE (recommended) or any Java IDE

### 1. Setting up Apache Tomcat

1. Download Apache Tomcat 9.x from the [official website](https://tomcat.apache.org/download-90.cgi). Choose the Core tar.gz package.

2. Extract the downloaded archive to a directory of your choice:
   ```bash
   tar -xzvf apache-tomcat-9.0.x.tar.gz
   ```

3. Set environment variables:
   ```bash
   # For Linux/Mac
   export CATALINA_HOME=/path/to/apache-tomcat-9.0.x
   export PATH=$PATH:$CATALINA_HOME/bin
   
   # For Windows (add to System Environment Variables)
   CATALINA_HOME=C:\path\to\apache-tomcat-9.0.x
   PATH=%PATH%;%CATALINA_HOME%\bin
   ```

4. Make the startup scripts executable (Linux/Mac):
   ```bash
   chmod +x $CATALINA_HOME/bin/*.sh
   ```

5. Start Tomcat:
   ```bash
   # Linux/Mac
   $CATALINA_HOME/bin/startup.sh
   
   # Windows
   %CATALINA_HOME%\bin\startup.bat
   ```

6. Verify Tomcat is running by visiting `http://localhost:8080` in your browser.

### 2. Setting up PostgreSQL

1. Download and install PostgreSQL from the [official website](https://www.postgresql.org/download/).

2. Start the PostgreSQL service:
   ```bash
   # Linux
   sudo service postgresql start
   
   # Mac
   brew services start postgresql
   
   # Windows
   # PostgreSQL service should start automatically
   ```

3. Create a database and user:
   ```bash
   # Connect to PostgreSQL
   psql -U postgres
   
   # Create database
   CREATE DATABASE global;
   
   # Set password (use 'say my name' as the password to match the application's configuration)
   ALTER USER postgres WITH PASSWORD 'say my name';
   
   # Exit PostgreSQL
   \q
   ```

4. Create the database schema by running the following SQL scripts:

   a. First, run the `create_tables.sql` script:
   ```bash
   psql -U postgres -d global -f src/db/create_tables.sql
   ```

   b. Then, run the `add_sentiment_analysis.sql` script:
   ```bash
   psql -U postgres -d global -f src/db/add_sentiment_analysis.sql
   ```

   Alternatively, you can run these SQL commands directly in the PostgreSQL console:

   ```sql
   -- Basic database setup script for Global Communication Network

   -- Users table
   CREATE TABLE IF NOT EXISTS users (
       username VARCHAR(50) PRIMARY KEY,
       password VARCHAR(100) NOT NULL,
       email VARCHAR(100) NOT NULL,
       phone VARCHAR(20),
       gender VARCHAR(10),
       registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
   );

   -- Messages table for direct messaging
   CREATE TABLE IF NOT EXISTS messages (
       message_id SERIAL PRIMARY KEY,
       sender VARCHAR(50) NOT NULL,
       receiver VARCHAR(50) NOT NULL,
       message TEXT NOT NULL,
       timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       CONSTRAINT fk_sender FOREIGN KEY (sender) REFERENCES users(username) ON DELETE CASCADE,
       CONSTRAINT fk_receiver FOREIGN KEY (receiver) REFERENCES users(username) ON DELETE CASCADE
   );

   -- Groups table
   CREATE TABLE IF NOT EXISTS groups (
       group_id SERIAL PRIMARY KEY,
       group_name VARCHAR(100) NOT NULL,
       created_by VARCHAR(50) NOT NULL,
       created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       CONSTRAINT fk_creator FOREIGN KEY (created_by) REFERENCES users(username) ON DELETE CASCADE
   );

   -- Group members table
   CREATE TABLE IF NOT EXISTS group_members (
       id SERIAL PRIMARY KEY,
       group_id INTEGER NOT NULL,
       username VARCHAR(50) NOT NULL,
       joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES groups(group_id) ON DELETE CASCADE,
       CONSTRAINT fk_user FOREIGN KEY (username) REFERENCES users(username) ON DELETE CASCADE,
       CONSTRAINT unique_membership UNIQUE (group_id, username)
   );

   -- Group messages table
   CREATE TABLE IF NOT EXISTS group_messages (
       message_id SERIAL PRIMARY KEY,
       group_id INTEGER NOT NULL,
       sender VARCHAR(50) NOT NULL,
       message TEXT NOT NULL,
       timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES groups(group_id) ON DELETE CASCADE,
       CONSTRAINT fk_sender FOREIGN KEY (sender) REFERENCES users(username) ON DELETE CASCADE
   );

   -- Create indexes for better performance
   CREATE INDEX idx_messages_sender ON messages(sender);
   CREATE INDEX idx_messages_receiver ON messages(receiver);
   CREATE INDEX idx_group_members_group ON group_members(group_id);
   CREATE INDEX idx_group_members_user ON group_members(username);
   CREATE INDEX idx_group_messages_group ON group_messages(group_id);
   CREATE INDEX idx_group_messages_sender ON group_messages(sender);

   -- Add sentiment analysis capabilities
   ALTER TABLE group_messages ADD COLUMN sentiment VARCHAR(20);
   ALTER TABLE group_messages ADD COLUMN sentiment_score NUMERIC(5,2);

   -- Create a sentiment_stats table to store aggregate sentiment data
   CREATE TABLE IF NOT EXISTS sentiment_stats (
       id SERIAL PRIMARY KEY,
       group_id INTEGER NOT NULL,
       day_date DATE NOT NULL,
       positive_count INTEGER DEFAULT 0,
       neutral_count INTEGER DEFAULT 0,
       negative_count INTEGER DEFAULT 0,
       CONSTRAINT fk_group FOREIGN KEY (group_id) REFERENCES groups(group_id) ON DELETE CASCADE,
       CONSTRAINT unique_group_day UNIQUE (group_id, day_date)
   );

   -- Create an index for faster sentiment queries
   CREATE INDEX idx_sentiment ON group_messages(group_id, sentiment);
   CREATE INDEX idx_sentiment_stats_date ON sentiment_stats(day_date);

   -- Add a function to update sentiment stats
   CREATE OR REPLACE FUNCTION update_sentiment_stats()
   RETURNS TRIGGER AS $$
   BEGIN
       INSERT INTO sentiment_stats (group_id, day_date, positive_count, neutral_count, negative_count)
       VALUES (NEW.group_id, CURRENT_DATE,
           CASE WHEN NEW.sentiment = 'POSITIVE' THEN 1 ELSE 0 END,
           CASE WHEN NEW.sentiment = 'NEUTRAL' THEN 1 ELSE 0 END,
           CASE WHEN NEW.sentiment = 'NEGATIVE' THEN 1 ELSE 0 END)
       ON CONFLICT (group_id, day_date) DO UPDATE SET
           positive_count = sentiment_stats.positive_count + CASE WHEN NEW.sentiment = 'POSITIVE' THEN 1 ELSE 0 END,
           neutral_count = sentiment_stats.neutral_count + CASE WHEN NEW.sentiment = 'NEUTRAL' THEN 1 ELSE 0 END,
           negative_count = sentiment_stats.negative_count + CASE WHEN NEW.sentiment = 'NEGATIVE' THEN 1 ELSE 0 END;
       RETURN NEW;
   END;
   $$ LANGUAGE plpgsql;

   -- Create a trigger for sentiment stats
   CREATE TRIGGER trigger_update_sentiment_stats
   AFTER INSERT ON group_messages
   FOR EACH ROW
   WHEN (NEW.sentiment IS NOT NULL)
   EXECUTE FUNCTION update_sentiment_stats();

   -- Create a view for sentiment analytics
   CREATE OR REPLACE VIEW group_sentiment_view AS
   SELECT 
       g.group_id,
       g.group_name,
       ss.day_date,
       ss.positive_count,
       ss.neutral_count,
       ss.negative_count,
       (ss.positive_count + ss.neutral_count + ss.negative_count) AS total_messages,
       CASE 
           WHEN (ss.positive_count > ss.negative_count AND ss.positive_count > ss.neutral_count) THEN 'POSITIVE'
           WHEN (ss.negative_count > ss.positive_count AND ss.negative_count > ss.neutral_count) THEN 'NEGATIVE'
           ELSE 'NEUTRAL'
       END AS daily_sentiment
   FROM 
       sentiment_stats ss
   JOIN 
       groups g ON ss.group_id = g.group_id;

   -- Create a function for sentiment trend
   CREATE OR REPLACE FUNCTION get_group_sentiment_trend(p_group_id INTEGER, p_days INTEGER)
   RETURNS TABLE (
       day_date DATE,
       positive_count INTEGER,
       negative_count INTEGER,
       neutral_count INTEGER,
       daily_sentiment VARCHAR(20)
   ) AS $$
   BEGIN
       RETURN QUERY
       SELECT 
           ss.day_date,
           ss.positive_count,
           ss.negative_count,
           ss.neutral_count,
           CASE 
               WHEN (ss.positive_count > ss.negative_count AND ss.positive_count > ss.neutral_count) THEN 'POSITIVE'
               WHEN (ss.negative_count > ss.positive_count AND ss.negative_count > ss.neutral_count) THEN 'NEGATIVE'
               ELSE 'NEUTRAL'
           END AS daily_sentiment
       FROM 
           sentiment_stats ss
       WHERE 
           ss.group_id = p_group_id
           AND ss.day_date >= (CURRENT_DATE - p_days)
       ORDER BY 
           ss.day_date DESC;
   END;
   $$ LANGUAGE plpgsql;
   ```

### 3. Setting up the Project

#### Option 1: Clone from GitHub

1. Clone the repository:
   ```bash
   git clone https://github.com/Ranjit2111/JSP_PostgreSQL_project.git
   ```

2. Open the project in NetBeans or your preferred IDE.

3. Configure the database connection:
   - The default connection string is `jdbc:postgresql://localhost:5432/global` with username `postgres` and password `say my name`
   - If you used different credentials, update them in the JSP files where database connections are established

4. Add the PostgreSQL JDBC driver to your project libraries (included in `lib/postgresql-42.7.3.jar`).

5. Build the project:
   ```bash
   # Using Ant
   ant build
   ```

#### Option 2: Manual Setup

1. Create a new Java Web Application project in your IDE.

2. Copy the project files into your project directory.

3. Add the PostgreSQL JDBC driver to your project libraries (included in `lib/postgresql-42.7.3.jar`).

4. Configure the database connection as described above.

5. Build the project.

## Running the Application

1. Start the Tomcat server:
   ```bash
   # Linux/Mac
   $CATALINA_HOME/bin/startup.sh
   
   # Windows
   %CATALINA_HOME%\bin\startup.bat
   ```

2. Deploy the application to Tomcat:
   - If using NetBeans, right-click the project and select "Run"
   - Alternatively, copy the built WAR file to Tomcat's webapps directory

3. Access the application at `http://localhost:8080/GlobalCommunication/`

4. Register a new account or sign in with existing credentials.

5. Navigate through the dashboard to access different features.

## Sentiment Analysis Module

The sentiment analysis module analyzes the emotional tone of messages in group chats:

- **Real-time Analysis**: Messages are analyzed as they are sent
- **Visual Indicators**: Color-coded badges and emojis show sentiment at a glance
- **Sentiment Categories**: Positive, Neutral, and Negative
- **Analytics Dashboard**: Access detailed sentiment analytics for each group

To access sentiment analytics:
1. Open a group chat
2. Click on the "Sentiment Analytics" button in the chat header

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Font Awesome for icons
- Apache Tomcat for the web server
- PostgreSQL for the database system 