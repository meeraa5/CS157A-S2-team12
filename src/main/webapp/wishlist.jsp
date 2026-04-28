<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.math.RoundingMode" %>
<%
	String ctx = request.getContextPath();
	@SuppressWarnings("unchecked")
	List<Map<String, Object>> wishlistItems = (List<Map<String, Object>>) request.getAttribute("wishlistItems");
	if (wishlistItems == null) {
		response.sendRedirect(ctx + "/WishlistServlet");
		return;
	}
	String dbError = (String) request.getAttribute("dbError");
	String qErr = request.getParameter("Error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, initial-scale=1.0">
	<title>My Wishlist - Spartan Exchange</title>
	<link rel="stylesheet" href="<%= ctx %>/styles.css">
</head>
<body>

<header class="navbar">
	<div class="logo">Spartan Exchange</div>
	<nav class="nav-links">
		<a href="<%= ctx %>/index.jsp">Home</a>
		<a href="<%= ctx %>/WishlistServlet">Wishlist</a>
		<a href="#">Help</a>
		<a href="<%= ctx %>/cart.jsp">Cart</a>
	</nav>
</header>

<main class="products" style="max-width: 1200px; margin: 0 auto; padding: 24px;">
	<section class="cart-left">
		<h2>Saved items</h2>

		<% if (dbError != null) { %>
			<p class="message" style="color: #b00020;"><%= dbError %></p>
		<% } %>
		<% if (qErr != null) { %>
			<p class="message" style="color: #b00020;">We could not update your wishlist. Try again.</p>
		<% } %>

		<% if (wishlistItems.isEmpty()) { %>
			<p>No items in your wishlist yet.</p>
			<p><a href="<%= ctx %>/index.jsp">Browse products</a></p>
		<% } else { %>
			<div class="product-grid" style="margin-top: 20px;">
			<% for (Map<String, Object> row : wishlistItems) {
				int wid = (Integer) row.get("wishlist_item_id");
				int pid = (Integer) row.get("product_id");
				String name = (String) row.get("product_name");
				String desc = row.get("product_description") != null ? (String) row.get("product_description") : "";
				BigDecimal price = (BigDecimal) row.get("price");
				String cond = row.get("product_condition") != null ? (String) row.get("product_condition") : "";
				String priceStr = price != null ? price.setScale(2, RoundingMode.HALF_UP).toPlainString() : "0.00";
			%>
				<div class="product-card">
					<h3><%= name.replace("&", "&amp;").replace("<", "&lt;") %></h3>
					<p><%= desc.replace("&", "&amp;").replace("<", "&lt;") %></p>
					<p class="price">$<%= priceStr %></p>
					<p style="font-size: 0.9rem; color: #555;"><%= cond.replace("&", "&amp;").replace("<", "&lt;") %></p>

					<div class="product-actions">
						<form method="post" action="<%= ctx %>/AddToCartServlet" style="display:inline;">
							<input type="hidden" name="product_id" value="<%= pid %>">
							<button type="submit">Add to cart</button>
						</form>
						<form method="post" action="<%= ctx %>/WishlistServlet" style="display:inline;">
							<input type="hidden" name="action" value="remove">
							<input type="hidden" name="wishlist_item_id" value="<%= wid %>">
							<button type="submit">Remove</button>
						</form>
					</div>
				</div>
			<% } %>
			</div>
		<% } %>
	</section>
</main>

<footer>
	<p>&copy; 2026 Spartan Exchange</p>
</footer>

</body>
</html>
