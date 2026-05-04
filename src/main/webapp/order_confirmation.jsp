<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.MySQLCon" %>

<%
Integer userId = (Integer) session.getAttribute("user_id");
if (userId == null) {
    response.sendRedirect("login.jsp?Error=Please login first");
    return;
}

String orderIdParam = request.getParameter("orderId");
if (orderIdParam == null) {
    response.sendRedirect("orders.jsp");
    return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Order Confirmation - Spartan Exchange</title>
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
try (Connection con = MySQLCon.getConnection()) {
    int orderId = Integer.parseInt(orderIdParam);
    String orderSql = "SELECT order_id, order_date, order_status, total_amount FROM orders WHERE order_id = ? AND user_id = ?";
    try (PreparedStatement orderPs = con.prepareStatement(orderSql)) {
        orderPs.setInt(1, orderId);
        orderPs.setInt(2, userId);
        try (ResultSet orderRs = orderPs.executeQuery()) {
            if (!orderRs.next()) {
%>
                <h2>Order not found</h2>
                <p>We could not find that order for your account.</p>
<%
            } else {
%>
                <section class="page-card">
                    <h2>Order Confirmed</h2>
                    <p>Thank you for your purchase. Your order has been placed successfully.</p>
                    <p><strong>Order #:</strong> <%= orderRs.getInt("order_id") %></p>
                    <p><strong>Date:</strong> <%= orderRs.getTimestamp("order_date") %></p>
                    <p><strong>Status:</strong> <%= orderRs.getString("order_status") %></p>
                    <p><strong>Total:</strong> $<%= orderRs.getBigDecimal("total_amount") %></p>
                </section>

                <section class="page-card">
                    <h3>Items Purchased</h3>
                    <table class="data-table">
                        <tr>
                            <th>Product</th>
                            <th>Quantity</th>
                            <th>Unit Price</th>
                            <th>Total</th>
                            <th>Review</th>
                        </tr>
<%
                String itemSql = "SELECT oi.product_id, oi.quantity, oi.unit_price, oi.total_price, p.product_name " +
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
                            <td>$<%= itemRs.getBigDecimal("unit_price") %></td>
                            <td>$<%= itemRs.getBigDecimal("total_price") %></td>
                            <td><a href="<%= request.getContextPath() %>/product_reviews.jsp?productId=<%= itemRs.getInt("product_id") %>">Add/View Review</a></td>
                        </tr>
<%
                        }
                    }
                }
%>
                    </table>
                    <p><a href="<%= request.getContextPath() %>/orders.jsp">View all orders</a></p>
                </section>
<%
            }
        }
    }
} catch (Exception e) {
    e.printStackTrace();
%>
    <p>Error loading order confirmation.</p>
<%
}
%>
</main>
</body>
</html>
