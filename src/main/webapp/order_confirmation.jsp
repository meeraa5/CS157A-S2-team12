<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, util.MySQLCon" %>
<%
    Integer userId = (Integer) session.getAttribute("user_id");
    String orderIdParam = request.getParameter("orderId");
    if (userId == null || orderIdParam == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Order Confirmed</title>
    <link rel="stylesheet" href="styles.css">
</head>
<body>
<main class="page-card">
<%
    try (Connection con = MySQLCon.getConnection()) {
        int orderId = Integer.parseInt(orderIdParam);
        String sql = "SELECT * FROM orders WHERE order_id = ? AND user_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
%>
    <h2>Order #<%= orderId %> Confirmed!</h2>
    <p>Total Paid: $<%= rs.getBigDecimal("total_amount") %></p>
    <p>Status: <%= rs.getString("order_status") %></p>
    <hr>
    <h3>Items:</h3>
    <ul>
    <%
        String itemSql = "SELECT p.product_name, oi.quantity FROM order_items oi JOIN products p ON oi.product_id = p.product_id WHERE oi.order_id = ?";
        try (PreparedStatement ips = con.prepareStatement(itemSql)) {
            ips.setInt(1, orderId);
            try (ResultSet irs = ips.executeQuery()) {
                while (irs.next()) {
    %>
        <li><%= irs.getString("product_name") %> (x<%= irs.getInt("quantity") %>)</li>
    <% } } } %>
    </ul>
    <a href="index.jsp" class="btn">Return Home</a>
<%
                } else {
                    out.println("Order not found.");
                }
            }
        }
    } catch (Exception e) { e.printStackTrace(); }
%>
</main>
</body>
</html>