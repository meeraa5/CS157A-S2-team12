package servlets;

import java.io.IOException;
import java.net.URLEncoder;
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
            response.sendRedirect("login.jsp?Error=Please login to write a review");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        String pIdStr = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String reviewText = request.getParameter("reviewText");

        // Safety check for parameters
        if (pIdStr == null || ratingStr == null) {
            response.sendRedirect("index.jsp");
            return;
        }

        int productId = Integer.parseInt(pIdStr);
        int rating = Integer.parseInt(ratingStr);

        try (Connection con = MySQLCon.getConnection()) {
            
            // 1. Check if user actually bought the item
            boolean hasPurchased = false;
            String checkSql = "SELECT 1 FROM order_items oi JOIN orders o ON oi.order_id = o.order_id " +
                              "WHERE o.user_id = ? AND oi.product_id = ? LIMIT 1";
            
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    hasPurchased = rs.next();
                }
            }

            if (!hasPurchased) {
                response.sendRedirect("product_reviews.jsp?productId=" + productId + "&Error=You must purchase this item before reviewing");
                return;
            }

            // 2. Insert or Update the review (ON DUPLICATE KEY logic)
            String reviewSql = "INSERT INTO reviews (user_id, product_id, rating, review_text) VALUES (?, ?, ?, ?) " +
                               "ON DUPLICATE KEY UPDATE rating = VALUES(rating), review_text = VALUES(review_text), date_posted = CURRENT_TIMESTAMP";
            
            try (PreparedStatement ps = con.prepareStatement(reviewSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                ps.setInt(3, rating);
                ps.setString(4, reviewText);
                ps.executeUpdate();
            }

            // 3. Log the activity
            try (PreparedStatement logPs = con.prepareStatement("INSERT INTO activity_log (user_id, activity_type, activity_detail) VALUES (?, 'Review', ?)")) {
                logPs.setInt(1, userId);
                logPs.setString(2, "User reviewed product #" + productId);
                logPs.executeUpdate();
            }

            response.sendRedirect("product_reviews.jsp?productId=" + productId + "&Success=Thank you for your review!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("product_reviews.jsp?productId=" + productId + "&Error=Could not save review: " + e.getMessage());
        }
    }
}