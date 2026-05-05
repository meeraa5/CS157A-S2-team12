package servlets;
import util.MySQLCon;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
//Imports which handles authentication requests from frontend and extends to HTTP requests such as the ones we used GET and POST





@WebServlet("/AuthServlet") //Authentication requests from frontend extends to GET AND POST
public class AuthServlet extends HttpServlet { //Helps ensures that login/signup is processed accordingly
    private static final long serialVersionUID = 1L;
    private String enc(String msg) {
        return URLEncoder.encode(msg, StandardCharsets.UTF_8);
    }
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
    }
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String mode = request.getParameter("mode"); //These codes retrieves input values from these features sent from frontend 
        String fullName = request.getParameter("full_name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/login.jsp?Error=" + enc("Email and Password are required"));
            return;
        }
    email = email.trim().toLowerCase();
      password = password.trim();
      try (Connection con = MySQLCon.getConnection()) {
            if ("signup".equalsIgnoreCase(mode)) {
                 if (fullName == null || fullName.trim().isEmpty()) {
                    response.sendRedirect(request.getContextPath() + "/login.jsp?Error=" + enc("Full name is required"));
                    return;
                }
                   String checkSql = "SELECT user_id FROM users WHERE sjsu_email = ?"; 
                      try (PreparedStatement checkStmt = con.prepareStatement(checkSql)) {
                        checkStmt.setString(1, email);

                    try (ResultSet checkRs = checkStmt.executeQuery()) {
                        if (checkRs.next()) {
                            response.sendRedirect(request.getContextPath() + "/login.jsp?Error=" + enc("Account already exists"));
                            return;
                        }
                    }
                }
                String insertSql = "INSERT INTO users (full_name, sjsu_email, password_hash) VALUES (?, ?, ?)";
                try (PreparedStatement insertStmt = con.prepareStatement(insertSql)) {
                    insertStmt.setString(1, fullName.trim());
                    insertStmt.setString(2, email);
                    insertStmt.setString(3, password);
                    insertStmt.executeUpdate();
                }
                response.sendRedirect(request.getContextPath() + "/login.jsp?Success=" + enc("Registered successfully. Please log in."));
                return;
            }            String loginSql = "SELECT user_id, full_name, sjsu_email FROM users WHERE sjsu_email = ? AND password_hash = ?";       
  //The block aboves cleans input and ensures connection to the database
          //If the user does not exists it helps insert new recording into users table in database
            //When loginng in it uses SQL query to verify login credintials matching email and passwords in the database
            
 try (PreparedStatement stmt = con.prepareStatement(loginSql)) { //The blocks executes the login query using provided email and password to check making sure it conects with database
     stmt.setString(1, email);
      stmt.setString(2, password);

                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        int userId = rs.getInt("user_id");
                        String dbFullName = rs.getString("full_name");
                        String dbEmail = rs.getString("sjsu_email");

                        HttpSession session = request.getSession();
                        session.setAttribute("user_id", userId);
                        session.setAttribute("username", dbFullName);
                        session.setAttribute("email", dbEmail);

                        response.sendRedirect(request.getContextPath() + "/index.jsp"); //After succesful login for user it is redirected to the mainpage index.jsp in this case
                    } else {
                        response.sendRedirect(request.getContextPath() + "/login.jsp?Error=" + enc("Invalid email or password"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/login.jsp?Error=" + enc("Database error during login"));
        }
    }
}