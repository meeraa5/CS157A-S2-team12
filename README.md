# CS157A – Spartan Exchange (Team 12)

##  Project Update – JSP + Servlet Migration


---

##  Major Changes made for second code review session 
* HTML → JSP (dynamic pages)
* Added backend logic using Java Servlets
* Organized project using standard Eclipse Dynamic Web structure according to three tier architecture example done in HW 1
* Prepared for Tomcat deployment

## Directory Structure
CS157A-S2-team12 -> src -> main -> java -> AuthServlet.java
->webapp -> index.jsp, login.jsp, styles.css
         
## Current Status
- User registration allows new users to create an account using @sjsu.edu email and password
- User login authentication allows existing users to log in and redirects them to the main page
- Session management stores user information (e.g., email) across pages
- Page navigation control allows redirection between login and homepage
- Search input handling allows users to enter and process search queries from the interface

## Next Goals
- Convert cart functionality into JavaScript within Eclipse architecture
- Convert wishlist functionality into JavaScript within Eclipse architecture
- Integrate MySQL database tables with the web application
- Add additional core functionalities (orders, reviews, etc.)
- Continue updating and refining the README documentation

## Local Mac Setup

This project runs as a JSP/Servlet web app on Tomcat with MySQL.

### Required tools

- JDK 17 or newer
- Apache Tomcat 9
- MySQL 8
- MySQL Connector/J available to Tomcat

### Database setup

Create and load the database:

```sh
mysql -u root -p -e "CREATE DATABASE IF NOT EXISTS spartanexchange;"
mysql -u root -p spartanexchange < schema.sql
mysql -u root -p spartanexchange < seed.sql
```

The app reads database settings from environment variables or Java system properties:

```sh
export DB_URL="jdbc:mysql://localhost:3306/spartanexchange?useSSL=false&serverTimezone=UTC"
export DB_USER="root"
export DB_PASSWORD="your_mysql_password"
```

If you do not set these values, the app defaults to local MySQL on `spartanexchange`, user `root`, and an empty password.

### Test accounts from seed.sql

- Admin: `admin@sjsu.edu` / `admin123`
- Student: `student@sjsu.edu` / `password123`

### Run in Tomcat

Deploy the project as a Dynamic Web Project, or build an exploded web app with compiled classes under `WEB-INF/classes` and copy `src/main/webapp` into Tomcat `webapps/CS157A_Team_12_Project`.

Open:

```text
http://localhost:8080/CS157A_Team_12_Project/
```
