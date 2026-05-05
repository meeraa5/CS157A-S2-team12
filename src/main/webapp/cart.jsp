<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.MySQLCon" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Shopping Cart - Spartan Exchange</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles.css">
</head>

<body>

<header class="navbar">
    <h1 class="logo">Spartan Exchange</h1>

    <nav class="nav-links">
        <a href="<%= request.getContextPath() %>/index.jsp">Home</a>
        <a href="<%= request.getContextPath() %>/login.jsp">Account</a>
        <a href="<%= request.getContextPath() %>/help.jsp">Help</a>
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

double total = 0.0;
int totalItems = 0;
%>

<main class="cart-page">

<section class="cart-left">
    <h2>Shopping Cart</h2>

    <%
    String error = request.getParameter("Error");
    if (error != null) {
    %>
        <p style="color:red; font-weight:bold;"><%= error %></p>
    <%
    }
    %>

    <%
    try {
        con = MySQLCon.getConnection();

        String sql =
            "SELECT ci.product_id, ci.quantity, " +
            "p.product_name, p.price, p.quantity_available " +
            "FROM cart c " +
            "JOIN cart_items ci ON c.cart_id = ci.cart_id " +  //This SQL query helps connects cart, cart item and products 
            //To retrieve all users cart with product detailes loike name price and available quantity
            "JOIN products p ON ci.product_id = p.product_id " +
            "WHERE c.user_id = ?";

        ps = con.prepareStatement(sql);
        ps.setInt(1, userId);
        rs = ps.executeQuery();

        boolean hasItems = false;

        while (rs.next()) {
            hasItems = true;
            
            
            //Help calculates and displays total price per item and updates overall cart total and item count for displays 

            int productId = rs.getInt("product_id");
            String productName = rs.getString("product_name");
            double price = rs.getDouble("price");
            int quantity = rs.getInt("quantity");
            int availableQuantity = rs.getInt("quantity_available");
            double itemTotal = price * quantity;
            total += itemTotal;
            totalItems += quantity;
    %>
   

    <div class="cart-item-row">
        <img src="https://via.placeholder.com/120" alt="Product Image">

        <div class="cart-info">
            <h4><%= productName %></h4>
            <p>Price: $<%= String.format("%.2f", price) %></p>
            <p>Quantity in Cart: <%= quantity %></p>
            <p>Available Stock: <%= availableQuantity %></p>
            <p>Item Total: $<%= String.format("%.2f", itemTotal) %></p>

            <div class="cart-actions">

                <form action="<%= request.getContextPath() %>/cart" method="post" style="display:inline;">
                    <input type="hidden" name="action" value="increment">
                    <input type="hidden" name="productId" value="<%= productId %>">

                    <% if (quantity >= availableQuantity) { %>
                        <button type="submit" disabled>+</button>
                    <% } else { %>
                        <button type="submit">+</button>
                    <% } %>
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

            <% if (quantity >= availableQuantity) { %>
                <p style="color:red;">Maximum stock reached.</p>
            <% } %>
        </div>
    </div>

    <%
        }

        if (!hasItems) {
    %>
        <p>No items added to cart.</p>
    <%
        }

    } catch (Exception e) {
        e.printStackTrace();
    %>
        <h3 style="color:red;">Error loading cart:</h3>
        <pre><%= e.toString() %></pre>
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
    <p>Total Items: <%= totalItems %></p>
    <button class="checkout-btn">Proceed to Checkout</button>
</section>

</main>

</body>
</html>