<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.MySQLCon" %>

<%
// Retrieve user session and the specific product ID
Integer userId = (Integer) session.getAttribute("user_id");
String productIdParam = request.getParameter("productId");

// If no product is specified, head back to home
if (productIdParam == null) {
    response.sendRedirect("index.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Product Reviews - Spartan Exchange</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles.css">
</head>
<body>
<header class="navbar">
    <h1 class="logo">Spartan Exchange</h1>
    <nav class="nav-links">
        <a href="<%= request.getContextPath() %>/index.jsp">Home</a>
        <a href="<%= request.getContextPath() %>/orders.jsp">Orders</a>
        <a href="<%= request.getContextPath() %>/cart.jsp">Cart</a>
    </nav>
</header>

<main>
<%
// Feedback messaging for the user (errors or success confirmations)
String error = request.getParameter("Error");
String success = request.getParameter("Success");
if (error != null) {
%>
    <div class="message" style="color: red; background: #fee; padding: 10px; margin: 10px; border: 1px solid red;"><%= error %></div>
<%
}
if (success != null) {
%>
    <div class="message success" style="color: green; background: #efe; padding: 10px; margin: 10px; border: 1px solid green;"><%= success %></div>
<%
}

try (Connection con = MySQLCon.getConnection()) {
    int productId = Integer.parseInt(productIdParam);
    String productName = "";
    
    // 1. Fetch Product Basic Info
    String productSql = "SELECT product_name, product_description FROM products WHERE product_id = ?";
    try (PreparedStatement productPs = con.prepareStatement(productSql)) {
        productPs.setInt(1, productId);
        try (ResultSet productRs = productPs.executeQuery()) {
            if (!productRs.next()) {
%>
                <p>Product not found.</p>
<%
                return;
            }
            productName = productRs.getString("product_name");
%>
    <section class="page-card">
        <h2><%= productName %></h2>
        <p><%= productRs.getString("product_description") %></p>
    </section>
<%
        }
    }

    boolean canReview = false;
    int existingRating = 5;
    String existingText = "";

    // 2. Logic to see if user has bought this item and if they have an existing review
    if (userId != null) {
        // CORRECTED: Ensure status matches 'Completed' (what your CheckoutServlet uses)
        String purchaseSql = "SELECT 1 FROM orders o JOIN order_items oi ON o.order_id = oi.order_id " +
                "WHERE o.user_id = ? AND oi.product_id = ? AND o.order_status = 'Completed' LIMIT 1";
        try (PreparedStatement purchasePs = con.prepareStatement(purchaseSql)) {
            purchasePs.setInt(1, userId);
            purchasePs.setInt(2, productId);
            try (ResultSet purchaseRs = purchasePs.executeQuery()) {
                canReview = purchaseRs.next();
            }
        }

        String existingSql = "SELECT rating, review_text FROM reviews WHERE user_id = ? AND product_id = ?";
        try (PreparedStatement existingPs = con.prepareStatement(existingSql)) {
            existingPs.setInt(1, userId);
            existingPs.setInt(2, productId);
            try (ResultSet existingRs = existingPs.executeQuery()) {
                if (existingRs.next()) {
                    existingRating = existingRs.getInt("rating");
                    existingText = existingRs.getString("review_text") == null ? "" : existingRs.getString("review_text");
                }
            }
        }
    }

    // 3. Show Review Submission Form if authorized
    if (canReview) {
%>
    <section class="page-card">
        <h3>Add or Update Your Review</h3>
        <form action="<%= request.getContextPath() %>/reviews" method="post">
            <input type="hidden" name="productId" value="<%= productId %>">
            <label for="rating">Rating</label>
            <select id="rating" name="rating" required>
<%
        for (int i = 1; i <= 5; i++) {
%>
                <option value="<%= i %>" <%= i == existingRating ? "selected" : "" %>><%= i %> star<%= i == 1 ? "" : "s" %></option>
<%
        }
%>
            </select>
            <br><br>
            <label for="reviewText">Review</label><br>
            <textarea id="reviewText" name="reviewText" rows="4" style="width:100%" placeholder="What did you think of this product?"><%= existingText %></textarea><br>
            <button type="submit" class="btn">Save Review</button>
        </form>
    </section>
<%
    } else if (userId == null) {
%>
    <p class="page-card"><a href="<%= request.getContextPath() %>/login.jsp">Log in</a> to review products you purchased.</p>
<%
    } else {
%>
    <p class="page-card">You can review this product after your purchase is completed.</p>
<%
    }
%>

    <section class="page-card">
        <h3>Customer Reviews</h3>
<%
    // Updated SQL to be more robust regarding columns
    String summarySql = "SELECT COUNT(*) AS review_count, AVG(rating) AS average_rating FROM reviews " +
            "WHERE product_id = ?";
    try (PreparedStatement summaryPs = con.prepareStatement(summarySql)) {
        summaryPs.setInt(1, productId);
        try (ResultSet summaryRs = summaryPs.executeQuery()) {
            if (summaryRs.next() && summaryRs.getInt("review_count") > 0) {
%>
        <p><strong>Average Rating:</strong> <%= String.format("%.1f", summaryRs.getDouble("average_rating")) %> / 5 from <%= summaryRs.getInt("review_count") %> review(s)</p>
<%
            } else {
%>
        <p>No reviews yet. Be the first to review!</p>
<%
            }
        }
    }

    String reviewSql = "SELECT r.rating, r.review_text, r.date_posted, u.full_name " +
            "FROM reviews r JOIN users u ON r.user_id = u.user_id " +
            "WHERE r.product_id = ? " + 
            "ORDER BY r.date_posted DESC";
    try (PreparedStatement reviewPs = con.prepareStatement(reviewSql)) {
        reviewPs.setInt(1, productId);
        try (ResultSet reviewRs = reviewPs.executeQuery()) {
            while (reviewRs.next()) {
%>
        <div class="review-card" style="border-bottom: 1px solid #ddd; padding: 10px 0; margin-bottom: 10px;">
            <p><strong><%= reviewRs.getInt("rating") %> / 5 Stars</strong> by <%= reviewRs.getString("full_name") %></p>
            <p><%= reviewRs.getString("review_text") == null ? "" : reviewRs.getString("review_text") %></p>
            <p><small style="color: #666;">Posted on: <%= reviewRs.getTimestamp("date_posted") %></small></p>
        </div>
<%
            }
        }
    }
%>
    </section>
<%
} catch (Exception e) {
    e.printStackTrace();
%>
    <p>Error loading reviews. Please check console logs.</p>
<%
}
%>
</main>
</body>
</html>