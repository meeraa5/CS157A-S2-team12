<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="util.MySQLCon" %>

<%-- The imports make necessary formatting as it makes sure its under java but the content is in HTML formating --%>
<%-- The second and third makes it possible for database connection its a live represantation to connection to databse--%>





<%
Connection con = null; //Assign database later 
PreparedStatement stmt = null; //Assign sql query with try block
ResultSet rs = null; //Store query results when got data from the database

String search = request.getParameter("search");
if (search == null) {
    search = "";
}
%>

<%-- Declaring the values first before assigning real values later with the help of try block--%>
<%--Because we do not have the values yet its in database --%>




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

    <form class="nav-search" method="get" action="<%= request.getContextPath() %>/index.jsp">
    <input type="text" id="search-input" name="search" placeholder="Search products..."
           value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>">
    <button type="submit">Search</button>
</form>

    <nav class="nav-links">
        <a href="<%= request.getContextPath() %>/wishlist.jsp">Wishlist</a>
        <a href="<%= request.getContextPath() %>/orders.jsp">Orders</a>
        <a href="#">Help</a>
        <a href="<%= request.getContextPath() %>/cart.jsp">Cart (0)</a>
        <!-- <a href="#">Logout</a> -->
    </nav>
</header>

<main>
    <section>
        <h2>Available Products</h2>
        <div class="product-container">
        
<!--  Mainly for page structure and layout
 Collects search input 
 Sends request to tomcat server
 Does not have database query by itself thats where the try block below comes in    -->    
        
        
<%
try { //Main part where it connects to the database
    con = MySQLCon.getConnection(); //Try block allows us to safely run database code because database code can fail 
//This helps connect to database 


    String sql = "SELECT p.product_id, p.product_name, p.product_description, p.price, " + 
                 "p.product_condition, p.quantity_available, p.product_status, c.category_name " +
                 "FROM products p " + //For exmple goes to products table
                 "JOIN categories c ON p.category_id = c.category_id " + //Links categories id with products category 
                 "WHERE p.product_status = 'Available' " + //Makes sure its condition is only for available products
                 "AND (p.product_name LIKE ? OR p.product_description LIKE ? OR c.category_name LIKE ?)";
//This retrieves data from the tables and combines related tables
//Chooses which attributes from the database to return 
		
    stmt = con.prepareStatement(sql);

    String keyword = "%" + search + "%";
    stmt.setString(1, keyword);
    stmt.setString(2, keyword);
    stmt.setString(3, keyword);

    rs = stmt.executeQuery();

    boolean hasProducts = false;

    while (rs.next()) {
        hasProducts = true;
%>
            <div class="product-card">
                <h3><%= rs.getString("product_name") %></h3> //Gets product name 
                <p><%= rs.getString("product_description") %></p> //Product description
                <p><strong>Price:</strong> $<%= rs.getBigDecimal("price") %></p> //Price
                <p><strong>Condition:</strong> <%= rs.getString("product_condition") %></p> //Condition
                <p><strong>Category:</strong> <%= rs.getString("category_name") %></p> //Category name
                <p><strong>Remaining Quantity:</strong> <%= rs.getInt("quantity_available") %></p> //Quantity
                <form method="post" action="<%= request.getContextPath() %>/AddToCartServlet">
    			<input type="hidden" name="product_id" value="<%= rs.getInt("product_id") %>">
    			<button type="submit">Add to Cart</button>
				</form>
                <p><a href="<%= request.getContextPath() %>/product_reviews.jsp?productId=<%= rs.getInt("product_id") %>">View Reviews</a></p>
            </div>
            
            //This displays one product for the current row of the results
            //This makes sure the loop through 
               
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
    try { if (rs != null) rs.close(); } catch (Exception e) {}
    try { if (stmt != null) stmt.close(); } catch (Exception e) {}
    try { if (con != null) con.close(); } catch (Exception e) {}
}
%>

//Exceptions to ensure that if something goes wrong on the try block at the top it displays specific messages
//In which we want to display 

        </div>
    </section>
</main>

<footer>
    <p>&copy; 2026 Spartan Exchange</p>
</footer>

</body>
</html>