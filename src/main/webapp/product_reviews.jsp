<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.MySQLCon" %>

<%
Integer userId = (Integer) session.getAttribute("user_id");
String productIdParam = request.getParameter("productId");
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
String error = request.getParameter("Error");
String success = request.getParameter("Success");
if (error != null) {
%>
    <div class="message"><%= error %></div>
<%
}
if (success != null) {
%>
    <div class="message success"><%= success %></div>
<%
}

try (Connection con = MySQLCon.getConnection()) {
    int productId = Integer.parseInt(productIdParam);
    String productName = "";
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

    if (userId != null) {
        String purchaseSql = "SELECT 1 FROM orders o JOIN order_items oi ON o.order_id = oi.order_id " +
                "WHERE o.user_id = ? AND oi.product_id = ? AND o.order_status IN ('Paid', 'Completed') LIMIT 1";
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
            <label for="reviewText">Review</label>
            <textarea id="reviewText" name="reviewText" rows="4"><%= existingText %></textarea>
            <button type="submit">Save Review</button>
        </form>
    </section>
<%
    } else if (userId == null) {
%>
    <p><a href="<%= request.getContextPath() %>/login.jsp">Log in</a> to review products you purchased.</p>
<%
    } else {
%>
    <p>You can review this product after purchasing it.</p>
<%
    }
%>

    <section class="page-card">
        <h3>Customer Reviews</h3>
<%
    String summarySql = "SELECT COUNT(*) AS review_count, AVG(rating) AS average_rating FROM reviews " +
            "WHERE product_id = ? AND review_status = 'Visible'";
    try (PreparedStatement summaryPs = con.prepareStatement(summarySql)) {
        summaryPs.setInt(1, productId);
        try (ResultSet summaryRs = summaryPs.executeQuery()) {
            if (summaryRs.next() && summaryRs.getInt("review_count") > 0) {
%>
        <p><strong>Average Rating:</strong> <%= String.format("%.1f", summaryRs.getDouble("average_rating")) %> / 5 from <%= summaryRs.getInt("review_count") %> review(s)</p>
<%
            } else {
%>
        <p>No reviews yet.</p>
<%
            }
        }
    }

    String reviewSql = "SELECT r.rating, r.review_text, r.date_posted, u.full_name " +
            "FROM reviews r JOIN users u ON r.user_id = u.user_id " +
            "WHERE r.product_id = ? AND r.review_status = 'Visible' " +
            "ORDER BY r.date_posted DESC";
    try (PreparedStatement reviewPs = con.prepareStatement(reviewSql)) {
        reviewPs.setInt(1, productId);
        try (ResultSet reviewRs = reviewPs.executeQuery()) {
            while (reviewRs.next()) {
%>
        <div class="review-card">
            <p><strong><%= reviewRs.getInt("rating") %> / 5</strong> by <%= reviewRs.getString("full_name") %></p>
            <p><%= reviewRs.getString("review_text") == null ? "" : reviewRs.getString("review_text") %></p>
            <p><small><%= reviewRs.getTimestamp("date_posted") %></small></p>
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
    <p>Error loading reviews.</p>
<%
}
%>
</main>
</body>
</html>
