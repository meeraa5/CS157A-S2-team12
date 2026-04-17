import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AuthServlet")
public class AuthServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String mode = request.getParameter("mode");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if ("signup".equals(mode)) {
            response.sendRedirect("login.jsp?Success=Registered successfully");
        } else {
            response.sendRedirect("index.jsp");
        }
    }
}