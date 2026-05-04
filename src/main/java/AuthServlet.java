import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import util.MySQLCon;


@WebServlet("/AuthServlet")
public class AuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String mode = request.getParameter("mode");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if ("signup".equals(mode)) {
            if (email == null || !email.trim().toLowerCase().endsWith("@sjsu.edu")) {
                response.sendRedirect("login.jsp?Error=Please use an @sjsu.edu email address");
                return;
            }

            try (Connection con = MySQLCon.getConnection();
                 PreparedStatement insertPs = con.prepareStatement(
                         "INSERT INTO users (full_name, sjsu_email, password_hash, status) VALUES (?, ?, ?, 'Active')")) {
                insertPs.setString(1, email);   // temporary full_name
                insertPs.setString(2, email);
                insertPs.setString(3, password);

                insertPs.executeUpdate();

                response.sendRedirect("login.jsp?Success=Registered successfully");
            } catch (Exception e) {
                e.printStackTrace();
                response.sendRedirect("login.jsp?Error=Signup failed");
            }
            return;
        }

        // LOGIN VALIDATION
        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            response.sendRedirect("login.jsp?Error=Email and Password are required");
            return;
        }

        HttpSession session = request.getSession();

        try {
            Connection con = MySQLCon.getConnection();

            String userSql = "SELECT user_id, full_name, sjsu_email FROM users WHERE sjsu_email = ? AND password_hash = ?";
            PreparedStatement userPs = con.prepareStatement(userSql);
            userPs.setString(1, email);
            userPs.setString(2, password);

            ResultSet userRs = userPs.executeQuery();

            if (userRs.next()) {
                int userId = userRs.getInt("user_id");
                String fullName = userRs.getString("full_name");
                String sjsuEmail = userRs.getString("sjsu_email");

                session.setAttribute("user_id", userId);
                session.setAttribute("full_name", fullName);
                session.setAttribute("email", sjsuEmail);

                String adminSql = "SELECT * FROM administrators WHERE user_id = ?";
                PreparedStatement adminPs = con.prepareStatement(adminSql);
                adminPs.setInt(1, userId);

                ResultSet adminRs = adminPs.executeQuery();

                if (adminRs.next()) {
                    session.setAttribute("role", "admin");
                    adminRs.close();
                    adminPs.close();
                    userRs.close();
                    userPs.close();
                    con.close();
                    response.sendRedirect("admin.jsp");
                } else {
                    session.setAttribute("role", "user");
                    adminRs.close();
                    adminPs.close();
                    userRs.close();
                    userPs.close();
                    con.close();
                    response.sendRedirect("index.jsp");
                }

            } else {
                userRs.close();
                userPs.close();
                con.close();
                response.sendRedirect("login.jsp?Error=Invalid email or password");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?Error=Database error");
        }
    }
}