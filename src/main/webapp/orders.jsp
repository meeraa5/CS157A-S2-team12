<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.MySQLCon" %>

<%
Integer userId = (Integer) session.getAttribute("user_id");
if (userId == null) {
    response.sendRedirect("login.jsp?Error=Please login first");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order History - Spartan Exchange</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles.css">
</head>
<body>
<header class="navbar">
    <h1 class="logo">Spartan Exchange</h1>
    <nav class="nav-links">
        <a href="<%= request.getContextPath() %>/index.jsp">Home</a>
        <a href="<%= request.getContextPath() %>/cart.jsp">Cart</a>
        <a href="<%= request.getContextPath() %>/login.jsp">Account</a>
    </nav>
</header>

<main>
    <h2>Order History</h2>
<%
try (Connection con = MySQLCon.getConnection()) {
    String orderSql = "SELECT order_id, order_date, order_status, total_amount " +
            "FROM orders WHERE user_id = ? ORDER BY order_date DESC";
    try (PreparedStatement orderPs = con.prepareStatement(orderSql)) {
        orderPs.setInt(1, userId);
        try (ResultSet orderRs = orderPs.executeQuery()) {
            boolean hasOrders = false;
            while (orderRs.next()) {
                hasOrders = true;
                int orderId = orderRs.getInt("order_id");
%>
    <section class="page-card">
        <h3>Order #<%= orderId %></h3>
        <p><strong>Date:</strong> <%= orderRs.getTimestamp("order_date") %></p>
        <p><strong>Status:</strong> <%= orderRs.getString("order_status") %></p>
        <p><strong>Total:</strong> $<%= orderRs.getBigDecimal("total_amount") %></p>
        <table class="data-table">
            <tr>
                <th>Product</th>
                <th>Quantity</th>
                <th>Total</th>
                <th>Review</th>
            </tr>
<%
                String itemSql = "SELECT oi.product_id, oi.quantity, oi.total_price, p.product_name " +
                        "FROM order_items oi JOIN products p ON oi.product_id = p.product_id " +
                        "WHERE oi.order_id = ?";
                try (PreparedStatement itemPs = con.prepareStatement(itemSql)) {
                    itemPs.setInt(1, orderId);
                    try (ResultSet itemRs = itemPs.executeQuery()) {
                        while (itemRs.next()) {
%>
            <tr>
                <td><%= itemRs.getString("product_name") %></td>
                <td><%= itemRs.getInt("quantity") %></td>
                <td>$<%= itemRs.getBigDecimal("total_price") %></td>
                <td><a href="<%= request.getContextPath() %>/product_reviews.jsp?productId=<%= itemRs.getInt("product_id") %>">Add/View Review</a></td>
            </tr>
<%
                        }
                    }
                }
%>
        </table>
    </section>
<%
            }
            if (!hasOrders) {
%>
    <p>You do not have any orders yet.</p>
<%
            }
        }
    }
} catch (Exception e) {
    e.printStackTrace();
%>
    <p>Error loading order history.</p>
<%
}
%>
</main>
</body>
</html>
