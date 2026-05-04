<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.MySQLCon" %>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart - Spartan Exchange</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles.css">
</head>

<body>

<header class="navbar">
    <h1 class="logo">Spartan Exchange</h1>

<nav class="nav-links">
    <a href="<%= request.getContextPath() %>/index.jsp">Home</a>
    <a href="<%= request.getContextPath() %>/orders.jsp">Orders</a>
    <a href="<%= request.getContextPath() %>/login.jsp">Account</a>
    <a href="#">Help</a>
    <a href="<%= request.getContextPath() %>/cart.jsp">Cart</a>
</nav>
</header>



<%
Integer userId = (Integer) session.getAttribute("user_id");

if (userId == null) {
    response.sendRedirect("login.jsp?Error=Please login first");
    return;
}

Connection con = null;
PreparedStatement ps = null;
ResultSet rs = null;

double total = 0;
int totalItems = 0;
%>

<main class="cart-page">

    <section class="cart-left">
        <h2>Shopping Cart</h2>
        <%
        String error = request.getParameter("Error");
        if (error != null) {
        %>
            <div class="message"><%= error %></div>
        <%
        }
        %>

        <%
        try {
            con = MySQLCon.getConnection();

            String sql = "SELECT ci.cart_item_id, ci.product_id, p.product_name, p.price, ci.quantity " +
                    "FROM cart c " +
                    "JOIN cart_items ci ON c.cart_id = ci.cart_id " +
                    "JOIN products p ON ci.product_id = p.product_id " +
                    "WHERE c.user_id = ?";

            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();

            boolean hasItems = false;

            while (rs.next()) {
                hasItems = true;

                String productName = rs.getString("product_name");
                double price = rs.getDouble("price");
                int quantity = rs.getInt("quantity"),
                	 productId = rs.getInt("product_id");
                
                total += price * quantity;
                totalItems += quantity;
        %>

        <div class="cart-item-row">
    <img src="https://via.placeholder.com/120" alt="Product Image">

    <div class="cart-info">
        <h4><%= productName %></h4>
        <p>$<%= String.format("%.2f", price) %></p>
        <p>Quantity: <%= quantity %></p>

        <div class="cart-actions">
            <form action="<%= request.getContextPath() %>/cart" method="post" style="display:inline;">
                <input type="hidden" name="action" value="increment">
                <input type="hidden" name="productId" value="<%= productId %>">
                <button type="submit">+</button>
            </form>

            <form action="<%= request.getContextPath() %>/cart" method="post" style="display:inline;">
                <input type="hidden" name="action" value="decrement">
                <input type="hidden" name="productId" value="<%= productId %>">
                <button type="submit">-</button>
            </form>

            <form action="<%= request.getContextPath() %>/cart" method="post" style="display:inline;">
                <input type="hidden" name="action" value="remove">
                <input type="hidden" name="productId" value="<%= productId %>">
                <button type="submit">Remove</button>
            </form>
        </div>
    </div>
</div>
        <%
            }

            if (!hasItems) {
        %>
            <p>No items in cart.</p>
        <%
            }

        } catch (Exception e) {
            e.printStackTrace();
        %>
            <p>Error loading cart.</p>
        <%
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (con != null) con.close(); } catch (Exception e) {}
        }
        %>
    </section>

    <section class="cart-right">
        <h3>Subtotal: $<%= String.format("%.2f", total) %></h3>
        <form action="<%= request.getContextPath() %>/checkout" method="post">
            <button class="checkout-btn" type="submit" <%= totalItems == 0 ? "disabled" : "" %>>Proceed to Checkout</button>
        </form>
    </section>

</main>
</body>
</html>



     
     
     
     
     
     
     
     
     
     
     
     
     
     
     