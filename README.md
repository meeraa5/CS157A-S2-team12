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
