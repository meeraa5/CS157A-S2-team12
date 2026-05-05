<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.MySQLCon" %>

<%
Connection con = null;
PreparedStatement stmt = null;
ResultSet rs = null;

String search = request.getParameter("search");
String category = request.getParameter("category");
String condition = request.getParameter("condition");
String minPrice = request.getParameter("minPrice");
String maxPrice = request.getParameter("maxPrice");

if (search == null) search = "";
if (category == null) category = "";
if (condition == null) condition = "";
if (minPrice == null) minPrice = "";
if (maxPrice == null) maxPrice = "";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Spartan Exchange</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles.css">
</head>
<body>

<header class="navbar">
    <div class="logo">Spartan Exchange</div>

    <nav class="nav-links">
        <a href="<%= request.getContextPath() %>/WishlistServlet">Wishlist</a>
        <a href="#">Help</a>
        <a href="<%= request.getContextPath() %>/cart.jsp">Cart (0)</a>
        <!-- <a href="#">Logout</a> -->
    </nav>
</header>

<main>
    <section>
        <h2>Available Products</h2>

        <div class="search-section">
            <form method="get" action="<%= request.getContextPath() %>/index.jsp" class="filter-bar">

                <input type="text" name="search" placeholder="Search products..." value="<%= search %>">

                <select name="category">
                    <option value="">All Categories</option>
                    <option value="Books" <%= category.equals("Books") ? "selected" : "" %>>Books</option>
                    <option value="Stationery" <%= category.equals("Stationery") ? "selected" : "" %>>Stationery</option>
                    <option value="Furniture" <%= category.equals("Furniture") ? "selected" : "" %>>Furniture</option>
                    <option value="Electronics" <%= category.equals("Electronics") ? "selected" : "" %>>Electronics</option>
                </select>

                <select name="condition">
                    <option value="">All Conditions</option>
                    <option value="New" <%= condition.equals("New") ? "selected" : "" %>>New</option>
                    <option value="Like New" <%= condition.equals("Like New") ? "selected" : "" %>>Like New</option>
                    <option value="Good" <%= condition.equals("Good") ? "selected" : "" %>>Good</option>
                    <option value="Used" <%= condition.equals("Used") ? "selected" : "" %>>Used</option>
                </select>

                <input type="number" step="0.01" name="minPrice" placeholder="Min Price" value="<%= minPrice %>">
                <input type="number" step="0.01" name="maxPrice" placeholder="Max Price" value="<%= maxPrice %>">

                <button type="submit">Apply</button>
                <a href="<%= request.getContextPath() %>/index.jsp" class="clear-btn">Clear</a>
            </form>
        </div>

        <div class="product-container">

<%
try {
    con = MySQLCon.getConnection();

    String sql = "SELECT p.product_id, p.product_name, p.product_description, p.price, " +
                 "p.product_condition, p.quantity_available, p.product_status, c.category_name " +
                 "FROM products p " +
                 "JOIN categories c ON p.category_id = c.category_id " +
                 "WHERE p.product_status = 'Available' " +
                 "AND (p.product_name LIKE ? OR p.product_description LIKE ? OR c.category_name LIKE ?) ";

    if (!category.equals("")) {
        sql += "AND c.category_name = ? ";
    }

    if (!condition.equals("")) {
        sql += "AND p.product_condition = ? ";
    }

    if (!minPrice.equals("")) {
        sql += "AND p.price >= ? ";
    }

    if (!maxPrice.equals("")) {
        sql += "AND p.price <= ? ";
    }

    stmt = con.prepareStatement(sql);

    int index = 1;
    String keyword = "%" + search + "%";

    stmt.setString(index++, keyword);
    stmt.setString(index++, keyword);
    stmt.setString(index++, keyword);

    if (!category.equals("")) {
        stmt.setString(index++, category);
    }

    if (!condition.equals("")) {
        stmt.setString(index++, condition);
    }

    if (!minPrice.equals("")) {
        stmt.setDouble(index++, Double.parseDouble(minPrice));
    }

    if (!maxPrice.equals("")) {
        stmt.setDouble(index++, Double.parseDouble(maxPrice));
    }

    rs = stmt.executeQuery();

    boolean hasProducts = false;

    while (rs.next()) {
        hasProducts = true;
%>

            <div class="product-card">
                <h3><%= rs.getString("product_name") %></h3>
                <p><%= rs.getString("product_description") %></p>
                <p><strong>Price:</strong> $<%= rs.getBigDecimal("price") %></p>
                <p><strong>Condition:</strong> <%= rs.getString("product_condition") %></p>
                <p><strong>Category:</strong> <%= rs.getString("category_name") %></p>
                <p><strong>Remaining Quantity:</strong> <%= rs.getInt("quantity_available") %></p>

                <form method="post" action="<%= request.getContextPath() %>/AddToCartServlet" style="margin-bottom: 8px;">
                    <input type="hidden" name="product_id" value="<%= rs.getInt("product_id") %>">
                    <button type="submit">Add to Cart</button>
                </form>

                <form method="post" action="<%= request.getContextPath() %>/WishlistServlet">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="product_id" value="<%= rs.getInt("product_id") %>">
                    <button type="submit">♡ Add to Wishlist</button>
                </form>
            </div>

<%
    }

    if (!hasProducts) {
%>
            <p>No products available.</p>
<%
    }

} catch (Exception e) {
    e.printStackTrace();
%>
            <p>Error loading products.</p>
<%
} finally {
    try { if (rs != null) rs.close(); } catch (Exception ignored) {}
    try { if (stmt != null) stmt.close(); } catch (Exception ignored) {}
    try { if (con != null) con.close(); } catch (Exception ignored) {}
}
%>

        </div>
    </section>
</main>

<footer>
    <p>&copy; 2026 Spartan Exchange</p>
</footer>

<script src="<%= request.getContextPath() %>/js/script.js"></script>
</body>
</html>