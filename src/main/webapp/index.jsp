<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<%


%>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Spartan Exchange</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/styles.css">
</head>
<body>

<header class="navbar">
    <div class="logo">Spartan Exchange</div>

 <div class="nav-search">
    <input type="text" id="search-input" placeholder="Search products...">
    <button type="button" onclick="searchProducts()">Search</button>
</div>

    <nav class="nav-links">
 
        <a href="#">Wishlist</a>
        <a href="#">Help</a>
        <a href="#">Cart (0)</a>
    </nav>
</header>

<main>
    <section>
        <h2>Available Products</h2>
        <div class="product-container">
            <div class="product-card">
                <h3>Textbook</h3>
                <p>Good condition CS book</p>
                <p>$40</p>
                <button>Add to Cart</button>
            </div>

       <div class="product-container" id="product-grid"></div>
       <script>
const products = [
    {
        id: 1,
        name: "Calculus Textbook",
        price: 19.99,
        image: "https://via.placeholder.com/200",
        description: "Used textbook in good condition"
    },
    {
        id: 2,
        name: "Laptop Stand",
        price: 29.99,
        image: "https://via.placeholder.com/200",
        description: "Adjustable aluminum stand"
    },
    {
        id: 3,
        name: "Desk Lamp",
        price: 39.99,
        image: "https://via.placeholder.com/200",
        description: "LED lamp for study desk"
    }
];

function displayProducts(productList) {
const productGrid = document.getElementById("product-grid");
productGrid.innerHTML = "";

 if (productList.length === 0) {
 productGrid.innerHTML = "<p>No matching products found.</p>";
    return;
    }

 productList.forEach(product => {
   const div = document.createElement("div");
    div.className = "product-card";

   div.innerHTML =
            "<img src='" + product.image + "'>" +
            "<h3>" + product.name + "</h3>" +
            "<p>" + product.description + "</p>" +
            "<p>$" + product.price.toFixed(2) + "</p>";
            productGrid.appendChild(div);
    });
}

function searchProducts() {
  const value = document.getElementById("search-input").value.toLowerCase().trim();
    const filtered = products.filter(p =>
        p.name.toLowerCase().includes(value) ||
        p.description.toLowerCase().includes(value)
    );

  displayProducts(filtered);
}

displayProducts(products);
</script>
    </section>
</main>

<footer>
    <p>&copy; 2026 Spartan Exchange</p>
</footer>

<script src="<%= request.getContextPath() %>/js/script.js"></script>






</body>
</html>