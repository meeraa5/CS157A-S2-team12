<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help - Spartan Exchange</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles.css">
</head>
<body>

<header class="navbar">
    <div class="logo">Spartan Exchange</div>
    <nav class="nav-links">
        <a href="<%= request.getContextPath() %>/index.jsp">Home</a>
        <a href="<%= request.getContextPath() %>/WishlistServlet">Wishlist</a>
        <a href="<%= request.getContextPath() %>/cart.jsp">Cart</a>
        <a href="<%= request.getContextPath() %>/AuthServlet?action=logout">Logout</a>
    </nav>
</header>

<main>
    <section class="product-card">
        <h2>Help</h2>
        <p>Use Spartan Exchange to browse available products, save items to your wishlist, and add products to your cart.</p>

        <h3>Shopping</h3>
        <p>Use the search and filter options on the home page to find products by name, category, condition, or price range.</p>

        <h3>Wishlist</h3>
        <p>Click "Add to Wishlist" on a product to save it for later. Open the Wishlist page from the navigation bar to view saved items.</p>

        <h3>Cart</h3>
        <p>Click "Add to Cart" on a product to start an order. Open the Cart page to review your selected items before checkout.</p>
    </section>
</main>

<footer>
    <p>&copy; 2026 Spartan Exchange</p>
</footer>

</body>
</html>
