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
        String contextPath = request.getContextPath();
        if (session == null || session.getAttribute("user_id") == null) {
            response.sendRedirect(contextPath + "/login.jsp?Error=Please login to write a review");
            return;
        }

        int userId = (int) session.getAttribute("user_id");
        String pIdStr = request.getParameter("productId");
        String ratingStr = request.getParameter("rating");
        String reviewText = request.getParameter("reviewText");

        // Safety check for parameters
        if (pIdStr == null || ratingStr == null) {
            response.sendRedirect(contextPath + "/index.jsp?Error=Invalid review request");
            return;
        }

        int productId;
        int rating;
        try {
            productId = Integer.parseInt(pIdStr);
            rating = Integer.parseInt(ratingStr);
        } catch (NumberFormatException e) {
            response.sendRedirect(contextPath + "/index.jsp?Error=Invalid review request");
            return;
        }

        if (rating < 1 || rating > 5) {
            response.sendRedirect(contextPath + "/product_reviews.jsp?productId=" + productId + "&Error=Rating must be between 1 and 5");
            return;
        }

        try (Connection con = MySQLCon.getConnection()) {
            
            // 1. Check if user actually bought the item
            boolean hasPurchased = false;
            String checkSql = "SELECT 1 FROM order_items oi JOIN orders o ON oi.order_id = o.order_id " +
                              "WHERE o.user_id = ? AND oi.product_id = ? AND o.order_status IN ('Paid', 'Completed') LIMIT 1";
            
            try (PreparedStatement ps = con.prepareStatement(checkSql)) {
                ps.setInt(1, userId);
                ps.setInt(2, productId);
                try (ResultSet rs = ps.executeQuery()) {
                    hasPurchased = rs.next();
                }
            }

            if (!hasPurchased) {
                response.sendRedirect(contextPath + "/product_reviews.jsp?productId=" + productId + "&Error=You must purchase this item before reviewing");
                return;
            }

            // 2. Insert or Update the review (ON DUPLICATE KEY logic)
            String reviewSql = "INSERT INTO reviews (user_id, product_id, rating, review_text, review_status) VALUES (?, ?, ?, ?, 'Visible') " +
                               "ON DUPLICATE KEY UPDATE rating = VALUES(rating), review_text = VALUES(review_text), review_status = 'Visible', date_posted = CURRENT_TIMESTAMP";
            
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

            response.sendRedirect(contextPath + "/product_reviews.jsp?productId=" + productId + "&Success=Thank you for your review!");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(contextPath + "/product_reviews.jsp?productId=" + productId + "&Error=Could not save review");
        }
    }
}