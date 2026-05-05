package servlets;

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

@WebServlet("/reviews")
public class ReviewServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect("login.jsp?Error=Please login first");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        int productId = Integer.parseInt(request.getParameter("productId"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        String reviewText = request.getParameter("reviewText");

        if (rating < 1 || rating > 5) {
            response.sendRedirect("product_reviews.jsp?productId=" + productId + "&Error=Rating must be between 1 and 5");
            return;
        }

        try (Connection con = MySQLCon.getConnection()) {
            if (!hasPurchasedProduct(con, userId, productId)) {
                response.sendRedirect("product_reviews.jsp?productId=" + productId + "&Error=You can only review products you purchased");
                return;
            }

            String sql = "INSERT INTO reviews (user_id, product_id, rating, review_text, review_status) " +
                    "VALUES (?, ?, ?, ?, 'Visible') " +
                    "ON DUPLICATE KEY UPDATE rating = VALUES(rating), review_text = VALUES(review_text), " +
                    "review_status = 'Visible', date_posted = CURRENT_TIMESTAMP";
            try (PreparedStatement ps = con.prepareStatement(sql)) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                ps.setInt(3, rating);
                ps.setString(4, reviewText);
                ps.executeUpdate();
            }

            logActivity(con, userId, "Review", "Reviewed product #" + productId);
            response.sendRedirect("product_reviews.jsp?productId=" + productId + "&Success=Review saved");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("product_reviews.jsp?productId=" + productId + "&Error=Could not save review");
        }
    }

    private boolean hasPurchasedProduct(Connection con, int userId, int productId) throws Exception {
        String sql = "SELECT 1 FROM orders o " +
                "JOIN order_items oi ON o.order_id = oi.order_id " +
                "WHERE o.user_id = ? AND oi.product_id = ? AND o.order_status IN ('Paid', 'Completed') LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        }
    }

    private void logActivity(Connection con, int userId, String type, String detail) throws Exception {
        String sql = "INSERT INTO activity_log (user_id, activity_type, activity_detail) VALUES (?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setString(2, type);
            ps.setString(3, detail);
            ps.executeUpdate();
        }
    }
}
