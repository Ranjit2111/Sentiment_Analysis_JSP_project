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
- NetBeans IDE 12.x or higher
- PostgreSQL 12.x or higher with pgAdmin (GUI)

### 1. Setting up Apache Tomcat

1. Download Apache Tomcat 9.x from the [official website](https://tomcat.apache.org/download-90.cgi). Choose the Core zip package (Windows) or tar.gz package (Linux/Mac).

2. Extract the downloaded archive to a directory of your choice.

3. In NetBeans IDE:
   - Go to the **Services** tab (usually on the left side)
   - Right-click on **Servers** and select **Add Server**
   - Select **Apache Tomcat or TomEE** from the list and click **Next**
   - Browse to the location where you extracted Tomcat and select the folder
   - Set a username and password if desired (or leave default)
   - Click **Finish** to complete the setup

4. You can verify the server is properly configured by right-clicking on the newly added Tomcat server in the Services tab and selecting **Start**.

### 2. Setting up PostgreSQL

1. If you haven't already, install PostgreSQL with pgAdmin from the [official website](https://www.postgresql.org/download/).

2. Launch pgAdmin (the PostgreSQL GUI application).

3. Create a new database:
   - In the pgAdmin browser panel, expand **Servers** > **PostgreSQL** (enter your password if prompted)
   - Right-click on **Databases** and select **Create** > **Database**
   - Name the database `global` and click **Save**

4. Set up the database user:
   - Expand **Login/Group Roles**
   - Right-click on the **postgres** user and select **Properties**
   - Go to the **Definition** tab and set the password to `say my name` (to match the application's configuration)
   - Click **Save**

5. Create the database schema:
   - Right-click on the `global` database and select **Query Tool**
   - Open the SQL files from the project (`src/db/create_tables.sql` and `src/db/add_sentiment_analysis.sql`)
   - Execute each script by selecting all content and clicking the **Execute/Refresh** button (or press F5)

   Alternatively, you can copy and paste the SQL commands from these files directly into the Query Tool.

### 3. Setting up the Project

#### Option 1: Clone from GitHub

1. Clone the repository:
   ```bash
   git clone https://github.com/Ranjit2111/JSP_PostgreSQL_project.git
   ```

2. Open the project in NetBeans:
   - Go to **File** > **Open Project**
   - Navigate to the cloned repository folder and select it
   - Click **Open Project**

3. Configure the database connection:
   - The default connection string is `jdbc:postgresql://localhost:5432/global` with username `postgres` and password `say my name`
   - If you used different credentials, update them in the JSP files where database connections are established

4. Add the PostgreSQL JDBC driver to your project libraries:
   - Right-click on the project in the Projects panel
   - Select **Properties**
   - Go to **Libraries** > **Add JAR/Folder**
   - Navigate to the project's `lib` folder and select `postgresql-42.7.3.jar`
   - Click **Open** and then **OK**

#### Option 2: Manual Setup

1. Create a new Java Web Application project in NetBeans:
   - Go to **File** > **New Project**
   - Select **Java with Ant** > **Java Web** > **Web Application**
   - Name the project `GlobalCommunication` and click **Finish**

2. Copy the project files into your project directory.

3. Add the PostgreSQL JDBC driver as described in Option 1, step 4.

4. Configure the database connection as described in Option 1, step 3.

## Running the Application

1. In NetBeans IDE:
   - Right-click on the project in the Projects panel
   - Select **Clean and Build** to compile the project
   - After successful build, right-click on the project again and select **Run**
   - NetBeans will automatically deploy the application to the configured Tomcat server

2. The application will open in your default web browser at `http://localhost:8080/GlobalCommunication/`

3. Register a new account or sign in with existing credentials.

4. Navigate through the dashboard to access different features.

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