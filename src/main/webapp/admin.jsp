<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ page
	import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet"%>
<%@ page import="util.MySQLCon, util.Product, java.util.List"%>




<%
String role = (String) session.getAttribute("role");

if (role == null || !role.equals("admin")) {
	response.sendRedirect("login.jsp?Error=Access denied");
	return;
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Admin Dashboard</title>
<link rel="stylesheet" href="<%=request.getContextPath()%>/styles.css">
</head>
<body>

	<div class="navbar" style="display: block;">
		<h1>Admin Dashboard</h1>
		<p>Welcome, Administrator.</p>
	</div>

	<script>
		function toggleVisibility(id) {
			hideAll();
			var theDiv = document.getElementById(id);
			if (theDiv.style.display == "none" || theDiv.style.display == "") {
				theDiv.style.display = "block";
				switcher.value = id;
			}
		}

		function hideAll() { // this is crude but oh well. hides all divs
			document.getElementById("reports").style.display = "none";
			document.getElementById("monitor").style.display = "none";
			document.getElementById("newProd").style.display = "none";
			document.getElementById("editInformation").style.display = "none";
			document.getElementById("reactivate").style.display = "none";
			document.getElementById("suspend").style.display = "none";
			document.getElementById("changeQuantity").style.display = "none";
			document.getElementById("restockProducts").style.display = "none";
			// changing this was redundant but i'll leave it
		}
	</script>

	<h2>Management Options</h2>
	<ul>
		<li><a href="#" onclick="toggleVisibility('reports')">Analytics and Reports</a></li>
		<li><a href="#" onclick="toggleVisibility('newProd')">Create
				New Product Listing</a></li>
		<li><a href="#" onclick="toggleVisibility('editInformation')">Edit
				Product Information</a></li>
		<li><a href="#" onclick="toggleVisibility('changeQuantity')">Adjust
				Inventory Quantities</a></li>
		<li><a href="#" onclick="toggleVisibility('restockProducts')">Restock
				Products</a></li>

	</ul>

	<br>


	<div class="section">
		<h2>User Management</h2>
		<ul>
			<li><a href="#" onclick="toggleVisibility('monitor')">Monitor
					User Accounts</a></li>
			<li><a href="#" onclick="toggleVisibility('suspend')">Suspend
					User Account</a></li>
			<li><a href="#" onclick="toggleVisibility('reactivate')">Reactivate
					User Account</a></li>
		</ul>
	</div>
	<!-- samantha will do admin and admin servlet -->

	<div id="adminFunctions" class="admin-functions">
		<div id="reports" class="admin-functions-box">
			<h2 class="admin-functions-headers">Analytics and Reports</h2>
			<%
			try (Connection reportCon = MySQLCon.getConnection()) {
				int totalUsers = 0;
				int totalProducts = 0;
				int totalTransactions = 0;
				double totalRevenue = 0;

				try (PreparedStatement countUsers = reportCon.prepareStatement("SELECT COUNT(*) FROM users");
					 ResultSet countUsersRs = countUsers.executeQuery()) {
					if (countUsersRs.next()) {
						totalUsers = countUsersRs.getInt(1);
					}
				}

				try (PreparedStatement countProducts = reportCon.prepareStatement("SELECT COUNT(*) FROM products");
					 ResultSet countProductsRs = countProducts.executeQuery()) {
					if (countProductsRs.next()) {
						totalProducts = countProductsRs.getInt(1);
					}
				}

				try (PreparedStatement countOrders = reportCon.prepareStatement("SELECT COUNT(*), COALESCE(SUM(total_amount), 0) FROM orders WHERE order_status IN ('Paid', 'Completed')");
					 ResultSet countOrdersRs = countOrders.executeQuery()) {
					if (countOrdersRs.next()) {
						totalTransactions = countOrdersRs.getInt(1);
						totalRevenue = countOrdersRs.getDouble(2);
					}
				}
			%>
			<div class="report-grid">
				<div class="report-card"><strong>Total Registered Users</strong><br><%= totalUsers %></div>
				<div class="report-card"><strong>Total Products Listed</strong><br><%= totalProducts %></div>
				<div class="report-card"><strong>Completed Transactions</strong><br><%= totalTransactions %></div>
				<div class="report-card"><strong>Total Revenue</strong><br>$<%= String.format("%.2f", totalRevenue) %></div>
			</div>

			<h3>Monthly Revenue</h3>
			<table class="data-table">
				<tr><th>Month</th><th>Revenue</th></tr>
				<%
				try (PreparedStatement monthly = reportCon.prepareStatement(
						"SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month, SUM(total_amount) AS revenue " +
						"FROM orders WHERE order_status IN ('Paid', 'Completed') GROUP BY DATE_FORMAT(order_date, '%Y-%m') ORDER BY order_month DESC");
					 ResultSet monthlyRs = monthly.executeQuery()) {
					while (monthlyRs.next()) {
				%>
				<tr><td><%= monthlyRs.getString("order_month") %></td><td>$<%= monthlyRs.getBigDecimal("revenue") %></td></tr>
				<%
					}
				}
				%>
			</table>

			<h3>Most Purchased Products</h3>
			<table class="data-table">
				<tr><th>Product</th><th>Quantity Sold</th></tr>
				<%
				try (PreparedStatement topProducts = reportCon.prepareStatement(
						"SELECT p.product_name, SUM(oi.quantity) AS quantity_sold " +
						"FROM order_items oi JOIN products p ON oi.product_id = p.product_id " +
						"GROUP BY p.product_id, p.product_name ORDER BY quantity_sold DESC LIMIT 5");
					 ResultSet topProductsRs = topProducts.executeQuery()) {
					while (topProductsRs.next()) {
				%>
				<tr><td><%= topProductsRs.getString("product_name") %></td><td><%= topProductsRs.getInt("quantity_sold") %></td></tr>
				<%
					}
				}
				%>
			</table>

			<h3>Least Purchased Products</h3>
			<table class="data-table">
				<tr><th>Product</th><th>Quantity Sold</th></tr>
				<%
				try (PreparedStatement lowProducts = reportCon.prepareStatement(
						"SELECT p.product_name, COALESCE(SUM(oi.quantity), 0) AS quantity_sold " +
						"FROM products p LEFT JOIN order_items oi ON p.product_id = oi.product_id " +
						"GROUP BY p.product_id, p.product_name ORDER BY quantity_sold ASC, p.product_name ASC LIMIT 5");
					 ResultSet lowProductsRs = lowProducts.executeQuery()) {
					while (lowProductsRs.next()) {
				%>
				<tr><td><%= lowProductsRs.getString("product_name") %></td><td><%= lowProductsRs.getInt("quantity_sold") %></td></tr>
				<%
					}
				}
				%>
			</table>

			<h3>Low Inventory Alerts</h3>
			<table class="data-table">
				<tr><th>Product</th><th>Quantity Available</th><th>Status</th></tr>
				<%
				try (PreparedStatement lowInventory = reportCon.prepareStatement(
						"SELECT product_name, quantity_available, product_status FROM products WHERE quantity_available < 5 ORDER BY quantity_available ASC");
					 ResultSet lowInventoryRs = lowInventory.executeQuery()) {
					while (lowInventoryRs.next()) {
				%>
				<tr>
					<td><%= lowInventoryRs.getString("product_name") %></td>
					<td><%= lowInventoryRs.getInt("quantity_available") %></td>
					<td><%= lowInventoryRs.getString("product_status") %></td>
				</tr>
				<%
					}
				}
				%>
			</table>
			<%
			} catch (Exception e) {
				e.printStackTrace();
			%>
			<p>Error loading analytics.</p>
			<%
			}
			%>
		</div>

		<div id="newProd" class="admin-functions-box">
			<form id="newProdForm" action="<%= request.getContextPath() %>/AdminServlet" method="post">
				<fieldset>
					<legend>
						<h2 class="admin-functions-headers">Create New Listing</h2>
					</legend>
					<label for="productName">Product Name:</label> <input type="text"
						id="productName" name="productName" class="formStuff" required>
					<br>
					<br> <label for="info">Information:</label><br>
					<textarea id="info" name="info" class="formStuff" required> </textarea>
					<br>
					<br> <label for="price">Price:</label> <input type="text"
						id="price" name="price" class="formStuff" required> 
					<br>
					<br> <label for="condition">Condition:</label> 
					<select name="condition" id="condition" required>
    					<option value="New">New</option>
    					<option value="Like New">Like New</option>
    					<option value="Good">Good</option>
    					<option value="Fair">Fair</option>
    					<option value="Used">Used</option>
  					</select> 
					<br>
					<br> <label for="quantityAvail">Quantity:</label> <input
						type="text" id="quantityAvail" name="quantityAvail"
						class="formStuff" required> 
					<br>
					<br> <label for="productStatus">Status:</label> 
					<select name="productStatus" id="productStatus" required>
    					<option value="Available" selected>Available</option>
    					<option value="Out_of_Stock">Out of Stock</option>
    					<option value="Inactive">Inactive</option>
  					</select>
					<br>
					<br> <label for="categoryId">Category ID:</label> <input
						type="text" id="categoryId" name="categoryId" class="formStuff"
						required> 
					<br>
					<br> <label for="createdByAdminId">Admin ID:</label> <input
						type="text" id="createdByAdminId" name="createdByAdminId"
						class="formStuff" required> 
					<br>
					<br>

					<button type="submit">Add New Product</button> <!-- eclipse auto format makes me mad -->
				</fieldset>
			</form>
		</div>

		<div id="editInformation" class="admin-functions-box">
			<h2 class="admin-functions-headers" id ="swivel">Edit Product Information</h2>
			<table id="editTable">
				<thead>
					<tr>
						<th>ID</th>
            			<th>Name</th>
            			<th>Information</th>
            			<th>Price</th>
            			<th>Condition</th>
            			<th>Quantity</th>
            			<th>Status</th>
            			<th>Date</th>
            			<th>Low Stock?</th>
            			<th>Category ID</th>
            			<th>Created by:</th>
					</tr>
				</thead>
				<tbody>
					<% 
						try {
						List<Product> theProducts = request.getAttribute("theProducts");
						for (Product product : theProducts){
					%>
						<tr>
							<td><%= product.getProductId() %></td>
							<td><%= product.getProductName() %></td>
							<td><%= product.getInfo() %></td>
							<td><%= product.getPrice() %></td>
							<td><%= product.getCondition() %></td>
							<td><%= product.getQuantityAvail() %></td>
							<td><%= product.getProductStatus() %></td>
							<td><%= product.getDateAdded() %></td>
							<td><%= product.getLowStockNotice() %></td>
							<td><%= product.getCategoryId() %></td>
							<td><%= product.getCreatedByAdminId() %></td>
							<td>
								<a href="<%= request.getContextPath() %>/AdminServlet" id="changeQuantity"></a>
								<a href="<%= request.getContextPath() %>/AdminServlet"></a>
							</td>
							
						</tr>
						<% }} catch (Exception e) {
							e.printStackTrace();
						} %>
				</tbody>
			</table>
		</div>

		<div id="changeQuantity" class="admin-functions-box">
			<h2 class="admin-functions-headers">Adjust Inventory Quantities</h2>
		</div>

		<div id="restockProducts" class="admin-functions-box">
			<h2 class="admin-functions-headers">Restock Products</h2>
		</div>

		<div id="monitor" class="admin-functions-box">
			<h2 class="admin-functions-headers">Monitor Users</h2>
		</div>

		<div id="suspend" class="admin-functions-box">
			<h2 class="admin-functions-headers">Suspend Users</h2>
		</div>

		<div id="reactivate" class="admin-functions-box">
			<h2 class="admin-functions-headers">Reactivate Users</h2>
		</div>
	</div>



</body>
</html>