<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.MySQLCon" %>

<%
// Start of original logic for handling search and filter parameters
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

// Check if user is logged in to show/hide certain links
Integer userId = (Integer) session.getAttribute("user_id");
String role = (String) session.getAttribute("role");
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
        <a href="<%= request.getContextPath() %>/index.jsp">Home</a>
        <% if (userId != null) { %>
            <a href="<%= request.getContextPath() %>/WishlistServlet">Wishlist</a>
            <a href="<%= request.getContextPath() %>/orders.jsp">Orders</a>
            <a href="<%= request.getContextPath() %>/cart.jsp">Cart</a>
            <% if ("admin".equals(role)) { %>
                <a href="<%= request.getContextPath() %>/admin.jsp">Admin</a>
            <% } %>
            <a href="<%= request.getContextPath() %>/AuthServlet?action=logout">Logout</a>
        <% } else { %>
            <a href="<%= request.getContextPath() %>/login.jsp">Login</a>
        <% } %>
        <a href="<%= request.getContextPath() %>/help.jsp">Help</a>
    </nav>
</header>

<main>
    <%-- Global Feedback Section --%>
    <% if (request.getParameter("Success") != null) { %>
        <div class="message success" style="color: green; padding: 10px; text-align: center;"><%= request.getParameter("Success") %></div>
    <% } %>

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

    // SQL construction logic with dynamic filtering
    String sql = "SELECT p.product_id, p.product_name, p.product_description, p.price, " +
                 "p.product_condition, p.quantity_available, p.product_status, c.category_name " +
                 "FROM products p " +
                 "JOIN categories c ON p.category_id = c.category_id " +
                 "WHERE p.product_status = 'Available' " +
                 "AND (p.product_name LIKE ? OR p.product_description LIKE ? OR c.category_name LIKE ?) ";

    if (!category.equals("")) sql += "AND c.category_name = ? ";
    if (!condition.equals("")) sql += "AND p.product_condition = ? ";
    if (!minPrice.equals("")) sql += "AND p.price >= ? ";
    if (!maxPrice.equals("")) sql += "AND p.price <= ? ";

    
    
    
    
    //The top part establishses a databse connection with SQL query to fetch available products and ther respective attributes
    
    
    
    stmt = con.prepareStatement(sql);

    int index = 1;
    String keyword = "%" + search + "%";

    stmt.setString(index++, keyword);
    stmt.setString(index++, keyword);
    stmt.setString(index++, keyword);

    //Dynamically ensures filters such as category condition price range for users to filter accordingly 
    
    if (!category.equals("")) stmt.setString(index++, category);
    if (!condition.equals("")) stmt.setString(index++, condition);
    if (!minPrice.equals("")) stmt.setDouble(index++, Double.parseDouble(minPrice));
    if (!maxPrice.equals("")) stmt.setDouble(index++, Double.parseDouble(maxPrice));

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
                <p><strong>Stock:</strong> <%= rs.getInt("quantity_available") %></p>

                <%-- Link to the reviews page fixed earlier --%>
                <a href="product_reviews.jsp?productId=<%= rs.getInt("product_id") %>" style="display:block; margin: 10px 0; color: #007bff;">View Product Reviews</a>

                <form method="post" action="<%= request.getContextPath() %>/cart" style="margin-bottom: 8px;">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="productId" value="<%= rs.getInt("product_id") %>">
                    <button type="submit" class="btn">Add to Cart</button>
                </form>

                <form method="post" action="<%= request.getContextPath() %>/WishlistServlet">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="product_id" value="<%= rs.getInt("product_id") %>">
                    <button type="submit" class="btn-wishlist">♡ Wishlist</button>
                </form>
            </div>
<%
    }
    if (!hasProducts) {
%>
            <p>No products match your criteria please try again.</p>
<%
    }
} catch (Exception e) {
    e.printStackTrace();
%>
            <p>Error loading products. Please check database connection, or please try again Later.</p>
<%
} finally {// Ensures all database and resources are closed to avoid data leakage or connection error 
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

</body>
</html>